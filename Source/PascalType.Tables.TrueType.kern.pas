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
  PT_Types,
  PT_Classes,
  PT_Tables;

//------------------------------------------------------------------------------
// TCustomPascalTypeKerningFormatSubTable
//------------------------------------------------------------------------------
type
  TCustomPascalTypeKerningFormatSubTable = class abstract(TCustomPascalTypeTable)
  public
    function GetKerningValue(LeftGlyphIndex, RightGlyphIndex: Word): integer; virtual; abstract;
  end;

  TPascalTypeKerningFormatSubTableClass = class of TCustomPascalTypeKerningFormatSubTable;


type
  TKerningFormat0SubTable = record
    Left  : Word; // The glyph index for the left-hand glyph in the kerning pair.
    Right : Word; // The glyph index for the right-hand glyph in the kerning pair.
    Value : SmallInt; // The kerning value for the above pair, in FUnits. If this value is greater than zero, the characters will be moved apart. If this value is less than zero, the character will be moved closer together.
  end;


//------------------------------------------------------------------------------
// TPascalTypeKerningFormat0SubTable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/kern#format-0
//------------------------------------------------------------------------------
type
  TPascalTypeKerningFormat0SubTable = class(TCustomPascalTypeKerningFormatSubTable)
  private
    FPairs: TArray<TKerningFormat0SubTable>;
    function GetPairCount: Integer;
    function GetPair(Index: Integer): TKerningFormat0SubTable;
  public
    procedure LoadFromStream(Stream: TStream); override;
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
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


//------------------------------------------------------------------------------
// TPascalTypeKerningSubTable
//------------------------------------------------------------------------------
type
  TPascalTypeKerningSubTable = class(TCustomPascalTypeTable)
  private
    FVersion    : Word;
    FLength     : Word;
    FCoverage   : Word;
    FFormatTable: TCustomPascalTypeKerningFormatSubTable;
    function GetFormat: Byte;
    function GetIsCrossStream: Boolean;
    function GetIsHorizontal: Boolean;
    function GetIsMinimum: Boolean;
    function GetIsReplace: Boolean;
    procedure SetFormat(const Value: Byte);
    procedure SetIsCrossStream(const Value: Boolean);
    procedure SetIsHorizontal(const Value: Boolean);
    procedure SetIsMinimum(const Value: Boolean);
    procedure SetIsReplace(const Value: Boolean);
    procedure SetVersion(const Value: Word);
  protected
    procedure AssignFormat; virtual;
    procedure CoverageChanged; virtual;
    procedure FormatChanged; virtual;
    procedure IsCrossStreamChanged; virtual;
    procedure IsHorizontalChanged; virtual;
    procedure IsMinimumChanged; virtual;
    procedure IsReplaceChanged; virtual;
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property Length: Word read FLength;
    property Coverage: Word read FCoverage;

    property IsHorizontal: Boolean read GetIsHorizontal write SetIsHorizontal;
    property IsMinimum: Boolean read GetIsMinimum write SetIsMinimum;
    property IsCrossStream: Boolean read GetIsCrossStream write SetIsCrossStream;
    property IsReplace: Boolean read GetIsReplace write SetIsReplace;
    property Format: Byte read GetFormat write SetFormat;

    property FormatTable: TCustomPascalTypeKerningFormatSubTable read FFormatTable;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeKerningTable
//
//------------------------------------------------------------------------------
// Kerning
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/kern
//------------------------------------------------------------------------------
type
  TPascalTypeKerningTable = class(TCustomPascalTypeNamedTable)
  private
    FKerningSubtableList: TPascalTypeTableList<TPascalTypeKerningSubTable>;
    FVersion            : Word;
    procedure SetVersion(const Value: Word);
    function GetKerningSubtableCount: Integer;
    function GetKerningSubtable(Index: Integer): TPascalTypeKerningSubTable;
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;

    property KerningSubtable[Index: Integer]: TPascalTypeKerningSubTable read GetKerningSubtable;
    property KerningSubtableCount: Integer read GetKerningSubtableCount;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  System.SysUtils,
  System.Math,
  PT_ResourceStrings;


//------------------------------------------------------------------------------
// TPascalTypeKerningFormat0SubTable
//------------------------------------------------------------------------------
function TPascalTypeKerningFormat0SubTable.GetKerningValue(LeftGlyphIndex, RightGlyphIndex: Word): integer;
var
  PairIndex: Integer;
