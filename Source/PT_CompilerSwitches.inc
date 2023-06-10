////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  PascalType - Compiler Switches                                            //
//  ------------------------------                                            //
//                                                                            //
//  With this include file you can finetune some settings. Not all of them    //
//  are documented in full length, but at least a hint is given here as well. //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{ Enable this option, if you want to check even reserved values and other
  not mandatory values.
  * Default: Enabled }
{$DEFINE AmbigiousExceptions} // TODO : Rename this option; Ambigious is not the correct term

{ Enable this option, if you want to raise an exception on non-severe font errors
  * Default: Disabled }
{-$DEFINE WarningExceptions}

{ If enabled every single read operation is validated to ensure all bytes
  queried could be readed entirely. While this guarantee to identify problems
  that would be hidden otherwise it is quite slow for the typical use.
  * Default: Disabled }
{$DEFINE ValidateEveryReadOperation}

{ This compiler switch enables the checksum test for each table. To ensure the
  font file is valid this should be enabled. However some older fonts contain
  invalid checksums, which will result in an exception.
  * Default: Enabled }
{-$DEFINE ChecksumTest}

{ Enable this option, if you want to enable using floating points where
  applicable. If this is disabled you may be able to use this library on
  processors that do not support floating point operations or run too slow.
  * Default: Enabled }
{$DEFINE UseFloatingPoint}

{ Enable this option, if you want to inline all stream data access operations
  If supported by the compiler, this will gain a speed benefit at the expense
  of larger executables.
  * Default: Disabled }
{-$DEFINE UseInline}

{ Enable this option, if you want to skip any optional table that is considered
  to be incomplete by this library. The optional features won't be available,
  but loading of the fonts should still be possible.
  * Default: Disabled }
{$DEFINE IgnoreIncompleteOptionalTables}

{ Enable FailOnCompositeGlyphTooDeep if composite glyph definition that exceed
  a defined max depth (8 by default) should raise an exception.
  Otherwise lower levels will just be ignored.
  See: TPascalTypeFontFace.MaxCompositeGlyphDepth.
  * Default: Enabled }
{$define FailOnCompositeGlyphTooDeep}

{ Enable Inverse_Y_axis to have delta-Y values applies as if the Y-origin is
  at the top, instead of at the bottom.
  See: TPascalTypeRasterizerGraphics32.RenderShapedText
  * Default: Enabled }
{$define Inverse_Y_axis}


{$DEFINE PUREPASCAL}

