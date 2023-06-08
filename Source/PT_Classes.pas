unit PT_Classes;

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
//  Portions created by Christian-W. Budde are Copyright (C) 2010-2021        //
//  by Christian-W. Budde. All Rights Reserved.                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

{$I PT_Compiler.inc}

uses
  Generics.Collections,
  Classes, SysUtils,
  PT_Types;

type
  // A GlyphID
  TGlyphID = Word;
  TGlyphString = TArray<TGlyphID>;

type
  TContourPoint = record
    XPos: Single;
    YPos: Single;
    Flags: Byte;
  end;
  PContourPoint = ^TContourPoint;

  TPascalTypeContour = array of TContourPoint;
  TPascalTypePath = array of TPascalTypeContour;

type
  TCustomPascalTypeNamedTable = class;
  TCustomPascalTypeNamedTableClass = class of TCustomPascalTypeNamedTable;

  IPascalTypeFontFace = interface(IUnknown)
    ['{A990D67B-BC60-4DA4-9D90-3C1D30AEC003}']
    function GetTableByTableName(const TableName: TTableName): TCustomPascalTypeNamedTable;
    function GetTableByTableType(TableType: TTableType): TCustomPascalTypeNamedTable;
    function GetTableByTableClass(TableClass: TCustomPascalTypeNamedTableClass): TCustomPascalTypeNamedTable;
  end;

  IPascalTypeFontFaceChange = interface(IUnknown)
    ['{4C10BAEF-04DB-42D0-9A6C-5FE155E80AEB}']
    procedure Changed;
  end;


  TCustomPascalTypeTable = class abstract(TInterfacedPersistent, IStreamPersist)
  private
    FParent: TCustomPascalTypeTable;
  protected
    procedure Changed; virtual;
    function GetFontFace: IPascalTypeFontFace; virtual;
//    constructor CreateHidden;
  public
    constructor Create(AParent: TCustomPascalTypeTable = nil); virtual;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;

    property Parent: TCustomPascalTypeTable read FParent;
    property FontFace: IPascalTypeFontFace read GetFontFace;
  end;
  TPascalTypeTableClass = class of TCustomPascalTypeTable;


  TXCustomPascalTypeInterfaceTable = class(TCustomPascalTypeTable)
  private
    FFontFace: IPascalTypeFontFace;
  protected
    procedure Changed; override;
    property FontFace: IPascalTypeFontFace read FFontFace;
  public
    constructor Create(const AFontFace: IPascalTypeFontFace); reintroduce; overload; virtual;
  end;
  TXCustomPascalTypeInterfaceTableClass = class of TXCustomPascalTypeInterfaceTable;


  TCustomPascalTypeNamedTable = class(TCustomPascalTypeTable)
  protected
    function GetInternalTableType: TTableType; virtual;
  public
    class function GetTableType: TTableType; virtual; abstract;

    procedure WriteTableTypeToStream(Stream: TStream); virtual;
    property TableType: TTableType read GetInternalTableType;
  end;


  TPascalTypeTableList<T: TCustomPascalTypeTable> = class(TObjectList<T>)
  public
    function Add: T; overload; virtual;
    function Add(ATableClass: TPascalTypeTableClass): T; overload;
    procedure Assign(Source: TPascalTypeTableList<T>);
  end;

  TPascalTypeTableInterfaceList<T: TCustomPascalTypeTable> = class(TPascalTypeTableList<T>)
  private
    FParent: TCustomPascalTypeTable;
  protected
    property Parent: TCustomPascalTypeTable read FParent;
  public
    constructor Create(AParent: TCustomPascalTypeTable);
    function Add: T; overload; override;
    function Add(ATableClass: TPascalTypeTableClass): T; overload;
    procedure Assign(Source: TPascalTypeTableList<T>);
  end;

