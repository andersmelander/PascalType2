unit TestShaper;

interface

uses
  Generics.Collections,
  Windows, Classes, SysUtils,
  TestFramework,
  PascalType.FontFace.SFNT;

type
  TTestPascalTypeOpenType = class(TTestCase)
  strict private
    FFont: TPascalTypeFontFace;
  protected
    property Font: TPascalTypeFontFace read FFont;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
  end;

  TTestOpenTypeGlyphFeatures = class(TTestPascalTypeOpenType)
  published
    procedure TestFeature_dlig;
    procedure TestFeature_frac;
    procedure TestFeature_frac_no;
  end;

implementation

{ TTestPascalTypeOpenType }

uses
  IOUtils,
  PT_Types,
  PascalType.Unicode,
  PascalType.Shaper,
  PascalType.Shaper.Script.Default,
  PascalType.Tables.OpenType.Common;

const
  sFontFolder = '..\Data';

procedure TTestPascalTypeOpenType.SetUp;
begin
  inherited ;
  FFont := TPascalTypeFontFace.Create;
end;

procedure TTestPascalTypeOpenType.TearDown;
begin
  FFont.Free;
  inherited;
end;

{ TTestOpenTypeGlyphFeatures }

procedure TTestOpenTypeGlyphFeatures.TestFeature_dlig;
begin
  var Filename := TPath.Combine(sFontFolder, 'SourceSansPro/SourceSansPro-Regular.otf');
  Font.LoadFromFile(Filename);

  var Text := 'ffi';
  var Glyphs: TArray<Cardinal> := [514, 36];
  var CodePoints: TArray<TArray<Word>> := [[102, 102], [105]];

  var UTF32 := PascalTypeUnicode.UTF16ToUTF32(Text);

  var Script := TPascalTypeShaper.DetectScript(UTF32);
  var Shaper := TPascalTypeShaper.CreateShaper(Font, Script);
  try
    var GlyphString := Shaper.TextToGlyphs(UTF32);

    CheckEquals(Length(Text), GlyphString.Count, 'CreateGlyphString wrong length');

    Shaper.Shape(GlyphString);

    CheckEquals(Length(Glyphs), GlyphString.Count, 'Shaped string wrong length');

    for var i := 0 to GlyphString.Count-1 do
      CheckEquals(Glyphs[i], GlyphString[i].GlyphID, 'Substitution mapped to wrong glyph');

    for var i := 0 to GlyphString.Count-1 do
      for var j := 0 to High(GlyphString[i].CodePoints) do
        CheckEquals(CodePoints[i, j], GlyphString[i].CodePoints[j], 'Substitution stored wrong character');

  finally
    Shaper.Free;
  end;
end;

procedure TTestOpenTypeGlyphFeatures.TestFeature_frac;
begin
  var Filename := TPath.Combine(sFontFolder, 'SourceSansPro/SourceSansPro-Regular.otf');
  Font.LoadFromFile(Filename);

  // 'frac' should be applied
  var Text := '123 1⁄16 123';
  var Glyphs: TArray<Cardinal> := [1088, 1089, 1090, 1, 1617, 1724, 1603, 1608, 1, 1088, 1089, 1090];

  var UTF32 := PascalTypeUnicode.UTF16ToUTF32(Text);

  var Script := TPascalTypeShaper.DetectScript(UTF32);
  var Shaper := TPascalTypeShaper.CreateShaper(Font, Script);
  try
    var GlyphString := Shaper.TextToGlyphs(UTF32);

    CheckEquals(Length(Text), GlyphString.Count, 'CreateGlyphString wrong length');

    Shaper.Shape(GlyphString);

    CheckEquals(Length(Glyphs), GlyphString.Count, 'Shaped string wrong length');

    for var i := 0 to GlyphString.Count-1 do
      CheckEquals(Glyphs[i], GlyphString[i].GlyphID, 'Substitution mapped to wrong glyph');

  finally
    Shaper.Free;
  end;
end;

procedure TTestOpenTypeGlyphFeatures.TestFeature_frac_no;
begin
  var Filename := TPath.Combine(sFontFolder, 'SourceSansPro/SourceSansPro-Regular.otf');
  Font.LoadFromFile(Filename);

  // 'frac' should not be applied
  var Text := 'a⁄b ⁄ 1⁄ ⁄2';
  var Glyphs: TArray<Cardinal> := [28, 1724, 29, 1, 1724, 1, 1617, 1724, 1, 1724, 1604];

  var UTF32 := PascalTypeUnicode.UTF16ToUTF32(Text);

  var Script := TPascalTypeShaper.DetectScript(UTF32);
  var Shaper := TPascalTypeShaper.CreateShaper(Font, Script);
  try
    var GlyphString := Shaper.TextToGlyphs(UTF32);

    CheckEquals(Length(Text), GlyphString.Count, 'CreateGlyphString wrong length');

    Shaper.Shape(GlyphString);

    CheckEquals(Length(Glyphs), GlyphString.Count, 'Shaped string wrong length');

    for var i := 0 to GlyphString.Count-1 do
      CheckEquals(Glyphs[i], GlyphString[i].GlyphID, 'Substitution mapped to wrong glyph');

  finally
    Shaper.Free;
  end;
end;

initialization

  RegisterTest('OpenType\Shaper\Features', TTestOpenTypeGlyphFeatures.Suite);
end.
