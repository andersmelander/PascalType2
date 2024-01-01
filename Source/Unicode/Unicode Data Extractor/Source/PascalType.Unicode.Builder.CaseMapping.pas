unit PascalType.Unicode.Builder.CaseMapping;

interface

uses
  PascalType.Unicode,
  PascalType.Unicode.Builder.ResourceWriter;

const
  CaseFoldingFileName = 'CaseFolding.txt';
  SpecialCasingFileName = 'SpecialCasing.txt';

//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeCaseMapping
//
//----------------------------------------------------------------------------------------------------------------------
// Collection of case mappings for each code point which is cased
//----------------------------------------------------------------------------------------------------------------------
type
  TUnicodeCaseMapping = class
  private type
    TCase = record
      Code: Cardinal;
      Fold: TPascalTypeCodePoints;        // Normalized case for case independent string comparison (e.g. for "ß" this is "ss")
      Lower: TPascalTypeCodePoints;       // Lower case (e.g. for "ß" this is "ß")
      Title: TPascalTypeCodePoints;       // Tile case (used mainly for compatiblity, ligatures etc., e.g. for "ß" this is "Ss")
      Upper: TPascalTypeCodePoints;       // Upper case (e.g. for "ß" this is "SS")
    end;

  private
    FCaseMapping: TArray<TCase>;

  private
    function FindOrAddCaseEntry(Code: Cardinal): Integer;

    procedure AddFoldCase(Code: Cardinal; const FoldMapping: TPascalTypeCodePoints);
  public
    procedure ParseCaseFolding(const AFilename: string);
    procedure ParseSpecialCasing(const AFilename: string);

    procedure AddLowerCase(Code: Cardinal; const Lower: TPascalTypeCodePoints);
    procedure AddUpperCase(Code: Cardinal; const Upper: TPascalTypeCodePoints);
    procedure AddTitleCase(Code: Cardinal; const Title: TPascalTypeCodePoints);

    procedure WriteAsResource(AResourceWriter: TResourceWriter);
  end;

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  Generics.Defaults,
  Generics.Collections,
  System.Classes,
  System.IOUtils,
  System.StrUtils,
  System.SysUtils,
  PascalType.Unicode.Builder.Common,
  PascalType.Unicode.Builder.Logger;

