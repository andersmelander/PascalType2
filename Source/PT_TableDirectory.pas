unit PT_TableDirectory;

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
  Classes, SysUtils, PT_Types, PT_Classes;

type
  // TrueType Table Directory Entry type
  TDirectoryTableEntry = packed record
    TableType: TTableType; // Table type
    CheckSum: Cardinal;    // Table checksum
    Offset: Cardinal;      // Table file offset
    Length: Cardinal;      // Table length
  end;

  TPascalTypeDirectoryTableEntry = class(TCustomPascalTypeTable)
  private
    FDirectoryTableEntry : TDirectoryTableEntry;
    procedure SetCheckSum(const Value: Cardinal);
    procedure SetLength(const Value: Cardinal);
    procedure SetOffset(const Value: Cardinal);
    procedure SetTableType(const Value: TTableType);
  protected
    procedure ChecksumChanged; virtual;
    procedure LengthChanged; virtual;
    procedure OffsetChanged; virtual;
    procedure TableTypeChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property DirectoryTableEntry: TDirectoryTableEntry read FDirectoryTableEntry;

    property TableType: TTableType read FDirectoryTableEntry.TableType write SetTableType;
    property CheckSum: Cardinal read FDirectoryTableEntry.CheckSum write SetCheckSum;
    property Offset: Cardinal read FDirectoryTableEntry.Offset write SetOffset;
    property Length: Cardinal read FDirectoryTableEntry.Length write SetLength;
  end;

  // TrueType Table Directory type
  TPascalTypeDirectoryTable = class(TCustomPascalTypeTable)
  private type
    TPascalTypeDirectoryTableList = TPascalTypeTableList<TPascalTypeDirectoryTableEntry>;
  private
    FVersion: Cardinal;  // A tag to indicate the OFA scaler (should be $10000)

    // required tables
    FHeaderTable: TPascalTypeDirectoryTableEntry;
    FMaxProfileDataEntry: TPascalTypeDirectoryTableEntry;
    FHorHeaderDataEntry: TPascalTypeDirectoryTableEntry;
    FHorMetricsDataEntry: TPascalTypeDirectoryTableEntry;
    FCharMapDataEntry: TPascalTypeDirectoryTableEntry;
    FNameDataEntry: TPascalTypeDirectoryTableEntry;
    FPostscriptDataEntry: TPascalTypeDirectoryTableEntry;
    FLocationDataEntry: TPascalTypeDirectoryTableEntry;
    FGlyphDataEntry: TPascalTypeDirectoryTableEntry;
    FOS2TableEntry: TPascalTypeDirectoryTableEntry;

    // table list
    FTableList: TPascalTypeDirectoryTableList;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    procedure ClearAndBuildRequiredEntries;
    function AddTableEntry(TableType: TTableType): TPascalTypeDirectoryTableEntry;

    property Version: Cardinal read FVersion;
    property TableList: TPascalTypeDirectoryTableList read FTableList;
    property HeaderTable: TPascalTypeDirectoryTableEntry read FHeaderTable;
    property MaximumProfileDataEntry: TPascalTypeDirectoryTableEntry read FMaxProfileDataEntry;
    property HorizontalHeaderDataEntry: TPascalTypeDirectoryTableEntry read FHorHeaderDataEntry;
    property HorizontalMetricsDataEntry: TPascalTypeDirectoryTableEntry read FHorMetricsDataEntry;
    property CharacterMapDataEntry: TPascalTypeDirectoryTableEntry read FCharMapDataEntry;
    property NameDataEntry: TPascalTypeDirectoryTableEntry read FNameDataEntry;
    property PostscriptDataEntry: TPascalTypeDirectoryTableEntry read FPostscriptDataEntry;
    property LocationDataEntry: TPascalTypeDirectoryTableEntry read FLocationDataEntry;
    property GlyphDataEntry: TPascalTypeDirectoryTableEntry read FGlyphDataEntry;
    property OS2TableEntry: TPascalTypeDirectoryTableEntry read FOS2TableEntry;
  end;

implementation

uses
  Math,
  Generics.Defaults,
  PT_Math,
  PT_ResourceStrings;

{ TPascalTypeDirectoryTableEntry }

procedure TPascalTypeDirectoryTableEntry.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeDirectoryTableEntry then
    FDirectoryTableEntry := TPascalTypeDirectoryTableEntry(Source).FDirectoryTableEntry;
end;

