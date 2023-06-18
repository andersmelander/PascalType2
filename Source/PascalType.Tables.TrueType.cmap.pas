unit PascalType.Tables.TrueType.cmap;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'cmap' table type                                     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Version: MPL 1.1 or LGPL 2.1 with linking exception                        //
//                                                                            //
// The contents of this file are subject to the Mozilla Public License        //
// Version 1.1 (the "License"); you may not use this file except in           //
// compliance with the License. You may obtain a copy of the License at       //
// http://www.mozilla.org/MPL/                                                //
//                                                                            //
// Software distributed under the License is distributed on an "AS IS"        //
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the    //
// License for the specific language governing rights and limitations under   //
// the License.                                                               //
//                                                                            //
// Alternatively, the contents of this file may be used under the terms of    //
// the Free Pascal modified version of the GNU Lesser General Public          //
// License Version 2.1 (the "FPC modified LGPL License"), in which case the   //
// provisions of this license are applicable instead of those above.          //
// Please see the file LICENSE.txt for additional information concerning      //
// this license.                                                              //
//                                                                            //
// The code is part of the PascalType Project                                 //
//                                                                            //
// The initial developer of this code is Christian-W. Budde                   //
//                                                                            //
// Portions created by Christian-W. Budde are Copyright (C) 2010-2021         //
// by Christian-W. Budde. All Rights Reserved.                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

{$I PT_Compiler.inc}

uses
  Generics.Collections,
  Classes,
  PT_Types,
  PT_Classes,
  PascalType.Unicode;

//------------------------------------------------------------------------------
//
//              TCustomPascalTypeCharacterMap
//
//------------------------------------------------------------------------------
// Mapping sub table base class
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap
//------------------------------------------------------------------------------
type
  // 'cmap' tables
  TCustomPascalTypeCharacterMap = class abstract(TCustomPascalTypeTable)
  protected
    class function GetFormat: Word; virtual; abstract;
  public
    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; virtual; abstract;

    property Format: Word read GetFormat;
  end;

  TPascalTypeCharacterMapClass = class of TCustomPascalTypeCharacterMap;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeCharacterMapDirectory
//
//------------------------------------------------------------------------------
// Character to Glyph Index Mapping Table - Base class
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap
//------------------------------------------------------------------------------
type
  TCustomPascalTypeCharacterMapDirectory = class abstract(TCustomPascalTypeTable)
  private
    FCharacterMap: TCustomPascalTypeCharacterMap;
    FEncodingID  : Word;
    function GetEncodingIDAsWord: Word;
    procedure SetEncodingIDAsWord(const Value: Word);
  protected
    function GetPlatformID: TPlatformID; virtual; abstract;
    procedure EncodingIDChanged; virtual;
    property PlatformSpecificID: Word read GetEncodingIDAsWord write SetEncodingIDAsWord;
  public
    constructor Create(EncodingID: Word); reintroduce; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; virtual;

    property PlatformID: TPlatformID read GetPlatformID;
    property EncodingID: Word read GetEncodingIDAsWord;
    property CharacterMap: TCustomPascalTypeCharacterMap read FCharacterMap;
  end;

  TPascalTypeCharacterMapDirectoryClass = class of TCustomPascalTypeCharacterMapDirectory;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapUnicodeDirectory
//
//------------------------------------------------------------------------------
// Character to Glyph Index Mapping Table - Unicode platform
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#unicode-platform-platform-id--0
//------------------------------------------------------------------------------
type
  TPascalTypeCharacterMapUnicodeDirectory = class(TCustomPascalTypeCharacterMapDirectory)
  private
    procedure SetEncodingID(const Value: TUnicodeEncodingID);
    function GetEncodingID: TUnicodeEncodingID;
  protected
    function GetPlatformID: TPlatformID; override;
  public
    property PlatformSpecificID: TUnicodeEncodingID read GetEncodingID write SetEncodingID;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapMacintoshDirectory
