unit PascalType.Tables.TrueType.vhea;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'vhea' table type                                     //
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
  PT_Types,
  PT_Classes,
  PascalType.Tables;

//------------------------------------------------------------------------------
//
//              TPascalTypeVerticalHeaderTable
//
//------------------------------------------------------------------------------
// Vertical header, optional table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/vhea
//------------------------------------------------------------------------------
type
  // Apparently not fully implemented?
  TPascalTypeVerticalHeaderTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion              : TFixedPoint;
    FAscent               : SmallInt; // Distance in FUnits from the centerline to the previous line’s descent.
    FDescent              : SmallInt; // Distance in FUnits from the centerline to the next line’s ascent.
    FLineGap              : SmallInt; // Reserved; set to 0
    FAdvanceHeightMax     : SmallInt; // The maximum advance height measurement -in FUnits found in the font. This value must be consistent with the entries in the vertical metrics table.
    FMinTopSideBearing    : SmallInt; // The minimum top sidebearing measurement found in the font, in FUnits. This value must be consistent with the entries in the vertical metrics table.
    FMinBottomSideBearing : SmallInt; // The minimum bottom sidebearing measurement found in the font, in FUnits. This value must be consistent with the entries in the vertical metrics table.
    FYMaxExtent           : SmallInt; // Defined as yMaxExtent= minTopSideBearing+(yMax-yMin)
    FCaretSlopeRise       : SmallInt; // The value of the caretSlopeRise field divided by the value of the caretSlopeRun Field determines the slope of the caret. A value of 0 for the rise and a value of 1 for the run specifies a horizontal caret. A value of 1 for the rise and a value of 0 for the run specifies a vertical caret. Intermediate values are desirable for fonts whose glyphs are oblique or italic. For a vertical font, a horizontal caret is best.
    FCaretSlopeRun        : SmallInt; // See the caretSlopeRise field. Value=1 for nonslanted vertical fonts.
    FCaretOffset          : SmallInt; // The amount by which the highlight on a slanted glyph needs to be shifted away from the glyph in order to produce the best appearance. Set value equal to 0 for nonslanted fonts.
//    FReserved             : array [0..3] of SmallInt; // Set to 0.
    FMetricDataFormat     : SmallInt; // Set to 0.
    FNumOfLongVerMetrics  : Word;     // Number of advance heights in the vertical metrics table.

    procedure SetVersion(const Value: TFixedPoint);
    procedure SetAdvanceHeightMax(const Value: SmallInt);
    procedure SetAscent(const Value: SmallInt);
    procedure SetCaretOffset(const Value: SmallInt);
    procedure SetCaretSlopeRise(const Value: SmallInt);
    procedure SetCaretSlopeRun(const Value: SmallInt);
    procedure SetDescent(const Value: SmallInt);
    procedure SetLineGap(const Value: SmallInt);
    procedure SetMetricDataFormat(const Value: SmallInt);
    procedure SetMinBottomSideBearing(const Value: SmallInt);
    procedure SetMinTopSideBearing(const Value: SmallInt);
    procedure SetNumOfLongVerMetrics(const Value: Word);
    procedure SetYMaxExtent(const Value: SmallInt);
  protected
    procedure AdvanceHeightMaxChanged; virtual;
    procedure AscentChanged; virtual;
    procedure CaretOffsetChanged; virtual;
    procedure CaretSlopeRiseChanged; virtual;
    procedure CaretSlopeRunChanged; virtual;
    procedure DescentChanged; virtual;
    procedure LineGapChanged; virtual;
    procedure MetricDataFormatChanged; virtual;
    procedure MinBottomSideBearingChanged; virtual;
    procedure MinTopSideBearingChanged; virtual;
    procedure NumOfLongVerMetricsChanged; virtual;
    procedure VersionChanged; virtual;
    procedure YMaxExtentChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
    property Ascent: SmallInt read FAscent write SetAscent;
    property Descent: SmallInt read FDescent write SetDescent;
    property LineGap: SmallInt read FLineGap write SetLineGap;
    property AdvanceHeightMax: SmallInt read FAdvanceHeightMax
      write SetAdvanceHeightMax;
    property MinTopSideBearing: SmallInt read FMinTopSideBearing
      write SetMinTopSideBearing;
    property MinBottomSideBearing: SmallInt read FMinBottomSideBearing
      write SetMinBottomSideBearing;
    property YMaxExtent: SmallInt read FYMaxExtent write SetYMaxExtent;
    property CaretSlopeRise: SmallInt read FCaretSlopeRise
      write SetCaretSlopeRise;
    property CaretSlopeRun: SmallInt read FCaretSlopeRun write SetCaretSlopeRun;
    property CaretOffset: SmallInt read FCaretOffset write SetCaretOffset;
    property MetricDataFormat: SmallInt read FMetricDataFormat
      write SetMetricDataFormat;
    property NumOfLongVerMetrics: Word read FNumOfLongVerMetrics
      write SetNumOfLongVerMetrics;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//              TPascalTypeVerticalHeaderTable
