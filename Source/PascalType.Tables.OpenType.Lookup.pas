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
  System.Classes,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Coverage;

type
  TCustomOpenTypeLookupTable = class;
  TOpenTypeLookupListTable = class;

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLookupSubTable
//
//------------------------------------------------------------------------------
// Base class for lookup table sub-formats
//------------------------------------------------------------------------------
  TCustomOpenTypeLookupSubTable = class abstract(TCustomPascalTypeTable)
  public type
    TSequenceLookupRecord = record
      SequenceIndex: Word;
      LookupListIndex: Word;
    end;
    TSequenceLookupRecords = TArray<TSequenceLookupRecord>;
  private
    FSubFormat: Word;
    function GetLookupTable: TCustomOpenTypeLookupTable;
  protected
    function ApplyLookupRecords(const AGlyphIterator: TPascalTypeGlyphGlyphIterator; const LookupRecords: TSequenceLookupRecords): boolean;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; virtual; abstract;

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
    FLookupFlags      : Word; // Lookup qualifiers
    FMarkFilteringSet : Word; // Index (base 0) into GDEF mark glyph sets structure. This field is only present if bit UseMarkFilteringSet of lookup flags is set.
    FSubTableList: TPascalTypeTableInterfaceList<TCustomOpenTypeLookupSubTable>;
  protected
    procedure SetLookupFlags(const Value: Word);
    procedure SetMarkFilteringSet(const Value: Word);
    function GetSubTable(Index: Integer): TCustomOpenTypeLookupSubTable;
    function GetSubTableCount: Integer;
    function GetLookupList: TOpenTypeLookupListTable;
    procedure LookupFlagsChanged; virtual;
    procedure MarkFilteringSetChanged; virtual;
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; virtual; abstract;
    function GetUseReverseDirection: boolean; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function GetEnumerator: TEnumerator<TCustomOpenTypeLookupSubTable>;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; virtual;

    // The meaning of LookupType depends on the parent type (GSUB/GPOS)
    property LookupType: Word read FLookupType;
    property LookupFlags: Word read FLookupFlags write SetLookupFlags;
    property MarkFilteringSet: Word read FMarkFilteringSet write SetMarkFilteringSet;
    // See: TCustomPascalTypeOpenTypeProcessor.ApplyLookups
    property UseReverseDirection: boolean read GetUseReverseDirection;

    property SubTableCount: Integer read GetSubTableCount;
    property SubTables[Index: Integer]: TCustomOpenTypeLookupSubTable read GetSubTable; default;

    property LookupList: TOpenTypeLookupListTable read GetLookupList;
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
    FCoverageTable: TCustomOpenTypeCoverageTable;
  protected
  public
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

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
  TOpenTypeLookupListTable = class(TCustomPascalTypeTable)
  private
    FLookupList: TPascalTypeTableInterfaceList<TCustomOpenTypeLookupTable>;
    function GetLookupTableCount: Integer;
    function GetLookupTable(Index: Integer): TCustomOpenTypeLookupTable;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property LookupTableCount: Integer read GetLookupTableCount;
    property LookupTables[Index: Integer]: TCustomOpenTypeLookupTable read GetLookupTable; default;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeLookupTableGeneric
//
//------------------------------------------------------------------------------
// Generic placeholder for those lookup types that have no concrete implementation.
//------------------------------------------------------------------------------
type
  TOpenTypeLookupTableGeneric = class(TCustomOpenTypeLookupTable)
  private type
    TOpenTypeLookupSubTableGeneric = class(TCustomOpenTypeLookupSubTable)
    public
      function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;
    end;
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  System.SysUtils,
{$ifdef DEBUG}
  WinApi.Windows,
{$endif DEBUG}
  PascalType.ResourceStrings,
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
    FLookupFlags := TCustomOpenTypeLookupTable(Source).FLookupFlags;
    FMarkFilteringSet := TCustomOpenTypeLookupTable(Source).FMarkFilteringSet;
    FSubTableList.Assign(TCustomOpenTypeLookupTable(Source).FSubTableList);
  end;
end;

procedure TCustomOpenTypeLookupTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  LookupPos: Int64;
  IsExtension: boolean;
  PosFormat: Word;
  Offset: Cardinal;
  i: integer;
  SubTableType: Word;
  SubTableOffsets: array of Word;
  SubTable: TCustomOpenTypeLookupSubTable;
  SubTableClass: TOpenTypeLookupSubTableClass;