//
//------------------------------------------------------------------------------
// Character to Glyph Index Mapping Table - Macintosh platform
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#macintosh-platform-platform-id--1
//------------------------------------------------------------------------------
type
  TPascalTypeCharacterMapMacintoshDirectory = class(TCustomPascalTypeCharacterMapDirectory)
  private
    procedure SetEncodingID(const Value: TAppleEncodingID);
    function GetEncodingID: TAppleEncodingID;
  protected
    function GetPlatformID: TPlatformID; override;
  public
    property PlatformSpecificID: TAppleEncodingID read GetEncodingID write SetEncodingID;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapMicrosoftDirectory
//
//------------------------------------------------------------------------------
// Character to Glyph Index Mapping Table - Windows platform
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#windows-platform-platform-id--3
//------------------------------------------------------------------------------
type
  TPascalTypeCharacterMapMicrosoftDirectory = class(TCustomPascalTypeCharacterMapDirectory)
  private
    procedure SetEncodingID(const Value: TMicrosoftEncodingID);
    function GetEncodingID: TMicrosoftEncodingID;
  protected
    function GetPlatformID: TPlatformID; override;
  public
    property PlatformSpecificID: TMicrosoftEncodingID read GetEncodingID write SetEncodingID;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapDirectoryGenericEntry
//
//------------------------------------------------------------------------------
// Character to Glyph Index Mapping Table - Custom platform and OTF Windows NT
// compatibility mapping
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#custom-platform-platform-id--4-and-otf-windows-nt-compatibility-mapping
//------------------------------------------------------------------------------
type
  TPascalTypeCharacterMapDirectoryGenericEntry = class(TCustomPascalTypeCharacterMapDirectory)
  protected
    function GetPlatformID: TPlatformID; override;
  public
    property PlatformSpecificID;
  end;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeCharacterMap
//
//------------------------------------------------------------------------------
// Character to Glyph Index Mapping Table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap
//------------------------------------------------------------------------------
type
  TPascalTypeCharacterMapTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: Word; // Version number (Set to zero)
    FMaps   : TList<TCustomPascalTypeCharacterMapDirectory>;
    function GetCharacterMapSubtableCount: Word;
    function GetCharacterMapSubtable(Index: Integer): TCustomPascalTypeCharacterMapDirectory;
    procedure SetVersion(const Value: Word);
  protected
    procedure CharacterMapDirectoryChanged; virtual;
  public
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property CharacterMapSubtableCount: Word read GetCharacterMapSubtableCount;
    property CharacterMapSubtable[Index: Integer]: TCustomPascalTypeCharacterMapDirectory read GetCharacterMapSubtable;
  end;


//------------------------------------------------------------------------------
//
//              Character map registration
//
//------------------------------------------------------------------------------
procedure RegisterPascalTypeCharacterMap(CharacterMapClass: TPascalTypeCharacterMapClass);
procedure RegisterPascalTypeCharacterMaps(CharacterMapClasses: array of TPascalTypeCharacterMapClass);
function FindPascalTypeCharacterMapByFormat(Format: Word): TPascalTypeCharacterMapClass;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_Tables,
  PT_ResourceStrings;

var
  GCharacterMapClasses: array of TPascalTypeCharacterMapClass;

resourcestring
  RCStrUnknownCharacterMap = 'Unknown character map (%d)';
  RCStrCharacterMapNotSet = 'Character map not set properly!';

function IsPascalTypeCharacterMapRegistered(CharacterMapClass: TPascalTypeCharacterMapClass): Boolean;
var
  CharacterMapClassIndex: Integer;
begin
  Result := False;
  for CharacterMapClassIndex := 0 to High(GCharacterMapClasses) do
    if GCharacterMapClasses[CharacterMapClassIndex] = CharacterMapClass then
      Exit(True);
end;

function CheckCharacterMapClassesValid: Boolean;
var
  CharacterMapClassBaseIndex: Integer;
  CharacterMapClassIndex    : Integer;
begin
  Result := True;
  for CharacterMapClassBaseIndex := 0 to High(GCharacterMapClasses) do
    for CharacterMapClassIndex := CharacterMapClassBaseIndex + 1 to High(GCharacterMapClasses) do
      if GCharacterMapClasses[CharacterMapClassBaseIndex] = GCharacterMapClasses[CharacterMapClassIndex] then
        Exit(False);
end;

