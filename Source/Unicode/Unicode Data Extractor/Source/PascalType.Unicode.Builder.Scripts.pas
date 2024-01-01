unit PascalType.Unicode.Builder.Scripts;

interface

uses
  PascalType.Unicode,
  PascalType.Unicode.Builder.CharacterSet,
  PascalType.Unicode.Builder.ResourceWriter;

const
  sScriptsFileName = 'Scripts.txt';

//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeScripts
//
//----------------------------------------------------------------------------------------------------------------------
type
  TUnicodeScripts = record
  private
    FScripts: TCharacterSetList;

    procedure Add(FirstCode, LastCode: TPascalTypeCodePoint; AScript: TUnicodeScript); // Actually array[TUnicodeScript] of TCharacterSet;
  public
    procedure Parse(const AFilename: string);

    procedure WriteAsResource(AResourceWriter: TResourceWriter);
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
  PascalType.Unicode.Builder.Logger;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeScripts.Add(FirstCode, LastCode: TPascalTypeCodePoint; AScript: TUnicodeScript);
begin
  if (AScript = usZzzz) then
    exit;

  while (FirstCode <= LastCode) do
  begin
    FScripts.Data[Ord(AScript)].SetCharacter(FirstCode);
    Inc(FirstCode);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeScripts.Parse(const AFilename: string);
(*
The format of this file is similar to that of Blocks.txt [Blocks]. The fields are separated by semicolons. The first
field contains either a single code point or the first and last code points in a range separated by “..”. The second
field provides the script property value for that range. The comment (after a #) indicates the General_Category and the
character name. For each range, it gives the character count in square brackets and uses the names for the first and
last characters in the range. For example:

    0B01;       Oriya # Mn       ORIYA SIGN CANDRABINDU
    0B02..0B03; Oriya # Mc   [2] ORIYA SIGN ANUSVARA..ORIYA SIGN VISARGA

The default value for the Script property is Unknown, given to all code points that are not explicitly mentioned in the
data file.
*)
var
  Reader: TStreamReader;
  Line: string;
  Columns: TArray<string>;
  Codes: TArray<string>;
  FirstCode, LastCode: TPascalTypeCodePoint;
  Script: TUnicodeScript;
  i: integer;
begin
  if not TFile.Exists(AFileName) then
  begin
    Logger.Warning(AFileName + ' not found, ignoring scripts');
    exit;
  end;

  if Logger.Verbose then
  begin
    Logger.Writeln;
    Logger.Writeln('Reading scripts data from ' + AFileName + ':');
  end;

  var ScriptMap := TDictionary<string, TUnicodeScript>.Create;
  try
    for Script := Low(TUnicodeScript) to High(TUnicodeScript) do
    begin
      var ISO15924 := PascalTypeUnicode.ScriptToISO15924(Script);
      if (ISO15924.Alias <> '') then
      begin
        if (not ScriptMap.TryAdd(ISO15924.Alias, Script)) then
          ScriptMap.Add(ISO15924.Alias+'_v2', Script); // E.g. 'Georgian'
      end;
    end;

    (*
    #  All code points not explicitly listed for Script
    #  have the value Unknown (scZzzz = 999).
    *)

    Reader := TStreamReader.Create(AFileName);
    try

      while (not Reader.EndOfStream) do
      begin
        // 0B01;       Oriya # Mn       ORIYA SIGN CANDRABINDU
        // 0B02..0B03; Oriya # Mc   [2] ORIYA SIGN ANUSVARA..ORIYA SIGN VISARGA

        Line := Reader.ReadLine;
        i := Pos('#', Line);
        if (i > 0) then
        begin
          while (i > 1) and (Line[i-1] = ' ') do
            Dec(i);
          Delete(Line, i, MaxInt);
        end;
        if (Line = '') then
          continue;

        Columns := Line.Split([';']);

        if (Length(Columns) < 2) then
          continue;

        Codes := Columns[0].Trim.Split(['..']);
        FirstCode := StrToInt('$'+Codes[0]);
        if (Length(Codes) > 1) then
          LastCode := StrToInt('$'+Codes[1])
        else
          LastCode := FirstCode;

        if (ScriptMap.TryGetValue(Columns[1].Trim, Script)) then
          Add(FirstCode, LastCode, Script);

        if Logger.Verbose then
          Logger.Write(#13'  %d%% done', [Round(100 * Reader.BaseStream.Position / Reader.BaseStream.Size)]);

      end;

    finally
      Reader.Free;
    end;
  finally
    ScriptMap.Free;
  end;

  if Logger.Verbose then
    Logger.Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeScripts.WriteAsResource(AResourceWriter: TResourceWriter);
begin
  FScripts.WriteAsResource(AResourceWriter);
end;

//----------------------------------------------------------------------------------------------------------------------

end.
