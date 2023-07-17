unit PascalType.Tables.TrueType.head;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'head' table type                                     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  Version: MPL 1.1 or LGPL 2.1 with linking exception                       //
//                                                                            //
//  The contents of this file are subject to the Mozilla Public License       //
//  Version 1.1 (the "License"); you may not use this file except in          //
//  compliance with the License. You may obtain a copy of the License at      //
//  http://www.mozilla.org/MPL/                                               //
//                                                                            //
//  Software distributed under the License is distributed on an "AS IS"       //
//  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the   //
//  License for the specific language governing rights and limitations under  //
//  the License.                                                              //
//                                                                            //
//  Alternatively, the contents of this file may be used under the terms of   //
//  the Free Pascal modified version of the GNU Lesser General Public         //
//  License Version 2.1 (the "FPC modified LGPL License"), in which case the  //
//  provisions of this license are applicable instead of those above.         //
//  Please see the file LICENSE.txt for additional information concerning     //
//  this license.                                                             //
//                                                                            //
//  The code is part of the PascalType Project                                //
//                                                                            //
//  The initial developer of this code is Christian-W. Budde                  //
//                                                                            //
//  Portions created by Christian-W. Budde are Copyright (C) 2010-2017        //
//  by Christian-W. Budde. All Rights Reserved.                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface


{$I PT_Compiler.inc}

uses
  Classes,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables;

//------------------------------------------------------------------------------
//
//              TPascalTypeHeaderTable
//
//------------------------------------------------------------------------------
// head — Font Header Table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/head
// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6head.html
//------------------------------------------------------------------------------
type
  TPascalTypeHeaderTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion            : TFixedPoint; // = $00010000
    FFontRevision       : TFixedPoint; // set by font manufacturer
    FCheckSumAdjustment : Cardinal; // To compute: set it to 0, calculate the checksum for the 'head' table and put it in the table directory, sum the entire font as uint32, then store B1B0AFBA - sum. The checksum for the 'head' table will not be wrong. That is OK.
    FMagicNumber        : Cardinal; // set to $5F0F3CF5
    FFlags              : TFontHeaderTableFlags;
    FUnitsPerEm         : Word; // range from 64 to 16384
    FCreatedDate        : Int64; // created international date
    FModifiedDate       : Int64; // modified international date
    FxMin               : SmallInt; // for all glyph bounding boxes
    FyMin               : SmallInt; // for all glyph bounding boxes
    FxMax               : SmallInt; // for all glyph bounding boxes
    FyMax               : SmallInt; // for all glyph bounding boxes
    FMacStyle           : TMacStyles; // see TMacStyles
    FLowestRecPPEM      : Word; // smallest readable size in pixels
    FFontDirectionHint  : TFontDirectionHint;
    FIndexToLocFormat   : TIndexToLocationFormat;
    FGlyphDataFormat    : Word; // 0 for current format
    procedure SetCheckSumAdjustment(const Value: Cardinal);
    procedure SetCreatedDate(const Value: Int64);
    procedure SetFlags(const Value: TFontHeaderTableFlags);
    procedure SetFontDirectionHint(const Value: TFontDirectionHint);
    procedure SetFontRevision(const Value: TFixedPoint);
    procedure SetGlyphDataFormat(const Value: Word);
    procedure SetIndexToLocFormat(const Value: TIndexToLocationFormat);
    procedure SetLowestRecPPEM(const Value: Word);
    procedure SetMacStyle(const Value: TMacStyles);
    procedure SetModifiedDate(const Value: Int64);
    procedure SetUnitsPerEm(const Value: Word);
    procedure SetVersion(const Value: TFixedPoint);
    procedure SetXMax(const Value: SmallInt);
    procedure SetXMin(const Value: SmallInt);
    procedure SetYMax(const Value: SmallInt);
    procedure SetYMin(const Value: SmallInt);
  protected
    procedure CheckSumAdjustmentChanged; virtual;
    procedure CreatedDateChanged; virtual;
    procedure FlagsChanged; virtual;
    procedure FontDirectionHintChanged; virtual;
    procedure FontRevisionChanged; virtual;
    procedure GlyphDataFormatChanged; virtual;
    procedure IndexToLocFormatChanged; virtual;
    procedure LowestRecPPEMChanged; virtual;
    procedure MacStyleChanged; virtual;
    procedure ModifiedDateChanged; virtual;
    procedure UnitsPerEmChanged; virtual;
    procedure VersionChanged; virtual;
    procedure XMaxChanged; virtual;
    procedure XMinChanged; virtual;
    procedure YMaxChanged; virtual;
    procedure YMinChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    // table data
    property Version: TFixedPoint read FVersion write SetVersion; // = $00010000
    property FontRevision: TFixedPoint read FFontRevision write SetFontRevision; // set by font manufacturer
    property CheckSumAdjustment: Cardinal read FCheckSumAdjustment write SetCheckSumAdjustment; // To compute: set it to 0, calculate the checksum for the 'head' table and put it in the table directory, sum the entire font as uint32, then store B1B0AFBA - sum. The checksum for the 'head' table will not be wrong. That is OK.
    property Flags: TFontHeaderTableFlags read FFlags write SetFlags;
    property UnitsPerEm: Word read FUnitsPerEm write SetUnitsPerEm; // range from 64 to 16384
    property CreatedDate: Int64 read FCreatedDate write SetCreatedDate; // created international date
    property ModifiedDate: Int64 read FModifiedDate write SetModifiedDate; // modified international date
    property XMin: SmallInt read FxMin write SetXMin; // for all glyph bounding boxes
    property YMin: SmallInt read FyMin write SetYMin; // for all glyph bounding boxes
    property XMax: SmallInt read FxMax write SetXMax; // for all glyph bounding boxes
    property YMax: SmallInt read FyMax write SetYMax; // for all glyph bounding boxes
    property MacStyle: TMacStyles read FMacStyle write SetMacStyle;
    property LowestRecPPEM: Word read FLowestRecPPEM write SetLowestRecPPEM; // smallest readable size in pixels
    property FontDirectionHint: TFontDirectionHint read FFontDirectionHint write SetFontDirectionHint; // 0 Mixed directional glyphs
    property IndexToLocationFormat: TIndexToLocationFormat read FIndexToLocFormat write SetIndexToLocFormat; // 0 for short offsets, 1 for long
    property GlyphDataFormat: Word read FGlyphDataFormat write SetGlyphDataFormat; // 0 for current format
  end;




