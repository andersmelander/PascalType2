unit PascalType.Classes;

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
  PascalType.Types;

type
  // A GlyphID
  TGlyphID = Word;
  TGlyphString = TArray<TGlyphID>;
  TGlyphStrings = TArray<TGlyphString>;

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
    function GetTableByTableType(const TableType: TTableType): TCustomPascalTypeNamedTable;
    function GetTableByTableClass(TableClass: TCustomPascalTypeNamedTableClass): TCustomPascalTypeNamedTable;
  end;

  IPascalTypeFontFaceChange = interface(IUnknown)
    ['{4C10BAEF-04DB-42D0-9A6C-5FE155E80AEB}']
    procedure Changed;
  end;


  TCustomPascalTypeTable = class abstract(TInterfacedPersistent)
  private
    FParent: TCustomPascalTypeTable;
  protected
    procedure Changed; virtual;
    function GetFontFace: IPascalTypeFontFace; virtual;
//    constructor CreateHidden;
  public
    constructor Create(AParent: TCustomPascalTypeTable = nil); virtual;

    procedure Assign(Source: TPersistent); override;

    // Most tables don't need to know the size of the data being loaded, but
    // a few do (e.g. 'cvt') so we have to pass the size along if it's known.
    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); virtual; abstract;

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
  EndianValue = class
  protected
    class procedure Process(const ASource; var ADest; ASize, AElementSize: integer); virtual;
  public
    class procedure Read<T>(AStream: TStream; var Buffer: T); overload;
    class procedure Read<T>(AStream: TStream; var Buffer; Count: integer); overload;
    class procedure Write<T>(AStream: TStream; const Buffer: T); overload;
    class procedure Write<T>(AStream: TStream; const Buffer; Count: integer); overload;

    // 8 bit
    class function ReadByte(AStream: TStream): Byte; overload;
    class procedure ReadByte(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class function ReadShortInt(AStream: TStream): ShortInt; overload;
    class procedure ReadShortInt(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class procedure WriteByte(AStream: TStream; AValue: Byte); overload;
    class procedure WriteByte(AStream: TStream; var Buffer; Count: integer); overload;
    class procedure WriteShortInt(AStream: TStream; AValue: ShortInt); overload;
    class procedure WriteShortInt(AStream: TStream; var Buffer; Count: integer); overload;

    // 16 bit
    class function ReadWord(AStream: TStream): Word; overload;
    class procedure ReadWord(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class function ReadSmallInt(AStream: TStream): SmallInt; overload;
    class procedure ReadSmallInt(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class procedure WriteWord(AStream: TStream; AValue: Word); overload;
    class procedure WriteWord(AStream: TStream; var Buffer; Count: integer); overload;
    class procedure WriteSmallInt(AStream: TStream; AValue: SmallInt); overload;
    class procedure WriteSmallInt(AStream: TStream; var Buffer; Count: integer); overload;

    // 24 bit
    class function ReadUInt24(AStream: TStream): Cardinal; overload; virtual;
    class procedure ReadUInt24(AStream: TStream; var Buffer; Count: integer = 1); overload; virtual;

    // 32 bit
    class function ReadCardinal(AStream: TStream): Cardinal; overload;
    class procedure ReadCardinal(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class function ReadInteger(AStream: TStream): Integer; overload;
    class procedure ReadInteger(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class procedure WriteCardinal(AStream: TStream; AValue: Cardinal); overload;
    class procedure WriteCardinal(AStream: TStream; var Buffer; Count: integer); overload;
    class procedure WriteInteger(AStream: TStream; AValue: Integer); overload;
    class procedure WriteInteger(AStream: TStream; var Buffer; Count: integer); overload;

    // 64 bit
    class function ReadUInt64(AStream: TStream): UInt64; overload;
    class procedure ReadUInt64(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class function ReadInt64(AStream: TStream): Int64; overload;
    class procedure ReadInt64(AStream: TStream; var Buffer; Count: integer = 1); overload;
    class procedure WriteUInt64(AStream: TStream; AValue: UInt64); overload;
    class procedure WriteUInt64(AStream: TStream; var Buffer; Count: integer); overload;
    class procedure WriteInt64(AStream: TStream; AValue: Int64); overload;
    class procedure WriteInt64(AStream: TStream; var Buffer; Count: Int64); overload;

    class procedure Copy<T>(const ASource; var ADest: T; ASize: integer); overload;
    class procedure Copy(ASource, ADest: PWord; ACount: integer); overload;
  end;

  BigEndianValue = class(EndianValue)
  protected
    class procedure Process(const ASource; var ADest; ASize, AElementSize: integer); override;
  public
    // 24 bit
    class function ReadUInt24(AStream: TStream): Cardinal; overload; override;
    class procedure ReadUInt24(AStream: TStream; var Buffer; Count: integer = 1); overload; override;
  end;

implementation

uses
  PascalType.Math,
  PascalType.ResourceStrings;

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

{ EndianValue }

class procedure EndianValue.Copy(ASource, ADest: PWord; ACount: integer);
begin
  Copy<Word>(ASource^, ADest^, ACount * SizeOf(Word));
end;

class procedure EndianValue.Copy<T>(const ASource; var ADest: T; ASize: integer);
begin
  Process(ADest, ASize, ASize, SizeOf(T));
end;

class procedure EndianValue.Process(const ASource; var ADest; ASize, AElementSize: integer);
begin
  Move(ASource, ADest, ASize);
end;

class procedure EndianValue.Write<T>(AStream: TStream; const Buffer: T);
begin
  Write<T>(AStream, Buffer, 1);
end;

class procedure EndianValue.Write<T>(AStream: TStream; const Buffer; Count: integer);
var
  p: ^T;
  Value: T;
begin
  p := @Buffer;
  while (Count > 0) do
  begin
    Process(p^, Value, SizeOf(T), SizeOf(T));
    AStream.Write(Value, SizeOf(T));
    Inc(p);
    Dec(Count);
  end;
end;

class procedure EndianValue.WriteByte(AStream: TStream; AValue: Byte);
begin
  Write(AStream, AValue);
end;

class procedure EndianValue.WriteByte(AStream: TStream; var Buffer; Count: integer);
begin
  Write<Byte>(AStream, Buffer, Count);
end;

class procedure EndianValue.WriteShortInt(AStream: TStream; AValue: ShortInt);
begin
  Write(AStream, AValue);
end;

class procedure EndianValue.WriteShortInt(AStream: TStream; var Buffer; Count: integer);
begin
  Write<ShortInt>(AStream, Buffer, Count);
end;

class procedure EndianValue.WriteSmallInt(AStream: TStream; AValue: SmallInt);
begin
  Write(AStream, AValue);
end;

class procedure EndianValue.WriteSmallInt(AStream: TStream; var Buffer; Count: integer);
begin
  Write<SmallInt>(AStream, Buffer, Count);
end;

class procedure EndianValue.WriteWord(AStream: TStream; AValue: Word);
begin
  Write(AStream, AValue);
end;

class procedure EndianValue.WriteWord(AStream: TStream; var Buffer; Count: integer);
begin
  Write<Word>(AStream, Buffer, Count);
end;

class procedure EndianValue.WriteCardinal(AStream: TStream; AValue: Cardinal);
begin
  Write(AStream, AValue);
end;

class procedure EndianValue.WriteCardinal(AStream: TStream; var Buffer; Count: integer);
begin
  Write<Cardinal>(AStream, Buffer, Count);
end;

class procedure EndianValue.WriteInteger(AStream: TStream; AValue: Integer);
begin
  Write(AStream, AValue);
end;

class procedure EndianValue.WriteInteger(AStream: TStream; var Buffer; Count: integer);
begin
  Write<Integer>(AStream, Buffer, Count);
end;

class procedure EndianValue.WriteUInt64(AStream: TStream; AValue: UInt64);
begin
  Write(AStream, AValue);
end;

class procedure EndianValue.WriteUInt64(AStream: TStream; var Buffer; Count: integer);
begin
  Write<UInt64>(AStream, Buffer, Count);
end;

class procedure EndianValue.WriteInt64(AStream: TStream; AValue: Int64);
begin
  Write(AStream, AValue);
end;

class procedure EndianValue.WriteInt64(AStream: TStream; var Buffer; Count: Int64);
begin
  Write<Int64>(AStream, Buffer, Count);
end;

class procedure EndianValue.Read<T>(AStream: TStream; var Buffer; Count: integer);
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
  Process(Buffer, Buffer, ReadSize, SizeOf(T));
end;

class procedure EndianValue.Read<T>(AStream: TStream; var Buffer: T);
begin
  Read<T>(AStream, Buffer, 1);
end;

class procedure EndianValue.ReadByte(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Byte>(AStream, Buffer, Count);
end;

class function EndianValue.ReadByte(AStream: TStream): Byte;
begin
  Read(AStream, Result);
end;

type
  UInt24 = array[0..2] of Byte;
  PUInt24 = ^UInt24;

class procedure EndianValue.ReadUInt24(AStream: TStream; var Buffer; Count: integer);
var
  p: PUInt24;
begin
  p := @Buffer;
  while (Count > 0) do
  begin
    AStream.Read(p^, SizeOf(UInt24));
    Inc(p);
    Dec(Count);
  end;
end;

class function EndianValue.ReadUInt24(AStream: TStream): Cardinal;
var
  Value: UInt24;
begin
  ReadUInt24(AStream, Value);
  Result := Value[0] or (Value[1] shl 8) or (Value[2] shl 16);
end;

class procedure EndianValue.ReadCardinal(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Cardinal>(AStream, Buffer, Count);
end;

class function EndianValue.ReadCardinal(AStream: TStream): Cardinal;
begin
  Read(AStream, Result);
end;

class procedure EndianValue.ReadInt64(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Int64>(AStream, Buffer, Count);
end;

class function EndianValue.ReadInt64(AStream: TStream): Int64;
begin
  Read(AStream, Result);
end;

class procedure EndianValue.ReadInteger(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Integer>(AStream, Buffer, Count);
end;

class function EndianValue.ReadInteger(AStream: TStream): Integer;
begin
  Read(AStream, Result);
end;

class procedure EndianValue.ReadShortInt(AStream: TStream; var Buffer; Count: integer);
begin
  Read<ShortInt>(AStream, Buffer, Count);
end;

class function EndianValue.ReadShortInt(AStream: TStream): ShortInt;
begin
  Read(AStream, Result);
end;

class procedure EndianValue.ReadSmallInt(AStream: TStream; var Buffer; Count: integer);
begin
  Read<SmallInt>(AStream, Buffer, Count);
end;

class function EndianValue.ReadSmallInt(AStream: TStream): SmallInt;
begin
  Read(AStream, Result);
end;

class procedure EndianValue.ReadUInt64(AStream: TStream; var Buffer; Count: integer);
begin
  Read<UInt64>(AStream, Buffer, Count);
end;

class function EndianValue.ReadUInt64(AStream: TStream): UInt64;
begin
  Read(AStream, Result);
end;

class procedure EndianValue.ReadWord(AStream: TStream; var Buffer; Count: integer);
begin
  Read<Word>(AStream, Buffer, Count);
end;

class function EndianValue.ReadWord(AStream: TStream): Word;
begin
  Read(AStream, Result);
end;

{ BigEndianValue }

class procedure BigEndianValue.Process(const ASource; var ADest; ASize, AElementSize: integer);
var
  pSource, pDest: PByte;
begin
  pSource := @ASource;
  pDest := @ADest;
  while (ASize >= AElementSize) do
  begin
    case AElementSize of
      1: ;
      2: PWord(pDest)^ := Swap16(PWord(pSource)^);
      4: PCardinal(pDest)^ := Swap32(PCardinal(pSource)^);
      8: PInt64(pDest)^ := Swap64(PInt64(pSource)^);
    else
      Assert(False);
    end;
    Inc(pSource, AElementSize);
    Inc(pDest, AElementSize);
    Dec(ASize, AElementSize);
  end;
end;

class procedure BigEndianValue.ReadUInt24(AStream: TStream; var Buffer; Count: integer);
var
  p: PUInt24;
  Temp: Byte;
begin
  p := @Buffer;
  while (Count > 0) do
  begin
    AStream.Read(p^, SizeOf(UInt24));
    Temp := p^[2];
    p^[2] := p^[0];
    p^[0] := Temp;
    Inc(p);
    Dec(Count);
  end;
end;

class function BigEndianValue.ReadUInt24(AStream: TStream): Cardinal;
var
  Value: UInt24;
begin
  ReadUInt24(AStream, Value);
  Result := Value[2] or (Value[1] shl 8) or (Value[0] shl 16);
end;

end.
