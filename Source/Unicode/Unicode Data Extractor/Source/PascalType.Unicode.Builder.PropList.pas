unit PascalType.Unicode.Builder.PropList;

interface

uses
  PascalType.Unicode.Builder.Categories;

const
  sPropListFileName = 'PropList.txt';

//----------------------------------------------------------------------------------------------------------------------
//
//      UnicodePropList
//
//----------------------------------------------------------------------------------------------------------------------
type
  UnicodePropList = record
  public
    class procedure Parse(const AFilename: string; var Categories: TUnicodeCategories); static;
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
//      UnicodePropList
//
//----------------------------------------------------------------------------------------------------------------------
class procedure UnicodePropList.Parse(const AFilename: string; var Categories: TUnicodeCategories);
var
 Lines,
 Line: TStringList;
 I, SeparatorPos: Integer;
 Start, Stop: Cardinal;
begin
  if not TFile.Exists(AFileName) then
  begin
    Logger.Warning(AFileName + ' not found, ignoring property list');
    exit;
  end;

  if Logger.Verbose then
  begin
    Logger.WriteLn;
    Logger.WriteLn('Reading property list from ' + AFileName + ':');
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFileName);
    Line := TStringList.Create;
    try
      for I := 0 to Lines.Count - 1 do
      begin
        // Layout of one line is:
        // <range> or <char>; <property>
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
            Categories.AddRange(Start, Stop, Line[1]);
          end
          else
          begin
            Start := StrToInt('$' + Line[0]);
            Categories.Add(Start, Line[1]);
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

end.
