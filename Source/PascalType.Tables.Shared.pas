unit PascalType.Tables.Shared;

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
  SysUtils,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables;

type
  TPascalTypeBitmapLineMetrics = class(TCustomPascalTypeTable)
  private
    FAscender             : Shortint;
    FDescender            : Shortint;
    FWidthMax             : Byte;
    FCaretSlopeNumerator  : Shortint;
    FCaretSlopeDenominator: Shortint;
    FCaretOffset          : Shortint;
    FMinOriginSB          : Shortint;
    FMinAdvanceSB         : Shortint;
    FMaxBeforeBL          : Shortint;
    FMinAfterBL           : Shortint;
    procedure SetAscender(const Value: Shortint);
    procedure SetCaretOffset(const Value: Shortint);
    procedure SetCaretSlopeDenominator(const Value: Shortint);
    procedure SetCaretSlopeNumerator(const Value: Shortint);
    procedure SetDescender(const Value: Shortint);
    procedure SetMaxBeforeBL(const Value: Shortint);
    procedure SetMinAdvanceSB(const Value: Shortint);
    procedure SetMinAfterBL(const Value: Shortint);
    procedure SetMinOriginSB(const Value: Shortint);
    procedure SetWidthMax(const Value: Byte);
  protected
    procedure AscenderChanged; virtual;
    procedure CaretOffsetChanged; virtual;
    procedure CaretSlopeDenominatorChanged; virtual;
    procedure CaretSlopeNumeratorChanged; virtual;
    procedure DescenderChanged; virtual;
    procedure MaxBeforeBLChanged; virtual;
    procedure MinAdvanceSBChanged; virtual;
    procedure MinAfterBLChanged; virtual;
    procedure MinOriginSBChanged; virtual;
    procedure WidthMaxChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Ascender: Shortint read FAscender write SetAscender;
    property Descender: Shortint read FDescender write SetDescender;
    property WidthMax: Byte read FWidthMax write SetWidthMax;
    property CaretSlopeNumerator: Shortint read FCaretSlopeNumerator write SetCaretSlopeNumerator;
    property CaretSlopeDenominator: Shortint read FCaretSlopeDenominator write SetCaretSlopeDenominator;
    property CaretOffset: Shortint read FCaretOffset write SetCaretOffset;
    property MinOriginSB: Shortint read FMinOriginSB write SetMinOriginSB;
    property MinAdvanceSB: Shortint read FMinAdvanceSB write SetMinAdvanceSB;
    property MaxBeforeBL: Shortint read FMaxBeforeBL write SetMaxBeforeBL;
    property MinAfterBL: Shortint read FMinAfterBL write SetMinAfterBL;
  end;

  TPascalTypeBitmapSizeTable = class(TCustomPascalTypeTable)
  private
    FIndexSubTableArrayOffset: Cardinal;
    // offset to index subtable from beginning of EBLC.
    FIndexTablesSize: Cardinal;
    // number of bytes in corresponding index subtables and array
    FNumberOfIndexSubTables: Cardinal;
    // an index subtable for each range or format change
    FColorRef       : Cardinal; // not used; set to 0.
    FStartGlyphIndex: Word; // lowest glyph index for this size
    FEndGlyphIndex  : Word; // highest glyph index for this size
    FPpemX          : Byte; // horizontal pixels per Em
    FPpemY          : Byte; // vertical pixels per Em
    FBitDepth       : Byte;
    // the Microsoft rasterizer v.1.7 or greater supports the following bitDepth values, as described below: 1, 2, 4, and 8.
    FFlags: Byte; // vertical or horizontal (see bitmapFlags)

    FHorizontalMetrics: TPascalTypeBitmapLineMetrics;
    FVerticalMetrics  : TPascalTypeBitmapLineMetrics;
    procedure SetBitDepth(const Value: Byte);
    procedure SetColorRef(const Value: Cardinal);
    procedure SetEndGlyphIndex(const Value: Word);
    procedure SetFlags(const Value: Byte);
    procedure SetIndexSubTableArrayOffset(const Value: Cardinal);
    procedure SetIndexTablesSize(const Value: Cardinal);
    procedure SetNumberOfIndexSubTables(const Value: Cardinal);
    procedure SetPpemX(const Value: Byte);
    procedure SetPpemY(const Value: Byte);
    procedure SetStartGlyphIndex(const Value: Word);
  protected
    procedure BitDepthChanged; virtual;
    procedure ColorRefChanged; virtual;
    procedure EndGlyphIndexChanged; virtual;
    procedure FlagsChanged; virtual;
    procedure IndexSubTableArrayOffsetChanged; virtual;
    procedure IndexTablesSizeChanged; virtual;
    procedure NumberOfIndexSubTablesChanged; virtual;
    procedure PpemXChanged; virtual;
    procedure PpemYChanged; virtual;
    procedure StartGlyphIndexChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property IndexSubTableArrayOffset: Cardinal read FIndexSubTableArrayOffset write SetIndexSubTableArrayOffset;
    property IndexTablesSize: Cardinal read FIndexTablesSize write SetIndexTablesSize;
    property NumberOfIndexSubTables: Cardinal read FNumberOfIndexSubTables write SetNumberOfIndexSubTables;
    property ColorRef: Cardinal read FColorRef write SetColorRef;
    property StartGlyphIndex: Word read FStartGlyphIndex write SetStartGlyphIndex;
    property EndGlyphIndex: Word read FEndGlyphIndex write SetEndGlyphIndex;
    property PpemX: Byte read FPpemX write SetPpemX;
    property PpemY: Byte read FPpemY write SetPpemY;
    property BitDepth: Byte read FBitDepth write SetBitDepth;
    property Flags: Byte read FFlags write SetFlags;

    property HorizontalMetrics: TPascalTypeBitmapLineMetrics read FHorizontalMetrics;
    property VerticalMetrics: TPascalTypeBitmapLineMetrics read FVerticalMetrics;
  end;

