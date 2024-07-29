program RenderDemo;

uses
  Forms,
  RenderDemoMain in 'RenderDemoMain.pas' {FmRenderDemo},
  PascalType.Classes in '..\..\Source\PascalType.Classes.pas',
  PascalType.Tables.TrueType.CharacterMaps in '..\..\Source\PascalType.Tables.TrueType.CharacterMaps.pas',
  PascalType.Renderer in '..\..\Source\PascalType.Renderer.pas',
  PascalType.Painter.GDI in '..\..\Source\PascalType.Painter.GDI.pas',
  PascalType.Math in '..\..\Source\PascalType.Math.pas',
  PascalType.Tables.TrueType.Panose.Classifications in '..\..\Source\PascalType.Tables.TrueType.Panose.Classifications.pas',
  PascalType.ResourceStrings in '..\..\Source\PascalType.ResourceStrings.pas',
  PascalType.FontFace in '..\..\Source\PascalType.FontFace.pas',
  PascalType.FontFace.SFNT in '..\..\Source\PascalType.FontFace.SFNT.pas',
  PascalType.Tables.TrueType.Directory in '..\..\Source\PascalType.Tables.TrueType.Directory.pas',
  PascalType.Tables in '..\..\Source\PascalType.Tables.pas',
  PascalType.Tables.Apple in '..\..\Source\PascalType.Tables.Apple.pas',
  PascalType.Tables.Bitmap in '..\..\Source\PascalType.Tables.Bitmap.pas',
  PascalType.Tables.FontForge in '..\..\Source\PascalType.Tables.FontForge.pas',
  PascalType.Tables.OpenType.GSUB in '..\..\Source\PascalType.Tables.OpenType.GSUB.pas',
  PascalType.Tables.OpenType.Features in '..\..\Source\PascalType.Tables.OpenType.Features.pas',
  PascalType.Tables.OpenType.Languages in '..\..\Source\PascalType.Tables.OpenType.Languages.pas',
  PascalType.Tables.OpenType.Scripts in '..\..\Source\PascalType.Tables.OpenType.Scripts.pas',
  PascalType.Tables.Optional in '..\..\Source\PascalType.Tables.Optional.pas',
  PascalType.Tables.Postscript in '..\..\Source\PascalType.Tables.Postscript.pas',
  PascalType.Tables.Postscript.Operators in '..\..\Source\PascalType.Tables.Postscript.Operators.pas',
  PascalType.Tables.Postscript.Operands in '..\..\Source\PascalType.Tables.Postscript.Operands.pas',
  PascalType.Tables.Shared in '..\..\Source\PascalType.Tables.Shared.pas',
  PascalType.Tables.TrueType in '..\..\Source\PascalType.Tables.TrueType.pas',
  PascalType.Types in '..\..\Source\PascalType.Types.pas',
  PascalType.Unicode.Names in '..\..\Source\PascalType.Unicode.Names.pas',
  PascalType.Platform.Windows in '..\..\Source\PascalType.Platform.Windows.pas',
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
  PascalType.Tables.TrueType.glyf in '..\..\Source\PascalType.Tables.TrueType.glyf.pas',
  PascalType.Tables.TrueType.hmtx in '..\..\Source\PascalType.Tables.TrueType.hmtx.pas',
  PascalType.Tables.TrueType.vmtx in '..\..\Source\PascalType.Tables.TrueType.vmtx.pas',
  PascalType.Tables.TrueType.hhea in '..\..\Source\PascalType.Tables.TrueType.hhea.pas',
  PascalType.Tables.TrueType.vhea in '..\..\Source\PascalType.Tables.TrueType.vhea.pas',
  PascalType.Tables.TrueType.os2 in '..\..\Source\PascalType.Tables.TrueType.os2.pas',
  PascalType.Tables.TrueType.Panose in '..\..\Source\PascalType.Tables.TrueType.Panose.pas',
  PascalType.Shaper in '..\..\Source\PascalType.Shaper.pas',
  PascalType.Painter.Graphics32 in '..\..\Source\PascalType.Painter.Graphics32.pas',
  PascalType.GlyphString in '..\..\Source\PascalType.GlyphString.pas',
  PascalType.Tables.OpenType.Substitution.Ligature in '..\..\Source\PascalType.Tables.OpenType.Substitution.Ligature.pas',
  PascalType.Unicode in '..\..\Source\PascalType.Unicode.pas',
  PascalType.Tables.TrueType.cmap in '..\..\Source\PascalType.Tables.TrueType.cmap.pas',
  PascalType.Shaper.Plan in '..\..\Source\PascalType.Shaper.Plan.pas',
  PascalType.Tables.OpenType.Substitution.Context in '..\..\Source\PascalType.Tables.OpenType.Substitution.Context.pas',
  PascalType.Tables.OpenType.Substitution.ChainedContext in '..\..\Source\PascalType.Tables.OpenType.Substitution.ChainedContext.pas',
  PascalType.Tables.OpenType.Positioning.Cursive in '..\..\Source\PascalType.Tables.OpenType.Positioning.Cursive.pas',
  PascalType.Tables.OpenType.Positioning.MarkToBase in '..\..\Source\PascalType.Tables.OpenType.Positioning.MarkToBase.pas',
  PascalType.Tables.OpenType.Common.ValueRecord in '..\..\Source\PascalType.Tables.OpenType.Common.ValueRecord.pas',
  PascalType.Tables.OpenType.Common.Mark in '..\..\Source\PascalType.Tables.OpenType.Common.Mark.pas',
  PascalType.Tables.OpenType.Common.Anchor in '..\..\Source\PascalType.Tables.OpenType.Common.Anchor.pas',
  PascalType.Tables.OpenType.Positioning.MarkToMark in '..\..\Source\PascalType.Tables.OpenType.Positioning.MarkToMark.pas',
  PascalType.Tables.OpenType.Positioning.MarkToLigature in '..\..\Source\PascalType.Tables.OpenType.Positioning.MarkToLigature.pas',
  PascalType.Tables.OpenType.Positioning.Mark in '..\..\Source\PascalType.Tables.OpenType.Positioning.Mark.pas',
  PascalType.Shaper.Script.Default in '..\..\Source\PascalType.Shaper.Script.Default.pas',
  PascalType.Shaper.OpenType.Processor.GPOS in '..\..\Source\PascalType.Shaper.OpenType.Processor.GPOS.pas',
  PascalType.Shaper.OpenType.Processor.GSUB in '..\..\Source\PascalType.Shaper.OpenType.Processor.GSUB.pas',
  PascalType.Shaper.Layout in '..\..\Source\PascalType.Shaper.Layout.pas',
  PascalType.Shaper.OpenType.Processor in '..\..\Source\PascalType.Shaper.OpenType.Processor.pas',
  PascalType.Shaper.Layout.OpenType in '..\..\Source\PascalType.Shaper.Layout.OpenType.pas',
  PascalType.Tables.TrueType.kern in '..\..\Source\PascalType.Tables.TrueType.kern.pas',
  PascalType.Tables.OpenType.Positioning.Context in '..\..\Source\PascalType.Tables.OpenType.Positioning.Context.pas',
  PascalType.Tables.OpenType.Positioning.ChainedContext in '..\..\Source\PascalType.Tables.OpenType.Positioning.ChainedContext.pas',
  PascalType.Shaper.Script.Arabic in '..\..\Source\PascalType.Shaper.Script.Arabic.pas',
  PascalType.Tables.OpenType.Substitution.Alternate in '..\..\Source\PascalType.Tables.OpenType.Substitution.Alternate.pas',
  PascalType.Tables.OpenType.Substitution.ReverseChainedContext in '..\..\Source\PascalType.Tables.OpenType.Substitution.ReverseChainedContext.pas',
  PascalType.Shaper.Script.Hangul in '..\..\Source\PascalType.Shaper.Script.Hangul.pas',
  PascalType.Tables.TrueType.head in '..\..\Source\PascalType.Tables.TrueType.head.pas',
  PascalType.Tables.TrueType.name in '..\..\Source\PascalType.Tables.TrueType.name.pas',
  PascalType.Tables.TrueType.maxp in '..\..\Source\PascalType.Tables.TrueType.maxp.pas',
  PascalType.Tables.TrueType.post in '..\..\Source\PascalType.Tables.TrueType.post.pas',
  PascalType.Painter in '..\..\Source\PascalType.Painter.pas',
  RenderDemo.Controls.FeatureButton in 'RenderDemo.Controls.FeatureButton.pas',
  PascalType.Tables.OpenType.COLR in '..\..\Source\PascalType.Tables.OpenType.COLR.pas',
  PascalType.Tables.OpenType.CPAL in '..\..\Source\PascalType.Tables.OpenType.CPAL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmRenderDemo, FmRenderDemo);
  Application.Run;
end.
