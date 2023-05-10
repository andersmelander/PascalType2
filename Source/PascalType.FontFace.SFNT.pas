unit PascalType.FontFace.SFNT;

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

{$IFDEF CPUx86_64}
  {$DEFINE PUREPASCAL}
{$ENDIF}

uses
  Generics.Collections,
  Classes, SysUtils, Types,
  PT_Types,
  PT_Classes,
  PascalType.FontFace,
  PT_Tables,
  PT_TableDirectory,
  PascalType.Tables.TrueType.hmtx,
  PascalType.Tables.TrueType.hhea,
  PascalType.Tables.TrueType.vmtx,
  PascalType.Tables.TrueType.os2,
  PascalType.Tables.TrueType.Panose;

type
  TTrueTypeGlyphMetric = record
    HorizontalMetric: THorizontalMetric;
    VerticalMetric: TVerticalMetric;
  end;

type
  TCustomPascalTypeFontFace = class abstract(TCustomPascalTypeFontFacePersistent, IPascalTypeFontFace)
  strict private
    FRootTable: TCustomPascalTypeTable;
    // required tables
    FHeaderTable: TPascalTypeHeaderTable;
    FHorizontalHeader: TPascalTypeHorizontalHeaderTable;
    FMaximumProfile: TPascalTypeMaximumProfileTable;
    FNameTable: TPascalTypeNameTable;
    FPostScriptTable: TPascalTypePostscriptTable;
  private
    function GetFontName: WideString;
    function GetFontStyle: TFontStyles;
    function GetFontFamilyName: WideString;
    function GetFontSubFamilyName: WideString;
    function GetFontVersion: WideString;
    function GetUniqueIdentifier: WideString;
  protected
    // IPascalTypeFontFaceTable
    function GetTableByTableName(const ATableName: TTableName): TCustomPascalTypeNamedTable; virtual;
    function GetTableByTableType(ATableType: TTableType): TCustomPascalTypeNamedTable; virtual;
    function GetTableByTableClass(ATableClass: TCustomPascalTypeNamedTableClass): TCustomPascalTypeNamedTable; virtual;
  protected
    procedure DirectoryTableLoaded(DirectoryTable: TPascalTypeDirectoryTable); virtual;
    procedure LoadTableFromStream(Stream: TStream; TableEntry: TPascalTypeDirectoryTableEntry); virtual; abstract;

    property RootTable: TCustomPascalTypeTable read FRootTable;

{$IFDEF ChecksumTest}
    procedure ValidateChecksum(Stream: TStream; TableEntry: TPascalTypeDirectoryTableEntry); virtual;
{$ENDIF}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;

    function GetGlyphByCharacter(Character: Word): Integer; overload; virtual; abstract;
    function GetGlyphByCharacter(Character: WideChar): Integer; overload;
    function GetGlyphByCharacter(Character: AnsiChar): Integer; overload;
    function HasGlyphByCharacter(Character: Word): boolean;

    // required tables
    property HeaderTable: TPascalTypeHeaderTable read FHeaderTable;
    property HorizontalHeader: TPascalTypeHorizontalHeaderTable read FHorizontalHeader;
    property MaximumProfile: TPascalTypeMaximumProfileTable read FMaximumProfile;
    property NameTable: TPascalTypeNameTable read FNameTable;
    property PostScriptTable: TPascalTypePostscriptTable read FPostScriptTable;

    // basic properties
    property FontFamilyName: WideString read GetFontFamilyName;
    property FontName: WideString read GetFontName;
    property FontStyle: TFontStyles read GetFontStyle;
    property FontSubFamilyName: WideString read GetFontSubFamilyName;
    property FontVersion: WideString read GetFontVersion;
    property UniqueIdentifier: WideString read GetUniqueIdentifier;
  end;

  TPascalTypeFontFaceScan = class(TCustomPascalTypeFontFace)
  protected
    procedure LoadTableFromStream(Stream: TStream; TableEntry: TPascalTypeDirectoryTableEntry); override;
  public
    procedure SaveToStream(Stream: TStream); override;
  end;

  TPascalTypeFontFace = class(TCustomPascalTypeFontFace)
  strict private
    // required tables
    FHorizontalMetrics: TPascalTypeHorizontalMetricsTable;
    FCharacterMap: TPascalTypeCharacterMapTable;
    FOS2Table: TPascalTypeOS2Table;

    FOptionalTables: TObjectList<TCustomPascalTypeNamedTable>;
  private
    function GetTableCount: Integer;
    function GetOptionalTableCount: Integer;
    function GetOptionalTable(Index: Integer): TCustomPascalTypeNamedTable;
    function GetGlyphData(Index: Integer): TCustomPascalTypeGlyphDataTable;
    function GetPanose: TCustomPascalTypePanoseTable;
    function GetBoundingBox: TRect;
    function GetGlyphCount: Word;
  protected
    // IPascalTypeFontFaceTable
    function GetTableByTableName(const TableName: TTableName): TCustomPascalTypeNamedTable; override;
    function GetTableByTableType(ATableType: TTableType): TCustomPascalTypeNamedTable; override;
    function GetTableByTableClass(TableClass: TCustomPascalTypeNamedTableClass): TCustomPascalTypeNamedTable; override;

  protected
    procedure DirectoryTableLoaded(DirectoryTable : TPascalTypeDirectoryTable); override;
    procedure LoadTableFromStream(Stream: TStream; TableEntry: TPascalTypeDirectoryTableEntry); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure SaveToStream(Stream: TStream); override;
    function ContainsTable(TableType: TTableType): Boolean;
    function GetGlyphMetric(GlyphIndex: Word): TTrueTypeGlyphMetric;
    function GetAdvanceWidth(GlyphIndex: Word): Word; deprecated 'Use GetGlyphMetric';
    function GetKerning(Last, Next: Word): Word;

    function GetGlyphByCharacter(Character: Word): Integer; override;

    function GetGlyphPath(GlyphIndex: Word): TPascalTypePath; // TODO : Use TFloatPoint

    property GlyphData[Index: Integer]: TCustomPascalTypeGlyphDataTable read GetGlyphData;

    property OptionalTable[Index: Integer]: TCustomPascalTypeNamedTable read GetOptionalTable;
    property OptionalTableCount: Integer read GetOptionalTableCount;

    // redirected properties
    property Panose: TCustomPascalTypePanoseTable read GetPanose;
    property BoundingBox: TRect read GetBoundingBox;
    property GlyphCount: Word read GetGlyphCount;

    // required tables
    property HeaderTable;
    property HorizontalHeader;
    property MaximumProfile;
    property NameTable;
    property PostScriptTable;
    property HorizontalMetrics: TPascalTypeHorizontalMetricsTable read FHorizontalMetrics;
    property CharacterMap: TPascalTypeCharacterMapTable read FCharacterMap;
    property OS2Table: TPascalTypeOS2Table read FOS2Table;

    property TableCount: Integer read GetTableCount;
  end;

