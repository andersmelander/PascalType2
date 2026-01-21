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
  PascalType.Types,
  PascalType.Classes,
  PascalType.Unicode,
  PascalType.GlyphString,
  PascalType.FontFace,
  PascalType.Tables,
  PascalType.Tables.TrueType.Directory,
  PascalType.Tables.TrueType.head,
  PascalType.Tables.TrueType.name,
  PascalType.Tables.TrueType.glyf,
  PascalType.Tables.TrueType.cmap,
  PascalType.Tables.TrueType.maxp,
  PascalType.Tables.TrueType.hmtx,
  PascalType.Tables.TrueType.hhea,
  PascalType.Tables.TrueType.vmtx,
  PascalType.Tables.TrueType.os2,
  PascalType.Tables.TrueType.post,
  PascalType.Tables.TrueType.Panose;

type
  TTrueTypeGlyphMetric = record
    HorizontalMetric: THorizontalMetric;
    VerticalMetric: TVerticalMetric;
  end;

type
  TCustomPascalTypeFontFace = class;

//------------------------------------------------------------------------------
//
//              TFontGlyphString
//
//------------------------------------------------------------------------------
// A glyph string with knowledge about the font
//------------------------------------------------------------------------------
  TFontGlyphString = class(TPascalTypeGlyphString)
  private
    FFont: TCustomPascalTypeFontFace;
  protected
    function GetGlyphClassID(AGlyph: TPascalTypeGlyph): integer; override;
    function GetMarkAttachmentType(AGlyph: TPascalTypeGlyph): integer; override;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace; const ACodePoints: TPascalTypeCodePoints); virtual;

    procedure HideDefaultIgnorables; override;

    property Font: TCustomPascalTypeFontFace read FFont;
  end;

  TFontGlyphStringClass = class of TFontGlyphString;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeFontFace
//
//------------------------------------------------------------------------------
// A TrueType/OpenType font
//------------------------------------------------------------------------------
  TCustomPascalTypeFontFace = class abstract(TCustomPascalTypeFontFacePersistent, IPascalTypeFontFace)
  strict protected const
{$IFDEF MSWINDOWS}
    PreferredPlatform = piMicrosoft; // This is strange. Why wouldn't we always prefer Unicode?
    PreferredLanguage = 1033;
{$ELSE}
    PreferredPlatform = piUnicode;
    PreferredLanguage = 3;
{$ENDIF}
  strict protected type
    TTableList = TObjectList<TCustomPascalTypeNamedTable>;
    TTableLookup = TDictionary<TTableType, TCustomPascalTypeNamedTable>;
  strict private
    FVersion: Cardinal;
    FRootTable: TCustomPascalTypeTable;

    // We keep the tables in two lists in order to avoid going through
    // TDictionary.Values.ToArray when we just need a list of tables.
    FTables: TTableList;
    FTableLookup: TTableLookup;

    // Required table shortcuts
    FHeaderTable: TPascalTypeHeaderTable;
    FHorizontalHeader: TPascalTypeHorizontalHeaderTable;
    FMaximumProfile: TPascalTypeMaximumProfileTable;
    FNameTable: TPascalTypeNameTable;
    FPostScriptTable: TPascalTypePostscriptTable;
  private
    function GetFontName: string;
    function GetFontStyle: TFontStyles;
    function GetFontFamilyName: string;
    function GetFontSubFamilyName: string;
    function GetFontVersion: string;
    function GetUniqueIdentifier: string;
    function GetTable(Index: integer): TCustomPascalTypeNamedTable;
    function GetTableCount: Integer;
  protected
    procedure Loaded; virtual;
    procedure Clear; virtual;
    procedure DirectoryTableLoaded(DirectoryTable: TPascalTypeDirectoryTable); virtual;
    procedure LoadTablesFromStream(Stream: TStream; const TableList: TPascalTypeDirectoryTableList); virtual;
    function LoadTableFromStream(Stream: TStream; const TableEntry: TDirectoryTableEntry): TCustomPascalTypeNamedTable; virtual;
    function GetGlyphStringClass: TFontGlyphStringClass; virtual;

    property RootTable: TCustomPascalTypeTable read FRootTable;
    property AllTables: TTableList read FTables;
    property TableLookup: TTableLookup read FTableLookup;

