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
  PascalType.Types,
  PascalType.Classes,
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
  protected
    function GetPlatformID: TPlatformID; virtual; abstract;
    procedure SetEncodingID(const Value: Word);
    procedure EncodingIDChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable; AEncodingID: Word); reintroduce; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; virtual;

    property PlatformID: TPlatformID read GetPlatformID;
    property EncodingID: Word read FEncodingID;// write SetEncodingID;
    property CharacterMap: TCustomPascalTypeCharacterMap read FCharacterMap;
  end;

  TPascalTypeCharacterMapDirectoryClass = class of TCustomPascalTypeCharacterMapDirectory;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapUnicodeDirectory
//
//------------------------------------------------------------------------------
// Character to Glyph Index Mapping Table - Unicode platform (platform ID = 0)
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
// Character to Glyph Index Mapping Table - Macintosh platform (platform ID = 1)
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#macintosh-platform-platform-id--1
//------------------------------------------------------------------------------
// TODO : Do we even need to support this mapping? I think Apple uses Unicode now and it's obsolete
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
// Character to Glyph Index Mapping Table - Windows platform (platform ID = 3)
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
    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; override;

    property PlatformSpecificID: TMicrosoftEncodingID read GetEncodingID write SetEncodingID;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapDirectoryGenericEntry
//
//------------------------------------------------------------------------------
// Character to Glyph Index Mapping Table - Custom platform (platform ID = 4)
// and OTF Windows NT compatibility mapping
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#custom-platform-platform-id--4-and-otf-windows-nt-compatibility-mapping
//------------------------------------------------------------------------------
type
  TPascalTypeCharacterMapDirectoryGenericEntry = class(TCustomPascalTypeCharacterMapDirectory)
  protected
    function GetPlatformID: TPlatformID; override;
  public
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
  private
    FBestCharacterMap: TCustomPascalTypeCharacterMapDirectory;
  protected
    procedure CharacterMapDirectoryChanged; virtual;
  public
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function GetGlyphByCharacter(ACodePoint: TPascalTypeCodePoint): Integer;

    property Version: Word read FVersion write SetVersion;
    property CharacterMapSubtableCount: Word read GetCharacterMapSubtableCount;
    property CharacterMapSubtable[Index: Integer]: TCustomPascalTypeCharacterMapDirectory read GetCharacterMapSubtable; default;
  end;


//------------------------------------------------------------------------------
//
//              Character map registration
//
//------------------------------------------------------------------------------
type
  PascalTypeCharacterMaps = record
    class procedure RegisterCharacterMap(CharacterMapClass: TPascalTypeCharacterMapClass); static;
    class procedure RegisterCharacterMaps(CharacterMapClasses: array of TPascalTypeCharacterMapClass); static;
    class function FindCharacterMapByFormat(Format: Word): TPascalTypeCharacterMapClass; static;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.Tables,
  PascalType.FontFace.SFNT,
  PascalType.Tables.TrueType.os2,
  PascalType.ResourceStrings;

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

class procedure PascalTypeCharacterMaps.RegisterCharacterMap(CharacterMapClass: TPascalTypeCharacterMapClass);
begin
  Assert(IsPascalTypeCharacterMapRegistered(CharacterMapClass) = False);
  SetLength(GCharacterMapClasses, Length(GCharacterMapClasses) + 1);
  GCharacterMapClasses[High(GCharacterMapClasses)] := CharacterMapClass;
end;

class procedure PascalTypeCharacterMaps.RegisterCharacterMaps(CharacterMapClasses: array of TPascalTypeCharacterMapClass);
var
  CharacterMapClassIndex: Integer;
begin
  SetLength(GCharacterMapClasses, Length(GCharacterMapClasses) + Length(CharacterMapClasses));
  for CharacterMapClassIndex := 0 to High(CharacterMapClasses) do
    GCharacterMapClasses[Length(GCharacterMapClasses) - Length(CharacterMapClasses) + CharacterMapClassIndex] :=
      CharacterMapClasses[CharacterMapClassIndex];
  Assert(CheckCharacterMapClassesValid);
end;

class function PascalTypeCharacterMaps.FindCharacterMapByFormat(Format: Word): TPascalTypeCharacterMapClass;
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

  if (BigEndianValue.ReadWord(Stream) <> Format) then
    raise EPascalTypeError.Create('CharacterMap format mismatch');
