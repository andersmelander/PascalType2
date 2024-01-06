unit TestUnicode;

interface

uses
  TestFramework;

var
  TestSuiteUnicode: ITestSuite;

implementation

initialization
  TestSuiteUnicode := TTestSuite.Create('Unicode');
  RegisterTest(TestSuiteUnicode);
end.