implementation

uses
  Math,
  PT_Math,
  PT_TablesTrueType,
  PascalType.Tables.TrueType.glyf,
  PT_ResourceStrings;

function CalculateCheckSum(Data: Pointer; Size: Integer): Cardinal; overload;
{$IFDEF PUREPASCAL}
var
  I: Integer;
begin
  Result := Swap32(PCardinal(Data)^);
  Inc(PCardinal(Data));

  // read subsequent cardinals
  for I := 1 to Size - 1 do
  begin
{$IFOPT Q+}
{$DEFINE Q_PLUS}
{$OVERFLOWCHECKS OFF}
{$ENDIF}
    Result := Result + Swap32(PCardinal(Data)^);
{$IFDEF Q_PLUS}
{$OVERFLOWCHECKS ON}
{$UNDEF Q_PLUS}
{$ENDIF}
    Inc(PCardinal(Data));
  end;
{$ELSE}
asm
  MOV     ECX, EDX
  XOR     EDX, EDX
  LEA     EAX, EAX + ECX * 4
  NEG     ECX
  JNL     @Done

  PUSH    EBX

@Start:
  MOV     EBX, [EAX + ECX * 4].DWord
  BSWAP   EBX
  ADD     EDX, EBX

  ADD     ECX, 1
  JS      @Start

  POP     EBX

@Done:
  MOV     EAX, EDX
  {$ENDIF}
end;

function CalculateCheckSum(Stream: TStream): Cardinal; overload;
var
  I    : Integer;
  Value: Cardinal;
begin
  with Stream do
  begin
    // ensure that at least one cardinal is in the stream
    if Size < 4 then
      Exit;

    // set position to beginning of the stream
    Seek(0, soFromBeginning);

    Assert(Size mod 4 = 0);

    if Stream is TMemoryStream then
      Result := CalculateCheckSum(TMemoryStream(Stream).Memory, Size div 4)
    else
    begin
      // read first cardinal
      Read(Result, SizeOf(Cardinal));
      Result := Swap32(Result);

      // read subsequent cardinals
      for I := 1 to (Size div 4) - 1 do
      begin
        Read(Value, SizeOf(Cardinal));
        Result := Result + Swap32(Value);
      end;
    end;
  end;
end;

function CalculateHeadCheckSum(Stream: TMemoryStream): Cardinal;
var
  I    : Integer;
  Value: Cardinal;
begin
  with Stream do
  begin
    // ensure that at least one cardinal is in the stream
    if Size < 4 then
      Exit;

    // set position to beginning of the stream
    Seek(0, soFromBeginning);

    // read first cardinal
    Read(Result, SizeOf(Cardinal));
    Result := Swap32(Result);

    // read subsequent cardinals
    for I := 1 to (Size div 4) - 1 do
    begin
      if I = 2 then
        Continue;
      Read(Value, SizeOf(Cardinal));
      Result := Result + Swap32(Value);
    end;
  end;
end;


{ TCustomPascalTypeFontFace }

type
  TPascalTypeTableRoot = class(TCustomPascalTypeTable)
  private
    FFontFace: IPascalTypeFontFace;
  protected
    function GetFontFace: IPascalTypeFontFace; override;
  public
    constructor Create(const AFontFace: IPascalTypeFontFace); reintroduce;
  end;

constructor TPascalTypeTableRoot.Create(const AFontFace: IPascalTypeFontFace);
begin
  inherited Create;
  FFontFace := AFontFace;
end;

function TPascalTypeTableRoot.GetFontFace: IPascalTypeFontFace;
begin
  Result := FFontFace;
end;

constructor TCustomPascalTypeFontFace.Create;
begin
  inherited;
  FRootTable := TPascalTypeTableRoot.Create(Self);

  // create required tables
  FHeaderTable := TPascalTypeHeaderTable.Create(FRootTable);
  FHorizontalHeader := TPascalTypeHorizontalHeaderTable.Create(FRootTable);
  FMaximumProfile := TPascalTypeMaximumProfileTable.Create(FRootTable);
  FNameTable := TPascalTypeNameTable.Create(FRootTable);
  FPostScriptTable := TPascalTypePostscriptTable.Create(FRootTable);
end;