{$IFDEF ChecksumTest}
    procedure ValidateChecksum(Stream: TStream; TableEntry: TDirectoryTableEntry); virtual;
{$ENDIF}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;

    function CreateGlyphString(const ACodePoints: TPascalTypeCodePoints): TFontGlyphString; virtual;

    // IPascalTypeFontFaceTable
    function GetTableByTableName(const ATableName: TTableName): TCustomPascalTypeNamedTable; virtual;
    function GetTableByTableType(const ATableType: TTableType): TCustomPascalTypeNamedTable; virtual;
    function GetTableByTableClass(ATableClass: TCustomPascalTypeNamedTableClass): TCustomPascalTypeNamedTable; virtual;

    function ContainsTable(const ATableType: TTableType): Boolean;

    function GetGlyphByCodePoint(ACodePoint: TPascalTypeCodePoint): Integer; overload; virtual; abstract;
    function GetGlyphByCodePoint(ACodePoint: Word): Integer; overload;
    function HasGlyphByCodePoint(ACodePoint: TPascalTypeCodePoint): boolean;
    function GetGlyphByCharacter(ACharacter: WideChar): Integer; overload;
    function GetGlyphByCharacter(ACharacter: AnsiChar): Integer; overload;

    function GetAdvanceWidth(GlyphIndex: Word): Word; virtual;

    // Font file version/type
    property Version: Cardinal read FVersion;

    property Tables[Index: integer]: TCustomPascalTypeNamedTable read GetTable;
    property TableCount: integer read GetTableCount;

    // Required tables
    property HeaderTable: TPascalTypeHeaderTable read FHeaderTable;
    property HorizontalHeader: TPascalTypeHorizontalHeaderTable read FHorizontalHeader;
    property MaximumProfile: TPascalTypeMaximumProfileTable read FMaximumProfile;
    property NameTable: TPascalTypeNameTable read FNameTable;
    property PostScriptTable: TPascalTypePostscriptTable read FPostScriptTable;

    // Basic font properties
    property FontFamilyName: string read GetFontFamilyName;
    property FontName: string read GetFontName;
    property FontStyle: TFontStyles read GetFontStyle;
    property FontSubFamilyName: string read GetFontSubFamilyName;
    property FontVersion: string read GetFontVersion;
    property UniqueIdentifier: string read GetUniqueIdentifier;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFontFace
//
//------------------------------------------------------------------------------
// Complete font reader (maybe someday also a writer)
//------------------------------------------------------------------------------
  TPascalTypeFontFace = class(TCustomPascalTypeFontFace)
  public
    const MaxCompositeGlyphDepth = 8; // Max recursion depth when resolving composite glyphs
  strict private
    // Shortcuts to required tables
    FHorizontalMetrics: TPascalTypeHorizontalMetricsTable;
    FCharacterMap: TPascalTypeCharacterMapTable;
    FOS2Table: TPascalTypeOS2Table;

    // Not required, but pretty important
    FGlyphData: TTrueTypeFontGlyphDataTable;
  private
    function GetGlyphData(Index: Integer): TCustomTrueTypeFontGlyphData;
    function GetPanose: TCustomPascalTypePanoseTable;
    function GetBoundingBox: TRect;
    function GetGlyphCount: Word;
  protected
    function DoGetGlyphPath(GlyphIndex: Word; Depth: integer): TPascalTypePath;
    procedure Loaded; override;
    procedure Clear; override;
    function LoadTableFromStream(Stream: TStream; const TableEntry: TDirectoryTableEntry): TCustomPascalTypeNamedTable; override;
  public
    function CreateLayoutEngine: TObject; override;

    procedure SaveToStream(Stream: TStream); override;

    function GetGlyphMetric(GlyphIndex: Word): TTrueTypeGlyphMetric;
    function GetAdvanceWidth(GlyphIndex: Word): Word; override;
    function GetKerning(Last, Next: Word): Word;

    function GetGlyphByCodePoint(ACodePoint: TPascalTypeCodePoint): Integer; override;

    function GetGlyphPath(GlyphIndex: Word): TPascalTypePath; // TODO : Use TFloatPoint

    property GlyphData[Index: Integer]: TCustomTrueTypeFontGlyphData read GetGlyphData;

    // Redirected sub properties
    property Panose: TCustomPascalTypePanoseTable read GetPanose;
    property BoundingBox: TRect read GetBoundingBox;
    property GlyphCount: Word read GetGlyphCount;

    // Required tables
    property HeaderTable;
    property HorizontalHeader;
    property MaximumProfile;
    property NameTable;
    property PostScriptTable;
    property GlyphTable: TTrueTypeFontGlyphDataTable read FGlyphData;
    property HorizontalMetrics: TPascalTypeHorizontalMetricsTable read FHorizontalMetrics;
    property CharacterMap: TPascalTypeCharacterMapTable read FCharacterMap;
    property OS2Table: TPascalTypeOS2Table read FOS2Table;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFontFaceScan
//
//------------------------------------------------------------------------------
// Basic font reader used to extract basic properties from a font file
//------------------------------------------------------------------------------
type
  TPascalTypeFontFaceScan = class(TCustomPascalTypeFontFace)
  protected
    function LoadTableFromStream(Stream: TStream; const TableEntry: TDirectoryTableEntry): TCustomPascalTypeNamedTable; override;
    procedure Loaded; override;
  public
    function GetGlyphByCodePoint(ACodePoint: TPascalTypeCodePoint): Integer; override;
    procedure SaveToStream(Stream: TStream); override;
    function CreateLayoutEngine: TObject; override;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  Math,
  PascalType.Math,
  PascalType.Tables.TrueType,
  PascalType.Tables.OpenType.GDEF,
  PascalType.Shaper.Layout.OpenType,
  PascalType.ResourceStrings;

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
{$IFOPT Q+}{$DEFINE Q_PLUS}{$OVERFLOWCHECKS OFF}{$ENDIF}
    Result := Result + Swap32(PCardinal(Data)^);
{$IFDEF Q_PLUS}{$OVERFLOWCHECKS ON}{$UNDEF Q_PLUS}{$ENDIF}
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

