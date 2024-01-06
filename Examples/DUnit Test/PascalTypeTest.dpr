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
  TestUnicode.Normalization in 'TestUnicode.Normalization.pas',
  TestUnicode.ArabicShaping in 'TestUnicode.ArabicShaping.pas',
  TestUnicode in 'TestUnicode.pas',
  TestShaper in 'TestShaper.pas',
  TestFontFace in 'TestFontFace.pas',
  TestFontFace.Load in 'TestFontFace.Load.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
end.

