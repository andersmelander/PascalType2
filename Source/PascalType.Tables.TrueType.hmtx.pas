unit PascalType.Tables.TrueType.hmtx;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'hmtx' table type                                     //
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
  PT_Tables;

//------------------------------------------------------------------------------
//
//              TPascalTypeHorizontalMetricsTable
//
//------------------------------------------------------------------------------
// Horizontal metrics, required table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/hmtx
//------------------------------------------------------------------------------
type
  THorizontalMetric = record
    AdvanceWidth: Word;
    Bearing: SmallInt;
  end;

  TPascalTypeHorizontalMetricsTable = class(TCustomPascalTypeNamedTable)
  private
    FHorizontalMetrics: array of THorizontalMetric;
  protected
    function GetHorizontalMetric(Index: Integer): THorizontalMetric;
    function GetHorizontalMetricCount: Integer;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property HorizontalMetric[Index: Integer]: THorizontalMetric read GetHorizontalMetric;
    property HorizontalMetricCount: Integer read GetHorizontalMetricCount;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings,
  PascalType.Tables.TrueType.hhea;

//------------------------------------------------------------------------------
//
//              TPascalTypeHorizontalMetricsTable
//
//------------------------------------------------------------------------------
constructor TPascalTypeHorizontalMetricsTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  SetLength(FHorizontalMetrics, 1);
  FHorizontalMetrics[0] := Default(THorizontalMetric);
end;

procedure TPascalTypeHorizontalMetricsTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeHorizontalMetricsTable then
    FHorizontalMetrics := TPascalTypeHorizontalMetricsTable(Source).FHorizontalMetrics;
end;

class function TPascalTypeHorizontalMetricsTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'hmtx';
end;

procedure TPascalTypeHorizontalMetricsTable.LoadFromStream(Stream: TStream);
var
  HorHead  : TPascalTypeHorizontalHeaderTable;
  MaxProf  : TPascalTypeMaximumProfileTable;
  LastWidth: Word;
  MtxIndex : Integer;
const
  CMaxProfTableType: TTableType = (AsAnsiChar: 'maxp');
begin
  inherited;

  HorHead := TPascalTypeHorizontalHeaderTable(Storage.GetTableByTableName('hhea'));
  Assert(HorHead <> nil);
  MaxProf := TPascalTypeMaximumProfileTable(Storage.GetTableByTableType(CMaxProfTableType));
  Assert(MaxProf <> nil);

  // check if vertical metrics header is available
  if HorHead = nil then
    raise EPascalTypeError.Create(RCStrNoHorizontalHeader);

  // set length of horizontal metrics
  SetLength(FHorizontalMetrics, MaxProf.NumGlyphs);

  // set last width to maximum advance width (only used when the width is not
  // stored as pairs as for monospaced fonts with glyphs accidentially deleted)
  LastWidth := HorHead.AdvanceWidthMax;

  for MtxIndex := 0 to HorHead.NumOfLongHorMetrics - 1 do
  begin
    // read advance width
    FHorizontalMetrics[MtxIndex].AdvanceWidth := ReadSwappedWord(Stream);

    // read left side bearing
    FHorizontalMetrics[MtxIndex].Bearing := ReadSwappedSmallInt(Stream);

    // remember last width
    LastWidth := FHorizontalMetrics[MtxIndex].AdvanceWidth;
  end;

  for MtxIndex := HorHead.NumOfLongHorMetrics to High(FHorizontalMetrics) do
  begin
    // read left side bearing
    FHorizontalMetrics[MtxIndex].Bearing := ReadSwappedSmallInt(Stream);

    // use advance width from last entry (useful for monospaced fonts)
    FHorizontalMetrics[MtxIndex].AdvanceWidth := LastWidth;
  end;
end;

procedure TPascalTypeHorizontalMetricsTable.SaveToStream(Stream: TStream);
var
  MtxIndex: Integer;
  HorHead : TPascalTypeHorizontalHeaderTable;
begin
  inherited;

  // locate horizontal header
  HorHead := TPascalTypeHorizontalHeaderTable(Storage.GetTableByTableName('hhea'));

  // check if vertical metrics header is available
  if HorHead = nil then
    raise EPascalTypeError.Create(RCStrNoHorizontalHeader);

  for MtxIndex := 0 to HorHead.NumOfLongHorMetrics - 1 do
  begin
    // write advance width
    WriteSwappedWord(Stream, FHorizontalMetrics[MtxIndex].AdvanceWidth);

    // write left side bearing
    WriteSwappedSmallInt(Stream, FHorizontalMetrics[MtxIndex].Bearing);
  end;

  for MtxIndex := HorHead.NumOfLongHorMetrics to High(FHorizontalMetrics) do
    // write advance width / left side bearing at once
    WriteSwappedWord(Stream, FHorizontalMetrics[MtxIndex].AdvanceWidth);
end;

function TPascalTypeHorizontalMetricsTable.GetHorizontalMetric(Index: Integer): THorizontalMetric;
begin
  if (Index < 0) or (Index > High(FHorizontalMetrics)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FHorizontalMetrics[Index];
end;

function TPascalTypeHorizontalMetricsTable.GetHorizontalMetricCount: Integer;
begin
  Result := Length(FHorizontalMetrics);
end;


initialization

  RegisterPascalTypeTable(TPascalTypeHorizontalMetricsTable);

end.