begin
  StartPos := Stream.Position;

  FLookupType := BigEndianValue.ReadWord(Stream);
  IsExtension := TCustomOpenTypeCommonTable(Parent.Parent).IsExtensionLookupType(FLookupType);

  FLookupFlags := BigEndianValue.ReadWord(Stream);

  // Read subtable count
  SetLength(SubTableOffsets, BigEndianValue.ReadWord(Stream));

  // Read lookup list index offsets
  for i := 0 to High(SubTableOffsets) do
    SubTableOffsets[i] := BigEndianValue.ReadWord(Stream);

  if (FLookupFlags and USE_MARK_FILTERING_SET <> 0) then
    FMarkFilteringSet := BigEndianValue.ReadWord(Stream);

  for i := 0 to High(SubTableOffsets) do
  begin
    LookupPos := StartPos + SubTableOffsets[i];
    Stream.Position := LookupPos;

    // Lookup is a an extension.
    // Get the actual lookuptype from the sub-table and the offset to the sub-table.
    if (IsExtension) then
    begin
      PosFormat := BigEndianValue.ReadWord(Stream);
      if (PosFormat <> 1) then
        raise EPascalTypeError.CreateFmt(RCStrUnknownVersion, [PosFormat]);

      FLookupType := BigEndianValue.ReadWord(Stream);
      if (TCustomOpenTypeCommonTable(Parent.Parent).IsExtensionLookupType(FLookupType)) then
        raise EPascalTypeError.CreateFmt(RCStrInvalidLookupType, [FLookupType]);

      Offset := BigEndianValue.ReadCardinal(Stream);

      Stream.Position := LookupPos + Offset;
    end;

    // Read lookup type
    SubTableType := BigEndianValue.ReadWord(Stream);
    SubTableClass := GetSubTableClass(SubTableType);

    if (SubTableClass = nil) then
      continue;

    // Add to subtable list
    SubTable := FSubTableList.Add(SubTableClass);

    // Load subtable
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

  BigEndianValue.WriteWord(Stream, FLookupType);
  BigEndianValue.WriteWord(Stream, FLookupFlags);

  BigEndianValue.WriteWord(Stream, FSubTableList.Count);
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
    BigEndianValue.WriteWord(Stream, SubTableOffsets[i]);

  Stream.Position := StartPos;
end;

function TCustomOpenTypeLookupTable.GetEnumerator: TEnumerator<TCustomOpenTypeLookupSubTable>;
begin
  Result := FSubTableList.GetEnumerator;
end;

function TCustomOpenTypeLookupTable.GetLookupList: TOpenTypeLookupListTable;
begin
  // Not so nice, but I'd rather not go through the FontFace to get at the list :-(
  Result := Parent as TOpenTypeLookupListTable;
end;

function TCustomOpenTypeLookupTable.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  SubTable: TCustomOpenTypeLookupSubTable;
begin
  for SubTable in FSubTableList do
    if (SubTable.Apply(AGlyphIterator)) then
      Exit(True);
  Result := False;
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

function TCustomOpenTypeLookupTable.GetUseReverseDirection: boolean;
begin
  Result := False;
end;

procedure TCustomOpenTypeLookupTable.SetLookupFlags(const Value: Word);
begin
  if FLookupFlags <> Value then
  begin
    FLookupFlags := Value;
    LookupFlagsChanged;
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

procedure TCustomOpenTypeLookupTable.LookupFlagsChanged;
begin
  Changed;
end;

procedure TCustomOpenTypeLookupTable.MarkFilteringSetChanged;
begin
  Changed;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeLookupTableGeneric
//
//------------------------------------------------------------------------------
function TOpenTypeLookupTableGeneric.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  Result := TOpenTypeLookupSubTableGeneric;
end;

function TOpenTypeLookupTableGeneric.TOpenTypeLookupSubTableGeneric.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
begin
{$ifdef DEBUG}
  OutputDebugString(PChar(Format('%s lookup not implemented. Lookup type: %d, sub-format: %d', [string(TCustomPascalTypeNamedTable(TOpenTypeLookupTableGeneric(Parent).LookupList.Parent).TableType.AsAnsiChar), TOpenTypeLookupTableGeneric(Parent).LookupType, SubFormat])));
{$endif DEBUG}

  Result := False;
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

procedure TOpenTypeLookupListTable.LoadFromStream(Stream: TStream; Size: Cardinal);

  function GetLookupTypeFromExtension: Word;
  var
    StartPos: Int64;
    LookupFlags: Word;
    Count: Word;
    SubOffset: Word;
    PosFormat: Word;
  begin
    StartPos := Stream.Position;

    Result := 0;

    // Skip LookupType and LookupFlags
    Stream.Position := Stream.Position + SizeOf(Word);

    // Read LookupFlags
    LookupFlags := BigEndianValue.ReadWord(Stream);

    // Read subtable count
    Count := BigEndianValue.ReadWord(Stream);

    // Read first lookup list index offset
    if (Count = 0) then
      Exit; // Invalid
    SubOffset := BigEndianValue.ReadWord(Stream);
    Stream.Position := Stream.Position + (Count-1)*SizeOf(Word);

    // Skip MarkFilteringSet
    if (LookupFlags and TCustomOpenTypeLookupTable.USE_MARK_FILTERING_SET <> 0) then
      Stream.Position := Stream.Position + SizeOf(Word);

    // Seek to sub-table
    Stream.Position := StartPos + SubOffset;

    // Read Extension Positioning Subtable Format 1
    // - posFormat (we just verify that it has the correct value)
    PosFormat := BigEndianValue.ReadWord(Stream);
    if (PosFormat <> 1) then
      Exit;

    // - extensionLookupType
    Result := BigEndianValue.ReadWord(Stream);

    // Skip extensionOffset. We don't need it here.
  end;