function CalculateCheckSum(Stream: TStream; Size: Cardinal): Cardinal; overload;
var
  I    : Integer;
begin
  // Ensure that at least one cardinal is in the stream
  if Size < 4 then
    Exit(0);

  // set position to beginning of the stream
//  Stream.Seek(0, soFromBeginning);

  Assert(Size mod 4 = 0);

  if Stream is TMemoryStream then
    Result := CalculateCheckSum(TMemoryStream(Stream).Memory, Size div 4)
  else
  begin
    // read first cardinal
    Result := BigEndianValue.ReadCardinal(Stream);

    // read subsequent cardinals
    for I := 1 to (Size div 4) - 1 do
    begin
{$IFOPT Q+}{$DEFINE Q_PLUS}{$OVERFLOWCHECKS OFF}{$ENDIF}
      Result := Result + BigEndianValue.ReadCardinal(Stream);
{$IFDEF Q_PLUS}{$OVERFLOWCHECKS ON}{$UNDEF Q_PLUS}{$ENDIF}
    end;
  end;
end;

function CalculateHeadCheckSum(Stream: TMemoryStream): Cardinal;
var
  I    : Integer;
begin
  with Stream do
  begin
    // ensure that at least one cardinal is in the stream
    if Size < 4 then
      Exit(0);

    // set position to beginning of the stream
    Seek(0, soFromBeginning);

    // read first cardinal
    Result := BigEndianValue.ReadCardinal(Stream);

    // read subsequent cardinals
    for I := 1 to (Size div 4) - 1 do
    begin
      if I = 2 then
        Continue;
      Result := Result + BigEndianValue.ReadCardinal(Stream);
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//              TFontGlyphString
//
//------------------------------------------------------------------------------
constructor TFontGlyphString.Create(AFont: TCustomPascalTypeFontFace; const ACodePoints: TPascalTypeCodePoints);
begin
  FFont := AFont;
  inherited Create(ACodePoints);
end;

function TFontGlyphString.GetGlyphClassID(AGlyph: TPascalTypeGlyph): integer;
var
  GDEF: TOpenTypeGlyphDefinitionTable;
begin
  GDEF := Font.GetTableByTableType('GDEF') as TOpenTypeGlyphDefinitionTable;
  if (GDEF <> nil) and (GDEF.GlyphClassDefinition <> nil) then
    Result := GDEF.GlyphClassDefinition.GetClassID(AGlyph.GlyphID)
  else
    Result := inherited GetGlyphClassID(AGlyph);
end;

function TFontGlyphString.GetMarkAttachmentType(AGlyph: TPascalTypeGlyph): integer;
var
  GDEF: TOpenTypeGlyphDefinitionTable;
begin
  GDEF := Font.GetTableByTableType('GDEF') as TOpenTypeGlyphDefinitionTable;
  if (GDEF <> nil) and (GDEF.MarkAttachmentClassDefinition <> nil) then
    Result := GDEF.MarkAttachmentClassDefinition.GetClassID(AGlyph.GlyphID)
  else
    Result := inherited GetMarkAttachmentType(AGlyph);
end;

procedure TFontGlyphString.HideDefaultIgnorables;
var
  SpaceGlyph: Word;
  Glyph: TPascalTypeGlyph;
begin
  SpaceGlyph := Font.GetGlyphByCodePoint(32);
  for Glyph in Self do
    if (Length(Glyph.CodePoints) > 0) and (PascalTypeUnicode.IsDefaultIgnorable(Glyph.CodePoints[0])) then
    begin
      Glyph.GlyphID := SpaceGlyph;
      Glyph.XAdvance := 0;
      Glyph.YAdvance := 0;
    end;
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeTableRoot
//
//------------------------------------------------------------------------------
// Root table. Just used to provide access to the font from the tables.
//------------------------------------------------------------------------------
type
  TPascalTypeTableRoot = class(TCustomPascalTypeTable)
  private
    FFontFace: IPascalTypeFontFace;
  protected
    function GetFontFace: IPascalTypeFontFace; override;
  public
    constructor Create(const AFontFace: IPascalTypeFontFace); reintroduce;
    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
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

procedure TPascalTypeTableRoot.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  raise EPascalTypeError.Create(RCStrNotImplemented);
end;