procedure TPascalTypeDirectoryTableEntry.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value : Cardinal;
begin
  with Stream, FDirectoryTableEntry do
  begin
    if Position + SizeOf(TDirectoryTableEntry) > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read table type
    Read(TableType, SizeOf(TTableType));

    // read checksum
    Read(Value, SizeOf(LongInt));
    CheckSum := Swap32(Value);

    // read offset
    Read(Value, SizeOf(LongInt));
    Offset := Swap32(Value);

    // read length
    Read(Value, SizeOf(LongInt));
    Length := Swap32(Value);
  end;
end;

procedure TPascalTypeDirectoryTableEntry.SaveToStream(Stream: TStream);
var
  Value : Cardinal;
begin
  with Stream do
  begin
    if Position + SizeOf(TDirectoryTableEntry) > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    with FDirectoryTableEntry do
    begin
      // read table type
      Write(TableType, SizeOf(TTableType));

      // write checksum
      Value := Swap32(CheckSum);
      Write(Value, SizeOf(LongInt));

      // write offset
      Value := Swap32(Offset);
      Write(Value, SizeOf(LongInt));

      // write length
      Value := Swap32(Length);
      Write(Value, SizeOf(LongInt));
    end;
  end;
end;

procedure TPascalTypeDirectoryTableEntry.SetCheckSum(const Value: Cardinal);
begin
  if FDirectoryTableEntry.CheckSum <> Value then
  begin
    FDirectoryTableEntry.CheckSum := Value;
    ChecksumChanged;
  end;
end;

procedure TPascalTypeDirectoryTableEntry.SetLength(const Value: Cardinal);
begin
  if FDirectoryTableEntry.Length <> Value then
  begin
    FDirectoryTableEntry.Length := Value;
    LengthChanged;
  end;
end;

procedure TPascalTypeDirectoryTableEntry.SetOffset(const Value: Cardinal);
begin
  if FDirectoryTableEntry.Offset <> Value then
  begin
    FDirectoryTableEntry.Offset := Value;
    OffsetChanged;
  end;
end;

procedure TPascalTypeDirectoryTableEntry.SetTableType(const Value: TTableType);
begin
  if FDirectoryTableEntry.TableType.AsCardinal <> Value.AsCardinal then
  begin
    FDirectoryTableEntry.TableType := Value;
    TableTypeChanged;
  end;
end;

procedure TPascalTypeDirectoryTableEntry.ChecksumChanged;
begin
  Changed;
end;

procedure TPascalTypeDirectoryTableEntry.LengthChanged;
begin
  Changed;
end;

procedure TPascalTypeDirectoryTableEntry.OffsetChanged;
begin
 Changed;
end;

procedure TPascalTypeDirectoryTableEntry.TableTypeChanged;
begin
  Changed;
end;


{ TPascalTypeDirectoryTable }

constructor TPascalTypeDirectoryTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion := $10000;
  FTableList := TPascalTypeDirectoryTableList.Create(TComparer<TPascalTypeDirectoryTableEntry>.Construct(
    function(const Item1, Item2: TPascalTypeDirectoryTableEntry): Integer
    begin
      Result := integer(Item2.Offset) - integer(Item1.Offset);
    end));
end;

destructor TPascalTypeDirectoryTable.Destroy;
begin
  FreeAndNil(FHeaderTable);
  FreeAndNil(FMaxProfileDataEntry);
  FreeAndNil(FHorHeaderDataEntry);
  FreeAndNil(FHorMetricsDataEntry);
  FreeAndNil(FCharMapDataEntry);
  FreeAndNil(FNameDataEntry);
  FreeAndNil(FPostscriptDataEntry);
  FreeAndNil(FLocationDataEntry);
  FreeAndNil(FGlyphDataEntry);
  FreeAndNil(FOS2TableEntry);

  FreeAndNil(FTableList);

  inherited;
end;

function TPascalTypeDirectoryTable.AddTableEntry(TableType: TTableType): TPascalTypeDirectoryTableEntry;
begin
  Result := FTableList.Add;
  Result.TableType := TableType;
end;

procedure TPascalTypeDirectoryTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is Self.ClassType then
  begin
    FVersion := TPascalTypeDirectoryTable(Source).FVersion;
    FTableList.Assign(TPascalTypeDirectoryTable(Source).FTableList);
  end;
end;

procedure TPascalTypeDirectoryTable.ClearAndBuildRequiredEntries;
var
  TableType : TTableType;