destructor TCustomPascalTypeFontFace.Destroy;
begin
  FreeAndNil(FHeaderTable);
  FreeAndNil(FHorizontalHeader);
  FreeAndNil(FMaximumProfile);
  FreeAndNil(FNameTable);
  FreeAndNil(FPostScriptTable);
  inherited;
end;

procedure TCustomPascalTypeFontFace.DirectoryTableLoaded(DirectoryTable: TPascalTypeDirectoryTable);
begin
  // optimize table read order
  DirectoryTable.TableList.Sort;
end;

function TCustomPascalTypeFontFace.GetFontFamilyName: WideString;
var
  NameSubTableIndex: Integer;
begin
  with FNameTable do
    for NameSubTableIndex := 0 to NameSubTableCount - 1 do
      with NameSubTable[NameSubTableIndex] do
{$IFDEF MSWINDOWS}
        if PlatformID = piMicrosoft then
{$ELSE}
        if PlatformID = piUnicode then
{$ENDIF}
          if NameID = niFamily then
          begin
            Result := Name;
            Exit;
          end;
end;

function TCustomPascalTypeFontFace.GetFontSubFamilyName: WideString;
var
  NameSubTableIndex: Integer;
begin
  with FNameTable do
    for NameSubTableIndex := 0 to NameSubTableCount - 1 do
      with NameSubTable[NameSubTableIndex] do
{$IFDEF MSWINDOWS}
        if PlatformID = piMicrosoft then
{$ELSE}
        if PlatformID = piUnicode then
{$ENDIF}
          if NameID = niSubfamily then
          begin
            Result := Name;
{$IFDEF MSWINDOWS}
            if LanguageID = 1033 then
              Exit;
{$ELSE}
            Exit;
{$ENDIF}
          end;
end;

function TCustomPascalTypeFontFace.GetFontVersion: WideString;
var
  NameSubTableIndex: Integer;
begin
  with FNameTable do
    for NameSubTableIndex := 0 to NameSubTableCount - 1 do
      with NameSubTable[NameSubTableIndex] do
{$IFDEF MSWINDOWS}
        if PlatformID = piMicrosoft then
{$ELSE}
        if PlatformID = piUnicode then
{$ENDIF}
          if NameID = niVersion then
          begin
            Result := Name;
{$IFDEF MSWINDOWS}
            if LanguageID = 1033 then
              Exit;
{$ELSE}
            Exit;
{$ENDIF}
          end;
end;

function TCustomPascalTypeFontFace.GetUniqueIdentifier: WideString;
var
  NameSubTableIndex: Integer;
begin
  with FNameTable do
    for NameSubTableIndex := 0 to NameSubTableCount - 1 do
      with NameSubTable[NameSubTableIndex] do
{$IFDEF MSWINDOWS}
        if PlatformID = piMicrosoft then
{$ELSE}
        if PlatformID = piUnicode then
{$ENDIF}
          if NameID = niUniqueIdentifier then
          begin
            Result := Name;
{$IFDEF MSWINDOWS}
            if LanguageID = 1033 then
              Exit;
{$ELSE}
            Exit;
{$ENDIF}
          end;
end;

function TCustomPascalTypeFontFace.GetFontName: WideString;
var
  NameSubTableIndex: Integer;
begin
  with FNameTable do
    for NameSubTableIndex := 0 to NameSubTableCount - 1 do
      with NameSubTable[NameSubTableIndex] do
{$IFDEF MSWINDOWS}
        if PlatformID = piMicrosoft then
{$ELSE}
        if PlatformID = piUnicode then
{$ENDIF}
          if NameID = niFullName then
          begin
            Result := Name;
{$IFDEF MSWINDOWS}
            if LanguageID = 1033 then
              Exit;
{$ELSE}
            Exit;
{$ENDIF}
          end;
end;

function TCustomPascalTypeFontFace.GetFontStyle: TFontStyles;
begin
  if msItalic in FHeaderTable.MacStyle then
    Result := [fsItalic]
  else
    Result := [];
  if msBold in FHeaderTable.MacStyle then
    Result := Result + [fsBold];
  if msUnderline in FHeaderTable.MacStyle then
    Result := Result + [fsUnderline];
end;

function TCustomPascalTypeFontFace.GetTableByTableClass(ATableClass: TCustomPascalTypeNamedTableClass): TCustomPascalTypeNamedTable;
begin
  // return nil if the table hasn't been found

  if ATableClass = HeaderTable.ClassType then
    Result := HeaderTable
  else
  if ATableClass = HorizontalHeader.ClassType then
    Result := HorizontalHeader
  else
  if ATableClass = MaximumProfile.ClassType then
    Result := MaximumProfile
  else
  if ATableClass = NameTable.ClassType then
    Result := NameTable
  else
  if ATableClass = PostScriptTable.ClassType then
    Result := PostScriptTable
  else
    Result := nil;
end;

function TCustomPascalTypeFontFace.GetTableByTableName(const ATableName: TTableName): TCustomPascalTypeNamedTable;
begin
  // return nil if the table hasn't been found

  if CompareTableType(HeaderTable.TableType, ATableName) then
    Result := HeaderTable
  else
  if CompareTableType(HorizontalHeader.TableType, ATableName) then
    Result := HorizontalHeader
  else
  if CompareTableType(MaximumProfile.TableType, ATableName) then
    Result := MaximumProfile
  else
  if CompareTableType(NameTable.TableType, ATableName) then
    Result := NameTable
  else
  if CompareTableType(PostScriptTable.TableType, ATableName) then
    Result := PostScriptTable
  else
    Result := nil;
end;

