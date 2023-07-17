unit PascalType.Tables.TrueType.hhea;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'hhea' table type                                     //
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
//              TPascalTypeHorizontalHeaderTable
//
//------------------------------------------------------------------------------
// Horizontal header, required table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/hhea
//------------------------------------------------------------------------------
type
  TPascalTypeHorizontalHeaderTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion             : TFixedPoint; // set to 1.0
    FAscent              : SmallInt;    // Distance from baseline of highest ascender
    FDescent             : SmallInt;    // Distance from baseline of lowest descender
    FLineGap             : SmallInt;    // typographic line gap
    FAdvanceWidthMax     : Word;        // must be consistent with horizontal metrics
    FMinLeftSideBearing  : SmallInt;    // must be consistent with horizontal metrics
    FMinRightSideBearing : SmallInt;    // must be consistent with horizontal metrics
    FXMaxExtent          : SmallInt;    // max(lsb + (xMax-xMin))
    FCaretSlopeRise      : SmallInt;    // used to calculate the slope of the caret (rise/run) set to 1 for vertical caret
    FCaretSlopeRun       : SmallInt;    // 0 for vertical
    FCaretOffset         : SmallInt;    // set value to 0 for non-slanted fonts
    FMetricDataFormat    : SmallInt;    // 0 for current format
    FNumOfLongHorMetrics : Word;        // number of advance widths in metrics table
    procedure SetAdvanceWidthMax(const Value: Word);
    procedure SetAscent(const Value: SmallInt);
    procedure SetCaretOffset(const Value: SmallInt);
    procedure SetCaretSlopeRise(const Value: SmallInt);
    procedure SetCaretSlopeRun(const Value: SmallInt);
    procedure SetDescent(const Value: SmallInt);
    procedure SetLineGap(const Value: SmallInt);
    procedure SetMetricDataFormat(const Value: SmallInt);
    procedure SetMinLeftSideBearing(const Value: SmallInt);
    procedure SetMinRightSideBearing(const Value: SmallInt);
    procedure SetNumOfLongHorMetrics(const Value: Word);
    procedure SetVersion(const Value: TFixedPoint);
    procedure SetXMaxExtent(const Value: SmallInt);
  protected
    procedure AdvanceWidthMaxChanged; virtual;
    procedure AscentChanged; virtual;
    procedure CaretOffsetChanged; virtual;
    procedure CaretSlopeRiseChanged; virtual;
    procedure CaretSlopeRunChanged; virtual;
    procedure DescentChanged; virtual;
    procedure LineGapChanged; virtual;
    procedure MetricDataFormatChanged; virtual;
    procedure MinLeftSideBearingChanged; virtual;
    procedure MinRightSideBearingChanged; virtual;
    procedure NumOfLongHorMetricsChanged; virtual;
    procedure VersionChanged; virtual;
    procedure XMaxExtentChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
    property Ascent         : SmallInt read FAscent write SetAscent;
    property Descent        : SmallInt read FDescent write SetDescent;
    property LineGap        : SmallInt read FLineGap write SetLineGap;
    property AdvanceWidthMax: Word read FAdvanceWidthMax write SetAdvanceWidthMax;
    property MinLeftSideBearing: SmallInt read FMinLeftSideBearing write SetMinLeftSideBearing;
    property MinRightSideBearing: SmallInt read FMinRightSideBearing write SetMinRightSideBearing;
    property XMaxExtent    : SmallInt read FXMaxExtent write SetXMaxExtent;
    property CaretSlopeRise: SmallInt read FCaretSlopeRise write SetCaretSlopeRise;
    property CaretSlopeRun: SmallInt read FCaretSlopeRun write SetCaretSlopeRun;
    property CaretOffset     : SmallInt read FCaretOffset write SetCaretOffset;
    property MetricDataFormat: SmallInt read FMetricDataFormat write SetMetricDataFormat;
    property NumOfLongHorMetrics: Word read FNumOfLongHorMetrics write SetNumOfLongHorMetrics;
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
//              TPascalTypeHorizontalHeaderTable
//
//------------------------------------------------------------------------------
constructor TPascalTypeHorizontalHeaderTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 1;
end;

procedure TPascalTypeHorizontalHeaderTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeHorizontalHeaderTable then
  begin
    FVersion := TPascalTypeHorizontalHeaderTable(Source).FVersion;
    FAscent := TPascalTypeHorizontalHeaderTable(Source).FAscent;
    FDescent := TPascalTypeHorizontalHeaderTable(Source).FDescent;
    FLineGap := TPascalTypeHorizontalHeaderTable(Source).FLineGap;
    FAdvanceWidthMax := TPascalTypeHorizontalHeaderTable(Source).FAdvanceWidthMax;
    FMinLeftSideBearing := TPascalTypeHorizontalHeaderTable(Source).FMinLeftSideBearing;
    FMinRightSideBearing := TPascalTypeHorizontalHeaderTable(Source).FMinRightSideBearing;
    FXMaxExtent := TPascalTypeHorizontalHeaderTable(Source).FXMaxExtent;
    FCaretSlopeRise := TPascalTypeHorizontalHeaderTable(Source).FCaretSlopeRise;
    FCaretSlopeRun := TPascalTypeHorizontalHeaderTable(Source).FCaretSlopeRun;
    FCaretOffset := TPascalTypeHorizontalHeaderTable(Source).FCaretOffset;
    FMetricDataFormat := TPascalTypeHorizontalHeaderTable(Source).FMetricDataFormat;
    FNumOfLongHorMetrics := TPascalTypeHorizontalHeaderTable(Source).FNumOfLongHorMetrics;
  end;
end;

class function TPascalTypeHorizontalHeaderTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'hhea';
end;

procedure TPascalTypeHorizontalHeaderTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | Type   | Name                | Description                                                                     |
  // +========+=====================+=================================================================================+
  // | Fixed  | version             | 0x00010000 (1.0)                                                                |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | FWord  | ascent              | Distance from baseline of highest ascender                                      |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | FWord  | descent             | Distance from baseline of lowest descender                                      |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | FWord  | lineGap             | typographic line gap                                                            |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | uFWord | advanceWidthMax     | must be consistent with horizontal metrics                                      |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | FWord  | minLeftSideBearing  | must be consistent with horizontal metrics                                      |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | FWord  | minRightSideBearing | must be consistent with horizontal metrics                                      |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | FWord  | xMaxExtent          | max(lsb + (xMax-xMin))                                                          |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | int16  | caretSlopeRise      | used to calculate the slope of the caret (rise/run) set to 1 for vertical caret |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | int16  | caretSlopeRun       | 0 for vertical                                                                  |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | FWord  | caretOffset         | set value to 0 for non-slanted fonts                                            |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | int16  | reserved            | set value to 0                                                                  |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | int16  | reserved            | set value to 0                                                                  |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | int16  | reserved            | set value to 0                                                                  |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | int16  | reserved            | set value to 0                                                                  |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | int16  | metricDataFormat    | 0 for current format                                                            |
  // +--------+---------------------+---------------------------------------------------------------------------------+
  // | uint16 | numOfLongHorMetrics | number of advance widths in metrics table                                       |
  // +--------+---------------------+---------------------------------------------------------------------------------+

  // check (minimum) table size
  if Stream.Position + 32 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FVersion.Fixed := BigEndianValue.ReadCardinal(Stream);

  // check version
  if not(Version.Value = 1) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  FAscent := BigEndianValue.ReadSmallInt(Stream);
  FDescent := BigEndianValue.ReadSmallInt(Stream);
  FLineGap := BigEndianValue.ReadSmallInt(Stream);
  FAdvanceWidthMax := BigEndianValue.ReadWord(Stream);
  FMinLeftSideBearing := BigEndianValue.ReadSmallInt(Stream);
  FMinRightSideBearing := BigEndianValue.ReadSmallInt(Stream);
  FXMaxExtent := BigEndianValue.ReadSmallInt(Stream);
  FCaretSlopeRise := BigEndianValue.ReadSmallInt(Stream);
  FCaretSlopeRun := BigEndianValue.ReadSmallInt(Stream);
  FCaretOffset := BigEndianValue.ReadSmallInt(Stream);
  Stream.Position := Stream.Position + 4*SizeOf(Word); // reserved (ignore!)
  FMetricDataFormat := BigEndianValue.ReadSmallInt(Stream); // TODO : Check for FMetricDataFormat=0?
  FNumOfLongHorMetrics := BigEndianValue.ReadWord(Stream);
