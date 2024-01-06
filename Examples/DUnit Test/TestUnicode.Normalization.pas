unit TestUnicode.Normalization;

interface

uses
  Generics.Collections,
  Windows, Classes, SysUtils,
  PascalType.Unicode,
  TestFramework;

type
  TUnicodeTestCase = record
    Row: integer;
    Name: string;
    Source: TPascalTypeCodePoints;
    NFC: TPascalTypeCodePoints;
    NFD: TPascalTypeCodePoints;
    NFKC: TPascalTypeCodePoints;
    NFKD: TPascalTypeCodePoints;
  end;

  TTestPascalTypeUnicodeNormalization = class(TTestCase)
  strict private
    FTestCases: TList<TUnicodeTestCase>;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDecompose;
    procedure TestCompose;
  end;

implementation

uses
  TestUnicode;

{ TTestPascalTypeUnicodeNormalization }

const
  sUnicodeDataFolder = '..\..\..\Source\Unicode\UCD';

procedure TTestPascalTypeUnicodeNormalization.SetUp;

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
  FTestCases := TList<TUnicodeTestCase>.Create;

  var Reader := TStreamReader.Create(sUnicodeDataFolder + '\NormalizationTest.txt', TEncoding.UTF8);
  try
    var RowValues := TStringList.Create;
    try
      RowValues.Delimiter := ';';
      RowValues.StrictDelimiter := True;

      var RowIndex := 0;

      while (not Reader.EndOfStream) do
      begin
        var Row := Reader.ReadLine;
        Inc(RowIndex);

        if (Row.StartsWith('#')) or (Row.StartsWith('@')) then
          continue;

        var UnicodeTestCase: TUnicodeTestCase;
        UnicodeTestCase.Row := RowIndex;

        var n := Pos(' ) ', Row);
        if (n > 0) then
          UnicodeTestCase.Name := Copy(Row, n+3, MaxInt);

        n := Pos('; #', Row);
        if (n > 0) then
          SetLength(Row, n-1);

        RowValues.DelimitedText := Row;

        UnicodeTestCase.Source := HexToCardinals(RowValues[0]);
        UnicodeTestCase.NFC := HexToCardinals(RowValues[1]);
        UnicodeTestCase.NFD := HexToCardinals(RowValues[2]);
        UnicodeTestCase.NFKC := HexToCardinals(RowValues[3]);
        UnicodeTestCase.NFKD := HexToCardinals(RowValues[4]);

        FTestCases.Add(UnicodeTestCase);
      end;

    finally
      RowValues.Free;
    end;

  finally
    Reader.Free;
  end;
end;

procedure TTestPascalTypeUnicodeNormalization.TearDown;
begin
  FTestCases.Free;
  inherited;
end;

procedure TTestPascalTypeUnicodeNormalization.TestCompose;

  function CodePointsToString(const CodePoints: TPascalTypeCodePoints): string;
  begin
    Result := '';
    for var CodePoint in CodePoints do
    begin
      if (Result <> '') then
        Result := Result + ' ';
      Result := Result + IntToHex(CodePoint, 4);
    end;
  end;

begin
  var Succeeded := 0;
  var Failed := 0;
  var Skipped := 0;
  for var UnicodeTestCase in FTestCases do
  begin
//    Status(Format('Testing row %d: %s...', [UnicodeTestCase.Row, UnicodeTestCase.Name]));

    var ThisFailed := False;

    var Normalized := UnicodeTestCase.NFD;
    Normalized := PascalTypeUnicode.Decompose(Normalized);

//    PascalTypeUnicode.Normalize(Normalized);
    var ComposedCodePoints := PascalTypeUnicode.Compose(Normalized);

//    CheckEquals(Length(ComposedCodePoints), Length(UnicodeTestCase.NFC), Format('Incorrect Composed length in row %d', [UnicodeTestCase.Row]));
    if (Length(UnicodeTestCase.NFC) <> Length(ComposedCodePoints)) then
    begin
      Status(Format('Incorrect composed length in row %d. Expected: %d, Actual: %d (%s)', [UnicodeTestCase.Row, Length(UnicodeTestCase.NFC), Length(ComposedCodePoints), UnicodeTestCase.Name]));
      ThisFailed := True;
    end;

    for var i := 0 to High(ComposedCodePoints) do
      if (UnicodeTestCase.NFC[i] <> ComposedCodePoints[i]) then
      begin
        Status(Format('Incorrect composed component in row %d. Decomposed: %s, Expected:%s, Actual: %s (%s)',
          [UnicodeTestCase.Row, CodePointsToString(UnicodeTestCase.NFD), CodePointsToString(UnicodeTestCase.NFC), CodePointsToString(ComposedCodePoints), UnicodeTestCase.Name]));
        ThisFailed := True;
        break;
      end;

    if (ThisFailed) then
      Inc(Failed)
    else
      Inc(Succeeded);
  end;
  Status(Format('%.0n tests succeeded, %.0n tests failed, %.0n skipped', [Succeeded * 1.0, Failed * 1.0, Skipped * 1.0]));
  Check(Failed = 0);
end;

procedure TTestPascalTypeUnicodeNormalization.TestDecompose;

  function CodePointsToString(const CodePoints: TPascalTypeCodePoints): string;
  begin
    Result := '';
    for var CodePoint in CodePoints do
    begin
      if (Result <> '') then
        Result := Result + ' ';
      Result := Result + IntToHex(CodePoint, 4);
    end;
  end;

begin
  var Succeeded := 0;
  var Failed := 0;
  var Skipped := 0;
  for var UnicodeTestCase in FTestCases do
  begin
//    Status(Format('Testing row %d: %s...', [UnicodeTestCase.Row, UnicodeTestCase.Name]));

    var DecomposedCodePoints := PascalTypeUnicode.Decompose(UnicodeTestCase.Source);
    PascalTypeUnicode.Normalize(DecomposedCodePoints);

//    CheckEquals(Length(UnicodeTestCase.NFD), Length(DecomposedCodePoints), Format('Incorrect decomposed length in row %d', [UnicodeTestCase.Row]));

    var ThisFailed := False;

    for var i := 0 to High(DecomposedCodePoints) do
      if (UnicodeTestCase.NFD[i] <> DecomposedCodePoints[i]) then
      begin
        var Msg := '';
        if (UnicodeTestCase.NFKD[i] = DecomposedCodePoints[i]) then
          Msg := ' (*** matched NFKD ***)';
        Status(Format('Incorrect decomposed component in row %d. Source: %s, Expected:%s, Actual: %s%s',
          [UnicodeTestCase.Row, CodePointsToString(UnicodeTestCase.Source), CodePointsToString(UnicodeTestCase.NFD), CodePointsToString(DecomposedCodePoints), Msg]));
        ThisFailed := True;
        break;
      end;

    if (ThisFailed) then
      Inc(Failed)
    else
      Inc(Succeeded);
  end;
  Status(Format('%.0n tests succeeded, %.0n tests failed, %.0n skipped', [Succeeded * 1.0, Failed * 1.0, Skipped * 1.0]));
  Check(Failed = 0);
end;


initialization
  TestSuiteUnicode.AddSuite(TTestPascalTypeUnicodeNormalization.Suite);
end.