function TCustomPascalTypeFontFace.GetTableByTableType(ATableType: TTableType): TCustomPascalTypeNamedTable;
begin
  // return nil if the table hasn't been found
  if ATableType.AsCardinal = HeaderTable.TableType.AsCardinal then
    Result := HeaderTable
  else
  if ATableType.AsCardinal = HorizontalHeader.TableType.AsCardinal then
    Result := HorizontalHeader
  else
  if ATableType.AsCardinal = MaximumProfile.TableType.AsCardinal then
    Result := MaximumProfile
  else
  if ATableType.AsCardinal = NameTable.TableType.AsCardinal then
    Result := NameTable
  else
  if ATableType.AsCardinal = PostScriptTable.TableType.AsCardinal then
    Result := PostScriptTable
  else
    Result := nil;
end;

procedure TCustomPascalTypeFontFace.LoadFromStream(Stream: TStream);
var
  DirectoryTable: TPascalTypeDirectoryTable;
  TableIndex    : Integer;
begin
  DirectoryTable := TPascalTypeDirectoryTable.Create(FRootTable);
  try
    DirectoryTable.LoadFromStream(Stream);

    // directory table has been read, notify
    DirectoryTableLoaded(DirectoryTable);

    // read header table
    if (HeaderTable = nil) then
      raise EPascalTypeError.Create(RCStrNoHeaderTable);
    LoadTableFromStream(Stream, DirectoryTable.HeaderTable);

    // read horizontal header table
    if (DirectoryTable.HorizontalHeaderDataEntry = nil) then
      raise EPascalTypeError.Create(RCStrNoHorizontalHeaderTable);
    LoadTableFromStream(Stream, DirectoryTable.HorizontalHeaderDataEntry);

    // read maximum profile table
    if (DirectoryTable.MaximumProfileDataEntry = nil) then
      raise EPascalTypeError.Create(RCStrNoMaximumProfileTable);
    LoadTableFromStream(Stream, DirectoryTable.MaximumProfileDataEntry);

    // eventually read OS/2 table or eventually raise an exception
    if (DirectoryTable.OS2TableEntry <> nil) then
      LoadTableFromStream(Stream, DirectoryTable.OS2TableEntry)
    else
    if (DirectoryTable.Version = $00010000) then
      raise EPascalTypeError.Create(RCStrNoOS2Table);

    // read horizontal metrics table
    if (DirectoryTable.HorizontalMetricsDataEntry = nil) then
      raise EPascalTypeError.Create(RCStrNoHorizontalMetricsTable);
    LoadTableFromStream(Stream, DirectoryTable.HorizontalMetricsDataEntry);

    // read character map table
    if (DirectoryTable.CharacterMapDataEntry = nil) then
      raise EPascalTypeError.Create(RCStrNoCharacterMapTable);
    LoadTableFromStream(Stream, DirectoryTable.CharacterMapDataEntry);

    // TODO: check if these are required by tables already read!!!
    // read index to location table
    if (DirectoryTable.LocationDataEntry <> nil) then
      LoadTableFromStream(Stream, DirectoryTable.LocationDataEntry)
    else
    if (DirectoryTable.Version = $74727565) then
      raise EPascalTypeError.Create(RCStrNoIndexToLocationTable);

    // read glyph data table
    if (DirectoryTable.GlyphDataEntry <> nil) then
      LoadTableFromStream(Stream, DirectoryTable.GlyphDataEntry)
    else
    if (DirectoryTable.Version = $74727565) then
      raise EPascalTypeError.Create(RCStrNoGlyphDataTable);

    // read name table
    if (DirectoryTable.NameDataEntry = nil) then
      raise EPascalTypeError.Create(RCStrNoNameTable);
    LoadTableFromStream(Stream, DirectoryTable.NameDataEntry);

    // read postscript table
    if (DirectoryTable.PostscriptDataEntry = nil) then
      raise EPascalTypeError.Create(RCStrNoPostscriptTable);
    LoadTableFromStream(Stream, DirectoryTable.PostscriptDataEntry);

    // read other table entries from stream
    for TableIndex := 0 to DirectoryTable.TableList.Count - 1 do
      LoadTableFromStream(Stream, DirectoryTable.TableList[TableIndex]);
  finally
    DirectoryTable.Free;
  end;
end;

{$IFDEF ChecksumTest}

procedure TCustomPascalTypeFontFace.ValidateChecksum(Stream: TStream;
  TableEntry: TPascalTypeDirectoryTableEntry);
var
  Checksum: Cardinal;
begin
  Stream.Position := 0;

  // calculate checksum of strem
  Checksum := CalculateCheckSum(Stream);

  if CompareTableType(TableEntry.TableType, 'head') then
  begin
    // ignore checksum adjustment
    Stream.Position := 8;
{$IFOPT Q+}
{$DEFINE Q_PLUS}
{$OVERFLOWCHECKS OFF}
{$ENDIF}
    Checksum := Checksum - ReadSwappedCardinal(Stream);
{$IFDEF Q_PLUS}
{$OVERFLOWCHECKS ON}
{$UNDEF Q_PLUS}
{$ENDIF}
  end;

  // check checksum
  if (Checksum <> TableEntry.Checksum) then
    raise EPascalTypeChecksumError.CreateFmt(RCStrChecksumError,
      [string(TableEntry.TableType)]);
end;
{$ENDIF}

function TCustomPascalTypeFontFace.GetGlyphByCharacter(Character: WideChar): Integer;
begin
  Result := GetGlyphByCharacter(Word(Character));
end;