procedure RegisterPascalTypeCharacterMap(CharacterMapClass: TPascalTypeCharacterMapClass);
begin
  Assert(IsPascalTypeCharacterMapRegistered(CharacterMapClass) = False);
  SetLength(GCharacterMapClasses, Length(GCharacterMapClasses) + 1);
  GCharacterMapClasses[High(GCharacterMapClasses)] := CharacterMapClass;
end;

procedure RegisterPascalTypeCharacterMaps(CharacterMapClasses: array of TPascalTypeCharacterMapClass);
var
  CharacterMapClassIndex: Integer;
begin
  SetLength(GCharacterMapClasses, Length(GCharacterMapClasses) + Length(CharacterMapClasses));
  for CharacterMapClassIndex := 0 to High(CharacterMapClasses) do
    GCharacterMapClasses[Length(GCharacterMapClasses) - Length(CharacterMapClasses) + CharacterMapClassIndex] :=
      CharacterMapClasses[CharacterMapClassIndex];
  Assert(CheckCharacterMapClassesValid);
end;

function FindPascalTypeCharacterMapByFormat(Format: Word): TPascalTypeCharacterMapClass;
var
  CharacterMapClassIndex: Integer;
begin
  Result := nil;
  for CharacterMapClassIndex := 0 to High(GCharacterMapClasses) do
    if GCharacterMapClasses[CharacterMapClassIndex].GetFormat = Format then
    begin
      Result := GCharacterMapClasses[CharacterMapClassIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown Table Class: ' + TableType);
end;

//------------------------------------------------------------------------------
//
//              TCustomPascalTypeCharacterMap
//
//------------------------------------------------------------------------------
procedure TCustomPascalTypeCharacterMap.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  if (BigEndianValueReader.ReadWord(Stream) <> Format) then
    raise Exception.Create('CharacterMap format mismatch');
end;

procedure TCustomPascalTypeCharacterMap.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedWord(Stream, Format);
end;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeCharacterMapDirectory
//
//------------------------------------------------------------------------------
constructor TCustomPascalTypeCharacterMapDirectory.Create(EncodingID: Word);
begin
  inherited Create;
  FEncodingID := EncodingID;
end;

destructor TCustomPascalTypeCharacterMapDirectory.Destroy;
begin
  FreeAndNil(FCharacterMap);

  inherited;
end;

procedure TCustomPascalTypeCharacterMapDirectory.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomPascalTypeCharacterMapDirectory then
  begin
    FEncodingID := TCustomPascalTypeCharacterMapDirectory(Source).FEncodingID;

    // match character map type
    if (FCharacterMap = nil) or (FCharacterMap.ClassType <> TCustomPascalTypeCharacterMapDirectory(Source).FCharacterMap.ClassType) then
    begin
      FreeAndNil(FCharacterMap);

      // create new character map
      FCharacterMap := TPascalTypeCharacterMapClass(TCustomPascalTypeCharacterMapDirectory(Source).FCharacterMap.ClassType).Create;
    end;

    // assign character map
    if (FCharacterMap <> nil) then
      FCharacterMap.Assign(TCustomPascalTypeCharacterMapDirectory(Source).FCharacterMap);
  end;
end;

procedure TCustomPascalTypeCharacterMapDirectory.EncodingIDChanged;
begin
  Changed;
end;

function TCustomPascalTypeCharacterMapDirectory.GetEncodingIDAsWord: Word;
begin
  Result := FEncodingID;
end;

function TCustomPascalTypeCharacterMapDirectory.CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer;
begin
  if (FCharacterMap = nil) then
    raise EPascalTypeError.Create(RCStrCharacterMapNotSet);
  Result := FCharacterMap.CharacterToGlyph(ACodePoint);
end;

procedure TCustomPascalTypeCharacterMapDirectory.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  MapFormat : Word;
  MapClass: TPascalTypeCharacterMapClass;
  OldMap  : TCustomPascalTypeCharacterMap;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read format
  MapFormat := BigEndianValueReader.ReadWord(Stream);
  MapClass := FindPascalTypeCharacterMapByFormat(MapFormat);

  if (MapClass = nil) then
    raise EPascalTypeError.CreateFmt(RCStrUnknownCharacterMap, [MapFormat]);

  OldMap := FCharacterMap;
  FCharacterMap := MapClass.Create;
  OldMap.Free;

  if (FCharacterMap <> nil) then
  begin
    Stream.Seek(-SizeOf(Word), soFromCurrent);
    FCharacterMap.LoadFromStream(Stream);
  end;
end;

procedure TCustomPascalTypeCharacterMapDirectory.SaveToStream(Stream: TStream);
begin
  if (FCharacterMap <> nil) then
    FCharacterMap.SaveToStream(Stream);
end;

procedure TCustomPascalTypeCharacterMapDirectory.SetEncodingIDAsWord
  (const Value: Word);
begin
  if Value <> FEncodingID then
  begin
    FEncodingID := Value;
    EncodingIDChanged;
  end;
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapUnicodeDirectory
//
//------------------------------------------------------------------------------
function TPascalTypeCharacterMapUnicodeDirectory.GetEncodingID: TUnicodeEncodingID;
begin
  Result := TUnicodeEncodingID(FEncodingID);
end;

function TPascalTypeCharacterMapUnicodeDirectory.GetPlatformID: TPlatformID;
begin
  Result := piUnicode;
end;

procedure TPascalTypeCharacterMapUnicodeDirectory.SetEncodingID
  (const Value: TUnicodeEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapMacintoshDirectory
//
//------------------------------------------------------------------------------
function TPascalTypeCharacterMapMacintoshDirectory.GetEncodingID: TAppleEncodingID;
begin
  Result := TAppleEncodingID(FEncodingID);
end;

function TPascalTypeCharacterMapMacintoshDirectory.GetPlatformID: TPlatformID;
begin
  Result := piApple;
end;

procedure TPascalTypeCharacterMapMacintoshDirectory.SetEncodingID(const Value: TAppleEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapMicrosoftDirectory
//
//------------------------------------------------------------------------------
function TPascalTypeCharacterMapMicrosoftDirectory.GetEncodingID: TMicrosoftEncodingID;
begin
  Result := TMicrosoftEncodingID(FEncodingID);
end;

function TPascalTypeCharacterMapMicrosoftDirectory.GetPlatformID: TPlatformID;
begin
  Result := piMicrosoft;
end;

procedure TPascalTypeCharacterMapMicrosoftDirectory.SetEncodingID(const Value: TMicrosoftEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapDirectoryGenericEntry
//
//------------------------------------------------------------------------------
function TPascalTypeCharacterMapDirectoryGenericEntry.GetPlatformID: TPlatformID;
begin
  Result := piCustom;
end;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeCharacterMap
//
//------------------------------------------------------------------------------
destructor TPascalTypeCharacterMapTable.Destroy;
begin
  FMaps.Free;
  inherited;
end;

procedure TPascalTypeCharacterMapTable.Assign(Source: TPersistent);
var
  i: Integer;
  MapClass: TPascalTypeCharacterMapDirectoryClass;
  SourceMap: TCustomPascalTypeCharacterMapDirectory;
  Map: TCustomPascalTypeCharacterMapDirectory;
begin
  inherited;
  if Source is TPascalTypeCharacterMapTable then
  begin
    FVersion := TPascalTypeCharacterMapTable(Source).FVersion;

    if (FMaps <> nil) then
      FMaps.Clear;

    // set length of map array
    if (TPascalTypeCharacterMapTable(Source).CharacterMapSubtableCount > 0) then
    begin
      if (FMaps = nil) then
        FMaps := TObjectList<TCustomPascalTypeCharacterMapDirectory>.Create;
      FMaps.Capacity := TPascalTypeCharacterMapTable(Source).CharacterMapSubtableCount;

      for i := 0 to TPascalTypeCharacterMapTable(Source).CharacterMapSubtableCount - 1 do
      begin
        SourceMap := TPascalTypeCharacterMapTable(Source).CharacterMapSubtable[i];
        MapClass := TPascalTypeCharacterMapDirectoryClass(SourceMap.ClassType);

        Map := MapClass.Create(SourceMap.EncodingID);
        FMaps.Add(Map);

        Map.Assign(SourceMap);
      end;
    end;
  end;
end;

function TPascalTypeCharacterMapTable.GetCharacterMapSubtable(Index: Integer): TCustomPascalTypeCharacterMapDirectory;
begin
  if (FMaps = nil) or (Index < 0) or (Index > FMaps.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FMaps[Index];
end;

function TPascalTypeCharacterMapTable.GetCharacterMapSubtableCount: Word;
begin
  if (FMaps <> nil) then
    Result := FMaps.Count
  else
    Result := 0;
end;

class function TPascalTypeCharacterMapTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'cmap';
end;

procedure TPascalTypeCharacterMapTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos  : Int64;
  i: Integer;
  PlatformID: Word;
  EncodingID: Word;
  Offsets: array of Cardinal;
  Map: TCustomPascalTypeCharacterMapDirectory;
begin
  // store stream start position
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size (table with at least one entry)
  if Stream.Position + 4*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read Version
  FVersion := BigEndianValueReader.ReadWord(Stream);

  // check version
  if (FVersion <> 0) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read subtable count
  SetLength(Offsets, BigEndianValueReader.ReadWord(Stream));

  // check (minimum) table size
  if Stream.Position + Length(Offsets) * (2 * SizeOf(Word) + SizeOf(Cardinal)) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  if (FMaps <> nil) then
    FMaps.Clear;

  if (Length(Offsets) > 0) then
  begin
    if (FMaps = nil) then
      FMaps := TObjectList<TCustomPascalTypeCharacterMapDirectory>.Create;

    FMaps.Capacity := Length(Offsets);

    // read directory entry
    for i := 0 to High(Offsets) do
    begin
      // read Platform ID
      PlatformID := BigEndianValueReader.ReadWord(Stream);

      // read encoding ID
      EncodingID := BigEndianValueReader.ReadWord(Stream);

      // create character map based on encoding
      case PlatformID of
        0:
          Map := TPascalTypeCharacterMapUnicodeDirectory.Create(EncodingID);
        1:
          Map := TPascalTypeCharacterMapMacintoshDirectory.Create(EncodingID);
        3:
          Map := TPascalTypeCharacterMapMicrosoftDirectory.Create(EncodingID);
      else
        Map := TPascalTypeCharacterMapDirectoryGenericEntry.Create(EncodingID);
      end;

      FMaps.Add(Map);

      // read and save offset
      Offsets[i] := StartPos + BigEndianValueReader.ReadCardinal(Stream);
    end;

    // load character map entries from stream
    for i := 0 to High(Offsets) do
    begin
      Stream.Position := Offsets[i];
      FMaps[i].LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeCharacterMapTable.SaveToStream(Stream: TStream);
var
  StartPos : Int64;
  DirIndex : Integer;
  Directory: array of Cardinal;
begin
  // store stream start position
  StartPos := Stream.Position;

  inherited;

  // write format type
  WriteSwappedWord(Stream, FVersion);

  // write directory entry count
  WriteSwappedWord(Stream, CharacterMapSubtableCount);

  if (CharacterMapSubtableCount > 0) then
  begin
    // offset directory
    Stream.Seek(soFromCurrent, (2*SizeOf(Word)+SizeOf(Cardinal)) * CharacterMapSubtableCount);

    // build directory (to be written later) and write data
    SetLength(Directory, FMaps.Count);

    for DirIndex := 0 to FMaps.Count-1 do
    begin
      Directory[DirIndex] := Cardinal(Stream.Position - StartPos);
      FMaps[DirIndex].SaveToStream(Stream);
    end;

    // locate directory
    Stream.Position := StartPos + 4;

    for DirIndex := 0 to FMaps.Count-1 do
    begin
      // write format
      WriteSwappedWord(Stream, Word(FMaps[DirIndex].PlatformID));

      // write encoding ID
      WriteSwappedWord(Stream, FMaps[DirIndex].EncodingID);

      // write offset
      WriteSwappedCardinal(Stream, Directory[DirIndex]);
    end;
  end;
end;

procedure TPascalTypeCharacterMapTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    CharacterMapDirectoryChanged;
  end;
end;

procedure TPascalTypeCharacterMapTable.CharacterMapDirectoryChanged;
begin
  Changed;
end;


initialization

  RegisterPascalTypeTable(TPascalTypeCharacterMapTable);

end.