begin
  Result := 0;
  for PairIndex := 0 to High(FPairs) do
    if FPairs[PairIndex].Left = LeftGlyphIndex then
      if FPairs[PairIndex].Right = RightGlyphIndex then
      begin
        Result := FPairs[PairIndex].Value;
        Exit;
      end;
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

procedure TPascalTypeKerningFormat0SubTable.LoadFromStream(Stream: TStream);
var
  PairIndex    : Integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read number of pairs
  SetLength(FPairs, BigEndianValueReader.ReadWord(Stream));

  Stream.Seek(3*SizeOf(Word), soFromCurrent);

  for PairIndex := 0 to High(FPairs) do
  begin
    FPairs[PairIndex].Left := BigEndianValueReader.ReadWord(Stream);
    FPairs[PairIndex].Right := BigEndianValueReader.ReadWord(Stream);
    FPairs[PairIndex].Value := BigEndianValueReader.ReadSmallInt(Stream);
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
  WriteSwappedWord(Stream, Length(FPairs));

  // write search range
  SearchRange := Round(6 * (Power(2, Floor(Log2(Length(FPairs))))));
  WriteSwappedWord(Stream, SearchRange);

  // write entry selector
  EntrySelector := Round(Log2(SearchRange / 6));
  WriteSwappedWord(Stream, EntrySelector);

  // write range shift
  RangeShift := 6 * Length(FPairs) - SearchRange;
  WriteSwappedWord(Stream, RangeShift);

  for PairIndex := 0 to High(FPairs) do
  begin
    WriteSwappedWord(Stream, FPairs[PairIndex].Left);
    WriteSwappedWord(Stream, FPairs[PairIndex].Right);
    WriteSwappedSmallInt(Stream, FPairs[PairIndex].Value);
  end;
end;


//------------------------------------------------------------------------------
// TPascalTypeKerningFormat2SubTable
//------------------------------------------------------------------------------
procedure TPascalTypeKerningFormat2SubTable.LoadFromStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
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
  FFormatTable := TPascalTypeKerningFormat0SubTable.Create;
  AssignFormat;
end;

destructor TPascalTypeKerningSubTable.Destroy;
begin
  FFormatTable.Free;
  inherited;
end;

procedure TPascalTypeKerningSubTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeKerningSubTable then
  begin
    FVersion := TPascalTypeKerningSubTable(Source).FVersion;
    FLength := TPascalTypeKerningSubTable(Source).FLength;
    FCoverage := TPascalTypeKerningSubTable(Source).FCoverage;

    FFormatTable.Assign(TPascalTypeKerningSubTable(Source).FFormatTable);
  end;
end;

procedure TPascalTypeKerningSubTable.LoadFromStream(Stream: TStream);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FVersion := BigEndianValueReader.ReadWord(Stream);

  if FVersion <> 0 then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  FLength := BigEndianValueReader.ReadWord(Stream);
  FCoverage := BigEndianValueReader.ReadWord(Stream);

  AssignFormat;

  case Format of
    0, 2:
      FFormatTable.LoadFromStream(Stream);
  else
    begin
      // check minimum size
      if Stream.Position + FLength - 6 > Stream.Size then
        raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

      Stream.Seek(soFromCurrent, FLength - 6);
    end;
  end;
end;

procedure TPascalTypeKerningSubTable.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedWord(Stream, FVersion);
  WriteSwappedWord(Stream, FLength);
  WriteSwappedWord(Stream, FCoverage);
end;

function TPascalTypeKerningSubTable.GetFormat: Byte;
begin
  Result := (FCoverage shr 8) and $FF;
end;

function TPascalTypeKerningSubTable.GetIsCrossStream: Boolean;
begin
  Result := (FCoverage and (1 shl 2)) > 0;
end;

function TPascalTypeKerningSubTable.GetIsHorizontal: Boolean;
begin
  Result := (FCoverage and 1) > 0;
end;

function TPascalTypeKerningSubTable.GetIsMinimum: Boolean;
begin
  Result := (FCoverage and (1 shl 1)) > 0;
end;

function TPascalTypeKerningSubTable.GetIsReplace: Boolean;
begin
  Result := (FCoverage and (1 shl 3)) > 0;
