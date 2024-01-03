unit PascalType.Unicode.Builder.UnicodeData;

interface

uses
  PascalType.Unicode.Builder.CharacterSet,
  PascalType.Unicode.Builder.Categories,
  PascalType.Unicode.Builder.Decomposition,
  PascalType.Unicode.Builder.Numbers,
  PascalType.Unicode.Builder.CaseMapping;

const
  sUnicodeDataFileName = 'UnicodeData.txt';

//----------------------------------------------------------------------------------------------------------------------
//
//      UnicodeData
//
//----------------------------------------------------------------------------------------------------------------------
type
  UnicodeData = record
  public
    class procedure Parse(const AFilename: string;
      var Categories: TUnicodeCategories;
      var CCCs: TCharacterSetList;
      Decompositions: TUnicodeDecompositions;
      Numbers: TUnicodeNumbers;
      CaseMapping: TUnicodeCaseMapping); static;
  end;


//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  Generics.Collections,
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  PascalType.Unicode,
  PascalType.Unicode.Builder.Common,
  PascalType.Unicode.Builder.Logger;

//----------------------------------------------------------------------------------------------------------------------
//
//      UnicodeData
//
//----------------------------------------------------------------------------------------------------------------------
class procedure UnicodeData.Parse(const AFilename: string;
  var Categories: TUnicodeCategories;
  var CCCs: TCharacterSetList;
  Decompositions: TUnicodeDecompositions;
  Numbers: TUnicodeNumbers;
  CaseMapping: TUnicodeCaseMapping);
var
  SymCharacters: TDictionary<string, Cardinal>;
  Lines,
  Line: TStringList;
  I, J: Integer;
  RangePending: Boolean;
  StartCode: TPascalTypeCodePoint;
  EndCode: TPascalTypeCodePoint;
  K, Tag: TCompatibilityFormattingTag;
  Name, SymName: string;
  Decomposition: TPascalTypeCodePoints;

  // number representation
  Nominator,
  Denominator: Int64;

  // case mapping
  AMapping: TPascalTypeCodePoints;