procedure TPascalTypeTableRoot.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeError.Create(RCStrNotImplemented);
end;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeFontFace
//
//------------------------------------------------------------------------------
constructor TCustomPascalTypeFontFace.Create;
begin
  inherited;
  FRootTable := TPascalTypeTableRoot.Create(Self);
  FTables := TTableList.Create;
  FTableLookup := TTableLookup.Create;
end;

destructor TCustomPascalTypeFontFace.Destroy;
begin
  FTableLookup.Free;
  FTables.Free;
  FRootTable.Free;
  inherited;
end;

function TCustomPascalTypeFontFace.GetTable(Index: integer): TCustomPascalTypeNamedTable;
begin
  Result := FTables[Index];
end;

function TCustomPascalTypeFontFace.GetTableCount: Integer;
begin
  Result := FTables.Count;
end;

procedure TCustomPascalTypeFontFace.DirectoryTableLoaded(DirectoryTable: TPascalTypeDirectoryTable);
begin
  if (Version = sfntVersionAppleTT) then
  begin
    if (not DirectoryTable.Contains(ttLoca)) then
      raise EPascalTypeError.Create(RCStrNoIndexToLocationTable);

    if (not DirectoryTable.Contains(ttGlyf)) then
      raise EPascalTypeError.Create(RCStrNoGlyphDataTable);
  end;
end;

function TCustomPascalTypeFontFace.LoadTableFromStream(Stream: TStream; const TableEntry: TDirectoryTableEntry): TCustomPascalTypeNamedTable;
var
  TableClass: TCustomPascalTypeNamedTableClass;
  Table: TCustomPascalTypeNamedTable;
  UnknownTableType: boolean;
begin
  Result := nil;

  Stream.Position := TableEntry.Offset;

{$IFDEF ChecksumTest}
  ValidateChecksum(Stream, TableEntry.Length);
{$ENDIF}

  TableClass := PascalTypeTableClasses.FindTableByType(TableEntry.TableType);

  UnknownTableType := (TableClass = nil);
  if (UnknownTableType) then
    TableClass := TPascalTypeUnknownTable;

  Table := TableClass.Create(RootTable);
  try
    if (UnknownTableType) then
      TPascalTypeUnknownTable(Table).TableType := TableEntry.TableType;

    try

      Table.LoadFromStream(Stream, TableEntry.Length);

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
          raise; // Table is mandatory; fail with an error

        exit; // Table is optional; We can survive without it
      end;
{$ELSE}
      raise
{$ENDIF}
    end;

    // Add to lookup first in case there's a duplicate table type
    TableLookup.Add(Table.TableType, Table);

    // Transfer ownership to list
    FTables.Add(Table);

    // Return value and clear Table so it's not freed in finally
    Result := Table;
    Table := nil;


    case Result.TableType.AsCardinal of
      ttHead:
        FHeaderTable := Result as TPascalTypeHeaderTable;

      ttMaxp:
        FMaximumProfile := Result as TPascalTypeMaximumProfileTable;

      ttHhea:
        FHorizontalHeader := Result as TPascalTypeHorizontalHeaderTable;

      ttName:
        FNameTable := Result as TPascalTypeNameTable;

      ttPost:
        FPostScriptTable := Result as TPascalTypePostscriptTable;
    end;

  finally
    // Free table unless it is now owned by FTables
    Table.Free;
  end;
end;

function TCustomPascalTypeFontFace.GetFontFamilyName: string;
begin
  if (not FNameTable.TryGetName(niTypographicFamily, PreferredPlatform, PreferredLanguage, Result)) then
    FNameTable.TryGetName(niFamily, PreferredPlatform, PreferredLanguage, Result, Result);
end;

function TCustomPascalTypeFontFace.GetFontSubFamilyName: string;
begin
  if (not FNameTable.TryGetName(niTypographicSubfamily, PreferredPlatform, PreferredLanguage, Result)) then
    FNameTable.TryGetName(niSubfamily, PreferredPlatform, PreferredLanguage, Result, Result);
end;

function TCustomPascalTypeFontFace.GetFontVersion: string;
begin
  FNameTable.TryGetName(niVersion, PreferredPlatform, PreferredLanguage, Result);
end;

function TCustomPascalTypeFontFace.GetUniqueIdentifier: string;
begin
  FNameTable.TryGetName(niUniqueIdentifier, PreferredPlatform, PreferredLanguage, Result);
end;

function TCustomPascalTypeFontFace.GetFontName: string;
begin
  FNameTable.TryGetName(niFullName, PreferredPlatform, PreferredLanguage, Result);
end;

function TCustomPascalTypeFontFace.GetFontStyle: TFontStyles;
begin
  Result := [];
  if msItalic in FHeaderTable.MacStyle then
    Include(Result, fsItalic);

  if msBold in FHeaderTable.MacStyle then
    Include(Result, fsBold);

  if msUnderline in FHeaderTable.MacStyle then
    Include(Result, fsUnderline);
end;

