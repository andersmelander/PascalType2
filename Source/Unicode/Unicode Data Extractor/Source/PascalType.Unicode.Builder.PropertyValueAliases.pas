unit PascalType.Unicode.Builder.PropertyValueAliases;

interface

uses
  Generics.Collections;

const
  AliasFileName = 'PropertyValueAliases.txt';


//----------------------------------------------------------------------------------------------------------------------
//
//      TPropertyValueAliases
//
//----------------------------------------------------------------------------------------------------------------------
type
  TPropertyValueAliases = class
  private type
    TCategoryAliases = TDictionary<string, string>;
  private
    FCategories: TObjectDictionary<string, TCategoryAliases>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(const AFilename: string);

    function ResolveAlias(const Category, Value: string): string;
  end;

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  PascalType.Unicode.Builder.Logger;

//----------------------------------------------------------------------------------------------------------------------
//
//      TPropertyValueAliases
//
//----------------------------------------------------------------------------------------------------------------------
constructor TPropertyValueAliases.Create;
begin
  inherited Create;
  FCategories := TObjectDictionary<string, TCategoryAliases>.Create([doOwnsValues])
end;

destructor TPropertyValueAliases.Destroy;
begin
  FCategories.Free;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TPropertyValueAliases.Parse(const AFilename: string);
(*
# Each line describes a property value name.
# This consists of three or more fields, separated by semicolons.
#
# First Field: The first field describes the property for which that
# property value name is used.
#
# Second Field: The second field is the short name for the property value.
# It is typically an abbreviation, but in a number of cases it is simply
# a duplicate of the "long name" in the third field.
#
# Third Field: The third field is the long name for the property value,
# typically the formal name used in documentation about the property value.
*)
var
  Reader: TStreamReader;
  Line: string;
  Values: TArray<string>;
  Category, ShortName, LongName: string;
  i: integer;
  Aliases: TCategoryAliases;
begin
  if (not TFile.Exists(AFileName)) then
  begin
    Logger.Warning(AFileName + ' not found, ignoring aliases');
    exit;
  end;

  if Logger.Verbose then
  begin
    Logger.Writeln;
    Logger.Writeln('Reading aliases data from ' + AFileName + ':');
  end;

  Reader := TStreamReader.Create(AFileName);
  try

    while (not Reader.EndOfStream) do
    begin
      // sc ; Adlm                             ; Adlam

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

      Values := Line.Split([';']);

      if (Length(Values) < 3) then
        continue;

      Category := Values[0].Trim;
      ShortName := Values[1].Trim;
      LongName := Values[2].Trim;

      if (not FCategories.TryGetValue(Category, Aliases)) then
      begin
        Aliases := TCategoryAliases.Create;
        FCategories.Add(Category, Aliases);
      end;
      Aliases.Add(ShortName, LongName);

      // Reverse
      if (not FCategories.TryGetValue('_'+Category, Aliases)) then
      begin
        Aliases := TCategoryAliases.Create;
        FCategories.Add('_'+Category, Aliases);
      end;
      Aliases.Add(LongName, ShortName);

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

function TPropertyValueAliases.ResolveAlias(const Category, Value: string): string;
var
  Aliases: TCategoryAliases;
begin
  if (not FCategories.TryGetValue(Category, Aliases)) or
    (not Aliases.TryGetValue(Value, Result)) then
    Result := Value;
end;

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

end.