begin
  if (not TFile.Exists(AFileName)) then
    Logger.FatalError('[Fatal error] ''%s'' not found', [AFileName], 1);

  if Logger.Verbose then
  begin
    Logger.Writeln;
    Logger.Writeln('Reading data from ' + AFileName + ':');
  end;

  Lines := nil;
  SymCharacters := nil;
  Line := nil;
  try
    Lines := TStringList.Create;
    SymCharacters := TDictionary<string, Cardinal>.Create;
    Line := TStringList.Create;

    // Unicode data files are about 600K in size, so don't hesitate and load them in one rush.
    Lines.LoadFromFile(AFileName);

    // Go for each line, organization is one line for a code point or two consecutive lines
    // for a range of code points.
    RangePending := False;
    StartCode := 0;
    for I := 0 to Lines.Count - 1 do
    begin
      SplitLine(Lines[I], Line);
      // continue only if the line is not empty
      if Line.Count > 1 then
      begin
        Name := UpperCase(Line[1]);
        // Line contains now up to 15 entries, starting with the code point value
        if RangePending then
        begin
          // last line was a range start, so this one must be the range end
          if Pos(', LAST>', Name) = 0 then
            Logger.FatalError('Range end expected in line %d.', [I + 1]);
          EndCode := StrToInt('$' + Line[0]);

          // register general category
          Categories.AddRange(StartCode, EndCode, Line[2]);

          // register bidirectional category
          Categories.AddRange(StartCode, EndCode, Line[4]);

          // mark the range as containing assigned code points
          Categories.AddRange(StartCode, EndCode, ccAssigned);
          RangePending := False;
        end
        else
        begin
          StartCode := StrToInt('$' + Line[0]);
          // check for the start of a range
          if Pos(', FIRST>', Name) > 0 then
            RangePending := True
          else
          begin
            // normal case, one code point must be parsed

            // 1) categorize code point as being assinged
            Categories.Add(StartCode, ccAssigned);

            // 2) find symmetric shapping characters
            // replace LEFT by RIGHT and vice-versa
            SymName := StringReplace(Name, 'LEFT', 'LLEEFFTT', [rfReplaceAll]);
            SymName := StringReplace(SymName, 'RIGHT', 'LEFT', [rfReplaceAll]);
            SymName := StringReplace(SymName, 'LLEEFFTT', 'RIGHT', [rfReplaceAll]);
            if Name <> SymName then
            begin
              if (SymCharacters.TryGetValue(SymName, EndCode)) then
              begin
                Categories.Add(StartCode, ccSymmetric);
                Categories.Add(EndCode, ccSymmetric);
              end else
                SymCharacters.Add(Name, StartCode);
            end;

            if Line.Count < 3 then
              Continue;
            // 3) categorize the general character class
            Categories.Add(StartCode, Line[2]);

            if Line.Count < 4 then
              Continue;
            // 4) register canonical combining class
            begin
              var CCClass := StrToInt(Line[3]);
              // Most of the code points have a combining class of 0 (the default class, so to speak)
              // hence we don't need to store them.
              if (CCClass <> 0) then
                CCCs.Data[CCClass].SetCharacter(StartCode);
            end;

            if Line.Count < 5 then
              Continue;
            // 5) categorize the bidirectional character class
            Categories.Add(StartCode, Line[4]);

            if Line.Count < 6 then
              Continue;
            // 6) if the character can be decomposed then keep its decomposed parts
            //    and add it to the can-be-decomposed category
            var DecompositionsStr := Line[5].Split([#32], TStringSplitOptions.ExcludeEmpty);
            Tag := cftCanonical;

            if (Length(DecompositionsStr) > 0) and (Pos('<', DecompositionsStr[0]) > 0) then
            begin
              for K := Low(DecompositionTags) to High(DecompositionTags) do
              begin
                if DecompositionTags[K] = DecompositionsStr[0] then
                begin
                  Tag := K;
                  Break;
                end;
              end;
              if Tag = cftCanonical then
                Logger.FatalError('Unknown decomposition tag ' + DecompositionsStr[0]);
              if Tag = cftNoBreak then
                Categories.Add(StartCode, ccNonBreaking);
              Delete(DecompositionsStr, 0, 1);
            end;

            if (Length(DecompositionsStr) > 0) and (Pos('<', DecompositionsStr[0]) = 0) then
            begin
              // consider only canonical decomposition mappings
              SetLength(Decomposition, Length(DecompositionsStr));
              for J := 0 to High(DecompositionsStr) do
                Decomposition[J] := StrToInt('$' + DecompositionsStr[J]);

              // If there is more than one code in the temporary decomposition
              // array then add the character with its decomposition.
              // (outchy) latest unicode data have aliases to link items having the same Decomposition
              //if DecompTempSize > 1 then
              Categories.Add(StartCode, ccComposed);
              Decompositions.Add(StartCode, Tag, Decomposition);
            end;

            if Line.Count < 9 then
              Break;
            // 7) examine if there is a numeric representation of this code
            var NumberStr := Line[8].Split(['/'], TStringSplitOptions.ExcludeEmpty);
            if (Length(NumberStr) = 1) then
            begin
              Nominator := StrToInt64(NumberStr[0]);
              Denominator := 1;
              Numbers.Add(StartCode, Nominator, Denominator);
            end else
            if (Length(NumberStr) = 2) then
            begin
              Nominator := StrToInt64(NumberStr[0]);
              Denominator := StrToInt64(NumberStr[1]);
              Numbers.Add(StartCode, Nominator, Denominator);
            end else
            if (Length(NumberStr) <> 0) then
              Logger.FatalError('Unknown number ' + Line[8]);

            if Line.Count < 10 then
              Continue;
            // 8) read mirrored character
            SymName := Line[9];
            if SymName = 'Y' then
              Categories.Add(StartCode, ccMirroring)
            else
            if SymName <> 'N' then
              Logger.FatalError('Unknown mirroring character');

            if Line.Count < 13 then
              Continue;
            SetLength(AMapping, 1);
            // 9) read simple upper case mapping (only 1 to 1 mappings)
            if (Length(Line[12]) > 0) then
            begin
              AMapping[0] := StrToInt('$' + Line[12]);
              CaseMapping.AddUpperCase(StartCode, AMapping);
            end;

            if Line.Count < 14 then
              Continue;
            // 10) read simple lower case mapping
            if (Length(Line[13]) > 0) then
            begin
              AMapping[0] := StrToInt('$' + Line[13]);
              CaseMapping.AddLowerCase(StartCode, AMapping);
            end;

            if Line.Count < 15 then
              Continue;
            // 11) read title case mapping
            if (Length(Line[14]) > 0) then
            begin
              AMapping[0] := StrToInt('$' + Line[14]);
              CaseMapping.AddTitleCase(StartCode, AMapping);
            end;
          end;
        end;
      end;

      if Logger.Verbose then
        Logger.Write(#13'  %d%% done', [Round(100 * I / Lines.Count)]);
    end;
  finally
    Lines.Free;
    Line.Free;
    SymCharacters.Free;
  end;

  if Logger.Verbose then
    Logger.Writeln;
end;

end.
