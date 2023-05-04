unit PascalType.Tables.OpenType.Lookup;

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
  Generics.Collections,
  Generics.Defaults,
  Classes,
  PT_Types,
  PT_Classes,
  PT_Tables,
  PascalType.Tables.OpenType.Coverage;


type
//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLookupSubTable
//
//------------------------------------------------------------------------------
// Base class for lookup table sub-formats
//------------------------------------------------------------------------------
  TCustomOpenTypeLookupTable = class;

  TCustomOpenTypeLookupSubTable = class abstract(TCustomPascalTypeTable)
  private
    FSubFormat: Word;
    function GetLookupTable: TCustomOpenTypeLookupTable;
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property SubFormat: Word read FSubFormat;
    property LookupTable: TCustomOpenTypeLookupTable read GetLookupTable;
  end;

  TOpenTypeLookupSubTableClass = class of TCustomOpenTypeLookupSubTable;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLookupTable
//
//------------------------------------------------------------------------------
// Common base class for GSUB/GPOS lookup tables
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#lookup-table
//------------------------------------------------------------------------------
  TCustomOpenTypeLookupTable = class abstract(TCustomPascalTypeTable)
  public
    const
      RIGHT_TO_LEFT             = $0001;
      IGNORE_BASE_GLYPHS 	= $0002;
      IGNORE_LIGATURES 	        = $0004;
      IGNORE_MARKS              = $0008;
      USE_MARK_FILTERING_SET    = $0010;
      MASK_RESERVED             = $00E0;
      MARK_ATTACHMENT_TYPE_MASK = $FF00;
  private
    FLookupType       : Word; // Different enumerations for GSUB and GPOS
    FLookupFlag       : Word; // Lookup qualifiers
    FMarkFilteringSet : Word; // Index (base 0) into GDEF mark glyph sets structure. This field is only present if bit UseMarkFilteringSet of lookup flags is set.
    FSubTableList: TPascalTypeTableInterfaceList<TCustomOpenTypeLookupSubTable>;
  protected
    procedure SetLookupFlag(const Value: Word);
    procedure SetMarkFilteringSet(const Value: Word);
    function GetSubTable(Index: Integer): TCustomOpenTypeLookupSubTable;
    function GetSubTableCount: Integer;
    procedure LookupFlagChanged; virtual;
    procedure MarkFilteringSetChanged; virtual;
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; virtual; abstract;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    // The meaning of LookupType depends on the parent type (GSUB/GPOS)
    property LookupType: Word read FLookupType;
    property LookupFlag: Word read FLookupFlag write SetLookupFlag;
    property MarkFilteringSet: Word read FMarkFilteringSet write SetMarkFilteringSet;

    property SubTableCount: Integer read GetSubTableCount;
    property SubTables[Index: Integer]: TCustomOpenTypeLookupSubTable read GetSubTable;
  end;

  TOpenTypeLookupTableClass = class of TCustomOpenTypeLookupTable;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLookupSubTableWithCoverage
//
//------------------------------------------------------------------------------
// Base class for lookup table sub-formats with a coverage table (all except the
// Extension lookup type sub-table)
//------------------------------------------------------------------------------
  TCustomOpenTypeLookupSubTableWithCoverage = class abstract(TCustomOpenTypeLookupSubTable)
  private
    FCoverageFormat: TCoverageFormat;
    FCoverageTable: TCustomOpenTypeCoverageTable;
  protected
  public
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property CoverageFormat: TCoverageFormat read FCoverageFormat;
    property CoverageTable: TCustomOpenTypeCoverageTable read FCoverageTable;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeLookupListTable
//
//------------------------------------------------------------------------------
// Lookup list table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#lookup-list-table
//------------------------------------------------------------------------------
type
  TOpenTypeLookupListTable = class(TCustomPascalTypeTable)
  private
    FLookupList: TPascalTypeTableInterfaceList<TCustomOpenTypeLookupTable>;
    function GetLookupTableCount: Integer;
    function GetLookupTable(Index: Integer): TCustomOpenTypeLookupTable;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property LookupTableCount: Integer read GetLookupTableCount;
    property LookupTables[Index: Integer]: TCustomOpenTypeLookupTable read GetLookupTable;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings,
  PascalType.Tables.OpenType.Common;

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLookupTable
//
//------------------------------------------------------------------------------
constructor TCustomOpenTypeLookupTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited Create(AParent); // Type check the parent
  FSubTableList := TPascalTypeTableInterfaceList<TCustomOpenTypeLookupSubTable>.Create(Self);
end;

destructor TCustomOpenTypeLookupTable.Destroy;
begin
  FreeAndNil(FSubTableList);
  inherited;
