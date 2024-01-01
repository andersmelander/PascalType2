unit TestUnicodeArabicShaping;

interface

uses
  Generics.Collections,
  Windows, Classes, SysUtils,
  PascalType.Unicode,
  TestFramework;

type
  TTestPascalTypeUnicodeArabicShaping = class(TTestCase)
  public
    procedure SetUp; override;
  published
    procedure TestArabicShapingData;
  end;

implementation

uses
  IOUtils;

const
  sUnicodeDataFolder = '..\..\..\Source\Unicode\UCD';
  sArabicShapingFileName = 'ArabicShaping.txt';

procedure TTestPascalTypeUnicodeArabicShaping.SetUp;
begin
  inherited;

  ArabicShapingClasses.Load;
end;

procedure TTestPascalTypeUnicodeArabicShaping.TestArabicShapingData;

  function HexToCardinal(const Hex: string): TPascalTypeCodePoint;
  begin
    Result := StrToInt('$'+Hex);
  end;

  function HexToCardinals(const Hex: string): TPascalTypeCodePoints;
  begin
    var Values := Hex.Split([' ']);
    SetLength(Result, Length(Values));
    for var i := 0 to High(Values) do
      Result[i] := HexToCardinal(Values[i]);
  end;

begin
  inherited;
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
  var Reader := TStreamReader.Create(TPath.Combine(sUnicodeDataFolder, sArabicShapingFileName), TEncoding.UTF8);
  try

    while (not Reader.EndOfStream) do
    begin
      // # Unicode; Schematic Name; Joining Type; Joining Group

      var Line := Reader.ReadLine.Trim;
      if (Line = '') or (Line.StartsWith('#')) then
        continue;

      var Columns := Line.Split([';']);

      if (Length(Columns) < 4) then
        continue;

      var Code: Cardinal := StrToInt('$'+Columns[0].Trim);

      var JoiningType: Char := Columns[2].Trim[1];

      var ShapingClassValue: Byte := 0;

      if (JoiningType = 'R') then
      begin
        var JoiningGroup := Columns[3].Trim;
        if (JoiningGroup = 'ALAPH') then
          ShapingClassValue := 5
        else
        if (JoiningGroup = 'DALATH RISH') then
          ShapingClassValue := 6;
      end;

      if (ShapingClassValue = 0) then
        case JoiningType of
          'U': ShapingClassValue := 1; // Non_Joining
          'L': ShapingClassValue := 2; // Left_Joining
          'R': ShapingClassValue := 3; // Right_Joining
          'D': ShapingClassValue := 4; // Dual_Joining
          'C': ShapingClassValue := 4; // Join_Causing
          'T': ShapingClassValue := 7; // Transparent
        end;

      if (ShapingClassValue <> 0) then
        CheckEquals(ShapingClassValue, Ord(ArabicShapingClasses.Trie.Values[Code]));
    end;

  finally
    Reader.Free;
  end;
end;

initialization
  RegisterTest(TTestPascalTypeUnicodeArabicShaping.Suite);
end.