function TCustomPascalTypeFontFace.GetGlyphByCharacter(Character: AnsiChar): Integer;
begin
  Result := GetGlyphByCharacter(Word(Character));
end;

function TCustomPascalTypeFontFace.HasGlyphByCharacter(Character: Word): boolean;
begin
  Result := (GetGlyphByCharacter(Character) <> 0);
end;


{ TPascalTypeFontFaceScan }

procedure TPascalTypeFontFaceScan.LoadTableFromStream(Stream: TStream; TableEntry: TPascalTypeDirectoryTableEntry);
var
  MemoryStream: TMemoryStream;
  Table: TCustomPascalTypeNamedTable;
begin
  Table := GetTableByTableType(TableEntry.TableType);
  if (Table = nil) then
    exit;

  MemoryStream := TMemoryStream.Create;
  try
    // set stream position
    Stream.Position := TableEntry.Offset;

    // copy from stream
    MemoryStream.CopyFrom(Stream, 4 * ((TableEntry.Length + 3) div 4));

{$IFDEF ChecksumTest}
    ValidateChecksum(MemoryStream, TableEntry);
{$ENDIF}
    // reset memory stream position
    MemoryStream.Position := 0;

    // restore original table length
    MemoryStream.Size := TableEntry.Length;

    Table.LoadFromStream(MemoryStream);

  finally
    MemoryStream.Free;
  end;
end;

procedure TPascalTypeFontFaceScan.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeFontFace }

constructor TPascalTypeFontFace.Create;
begin
  inherited;

  // create required tables
  FHorizontalMetrics := TPascalTypeHorizontalMetricsTable.Create(RootTable);
  FCharacterMap := TPascalTypeCharacterMapTable.Create(RootTable);

  // create optional table list
  FOptionalTables := TObjectList<TCustomPascalTypeNamedTable>.Create;
end;

destructor TPascalTypeFontFace.Destroy;
begin
  FreeAndNil(FHorizontalMetrics);
  FreeAndNil(FCharacterMap);
  FreeAndNil(FOptionalTables);
  FreeAndNil(FOS2Table);
  inherited;
end;

procedure TPascalTypeFontFace.DirectoryTableLoaded(DirectoryTable: TPascalTypeDirectoryTable);
begin
  inherited;

  // clear optional tables
  FOptionalTables.Clear;

  // eventually free OS/2 table
  FreeAndNil(FOS2Table);
end;

function TPascalTypeFontFace.GetAdvanceWidth(GlyphIndex: Word): Word;
begin
  if (GlyphIndex < FHorizontalMetrics.HorizontalMetricCount) then
    Result := FHorizontalMetrics.HorizontalMetric[GlyphIndex].AdvanceWidth
  else
    Result := FHorizontalMetrics.HorizontalMetric[0].AdvanceWidth;
end;

function TPascalTypeFontFace.GetBoundingBox: TRect;
begin
  Result.Left := HeaderTable.XMin;
  Result.Top := HeaderTable.YMax;
  Result.Right := HeaderTable.XMax;
  Result.Bottom := HeaderTable.YMin;
end;

function TPascalTypeFontFace.GetGlyphCount: Word;
begin
  Result := MaximumProfile.NumGlyphs;
end;

function TPascalTypeFontFace.GetGlyphData(Index: Integer): TCustomPascalTypeGlyphDataTable;
var
  GlyphDataTable: TTrueTypeFontGlyphDataTable;
begin
  Result := nil;

  GlyphDataTable := TTrueTypeFontGlyphDataTable(GetTableByTableName('glyf'));
  if (GlyphDataTable <> nil) then
    if (Index >= 0) and (Index < GlyphDataTable.GlyphDataCount) then
      Result := GlyphDataTable.GlyphData[Index];
end;

function TPascalTypeFontFace.GetGlyphByCharacter(Character: Word): Integer;
var
  CharMapIndex: Integer;
{$IFDEF MSWINDOWS}
  CharacterMapDirectory: TPascalTypeCharacterMapMicrosoftDirectory;
{$ENDIF}
{$IFDEF OSX}
  CharacterMapDirectory: TPascalTypeCharacterMapMacintoshDirectory;
{$ENDIF}
begin
  // direct translate character to glyph (will most probably fail!!!
  Result := Integer(Character);

  for CharMapIndex := 0 to CharacterMap.CharacterMapSubtableCount - 1 do
{$IFDEF MSWINDOWS}
    if CharacterMap.CharacterMapSubtable[CharMapIndex] is TPascalTypeCharacterMapMicrosoftDirectory then
    begin
      CharacterMapDirectory := TPascalTypeCharacterMapMicrosoftDirectory(CharacterMap.CharacterMapSubtable[CharMapIndex]);
      case CharacterMapDirectory.PlatformSpecificID of
        meUnicodeBMP:
          begin
            Result := CharacterMapDirectory.CharacterToGlyph(Integer(Character));
            // TODO : Only break if result<>0?
            break;
          end;

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
            //
            // This works with "Symbol" but not with "Marlett", small letter "a"
            if (OS2Table <> nil) then
              Character := Word(Integer(Character) - Ord(' ') + OS2Table.UnicodeFirstCharacterIndex)
            else
              Character := Word(Integer(Character) - Ord(' ') + $F020);
            Result := CharacterMapDirectory.CharacterToGlyph(Character);
            // TODO : Only break if result<>0?
            break;
          end;
      end;
    end;
{$ENDIF}
{$IFDEF OSX}
  if CharacterMap.CharacterMapSubtable[CharMapIndex] is TPascalTypeCharacterMapMacintoshDirectory then
  begin
    CharacterMapDirectory := TPascalTypeCharacterMapMacintoshDirectory(CharacterMap.CharacterMapSubtable[CharMapIndex]);
    if CharacterMapDirectory.PlatformSpecificID = 1 then
    begin
      Result := CharacterMapDirectory.CharacterToGlyph(Integer(Character));
      break;
    end;
  end;
{$ENDIF}
end;