begin
  FVersion := $10000;

  // clear fixed table entries
  FreeAndNil(FHeaderTable);
  FreeAndNil(FMaxProfileDataEntry);
  FreeAndNil(FHorHeaderDataEntry );
  FreeAndNil(FHorMetricsDataEntry);
  FreeAndNil(FCharMapDataEntry);
  FreeAndNil(FNameDataEntry);
  FreeAndNil(FPostscriptDataEntry);
  FreeAndNil(FLocationDataEntry);
  FreeAndNil(FGlyphDataEntry);
  FreeAndNil(FOS2TableEntry);

  // clear table list
  FTableList.Clear;

  // create head table entry
  FHeaderTable := TPascalTypeDirectoryTableEntry.Create;
  TableType.AsAnsiChar := 'head';
  FHeaderTable.TableType := TableType;

  // create maxp table entry
  FMaxProfileDataEntry := TPascalTypeDirectoryTableEntry.Create;
  TableType.AsAnsiChar := 'maxp';
  FMaxProfileDataEntry.TableType := TableType;

  // create hhea table entry
  FHorHeaderDataEntry := TPascalTypeDirectoryTableEntry.Create;
  TableType.AsAnsiChar := 'hhea';
  FHorHeaderDataEntry.TableType := TableType;

  // create hmtx table entry
  FHorMetricsDataEntry := TPascalTypeDirectoryTableEntry.Create;
  TableType.AsAnsiChar := 'hmtx';
  FHorMetricsDataEntry.TableType := TableType;

  // create cmap table entry
  FCharMapDataEntry := TPascalTypeDirectoryTableEntry.Create;
  TableType.AsAnsiChar := 'cmap';
  FCharMapDataEntry.TableType := TableType;

  // create name table entry
  FNameDataEntry := TPascalTypeDirectoryTableEntry.Create;
  TableType.AsAnsiChar := 'name';
  FNameDataEntry.TableType := TableType;

  // create post table entry
  FPostscriptDataEntry := TPascalTypeDirectoryTableEntry.Create;
  TableType.AsAnsiChar := 'post';
  FPostscriptDataEntry.TableType := TableType;
end;

procedure TPascalTypeDirectoryTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  TableIndex    : Integer;
  TableEntry    : TPascalTypeDirectoryTableEntry;
  NumTables     : Word; // number of tables
begin
  inherited;

  // make sure at least the offset subtable is contained in the file
  if Size < 10 then
    raise EPascalTypeError.Create(RCStrWrongFilesize);

  // read version
  FVersion := BigEndianValueReader.ReadCardinal(Stream);

  // check for known scaler types (OSX and Windows)
  case Version of
    $00010000:;
    $4F54544F:;
    $74727565:;
  else
    raise EPascalTypeError.CreateFmt(RCStrUnknownVersion, [Version]);
  end;

  // read number of tables
  NumTables := BigEndianValueReader.ReadWord(Stream);

  Stream.Seek(6, soFromCurrent);

  // read table entries from stream
  for TableIndex := 0 to NumTables - 1 do
  begin
    TableEntry := TPascalTypeDirectoryTableEntry.Create;
    TableEntry.LoadFromStream(Stream);

    // add table entry as required table or add to directory table list
    if CompareTableType(TableEntry.TableType, 'head') then
      FHeaderTable := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'maxp') then
      FMaxProfileDataEntry := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'hhea') then
      FHorHeaderDataEntry := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'hmtx') then
      FHorMetricsDataEntry := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'cmap') then
      FCharMapDataEntry := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'name') then
      FNameDataEntry := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'post') then
      FPostscriptDataEntry := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'loca') then
      FLocationDataEntry := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'glyf') then
      FGlyphDataEntry := TableEntry
    else
    if CompareTableType(TableEntry.TableType, 'OS/2') then
      FOS2TableEntry := TableEntry
    else
      FTableList.Add(TableEntry);
  end;

  // check for required tables
  case Version of
    $00010000:
      if (OS2TableEntry = nil) then
        raise EPascalTypeError.Create(RCStrNoOS2Table);
    $74727565:
      begin
        if (FLocationDataEntry = nil) then
          raise EPascalTypeError.Create(RCStrNoIndexToLocationTable);
        if (FGlyphDataEntry = nil) then
          raise EPascalTypeError.Create(RCStrNoGlyphDataTable);
      end;
  end;
end;

procedure TPascalTypeDirectoryTable.SaveToStream(Stream: TStream);
begin
  inherited;
end;

end.
