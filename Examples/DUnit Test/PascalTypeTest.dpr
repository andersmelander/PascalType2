program PascalTypeTest;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

{$R 'Default.res' '..\..\Resource\Default.rc'}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  TestUnicodeNormalization in 'TestUnicodeNormalization.pas',
  TestUnicodeArabicShaping in 'TestUnicodeArabicShaping.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
end.