end;

procedure TCustomPascalTypeCharacterMap.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteWord(Stream, Format);
end;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeCharacterMapDirectory
//
//------------------------------------------------------------------------------
constructor TCustomPascalTypeCharacterMapDirectory.Create(AParent: TCustomPascalTypeTable; AEncodingID: Word);
begin
  inherited Create(AParent);
  FEncodingID := AEncodingID;
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
  MapFormat := BigEndianValue.ReadWord(Stream);
  MapClass := PascalTypeCharacterMaps.FindCharacterMapByFormat(MapFormat);

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

procedure TCustomPascalTypeCharacterMapDirectory.SetEncodingID(const Value: Word);
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
  Result := TUnicodeEncodingID(EncodingID);
end;

function TPascalTypeCharacterMapUnicodeDirectory.GetPlatformID: TPlatformID;
begin
  Result := piUnicode;
end;

procedure TPascalTypeCharacterMapUnicodeDirectory.SetEncodingID(const Value: TUnicodeEncodingID);
begin
  inherited SetEncodingID(Ord(Value));
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapMacintoshDirectory
//
//------------------------------------------------------------------------------
function TPascalTypeCharacterMapMacintoshDirectory.GetEncodingID: TAppleEncodingID;
begin
  Result := TAppleEncodingID(EncodingID);
end;

function TPascalTypeCharacterMapMacintoshDirectory.GetPlatformID: TPlatformID;
begin
  Result := piApple;
end;

procedure TPascalTypeCharacterMapMacintoshDirectory.SetEncodingID(const Value: TAppleEncodingID);
begin
  inherited SetEncodingID(Ord(Value));
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCharacterMapMicrosoftDirectory
//
//------------------------------------------------------------------------------
function TPascalTypeCharacterMapMicrosoftDirectory.CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer;
var
  OS2Table: TPascalTypeOS2Table;
begin
  case PlatformSpecificID of
    meUnicodeBMP:
        Result := inherited CharacterToGlyph(ACodePoint);

    // meSymbol included. How else are we going to use symbol fonts?
    // Seen with: "Symbol"
    meSymbol:
      begin
        // https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#windows-platform-platform-id--3
        //
        // The symbol encoding was created to support fonts with arbitrary ornaments or symbols
        // not supported in Unicode or other standard encodings. A format 4 subtable would be used,
        // typically with up to 224 graphic characters assigned at code positions beginning with 0xF020.
        // This corresponds to a sub-range within the Unicode Private-Use Area (PUA), though this is not
        // a Unicode encoding. In legacy usage, some applications would represent the symbol characters
        // in text using a single-byte encoding, and then map 0x20 to the OS/2.usFirstCharIndex value in
        // the font.
        Result := inherited CharacterToGlyph(ACodePoint);

        if (Result = 0) and (ACodePoint < $F000) then
        begin
          OS2Table := TPascalTypeFontFace(FontFace).OS2Table;

          if (OS2Table <> nil) and
            ((OS2Table.CodePageRange = nil) or (OS2Table.CodePageRange.SupportsSymbolCharacterSet) or
             ((OS2Table.CodePageRange.AsCardinal[0] = 0) and (OS2Table.CodePageRange.AsCardinal[1] = 0))) then
            // Using the offset in OS2Table.UnicodeFirstCharacterIndex, as the documentation suggests,
            // works for very few symbols fonts. Using a hardcoded value of $F020 works for most.
            // ACodePoint := Word(Integer(ACodePoint) - Ord(' ') + OS2Table.UnicodeFirstCharacterIndex)
            ACodePoint := Word(Integer(ACodePoint) - Ord(' ') + $F020);

          Result := inherited CharacterToGlyph(ACodePoint);
        end;
      end;
  else
    Result := inherited CharacterToGlyph(ACodePoint);
  end;
end;

function TPascalTypeCharacterMapMicrosoftDirectory.GetEncodingID: TMicrosoftEncodingID;
begin
  Result := TMicrosoftEncodingID(EncodingID);
end;

function TPascalTypeCharacterMapMicrosoftDirectory.GetPlatformID: TPlatformID;
begin
  Result := piMicrosoft;
end;