implementation

uses
  PascalType.ResourceStrings;

{ TPascalTypeBitmapLineMetrics }

procedure TPascalTypeBitmapLineMetrics.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeBitmapLineMetrics then
  begin
    FAscender := TPascalTypeBitmapLineMetrics(Source).FAscender;
    FDescender := TPascalTypeBitmapLineMetrics(Source).FDescender;
    FWidthMax := TPascalTypeBitmapLineMetrics(Source).FWidthMax;
    FCaretSlopeNumerator := TPascalTypeBitmapLineMetrics(Source).FCaretSlopeNumerator;
    FCaretSlopeDenominator := TPascalTypeBitmapLineMetrics(Source).FCaretSlopeDenominator;
    FCaretOffset := TPascalTypeBitmapLineMetrics(Source).FCaretOffset;
    FMinOriginSB := TPascalTypeBitmapLineMetrics(Source).FMinOriginSB;
    FMinAdvanceSB := TPascalTypeBitmapLineMetrics(Source).FMinAdvanceSB;
    FMaxBeforeBL := TPascalTypeBitmapLineMetrics(Source).FMaxBeforeBL;
    FMinAfterBL := TPascalTypeBitmapLineMetrics(Source).FMinAfterBL;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  if Stream.Position + 12 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  Stream.Read(FAscender, 1);
  Stream.Read(FDescender, 1);
  Stream.Read(FWidthMax, 1);
  Stream.Read(FCaretSlopeNumerator, 1);
  Stream.Read(FCaretSlopeDenominator, 1);
  Stream.Read(FCaretOffset, 1);
  Stream.Read(FMinOriginSB, 1);
  Stream.Read(FMinAdvanceSB, 1);
  Stream.Read(FMaxBeforeBL, 1);
  Stream.Read(FMinAfterBL, 1);

  // Skip padding
  Stream.Seek(2, soCurrent);
end;

procedure TPascalTypeBitmapLineMetrics.SaveToStream(Stream: TStream);
begin
  inherited;

  Stream.Write(FAscender, 1);
  Stream.Write(FDescender, 1);
  Stream.Write(FWidthMax, 1);
  Stream.Write(FCaretSlopeNumerator, 1);
  Stream.Write(FCaretSlopeDenominator, 1);
  Stream.Write(FCaretOffset, 1);
  Stream.Write(FMinOriginSB, 1);
  Stream.Write(FMinAdvanceSB, 1);
  Stream.Write(FMaxBeforeBL, 1);
  Stream.Write(FMinAfterBL, 1);
