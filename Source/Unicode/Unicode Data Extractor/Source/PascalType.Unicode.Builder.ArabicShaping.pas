unit PascalType.Unicode.Builder.ArabicShaping;

interface

uses
  PascalType.Unicode,
  PascalType.Unicode.Builder.CharacterSet,
  PascalType.Unicode.Builder.ResourceWriter;

const
  ArabicShapingFileName = 'ArabicShaping.txt';

//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeArabicShaping
//
//----------------------------------------------------------------------------------------------------------------------
type
  TUnicodeArabicShaping = class
  private
    FArabicShapingClasses: TCharacterSetList;

  private
    procedure AddClass(Code: TPascalTypeCodePoint; AClass: ArabicShapingClasses.TShapingClass);

  public
    procedure Parse(const AFilename: string);

    procedure WriteAsResource(AResourceWriter: TResourceWriter);
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
//      TUnicodeArabicShaping
//
//----------------------------------------------------------------------------------------------------------------------
procedure TUnicodeArabicShaping.AddClass(Code: TPascalTypeCodePoint; AClass: ArabicShapingClasses.TShapingClass);
begin
  Assert(FArabicShapingClasses.Data[Ord(AClass)].Characters[Code] = False);
  FArabicShapingClasses.Data[Ord(AClass)].SetCharacter(Code);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeArabicShaping.Parse(const AFilename: string);
(*
# Each line contains four fields, separated by a semicolon.
#
# Field 0: the code point, in 4-digit hexadecimal
#   form, of a character.
#
# Field 1: gives a short schematic name for that character.
#   The schematic name is descriptive of the shape, based as
#   consistently as possible on a name for the skeleton and
#   then the diacritic marks applied to the skeleton, if any.
#   Note that this schematic name is considered a comment,
#   and does not constitute a formal property value.
#
# Field 2: defines the joining type (property name: Joining_Type)
#   R Right_Joining
#   L Left_Joining
#   D Dual_Joining
#   C Join_Causing
#   U Non_Joining
#   T Transparent
#
# See Section 9.2, Arabic for more information on these joining types.
# Note that for cursive joining scripts which are typically rendered
# top-to-bottom, rather than right-to-left, Joining_Type=L conventionally
# refers to bottom joining, and Joining_Type=R conventionally refers
# to top joining. See Section 14.4, Phags-pa for more information on the
# interpretation of joining types in vertical layout.
#
# Field 3: defines the joining group (property name: Joining_Group)
#
# The values of the joining group are based schematically on character
# names. Where a schematic character name consists of two or more parts
# separated by spaces, the formal Joining_Group property value, as specified in
# PropertyValueAliases.txt, consists of the same name parts joined by
# underscores. Hence, the entry:
#
#   0629; TEH MARBUTA; R; TEH MARBUTA
#
# corresponds to [Joining_Group = Teh_Marbuta].
*)
(* The following rule is implemented in the shaper:
# Note: Code points that are not explicitly listed in this file are
# either of joining type T or U:
#
# - Those that are not explicitly listed and that are of General Category Mn, Me, or Cf
#   have joining type T.
# - All others not explicitly listed have joining type U.
*)
var
  Reader: TStreamReader;
  Line: string;
  Columns: TArray<string>;
  Code: TPascalTypeCodePoint;
begin
  if not TFile.Exists(AFilename) then
  begin
    Logger.Warning(AFilename + ' not found, ignoring arabic shaping');
    exit;
  end;

  if Logger.Verbose then
  begin
    Logger.Writeln;
    Logger.Writeln('Reading arabic shaping data from ' + AFilename + ':');
  end;

  Reader := TStreamReader.Create(AFilename);
  try

    while (not Reader.EndOfStream) do
    begin
      // # Unicode; Schematic Name; Joining Type; Joining Group

      Line := Reader.ReadLine.Trim;
      if (Line = '') or (Line.StartsWith('#')) then
        continue;

      Columns := Line.Split([';']);

      if (Length(Columns) < 4) then
        continue;

      Code := StrToInt('$'+Columns[0].Trim);

      var JoiningType: Char := Columns[2].Trim[1];

      var ShapingClassValue: ArabicShapingClasses.TShapingClass := scUnassigned;

      if (JoiningType = 'R') then
      begin
        var JoiningGroup := Columns[3].Trim;
        if (JoiningGroup = 'ALAPH') then
          ShapingClassValue := scALAPH
        else
        if (JoiningGroup = 'DALATH RISH') then
          ShapingClassValue := scDALATH_RISH;
      end;

      if (ShapingClassValue = scUnassigned) then
        case JoiningType of
          'U': ShapingClassValue := scNon_Joining; // Non_Joining
          'L': ShapingClassValue := scLeft_Joining; // Left_Joining
          'R': ShapingClassValue := scRight_Joining; // Right_Joining
          'D': ShapingClassValue := scDual_Joining; // Dual_Joining
          'C': ShapingClassValue := scDual_Joining; // Join_Causing
          'T': ShapingClassValue := scTransparent; // Transparent
        end;

      if (ShapingClassValue <> scUnassigned) then
        AddClass(Code, ShapingClassValue);

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

procedure TUnicodeArabicShaping.WriteAsResource(AResourceWriter: TResourceWriter);
begin
  FArabicShapingClasses.WriteAsResource(AResourceWriter);
end;

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

end.
