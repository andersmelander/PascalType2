unit PascalType.Tables.TrueType.name;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'name' table type                                     //
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
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables;

type
  TCustomTrueTypeFontNamePlatform = class(TCustomPascalTypeTable)
  private
    FEncodingID: Word; // Platform-specific encoding identifier.
    FLanguageID: Word; // Language identifier.
    FNameID    : TNameID; // Name identifiers.
    FNameString: WideString;
    function GetEncodingIDAsWord: Word;
    procedure SetEncodingIDAsWord(const Value: Word);
  protected

    function GetPlatformID: TPlatformID; virtual; abstract;
    procedure EncodingIDChanged; virtual;

    property PlatformSpecificID: Word read GetEncodingIDAsWord write SetEncodingIDAsWord;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word);virtual; abstract;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Name: WideString read FNameString;
    property NameID: TNameID read FNameID;
    property PlatformID: TPlatformID read GetPlatformID;
    property LanguageID: Word read FLanguageID;
  end;

  TTrueTypeFontNamePlatformClass = class of TCustomTrueTypeFontNamePlatform;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontNamePlatformUnicode
//
//------------------------------------------------------------------------------
type
  TTrueTypeFontNamePlatformUnicode = class(TCustomTrueTypeFontNamePlatform)
  private
    procedure SetEncodingID(const Value: TUnicodeEncodingID);
    function GetEncodingID: TUnicodeEncodingID;
  protected
    function GetPlatformID: TPlatformID; override;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word); override;

    property PlatformSpecificID: TUnicodeEncodingID read GetEncodingID write SetEncodingID;
  end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontNamePlatformApple
//
//------------------------------------------------------------------------------
type
  TTrueTypeFontNamePlatformApple = class(TCustomTrueTypeFontNamePlatform)
  private
    function GetEncodingID: TAppleEncodingID;
    procedure SetEncodingID(const Value: TAppleEncodingID);
  protected
    function GetPlatformID: TPlatformID; override;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word); override;

    property PlatformSpecificID: TAppleEncodingID read GetEncodingID write SetEncodingID;
  end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontNamePlatformMicrosoft
//
//------------------------------------------------------------------------------
type
  TTrueTypeFontNamePlatformMicrosoft = class(TCustomTrueTypeFontNamePlatform)
  private
    function GetEncodingID: TMicrosoftEncodingID;
    procedure SetEncodingID(const Value: TMicrosoftEncodingID);
  protected
    function GetPlatformID: TPlatformID; override;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word); override;

    property PlatformSpecificID: TMicrosoftEncodingID read GetEncodingID write SetEncodingID;
  end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontNamePlatformISO
//
//------------------------------------------------------------------------------
type
  TTrueTypeFontNamePlatformISO = class(TCustomTrueTypeFontNamePlatform)
  protected
    function GetPlatformID: TPlatformID; override;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word); override;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeNameTable
//
//------------------------------------------------------------------------------
// name — Naming Table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/name
// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6name.html
//------------------------------------------------------------------------------
type
  TPascalTypeNameTable = class(TCustomPascalTypeNamedTable)
  private
    FFormat       : Word; // Format selector. Set to 0.
    FNameSubTables: TPascalTypeTableList<TCustomTrueTypeFontNamePlatform>;
    procedure SetFormat(const Value: Word);
    function GetNameSubTable(Index: Word): TCustomTrueTypeFontNamePlatform;
    function GetNameSubTableCount: Word;
  protected
    procedure FormatChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable = nil); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Format: Word read FFormat write SetFormat;
    property NameSubTableCount: Word read GetNameSubTableCount;
    property NameSubTable[Index: Word]: TCustomTrueTypeFontNamePlatform read GetNameSubTable;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.ResourceStrings;


//------------------------------------------------------------------------------
//              TCustomTrueTypeFontNamePlatform
//------------------------------------------------------------------------------
procedure TCustomTrueTypeFontNamePlatform.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomTrueTypeFontNamePlatform then
  begin
    FEncodingID := TCustomTrueTypeFontNamePlatform(Source).FEncodingID;
    FLanguageID := TCustomTrueTypeFontNamePlatform(Source).FLanguageID;
    FNameID := TCustomTrueTypeFontNamePlatform(Source).FNameID;
    FNameString := TCustomTrueTypeFontNamePlatform(Source).FNameString;
  end;
