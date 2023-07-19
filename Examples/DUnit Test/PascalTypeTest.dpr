program PascalTypeTest;
{

  Delphi DUnit-Testprojekt
  -------------------------
  Dieses Projekt enth�lt das DUnit-Test-Framework und die GUI/Konsolen-Test-Runner.
  Zum Verwenden des Konsolen-Test-Runners f�gen Sie den konditinalen Definitionen  
  in den Projektoptionen "CONSOLE_TESTRUNNER" hinzu. Ansonsten wird standardm��ig 
  der GUI-Test-Runner verwendet.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

{$R 'Default.res' '..\..\Resource\Default.rc'}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  PT_ByteCodeInterpreter in '..\..\Source\PT_ByteCodeInterpreter.pas',
  PT_Classes in '..\..\Source\PT_Classes.pas',
  PascalType.Tables.TrueType.CharacterMaps in '..\..\Source\PascalType.Tables.TrueType.CharacterMaps.pas',
  PascalType.Rasterizer in '..\..\Source\PascalType.Rasterizer.pas',
  PascalType.Rasterizer.GDI in '..\..\Source\PascalType.Rasterizer.GDI.pas',
  PT_Math in '..\..\Source\PT_Math.pas',
  PascalType.Tables.TrueType.Panose.Classifications in '..\..\Source\PascalType.Tables.TrueType.Panose.Classifications.pas',
  PT_ResourceStrings in '..\..\Source\PT_ResourceStrings.pas',
  PascalType.FontFace in '..\..\Source\PascalType.FontFace.pas',
  PascalType.FontFace.SFNT in '..\..\Source\PascalType.FontFace.SFNT.pas',
  PT_TableDirectory in '..\..\Source\PT_TableDirectory.pas',
  PT_Tables in '..\..\Source\PT_Tables.pas',
  PT_TablesApple in '..\..\Source\PT_TablesApple.pas',
  PT_TablesBitmap in '..\..\Source\PT_TablesBitmap.pas',
  PT_TablesFontForge in '..\..\Source\PT_TablesFontForge.pas',
  PascalType.Tables.OpenType.GSUB in '..\..\Source\PascalType.Tables.OpenType.GSUB.pas',
  PascalType.Tables.OpenType.Features in '..\..\Source\PascalType.Tables.OpenType.Features.pas',
  PascalType.Tables.OpenType.Languages in '..\..\Source\PascalType.Tables.OpenType.Languages.pas',
  PascalType.Tables.OpenType.Scripts in '..\..\Source\PascalType.Tables.OpenType.Scripts.pas',
  PT_TablesOptional in '..\..\Source\PT_TablesOptional.pas',
  PT_TablesPostscript in '..\..\Source\PT_TablesPostscript.pas',
  PT_TablesPostscriptOperators in '..\..\Source\PT_TablesPostscriptOperators.pas',
  PT_TablesPostscriptOperands in '..\..\Source\PT_TablesPostscriptOperands.pas',
  PT_TablesShared in '..\..\Source\PT_TablesShared.pas',
  PT_TablesTrueType in '..\..\Source\PT_TablesTrueType.pas',
  PT_Types in '..\..\Source\PT_Types.pas',
  RenderDemoFontNameScanner in '..\Render Demo\RenderDemoFontNameScanner.pas',
  PascalType.Tables.OpenType in '..\..\Source\PascalType.Tables.OpenType.pas',
  PascalType.Tables.OpenType.GPOS in '..\..\Source\PascalType.Tables.OpenType.GPOS.pas',
  PascalType.Tables.OpenType.Common in '..\..\Source\PascalType.Tables.OpenType.Common.pas',
  PascalType.Tables.OpenType.Coverage in '..\..\Source\PascalType.Tables.OpenType.Coverage.pas',
  PascalType.Tables.OpenType.Substitution in '..\..\Source\PascalType.Tables.OpenType.Substitution.pas',
  PascalType.Tables.OpenType.Lookup in '..\..\Source\PascalType.Tables.OpenType.Lookup.pas',
  PascalType.Tables.OpenType.BASE in '..\..\Source\PascalType.Tables.OpenType.BASE.pas',
  PascalType.Tables.OpenType.GDEF in '..\..\Source\PascalType.Tables.OpenType.GDEF.pas',
  PascalType.Tables.OpenType.JSTF in '..\..\Source\PascalType.Tables.OpenType.JSTF.pas',
  PascalType.Tables.OpenType.LanguageSystem in '..\..\Source\PascalType.Tables.OpenType.LanguageSystem.pas',
  PascalType.Tables.OpenType.Script in '..\..\Source\PascalType.Tables.OpenType.Script.pas',
  PascalType.Tables.OpenType.Feature in '..\..\Source\PascalType.Tables.OpenType.Feature.pas',
  PascalType.Tables.OpenType.Substitution.Single in '..\..\Source\PascalType.Tables.OpenType.Substitution.Single.pas',
  PascalType.Tables.OpenType.Substitution.Multiple in '..\..\Source\PascalType.Tables.OpenType.Substitution.Multiple.pas',
  PascalType.Tables.OpenType.Positioning in '..\..\Source\PascalType.Tables.OpenType.Positioning.pas',
  PascalType.Tables.OpenType.Positioning.Single in '..\..\Source\PascalType.Tables.OpenType.Positioning.Single.pas',
  PascalType.Tables.OpenType.Positioning.Pair in '..\..\Source\PascalType.Tables.OpenType.Positioning.Pair.pas',
  PascalType.Tables.OpenType.ClassDefinition in '..\..\Source\PascalType.Tables.OpenType.ClassDefinition.pas',
  PascalType.Tables.TrueType.glyf in '..\..\Source\PascalType.Tables.TrueType.glyf.pas',
  PascalType.Tables.TrueType.hmtx in '..\..\Source\PascalType.Tables.TrueType.hmtx.pas',
  PascalType.Tables.TrueType.vmtx in '..\..\Source\PascalType.Tables.TrueType.vmtx.pas',
  PascalType.Tables.TrueType.hhea in '..\..\Source\PascalType.Tables.TrueType.hhea.pas',
  PascalType.Tables.TrueType.vhea in '..\..\Source\PascalType.Tables.TrueType.vhea.pas',
  PascalType.Tables.TrueType.os2 in '..\..\Source\PascalType.Tables.TrueType.os2.pas',
  PascalType.Tables.TrueType.Panose in '..\..\Source\PascalType.Tables.TrueType.Panose.pas',
  PascalType.Shaper in '..\..\Source\PascalType.Shaper.pas',
  PascalType.Rasterizer.Graphics32 in '..\..\Source\PascalType.Rasterizer.Graphics32.pas',
  PascalType.GlyphString in '..\..\Source\PascalType.GlyphString.pas',
  PascalType.Tables.OpenType.Substitution.Ligature in '..\..\Source\PascalType.Tables.OpenType.Substitution.Ligature.pas',
  PascalType.Unicode in '..\..\Source\PascalType.Unicode.pas',
  PascalType.Tables.TrueType.cmap in '..\..\Source\PascalType.Tables.TrueType.cmap.pas',
  TestUnicode in 'TestUnicode.pas',
  TestOpenTypeReader in 'TestOpenTypeReader.pas',
  TestShaper in 'TestShaper.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
end.