//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeCaseMapping
//
//----------------------------------------------------------------------------------------------------------------------
function TUnicodeCaseMapping.FindOrAddCaseEntry(Code: Cardinal): Integer;
// Used to look up the given code in the case mapping array. If no entry with the given code
// exists then it is added implicitely.
begin
  var NewCase := Default(TCase);
  NewCase.Code := Code;

  if (not TArray.BinarySearch<TCase>(FCaseMapping, NewCase, Result, TComparer<TCase>.Construct(
    function(const A, B: TCase): integer
    begin
      Result := (integer(A.Code) - integer(B.Code));
    end))) then
    Insert(NewCase, FCaseMapping, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCaseMapping.ParseCaseFolding(const AFilename: string);
// Casefolding data is given by yet another optional file. Usually case insensitive string comparisons
// are done by converting the strings to lower case and compare them, but in some cases
// this is not enough. We only add those special cases to our internal casing array.
var
  Reader: TStreamReader;
  Line: string;
  Values: TArray<string>;
  Code: Cardinal;
  Mapping: TPascalTypeCodePoints;
begin
  if not TFile.Exists(AFilename) then
  begin
    Logger.Warning(AFilename + ' not found, ignoring case folding');
    exit;
  end;

  if Logger.Verbose then
  begin
    Logger.Writeln;
    Logger.Writeln('Reading case folding data from ' + AFilename + ':');
  end;

  Reader := TStreamReader.Create(AFilename);
  try

    while (not Reader.EndOfStream) do
    begin

       // Layout of one line is:
       // <code>; <status>; <mapping>; # <name>
       // where status is either "L" describing a normal lowered letter
       // and "E" for exceptions (only the second is read)

      Line := Reader.ReadLine.Trim;
      if (Line = '') or (Line.StartsWith('#')) then
        continue;

      Values := Line.Split([';']);

      if (Length(Values) < 3) then
        continue;

      // The code currently being under consideration
      Code := StrToInt('$' + Values[0]);

      // Type of mapping
      if ((Values[1] = 'C') or (Values[1] = 'F')) and (Values[2].Trim <> '') then
      begin
        SplitCodes(Values[2].Trim, Mapping);
        AddFoldCase(Code, Mapping);
      end;

      if Logger.Verbose then
        Logger.Write(#13'  %d%% done', [Round(100 * Reader.BaseStream.Position / Reader.BaseStream.Size)]);

    end;

  finally
    Reader.Free;
  end;

  if Logger.Verbose then
    Logger.Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCaseMapping.ParseSpecialCasing(const AFilename: string);
// One-to-many case mappings are given by a separate file which is in a different format
// than the Unicode data file. This procedure parses this file and adds those extended mappings
// to the internal array.
var
  Lines,
  Line: TStringList;
  I: Integer;
  Code: Cardinal;
  AMapping: TPascalTypeCodePoints;
begin
  if not TFile.Exists(AFilename) then
  begin
    Logger.Warning(AFilename + ' not found, ignoring special casing');
    exit;
  end;

  if Logger.Verbose then
  begin
    Logger.Writeln;
    Logger.Writeln('Reading special casing data from ' + AFilename + ':');
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFilename);
    Line := TStringList.Create;
    try
      for I := 0 to Lines.Count - 1 do
      begin
        SplitLine(Lines[I], Line);

        // Continue only if the line is not empty
        if (Line.Count > 0) and (Length(Line[0]) > 0) then
        begin
          Code := StrToInt('$' + Line[0]);

          // Lower case
          if Length(Line[1]) > 0 then
          begin
            SplitCodes(Line[1], AMapping);
            AddLowerCase(Code, AMapping);
          end;

          // Title case
          if Length(Line[2]) > 0 then
          begin
            SplitCodes(Line[2], AMapping);
            AddTitleCase(Code, AMapping);
          end;

          // Upper case
          if Length(Line[3]) > 0 then
          begin
            SplitCodes(Line[3], AMapping);
            AddUpperCase(Code, AMapping);
          end;
        end;

        if Logger.Verbose then
          Logger.Write(#13'  %d%% done', [Round(100 * I / Lines.Count)]);
      end;
    finally
      Line.Free;
    end;
  finally
    Lines.Free;
  end;

  if Logger.Verbose then
    Logger.Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCaseMapping.WriteAsResource(AResourceWriter: TResourceWriter);
begin
  // Record how many case mapping entries we have
  AResourceWriter.WriteResourceCardinal(Length(FCaseMapping));

  for var i := 0 to High(FCaseMapping) do
  begin
    // Store every available case mapping, consider one-to-many mappings

    // a) Actual code point
    AResourceWriter.WriteResourceChar(FCaseMapping[i].Code);

    // b) Normalized case
    AResourceWriter.WriteResourceByte(Length(FCaseMapping[i].Fold));
    AResourceWriter.WriteResourceCharArray(FCaseMapping[i].Fold);

    // c) Lower case
    AResourceWriter.WriteResourceByte(Length(FCaseMapping[i].Lower));
    AResourceWriter.WriteResourceCharArray(FCaseMapping[i].Lower);

    // d) Title case
    AResourceWriter.WriteResourceByte(Length(FCaseMapping[i].Title));
    AResourceWriter.WriteResourceCharArray(FCaseMapping[i].Title);

    // e) Upper case
    AResourceWriter.WriteResourceByte(Length(FCaseMapping[i].Upper));
    AResourceWriter.WriteResourceCharArray(FCaseMapping[i].Upper);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCaseMapping.AddFoldCase(Code: Cardinal; const FoldMapping: TPascalTypeCodePoints);
var
  Index: Integer;
begin
  Index := FindOrAddCaseEntry(Code);
  if (Length(FCaseMapping[Index].Fold) = 0) then
    FCaseMapping[Index].Fold := Copy(FoldMapping)
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCaseMapping.AddLowerCase(Code: Cardinal; const Lower: TPascalTypeCodePoints);
var
  Index: Integer;
begin
  Index := FindOrAddCaseEntry(Code);
  if (Length(FCaseMapping[Index].Lower) = 0) then
    FCaseMapping[Index].Lower := Copy(Lower)
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCaseMapping.AddUpperCase(Code: Cardinal; const Upper: TPascalTypeCodePoints);
var
  Index: Integer;
begin
  Index := FindOrAddCaseEntry(Code);
  if (Length(FCaseMapping[Index].Upper) = 0) then
    FCaseMapping[Index].Upper := Copy(Upper)
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCaseMapping.AddTitleCase(Code: Cardinal; const Title: TPascalTypeCodePoints);
var
  Index: Integer;
begin
  Index := FindOrAddCaseEntry(Code);
  if (Length(FCaseMapping[Index].Title) = 0) then
    FCaseMapping[Index].Title := Copy(Title)
end;

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

end.