function TPascalTypeFontFace.GetGlyphMetric(GlyphIndex: Word): TTrueTypeGlyphMetric;
var
  GlyphDataTable: TTrueTypeFontGlyphDataTable;

  procedure DoGetGlyphMetric(GlyphIndex: Word; var MetricIndex: Word);
  var
    Glyph: TCustomTrueTypeFontGlyphData;
    i: integer;
    CompositeGlyphData: TTrueTypeFontCompositeGlyphData;
    ComponentGlyphMetric: TTrueTypeGlyphMetric;
  begin
    Glyph := GlyphDataTable.GlyphData[GlyphIndex];

    // If glyph is a simple glyph then we will just use its index as the metric index.
    if (Glyph is TTrueTypeFontSimpleGlyphData) then
      // The default MetricIndex value has already been set by the caller.
      exit;

    // If glyph is a composite glyph, then we will either use its index or one of
    // its components index as the metric index.
    if Glyph is TTrueTypeFontCompositeGlyphData then
    begin
      // The default MetricIndex value has already been set by the caller.
      CompositeGlyphData := TTrueTypeFontCompositeGlyphData(Glyph);

      // Recursively process composite glyph components
      for i := 0 to CompositeGlyphData.GlyphCount-1 do
        if (CompositeGlyphData.Glyph[i].Flags and TPascalTypeCompositeGlyph.GLYF_USE_MY_METRICS <> 0) then
        begin
          // We will use the index of the component. Set MetricIndex and recurse.
          MetricIndex := CompositeGlyphData.Glyph[i].GlyphIndex;

          DoGetGlyphMetric(CompositeGlyphData.Glyph[i].GlyphIndex, MetricIndex);

          // In theory multiple components could set USE_MY_METRICS but we
          // ignore that as it doesn't make sense.
          exit;
        end;
    end;
  end;

var
  MetricIndex: Word;
  VerticalMetricsTable: TPascalTypeVerticalMetricsTable;
begin
  Result := Default(TTrueTypeGlyphMetric);
  GlyphDataTable := TTrueTypeFontGlyphDataTable(GetTableByTableName('glyf'));
  if (GlyphDataTable = nil) then
    exit;

  MetricIndex := GlyphIndex;
  DoGetGlyphMetric(GlyphIndex, MetricIndex);

  Result.HorizontalMetric := FHorizontalMetrics.HorizontalMetric[MetricIndex];

  VerticalMetricsTable := TPascalTypeVerticalMetricsTable(GetTableByTableType(TPascalTypeVerticalMetricsTable.GetTableType));
  // TODO : Fall back to something for vertical metric if 'vmtx' isn't present
  if (VerticalMetricsTable <> nil) then
    Result.VerticalMetric := VerticalMetricsTable.VerticalMetric[MetricIndex];
end;

function TPascalTypeFontFace.GetGlyphPath(GlyphIndex: Word): TPascalTypePath;

  procedure AppendPath(var Path: TPascalTypePath; const Append: TPascalTypePath);
  var
    NewIndex: integer;
    Contour: TPascalTypeContour;
  begin
    NewIndex := Length(Path);
    SetLength(Path, Length(Path)+Length(Append));
    for Contour in Append do
    begin
      Path[NewIndex] := Contour;
      Inc(NewIndex);
    end;
  end;

  function AffineTransformation(const Path: TPascalTypePath; const AffineTransformationMatrix: TSmallScaleMatrix): TPascalTypePath;
  const
    q: Single = 33.0 / 35536.0;
  var
    i, j: integer;
    m0, n0: double;
    m, n: double;
    TempX: Single;
    OffsetX, OffsetY: Single;
    Contour: TPascalTypeContour;
  begin
    SetLength(Result, Length(Path));

    // See: https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6glyf.html#COMPOUNDGLYPHS

    m0 := Max(Abs(AffineTransformationMatrix[0,0]), Abs(AffineTransformationMatrix[0,1]));
    n0 := Max(Abs(AffineTransformationMatrix[1,0]), Abs(AffineTransformationMatrix[1,1]));

    if (m0 <> 0) and (n0 <> 0) then
    begin
      if (Abs(AffineTransformationMatrix[0,0]) - Abs(AffineTransformationMatrix[1,0]) <= q) then
        m := 2 * m0
      else
        m := m0;

      if (Abs(AffineTransformationMatrix[0,1]) - Abs(AffineTransformationMatrix[1,1]) <= q) then
        n := 2 * n0
      else
        n := n0;

      OffsetX := AffineTransformationMatrix[0,2] * m;
      OffsetY := AffineTransformationMatrix[1,2] * n;

      // Transform all points in path
      for i := 0 to High(Path) do
      begin
        Contour := Copy(Path[i]);
        Result[i] := Contour;
        for j := 0 to High(Contour) do
        begin
          TempX :=        AffineTransformationMatrix[0,0] * Contour[j].XPos + AffineTransformationMatrix[1,0] * Contour[j].YPos + OffsetX;
          Contour[j].YPos := AffineTransformationMatrix[0,1] * Contour[j].XPos + AffineTransformationMatrix[1,1] * Contour[j].YPos + OffsetY;
          Contour[j].XPos := TempX;
        end;
      end;

    end else
    if (AffineTransformationMatrix[0,2] <> 0) or (AffineTransformationMatrix[1,2] <> 0) then
    begin
      OffsetX := AffineTransformationMatrix[0,2];
      OffsetY := AffineTransformationMatrix[1,2];

      // Simple translation
      for i := 0 to High(Path) do
      begin
        Contour := Copy(Path[i]);
        Result[i] := Contour;
        for j := 0 to High(Contour) do
        begin
          Contour[j].XPos := Contour[j].XPos + OffsetX;
          Contour[j].YPos := Contour[j].YPos + OffsetY;
        end;
      end;
    end;
  end;

  function Translate(var Path: TPascalTypePath; OffsetX, OffsetY: Single): TPascalTypePath;
  var
    i, j: integer;
    Contour: TPascalTypeContour;
  begin
    SetLength(Result, Length(Path));
    // Simple translation
    for i := 0 to High(Path) do
    begin
      Contour := Copy(Path[i]);
      Result[i] := Contour;
      for j := 0 to High(Contour) do
      begin
        Contour[j].XPos := Contour[j].XPos + OffsetX;
        Contour[j].YPos := Contour[j].YPos + OffsetY;
      end;
    end;
  end;

  function GetCompositeGlyphPath(ParentGlyph: TTrueTypeFontCompositeGlyphData): TPascalTypePath;
  var
    i: integer;
    CompositeGlyph: TPascalTypeCompositeGlyph;
    GlyphPath: TPascalTypePath;
  begin
    // TODO : Point-to-point translation (GLYF_ARGS_ARE_XY_VALUES not set)
    SetLength(Result, 0);
    // Decompose compound ParentGlyph
    for i := 0 to ParentGlyph.GlyphCount-1 do
    begin
      CompositeGlyph := ParentGlyph.Glyph[i];

      // Recurse
      GlyphPath := GetGlyphPath(CompositeGlyph.GlyphIndex);

      if (CompositeGlyph.HasAffineTransformationMatrix) then
        GlyphPath := AffineTransformation(GlyphPath, CompositeGlyph.AffineTransformationMatrix)
      else
      if (CompositeGlyph.HasOffset) then
        GlyphPath := Translate(GlyphPath, CompositeGlyph.OffsetX, CompositeGlyph.OffsetY);

      AppendPath(Result, GlyphPath);
    end;
  end;

