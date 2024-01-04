unit PascalType.Tables.TrueType.kern;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'kern' table type                                     //
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
  System.Classes,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables;

//------------------------------------------------------------------------------
// TCustomPascalTypeKerningFormatSubTable
//------------------------------------------------------------------------------
type
  TCustomPascalTypeKerningFormatSubTable = class abstract(TCustomPascalTypeTable)
  public
    function GetKerningValue(LeftGlyphIndex, RightGlyphIndex: Word): integer; virtual; abstract;
  end;

  TPascalTypeKerningFormatSubTableClass = class of TCustomPascalTypeKerningFormatSubTable;


//------------------------------------------------------------------------------
// TPascalTypeKerningFormat0SubTable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/kern#format-0
//------------------------------------------------------------------------------
type
  TPascalTypeKerningFormat0SubTable = class(TCustomPascalTypeKerningFormatSubTable)
  private type
    TKerningFormat0SubTable = record
      Left : Word;      // The glyph index for the left-hand glyph in the kerning pair.
      Right: Word;      // The glyph index for the right-hand glyph in the kerning pair.
      Value: SmallInt;  // The kerning value for the above pair, in FUnits. If this value is greater than zero, the characters will be moved apart. If this value is less than zero, the character will be moved closer together.
    end;
  private
    FPairs: TArray<TKerningFormat0SubTable>;
    function GetPairCount: Integer;
    function GetPair(Index: Integer): TKerningFormat0SubTable;
  public
    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function GetKerningValue(LeftGlyphIndex: Word; RightGlyphIndex: Word): integer; override;

    property PairCount: Integer read GetPairCount;
    property Pair[Index: Integer]: TKerningFormat0SubTable read GetPair;
  end;


//------------------------------------------------------------------------------
// TPascalTypeKerningFormat2SubTable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/kern#format-2
//------------------------------------------------------------------------------
type
  TPascalTypeKerningFormat2SubTable = class(TCustomPascalTypeKerningFormatSubTable)
  private
    FLeftFirstGlyph: Word; // First glyph in left class range.
    FRightFirstGlyph: Word;  // Last glyph in right class range.
    FKernValues: TArray<TArray<SmallInt>>;
//    FKernValues: TArray<SmallInt>;
  public
    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function GetKerningValue(LeftGlyphIndex: Word; RightGlyphIndex: Word): integer; override;
  end;


//------------------------------------------------------------------------------
// TPascalTypeKerningSubTable
//------------------------------------------------------------------------------
type
  TPascalTypeKerningTable = class;

  TPascalTypeKerningSubTable = class abstract(TCustomPascalTypeTable)
  private
    FFormatTable: TCustomPascalTypeKerningFormatSubTable;
    FFormat: Byte;
  protected
    function GetKerningTable: TPascalTypeKerningTable;
    function GetIsCrossStream: Boolean; virtual; abstract;
    function GetIsHorizontal: Boolean; virtual;
    function GetIsMinimum: Boolean; virtual;
    function GetIsReplace: Boolean; virtual;
    function GetIsVertical: Boolean; virtual;
    function GetIsVariation: Boolean; virtual;
    procedure SetIsCrossStream(const Value: Boolean); virtual; abstract;
    procedure SetIsHorizontal(const Value: Boolean); virtual;
    procedure SetIsMinimum(const Value: Boolean); virtual;
    procedure SetIsReplace(const Value: Boolean); virtual;
    procedure SetIsVertical(const Value: Boolean); virtual;
    procedure SetIsVariation(const Value: Boolean); virtual;
    procedure SetFormat(const Value: Byte);
  protected
    function GetFormatClass: TPascalTypeKerningFormatSubTableClass; virtual;

    procedure CreateFormatTable;
    procedure FormatChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    property Format: Byte read FFormat write SetFormat;

    property IsHorizontal: Boolean read GetIsHorizontal write SetIsHorizontal;
    property IsMinimum: Boolean read GetIsMinimum write SetIsMinimum;
    property IsCrossStream: Boolean read GetIsCrossStream write SetIsCrossStream;
    property IsReplace: Boolean read GetIsReplace write SetIsReplace;
    property IsVertical: Boolean read GetIsVertical write SetIsVertical;
    property IsVariation: Boolean read GetIsVariation write SetIsVariation;

    property KerningTable: TPascalTypeKerningTable read GetKerningTable; // Parent kerning table
    property FormatTable: TCustomPascalTypeKerningFormatSubTable read FFormatTable;
  end;

  TPascalTypeKerningSubTableClass = class of TPascalTypeKerningSubTable;

