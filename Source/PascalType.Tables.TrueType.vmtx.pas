unit PascalType.Tables.TrueType.vmtx;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'vmtx' table type                                     //
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
//              TPascalTypeVerticalMetricsTable
//
//------------------------------------------------------------------------------
// Vertical metrics, optional table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/vmtx
//------------------------------------------------------------------------------
type
  TVerticalMetric = record
    AdvanceHeight: Word;
    TopSideBearing: SmallInt;
  end;

  TPascalTypeVerticalMetricsTable = class(TCustomPascalTypeNamedTable)
  private
    FVerticalMetrics: array of TVerticalMetric;
  protected
    function GetVerticalMetric(Index: Integer): TVerticalMetric;
    function GetVerticalMetricCount: Integer;
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property VerticalMetric[Index: Integer]: TVerticalMetric read GetVerticalMetric;
    property VerticalMetricCount: Integer read GetVerticalMetricCount;
  end;



//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings,
  PascalType.Tables.TrueType.vhea;

//------------------------------------------------------------------------------
//
//              TPascalTypeVerticalMetricsTable
//
//------------------------------------------------------------------------------
procedure TPascalTypeVerticalMetricsTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeVerticalMetricsTable then
    FVerticalMetrics := TPascalTypeVerticalMetricsTable(Source).FVerticalMetrics;
end;

class function TPascalTypeVerticalMetricsTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'vdmx';
end;

function TPascalTypeVerticalMetricsTable.GetVerticalMetric(Index: Integer): TVerticalMetric;
begin
  if (Index < 0) and (Index > High(FVerticalMetrics)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FVerticalMetrics[Index];
end;

function TPascalTypeVerticalMetricsTable.GetVerticalMetricCount: Integer;
begin
  Result := Length(FVerticalMetrics);
end;

procedure TPascalTypeVerticalMetricsTable.LoadFromStream(Stream: TStream);
var
  MtxIndex      : Integer;
  VerticalHeader: TPascalTypeVerticalHeaderTable;
  MaximumProfile: TPascalTypeMaximumProfileTable;
begin
  inherited;

  // locate vertical metrics header
  VerticalHeader := TPascalTypeVerticalHeaderTable(FontFace.GetTableByTableClass(TPascalTypeVerticalHeaderTable));
  MaximumProfile := TPascalTypeMaximumProfileTable(FontFace.GetTableByTableName('maxp'));
  Assert(MaximumProfile <> nil);

  // check if vertical metrics header is available
  if VerticalHeader = nil then
    raise EPascalTypeError.Create(RCStrNoVerticalHeader);

  // set length of vertical metrics
  SetLength(FVerticalMetrics, MaximumProfile.NumGlyphs);

  for MtxIndex := 0 to VerticalHeader.NumOfLongVerMetrics - 1 do
  begin
    // read advance width
    FVerticalMetrics[MtxIndex].AdvanceHeight := ReadSwappedSmallInt(Stream);

    // read left side bearing
    FVerticalMetrics[MtxIndex].TopSideBearing := ReadSwappedSmallInt(Stream);
  end;

  for MtxIndex := VerticalHeader.NumOfLongVerMetrics to High(FVerticalMetrics) do
  begin
    // read advance width / left side bearing at once
    FVerticalMetrics[MtxIndex].AdvanceHeight := ReadSwappedSmallInt(Stream);
    FVerticalMetrics[MtxIndex].TopSideBearing := FVerticalMetrics[MtxIndex].AdvanceHeight;
  end;
end;

procedure TPascalTypeVerticalMetricsTable.SaveToStream(Stream: TStream);
var
  MtxIndex      : Integer;
  VerticalHeader: TPascalTypeVerticalHeaderTable;
begin
  inherited;

  // locate vertical metrics header
  VerticalHeader := TPascalTypeVerticalHeaderTable(FontFace.GetTableByTableClass(TPascalTypeVerticalHeaderTable));

  // check if vertical metrics header is available
  if VerticalHeader = nil then
    raise EPascalTypeError.Create(RCStrNoVerticalHeader);

  for MtxIndex := 0 to VerticalHeader.NumOfLongVerMetrics - 1 do
  begin
    // write advance width
    WriteSwappedSmallInt(Stream, FVerticalMetrics[MtxIndex].AdvanceHeight);

    // write left side bearing
    WriteSwappedSmallInt(Stream, FVerticalMetrics[MtxIndex].TopSideBearing);
  end;

  for MtxIndex := VerticalHeader.NumOfLongVerMetrics to High(FVerticalMetrics) do
    // write advance width / left side bearing at once
    WriteSwappedSmallInt(Stream, FVerticalMetrics[MtxIndex].AdvanceHeight);
end;



initialization

  RegisterPascalTypeTable(TPascalTypeVerticalMetricsTable);

end.