//
//------------------------------------------------------------------------------
constructor TPascalTypeVerticalHeaderTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 1;
end;

procedure TPascalTypeVerticalHeaderTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeVerticalHeaderTable then
  begin
    FVersion := TPascalTypeVerticalHeaderTable(Source).FVersion;
    FAscent := TPascalTypeVerticalHeaderTable(Source).FAscent;
    FDescent := TPascalTypeVerticalHeaderTable(Source).FDescent;
    FLineGap := TPascalTypeVerticalHeaderTable(Source).FLineGap;
    FAdvanceHeightMax := TPascalTypeVerticalHeaderTable(Source).FAdvanceHeightMax;
    FMinTopSideBearing := TPascalTypeVerticalHeaderTable(Source).FMinTopSideBearing;
    FMinBottomSideBearing := TPascalTypeVerticalHeaderTable(Source).FMinBottomSideBearing;
    FYMaxExtent := TPascalTypeVerticalHeaderTable(Source).FYMaxExtent;
    FCaretSlopeRise := TPascalTypeVerticalHeaderTable(Source).FCaretSlopeRise;
    FCaretSlopeRun := TPascalTypeVerticalHeaderTable(Source).FCaretSlopeRun;
    FCaretOffset := TPascalTypeVerticalHeaderTable(Source).FCaretOffset;
    FMetricDataFormat := TPascalTypeVerticalHeaderTable(Source).FMetricDataFormat;
    FNumOfLongVerMetrics := TPascalTypeVerticalHeaderTable(Source).FNumOfLongVerMetrics;
  end;
end;

class function TPascalTypeVerticalHeaderTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'vhea';
end;

procedure TPascalTypeVerticalHeaderTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  i: integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 36 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read version
  FVersion.Fixed := BigEndianValue.ReadCardinal(Stream);

  if Version.Value <> 1 then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // if Version.Fract <> 0
  // then raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read ascent
  FAscent := BigEndianValue.ReadSmallInt(Stream);

  // read descent
  FDescent := BigEndianValue.ReadSmallInt(Stream);

  // read line gap
  FLineGap := BigEndianValue.ReadSmallInt(Stream);

  // read advanced height max
  FAdvanceHeightMax := BigEndianValue.ReadSmallInt(Stream);

  // read minimum side bearing
  FMinTopSideBearing := BigEndianValue.ReadSmallInt(Stream);

  // read minimum bottom bearing
  FMinBottomSideBearing := BigEndianValue.ReadSmallInt(Stream);

  // read y-max extent
  FYMaxExtent := BigEndianValue.ReadSmallInt(Stream);

  // read caret slope rise
  FCaretSlopeRise := BigEndianValue.ReadSmallInt(Stream);

  // read caret slope run
  FCaretSlopeRun := BigEndianValue.ReadSmallInt(Stream);

  // read caret offset
  FCaretOffset := BigEndianValue.ReadSmallInt(Stream);

{$IFDEF AmbigiousExceptions}
  // read reserved
  for i := 0 to 3 do
    if BigEndianValue.ReadSmallInt(Stream) <> 0 then
      raise EPascalTypeError.Create(RCStrReservedValueError);
{$ELSE}
  Stream.Seek(4*SizeOf(SmallInt), soCurrent);
{$ENDIF}
  // read metric data format
  FMetricDataFormat := BigEndianValue.ReadWord(Stream); // Unused - Set to 0

  // read metric data format
  FNumOfLongVerMetrics := BigEndianValue.ReadWord(Stream);
end;

procedure TPascalTypeVerticalHeaderTable.SaveToStream(Stream: TStream);
var
  i: integer;
