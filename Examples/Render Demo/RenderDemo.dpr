program RenderDemo;

uses
  Forms,
  RenderDemoMain in 'RenderDemoMain.pas' {FmRenderDemo},
  PT_ByteCodeInterpreter in '..\..\Source\PT_ByteCodeInterpreter.pas',
  PT_Classes in '..\..\Source\PT_Classes.pas',
  PT_CharacterMap in '..\..\Source\PT_CharacterMap.pas',
  PT_FontEngine in '..\..\Source\PT_FontEngine.pas',
  PT_FontEngineGDI in '..\..\Source\PT_FontEngineGDI.pas',
  PT_Math in '..\..\Source\PT_Math.pas',
  PT_PanoseClassifications in '..\..\Source\PT_PanoseClassifications.pas',
  PT_ResourceStrings in '..\..\Source\PT_ResourceStrings.pas',
  PT_Storage in '..\..\Source\PT_Storage.pas',
  PT_StorageSFNT in '..\..\Source\PT_StorageSFNT.pas',
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
  PT_UnicodeNames in '..\..\Source\PT_UnicodeNames.pas',
  PT_Windows in '..\..\Source\PT_Windows.pas',
  RenderDemoFontNameScanner in 'RenderDemoFontNameScanner.pas',
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
  PascalType.Tables.TrueType.GLYF in '..\..\Source\PascalType.Tables.TrueType.GLYF.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmRenderDemo, FmRenderDemo);
  Application.Run;
end.