//------------------------------------------------------------------------------
//
//              TPascalTypeKerningTable
//
//------------------------------------------------------------------------------
// Kerning
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/kern
//------------------------------------------------------------------------------
  TPascalTypeKerningTable = class(TCustomPascalTypeNamedTable)
  private
    FKerningSubtableList: TPascalTypeTableInterfaceList<TPascalTypeKerningSubTable>;
    FVersion: Cardinal;
    procedure SetVersion(const Value: Cardinal);
    function GetKerningSubtableCount: Integer;
    function GetKerningSubtable(Index: Integer): TPascalTypeKerningSubTable;
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Cardinal read FVersion write SetVersion;

    property KerningSubtable[Index: Integer]: TPascalTypeKerningSubTable read GetKerningSubtable; default;
    property KerningSubtableCount: Integer read GetKerningSubtableCount;
  end;


//------------------------------------------------------------------------------
// TPascalTypeKerningSubTableMicrosoft
//------------------------------------------------------------------------------
// Version 0: Microsoft format
//------------------------------------------------------------------------------
type
  TPascalTypeKerningSubTableMicrosoft = class(TPascalTypeKerningSubTable)
  private const
    KernHorizontal  = $01;
    KernMinimum     = $02;
    KernCrossStream = $04;
    KernOverride    = $08;
  private
    FVersion: Word;
    FLength: Word;
    FCoverage: Byte;
  protected
    function GetFormatClass: TPascalTypeKerningFormatSubTableClass; override;
  protected
    function GetIsCrossStream: Boolean; override;
    function GetIsHorizontal: Boolean; override;
    function GetIsVertical: Boolean; override;
    function GetIsMinimum: Boolean; override;
    function GetIsReplace: Boolean; override;
    procedure SetIsCrossStream(const Value: Boolean); override;
    procedure SetIsHorizontal(const Value: Boolean); override;
    procedure SetIsMinimum(const Value: Boolean); override;
    procedure SetIsReplace(const Value: Boolean); override;
    procedure SetVersion(const Value: Word);
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property Length: Word read FLength;
    property Coverage: Byte read FCoverage;
  end;


//------------------------------------------------------------------------------
// TPascalTypeKerningSubTableApple
//------------------------------------------------------------------------------
// Version 1: Apple format
//------------------------------------------------------------------------------
type
  TPascalTypeKerningSubTableApple = class(TPascalTypeKerningSubTable)
  private const
    KernVariation   = $20;
    KernCrossStream = $40;
    KernVertical    = $80;
  private
    FLength: Cardinal;
    FCoverage: Byte;
    FTupleIndex: Word;
  protected
    function GetFormatClass: TPascalTypeKerningFormatSubTableClass; override;
  protected
    function GetIsCrossStream: Boolean; override;
    function GetIsHorizontal: Boolean; override;
    function GetIsVertical: Boolean; override;
    function GetIsVariation: Boolean; override;
    procedure SetIsCrossStream(const Value: Boolean); override;
    procedure SetIsVertical(const Value: Boolean); override;
    procedure SetIsVariation(const Value: Boolean); override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Length: Cardinal read FLength;
    property Coverage: Byte read FCoverage;
    property TupleIndex: Word read FTupleIndex;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  Generics.Defaults,
  Generics.Collections,
  System.SysUtils,
  System.Math,
  PascalType.ResourceStrings;


//------------------------------------------------------------------------------
// TPascalTypeKerningFormat0SubTable
//------------------------------------------------------------------------------
function TPascalTypeKerningFormat0SubTable.GetKerningValue(LeftGlyphIndex, RightGlyphIndex: Word): integer;
var
  Pair: TKerningFormat0SubTable;
  Index: Integer;
