unit TestOpenTypeReader;

interface

uses
  Generics.Collections,
  Windows, Classes, SysUtils,
  TestFramework,
  PascalType.FontFace.SFNT,
  FileTestFramework;

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

  TTestOpenType_cmap = class(TTestPascalTypeOpenType)
  published
    procedure Test_cmap;
    procedure Test_cmap14;
  end;

  TTestOpenTypeGlyphString = class(TTestPascalTypeOpenType)
  published
    procedure TestGlyphString;
  end;

  TTestOpenTypeGlyphFeatures = class(TTestPascalTypeOpenType)
  published
    procedure TestFeatures;
  end;

  TTestOpenTypeLoad = class(TFileTestCase)
  published
    procedure TestLoad;
  end;

implementation

{ TTestPascalTypeOpenType }

uses
  IOUtils,
  PT_Types,
  PascalType.Unicode,
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

{ TTestOpenTypeLoad }

procedure TTestOpenTypeLoad.TestLoad;
begin
  var Font := TPascalTypeFontFace.Create;
  try

    Font.LoadFromFile(TestFileName);

    Check(True);

//    var GSUB: TCustomOpenTypeCommonTable := Font.GetTableByTableName('GSUB') as TCustomOpenTypeCommonTable;
//    Check(GSUB <> nil, 'GSUB table missing');

  finally
    Font.Free;
  end;
end;

{ TTestOpenType_cmap }

procedure TTestOpenType_cmap.Test_cmap;
begin
  var Filename := TPath.Combine(sFontFolder, 'SourceSansPro/SourceSansPro-Regular.otf');
  Font.LoadFromFile(Filename);

  CheckNotEquals(0, Font.CharacterMap.GetGlyphByCharacter(Ord('a')), 'GetGlyphByCharacter failed to find ''a''');
  CheckEquals(0, Font.CharacterMap.GetGlyphByCharacter(0), 'GetGlyphByCharacter failed to not find ''null''');

  CheckEquals(28, Font.CharacterMap.GetGlyphByCharacter(Ord('a')), 'GetGlyphByCharacter returned wrong glyph');
end;

procedure TTestOpenType_cmap.Test_cmap14;
begin
  var Filename := TPath.Combine(sFontFolder, 'TestCMAP14.otf');
  Font.LoadFromFile(Filename);

  var GlyphString := Font.CreateGlyphString(PascalTypeUnicode.UTF16ToUTF32(#$82a6#$82a6#$E0100#$82a6#$E0101));

  CheckEquals(3, GlyphString.Count, 'CreateGlyphString wrong length');

  var Glyphs: TArray<Cardinal> := [1, 1, 2];
  for var i := 0 to GlyphString.Count-1 do
    CheckEquals(Glyphs[i], GlyphString[i].GlyphID, 'CreateGlyphString mapped to wrong glyph');
end;

{ TTestOpenTypeGlyphString }

procedure TTestOpenTypeGlyphString.TestGlyphString;
begin
  var Filename := TPath.Combine(sFontFolder, 'SourceSansPro/SourceSansPro-Regular.otf');
  Font.LoadFromFile(Filename);

  var GlyphString := Font.CreateGlyphString([Ord('a')]);

  CheckEquals(1, GlyphString.Count, 'CreateGlyphString wrong length');

  CheckEquals(1, Length(GlyphString[0].CodePoints), 'CreateGlyphString stored incorrect number of codepoints');

  CheckEquals(28, GlyphString[0].GlyphID, 'CreateGlyphString mapped to wrong glyph');

  CheckEquals(97, GlyphString[0].CodePoints[0], 'CreateGlyphString stored wrong character');

  var Text := 'hello';
  var Glyphs: TArray<Cardinal> := [35, 32, 39, 39, 42];
  var UTF32 := PascalTypeUnicode.UTF16ToUTF32(Text);
  GlyphString := Font.CreateGlyphString(UTF32);

  CheckEquals(Length(Text), GlyphString.Count, 'CreateGlyphString wrong length');
  for var i := 0 to GlyphString.Count-1 do
  begin
    CheckEquals(Glyphs[i], GlyphString[i].GlyphID, 'CreateGlyphString mapped to wrong glyph');
    CheckEquals(Ord(Text[i+1]), GlyphString[i].CodePoints[0], 'CreateGlyphString stored wrong character');
  end;
end;

{ TTestOpenTypeGlyphFeatures }

procedure TTestOpenTypeGlyphFeatures.TestFeatures;
begin
  var Filename := TPath.Combine(sFontFolder, 'SourceSansPro/SourceSansPro-Regular.otf');
  Font.LoadFromFile(Filename);

  var GSUBFeatures: TArray<TTableType> := [
    'aalt', 'c2sc', 'case', 'ccmp', 'dnom', 'frac', 'liga', 'numr',
    'onum', 'ordn', 'pnum', 'salt', 'sinf', 'smcp', 'ss01', 'ss02',
    'ss03', 'ss04', 'ss05', 'subs', 'sups', 'zero', 'locl'
  ];

  var Table: TCustomOpenTypeCommonTable := Font.GetTableByTableName('GSUB') as TCustomOpenTypeCommonTable;
  var TableFeatures: TPascalTypeFeatures;

  for var i := 0 to Table.FeatureListTable.FeatureCount-1 do
    TableFeatures.Add(Table.FeatureListTable[i].TableType);
  CheckEquals(Length(GSUBFeatures), TableFeatures.Count, 'GSUB features wrong count');

  for var Feature in GSUBFeatures do
    Check(TableFeatures.Contains(Feature.AsAnsiChar), Format('Missing GSUB feature: %s', [Feature.AsString]));

  var GPOSFeatures: TArray<TTableType> := [
    'aalt', 'c2sc', 'case', 'ccmp', 'dnom', 'frac', 'liga', 'numr',
    'onum', 'ordn', 'pnum', 'salt', 'sinf', 'smcp', 'ss01', 'ss02',
    'ss03', 'ss04', 'ss05', 'subs', 'sups', 'zero', 'kern', 'mark',
    'mkmk', 'size', 'locl'
  ];

  Table := Font.GetTableByTableName('GPOS') as TCustomOpenTypeCommonTable;

  TableFeatures := [];
  for var i := 0 to Table.FeatureListTable.FeatureCount-1 do
    TableFeatures.Add(Table.FeatureListTable[i].TableType);
  CheckEquals(Length(GPOSFeatures), TableFeatures.Count, 'GPOS features wrong count');

  for var Feature in GPOSFeatures do
    Check(TableFeatures.Contains(Feature.AsAnsiChar), Format('Missing GPOS feature: %s', [Feature.AsString]));
end;

initialization

  var OpenTypeSuite := TTestSuite.Create('OpenType');
  RegisterTest(OpenTypeSuite);

  var TestSuite: ITestSuite := TFolderTestSuite.Create('Load font files', TTestOpenTypeLoad, sFontFolder, '*.otf', True);
  OpenTypeSuite.AddSuite(TestSuite);

  RegisterTest('OpenType\GlyphString', TTestOpenTypeGlyphString.Suite);
  RegisterTest('OpenType\cmap table', TTestOpenType_cmap.Suite);
  RegisterTest('OpenType\Features', TTestOpenTypeGlyphFeatures.Suite);
end.
