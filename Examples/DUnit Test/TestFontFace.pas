unit TestFontFace;

interface

uses
  TestFramework;

var
  TestSuiteFontFace: ITestSuite;

implementation

initialization
  TestSuiteFontFace := TTestSuite.Create('FontFace');
  RegisterTest(TestSuiteFontFace);
end.

