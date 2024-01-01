unit PascalType.Unicode.Builder.DerivedNormalizationProps;

interface

uses
  PascalType.Unicode.Builder.Decomposition;

const
  sDerivedNormalizationPropsFileName = 'DerivedNormalizationProps.txt';

//----------------------------------------------------------------------------------------------------------------------
//
//      UnicodeDerivedNormalizationProps
//
//----------------------------------------------------------------------------------------------------------------------
type
  UnicodeDerivedNormalizationProps = record
  public
    class procedure Parse(const AFilename: string; Compositions: TUnicodeCompositions); static;
  end;


//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  PascalType.Unicode.Builder.Common,
  PascalType.Unicode.Builder.Logger;

//----------------------------------------------------------------------------------------------------------------------
//
//      UnicodeDerivedNormalizationProps
//
//----------------------------------------------------------------------------------------------------------------------
class procedure UnicodeDerivedNormalizationProps.Parse(const AFilename: string; Compositions: TUnicodeCompositions);
// parse DerivedNormalizationProps looking for composition exclusions
var
 Lines,
 Line: TStringList;
 I, SeparatorPos: Integer;
 Start, Stop: Cardinal;
begin
  if not TFile.Exists(AFileName) then
  begin
    Logger.Warning(AFileName + ' not found, ignoring derived normalization');
    exit;
  end;

  if Logger.Verbose then
  begin
    Logger.WriteLn;
    Logger.WriteLn('Reading derived normalization props from ' + AFileName + ':');
  end;

  Lines := TStringList.Create;
 try
   Lines.LoadFromFile(AFileName);
   Line := TStringList.Create;
   try
     for I := 0 to Lines.Count - 1 do
     begin
       // Layout of one line is:
       // <range>; <options> [;...] ; # <name>
       SplitLine(Lines[I], Line);
       // continue only if the line is not empty
       if (Line.Count > 0) and (Length(Line[0]) > 1) then
       begin
         // the range currently being under consideration
         SeparatorPos := Pos('..', Line[0]);
         if SeparatorPos > 0 then
         begin
           Start := StrToInt('$' + Copy(Line[0], 1, SeparatorPos - 1));
           Stop := StrToInt('$' + Copy(Line[0], SeparatorPos + 2, MaxInt));
         end
         else
         begin
           Start := StrToInt('$' + Line[0]);
           Stop := Start;
         end;
         // first option is considered
         if SameText(Line[1], 'Full_Composition_Exclusion') then
           Compositions.AddExclusions(Start, Stop);
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

end.