function TCustomPascalTypeFontFace.ContainsTable(const ATableType: TTableType): Boolean;
begin
  Result := FTableLookup.ContainsKey(ATableType);
end;

function TCustomPascalTypeFontFace.GetTableByTableClass(ATableClass: TCustomPascalTypeNamedTableClass): TCustomPascalTypeNamedTable;
begin
  for Result in FTables do
    if (Result.ClassType = ATableClass) then
      exit;
  Result := nil;
end;

function TCustomPascalTypeFontFace.GetTableByTableName(const ATableName: TTableName): TCustomPascalTypeNamedTable;
begin
  if (not FTableLookup.TryGetValue(ATableName, Result)) then
    Result := nil;
end;

function TCustomPascalTypeFontFace.GetTableByTableType(const ATableType: TTableType): TCustomPascalTypeNamedTable;
begin
  if (not FTableLookup.TryGetValue(ATableType, Result)) then
    Result := nil;
end;

procedure TCustomPascalTypeFontFace.Clear;
begin
  BeginUpdate;
  try
    Notify(fnClear);

    FTableLookup.Clear;
    FTables.Clear;

    FHeaderTable := nil;
    FHorizontalHeader := nil;
    FMaximumProfile := nil;
    FNameTable := nil;
    FPostScriptTable := nil;

    Changed;
  finally
    EndUpdate;
  end;
end;

procedure TCustomPascalTypeFontFace.Loaded;
begin
  // Verify that required tables are present
  if (HeaderTable = nil) then
    raise EPascalTypeError.Create(RCStrNoHeaderTable);

  if (HorizontalHeader = nil) then
    raise EPascalTypeError.Create(RCStrNoHorizontalHeaderTable);

  if (MaximumProfile = nil) then
    raise EPascalTypeError.Create(RCStrNoMaximumProfileTable);

  if (NameTable = nil) then
    raise EPascalTypeError.Create(RCStrNoNameTable);

  if (PostScriptTable = nil) then
    raise EPascalTypeError.Create(RCStrNoPostscriptTable);
end;

procedure TCustomPascalTypeFontFace.LoadTablesFromStream(Stream: TStream; const TableList: TPascalTypeDirectoryTableList);
var
  i: integer;
begin
  // Load tables
  for i := 0 to High(TableList) do
  begin
    if (TableLookup.ContainsKey(TableList[i].TableType)) then
      continue;

    LoadTableFromStream(Stream, TableList[i]);
  end;
end;

procedure TCustomPascalTypeFontFace.LoadFromStream(Stream: TStream);
var
  DirectoryTable: TPascalTypeDirectoryTable;
  i: integer;
  Index: integer;
const
  Preload: array of TTableName = ['head', 'maxp', 'loca'];
begin
  BeginUpdate;
  try

    Clear;

    DirectoryTable := TPascalTypeDirectoryTable.Create(FRootTable);
    try
      DirectoryTable.LoadFromStream(Stream, Stream.Size);

      FVersion := DirectoryTable.Version;

      // Directory table has been read, notify
      DirectoryTableLoaded(DirectoryTable);

      // Preload tables that other tables depend on
      for i := 0 to High(Preload) do
      begin
        Index := DirectoryTable.IndexOfTableEntry(Preload[i]);
        if (Index <> -1) then
          LoadTableFromStream(Stream, DirectoryTable.TableList[Index]);
      end;

      LoadTablesFromStream(Stream, DirectoryTable.TableList);

    finally
      DirectoryTable.Free;
    end;

    // Verify required tables and map table shortcuts
    Loaded;

    Changed;
  finally
    EndUpdate;
  end;
end;

{$IFDEF ChecksumTest}

procedure TCustomPascalTypeFontFace.ValidateChecksum(Stream: TStream;
  TableEntry: TDirectoryTableEntry);
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
{$IFOPT Q+}{$DEFINE Q_PLUS}{$OVERFLOWCHECKS OFF}{$ENDIF}
    Checksum := Checksum - BigEndianValue.ReadCardinal(Stream);
{$IFDEF Q_PLUS}{$OVERFLOWCHECKS ON}{$UNDEF Q_PLUS}{$ENDIF}
  end;

  // check checksum
  if (Checksum <> TableEntry.Checksum) then
    raise EPascalTypeChecksumError.CreateFmt(RCStrChecksumError,
      [string(TableEntry.TableType)]);
end;
{$ENDIF}

function TCustomPascalTypeFontFace.GetGlyphStringClass: TFontGlyphStringClass;
begin
  Result := TFontGlyphString;
end;

function TCustomPascalTypeFontFace.CreateGlyphString(const ACodePoints: TPascalTypeCodePoints): TFontGlyphString;
var
  Glyph: TPascalTypeGlyph;
begin
  Result := GetGlyphStringClass.Create(Self, ACodePoints);

  // Map Unicode CodePoints to Glyph IDs
  for Glyph in Result do
    Glyph.GlyphID := GetGlyphByCodePoint(Glyph.CodePoints[0]);