end;

procedure TPascalTypeBitmapLineMetrics.SetAscender(const Value: Shortint);
begin
  if FAscender <> Value then
  begin
    FAscender := Value;
    AscenderChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetCaretOffset(const Value: Shortint);
begin
  if FCaretOffset <> Value then
  begin
    FCaretOffset := Value;
    CaretOffsetChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetCaretSlopeDenominator
  (const Value: Shortint);
begin
  if FCaretSlopeDenominator <> Value then
  begin
    FCaretSlopeDenominator := Value;
    CaretSlopeDenominatorChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetCaretSlopeNumerator
  (const Value: Shortint);
begin
  if FCaretSlopeNumerator <> Value then
  begin
    FCaretSlopeNumerator := Value;
    CaretSlopeNumeratorChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetDescender(const Value: Shortint);
begin
  if FDescender <> Value then
  begin
    FDescender := Value;
    DescenderChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetMaxBeforeBL(const Value: Shortint);
begin
  if FMaxBeforeBL <> Value then
  begin
    FMaxBeforeBL := Value;
    MaxBeforeBLChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetMinAdvanceSB(const Value: Shortint);
begin
  if FMinAdvanceSB <> Value then
  begin
    FMinAdvanceSB := Value;
    MinAdvanceSBChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetMinAfterBL(const Value: Shortint);
begin
  if FMinAfterBL <> Value then
  begin
    FMinAfterBL := Value;
    MinAfterBLChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetMinOriginSB(const Value: Shortint);
begin
  if FMinOriginSB <> Value then
  begin
    FMinOriginSB := Value;
    MinOriginSBChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.SetWidthMax(const Value: Byte);
begin
  if FWidthMax <> Value then
  begin
    FWidthMax := Value;
    WidthMaxChanged;
  end;
end;

procedure TPascalTypeBitmapLineMetrics.AscenderChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.CaretOffsetChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.CaretSlopeDenominatorChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.CaretSlopeNumeratorChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.DescenderChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.MaxBeforeBLChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.MinAdvanceSBChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.MinAfterBLChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.MinOriginSBChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapLineMetrics.WidthMaxChanged;
begin
  Changed;
end;

{ TPascalTypeBitmapSizeTable }

constructor TPascalTypeBitmapSizeTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FHorizontalMetrics := TPascalTypeBitmapLineMetrics.Create(Self);
  FVerticalMetrics := TPascalTypeBitmapLineMetrics.Create(Self);
end;

destructor TPascalTypeBitmapSizeTable.Destroy;
begin
  FreeAndNil(FHorizontalMetrics);
  FreeAndNil(FVerticalMetrics);
  inherited;
end;

procedure TPascalTypeBitmapSizeTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeBitmapSizeTable then
  begin
    FIndexSubTableArrayOffset := TPascalTypeBitmapSizeTable(Source).FIndexSubTableArrayOffset;
    FIndexTablesSize := TPascalTypeBitmapSizeTable(Source).FIndexTablesSize;
    FNumberOfIndexSubTables := TPascalTypeBitmapSizeTable(Source).FNumberOfIndexSubTables;
    FColorRef := TPascalTypeBitmapSizeTable(Source).FColorRef;
    FStartGlyphIndex := TPascalTypeBitmapSizeTable(Source).FStartGlyphIndex;
    FEndGlyphIndex := TPascalTypeBitmapSizeTable(Source).FEndGlyphIndex;
    FPpemX := TPascalTypeBitmapSizeTable(Source).FPpemX;
    FPpemY := TPascalTypeBitmapSizeTable(Source).FPpemY;
    FBitDepth := TPascalTypeBitmapSizeTable(Source).FBitDepth;
    FFlags := TPascalTypeBitmapSizeTable(Source).FFlags;

    FHorizontalMetrics.Assign(TPascalTypeBitmapSizeTable(Source).FHorizontalMetrics);
    FVerticalMetrics.Assign(TPascalTypeBitmapSizeTable(Source).FVerticalMetrics);
  end;