end;

procedure TCustomOpenTypeLookupTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeLookupTable then
  begin
    Assert(FLookupType = TCustomOpenTypeLookupTable(Source).FLookupType);
    FLookupFlag := TCustomOpenTypeLookupTable(Source).FLookupFlag;
    FMarkFilteringSet := TCustomOpenTypeLookupTable(Source).FMarkFilteringSet;
    FSubTableList.Assign(TCustomOpenTypeLookupTable(Source).FSubTableList);
  end;
end;

procedure TCustomOpenTypeLookupTable.LoadFromStream(Stream: TStream);
var
  StartPos       : Int64;
  LookupIndex    : Word;
  SubTableType: Word;
  SubTableOffsets: array of Word;
  SubTable: TCustomOpenTypeLookupSubTable;
  SubTableClass: TOpenTypeLookupSubTableClass;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  FLookupType := ReadSwappedWord(Stream);
  FLookupFlag := ReadSwappedWord(Stream);

  // read subtable count
  SetLength(SubTableOffsets, ReadSwappedWord(Stream));

  // read lookup list index offsets
  for LookupIndex := 0 to High(SubTableOffsets) do
    SubTableOffsets[LookupIndex] := ReadSwappedWord(Stream);

  // eventually read mark filtering set
  if (FLookupFlag and USE_MARK_FILTERING_SET <> 0) then
    FMarkFilteringSet := ReadSwappedWord(Stream);

  for LookupIndex := 0 to High(SubTableOffsets) do
  begin
    Stream.Position := StartPos + SubTableOffsets[LookupIndex];

    // read lookup type
    SubTableType := ReadSwappedWord(Stream);
    SubTableClass := GetSubTableClass(SubTableType);

    if (SubTableClass = nil) then
      continue;

    // add to subtable list
    SubTable := FSubTableList.Add(SubTableClass);

    // load subtable
    Stream.Seek(-SizeOf(Word), soFromCurrent);
    SubTable.LoadFromStream(Stream);
  end;
end;

procedure TCustomOpenTypeLookupTable.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
  SubTableOffsets: array of Word;
  i: integer;
  OffsetTablePos: Int64;
begin
  StartPos := Stream.Position;

  inherited;

  WriteSwappedWord(Stream, FLookupType);
  WriteSwappedWord(Stream, FLookupFlag);

  WriteSwappedWord(Stream, FSubTableList.Count);
  OffsetTablePos := Stream.Position;
  // Reserve space for offset list
  Stream.Seek(FSubTableList.Count * SizeOf(Word), soCurrent);

  SetLength(SubTableOffsets, FSubTableList.Count);
  for i := 0 to FSubTableList.Count-1 do
  begin
    SubTableOffsets[i] := Stream.Position - StartPos;
    FSubTableList[i].SaveToStream(Stream);
  end;

  StartPos := Stream.Position;

  Stream.Position := OffsetTablePos;
  for i := 0 to FSubTableList.Count-1 do
    WriteSwappedWord(Stream, SubTableOffsets[i]);

  Stream.Position := StartPos;
end;