end;

procedure TPascalTypeKerningSubTable.SetFormat(const Value: Byte);
begin
  if Value <> Format then
  begin
    FCoverage := (FCoverage and $FF) or ((Value and $FF) shl 8);
    FormatChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsCrossStream(const Value: Boolean);
begin
  if IsCrossStream <> Value then
  begin
    FCoverage := (FCoverage and (not(1 shl 2))) or (Integer(Value = True) shl 2);
    IsCrossStreamChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsHorizontal(const Value: Boolean);
begin
  if IsHorizontal <> Value then
  begin
    FCoverage := (FCoverage and (not 1)) or (Integer(Value = True));
    IsHorizontalChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsMinimum(const Value: Boolean);
begin
  if IsMinimum <> Value then
  begin
    FCoverage := (FCoverage and (not(1 shl 1))) or (Integer(Value = True) shl 1);
    IsMinimumChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsReplace(const Value: Boolean);
begin
  if IsReplace <> Value then
  begin
    FCoverage := (FCoverage and (not(1 shl 3))) or (Integer(Value = True) shl 3);
    IsReplaceChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.AssignFormat;
var
  OldFormatTable: TCustomPascalTypeKerningFormatSubTable;
const
  CFormatClasses: array[0..1] of TPascalTypeKerningFormatSubTableClass = (TPascalTypeKerningFormat0SubTable, TPascalTypeKerningFormat2SubTable);
begin
  case Format of
    0, 2:
      if not(FFormatTable is CFormatClasses[Format shr 1]) then
      begin
        OldFormatTable := FFormatTable;
        FFormatTable := CFormatClasses[Format shr 1].Create;
        if (OldFormatTable <> nil) then
        begin
          FFormatTable.Assign(OldFormatTable);
          OldFormatTable.Free;
        end;
      end;
  else
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);
  end;
end;

procedure TPascalTypeKerningSubTable.FormatChanged;
begin
  AssignFormat;
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.IsCrossStreamChanged;
begin
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.IsHorizontalChanged;
begin
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.IsMinimumChanged;
begin
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.IsReplaceChanged;
begin
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.CoverageChanged;
begin
  Changed;
end;

procedure TPascalTypeKerningSubTable.VersionChanged;
begin
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
  FKerningSubtableList := TPascalTypeTableList<TPascalTypeKerningSubTable>.Create;
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
  if (Index >= 0) and (Index < FKerningSubtableList.Count) then
    Result := FKerningSubtableList[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TPascalTypeKerningTable.GetKerningSubtableCount: Integer;
begin
  Result := FKerningSubtableList.Count;
end;

class function TPascalTypeKerningTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'kern';
end;

procedure TPascalTypeKerningTable.LoadFromStream(Stream: TStream);
var
  SubTableIndex: Integer;
  SubTable     : TPascalTypeKerningSubTable;
  SubTableCount: Word;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // clear eventually existing tables
  FKerningSubtableList.Clear;

  // read version
  FVersion := BigEndianValueReader.ReadWord(Stream);

  // For now we only support version 0 (same as Windows).
  // At time of writing, Apple has defined 3 additional versions.
  // https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6kern.html
  // TODO : Support for more kerning table versions
  if FVersion <> 0 then
    exit;
    // raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read number of glyphs
  SubTableCount := BigEndianValueReader.ReadWord(Stream);

  for SubTableIndex := 0 to SubTableCount - 1 do
  begin
    SubTable := FKerningSubtableList.Add;
    // load from stream
    SubTable.LoadFromStream(Stream);
  end;
end;

procedure TPascalTypeKerningTable.SaveToStream(Stream: TStream);
var
  SubTableIndex: Integer;
begin
  // write version
  WriteSwappedWord(Stream, FVersion);

  // write number of glyphs
  WriteSwappedWord(Stream, FKerningSubtableList.Count);

  // save to stream
  for SubTableIndex := 0 to FKerningSubtableList.Count - 1 do
    FKerningSubtableList[SubTableIndex].SaveToStream(Stream);
end;

procedure TPascalTypeKerningTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeKerningTable.VersionChanged;
begin
  Changed;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

initialization

  RegisterPascalTypeTable(TPascalTypeKerningTable);

end.
