unit PT_TablesBitmap;

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
  Classes, SysUtils, PT_Types, PT_Classes, PT_Tables, PT_TablesShared;

type
  TCustomPascalTypeEmbeddedBitmapTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: TFixedPoint; // Initially defined as 0x00020000
    procedure SetVersion(const Value: TFixedPoint);
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
  end;


  // table 'EBDT'

  TPascalTypeEmbeddedBitmapDataTable = class(TCustomPascalTypeEmbeddedBitmapTable)
  private
  protected
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  // table 'EBLC'

  TPascalTypeEmbeddedBitmapLocationTable = class(TCustomPascalTypeEmbeddedBitmapTable)
  private
    FBitmapSizeList: TPascalTypeTableList<TPascalTypeBitmapSizeTable>;
    function GetBitmapSizeTable(Index: Integer): TPascalTypeBitmapSizeTable;
    function GetBitmapSizeTableCount: Integer;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property BitmapSizeTableCount: Integer read GetBitmapSizeTableCount;
    property BitmapSizeTable[Index: Integer]: TPascalTypeBitmapSizeTable read GetBitmapSizeTable;
  end;


  // table 'EBSC'

  TPascalTypeBitmapScaleTable = class(TCustomPascalTypeTable)
  private
    FPpemX          : Byte; // target horizontal pixels per Em
    FPpemY          : Byte; // target vertical pixels per Em
    FSubstitutePpemX: Byte; // use bitmaps of this size
    FSubstitutePpemY: Byte; // use bitmaps of this size

    FHorizontalMetrics: TPascalTypeBitmapLineMetrics;
    FVerticalMetrics  : TPascalTypeBitmapLineMetrics;
    procedure SetPpemX(const Value: Byte);
    procedure SetPpemY(const Value: Byte);
    procedure SetSubstitutePpemX(const Value: Byte);
    procedure SetSubstitutePpemY(const Value: Byte);
  protected
    procedure PpemXChanged; virtual;
    procedure PpemYChanged; virtual;
    procedure SubstitutePpemXChanged; virtual;
    procedure SubstitutePpemYChanged; virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property PpemX: Byte read FPpemX write SetPpemX;
    property PpemY: Byte read FPpemY write SetPpemY;
    property SubstitutePpemX: Byte read FSubstitutePpemX
      write SetSubstitutePpemX;
    property SubstitutePpemY: Byte read FSubstitutePpemY
      write SetSubstitutePpemY;

    property HorizontalMetrics: TPascalTypeBitmapLineMetrics
      read FHorizontalMetrics;
    property VerticalMetrics: TPascalTypeBitmapLineMetrics
      read FVerticalMetrics;
  end;

  TPascalTypeEmbeddedBitmapScalingTable = class(TCustomPascalTypeEmbeddedBitmapTable)
  private
    FBitmapScaleList: TPascalTypeTableList<TPascalTypeBitmapScaleTable>;
    function GetBitmapScaleTable(Index: Integer): TPascalTypeBitmapScaleTable;
    function GetBitmapScaleTableCount: Integer;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property BitmapScaleTableCount: Integer read GetBitmapScaleTableCount;
    property BitmapScaleTable[Index: Integer]: TPascalTypeBitmapScaleTable
      read GetBitmapScaleTable;
  end;

implementation

uses
  PT_ResourceStrings;

{ TCustomPascalTypeEmbeddedBitmapTable }

constructor TCustomPascalTypeEmbeddedBitmapTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited;
  FVersion.Value := 2;
end;

procedure TCustomPascalTypeEmbeddedBitmapTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomPascalTypeEmbeddedBitmapTable then
    FVersion := TCustomPascalTypeEmbeddedBitmapTable(Source).FVersion;
end;

procedure TCustomPascalTypeEmbeddedBitmapTable.LoadFromStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion.Fixed := ReadSwappedCardinal(Stream);

    if FVersion.Value < 2 then
      raise EPascalTypeError.Create(RCStrUnknownVersion);
  end;
end;

procedure TCustomPascalTypeEmbeddedBitmapTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write version
  WriteSwappedCardinal(Stream, Cardinal(FVersion));
end;

procedure TCustomPascalTypeEmbeddedBitmapTable.SetVersion
  (const Value: TFixedPoint);
begin
  if (FVersion.Value <> Value.Value) or (FVersion.Fract <> Value.Fract) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TCustomPascalTypeEmbeddedBitmapTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeEmbeddedBitmapDataTable }

constructor TPascalTypeEmbeddedBitmapDataTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited;

end;

destructor TPascalTypeEmbeddedBitmapDataTable.Destroy;
begin

  inherited;
end;