function TCustomOpenTypeLookupTable.GetSubTable(Index: Integer): TCustomOpenTypeLookupSubTable;
begin
  if (Index < 0) or (Index >= FSubTableList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := TCustomOpenTypeLookupSubTable(FSubTableList[Index]);
end;

function TCustomOpenTypeLookupTable.GetSubTableCount: Integer;
begin
  Result := FSubTableList.Count;
end;

procedure TCustomOpenTypeLookupTable.SetLookupFlag(const Value: Word);
begin
  if FLookupFlag <> Value then
  begin
    FLookupFlag := Value;
    LookupFlagChanged;
  end;
end;

procedure TCustomOpenTypeLookupTable.SetMarkFilteringSet(const Value: Word);
begin
  if FMarkFilteringSet <> Value then
  begin
    FMarkFilteringSet := Value;
    MarkFilteringSetChanged;
  end;
end;

procedure TCustomOpenTypeLookupTable.LookupFlagChanged;
begin
  Changed;
end;

procedure TCustomOpenTypeLookupTable.MarkFilteringSetChanged;
begin
  Changed;
end;

//------------------------------------------------------------------------------
//
//              TOpenTypeLookupListTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeLookupListTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited Create(AParent as TCustomOpenTypeCommonTable); // Type check the parent
  FLookupList := TPascalTypeTableInterfaceList<TCustomOpenTypeLookupTable>.Create(Self);
end;

destructor TOpenTypeLookupListTable.Destroy;
begin
  FreeAndNil(FLookupList);
  inherited;
end;

procedure TOpenTypeLookupListTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeLookupListTable then
    FLookupList.Assign(TOpenTypeLookupListTable(Source).FLookupList);
end;

function TOpenTypeLookupListTable.GetLookupTable(Index: Integer): TCustomOpenTypeLookupTable;
begin
  if (Index < 0) or (Index >= FLookupList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FLookupList[Index];
end;

function TOpenTypeLookupListTable.GetLookupTableCount: Integer;
begin
  Result := FLookupList.Count;
end;

procedure TOpenTypeLookupListTable.LoadFromStream(Stream: TStream);
var
  StartPos   : Int64;
  LookupIndex: Integer;
  LookupTableOffsets: array of Word;
  LookupTable: TCustomOpenTypeLookupTable;
  LookupTableClass: TOpenTypeLookupTableClass;
  LookupType: Word;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read lookup list count
  SetLength(LookupTableOffsets, ReadSwappedWord(Stream));

  // read offsets
  for LookupIndex := 0 to High(LookupTableOffsets) do
    LookupTableOffsets[LookupIndex] := ReadSwappedWord(Stream);

  FLookupList.Clear;

  for LookupIndex := 0 to High(LookupTableOffsets) do
  begin
    // set position to start of lookup table
    Stream.Position := StartPos + LookupTableOffsets[LookupIndex];

    LookupType := ReadSwappedWord(Stream);

    // Get the lookup table class from the parent.
    // The mapping from LookupType to lookup table class differs between GSUB and GPOS.
    LookupTableClass := TCustomOpenTypeCommonTable(Parent).GetLookupTableClass(LookupType);
    if (LookupTableClass = nil) then
      continue;

    Stream.Seek(-SizeOf(Word), soFromCurrent);

    LookupTable := FLookupList.Add(LookupTableClass);

    // load from stream
    LookupTable.LoadFromStream(Stream);
  end;
end;

procedure TOpenTypeLookupListTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLookupSubTable
//
//------------------------------------------------------------------------------
constructor TCustomOpenTypeLookupSubTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited Create(AParent as TCustomOpenTypeLookupTable);
  FSubFormat := $FFFF;
end;

function TCustomOpenTypeLookupSubTable.GetLookupTable: TCustomOpenTypeLookupTable;
begin
  Result := TCustomOpenTypeLookupTable(Parent);
end;

procedure TCustomOpenTypeLookupSubTable.LoadFromStream(Stream: TStream);
begin
  inherited;
  FSubFormat := ReadSwappedWord(Stream);
end;

procedure TCustomOpenTypeLookupSubTable.SaveToStream(Stream: TStream);
begin
  inherited;
  WriteSwappedWord(Stream, FSubFormat);
end;

procedure TCustomOpenTypeLookupSubTable.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TCustomOpenTypeLookupSubTable) then
    FSubFormat := TCustomOpenTypeLookupSubTable(Source).SubFormat;
end;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLookupSubTableWithCoverage
//
//------------------------------------------------------------------------------
destructor TCustomOpenTypeLookupSubTableWithCoverage.Destroy;
begin
  FreeAndNil(FCoverageTable);
  inherited;
end;

procedure TCustomOpenTypeLookupSubTableWithCoverage.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TCustomOpenTypeLookupSubTableWithCoverage) then
  begin
    FCoverageFormat := TCustomOpenTypeLookupSubTableWithCoverage(Source).CoverageFormat;
    FCoverageTable.Assign(TCustomOpenTypeLookupSubTableWithCoverage(Source).CoverageTable);
  end;
end;

procedure TCustomOpenTypeLookupSubTableWithCoverage.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  CoveragePos: Int64;
  SavePos: Int64;
begin
  StartPos := Stream.Position;

  inherited;

  // Offset from start of sub-table to coverage table
  CoveragePos := StartPos + ReadSwappedWord(Stream);
  SavePos := Stream.Position;

  // Get the coverage type so we can create the correct object to read the coverage table
  Stream.Position := CoveragePos;
  FCoverageFormat := TCoverageFormat(ReadSwappedWord(Stream));

  FCoverageTable := TCustomOpenTypeCoverageTable.ClassByFormat(FCoverageFormat).Create;

  Stream.Position := CoveragePos;
  FCoverageTable.LoadFromStream(Stream);

  // Sub table header continues after CoveragePos
  Stream.Position := SavePos;
end;

procedure TCustomOpenTypeLookupSubTableWithCoverage.SaveToStream(Stream: TStream);
begin
  inherited;
  WriteSwappedWord(Stream, Ord(FCoverageFormat));
end;

//------------------------------------------------------------------------------

end.