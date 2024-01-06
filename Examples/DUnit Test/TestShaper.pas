unit TestShaper;

interface

uses
  TestFramework;

var
  TestSuiteShaper: ITestSuite;

implementation

initialization
  TestSuiteShaper := TTestSuite.Create('Shaper');
  RegisterTest(TestSuiteShaper);
end.