var
  Glyph: TCustomTrueTypeFontGlyphData;
begin
  Glyph := TCustomTrueTypeFontGlyphData(GlyphData[GlyphIndex]);

  if (Glyph is TTrueTypeFontSimpleGlyphData) then
    Result := TTrueTypeFontSimpleGlyphData(Glyph).Path
  else
  if Glyph is TTrueTypeFontCompositeGlyphData then
    // Recursively fetch glyph contours
    Result := GetCompositeGlyphPath(TTrueTypeFontCompositeGlyphData(Glyph));
end;

function TPascalTypeFontFace.GetKerning(Last, Next: Word): Word;
// var
// KernTable : TPascalType
begin
  Result := 0;
  // GetTableByTableType()
end;

function TPascalTypeFontFace.GetOptionalTable(Index: Integer): TCustomPascalTypeNamedTable;
begin
  if (Index < 0) or (Index >= FOptionalTables.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FOptionalTables[Index];
end;

function TPascalTypeFontFace.GetOptionalTableCount: Integer;
begin
  Result := FOptionalTables.Count;
end;

function TPascalTypeFontFace.GetPanose: TCustomPascalTypePanoseTable;
begin
  // default result
  Result := nil;

  if (FOS2Table <> nil) then
    Result := FOS2Table.Panose
end;

function TPascalTypeFontFace.GetTableByTableType(ATableType: TTableType): TCustomPascalTypeNamedTable;
var
  TableIndex: Integer;
begin
  Result := inherited GetTableByTableType(ATableType);

  if (Result = nil) then
  begin
    if ATableType.AsCardinal = HorizontalMetrics.TableType.AsCardinal then
      Result := HorizontalMetrics
    else
    if ATableType.AsCardinal = CharacterMap.TableType.AsCardinal then
      Result := CharacterMap
    else
      for TableIndex := 0 to FOptionalTables.Count - 1 do
        if ATableType.AsCardinal = FOptionalTables[TableIndex].TableType.AsCardinal then
          Exit(FOptionalTables[TableIndex]);
  end;
end;

function TPascalTypeFontFace.GetTableByTableClass(TableClass: TCustomPascalTypeNamedTableClass): TCustomPascalTypeNamedTable;
var
  TableIndex: Integer;
begin
  Result := inherited GetTableByTableClass(TableClass);

  if (Result = nil) then
  begin
    if TableClass = HorizontalMetrics.ClassType then
      Result := HorizontalMetrics
    else
    if TableClass = CharacterMap.ClassType then
      Result := CharacterMap
    else
      for TableIndex := 0 to FOptionalTables.Count - 1 do
        if FOptionalTables[TableIndex].ClassType = TableClass then
          Exit(FOptionalTables[TableIndex]);
  end;
end;

function TPascalTypeFontFace.GetTableByTableName(const TableName: TTableName): TCustomPascalTypeNamedTable;
var
  TableIndex: Integer;
begin
  Result := inherited GetTableByTableName(TableName);

  if (Result = nil) then
  begin
    if CompareTableType(HorizontalMetrics.TableType, TableName) then
      Result := HorizontalMetrics
    else
    if CompareTableType(CharacterMap.TableType, TableName) then
      Result := CharacterMap
    else
      for TableIndex := 0 to FOptionalTables.Count - 1 do
        if CompareTableType(FOptionalTables[TableIndex].TableType, TableName) then
          Exit(FOptionalTables[TableIndex]);
  end;
end;

function TPascalTypeFontFace.ContainsTable(TableType: TTableType): Boolean;
begin
  Result := GetTableByTableType(TableType) <> nil;
end;

function TPascalTypeFontFace.GetTableCount: Integer;
begin
  Result := 7 + FOptionalTables.Count;
end;

procedure TPascalTypeFontFace.LoadTableFromStream(Stream: TStream; TableEntry: TPascalTypeDirectoryTableEntry);
var
  MemoryStream: TMemoryStream;
  TableClass  : TCustomPascalTypeNamedTableClass;
  CurrentTable: TCustomPascalTypeNamedTable;
begin
  MemoryStream := TMemoryStream.Create;
  try
    // set stream position
    Stream.Position := TableEntry.Offset;

    // copy from stream
    MemoryStream.CopyFrom(Stream, 4 * ((TableEntry.Length + 3) div 4));

{$IFDEF ChecksumTest}
    ValidateChecksum(MemoryStream, TableEntry);
{$ENDIF}
    // reset memory stream position
    MemoryStream.Seek(soFromBeginning, 0);

    // restore original table length
    MemoryStream.Size := TableEntry.Length;

    TableClass := FindPascalTypeTableByType(TableEntry.TableType);
    if TableClass <> nil then
    begin
      CurrentTable := TableClass.Create(RootTable);
      try
        // load table from stream
        try
          CurrentTable.LoadFromStream(MemoryStream);

          // assign tables
          if TableClass = TPascalTypeHeaderTable then
            HeaderTable.Assign(CurrentTable)
          else
          if TableClass = TPascalTypeHorizontalHeaderTable then
            HorizontalHeader.Assign(CurrentTable)
          else
          if TableClass = TPascalTypeHorizontalMetricsTable then
            HorizontalMetrics.Assign(CurrentTable)
          else
          if TableClass = TPascalTypePostscriptTable then
            PostScriptTable.Assign(CurrentTable)
          else
          if TableClass = TPascalTypeMaximumProfileTable then
            MaximumProfile.Assign(CurrentTable)
          else
          if TableClass = TPascalTypeNameTable then
            NameTable.Assign(CurrentTable)
          else
          if TableClass = TPascalTypeCharacterMapTable then
            CharacterMap.Assign(CurrentTable)
          else
          if TableClass = TPascalTypeOS2Table then
          begin
            Assert(FOS2Table = nil);
            FOS2Table := TPascalTypeOS2Table(CurrentTable);
            CurrentTable := nil;
          end else
          begin
            FOptionalTables.Add(CurrentTable);
            CurrentTable := nil;
          end;

        except
{$IFDEF IgnoreIncompleteOptionalTables}
          on E: EPascalTypeTableIncomplete do
          begin
            if (TableClass = TPascalTypeHeaderTable) or
              (TableClass = TPascalTypeHorizontalHeaderTable) or
              (TableClass = TPascalTypeHorizontalMetricsTable) or
              (TableClass = TPascalTypePostscriptTable) or
              (TableClass = TPascalTypeMaximumProfileTable) or
              (TableClass = TPascalTypeNameTable) then
              raise;
          end;
{$ELSE}
          raise
{$ENDIF}
        end;

      finally
        // dispose temporary table
        CurrentTable.Free;
      end;
    end else
    begin
      CurrentTable := TPascalTypeUnknownTable.Create(RootTable, TableEntry.TableType);
      CurrentTable.LoadFromStream(Stream);
      FOptionalTables.Add(CurrentTable);
    end;

  finally
    MemoryStream.Free;
  end;
end;

procedure TPascalTypeFontFace.SaveToStream(Stream: TStream);
var
  DirectoryTable: TPascalTypeDirectoryTable;
  TableIndex    : Integer;
  NamedTable    : TCustomPascalTypeNamedTable;
  MemoryStream  : TMemoryStream;
begin
  // create directory table
  DirectoryTable := TPascalTypeDirectoryTable.Create(RootTable);

  try
    DirectoryTable.ClearAndBuildRequiredEntries;

    // build directory table
    for TableIndex := 0 to FOptionalTables.Count - 1 do
      DirectoryTable.AddTableEntry(FOptionalTables[TableIndex].TableType);

    // write temporary directory to determine its size
    SaveToStream(Stream);

    // build directory table
    for TableIndex := 0 to TableCount - 1 do
    begin
      NamedTable := GetTableByTableType(DirectoryTable.TableList[TableIndex].TableType);
      Assert(NamedTable <> nil);

      DirectoryTable.TableList[TableIndex].Offset := Stream.Position;

      MemoryStream := TMemoryStream.Create;
      try
        NamedTable.SaveToStream(MemoryStream);

        // store original stream length
        DirectoryTable.TableList[TableIndex].Length := MemoryStream.Size;

        // extend to a modulo 4 size
        MemoryStream.Size := 4 * ((DirectoryTable.TableList[TableIndex].Length + 3) div 4);

        // calculate checksum
        DirectoryTable.TableList[TableIndex].Checksum := CalculateCheckSum(MemoryStream);

        // reset stream position
        MemoryStream.Position := 0;

        // copy streams
        Stream.CopyFrom(MemoryStream, DirectoryTable.TableList[TableIndex].Length);
      finally
        MemoryStream.Free;
      end;
    end;

    // reset stream position
    Stream.Position := 0;

    // write final directory
    SaveToStream(Stream);
  finally
    DirectoryTable.Free;
  end;
end;

end.