var
  StartPos: Int64;
  SavePos: Int64;
  i: Integer;
  LookupTableOffsets: array of Word;
  LookupTable: TCustomOpenTypeLookupTable;
  LookupType: Word;
  LookupTableClass: TOpenTypeLookupTableClass;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read lookup list count
  SetLength(LookupTableOffsets, BigEndianValue.ReadWord(Stream));

  // read offsets
  for i := 0 to High(LookupTableOffsets) do
    LookupTableOffsets[i] := BigEndianValue.ReadWord(Stream);

  FLookupList.Clear;

  for i := 0 to High(LookupTableOffsets) do
  begin
    // set position to start of lookup table
    Stream.Position := StartPos + LookupTableOffsets[i];

    // We peek ahead into the stream to determine the lookup table class in order to
    // support extension lookups. For extension lookup types the actual lookup type
    // is stored in the lookup sub-tables.
    LookupType := BigEndianValue.ReadWord(Stream);
    Stream.Seek(-SizeOf(Word), soFromCurrent);

    if (TCustomOpenTypeCommonTable(Parent).IsExtensionLookupType(LookupType)) then
    begin
      SavePos := Stream.Position;
      // Peek ahead into lookup table to get actual lookup type
      LookupType := GetLookupTypeFromExtension;

      // Make sure that the extension lookup didn't specify the lookup type as an extension lookup
      if (TCustomOpenTypeCommonTable(Parent).IsExtensionLookupType(LookupType)) then
        raise EPascalTypeError.CreateFmt(RCStrInvalidLookupType, [LookupType]);

      Stream.Position := SavePos;
    end;

    // Get the lookup table class from the parent.
    // The mapping from LookupType to lookup table class differs between GSUB and GPOS.
    LookupTableClass := TCustomOpenTypeCommonTable(Parent).GetLookupTableClass(LookupType);

    if (LookupTableClass = nil) then
      // We *must* load the table even if we have no implementation for it.
      // Otherwise the index numbers in the feature lookup list (see
      // TCustomOpenTypeFeatureTable) will not match.
      LookupTableClass := TOpenTypeLookupTableGeneric;

    LookupTable := FLookupList.Add(LookupTableClass);

    // Load lookup table
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

procedure TCustomOpenTypeLookupSubTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;
  FSubFormat := BigEndianValue.ReadWord(Stream);
end;

procedure TCustomOpenTypeLookupSubTable.SaveToStream(Stream: TStream);
begin
  inherited;
  BigEndianValue.WriteWord(Stream, FSubFormat);
end;

function TCustomOpenTypeLookupSubTable.ApplyLookupRecords(const AGlyphIterator: TPascalTypeGlyphGlyphIterator;
  const LookupRecords: TSequenceLookupRecords): boolean;
var
  LookupList: TOpenTypeLookupListTable;
  Lookup: TCustomOpenTypeLookupTable;
  i: integer;
  Iterator: TPascalTypeGlyphGlyphIterator;
begin
  // Lookup can be empty in which case we consider it a match. See issue #49
  if (Length(LookupRecords) = 0) then
    Exit(True);

  Result := False;

  LookupList := LookupTable.LookupList;
  for i := 0 to High(LookupRecords) do
  begin
    Iterator := AGlyphIterator.Clone;

    // Adjust the glyph index
    Iterator.Next(LookupRecords[i].SequenceIndex);

    // Get the referenced lookup
    Lookup := LookupList[LookupRecords[i].LookupListIndex];

    Iterator.LookupFlags := Lookup.LookupFlags;

    // Recursively apply until one matches
    if (Lookup.Apply(Iterator)) then
      Exit(True);
  end;
  // TODO : FontKit doesn't increment the iterator (hence the const param). I believe that is wrong.
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
    FreeAndNil(FCoverageTable);
    if (TCustomOpenTypeLookupSubTableWithCoverage(Source).CoverageTable <> nil) then
      FCoverageTable := TCustomOpenTypeLookupSubTableWithCoverage(Source).CoverageTable.Clone(Self);
  end;
end;

procedure TCustomOpenTypeLookupSubTableWithCoverage.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  CoverageOfs: Word;
  SavePos: Int64;
begin
  FreeAndNil(FCoverageTable);

  StartPos := Stream.Position;

  inherited;

  // Offset from start of sub-table to coverage table
  CoverageOfs := BigEndianValue.ReadWord(Stream);
  SavePos := Stream.Position;

  Stream.Position := StartPos + CoverageOfs;
  FCoverageTable := TCustomOpenTypeCoverageTable.CreateFromStream(Stream, Self);

  // Sub table header continues after Coverage offset
  Stream.Position := SavePos;
end;

procedure TCustomOpenTypeLookupSubTableWithCoverage.SaveToStream(Stream: TStream);
begin
  Assert(FCoverageTable <> nil);
  inherited;
  FCoverageTable.SaveToStream(Stream);
end;

//------------------------------------------------------------------------------

end.