end;

procedure TPascalTypeBitmapSizeTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 24 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FIndexSubTableArrayOffset := BigEndianValue.ReadCardinal(Stream);
  FIndexTablesSize := BigEndianValue.ReadCardinal(Stream);
  FNumberOfIndexSubTables := BigEndianValue.ReadCardinal(Stream);
  FColorRef := BigEndianValue.ReadCardinal(Stream);
  FHorizontalMetrics.LoadFromStream(Stream);
  FVerticalMetrics.LoadFromStream(Stream);
  FStartGlyphIndex := BigEndianValue.ReadWord(Stream);
  FEndGlyphIndex := BigEndianValue.ReadWord(Stream);
  Stream.Read(FPpemX, 1);
  Stream.Read(FPpemY, 1);
  Stream.Read(FBitDepth, 1);
  Stream.Read(FFlags, 1);
end;

procedure TPascalTypeBitmapSizeTable.SaveToStream(Stream: TStream);
begin

  BigEndianValue.WriteCardinal(Stream, FIndexSubTableArrayOffset);
  BigEndianValue.WriteCardinal(Stream, FIndexTablesSize);
  BigEndianValue.WriteCardinal(Stream, FNumberOfIndexSubTables);
  BigEndianValue.WriteCardinal(Stream, FColorRef);
  FHorizontalMetrics.SaveToStream(Stream);
  FVerticalMetrics.SaveToStream(Stream);
  BigEndianValue.WriteWord(Stream, FStartGlyphIndex);
  BigEndianValue.WriteWord(Stream, FEndGlyphIndex);
  Write(FPpemX, 1);
  Write(FPpemY, 1);
  Write(FBitDepth, 1);
  Write(FFlags, 1);
end;

procedure TPascalTypeBitmapSizeTable.SetBitDepth(const Value: Byte);
begin
  if FBitDepth <> Value then
  begin
    FBitDepth := Value;
    BitDepthChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetColorRef(const Value: Cardinal);
begin
  if FColorRef <> Value then
  begin
    FColorRef := Value;
    ColorRefChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetEndGlyphIndex(const Value: Word);
begin
  if FEndGlyphIndex <> Value then
  begin
    FEndGlyphIndex := Value;
    EndGlyphIndexChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetFlags(const Value: Byte);
begin
  if FFlags <> Value then
  begin
    FFlags := Value;
    FlagsChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetIndexSubTableArrayOffset
  (const Value: Cardinal);
begin
  if FIndexSubTableArrayOffset <> Value then
  begin
    FIndexSubTableArrayOffset := Value;
    IndexSubTableArrayOffsetChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetIndexTablesSize(const Value: Cardinal);
begin
  if FIndexTablesSize <> Value then
  begin
    FIndexTablesSize := Value;
    IndexTablesSizeChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetNumberOfIndexSubTables
  (const Value: Cardinal);
begin
  if FNumberOfIndexSubTables <> Value then
  begin
    FNumberOfIndexSubTables := Value;
    NumberOfIndexSubTablesChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetPpemX(const Value: Byte);
begin
  if FPpemX <> Value then
  begin
    FPpemX := Value;
    PpemXChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetPpemY(const Value: Byte);
begin
  if FPpemY <> Value then
  begin
    FPpemY := Value;
    PpemYChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.SetStartGlyphIndex(const Value: Word);
begin
  if FStartGlyphIndex <> Value then
  begin
    FStartGlyphIndex := Value;
    StartGlyphIndexChanged;
  end;
end;

procedure TPascalTypeBitmapSizeTable.BitDepthChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.ColorRefChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.EndGlyphIndexChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.FlagsChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.IndexSubTableArrayOffsetChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.IndexTablesSizeChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.NumberOfIndexSubTablesChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.PpemXChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.PpemYChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapSizeTable.StartGlyphIndexChanged;
begin
  Changed;
end;

end.