procedure TPascalTypeCharacterMapMicrosoftDirectory.SetEncodingID(const Value: TMicrosoftEncodingID);
begin
  inherited SetEncodingID(Ord(Value));
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
    FBestCharacterMap := nil;

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

        Map := MapClass.Create(Self, SourceMap.EncodingID);
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

function TPascalTypeCharacterMapTable.GetGlyphByCharacter(ACodePoint: TPascalTypeCodePoint): Integer;

  function FindPlatformMap(PlatformID: TPlatformID): TCustomPascalTypeCharacterMapDirectory;
  begin
    for Result in FMaps do
      if (Result.PlatformID = PlatformID) and (Result.CharacterMap.Format in [0,2,4,6,12]) then
        exit;
    Result := nil;
  end;

// var
//  Map: TCustomPascalTypeCharacterMapDirectory;
begin
  if (FBestCharacterMap = nil) then
  begin
    if (FMaps = nil) then
      Exit(0);

    // Prefer Unicode
    FBestCharacterMap := FindPlatformMap(piUnicode);

    // Fall back to Windows
    if (FBestCharacterMap = nil) then
      FBestCharacterMap := FindPlatformMap(piMicrosoft);

    // If everything fails, just get one that we can handle
// TODO : Handle encoding
(*
    if (FBestCharacterMap = nil) then
    begin
      for Map in FMaps do
      begin
        var Encoding := GetEncoding(Map.PlatformID, Map.EncodingID, 0); // TODO : How do we get Language here? Pass as parameter?
        FBestCharacterMap := GetEncodingMap(Encoding);
        if (FBestCharacterMap <> nil) then
          break;
      end;
    end;
*)
    if (FBestCharacterMap = nil) then
      raise EPascalTypeError.Create(RCStrCharacterMapNotSet);
  end;

  Result := FBestCharacterMap.CharacterToGlyph(ACodePoint);
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
  FBestCharacterMap := nil;

  if (FMaps <> nil) then
    FMaps.Clear;

  // store stream start position
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size (table with at least one entry)
  if Stream.Position + 4*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read Version
  FVersion := BigEndianValue.ReadWord(Stream);

  // check version
  if (FVersion <> 0) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read subtable count
  SetLength(Offsets, BigEndianValue.ReadWord(Stream));

  if (Length(Offsets) = 0) then
    exit;

  // check (minimum) table size
  if Stream.Position + Length(Offsets) * (2 * SizeOf(Word) + SizeOf(Cardinal)) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  if (FMaps = nil) then
    FMaps := TObjectList<TCustomPascalTypeCharacterMapDirectory>.Create;

  FMaps.Capacity := Length(Offsets);

  // read directory entry
  for i := 0 to High(Offsets) do
  begin
    // read Platform ID
    PlatformID := BigEndianValue.ReadWord(Stream);

    // read encoding ID
    EncodingID := BigEndianValue.ReadWord(Stream);

    // create character map based on encoding
    case TPlatformID(PlatformID) of
      piUnicode:
        Map := TPascalTypeCharacterMapUnicodeDirectory.Create(Self, EncodingID);

      piApple:
        Map := TPascalTypeCharacterMapMacintoshDirectory.Create(Self, EncodingID);

      piMicrosoft:
        Map := TPascalTypeCharacterMapMicrosoftDirectory.Create(Self, EncodingID);
    else
      // TODO : PlatformID should be stored in map so it isn't lost
      Map := TPascalTypeCharacterMapDirectoryGenericEntry.Create(Self, EncodingID);
    end;

    FMaps.Add(Map);

    // read and save offset
    Offsets[i] := BigEndianValue.ReadCardinal(Stream);
  end;

  // load character map entries from stream
  for i := 0 to High(Offsets) do
  begin
    Stream.Position := StartPos + Offsets[i];
    FMaps[i].LoadFromStream(Stream);
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
  BigEndianValue.WriteWord(Stream, FVersion);

  // write directory entry count
  BigEndianValue.WriteWord(Stream, CharacterMapSubtableCount);

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
      BigEndianValue.WriteWord(Stream, Word(FMaps[DirIndex].PlatformID));

      // write encoding ID
      BigEndianValue.WriteWord(Stream, FMaps[DirIndex].EncodingID);

      // write offset
      BigEndianValue.WriteCardinal(Stream, Directory[DirIndex]);
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

  PascalTypeTableClasses.RegisterTable(TPascalTypeCharacterMapTable);

end.