begin
  Pair.Left := LeftGlyphIndex;
  Pair.Right := LeftGlyphIndex;
  if (TArray.BinarySearch<TKerningFormat0SubTable>(FPairs, Pair, Index,
    TComparer<TKerningFormat0SubTable>.Construct(
      function(const A, B: TKerningFormat0SubTable): integer
      begin
        Result := integer(A.Left)-integer(B.Left);
        if (Result = 0) then
          Result := integer(A.Right)-integer(B.Right);
      end))) then
    Result := FPairs[Index].Value
  else
    Result := 0;
end;

function TPascalTypeKerningFormat0SubTable.GetPair(Index: Integer): TKerningFormat0SubTable;
begin
  if (Index < 0) or (Index > High(FPairs)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FPairs[Index];
end;

function TPascalTypeKerningFormat0SubTable.GetPairCount: Integer;
begin
  Result := Length(FPairs);
end;

procedure TPascalTypeKerningFormat0SubTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  PairIndex    : Integer;
begin
  // +--------+---------------+----------------------------------------------------------+
  // | Type   | Field         | Description                                              |
  // +========+===============+==========================================================+
  // | uint16 | nPairs        | This gives the number of kerning pairs in the table.     |
  // +--------+---------------+----------------------------------------------------------+
  // | uint16 | searchRange   | Ignored                                                  |
  // +--------+---------------+----------------------------------------------------------+
  // | uint16 | entrySelector | Ignored                                                  |
  // +--------+---------------+----------------------------------------------------------+
  // | uint16 | rangeShift    | Ignored                                                  |
  // +--------+---------------+----------------------------------------------------------+

  inherited;

  if Stream.Position + 4*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  SetLength(FPairs, BigEndianValue.ReadWord(Stream));

  Stream.Seek(3*SizeOf(Word), soFromCurrent);

  for PairIndex := 0 to High(FPairs) do
  begin
    FPairs[PairIndex].Left := BigEndianValue.ReadWord(Stream);
    FPairs[PairIndex].Right := BigEndianValue.ReadWord(Stream);
    FPairs[PairIndex].Value := BigEndianValue.ReadSmallInt(Stream);
  end;
end;

procedure TPascalTypeKerningFormat0SubTable.SaveToStream(Stream: TStream);
var
  PairIndex    : Integer;
  SearchRange  : Word;
  EntrySelector: Word;
  RangeShift   : Word;
begin
  inherited;

  // write number of pairs
  BigEndianValue.WriteWord(Stream, Length(FPairs));

  // write search range
  SearchRange := Round(6 * (Power(2, Floor(Log2(Length(FPairs))))));
  BigEndianValue.WriteWord(Stream, SearchRange);

  // write entry selector
  EntrySelector := Round(Log2(SearchRange / 6));
  BigEndianValue.WriteWord(Stream, EntrySelector);

  // write range shift
  RangeShift := 6 * Length(FPairs) - SearchRange;
  BigEndianValue.WriteWord(Stream, RangeShift);

  for PairIndex := 0 to High(FPairs) do
  begin
    BigEndianValue.WriteWord(Stream, FPairs[PairIndex].Left);
    BigEndianValue.WriteWord(Stream, FPairs[PairIndex].Right);
    BigEndianValue.WriteSmallInt(Stream, FPairs[PairIndex].Value);
  end;
end;


//------------------------------------------------------------------------------
// TPascalTypeKerningFormat2SubTable
//------------------------------------------------------------------------------
function TPascalTypeKerningFormat2SubTable.GetKerningValue(LeftGlyphIndex, RightGlyphIndex: Word): integer;
begin
  if (LeftGlyphIndex < FLeftFirstGlyph) or (RightGlyphIndex < FRightFirstGlyph) then
    Exit(0);

  Dec(LeftGlyphIndex, FLeftFirstGlyph);

  if (LeftGlyphIndex > High(FKernValues)) then
    Exit(0);

  Dec(RightGlyphIndex, FRightFirstGlyph);

  if (RightGlyphIndex > High(FKernValues[LeftGlyphIndex])) then
    Exit(0);

  Result := FKernValues[LeftGlyphIndex, RightGlyphIndex];
end;

procedure TPascalTypeKerningFormat2SubTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  var StartPos := Stream.Position - 8;
  // Offsets are documented to be from start of *this* table, but for some
  // reason the offset values are off by 8 (which happens to be the size
  // of the parent header...).

  inherited;

  var RowWidth := BigEndianValue.ReadWord(Stream);
  var LeftOffset := BigEndianValue.ReadWord(Stream);
  var RightOffset := BigEndianValue.ReadWord(Stream);
  var KernOffset := BigEndianValue.ReadWord(Stream);

  var SecondCount := RowWidth div SizeOf(Word);
  var FirstCount := 0;

  Stream.Position := StartPos + LeftOffset;
  FLeftFirstGlyph := BigEndianValue.ReadWord(Stream);

  var LeftOffsets: TArray<Word>;
  SetLength(LeftOffsets, BigEndianValue.ReadWord(Stream));
  for var i := 0 to High(LeftOffsets) do
  begin
    var Offset := BigEndianValue.ReadWord(Stream);
    // Apple: "Values within the left-hand offset table should not be less than the kerning array offset."
    if (Offset < KernOffset) then
      raise EPascalTypeError.CreateFmt(RCStrValueOutOfBounds, [Offset]);

    LeftOffsets[i] := (Offset - KernOffset) div RowWidth;

    if (LeftOffsets[i] > FirstCount) then
      FirstCount := LeftOffsets[i];
  end;

  Inc(FirstCount);

  Stream.Position := StartPos + RightOffset;
  FRightFirstGlyph := BigEndianValue.ReadWord(Stream);

  var RightOffsets: TArray<Word>;
  SetLength(RightOffsets, BigEndianValue.ReadWord(Stream));
  for var i := 0 to High(RightOffsets) do
    RightOffsets[i] := BigEndianValue.ReadWord(Stream) div SizeOf(Word);

  Stream.Position := StartPos + KernOffset;
  SetLength(FKernValues, FirstCount);
  for var i := 0 to FirstCount-1 do
  begin
    SetLength(FKernValues[i], SecondCount);
    for var j := 0 to SecondCount-1 do
      FKernValues[i, j] := BigEndianValue.ReadSmallInt(Stream);
  end;
end;

procedure TPascalTypeKerningFormat2SubTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


//------------------------------------------------------------------------------
// TPascalTypeKerningSubTable
//------------------------------------------------------------------------------
constructor TPascalTypeKerningSubTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  CreateFormatTable;
end;

destructor TPascalTypeKerningSubTable.Destroy;
begin
  FFormatTable.Free;
  inherited;
end;

procedure TPascalTypeKerningSubTable.CreateFormatTable;
begin
  var FormatClass := GetFormatClass;
  if (FormatClass = nil) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  FreeAndNil(FFormatTable);
  FFormatTable := FormatClass.Create;
end;

procedure TPascalTypeKerningSubTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeKerningSubTable then
  begin
    FFormat := TPascalTypeKerningSubTableApple(Source).FFormat;
    CreateFormatTable;
    FFormatTable.Assign(TPascalTypeKerningSubTable(Source).FFormatTable);
  end;
end;

function TPascalTypeKerningSubTable.GetKerningTable: TPascalTypeKerningTable;
begin
  Result := TPascalTypeKerningTable(Parent);
end;

function TPascalTypeKerningSubTable.GetFormatClass: TPascalTypeKerningFormatSubTableClass;
begin
  case Format of
    0: Result := TPascalTypeKerningFormat0SubTable;
    2: Result := TPascalTypeKerningFormat2SubTable;
  else
    Result := nil;
  end;
end;

function TPascalTypeKerningSubTable.GetIsHorizontal: Boolean;
begin
  Result := False;
end;

function TPascalTypeKerningSubTable.GetIsMinimum: Boolean;
begin
  Result := False;
end;

function TPascalTypeKerningSubTable.GetIsReplace: Boolean;
begin
  Result := False;
end;

function TPascalTypeKerningSubTable.GetIsVariation: Boolean;
begin
  Result := False;
end;

function TPascalTypeKerningSubTable.GetIsVertical: Boolean;
begin
  Result := False;
end;

procedure TPascalTypeKerningSubTable.SetFormat(const Value: Byte);
begin
  if (Value <> FFormat) then
  begin
    FFormat := Value;
    FormatChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsHorizontal(const Value: Boolean);
begin
end;

procedure TPascalTypeKerningSubTable.SetIsMinimum(const Value: Boolean);
begin
end;

procedure TPascalTypeKerningSubTable.SetIsReplace(const Value: Boolean);
begin
end;

procedure TPascalTypeKerningSubTable.SetIsVariation(const Value: Boolean);
begin
end;

procedure TPascalTypeKerningSubTable.SetIsVertical(const Value: Boolean);
begin
end;

procedure TPascalTypeKerningSubTable.FormatChanged;
begin
  CreateFormatTable;
  Changed;
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeKerningTable
//
//------------------------------------------------------------------------------
constructor TPascalTypeKerningTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FKerningSubtableList := TPascalTypeTableInterfaceList<TPascalTypeKerningSubTable>.Create(Self);
end;

destructor TPascalTypeKerningTable.Destroy;
begin
  FKerningSubtableList.Free;
  inherited;
end;

procedure TPascalTypeKerningTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeKerningTable then
  begin
    FVersion := TPascalTypeKerningTable(Source).FVersion;
    FKerningSubtableList.Assign(TPascalTypeKerningTable(Source).FKerningSubtableList);
  end;
end;

function TPascalTypeKerningTable.GetKerningSubtable(Index: Integer): TPascalTypeKerningSubTable;
begin
  if (Index < 0) or  (Index >= FKerningSubtableList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FKerningSubtableList[Index];
end;

function TPascalTypeKerningTable.GetKerningSubtableCount: Integer;
begin
  Result := FKerningSubtableList.Count;
end;

class function TPascalTypeKerningTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'kern';
end;

procedure TPascalTypeKerningTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  SubTableCount: Cardinal;
  SubTableClass: TPascalTypeKerningSubTableClass;
begin
  // The format differs for Microsoft (version 0) tables and Apple (version 1) tables.
  //
  // Windows only supports version 0.
  // Apple supports version 0 and 1.
  //
  // Apple: "Fonts targeted for OS X only should use the new format; fonts targeted
  // for both OS X and Windows should use the old format."
  //
  // Version 0:
  // +--------+---------+-------------------------------------------+
  // | Type   | Field   | Description                               |
  // +========+=========+===========================================+
  // | uint16 | version | Table version number.                     |
  // +--------+---------+-------------------------------------------+
  // | uint16 | nTables | Number of subtables in the kerning table. |
  // +--------+---------+-------------------------------------------+
  //
  // Version 1:
  // +--------+---------+-------------------------------------------+
  // | Type   | Field   | Description                               |
  // +========+=========+===========================================+
  // | uint32 | version | Table version number.                     |
  // +--------+---------+-------------------------------------------+
  // | uint32 | nTables | Number of subtables in the kerning table. |
  // +--------+---------+-------------------------------------------+

  FKerningSubtableList.Clear;

  inherited;

  FVersion := BigEndianValue.ReadWord(Stream);
  if (FVersion > 1) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);
  if (FVersion = 1) then
    Stream.Seek(SizeOf(Word), soFromCurrent);

  if (FVersion = 0) then
    SubTableCount := BigEndianValue.ReadWord(Stream)
  else
    SubTableCount := BigEndianValue.ReadCardinal(Stream);

  if (FVersion = 0) then
    SubTableClass := TPascalTypeKerningSubTableMicrosoft
  else
    SubTableClass := TPascalTypeKerningSubTableApple;

  for var i := 0 to SubTableCount - 1 do
  begin
    var SubTable := FKerningSubtableList.Add(SubTableClass);
    SubTable.LoadFromStream(Stream);
  end;
end;

procedure TPascalTypeKerningTable.SaveToStream(Stream: TStream);
begin
  if (FVersion = 0) then
  begin
    BigEndianValue.WriteWord(Stream, FVersion);
    BigEndianValue.WriteWord(Stream, FKerningSubtableList.Count);
  end else
  begin
    BigEndianValue.WriteCardinal(Stream, FVersion);
    BigEndianValue.WriteCardinal(Stream, FKerningSubtableList.Count);
  end;

  for var i := 0 to FKerningSubtableList.Count - 1 do
    FKerningSubtableList[i].SaveToStream(Stream);
end;

procedure TPascalTypeKerningTable.SetVersion(const Value: Cardinal);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    FKerningSubtableList.Clear;
    Changed;
  end;
end;


//------------------------------------------------------------------------------
// TPascalTypeKerningSubTableMicrosoft
//------------------------------------------------------------------------------
procedure TPascalTypeKerningSubTableMicrosoft.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeKerningSubTableMicrosoft then
  begin
    FVersion := TPascalTypeKerningSubTableMicrosoft(Source).FVersion;
    FLength := TPascalTypeKerningSubTableMicrosoft(Source).FLength;
    FCoverage := TPascalTypeKerningSubTableMicrosoft(Source).FCoverage;
  end;
end;

procedure TPascalTypeKerningSubTableMicrosoft.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  // Kerning subtables share the same header format.
  // This header is used to identify the format of the subtable and the kind of information it contains.
  // Note: The layout differs for Microsoft (version 0) tables and Apple (version 1) tables.
  //
  // Version 0:
  // +--------+----------+----------------------------------------------------------+
  // | Type   | Field    | Description                                              |
  // +========+==========+==========================================================+
  // | uint16 | version  | Kern subtable version number (values undefined)          |
  // +--------+----------+----------------------------------------------------------+
  // | uint16 | length   | Length of the subtable, in bytes(including this header). |
  // +--------+----------+----------------------------------------------------------+
  // | uint16 | coverage | What type of information is contained in this table.     |
  // +--------+----------+----------------------------------------------------------+

  inherited;

  FVersion := BigEndianValue.ReadWord(Stream);
  FLength := BigEndianValue.ReadWord(Stream);
  Format := BigEndianValue.ReadByte(Stream);
  FCoverage := BigEndianValue.ReadByte(Stream);

  CreateFormatTable;

  FormatTable.LoadFromStream(Stream);
end;

procedure TPascalTypeKerningSubTableMicrosoft.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteWord(Stream, FVersion);
  BigEndianValue.WriteWord(Stream, FLength);
  BigEndianValue.WriteByte(Stream, Format);
  BigEndianValue.WriteByte(Stream, FCoverage);

  FormatTable.SaveToStream(Stream);
end;

function TPascalTypeKerningSubTableMicrosoft.GetFormatClass: TPascalTypeKerningFormatSubTableClass;
begin
  Result := inherited;
end;

function TPascalTypeKerningSubTableMicrosoft.GetIsCrossStream: Boolean;
begin
  Result := (FCoverage and KernCrossStream <> 0)
end;

function TPascalTypeKerningSubTableMicrosoft.GetIsHorizontal: Boolean;
begin
  Result := (FCoverage and KernHorizontal <> 0);
end;

function TPascalTypeKerningSubTableMicrosoft.GetIsMinimum: Boolean;
begin
  Result := (FCoverage and KernMinimum <> 0);
end;

function TPascalTypeKerningSubTableMicrosoft.GetIsReplace: Boolean;
begin
  Result := (FCoverage and KernOverride <> 0);
end;

function TPascalTypeKerningSubTableMicrosoft.GetIsVertical: Boolean;
begin
  Result := not IsHorizontal;
end;

procedure TPascalTypeKerningSubTableMicrosoft.SetIsCrossStream(const Value: Boolean);
begin
  if IsCrossStream <> Value then
  begin
    if (Value) then
      FCoverage := FCoverage or KernCrossStream
    else
      FCoverage := FCoverage and (not KernCrossStream);
    Changed;
  end;
end;

procedure TPascalTypeKerningSubTableMicrosoft.SetIsHorizontal(const Value: Boolean);
begin
  if (IsHorizontal <> Value) then
  begin
    if (Value) then
      FCoverage := FCoverage or KernHorizontal
    else
      FCoverage := FCoverage and (not KernHorizontal);
    Changed;
  end;
end;

procedure TPascalTypeKerningSubTableMicrosoft.SetIsMinimum(const Value: Boolean);
begin
  if (IsMinimum <> Value) then
  begin
    if (Value) then
      FCoverage := FCoverage or KernMinimum
    else
      FCoverage := FCoverage and (not KernMinimum);
    Changed;
  end;
end;

procedure TPascalTypeKerningSubTableMicrosoft.SetIsReplace(const Value: Boolean);
begin
  if (IsReplace <> Value) then
  begin
    if (Value) then
      FCoverage := FCoverage or KernOverride
    else
      FCoverage := FCoverage and (not KernOverride);
    Changed;
  end;
end;

procedure TPascalTypeKerningSubTableMicrosoft.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    Changed;
  end;
end;


//------------------------------------------------------------------------------
// TPascalTypeKerningSubTableApple
//------------------------------------------------------------------------------
procedure TPascalTypeKerningSubTableApple.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeKerningSubTableApple then
  begin
    FLength := TPascalTypeKerningSubTableApple(Source).FLength;
    FCoverage := TPascalTypeKerningSubTableApple(Source).FCoverage;
    FTupleIndex := TPascalTypeKerningSubTableApple(Source).FTupleIndex;
  end;
end;

procedure TPascalTypeKerningSubTableApple.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  // Kerning subtables share the same header format.
  // This header is used to identify the format of the subtable and the kind of information it contains.
  // Note: The layout differs for Microsoft (version 0) tables and Apple (version 1) tables.
  //
  // Version 1:
  // +--------+-----------+----------------------------------------------------------+
  // | Type   | Field     | Description                                              |
  // +========+===========+==========================================================+
  // | uint32 | length    | Length of the subtable, in bytes(including this header). |
  // +--------+-----------+----------------------------------------------------------+
  // | uint16 | coverage  | What type of information is contained in this table.     |
  // +--------+-----------+----------------------------------------------------------+
  // | uint16 | tupleIndex| What type of information is contained in this table.     |
  // +--------+-----------+----------------------------------------------------------+

  var StartPos := Stream.Position;

  inherited;

  FLength := BigEndianValue.ReadCardinal(Stream);
  FCoverage := BigEndianValue.ReadByte(Stream);
  Format := BigEndianValue.ReadByte(Stream);
  FTupleIndex := BigEndianValue.ReadWord(Stream);

  FormatTable.LoadFromStream(Stream);

  Stream.Position := StartPos + FLength;

end;

procedure TPascalTypeKerningSubTableApple.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteCardinal(Stream, FLength);
  BigEndianValue.WriteByte(Stream, FCoverage);
  BigEndianValue.WriteByte(Stream, Format);
  BigEndianValue.WriteWord(Stream, FTupleIndex);

  FormatTable.SaveToStream(Stream);
end;

function TPascalTypeKerningSubTableApple.GetFormatClass: TPascalTypeKerningFormatSubTableClass;
begin
  Result := inherited;
end;

function TPascalTypeKerningSubTableApple.GetIsCrossStream: Boolean;
begin
  Result := (FCoverage and KernCrossStream <> 0);
end;

function TPascalTypeKerningSubTableApple.GetIsHorizontal: Boolean;
begin
  Result := not IsVertical;
end;

function TPascalTypeKerningSubTableApple.GetIsVariation: Boolean;
begin
  Result := (FCoverage and KernVariation <> 0);
end;

function TPascalTypeKerningSubTableApple.GetIsVertical: Boolean;
begin
  Result := (FCoverage and KernVertical <> 0);
end;

procedure TPascalTypeKerningSubTableApple.SetIsCrossStream(const Value: Boolean);
begin
  if IsCrossStream <> Value then
  begin
    if (Value) then
      FCoverage := FCoverage or KernCrossStream
    else
      FCoverage := FCoverage and (not KernCrossStream);
    Changed;
  end;
end;

procedure TPascalTypeKerningSubTableApple.SetIsVariation(const Value: Boolean);
begin
  if (IsHorizontal <> Value) then
  begin
    if (Value) then
      FCoverage := FCoverage or KernVariation
    else
      FCoverage := FCoverage and (not KernVariation);
    Changed;
  end;
end;

procedure TPascalTypeKerningSubTableApple.SetIsVertical(const Value: Boolean);
begin
  if (IsHorizontal <> Value) then
  begin
    if (Value) then
      FCoverage := FCoverage or KernVertical
    else
      FCoverage := FCoverage and (not KernVertical);
    Changed;
  end;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

initialization

  PascalTypeTableClasses.RegisterTable(TPascalTypeKerningTable);

end.