//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.ResourceStrings;


//------------------------------------------------------------------------------
//
//              TPascalTypeHeaderTable
//
//------------------------------------------------------------------------------
constructor TPascalTypeHeaderTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;

  FVersion.Value := 1;
  FVersion.Fract := 0;
  FFontRevision.Value := 1;
  FFontRevision.Fract := 0;
  FCheckSumAdjustment := 0;
  FMagicNumber := $F53C0F5F;
  FUnitsPerEm := 2048;
end;

procedure TPascalTypeHeaderTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeHeaderTable then
  begin
    FVersion := TPascalTypeHeaderTable(Source).FVersion;
    FFontRevision := TPascalTypeHeaderTable(Source).FFontRevision;
    FCheckSumAdjustment := TPascalTypeHeaderTable(Source).FCheckSumAdjustment;
    FMagicNumber := TPascalTypeHeaderTable(Source).FMagicNumber;
    FFlags := TPascalTypeHeaderTable(Source).FFlags;
    FUnitsPerEm := TPascalTypeHeaderTable(Source).FUnitsPerEm;
    FCreatedDate := TPascalTypeHeaderTable(Source).FCreatedDate;
    FModifiedDate := TPascalTypeHeaderTable(Source).FModifiedDate;
    FxMin := TPascalTypeHeaderTable(Source).FxMin;
    FyMin := TPascalTypeHeaderTable(Source).FyMin;
    FxMax := TPascalTypeHeaderTable(Source).FxMax;
    FyMax := TPascalTypeHeaderTable(Source).FyMax;
    FMacStyle := TPascalTypeHeaderTable(Source).FMacStyle;
    FLowestRecPPEM := TPascalTypeHeaderTable(Source).FLowestRecPPEM;
    FFontDirectionHint := TPascalTypeHeaderTable(Source).FFontDirectionHint;
    FIndexToLocFormat := TPascalTypeHeaderTable(Source).FIndexToLocFormat;
    FGlyphDataFormat := TPascalTypeHeaderTable(Source).FGlyphDataFormat;
  end;
end;

class function TPascalTypeHeaderTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'head';
end;