end;

function TCustomTrueTypeFontNamePlatform.GetEncodingIDAsWord: Word;
begin
  Result := FEncodingID;
end;

procedure TCustomTrueTypeFontNamePlatform.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FEncodingID := BigEndianValue.ReadWord(Stream);
  FLanguageID := BigEndianValue.ReadWord(Stream);
  FNameID := TNameID(BigEndianValue.ReadWord(Stream));
end;

procedure TCustomTrueTypeFontNamePlatform.SaveToStream(Stream: TStream);
begin
  BigEndianValue.WriteWord(Stream, FEncodingID);
  BigEndianValue.WriteWord(Stream, FLanguageID);
  BigEndianValue.WriteWord(Stream, Word(FNameID));
end;

procedure TCustomTrueTypeFontNamePlatform.SetEncodingIDAsWord(const Value: Word);
begin
  if Value <> FEncodingID then
  begin
    FEncodingID := Value;
    EncodingIDChanged;
  end;
end;

procedure TCustomTrueTypeFontNamePlatform.EncodingIDChanged;
begin
  Changed;
end;


//------------------------------------------------------------------------------
//              TTrueTypeFontNamePlatformUnicode
//------------------------------------------------------------------------------
function TTrueTypeFontNamePlatformUnicode.GetPlatformID: TPlatformID;
begin
  Result := piUnicode;
end;

procedure TTrueTypeFontNamePlatformUnicode.ReadStringFromStream(Stream: TStream; Length: Word);
var
  i: Integer;
begin
  SetLength(FNameString, Length div 2);

  for i := 1 to High(FNameString) do
    FNameString[i] := WideChar(BigEndianValue.ReadWord(Stream));
end;

function TTrueTypeFontNamePlatformUnicode.GetEncodingID: TUnicodeEncodingID;
begin
  Result := TUnicodeEncodingID(FEncodingID);
end;

