unit TestFontFace.Load;

interface

uses
  Generics.Collections,
  Windows, Classes, SysUtils,
  PascalType.FontFace,
  PascalType.FontFace.SFNT,
  TestFramework;

type
  TTestPascalTypeFontFaceApple = class(TTestCase)
  private
    FFontFace: TPascalTypeFontFace;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAppleChancery;
  end;

implementation

uses
  IOUtils,
  TestFontFace;

const
  sFontFolder = '..\Data\';

procedure TTestPascalTypeFontFaceApple.SetUp;
begin
  inherited;
  FFontFace := TPascalTypeFontFace.Create;
end;

procedure TTestPascalTypeFontFaceApple.TearDown;
begin
  inherited;
  FreeAndNil(FFontFace);
end;

procedure TTestPascalTypeFontFaceApple.TestAppleChancery;
begin
  // Apple Chancery is an old OS 9 system font.
  // Notably it contains a 'kern' version 1 table with a format 2 subtable.
  FFontFace.LoadFromFile(sFontFolder+'Apple Chancery.ttf');
end;

initialization
  TestSuiteFontFace.AddSuite(TTestPascalTypeFontFaceApple.Suite);
end.