procedure TPascalTypeHeaderTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // Type         | Name               | Description
  // -------------|--------------------|----------------------------------------------------------------------------------------------------
  // uint16       | majorVersion       | Major version number of the font header table — set to 1.
  // uint16       | minorVersion       | Minor version number of the font header table — set to 0.
  // Fixed        | fontRevision       | Set by font manufacturer.
  // uint32       | checkSumAdjustment | To compute: set it to 0, sum the entire font as uint32, then store 0xB1B0AFBA - sum.If the font is used as a component in a font collection file, the value of this field will be invalidated by changes to the file structure and font table directory, and must be ignored.
  // uint32       | magicNumber        | Set to 0x5F0F3CF5.
  // uint16       | flags              |    Bit 0: Baseline for font at y = 0;
  //                                        Bit 1: Left sidebearing point at x = 0(relevant only for TrueType rasterizers) — see the note below regarding variable fonts;
  //                                        Bit 2: Instructions may depend on point size;
  //                                        Bit 3: Force ppem to integer values for all internal scaler math; may use fractional ppem sizes if this bit is clear;
  //                                        Bit 4: Instructions may alter advance width(the advance widths might not scale linearly);
  //                                        Bit 5: This bit is not used in OpenType, and should not be set in order to ensure compatible behavior on all platforms.If set, it may result in different behavior for vertical layout in some platforms. (See Apple's specification for details regarding behavior in Apple platforms.)
  //                                        Bits 6–10: These bits are not used in Opentype and should always be cleared. (See Apple's specification for details regarding legacy used in Apple platforms.)
  //                                        Bit 11: Font data is ‘lossless’ as a results of having been subjected to optimizing transformation and/or compression (such as e.g.compression mechanisms defined by ISO/IEC 14496-18, MicroType Express, WOFF 2.0 or similar) where the original font functionality and features are retained but the binary compatibility between input and output font files is not guaranteed.As a result of the applied transform, the ‘DSIG’ Table may also be invalidated.
  //                                        Bit 12: Font converted (produce compatible metrics)
  //                                        Bit 13: Font optimized for ClearType™. Note, fonts that rely on embedded bitmaps (EBDT) for rendering should not be considered optimized for ClearType, and therefore should keep this bit cleared.
  //                                        Bit 14: Last Resort font.If set, indicates that the glyphs encoded in the cmap subtables are simply generic symbolic representations of code point ranges and don’t truly represent support for those code points.If unset, indicates that the glyphs encoded in the cmap subtables represent proper support for those code points.
  //                                        Bit 15: Reserved, set to 0
  // uint16       | unitsPerEm         | Valid range is from 16 to 16384. This value should be a power of 2 for fonts that have TrueType outlines.
  // LONGDATETIME | created            | Number of seconds since 12:00 midnight that started January 1st 1904 in GMT/UTC time zone. 64-bit integer
  // LONGDATETIME | modified           | Number of seconds since 12:00 midnight that started January 1st 1904 in GMT/UTC time zone. 64-bit integer
  // int16        | xMin               | For all glyph bounding boxes.
  // int16        | yMin               | For all glyph bounding boxes.
  // int16        | xMax               | For all glyph bounding boxes.
  // int16        | yMax               | For all glyph bounding boxes.
  // uint16       | macStyle           |   Bit 0: Bold (if set to 1);
  //                                       Bit 1: Italic(if set to 1)
  //                                       Bit 2: Underline(if set to 1)
  //                                       Bit 3: Outline(if set to 1)
  //                                       Bit 4: Shadow(if set to 1)
  //                                       Bit 5: Condensed(if set to 1)
  //                                       Bit 6: Extended(if set to 1)
  //                                       Bits 7–15: Reserved(set to 0).
  // uint16       |lowestRecPPEM       |  Smallest readable size in pixels.
  // int16        | fontDirectionHint  |  Deprecated(Set to 2).
  //                                          0: Fully mixed directional glyphs;
  //                                          1: Only strongly left to right;
  //                                          2: Like 1 but also contains neutrals;
  //                                          -1: Only strongly right to left;
  //                                          -2: Like -1 but also contains neutrals. 1
  // int16        | indexToLocFormat   | 0 for short offsets (Offset16), 1 for long (Offset32).
  // int16        | glyphDataFormat    | 0 for current format.

  // check (minimum) table size
  if Stream.Position + 54 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FVersion.Fixed := BigEndianValue.ReadInteger(Stream);

  if (Version.Value <> 1) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  FFontRevision.Fixed := BigEndianValue.ReadInteger(Stream);
  FCheckSumAdjustment := BigEndianValue.ReadCardinal(Stream);;
  FMagicNumber := BigEndianValue.ReadCardinal(Stream);
  if (FMagicNumber <> $5F0F3CF5) then
    raise EPascalTypeError.Create(RCStrNoMagic);

  FFlags := WordToFontHeaderTableFlags(BigEndianValue.ReadWord(Stream));
  FUnitsPerEm := BigEndianValue.ReadWord(Stream);
  FCreatedDate := BigEndianValue.ReadInt64(Stream);
  FModifiedDate := BigEndianValue.ReadInt64(Stream);
  FxMin := BigEndianValue.ReadSmallInt(Stream);
  FyMin := BigEndianValue.ReadSmallInt(Stream);
  FxMax := BigEndianValue.ReadSmallInt(Stream);
  FyMax := BigEndianValue.ReadSmallInt(Stream);
  FMacStyle := WordToMacStyles(BigEndianValue.ReadWord(Stream));
  FLowestRecPPEM := BigEndianValue.ReadWord(Stream);
  FFontDirectionHint := TFontDirectionHint(BigEndianValue.ReadSmallInt(Stream));
  FIndexToLocFormat := TIndexToLocationFormat(BigEndianValue.ReadSmallInt(Stream));
  if (not(FIndexToLocFormat in [ilShort, ilLong])) then
    raise EPascalTypeError.CreateFmt(RCStrWrongIndexToLocFormat, [Ord(FIndexToLocFormat)]);
  FGlyphDataFormat := BigEndianValue.ReadSmallInt(Stream);