procedure TTrueTypeFontNamePlatformUnicode.SetEncodingID(const Value: TUnicodeEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


//------------------------------------------------------------------------------
//              TTrueTypeFontNamePlatformApple
//------------------------------------------------------------------------------
function TTrueTypeFontNamePlatformApple.GetPlatformID: TPlatformID;
begin
  Result := piApple;
end;

procedure TTrueTypeFontNamePlatformApple.ReadStringFromStream(Stream: TStream; Length: Word);
var
  sAnsi: AnsiString;
begin
  SetLength(sAnsi, Length);

  if (Length > 0) then
    Stream.Read(sAnsi[1], Length);

  FNameString := string(sAnsi);
end;

function TTrueTypeFontNamePlatformApple.GetEncodingID: TAppleEncodingID;
begin
  Result := TAppleEncodingID(FEncodingID);
end;

procedure TTrueTypeFontNamePlatformApple.SetEncodingID(const Value: TAppleEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


//------------------------------------------------------------------------------
//              TTrueTypeFontNamePlatformMicrosoft
//------------------------------------------------------------------------------
function TTrueTypeFontNamePlatformMicrosoft.GetPlatformID: TPlatformID;
begin
  Result := piMicrosoft;
end;

procedure TTrueTypeFontNamePlatformMicrosoft.ReadStringFromStream(Stream: TStream; Length: Word);
var
  i: Integer;
begin
  SetLength(FNameString, Length div 2);

  for i := 1 to High(FNameString) do
    FNameString[i] := WideChar(BigEndianValue.ReadWord(Stream));
end;

function TTrueTypeFontNamePlatformMicrosoft.GetEncodingID: TMicrosoftEncodingID;
begin
  Result := TMicrosoftEncodingID(FEncodingID);
end;

procedure TTrueTypeFontNamePlatformMicrosoft.SetEncodingID(const Value: TMicrosoftEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


//------------------------------------------------------------------------------
//              TTrueTypeFontNamePlatformISO
//------------------------------------------------------------------------------
function TTrueTypeFontNamePlatformISO.GetPlatformID: TPlatformID;
begin
  Result := piISO;
end;

procedure TTrueTypeFontNamePlatformISO.ReadStringFromStream(Stream: TStream; Length: Word);
var
  sAnsi: AnsiString;
  i: Integer;
begin
  case FEncodingID of
    0:
      begin
        SetLength(sAnsi, Length);

        if (Length > 0) then
          Stream.Read(sAnsi[1], Length);

        FNameString := string(sAnsi);
      end;
    1:
      begin
        SetLength(FNameString, Length div 2);

        for i := 1 to High(FNameString) do
          FNameString[i] := WideChar(BigEndianValue.ReadWord(Stream));
      end;
  else
    raise EPascalTypeError.Create('Unsupported encoding');
  end;
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeNameTable
//
//------------------------------------------------------------------------------
constructor TPascalTypeNameTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FNameSubTables := TPascalTypeTableList<TCustomTrueTypeFontNamePlatform>.Create;
end;

destructor TPascalTypeNameTable.Destroy;
begin
  FNameSubTables.Free;
  inherited;
end;

function TPascalTypeNameTable.GetNameSubTable(Index: Word): TCustomTrueTypeFontNamePlatform;
begin
  Result := FNameSubTables[Index];
end;

function TPascalTypeNameTable.GetNameSubTableCount: Word;
begin
  Result := FNameSubTables.Count;
end;

class function TPascalTypeNameTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'name'
end;

procedure TPascalTypeNameTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeNameTable then
  begin
    FFormat := TPascalTypeNameTable(Source).FFormat;
    FNameSubTables.Assign(TPascalTypeNameTable(Source).FNameSubTables);
  end;
end;

procedure TPascalTypeNameTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  SavePos: Int64;
  StorageOffset: Word;
  Count: Word;
  NameIndex  : Integer;
  StrLength  : Word;
  StrOffset  : Word;
  Value16    : Word;
  PlatformClass: TTrueTypeFontNamePlatformClass;
  SubTable: TCustomTrueTypeFontNamePlatform;
const
  PlatformClasses: array[TPlatformID] of TTrueTypeFontNamePlatformClass = (
    TTrueTypeFontNamePlatformUnicode,
    TTrueTypeFontNamePlatformApple,
    TTrueTypeFontNamePlatformISO,
    TTrueTypeFontNamePlatformMicrosoft,
    nil);
begin
  StartPos := Stream.Position;

  FNameSubTables.Clear;

  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FFormat := BigEndianValue.ReadWord(Stream);

  if not(FFormat in [0..1]) then
    raise EPascalTypeError.Create(RCStrUnknownFormat);

  Count := BigEndianValue.ReadWord(Stream);
  FNameSubTables.Capacity := Count;

  StorageOffset := BigEndianValue.ReadWord(Stream);

  if Stream.Position + Count * 12 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  for NameIndex := 0 to Count-1 do
  begin
    Value16 := BigEndianValue.ReadWord(Stream);

    PlatformClass := PlatformClasses[TPlatformID(Value16)];
    if (PlatformClass = nil) then
      raise EPascalTypeError.CreateFmt(RCStrUnsupportedPlatform, [Value16]);

    SubTable := FNameSubTables.Add(PlatformClass);

    // Load fixed part of name record
    SubTable.LoadFromStream(Stream);

    StrLength := BigEndianValue.ReadWord(Stream);
    StrOffset := BigEndianValue.ReadWord(Stream);

    SavePos := Stream.Position;

    // Position stream to load string
    Stream.Position := StartPos + StorageOffset + StrOffset;

    // Read string from steam
    SubTable.ReadStringFromStream(Stream, StrLength);

    Stream.Position := SavePos;
  end;

  // Naming table version 1 data follows
  if (FFormat > 0) then
  begin
    // ...ignored for now...
  end;
end;

procedure TPascalTypeNameTable.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

procedure TPascalTypeNameTable.SetFormat(const Value: Word);
begin
  if FFormat <> Value then
  begin
    FFormat := Value;
    FormatChanged;
  end;
end;

procedure TPascalTypeNameTable.FormatChanged;
begin
  Changed;
end;


initialization

  PascalTypeTableClasses.RegisterTable(TPascalTypeNameTable);

end.