type
  ValueReader = class
  protected
    class procedure PostProcess(var ABuffer; ASize, AElementSize: integer); virtual;
  public
    class procedure Read<T>(AStream: TStream; var Buffer: T); overload;
    class procedure Read<T>(AStream: TStream; var Buffer; Count: integer); overload;

    // 8 bit
    class function ReadByte(AStream: TStream): Byte; overload;
    class procedure ReadByte(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class function ReadShortInt(AStream: TStream): ShortInt; overload;
    class procedure ReadShortInt(AStream: TStream; var Buffer; Count: integer = 1); overload;

    // 16 bit
    class function ReadWord(AStream: TStream): Word; overload;
    class procedure ReadWord(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class function ReadSmallInt(AStream: TStream): SmallInt; overload;
    class procedure ReadSmallInt(AStream: TStream; var Buffer; Count: integer = 1); overload;

    // 32 bit
    class function ReadCardinal(AStream: TStream): Cardinal; overload;
    class procedure ReadCardinal(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class function ReadInteger(AStream: TStream): Integer; overload;
    class procedure ReadInteger(AStream: TStream; var Buffer; Count: integer = 1); overload;

    // 64 bit
    class function ReadUInt64(AStream: TStream): UInt64; overload;
    class procedure ReadUInt64(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class function ReadInt64(AStream: TStream): Int64; overload;
    class procedure ReadInt64(AStream: TStream; var Buffer; Count: integer = 1); overload;

    class procedure Copy<T>(const ASource; var ADest: T; ASize: integer); overload;
    class procedure Copy(ASource, ADest: PWord; ACount: integer); overload;
  end;

  BigEndianValueReader = class(ValueReader)
  protected
    class procedure PostProcess(var ABuffer; ASize, AElementSize: integer); override;
  public
  end;

// big-endian stream I/O
function ReadSwappedWord(Stream: TStream): Word; {$IFDEF UseInline} inline; {$ENDIF} deprecated 'Use BigEndianValueReader.ReadWord';
function ReadSwappedSmallInt(Stream: TStream): SmallInt; {$IFDEF UseInline} inline; {$ENDIF} deprecated 'Use BigEndianValueReader.ReadSmallInt';
function ReadSwappedCardinal(Stream: TStream): Cardinal; {$IFDEF UseInline} inline; {$ENDIF} deprecated 'Use BigEndianValueReader.ReadCardinal';
function ReadSwappedInt64(Stream: TStream): Int64; {$IFDEF UseInline} inline; {$ENDIF} deprecated 'Use BigEndianValueReader.ReadInt64';
procedure WriteSwappedWord(Stream: TStream; Value: Word); {$IFDEF UseInline} inline; {$ENDIF}
procedure WriteSwappedSmallInt(Stream: TStream; Value: SmallInt); {$IFDEF UseInline} inline; {$ENDIF}
procedure WriteSwappedCardinal(Stream: TStream; Value: Cardinal); {$IFDEF UseInline} inline; {$ENDIF}
procedure WriteSwappedInt64(Stream: TStream; Value: Int64); {$IFDEF UseInline} inline; {$ENDIF}
procedure CopySwappedWord(Source: PWord; Destination: PWord; Size: Integer); deprecated 'Use BigEndianValueReader.Copy';

implementation

uses
  PT_Math,
  PT_ResourceStrings;

function ReadSwappedWord(Stream: TStream): Word;
begin
{$IFDEF ValidateEveryReadOperation}
  if Stream.Read(Result, SizeOf(Word)) <> SizeOf(Word) then
    raise EPascalTypeStremReadError.Create(RCStrStreamReadError);
{$ELSE}
  Stream.Read(Result, SizeOf(Word));
{$ENDIF}
  Result := Swap16(Result);
end;

function ReadSwappedSmallInt(Stream: TStream): SmallInt;
begin
{$IFDEF ValidateEveryReadOperation}
  if Stream.Read(Result, SizeOf(SmallInt)) <> SizeOf(SmallInt) then
    raise EPascalTypeStremReadError.Create(RCStrStreamReadError);
{$ELSE}
  Stream.Read(Result, SizeOf(SmallInt));
{$ENDIF}
  Result := SmallInt(Swap16(Word(Result)));
end;

function ReadSwappedCardinal(Stream: TStream): Cardinal;
begin
{$IFDEF ValidateEveryReadOperation}
  Assert(SizeOf(Cardinal) = 4);
  if Stream.Read(Result, SizeOf(Cardinal)) <> SizeOf(Cardinal) then
    raise EPascalTypeStremReadError.Create(RCStrStreamReadError);
{$ELSE}
  Stream.Read(Result, SizeOf(Cardinal));
{$ENDIF}
  Result := Swap32(Result);
end;

function ReadSwappedInt64(Stream: TStream): Int64;
begin
{$IFDEF ValidateEveryReadOperation}
  if Stream.Read(Result, SizeOf(Int64)) <> SizeOf(Int64) then
    raise EPascalTypeStremReadError.Create(RCStrStreamReadError);
{$ELSE}
  Stream.Read(Result, SizeOf(Int64));
{$ENDIF}
  Result := Swap64(Result);
end;

procedure WriteSwappedWord(Stream: TStream; Value: Word);
begin
  Value := Swap16(Value);
  Stream.Write(Value, SizeOf(Word));
end;

procedure WriteSwappedSmallInt(Stream: TStream; Value: SmallInt);
begin
  Value := Swap16(Value);
  Stream.Write(Value, SizeOf(SmallInt));
end;

procedure WriteSwappedCardinal(Stream: TStream; Value: Cardinal);
begin
  Value := Swap32(Value);
  Stream.Write(Value, SizeOf(Cardinal));
end;

procedure WriteSwappedInt64(Stream: TStream; Value: Int64);
begin
  Value := Swap64(Value);
  Stream.Write(Value, SizeOf(Int64));
end;

procedure CopySwappedWord(Source: PWord; Destination: PWord; Size: Integer);
var
  Cnt: Integer;
begin
  for Cnt := 0 to Size - 1 do
  begin
    Destination^ := Swap16(Source^);
    Inc(Source);
    Inc(Destination);
  end;
end;


{ TPascalTypeTableList<T> }

function TPascalTypeTableList<T>.Add: T;
begin
  Result := T.Create;
  Add(Result);
end;

function TPascalTypeTableList<T>.Add(ATableClass: TPascalTypeTableClass): T;
begin
  Result := T(ATableClass.Create);
  Add(Result);
end;

procedure TPascalTypeTableList<T>.Assign(Source: TPascalTypeTableList<T>);
var
  SourceItem: T;
  DestItem: T;
begin
  Clear;
  for SourceItem in Source do
  begin
    DestItem := T(TPascalTypeTableClass(SourceItem.ClassType).Create);
    Add(DestItem);
    DestItem.Assign(SourceItem);
  end;
end;

{ TPascalTypeTableInterfaceList<T> }

function TPascalTypeTableInterfaceList<T>.Add: T;
begin
  Result := T(TPascalTypeTableClass(T).Create(FParent));
  Add(Result);
end;

function TPascalTypeTableInterfaceList<T>.Add(ATableClass: TPascalTypeTableClass): T;
begin
  Result := T(ATableClass.Create(FParent));
  Add(Result);
end;

procedure TPascalTypeTableInterfaceList<T>.Assign(Source: TPascalTypeTableList<T>);
var
  SourceItem: T;
  DestItem: T;
begin
  Clear;
  for SourceItem in Source do
  begin
    DestItem := Add(TPascalTypeTableClass(SourceItem.ClassType));
    DestItem.Assign(SourceItem);
  end;
end;

constructor TPascalTypeTableInterfaceList<T>.Create(AParent: TCustomPascalTypeTable);
begin
  inherited Create;
  FParent := AParent;
end;

{ TCustomPascalTypeTable }

constructor TCustomPascalTypeTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited Create;
  FParent := AParent;
end;

(*
constructor TCustomPascalTypeTable.CreateHidden;
begin
end;
*)

function TCustomPascalTypeTable.GetFontFace: IPascalTypeFontFace;
begin
  if (Parent <> nil) then
    Result := Parent.FontFace
  else
    Result := nil;
end;

procedure TCustomPascalTypeTable.Assign(Source: TPersistent);
begin
  if (Source is TCustomPascalTypeTable) then
  begin
    // Backstop
  end else
    inherited;
end;

procedure TCustomPascalTypeTable.Changed;
begin
  // nothing here yet
end;


{ TXCustomPascalTypeInterfaceTable }

procedure TXCustomPascalTypeInterfaceTable.Changed;
begin
  inherited;
  // if FFontFace is IPascalTypeFontFaceChange
  // then (FFontFace as IPascalTypeFontFaceChange).Changed;
end;

constructor TXCustomPascalTypeInterfaceTable.Create(const AFontFace: IPascalTypeFontFace);
begin
  inherited Create;
  FFontFace := AFontFace;
end;

{ TCustomPascalTypeNamedTable }

function TCustomPascalTypeNamedTable.GetInternalTableType: TTableType;
begin
  Result := GetTableType;
end;

procedure TCustomPascalTypeNamedTable.WriteTableTypeToStream(Stream: TStream);
var
  TableName: TTableType;
begin
  // store chunk name to memory stream
  TableName := TableType;
  Stream.Write(TableName, 4);
end;

{ ValueReader }

class procedure ValueReader.Copy(ASource, ADest: PWord; ACount: integer);
begin
  Copy<Word>(ASource^, ADest^, ACount * SizeOf(Word));
end;

class procedure ValueReader.Copy<T>(const ASource; var ADest: T; ASize: integer);
begin
  Move(ASource, ADest, ASize);
  PostProcess(ADest, ASize, SizeOf(T));
end;

class procedure ValueReader.PostProcess(var ABuffer; ASize, AElementSize: integer);
begin
end;

class procedure ValueReader.Read<T>(AStream: TStream; var Buffer; Count: integer);
var
  BufferSize: Int64;
  ReadSize: Int64;
begin
  BufferSize := SizeOf(T) * Count;
  ReadSize := AStream.Read(Buffer, BufferSize);
{$IFDEF ValidateEveryReadOperation}
  if ReadSize <> BufferSize then
    raise EPascalTypeStremReadError.Create(RCStrStreamReadError);
{$ENDIF}
  PostProcess(Buffer, ReadSize, SizeOf(T));
end;

class procedure ValueReader.Read<T>(AStream: TStream; var Buffer: T);
begin
  Read<T>(AStream, Buffer, 1);
end;

class procedure ValueReader.ReadByte(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Byte>(AStream, Buffer, Count);
end;

class function ValueReader.ReadByte(AStream: TStream): Byte;
begin
  Read(AStream, Result);
end;

class procedure ValueReader.ReadCardinal(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Cardinal>(AStream, Buffer, Count);
end;

class function ValueReader.ReadCardinal(AStream: TStream): Cardinal;
begin
  Read(AStream, Result);
end;

class procedure ValueReader.ReadInt64(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Int64>(AStream, Buffer, Count);
end;

class function ValueReader.ReadInt64(AStream: TStream): Int64;
begin
  Read(AStream, Result);
end;

class procedure ValueReader.ReadInteger(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Integer>(AStream, Buffer, Count);
end;

class function ValueReader.ReadInteger(AStream: TStream): Integer;
begin
  Read(AStream, Result);
end;

class procedure ValueReader.ReadShortInt(AStream: TStream; var Buffer; Count: integer);
begin
  Read<ShortInt>(AStream, Buffer, Count);
end;

class function ValueReader.ReadShortInt(AStream: TStream): ShortInt;
begin
  Read(AStream, Result);
end;

class procedure ValueReader.ReadSmallInt(AStream: TStream; var Buffer; Count: integer);
begin
  Read<SmallInt>(AStream, Buffer, Count);
end;

class function ValueReader.ReadSmallInt(AStream: TStream): SmallInt;
begin
  Read(AStream, Result);
end;

class procedure ValueReader.ReadUInt64(AStream: TStream; var Buffer; Count: integer);
begin
  Read<UInt64>(AStream, Buffer, Count);
end;

class function ValueReader.ReadUInt64(AStream: TStream): UInt64;
begin
  Read(AStream, Result);
end;

class procedure ValueReader.ReadWord(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Word>(AStream, Buffer, Count);
end;

class function ValueReader.ReadWord(AStream: TStream): Word;
begin
  Read(AStream, Result);
end;

{ BigEndianValueReader }

class procedure BigEndianValueReader.PostProcess(var ABuffer; ASize, AElementSize: integer);
var
  p: PByte;
begin
  p := @ABuffer;
  while (ASize >= AElementSize) do
  begin
    case AElementSize of
      1: ;
      2: PWord(p)^ := Swap16(PWord(p)^);
      4: PCardinal(p)^ := Swap32(PCardinal(p)^);
      8: PInt64(p)^ := Swap64(PInt64(p)^);
    else
      Assert(False);
    end;
    Inc(p, AElementSize);
    Dec(ASize, AElementSize);
  end;
end;

end.