end;

procedure TPascalTypeHeaderTable.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));
  BigEndianValue.WriteCardinal(Stream, Cardinal(FFontRevision));
  BigEndianValue.WriteCardinal(Stream, FCheckSumAdjustment);
  BigEndianValue.WriteCardinal(Stream, FMagicNumber);
  BigEndianValue.WriteWord(Stream, FontHeaderTableFlagsToWord(FFlags));
  BigEndianValue.WriteWord(Stream, FUnitsPerEm);
  BigEndianValue.WriteInt64(Stream, FCreatedDate);
  BigEndianValue.WriteInt64(Stream, FModifiedDate);
  BigEndianValue.WriteSmallInt(Stream, FxMin);
  BigEndianValue.WriteSmallInt(Stream, FyMin);
  BigEndianValue.WriteSmallInt(Stream, FxMax);
  BigEndianValue.WriteSmallInt(Stream, FyMax);
  BigEndianValue.WriteWord(Stream, MacStylesToWord(FMacStyle));
  BigEndianValue.WriteWord(Stream, FLowestRecPPEM);
  BigEndianValue.WriteWord(Stream, Word(FFontDirectionHint));
  BigEndianValue.WriteWord(Stream, Ord(FIndexToLocFormat));
  BigEndianValue.WriteWord(Stream, FGlyphDataFormat);
end;

procedure TPascalTypeHeaderTable.SetCheckSumAdjustment(const Value: Cardinal);
begin
  if FCheckSumAdjustment <> Value then
  begin
    FCheckSumAdjustment := Value;
    CheckSumAdjustmentChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetCreatedDate(const Value: Int64);
begin
  if FCreatedDate <> CreatedDate then
  begin
    FCreatedDate := Value;
    CreatedDateChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetFlags(const Value: TFontHeaderTableFlags);
begin
  if FFlags <> Value then
  begin
    FFlags := Value;
    FlagsChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetFontDirectionHint
  (const Value: TFontDirectionHint);
begin
  if FFontDirectionHint <> Value then
  begin
    FFontDirectionHint := Value;
    FontDirectionHintChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetFontRevision(const Value: TFixedPoint);
begin
  if (FFontRevision.Fract <> Value.Fract) or (FFontRevision.Value <> Value.Value)
  then
  begin
    FFontRevision := Value;
    FontRevisionChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetGlyphDataFormat(const Value: Word);
begin
  if FGlyphDataFormat <> Value then
  begin
    FGlyphDataFormat := Value;
    GlyphDataFormatChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetIndexToLocFormat
  (const Value: TIndexToLocationFormat);
begin
  if FIndexToLocFormat <> Value then
  begin
    FIndexToLocFormat := Value;
    IndexToLocFormatChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetLowestRecPPEM(const Value: Word);
begin
  if FLowestRecPPEM <> Value then
  begin
    FLowestRecPPEM := Value;
    LowestRecPPEMChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetMacStyle(const Value: TMacStyles);
begin
  if FMacStyle <> Value then
  begin
    FMacStyle := Value;
    MacStyleChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetModifiedDate(const Value: Int64);
begin
  if FModifiedDate <> Value then
  begin
    FModifiedDate := Value;
    ModifiedDateChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetUnitsPerEm(const Value: Word);
begin
  if FUnitsPerEm <> Value then
  begin
    FUnitsPerEm := Value;
    UnitsPerEmChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion <> Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetXMax(const Value: SmallInt);
begin
  if FxMax <> Value then
  begin
    FxMax := Value;
    XMaxChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetXMin(const Value: SmallInt);
begin
  if FxMin <> Value then
  begin
    FxMin := Value;
    XMinChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetYMax(const Value: SmallInt);
begin
  if FyMax <> Value then
  begin
    FyMax := Value;
    YMaxChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetYMin(const Value: SmallInt);
begin
  if FyMin <> Value then
  begin
    FyMin := Value;
    YMinChanged;
  end;
end;

procedure TPascalTypeHeaderTable.CheckSumAdjustmentChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.CreatedDateChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.FlagsChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.FontDirectionHintChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.FontRevisionChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.GlyphDataFormatChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.IndexToLocFormatChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.LowestRecPPEMChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.MacStyleChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.ModifiedDateChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.UnitsPerEmChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.VersionChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.XMaxChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.XMinChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.YMaxChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.YMinChanged;
begin
  Changed;
end;


initialization

  PascalTypeTableClasses.RegisterTable(TPascalTypeHeaderTable);

end.

