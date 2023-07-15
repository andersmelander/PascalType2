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
var
  Value16: SmallInt;
begin
  // check (minimum) table size
  if Stream.Position + 54 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read version
  FVersion.Fixed := BigEndianValue.ReadInteger(Stream);

  // check version
  if (Version.Value <> 1) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read font revision
  FFontRevision.Fixed := BigEndianValue.ReadInteger(Stream);

  // read check sum adjust
  FCheckSumAdjustment := BigEndianValue.ReadCardinal(Stream);;

  // read magic number
  FMagicNumber := BigEndianValue.ReadCardinal(Stream);

  // check for magic
  if (FMagicNumber <> $5F0F3CF5) then
    raise EPascalTypeError.Create(RCStrNoMagic);

  // read flags
  FFlags := WordToFontHeaderTableFlags(BigEndianValue.ReadWord(Stream));

  // read UnitsPerEm
  FUnitsPerEm := BigEndianValue.ReadWord(Stream);

  // read CreatedDate
  FCreatedDate := BigEndianValue.ReadInt64(Stream);

  // read ModifiedDate
  FModifiedDate := BigEndianValue.ReadInt64(Stream);

  // read xMin
  FxMin := BigEndianValue.ReadSmallInt(Stream);

  // read yMin
  FyMin := BigEndianValue.ReadSmallInt(Stream);

  // read xMax
  FxMax := BigEndianValue.ReadSmallInt(Stream);

  // read xMax
  FyMax := BigEndianValue.ReadSmallInt(Stream);

  // read MacStyle
  FMacStyle := WordToMacStyles(BigEndianValue.ReadWord(Stream));

  // read LowestRecPPEM
  FLowestRecPPEM := BigEndianValue.ReadWord(Stream);

  // read FontDirectionHint
  FFontDirectionHint := TFontDirectionHint(BigEndianValue.ReadSmallInt(Stream));

  // read IndexToLocFormat
  Value16 := BigEndianValue.ReadSmallInt(Stream);
  case Value16 of
    0:
      FIndexToLocFormat := ilShort;
    1:
      FIndexToLocFormat := ilLong;
  else
    raise EPascalTypeError.CreateFmt(RCStrWrongIndexToLocFormat, [Value16]);
  end;

  // read GlyphDataFormat
  FGlyphDataFormat := BigEndianValue.ReadSmallInt(Stream);
end;

procedure TPascalTypeHeaderTable.SaveToStream(Stream: TStream);
begin
  // write version
  BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));

  // write font revision
  BigEndianValue.WriteCardinal(Stream, Cardinal(FFontRevision));

  // write check sum adjust
  BigEndianValue.WriteCardinal(Stream, FCheckSumAdjustment);

  // write magic number
  BigEndianValue.WriteCardinal(Stream, FMagicNumber);

  // write flags
  BigEndianValue.WriteWord(Stream, FontHeaderTableFlagsToWord(FFlags));

  // write UnitsPerEm
  BigEndianValue.WriteWord(Stream, FUnitsPerEm);

  // write CreatedDate
  BigEndianValue.WriteInt64(Stream, FCreatedDate);

  // write ModifiedDate
  BigEndianValue.WriteInt64(Stream, FModifiedDate);

  // write xMin
  BigEndianValue.WriteSmallInt(Stream, FxMin);

  // write yMin
  BigEndianValue.WriteSmallInt(Stream, FyMin);

  // write xMax
  BigEndianValue.WriteSmallInt(Stream, FxMax);

  // write xMax
  BigEndianValue.WriteSmallInt(Stream, FyMax);

  // write MacStyle
  BigEndianValue.WriteWord(Stream, MacStylesToWord(FMacStyle));

  // write LowestRecPPEM
  BigEndianValue.WriteWord(Stream, FLowestRecPPEM);

  // write FontDirectionHint
  BigEndianValue.WriteWord(Stream, Word(FFontDirectionHint));

  // write IndexToLocFormat
  case FIndexToLocFormat of
    ilShort:
      BigEndianValue.WriteWord(Stream, 0);
    ilLong:
      BigEndianValue.WriteWord(Stream, 1);
  else
    raise EPascalTypeError.CreateFmt(RCStrWrongIndexToLocFormat,
      [Word(FIndexToLocFormat)]);
  end;

  // write GlyphDataFormat
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