procedure TPascalTypeEmbeddedBitmapDataTable.Assign(Source: TPersistent);
begin
  inherited;
end;

class function TPascalTypeEmbeddedBitmapDataTable.GetTableType: TTableType;
begin
  Result := 'EBDT';
end;

procedure TPascalTypeEmbeddedBitmapDataTable.LoadFromStream(Stream: TStream);
// var Value32 : Cardinal;
begin
  inherited;

  with Stream do
  begin
  end;
end;

procedure TPascalTypeEmbeddedBitmapDataTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeEmbeddedBitmapLocationTable }

constructor TPascalTypeEmbeddedBitmapLocationTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  FBitmapSizeList := TPascalTypeTableList<TPascalTypeBitmapSizeTable>.Create;
  inherited;
end;

destructor TPascalTypeEmbeddedBitmapLocationTable.Destroy;
begin
  FreeAndNil(FBitmapSizeList);
  inherited;
end;

procedure TPascalTypeEmbeddedBitmapLocationTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeEmbeddedBitmapLocationTable then
    FBitmapSizeList.Assign(TPascalTypeEmbeddedBitmapLocationTable(Source).FBitmapSizeList);
end;

function TPascalTypeEmbeddedBitmapLocationTable.GetBitmapSizeTable(Index: Integer): TPascalTypeBitmapSizeTable;
begin
  if (Index < 0) or (Index >= FBitmapSizeList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FBitmapSizeList[Index];
end;

function TPascalTypeEmbeddedBitmapLocationTable.GetBitmapSizeTableCount: Integer;
begin
  Result := FBitmapSizeList.Count;
end;

class function TPascalTypeEmbeddedBitmapLocationTable.GetTableType: TTableType;
begin
  Result := 'EBLC';
end;

procedure TPascalTypeEmbeddedBitmapLocationTable.LoadFromStream(Stream: TStream);
var
  BitmapSizeCount: Cardinal;
  BitmapSizeIndex: Integer;
  BitmapSizeTable: TPascalTypeBitmapSizeTable;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read number of BitmapSize tables
    BitmapSizeCount := ReadSwappedCardinal(Stream);

    // read bitmap size tables
    for BitmapSizeIndex := 0 to BitmapSizeCount - 1 do
    begin
      // create bitmap size table
      // add bitmap size table
      BitmapSizeTable := FBitmapSizeList.Add;

      // load bitmap size table
      BitmapSizeTable.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeEmbeddedBitmapLocationTable.SaveToStream(Stream: TStream);
var
  BitmapSizeIndex: Integer;
begin
  inherited;

  // write number of BitmapSize tables
  WriteSwappedCardinal(Stream, FBitmapSizeList.Count);

  // write bitmap size tables
  for BitmapSizeIndex := 0 to FBitmapSizeList.Count - 1 do
    // save bitmap size table to stream
    FBitmapSizeList[BitmapSizeIndex].SaveToStream(Stream);
end;


{ TPascalTypeBitmapScaleTable }

constructor TPascalTypeBitmapScaleTable.Create;
begin
  inherited;
  FHorizontalMetrics := TPascalTypeBitmapLineMetrics.Create;
  FVerticalMetrics := TPascalTypeBitmapLineMetrics.Create;
end;

destructor TPascalTypeBitmapScaleTable.Destroy;
begin
  FreeAndNil(FHorizontalMetrics);
  FreeAndNil(FVerticalMetrics);
  inherited;
end;

procedure TPascalTypeBitmapScaleTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeBitmapScaleTable then
  begin
    FPpemX := TPascalTypeBitmapScaleTable(Source).FPpemX;
    FPpemY := TPascalTypeBitmapScaleTable(Source).FPpemY;
    FSubstitutePpemX := TPascalTypeBitmapScaleTable(Source).FSubstitutePpemX;
    FSubstitutePpemY := TPascalTypeBitmapScaleTable(Source).FSubstitutePpemY;

    FHorizontalMetrics.Assign(TPascalTypeBitmapScaleTable(Source).FHorizontalMetrics);
    FVerticalMetrics.Assign(TPascalTypeBitmapScaleTable(Source).FVerticalMetrics);
  end;
end;

procedure TPascalTypeBitmapScaleTable.LoadFromStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // load horizontal metrics from stream
    FHorizontalMetrics.LoadFromStream(Stream);

    // load vertical metrics from stream
    FVerticalMetrics.LoadFromStream(Stream);

    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read horizontal pixels per Em
    Read(FPpemX, 1);

    // read vertical pixels per Em
    Read(FPpemY, 1);

    // read horizontal substitute ppem
    Read(FSubstitutePpemX, 1);

    // read vertical substitute ppem
    Read(FSubstitutePpemY, 1);
  end;
end;

procedure TPascalTypeBitmapScaleTable.SaveToStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // save horizontal metrics to stream
    FHorizontalMetrics.SaveToStream(Stream);

    // save vertical metrics to stream
    FVerticalMetrics.SaveToStream(Stream);

    // write horizontal pixels per Em
    Write(FPpemX, 1);

    // write vertical pixels per Em
    Write(FPpemY, 1);

    // write horizontal substitute ppem
    Write(FSubstitutePpemX, 1);

    // write vertical substitute ppem
    Write(FSubstitutePpemY, 1);
  end;
end;

procedure TPascalTypeBitmapScaleTable.SetPpemX(const Value: Byte);
begin
  if FPpemX <> Value then
  begin
    FPpemX := Value;
    PpemXChanged;
  end;
end;

procedure TPascalTypeBitmapScaleTable.SetPpemY(const Value: Byte);
begin
  if FPpemY <> Value then
  begin
    FPpemY := Value;
    PpemYChanged;
  end;
end;

procedure TPascalTypeBitmapScaleTable.SetSubstitutePpemX(const Value: Byte);
begin
  if FSubstitutePpemX <> Value then
  begin
    FSubstitutePpemX := Value;
    SubstitutePpemXChanged;
  end;
end;

procedure TPascalTypeBitmapScaleTable.SetSubstitutePpemY(const Value: Byte);
begin
  if FSubstitutePpemY <> Value then
  begin
    FSubstitutePpemY := Value;
    SubstitutePpemYChanged;
  end;
end;

procedure TPascalTypeBitmapScaleTable.PpemXChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapScaleTable.PpemYChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapScaleTable.SubstitutePpemXChanged;
begin
  Changed;
end;

procedure TPascalTypeBitmapScaleTable.SubstitutePpemYChanged;
begin
  Changed;
end;


{ TPascalTypeEmbeddedBitmapScalingTable }

constructor TPascalTypeEmbeddedBitmapScalingTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  FBitmapScaleList := TPascalTypeTableList<TPascalTypeBitmapScaleTable>.Create;
  inherited;
end;

destructor TPascalTypeEmbeddedBitmapScalingTable.Destroy;
begin
  FreeAndNil(FBitmapScaleList);
  inherited;
end;

procedure TPascalTypeEmbeddedBitmapScalingTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeEmbeddedBitmapScalingTable then
    FBitmapScaleList.Assign(TPascalTypeEmbeddedBitmapScalingTable(Source).FBitmapScaleList);
end;

function TPascalTypeEmbeddedBitmapScalingTable.GetBitmapScaleTable(Index: Integer): TPascalTypeBitmapScaleTable;
begin
  if (Index < 0) and (Index >= FBitmapScaleList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FBitmapScaleList[Index];
end;

function TPascalTypeEmbeddedBitmapScalingTable.GetBitmapScaleTableCount: Integer;
begin
  Result := FBitmapScaleList.Count;
end;

class function TPascalTypeEmbeddedBitmapScalingTable.GetTableType: TTableType;
begin
  Result := 'EBLC';
end;

procedure TPascalTypeEmbeddedBitmapScalingTable.LoadFromStream(Stream: TStream);
var
  BitmapScaleCount: Cardinal;
  BitmapScaleIndex: Integer;
  BitmapScaleTable: TPascalTypeBitmapScaleTable;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read number of bitmap scale tables
    BitmapScaleCount := ReadSwappedCardinal(Stream);

    // read bitmap size tables
    for BitmapScaleIndex := 0 to BitmapScaleCount - 1 do
    begin
      // create bitmap size table
      // add bitmap size table
      BitmapScaleTable := FBitmapScaleList.Add;

      // load bitmap size table
      BitmapScaleTable.LoadFromStream(Stream);

    end;
  end;
end;

procedure TPascalTypeEmbeddedBitmapScalingTable.SaveToStream(Stream: TStream);
var
  BitmapScaleIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // write number of BitmapScale tables
    WriteSwappedCardinal(Stream, FBitmapScaleList.Count);

    // write bitmap size tables
    for BitmapScaleIndex := 0 to FBitmapScaleList.Count - 1 do
    begin
      // save bitmap size table to stream
      TPascalTypeBitmapScaleTable(FBitmapScaleList).SaveToStream(Stream);
    end;
  end;
end;

initialization

RegisterPascalTypeTables([TPascalTypeEmbeddedBitmapDataTable,
  TPascalTypeEmbeddedBitmapLocationTable,
  TPascalTypeEmbeddedBitmapScalingTable]);

end.