begin
  inherited;

  // write version
  BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));

  // write ascent
  BigEndianValue.WriteSmallInt(Stream, FAscent);

  // write descent
  BigEndianValue.WriteSmallInt(Stream, FDescent);

  // write line gap
  BigEndianValue.WriteSmallInt(Stream, FLineGap);

  // write advanced height max
  BigEndianValue.WriteSmallInt(Stream, FAdvanceHeightMax);

  // write minimum side bearing
  BigEndianValue.WriteSmallInt(Stream, FMinTopSideBearing);

  // write minimum bottom bearing
  BigEndianValue.WriteSmallInt(Stream, FMinBottomSideBearing);

  // write y-max extent
  BigEndianValue.WriteSmallInt(Stream, FYMaxExtent);

  // write caret slope rise
  BigEndianValue.WriteSmallInt(Stream, FCaretSlopeRise);

  // write caret slope run
  BigEndianValue.WriteSmallInt(Stream, FCaretSlopeRun);

  // write caret offset
  BigEndianValue.WriteSmallInt(Stream, FCaretOffset);

  // write reserved
  for i := 0 to 3 do
    BigEndianValue.WriteCardinal(Stream, 0);

  // write metric data format
  BigEndianValue.WriteWord(Stream, FMetricDataFormat);

  // write number of long vertical metrics
  BigEndianValue.WriteWord(Stream, FNumOfLongVerMetrics);
end;

procedure TPascalTypeVerticalHeaderTable.SetAdvanceHeightMax
  (const Value: SmallInt);
begin
  if FAdvanceHeightMax <> Value then
  begin
    FAdvanceHeightMax := Value;
    AdvanceHeightMaxChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetAscent(const Value: SmallInt);
begin
  if Ascent <> Value then
  begin
    FAscent := Value;
    AscentChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetCaretOffset(const Value: SmallInt);
begin
  if CaretOffset <> Value then
  begin
    FCaretOffset := Value;
    CaretOffsetChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetCaretSlopeRise
  (const Value: SmallInt);
begin
  if CaretSlopeRise <> Value then
  begin
    FCaretSlopeRise := Value;
    CaretSlopeRiseChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetCaretSlopeRun
  (const Value: SmallInt);
begin
  if CaretSlopeRun <> Value then
  begin
    FCaretSlopeRun := Value;
    CaretSlopeRunChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetDescent(const Value: SmallInt);
begin
  if Descent <> Value then
  begin
    FDescent := Value;
    DescentChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetLineGap(const Value: SmallInt);
begin
  if LineGap <> Value then
  begin
    FLineGap := Value;
    LineGapChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetMetricDataFormat
  (const Value: SmallInt);
begin
  if MetricDataFormat <> Value then
  begin
    FMetricDataFormat := Value;
    MetricDataFormatChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetMinBottomSideBearing
  (const Value: SmallInt);
begin
  if MinBottomSideBearing <> Value then
  begin
    FMinBottomSideBearing := Value;
    MinBottomSideBearingChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetMinTopSideBearing
  (const Value: SmallInt);
begin
  if MinTopSideBearing <> Value then
  begin
    FMinTopSideBearing := Value;
    MinTopSideBearingChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetNumOfLongVerMetrics
  (const Value: Word);
begin
  if NumOfLongVerMetrics <> Value then
  begin
    FNumOfLongVerMetrics := Value;
    NumOfLongVerMetricsChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Value <> Value.Value) or (FVersion.Fract <> Value.Fract) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.SetYMaxExtent(const Value: SmallInt);
begin
  if YMaxExtent <> Value then
  begin
    FYMaxExtent := Value;
    YMaxExtentChanged;
  end;
end;

procedure TPascalTypeVerticalHeaderTable.VersionChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.AscentChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.CaretOffsetChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.CaretSlopeRiseChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.CaretSlopeRunChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.DescentChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.AdvanceHeightMaxChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.LineGapChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.MetricDataFormatChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.MinBottomSideBearingChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.MinTopSideBearingChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.NumOfLongVerMetricsChanged;
begin
  Changed;
end;

procedure TPascalTypeVerticalHeaderTable.YMaxExtentChanged;
begin
  Changed;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

initialization

  PascalTypeTableClasses.RegisterTable(TPascalTypeVerticalHeaderTable);

end.