end;


function TCustomPascalTypeFontFace.GetGlyphByCodePoint(ACodePoint: Word): Integer;
begin
  Result := GetGlyphByCodePoint(TPascalTypeCodePoint(ACodePoint));
end;

function TCustomPascalTypeFontFace.GetGlyphByCharacter(ACharacter: WideChar): Integer;
begin
  Result := GetGlyphByCodePoint(TPascalTypeCodePoint(ACharacter));
end;

function TCustomPascalTypeFontFace.GetGlyphByCharacter(ACharacter: AnsiChar): Integer;
begin
  Result := GetGlyphByCodePoint(TPascalTypeCodePoint(ACharacter));
end;

function TCustomPascalTypeFontFace.HasGlyphByCodePoint(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := (GetGlyphByCodePoint(ACodePoint) <> 0);
end;

function TCustomPascalTypeFontFace.GetAdvanceWidth(GlyphIndex: Word): Word;
begin
  Result := HorizontalHeader.AdvanceWidthMax; // Better than nothing :-(
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFontFaceScan
//
//------------------------------------------------------------------------------
function TPascalTypeFontFaceScan.CreateLayoutEngine: TObject;
begin
  Result := nil;
end;

function TPascalTypeFontFaceScan.GetGlyphByCodePoint(ACodePoint: TPascalTypeCodePoint): Integer;
begin
  Result := 0;
end;

procedure TPascalTypeFontFaceScan.Loaded;
begin
  // Verify that required tables are present
  if (HeaderTable = nil) then
    raise EPascalTypeError.Create(RCStrNoHeaderTable);

  if (NameTable = nil) then
    raise EPascalTypeError.Create(RCStrNoNameTable);
end;

function TPascalTypeFontFaceScan.LoadTableFromStream(Stream: TStream; const TableEntry: TDirectoryTableEntry): TCustomPascalTypeNamedTable;
begin
  // We only need to load a very few tables
  case TableEntry.TableType.AsCardinal of
    ttName,
    ttHead:
      Result := inherited;

  else
    Result := nil;
  end;
end;

procedure TPascalTypeFontFaceScan.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFontFace
//
//------------------------------------------------------------------------------
function TPascalTypeFontFace.CreateLayoutEngine: TObject;
begin
  Result := TPascalTypeOpenTypeLayoutEngine.Create(Self);
end;

function TPascalTypeFontFace.GetAdvanceWidth(GlyphIndex: Word): Word;
begin
  if (FHorizontalMetrics <> nil) then
  begin
    if (GlyphIndex < FHorizontalMetrics.HorizontalMetricCount) then
      Result := FHorizontalMetrics.HorizontalMetric[GlyphIndex].AdvanceWidth
    else
      Result := FHorizontalMetrics.HorizontalMetric[0].AdvanceWidth;
  end else
    Result := 0; // Font hasn't been loaded
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

function TPascalTypeFontFace.GetGlyphData(Index: Integer): TCustomTrueTypeFontGlyphData;
begin
  Result := nil;

  if (GlyphTable <> nil) then
    if (Index >= 0) and (Index < GlyphTable.GlyphDataCount) then
      Result := GlyphTable.GlyphData[Index];
end;

function TPascalTypeFontFace.GetGlyphByCodePoint(ACodePoint: TPascalTypeCodePoint): Integer;
begin
  if (CharacterMap <> nil) then
    Result := CharacterMap.GetGlyphByCharacter(ACodePoint)
  else
    Result := 0; // Font hasn't been loaded
end;

function TPascalTypeFontFace.GetGlyphMetric(GlyphIndex: Word): TTrueTypeGlyphMetric;

  procedure DoGetGlyphMetric(GlyphIndex: Word; var MetricIndex: Word; Depth: integer);
  var
    Glyph: TCustomTrueTypeFontGlyphData;
    i: integer;
    CompositeGlyphData: TTrueTypeFontCompositeGlyphData;
  begin
    if (Depth > MaxCompositeGlyphDepth) then
{$ifdef FailOnCompositeGlyphTooDeep}
      raise EPascalTypeError.Create('Composite glyph exceeded recursion depth');
{$else FailOnCompositeGlyphTooDeep}
      exit;
{$endif FailOnCompositeGlyphTooDeep}

    Glyph := GlyphTable.GlyphData[GlyphIndex];

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

          DoGetGlyphMetric(CompositeGlyphData.Glyph[i].GlyphIndex, MetricIndex, Depth + 1);

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
  if (GlyphTable = nil) then
    exit;

  MetricIndex := GlyphIndex;
  DoGetGlyphMetric(GlyphIndex, MetricIndex, 0);

  Result.HorizontalMetric := FHorizontalMetrics.HorizontalMetric[MetricIndex];

  VerticalMetricsTable := TPascalTypeVerticalMetricsTable(GetTableByTableType(TPascalTypeVerticalMetricsTable.GetTableType));
  // TODO : Fall back to something for vertical metric if 'vmtx' isn't present
  if (VerticalMetricsTable <> nil) then
    Result.VerticalMetric := VerticalMetricsTable.VerticalMetric[MetricIndex];
end;

function TPascalTypeFontFace.DoGetGlyphPath(GlyphIndex: Word; Depth: integer): TPascalTypePath;

  procedure AppendPath(var Path: TPascalTypePath; const Append: TPascalTypePath);
  var
    NewIndex: integer;
    Contour: TPascalTypeContour;
  begin
    if (Length(Append) = 0) then
      exit;

    NewIndex := Length(Path);

    SetLength(Path, Length(Path) + Length(Append));

    for Contour in Append do
    begin
      Path[NewIndex] := Contour;
      Inc(NewIndex);
    end;
  end;

  function AffineTransformation(const Path: TPascalTypePath; const AffineTransformationMatrix: TSmallScaleMatrix; ScaleOffset: boolean): TPascalTypePath;
  const
    q: Single = 33.0 / 35536.0;
  var
    i, j: integer;
    m0, n0: Single;
    m, n: Single;
    TempX: Single;
    OffsetX, OffsetY: Single;
    Contour: TPascalTypeContour;
  begin
    SetLength(Result, Length(Path));

    // See: https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6glyf.html#COMPOUNDGLYPHS

    m0 := Max(Abs(AffineTransformationMatrix[0,0]), Abs(AffineTransformationMatrix[0,1]));
    n0 := Max(Abs(AffineTransformationMatrix[1,0]), Abs(AffineTransformationMatrix[1,1]));

    OffsetX := AffineTransformationMatrix[0,2];
    OffsetY := AffineTransformationMatrix[1,2];

    if (m0 <> 0) and (n0 <> 0) then
    begin
      if (ScaleOffset) then
      begin
        if (Abs(AffineTransformationMatrix[0,0]) - Abs(AffineTransformationMatrix[1,0]) <= q) then
          m := 2 * m0
        else
          m := m0;

        if (Abs(AffineTransformationMatrix[0,1]) - Abs(AffineTransformationMatrix[1,1]) <= q) then
          n := 2 * n0
        else
          n := n0;

        OffsetX := OffsetX * m;
        OffsetY := OffsetY * n;
      end;

      // Transform all points in path
      for i := 0 to High(Path) do
      begin
        Contour := Copy(Path[i]);
        Result[i] := Contour;
        for j := 0 to High(Contour) do
        begin
          if (ScaleOffset) then
          begin
            Contour[j].XPos := Contour[j].XPos + OffsetX;
            Contour[j].YPos := Contour[j].YPos + OffsetY;
            TempX :=           AffineTransformationMatrix[0,0] * Contour[j].XPos + AffineTransformationMatrix[1,0] * Contour[j].YPos;
            Contour[j].YPos := AffineTransformationMatrix[0,1] * Contour[j].XPos + AffineTransformationMatrix[1,1] * Contour[j].YPos;
            Contour[j].XPos := TempX;
          end else
          begin
            TempX :=           AffineTransformationMatrix[0,0] * Contour[j].XPos + AffineTransformationMatrix[1,0] * Contour[j].YPos + OffsetX;
            Contour[j].YPos := AffineTransformationMatrix[0,1] * Contour[j].XPos + AffineTransformationMatrix[1,1] * Contour[j].YPos + OffsetY;
            Contour[j].XPos := TempX;
          end;
        end;
      end;

    end else
    if (OffsetX <> 0) or (OffsetY <> 0) then
    begin
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
    ScaleOffset: boolean;
  begin
    // TODO : Point-to-point translation (GLYF_ARGS_ARE_XY_VALUES not set)
    SetLength(Result, 0);
    // Decompose compound ParentGlyph
    for i := 0 to ParentGlyph.GlyphCount-1 do
    begin
      CompositeGlyph := ParentGlyph.Glyph[i];

      // Recurse
      GlyphPath := DoGetGlyphPath(CompositeGlyph.GlyphIndex, Depth + 1);

      if (CompositeGlyph.HasAffineTransformationMatrix) then
      begin
        // Apple uses GLYF_SCALED_COMPONENT_OFFSET: First translate, then scale
        // Microsoft uses GLYF_UNSCALED_COMPONENT_OFFSET: First scale, then translate
        if (CompositeGlyph.Flags and TPascalTypeCompositeGlyph.GLYF_SCALED_COMPONENT_OFFSET <> 0) then
          ScaleOffset := True
        else
        if (CompositeGlyph.Flags and TPascalTypeCompositeGlyph.GLYF_UNSCALED_COMPONENT_OFFSET <> 0) then
          ScaleOffset := False
        else
{$IF Defined(MSWINDOWS)}
          ScaleOffset := False;
{$ELSEIF Defined(OSX)}
          ScaleOffset := True;
{$ELSE}
          ScaleOffset := False;
{$IFEND}

        GlyphPath := AffineTransformation(GlyphPath, CompositeGlyph.AffineTransformationMatrix, ScaleOffset);
      end else
      if (CompositeGlyph.HasOffset) then
        GlyphPath := Translate(GlyphPath, CompositeGlyph.OffsetX, CompositeGlyph.OffsetY);

      AppendPath(Result, GlyphPath);
    end;
  end;

var
  Glyph: TCustomTrueTypeFontGlyphData;
begin
  if (Depth > MaxCompositeGlyphDepth) then
{$ifdef FailOnCompositeGlyphTooDeep}
    raise EPascalTypeError.Create('Composite glyph exceeded recursion depth');
{$else FailOnCompositeGlyphTooDeep}
    Exit(nil);
{$endif FailOnCompositeGlyphTooDeep}

  Glyph := TCustomTrueTypeFontGlyphData(GlyphData[GlyphIndex]);

  if (Glyph is TTrueTypeFontSimpleGlyphData) then
    Result := TTrueTypeFontSimpleGlyphData(Glyph).Path
  else
  if Glyph is TTrueTypeFontCompositeGlyphData then
    // Recursively fetch glyph contours
    Result := GetCompositeGlyphPath(TTrueTypeFontCompositeGlyphData(Glyph));
end;

function TPascalTypeFontFace.GetGlyphPath(GlyphIndex: Word): TPascalTypePath;
begin
  Result := DoGetGlyphPath(GlyphIndex, 0);
end;

function TPascalTypeFontFace.GetKerning(Last, Next: Word): Word;
// var
// KernTable : TPascalType
begin
  Result := 0;
  // GetTableByTableType()
end;

function TPascalTypeFontFace.GetPanose: TCustomPascalTypePanoseTable;
begin
  if (FOS2Table <> nil) then
    Result := FOS2Table.Panose
  else
    Result := nil;
end;

procedure TPascalTypeFontFace.Clear;
begin
  inherited;

  FGlyphData := nil;
  FHorizontalMetrics := nil;
  FCharacterMap := nil;
  FOS2Table := nil;
end;

procedure TPascalTypeFontFace.Loaded;
begin
  inherited;

  if (Version = sfntVersionTrueType) and (OS2Table = nil) then
    raise EPascalTypeError.Create(RCStrNoOS2Table);

  if (HorizontalMetrics = nil) then
    raise EPascalTypeError.Create(RCStrNoHorizontalMetricsTable);

  if (CharacterMap = nil) then
    raise EPascalTypeError.Create(RCStrNoCharacterMapTable);

  // Strangely, the glyf table is optional
  (*
  if (GlyphTable = nil) then
    raise EPascalTypeError.Create(RCStrNoGlyphDataTable);
  *)
end;

function TPascalTypeFontFace.LoadTableFromStream(Stream: TStream; const TableEntry: TDirectoryTableEntry): TCustomPascalTypeNamedTable;
begin
  Result := inherited;

  if (Result = nil) then
    exit;

  case Result.TableType.AsCardinal of
    ttHmtx:
      FHorizontalMetrics := Result as TPascalTypeHorizontalMetricsTable;

    ttCmap:
      FCharacterMap := Result as TPascalTypeCharacterMapTable;

    ttGlyf:
      FGlyphData := Result as TTrueTypeFontGlyphDataTable;

    ttOS2:
      FOS2Table := Result as TPascalTypeOS2Table;
  end;
end;

procedure TPascalTypeFontFace.SaveToStream(Stream: TStream);
(*
var
  StartPos: Int64;
  DirectoryTable: TPascalTypeDirectoryTable;
  TableIndex    : Integer;
  NamedTable    : TCustomPascalTypeNamedTable;
  MemoryStream  : TMemoryStream;
*)
begin
(* TODO
  StartPos := Stream.Position;
  // create directory table
  DirectoryTable := TPascalTypeDirectoryTable.Create(RootTable);

  try
    DirectoryTable.ClearAndBuildRequiredEntries;

    // build directory table
    for TableIndex := 0 to AllTables.Count-1 do
      DirectoryTable.AddTableEntry(AllTables[TableIndex].TableType);

    // write temporary directory to determine its size
    DirectoryTable.SaveToStream(Stream);

    // build directory table
    for TableIndex := 0 to AllTables.Count-1 do
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
        MemoryStream.Position := 0;
        DirectoryTable.TableList[TableIndex].Checksum := CalculateCheckSum(MemoryStream, MemoryStream.Size);

        // copy streams
        MemoryStream.Position := 0;
        Stream.CopyFrom(MemoryStream, DirectoryTable.TableList[TableIndex].Length);
      finally
        MemoryStream.Free;
      end;
    end;

    // reset stream position
    Stream.Position := StartPos;

    // write final directory
    DirectoryTable.SaveToStream(Stream);
  finally
    DirectoryTable.Free;
  end;
*)
end;

end.