end;

procedure TPascalTypeHorizontalHeaderTable.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));
  BigEndianValue.WriteSmallInt(Stream, FAscent);
  BigEndianValue.WriteSmallInt(Stream, FDescent);
  BigEndianValue.WriteSmallInt(Stream, FLineGap);
  BigEndianValue.WriteWord(Stream, FAdvanceWidthMax);
  BigEndianValue.WriteSmallInt(Stream, FMinLeftSideBearing);
  BigEndianValue.WriteSmallInt(Stream, FMinRightSideBearing);
  BigEndianValue.WriteSmallInt(Stream, FXMaxExtent);
  BigEndianValue.WriteSmallInt(Stream, FCaretSlopeRise);
  BigEndianValue.WriteSmallInt(Stream, FCaretSlopeRun);
  BigEndianValue.WriteSmallInt(Stream, FCaretOffset);
  BigEndianValue.WriteWord(Stream, 0); // reserved, set to zero!
  BigEndianValue.WriteWord(Stream, 0);
  BigEndianValue.WriteWord(Stream, 0);
  BigEndianValue.WriteWord(Stream, 0);
  BigEndianValue.WriteSmallInt(Stream, FMetricDataFormat);
  BigEndianValue.WriteWord(Stream, FNumOfLongHorMetrics);
end;

procedure TPascalTypeHorizontalHeaderTable.SetAdvanceWidthMax(const Value: Word);
begin
  if FAdvanceWidthMax <> Value then
  begin
    FAdvanceWidthMax := Value;
    AdvanceWidthMaxChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetAscent(const Value: SmallInt);
begin
  if FAscent <> Value then
  begin
    FAscent := Value;
    AscentChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetCaretOffset(const Value: SmallInt);
begin
  if FCaretOffset <> Value then
  begin
    FCaretOffset := Value;
    CaretOffsetChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetCaretSlopeRise
  (const Value: SmallInt);
begin
  if FCaretSlopeRise <> Value then
  begin
    FCaretSlopeRise := Value;
    CaretSlopeRiseChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetCaretSlopeRun(const Value: SmallInt);
begin
  if FCaretSlopeRun <> Value then
  begin
    FCaretSlopeRun := Value;
    CaretSlopeRunChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetDescent(const Value: SmallInt);
begin
  if FDescent <> Value then
  begin
    FDescent := Value;
    DescentChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetLineGap(const Value: SmallInt);
begin
  if FLineGap <> Value then
  begin
    FLineGap := Value;
    LineGapChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetMetricDataFormat(const Value: SmallInt);
begin
  if FMetricDataFormat <> Value then
  begin
    FMetricDataFormat := Value;
    MetricDataFormatChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetMinLeftSideBearing(const Value: SmallInt);
begin
  if FMinLeftSideBearing <> Value then
  begin
    FMinLeftSideBearing := Value;
    MinLeftSideBearingChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetMinRightSideBearing(const Value: SmallInt);
begin
  if FMinRightSideBearing <> Value then
  begin
    FMinRightSideBearing := Value;
    MinRightSideBearingChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetNumOfLongHorMetrics(const Value: Word);
begin
  if FNumOfLongHorMetrics <> Value then
  begin
    FNumOfLongHorMetrics := Value;
    NumOfLongHorMetricsChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.SetXMaxExtent(const Value: SmallInt);
begin
  if FXMaxExtent <> Value then
  begin
    FXMaxExtent := Value;
    XMaxExtentChanged;
  end;
end;

procedure TPascalTypeHorizontalHeaderTable.AdvanceWidthMaxChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.AscentChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.CaretOffsetChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.CaretSlopeRiseChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.CaretSlopeRunChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.DescentChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.LineGapChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.MetricDataFormatChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.MinLeftSideBearingChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.MinRightSideBearingChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.NumOfLongHorMetricsChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.VersionChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalHeaderTable.XMaxExtentChanged;
begin
  Changed;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

initialization

  PascalTypeTableClasses.RegisterTable(TPascalTypeHorizontalHeaderTable);

end.
