unit PT_TablesOpenType;

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
  Classes, Contnrs, PT_Types, PT_Classes, PT_Tables;

type
  TCustomOpenTypeNamedTable = class(TCustomPascalTypeNamedTable)
  protected
    class function GetDisplayName: string; virtual; abstract;
  public
    property DisplayName: string read GetDisplayName;
  end;

  TCustomOpenTypeVersionedNamedTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: TFixedPoint; // Version of the GDEF table-initially = 0x00010002
    procedure SetVersion(const Value: TFixedPoint);
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
  end;

  TCustomOpenTypeClassDefinitionTable = class(TCustomPascalTypeTable)
  protected
    class function GetClassFormat: Word; virtual; abstract;
  public
    property ClassFormat: Word read GetClassFormat;
  end;

  TOpenTypeClassDefinitionTableClass = class of TCustomOpenTypeClassDefinitionTable;

  TOpenTypeClassDefinitionFormat1Table = class(TCustomOpenTypeClassDefinitionTable)
  private
    FStartGlyph      : Word;          // First GlyphID of the ClassValueArray
    FClassValueArray : array of Word; // Array of Class Values-one per GlyphID
    procedure SetStartGlyph(const Value: Word);
    function GetClassValueCount: Integer;
    function GetClassValue(Index: Integer): Word;
  protected
    class function GetClassFormat: Word; override;

    procedure StartGlyphChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property StartGlyph: Word read FStartGlyph write SetStartGlyph;
    property ClassValueCount: Integer read GetClassValueCount;
    property ClassValue[Index: Integer]: Word read GetClassValue;
  end;

  TClassRangeRecord = packed record
    StartGlyph : Word; // First GlyphID in the range
    EndGlyph   : Word; // Last GlyphID in the range
    GlyphClass : Word; // Applied to all glyphs in the range
  end;

  TOpenTypeClassDefinitionFormat2Table = class(TCustomOpenTypeClassDefinitionTable)
  private
    FClassRangeRecords: array of TClassRangeRecord; // Array of ClassRangeRecords-ordered by Start GlyphID
    function GetClassRangeRecord(Index: Integer): TClassRangeRecord;
    function GetClassRangeRecordCount: Integer;

  protected
    class function GetClassFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property ClassRangeRecordCount: Integer read GetClassRangeRecordCount;
    property ClassRangeRecord[Index: Integer]: TClassRangeRecord
      read GetClassRangeRecord;
  end;

  TOpenTypeMarkGlyphSetTable = class(TCustomPascalTypeTable)
  private
    FTableFormat: Word; // Format identifier == 1
    FCoverage   : array of Cardinal; // Array of offsets to mark set coverage tables.
    function GetCoverage(Index: Integer): Cardinal;
    function GetCoverageCount: Integer;
    procedure SetTableFormat(const Value: Word);
  protected
    procedure TableFormatChanged; virtual;
  public
    constructor Create; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property TableFormat: Word read FTableFormat write SetTableFormat;
    property CoverageCount: Integer read GetCoverageCount;
    property Coverage[Index: Integer]: Cardinal read GetCoverage;
  end;


  // table 'BASE'

  TOpenTypeBaselineTagListTable = class(TCustomPascalTypeTable)
  private
    FBaseLineTags: array of TTableType;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TBaseLineScriptRecord = packed record
    Tag          : TTableType;
    ScriptOffset : Word;
    // still todo see: http://www.microsoft.com/typography/otspec/base.htm
  end;

  TOpenTypeBaselineScriptListTable = class(TCustomPascalTypeTable)
  private
    FBaseLineScript: array of TBaseLineScriptRecord;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TOpenTypeAxisTable = class(TCustomPascalTypeTable)
  private
    FBaseLineTagList: TOpenTypeBaselineTagListTable;
  public
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TOpenTypeBaselineTable = class(TCustomOpenTypeVersionedNamedTable)
  private
    FHorizontalAxis: TOpenTypeAxisTable;
    FVerticalAxis  : TOpenTypeAxisTable;
  public
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'GDEF'

  TOpenTypeGlyphDefinitionTable = class(TCustomOpenTypeVersionedNamedTable)
  private
    FGlyphClassDef      : TCustomOpenTypeClassDefinitionTable; // Class definition table for glyph type
    FAttachList         : Word;                                // Offset to list of glyphs with attachment points-from beginning of GDEF header (may be NULL)
    FLigCaretList       : Word;                                // Offset to list of positioning points for ligature carets-from beginning of GDEF header (may be NULL)
    FMarkAttachClassDef : TCustomOpenTypeClassDefinitionTable; // Class definition table for mark attachment type (may be nil)
    FMarkGlyphSetsDef   : TOpenTypeMarkGlyphSetTable;          // Table of mark set definitions (may be nil)
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property GlyphClassDefinition: TCustomOpenTypeClassDefinitionTable read FGlyphClassDef;
    property MarkAttachmentClassDefinition: TCustomOpenTypeClassDefinitionTable read FMarkAttachClassDef;
    property MarkGlyphSet: TOpenTypeMarkGlyphSetTable read FMarkGlyphSetsDef;
  end;

  TTagOffsetRecord = packed record
    Tag: TTableType;
    Offset: Word;
  end;

  TCustomOpenTypeLanguageSystemTable = class(TCustomOpenTypeNamedTable)
  private
    FLookupOrder     : Word;          // = NULL (reserved for an offset to a reordering table)
    FReqFeatureIndex : Word;          // Index of a feature required for this language system- if no required features = 0xFFFF
    FFeatureIndices  : array of Word; // Array of indices into the FeatureList-in arbitrary order
    function GetFeatureIndex(Index: Integer): Word;
    function GetFeatureIndexCount: Integer;
    procedure SetLookupOrder(const Value: Word);
    procedure SetReqFeatureIndex(const Value: Word);
  protected
    procedure LookupOrderChanged; virtual;
    procedure ReqFeatureIndexChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property LookupOrder: Word read FLookupOrder write SetLookupOrder;
    property RequiredFeatureIndex: Word read FReqFeatureIndex write SetReqFeatureIndex;
    property FeatureIndexCount: Integer read GetFeatureIndexCount;
    property FeatureIndex[Index: Integer]: Word read GetFeatureIndex;
  end;

  TOpenTypeLanguageSystemTableClass = class of TCustomOpenTypeLanguageSystemTable;

  TOpenTypeDefaultLanguageSystemTable = class(TCustomOpenTypeLanguageSystemTable)
  protected
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;
  end;

  TCustomOpenTypeScriptTable = class(TCustomOpenTypeNamedTable)
  private
    FDefaultLangSys      : TCustomOpenTypeLanguageSystemTable;
    FLanguageSystemTables: TPascalTypeTableInterfaceList<TCustomOpenTypeNamedTable>;
    function GetLanguageSystemTable(Index: Integer): TCustomOpenTypeNamedTable;
    function GetLanguageSystemTableCount: Integer;
    procedure SetDefaultLangSys(const Value: TCustomOpenTypeLanguageSystemTable);
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property DefaultLangSys: TCustomOpenTypeLanguageSystemTable read FDefaultLangSys write SetDefaultLangSys;
    property LanguageSystemTableCount: Integer read GetLanguageSystemTableCount;
    property LanguageSystemTable[Index: Integer]: TCustomOpenTypeNamedTable read GetLanguageSystemTable;
  end;

  TOpenTypeScriptTableClass = class of TCustomOpenTypeScriptTable;

  TOpenTypeDefaultLanguageSystemTables = class(TCustomOpenTypeScriptTable)
  protected
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;

    procedure LoadFromStream(Stream: TStream); override;
  end;

  TOpenTypeScriptListTable = class(TCustomPascalTypeInterfaceTable)
  private
    FLangSysList: TPascalTypeTableInterfaceList<TCustomOpenTypeScriptTable>;
    function GetLanguageSystemCount: Integer;
    function GetLanguageSystem(Index: Integer): TCustomOpenTypeScriptTable;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property LanguageSystemCount: Integer read GetLanguageSystemCount;
    property LanguageSystem[Index: Integer]: TCustomOpenTypeScriptTable
      read GetLanguageSystem;
  end;

  TCustomOpenTypeFeatureTable = class(TCustomOpenTypeNamedTable)
  private
    FFeatureParams   : Word;          // = NULL (reserved for offset to FeatureParams)
    FLookupListIndex : array of Word; // Array of LookupList indices for this feature -zero-based (first lookup is LookupListIndex = 0)
    function GetLookupList(Index: Integer): Word;
    function GetLookupListCount: Integer;
    procedure SetFeatureParams(const Value: Word);
  protected
    procedure FeatureParamsChanged; virtual;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property DisplayName: string read GetDisplayName;
    property FeatureParams: Word read FFeatureParams write SetFeatureParams;
    property LookupListCount: Integer read GetLookupListCount;
    property LookupList[Index: Integer]: Word read GetLookupList;
  end;

  TOpenTypeFeatureTableClass = class of TCustomOpenTypeFeatureTable;

  TOpenTypeFeatureListTable = class(TCustomPascalTypeInterfaceTable)
  private
    FFeatureList: TPascalTypeTableInterfaceList<TCustomOpenTypeFeatureTable>;
    function GetFeature(Index: Integer): TCustomOpenTypeFeatureTable;
    function GetFeatureCount: Integer;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property FeatureCount: Integer read GetFeatureCount;
    property Feature[Index: Integer]: TCustomOpenTypeFeatureTable
      read GetFeature;
  end;

  TCustomOpenTypeCoverageTable = class(TCustomPascalTypeTable)
  protected
    class function GetCoverageFormat: TCoverageFormat; virtual; abstract;
  public
    property Format: TCoverageFormat read GetCoverageFormat;
  end;

  TOpenTypeCoverage1Table = class(TCustomOpenTypeCoverageTable)
  private
    FGlyphArray: array of Word; // Array of GlyphIDs-in numerical order
    function GetGlyph(Index: Integer): Word;
    function GetGlyphCount: Integer;
  protected
    class function GetCoverageFormat: TCoverageFormat; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property GlyphCount: Integer read GetGlyphCount;
    property Glyph[Index: Integer]: Word read GetGlyph;
  end;

  TRangeRecord = packed record
    StartGlyph         : Word; // First GlyphID in the range
    EndGlyph           : Word; // Last GlyphID in the range
    StartCoverageIndex : Word; // Coverage Index of first GlyphID in range
  end;

  TOpenTypeCoverage2Table = class(TCustomOpenTypeCoverageTable)
  private
    FRangeArray: array of TRangeRecord;
    function GetRange(Index: Integer): TRangeRecord;
    function GetRangeCount: Integer;
  protected
    class function GetCoverageFormat: TCoverageFormat; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property RangeCount: Integer read GetRangeCount;
    property Range[Index: Integer]: TRangeRecord read GetRange;
  end;

  TOpenTypeLookupTable = class(TCustomPascalTypeInterfaceTable)
  private
    FLookupType       : Word; // Different enumerations for GSUB and GPOS
    FLookupFlag       : Word; // Lookup qualifiers
    FMarkFilteringSet : Word; // Index (base 0) into GDEF mark glyph sets structure. This field is only present if bit UseMarkFilteringSet of lookup flags is set.
    FSubtableList     : TPascalTypeTableList<TCustomOpenTypeCoverageTable>;
    procedure SetLookupFlag(const Value: Word);
    procedure SetLookupType(const Value: Word);
    procedure SetMarkFilteringSet(const Value: Word);
    function GetSubtable(Index: Integer): TCustomOpenTypeCoverageTable;
    function GetSubtableCount: Integer;
  protected
    procedure LookupFlagChanged; virtual;
    procedure LookupTypeChanged; virtual;
    procedure MarkFilteringSetChanged; virtual;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property LookupType: Word read FLookupType write SetLookupType;
    property LookupFlag: Word read FLookupFlag write SetLookupFlag;
    property MarkFilteringSet: Word read FMarkFilteringSet write SetMarkFilteringSet;

    property SubtableCount: Integer read GetSubtableCount;
    property Subtable[Index: Integer]: TCustomOpenTypeCoverageTable read GetSubtable;
  end;

  TOpenTypeLookupListTable = class(TCustomPascalTypeInterfaceTable)
  private
    FLookupList : TPascalTypeTableInterfaceList<TOpenTypeLookupTable>;
    function GetLookupTableCount: Integer;
    function GetLookupTable(Index: Integer): TOpenTypeLookupTable;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property LookupTableCount: Integer read GetLookupTableCount;
    property LookupTable[Index: Integer]: TOpenTypeLookupTable
      read GetLookupTable;
  end;

  TCustomOpenTypeCommonTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion          : TFixedPoint; // Version of the GPOS table-initially = 0x00010000
    FScriptListTable  : TOpenTypeScriptListTable;
    FFeatureListTable : TOpenTypeFeatureListTable;
    FLookupListTable  : TOpenTypeLookupListTable;
    procedure SetVersion(const Value: TFixedPoint);
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
    property ScriptListTable: TOpenTypeScriptListTable read FScriptListTable;
    property FeatureListTable: TOpenTypeFeatureListTable read FFeatureListTable;
    property LookupListTable: TOpenTypeLookupListTable read FLookupListTable;
  end;


  // table 'GPOS'

  TOpenTypeGlyphPositionTable = class(TCustomOpenTypeCommonTable)
  public
    class function GetTableType: TTableType; override;
  end;


  // table 'GSUB'

  TOpenTypeGlyphSubstitutionTable = class(TCustomOpenTypeCommonTable)
  public
    class function GetTableType: TTableType; override;
  end;


  // table 'JSTF'

  // not entirely implemented, for more information see
  // http://www.microsoft.com/typography/otspec/jstf.htm

  TCustomOpenTypeJustificationLanguageSystemTable = class(TCustomOpenTypeNamedTable)
  private
  protected
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TOpenTypeJustificationLanguageSystemTableClass = class of TCustomOpenTypeJustificationLanguageSystemTable;

  TOpenTypeJustificationLanguageSystemTable = class(TCustomOpenTypeJustificationLanguageSystemTable)
  protected
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;
  end;

  TOpenTypeExtenderGlyphTable = class(TCustomPascalTypeTable)
  private
    FGlyphID: array of Word; // GlyphIDs-in increasing numerical order
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TCustomOpenTypeJustificationScriptTable = class(TCustomOpenTypeNamedTable)
  private
    FExtenderGlyphTable  : TOpenTypeExtenderGlyphTable;
    FDefaultLangSys      : TCustomOpenTypeJustificationLanguageSystemTable;
    FLanguageSystemTables: TPascalTypeTableInterfaceList<TCustomOpenTypeJustificationLanguageSystemTable>;
    function GetLanguageSystemTable(Index: Integer): TCustomOpenTypeJustificationLanguageSystemTable;
    function GetLanguageSystemTableCount: Integer;
    procedure SetDefaultLangSys(const Value: TCustomOpenTypeJustificationLanguageSystemTable);
  protected
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property DefaultLangSys: TCustomOpenTypeJustificationLanguageSystemTable read FDefaultLangSys write SetDefaultLangSys;
    property LanguageSystemTableCount: Integer read GetLanguageSystemTableCount;
    property LanguageSystemTable[Index: Integer]: TCustomOpenTypeJustificationLanguageSystemTable read GetLanguageSystemTable;
  end;

  TOpenTypeJustificationScriptTable = class(TCustomOpenTypeJustificationScriptTable)
  protected
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;
  end;

  TJustificationScriptDirectoryEntry = packed record
    Tag: TTableType;
    Offset: Word;
  end;

  TOpenTypeJustificationTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion : TFixedPoint; // Version of the JSTF table-initially set to 0x00010000
    FScripts : TPascalTypeTableInterfaceList<TCustomOpenTypeJustificationScriptTable>;
    procedure SetVersion(const Value: TFixedPoint);
    function GetScriptCount: Cardinal;
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
    property ScriptCount: Cardinal read GetScriptCount;
  end;

  // language system
procedure RegisterLanguageSystem(LanguageSystemClass: TOpenTypeLanguageSystemTableClass);
procedure RegisterLanguageSystems(LanguageSystemClasses: array of TOpenTypeLanguageSystemTableClass);
function FindLanguageSystemByType(TableType: TTableType): TOpenTypeLanguageSystemTableClass;

// scripts
procedure RegisterScript(ScriptClass: TOpenTypeScriptTableClass);
procedure RegisterScripts(ScriptClasses: array of TOpenTypeScriptTableClass);
function FindScriptByType(TableType: TTableType): TOpenTypeScriptTableClass;

// features
procedure RegisterFeature(FeatureClass: TOpenTypeFeatureTableClass);
procedure RegisterFeatures(FeaturesClasses: array of TOpenTypeFeatureTableClass);
function FindFeatureByType(TableType: TTableType): TOpenTypeFeatureTableClass;

// justification language system
procedure RegisterJustificationLanguageSystem(LanguageSystemClass: TOpenTypeJustificationLanguageSystemTableClass);
procedure RegisterJustificationLanguageSystems(LanguageSystemClasses: array of TOpenTypeJustificationLanguageSystemTableClass);
function FindJustificationLanguageSystemByType(TableType: TTableType): TOpenTypeJustificationLanguageSystemTableClass;

var
  GFeatureClasses        : array of TOpenTypeFeatureTableClass;
  GLanguageSystemClasses : array of TOpenTypeLanguageSystemTableClass;
  GScriptClasses         : array of TOpenTypeScriptTableClass;
  GJustificationLanguageSystemClasses: array of TOpenTypeJustificationLanguageSystemTableClass;

implementation

uses
  Math, SysUtils, PT_Math, PT_ResourceStrings, PT_TablesOpenTypeFeatures;


{ TCustomOpenTypeVersionedNamedTable }

constructor TCustomOpenTypeVersionedNamedTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited;
  FVersion.Fract := 0;
end;

procedure TCustomOpenTypeVersionedNamedTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeVersionedNamedTable then
    FVersion := TCustomOpenTypeVersionedNamedTable(Source).FVersion;
end;

procedure TCustomOpenTypeVersionedNamedTable.LoadFromStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read version
    FVersion.Fixed := ReadSwappedCardinal(Stream);
  end;
end;

procedure TCustomOpenTypeVersionedNamedTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write version
  WriteSwappedCardinal(Stream, Cardinal(Version));
end;

procedure TCustomOpenTypeVersionedNamedTable.SetVersion
  (const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TCustomOpenTypeVersionedNamedTable.VersionChanged;
begin
  Changed;
end;


{ TCustomOpenTypeClassDefinitionTable }


{ TOpenTypeClassDefinitionFormat1Table }

procedure TOpenTypeClassDefinitionFormat1Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeClassDefinitionFormat1Table then
  begin
    FStartGlyph := TOpenTypeClassDefinitionFormat1Table(Source).FStartGlyph;
    FClassValueArray := TOpenTypeClassDefinitionFormat1Table(Source).FClassValueArray;
  end;
end;

class function TOpenTypeClassDefinitionFormat1Table.GetClassFormat: Word;
begin
  Result := 1;
end;

function TOpenTypeClassDefinitionFormat1Table.GetClassValue(Index: Integer): Word;
begin
  if (Index < 0) or (Index > High(FClassValueArray)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FClassValueArray[Index];
end;

function TOpenTypeClassDefinitionFormat1Table.GetClassValueCount: Integer;
begin
  Result := Length(FClassValueArray);
end;

procedure TOpenTypeClassDefinitionFormat1Table.LoadFromStream(Stream: TStream);
var
  ArrayIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read start glyph
    FStartGlyph := ReadSwappedWord(Stream);

    // read ClassValueArray length
    SetLength(FClassValueArray, ReadSwappedWord(Stream));

    // read ClassValueArray
    for ArrayIndex := 0 to High(FClassValueArray) do
      FClassValueArray[ArrayIndex] := ReadSwappedWord(Stream);
  end;
end;

procedure TOpenTypeClassDefinitionFormat1Table.SaveToStream(Stream: TStream);
var
  ArrayIndex: Integer;
begin
  inherited;

  // write start glyph
  WriteSwappedWord(Stream, FStartGlyph);

  // write ClassValueArray length
  WriteSwappedWord(Stream, Length(FClassValueArray));

  // write ClassValueArray
  for ArrayIndex := 0 to High(FClassValueArray) do
    WriteSwappedWord(Stream, FClassValueArray[ArrayIndex]);
end;

procedure TOpenTypeClassDefinitionFormat1Table.SetStartGlyph(const Value: Word);
begin
  if FStartGlyph <> Value then
  begin
    FStartGlyph := Value;
    StartGlyphChanged;
  end;
end;

procedure TOpenTypeClassDefinitionFormat1Table.StartGlyphChanged;
begin
  Changed;
end;


{ TOpenTypeClassDefinitionFormat2Table }

procedure TOpenTypeClassDefinitionFormat2Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeClassDefinitionFormat2Table then
    FClassRangeRecords := TOpenTypeClassDefinitionFormat2Table(Source).FClassRangeRecords;
end;

class function TOpenTypeClassDefinitionFormat2Table.GetClassFormat: Word;
begin
  Result := 2;
end;

function TOpenTypeClassDefinitionFormat2Table.GetClassRangeRecord(Index: Integer): TClassRangeRecord;
begin
  if (Index < 0) or (Index > High(FClassRangeRecords)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FClassRangeRecords[Index];
end;

function TOpenTypeClassDefinitionFormat2Table.GetClassRangeRecordCount: Integer;
begin
  Result := Length(FClassRangeRecords);
end;

procedure TOpenTypeClassDefinitionFormat2Table.LoadFromStream(Stream: TStream);
var
  ArrayIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read ClassRangeRecords length
    SetLength(FClassRangeRecords, ReadSwappedWord(Stream));

    // read ClassRangeRecords
    for ArrayIndex := 0 to High(FClassRangeRecords) do
      with FClassRangeRecords[ArrayIndex] do
      begin
        // read start glyph
        StartGlyph := ReadSwappedWord(Stream);

        // read end glyph
        EndGlyph := ReadSwappedWord(Stream);

        // read glyph class
        GlyphClass := ReadSwappedWord(Stream);
      end;
  end;
end;

procedure TOpenTypeClassDefinitionFormat2Table.SaveToStream(Stream: TStream);
begin
  inherited;

  // write ClassRangeRecords length
  WriteSwappedWord(Stream, Length(FClassRangeRecords));
end;


{ TOpenTypeMarkGlyphSetTable }

constructor TOpenTypeMarkGlyphSetTable.Create;
begin
  inherited;
  FTableFormat := 1;
end;

procedure TOpenTypeMarkGlyphSetTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeMarkGlyphSetTable then
  begin
    FTableFormat := TOpenTypeMarkGlyphSetTable(Source).FTableFormat;
    FCoverage := TOpenTypeMarkGlyphSetTable(Source).FCoverage;
  end;
end;

function TOpenTypeMarkGlyphSetTable.GetCoverage(Index: Integer): Cardinal;
begin
  if (Index < 0) or (Index > High(FCoverage)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FCoverage[Index];
end;

function TOpenTypeMarkGlyphSetTable.GetCoverageCount: Integer;
begin
  Result := Length(FCoverage);
end;

procedure TOpenTypeMarkGlyphSetTable.LoadFromStream(Stream: TStream);
var
  CoverageIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FTableFormat := ReadSwappedWord(Stream);

    if FTableFormat > 1 then
      raise EPascalTypeError.Create(RCStrUnknownVersion);

    // read coverage length
    SetLength(FCoverage, ReadSwappedWord(Stream));

    // check (minimum) table size
    if Position + Length(FCoverage) * SizeOf(Cardinal) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read coverage data
    for CoverageIndex := 0 to High(FCoverage) do
      FCoverage[CoverageIndex] := ReadSwappedCardinal(Stream);
  end;
end;

procedure TOpenTypeMarkGlyphSetTable.SaveToStream(Stream: TStream);
var
  CoverageIndex: Integer;
begin
  inherited;

  // write table format
  WriteSwappedWord(Stream, FTableFormat);

  // write coverage length
  WriteSwappedWord(Stream, Length(FCoverage));

  // write coverage data
  for CoverageIndex := 0 to High(FCoverage) do
    WriteSwappedCardinal(Stream, FCoverage[CoverageIndex]);
end;

procedure TOpenTypeMarkGlyphSetTable.SetTableFormat(const Value: Word);
begin
  if FTableFormat <> Value then
  begin
    FTableFormat := Value;
    TableFormatChanged;
  end;
end;

procedure TOpenTypeMarkGlyphSetTable.TableFormatChanged;
begin
  Changed;
end;


{ TOpenTypeBaselineTagListTable }

procedure TOpenTypeBaselineTagListTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeBaselineTagListTable then
    FBaseLineTags := TOpenTypeBaselineTagListTable(Source).FBaseLineTags;
end;

procedure TOpenTypeBaselineTagListTable.LoadFromStream(Stream: TStream);
var
  TagIndex: Word;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read baseline tag list array length
    SetLength(FBaseLineTags, ReadSwappedWord(Stream));

    // check if table is complete
    if Position + 4 * Length(FBaseLineTags) > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read baseline array data
    for TagIndex := 0 to High(FBaseLineTags) do
      Read(FBaseLineTags[TagIndex], SizeOf(TTableType));
  end;
end;

procedure TOpenTypeBaselineTagListTable.SaveToStream(Stream: TStream);
var
  TagIndex: Word;
begin
  inherited;

  with Stream do
  begin
    // write baseline tag list array length
    WriteSwappedWord(Stream, Length(FBaseLineTags));

    // write baseline array data
    for TagIndex := 0 to High(FBaseLineTags) do
      Write(FBaseLineTags[TagIndex], SizeOf(TTableType));
  end;
end;


{ TOpenTypeBaselineScriptListTable }

procedure TOpenTypeBaselineScriptListTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeBaselineScriptListTable then
    FBaseLineScript := TOpenTypeBaselineScriptListTable(Source).FBaseLineScript;
end;

procedure TOpenTypeBaselineScriptListTable.LoadFromStream(Stream: TStream);
var
  ScriptIndex: Word;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read baseline stript list array length
    SetLength(FBaseLineScript, ReadSwappedWord(Stream));

    // check if table is complete
    if Position + 6 * Length(FBaseLineScript) > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read baseline array data
    for ScriptIndex := 0 to High(FBaseLineScript) do
    begin
      // read tag
      Read(FBaseLineScript[ScriptIndex].Tag, SizeOf(TTableType));

      // read script offset
      FBaseLineScript[ScriptIndex].ScriptOffset := ReadSwappedWord(Stream);
    end;
  end;
end;

procedure TOpenTypeBaselineScriptListTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TOpenTypeAxisTable }

destructor TOpenTypeAxisTable.Destroy;
begin
  FreeAndNil(FBaseLineTagList);
  inherited;
end;

procedure TOpenTypeAxisTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeAxisTable then
  begin
    // check if baseline tag list table needs to be assigned
    if (TOpenTypeAxisTable(Source).FBaseLineTagList <> nil) then
    begin
      // eventually create new destination baseline tag list table
      if (FBaseLineTagList = nil) then
        FBaseLineTagList := TOpenTypeBaselineTagListTable.Create;

      // assign baseline tag list table
      FBaseLineTagList.Assign(TOpenTypeAxisTable(Source).FBaseLineTagList);
    end else
      FreeAndNil(FBaseLineTagList);
  end;
end;

procedure TOpenTypeAxisTable.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  Value16 : Word;
begin
  inherited;

  with Stream do
  begin
    // remember start position
    StartPos := Position;

    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read baseline tag list table offset (maybe 0)
    Read(Value16, SizeOf(Word));
    if Value16 > 0 then
    begin
      // locate baseline tag list table
      Position := StartPos + Value16;

      // eventually create baseline tag list table
      if (FBaseLineTagList = nil) then
        FBaseLineTagList := TOpenTypeBaselineTagListTable.Create;

      // load baseline tag list table from stream
      FBaseLineTagList.LoadFromStream(Stream);
    end;
  end;
end;

procedure TOpenTypeAxisTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TOpenTypeBaselineTable }

destructor TOpenTypeBaselineTable.Destroy;
begin
  FreeAndNil(FHorizontalAxis);
  FreeAndNil(FVerticalAxis);
  inherited;
end;

procedure TOpenTypeBaselineTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeBaselineTable then
  begin
    // check if horizontal axis needs to be assigned
    if (TOpenTypeBaselineTable(Source).FHorizontalAxis <> nil) then
    begin
      // eventually create new destination axis table
      if (FHorizontalAxis = nil) then
        FHorizontalAxis := TOpenTypeAxisTable.Create;

      // assign horizontal axis table
      FHorizontalAxis.Assign(TOpenTypeBaselineTable(Source).FHorizontalAxis);
    end else
      FreeAndNil(FHorizontalAxis);

    // check if vertical axis needs to be assigned
    if (TOpenTypeBaselineTable(Source).FVerticalAxis <> nil) then
    begin
      // eventually create new destination axis table
      if (FVerticalAxis = nil) then
        FVerticalAxis := TOpenTypeAxisTable.Create;

      // assign horizontal axis table
      FVerticalAxis.Assign(TOpenTypeBaselineTable(Source).FVerticalAxis);
    end else
      FreeAndNil(FVerticalAxis);
  end;
end;

class function TOpenTypeBaselineTable.GetTableType: TTableType;
begin
  Result := 'BASE';
end;

procedure TOpenTypeBaselineTable.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  Value16 : Word;
begin
  inherited;

  with Stream do
  begin
    // check version alread read
    if Version.Value <> 1 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // remember start position as position minus the version already read
    StartPos := Position - 4;

    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read horizontal axis table offset (maybe 0)
    Read(Value16, SizeOf(Word));
    if Value16 > 0 then
    begin
      // locate horizontal axis table
      Position := StartPos + Value16;

      // eventually create horizontal axis table
      if (FHorizontalAxis = nil) then
        FHorizontalAxis := TOpenTypeAxisTable.Create;

      // load horizontal axis table from stream
      FHorizontalAxis.LoadFromStream(Stream);
    end;

    // read vertical axis table offset (maybe 0)
    Read(Value16, SizeOf(Word));
    if Value16 > 0 then
    begin
      // locate horizontal axis table
      Position := StartPos + Value16;

      // eventually create horizontal axis table
      if (FVerticalAxis = nil) then
        FVerticalAxis := TOpenTypeAxisTable.Create;

      // load horizontal axis table from stream
      FVerticalAxis.LoadFromStream(Stream);
    end;

  end;
end;

procedure TOpenTypeBaselineTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TOpenTypeGlyphDefinitionTable }

constructor TOpenTypeGlyphDefinitionTable.Create(const AStorage: IPascalTypeStorageTable);
const
  CGlyphDefinitionDefaultVersion: Cardinal = $10002;
begin
  inherited;
  FVersion.Fixed := CGlyphDefinitionDefaultVersion;
end;

destructor TOpenTypeGlyphDefinitionTable.Destroy;
begin
  FreeAndNil(FGlyphClassDef);
  FreeAndNil(FMarkAttachClassDef);
  FreeAndNil(FMarkGlyphSetsDef);
  inherited;
end;

procedure TOpenTypeGlyphDefinitionTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeGlyphDefinitionTable then
  begin
    FAttachList := TOpenTypeGlyphDefinitionTable(Source).FAttachList;
    FLigCaretList := TOpenTypeGlyphDefinitionTable(Source).FLigCaretList;

    if (TOpenTypeGlyphDefinitionTable(Source).FMarkGlyphSetsDef <> nil) then
    begin
      FMarkGlyphSetsDef := TOpenTypeMarkGlyphSetTable.Create;
      FMarkGlyphSetsDef.Assign(TOpenTypeGlyphDefinitionTable(Source).FMarkGlyphSetsDef);
    end else
      FMarkGlyphSetsDef.Free;

    if (TOpenTypeGlyphDefinitionTable(Source).FGlyphClassDef <> nil) then
    begin
      if (FGlyphClassDef <> nil) and (FGlyphClassDef.ClassType <>  TOpenTypeGlyphDefinitionTable(Source).FGlyphClassDef.ClassType) then
        FreeAndNil(FGlyphClassDef);
      FGlyphClassDef := TOpenTypeClassDefinitionTableClass(TOpenTypeGlyphDefinitionTable(Source).FGlyphClassDef.ClassType).Create;
      FGlyphClassDef.Assign(TOpenTypeGlyphDefinitionTable(Source).FGlyphClassDef);
    end else
      FreeAndNil(FGlyphClassDef);

    if (TOpenTypeGlyphDefinitionTable(Source).FMarkAttachClassDef <> nil) then
    begin
      if (FMarkAttachClassDef <> nil) and (FMarkAttachClassDef.ClassType <>  TOpenTypeGlyphDefinitionTable(Source).FMarkAttachClassDef.ClassType) then
        FreeAndNil(FMarkAttachClassDef);

      FMarkAttachClassDef := TOpenTypeClassDefinitionTableClass(TOpenTypeGlyphDefinitionTable(Source).FMarkAttachClassDef.ClassType).Create;
      FMarkAttachClassDef.Assign(TOpenTypeGlyphDefinitionTable(Source).FMarkAttachClassDef);
    end else
      FreeAndNil(FMarkAttachClassDef);
  end;
end;

class function TOpenTypeGlyphDefinitionTable.GetTableType: TTableType;
begin
  Result := 'GDEF';
end;

procedure TOpenTypeGlyphDefinitionTable.LoadFromStream(Stream: TStream);
var
  StartPos           : Int64;
  Value16            : Word;
  GlyphClassDefOffset: Word;
  MarkAttClassDefOffs: Word;
  MarkGlyphSetsDefOff: Word;
begin
  inherited;

  with Stream do
  begin
    // check version alread read
    if Version.Value <> 1 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // remember start position as position minus the version already read
    StartPos := Position - 4;

    // check if table is complete
    if Position + 10 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read glyph class definition offset
    GlyphClassDefOffset := ReadSwappedWord(Stream);

    // read attach list
    FAttachList := ReadSwappedWord(Stream);

    // read ligature caret list
    FLigCaretList := ReadSwappedWord(Stream);

    // read mark attach class definition offset
    MarkAttClassDefOffs := ReadSwappedWord(Stream);

    // read mark glyph set offset
    MarkGlyphSetsDefOff := ReadSwappedWord(Stream);

    // eventually free existing class definition
    FreeAndNil(FGlyphClassDef);

    // eventually read glyph class
    if GlyphClassDefOffset <> 0 then
    begin
      Position := StartPos + GlyphClassDefOffset;

      // read class definition format
      Read(Value16, SizeOf(Word));
      case Swap16(Value16) of
        1:
          FGlyphClassDef := TOpenTypeClassDefinitionFormat1Table.Create;
        2:
          FGlyphClassDef := TOpenTypeClassDefinitionFormat2Table.Create;
      else
        raise EPascalTypeError.Create(RCStrUnknownClassDefinition);
      end;

      if (FGlyphClassDef <> nil) then
        FGlyphClassDef.LoadFromStream(Stream);
    end;

    // eventually free existing class definition
    FreeAndNil(FMarkAttachClassDef);

    // eventually read mark attachment class definition
    if MarkAttClassDefOffs <> 0 then
    begin
      Position := StartPos + MarkAttClassDefOffs;

      // read class definition format
      Read(Value16, SizeOf(Word));
      case Swap16(Value16) of
        1:
          FMarkAttachClassDef := TOpenTypeClassDefinitionFormat1Table.Create;
        2:
          FMarkAttachClassDef := TOpenTypeClassDefinitionFormat2Table.Create;
      else
        raise EPascalTypeError.Create(RCStrUnknownClassDefinition);
      end;

      if (FMarkAttachClassDef <> nil) then
        FMarkAttachClassDef.LoadFromStream(Stream);
    end;

    // eventually read mark glyph set (otherwise free existing glyph set)
    if MarkGlyphSetsDefOff <> 0 then
    begin
      Position := StartPos + MarkGlyphSetsDefOff;

      // eventually create new mark glyph set
      if (FMarkGlyphSetsDef = nil) then
        FMarkGlyphSetsDef := TOpenTypeMarkGlyphSetTable.Create;

      FMarkGlyphSetsDef.LoadFromStream(Stream);
    end else
      FreeAndNil(FMarkGlyphSetsDef);

  end;
end;

procedure TOpenTypeGlyphDefinitionTable.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
  Offsets : array [0..4] of Word;
begin
  inherited;

  with Stream do
  begin
    // remember start position as position minus version aready written
    StartPos := Position - 4;

    // reset offset array to zero
    FillChar(Offsets[0], 5 * SizeOf(Word), 0);

    // skip directory for now
    Seek(SizeOf(Offsets), soCurrent);

    // write glyph class definition
    if (FGlyphClassDef <> nil) then
    begin
      Offsets[0] := Word(Position - StartPos);
      FGlyphClassDef.SaveToStream(Stream);
    end;

    (*
      // write attachment list
      if (FAttachList <> nil) then
      begin
      Offsets[1] := Word(Position - StartPos);
      FAttachList.SaveToStream(Stream);
      end;

      // write ligature caret list
      if (FLigCaretList <> nil) then
      begin
      Offsets[2] := Word(Position - StartPos);
      FLigCaretList.SaveToStream(Stream);
      end;
    *)

    // write mark attachment class definition
    if (FMarkAttachClassDef <> nil) then
    begin
      Offsets[3] := Word(Position - StartPos);
      FMarkAttachClassDef.SaveToStream(Stream);
    end;

    // write mark glyph set definition
    if (FMarkGlyphSetsDef <> nil) then
    begin
      Offsets[4] := Word(Position - StartPos);
      FMarkGlyphSetsDef.SaveToStream(Stream);
    end;

    // skip directory for now
    Position := StartPos + SizeOf(TFixedPoint);

    // write directory

    // write glyph class definition
    WriteSwappedWord(Stream, Offsets[0]);

    // write attach list
    WriteSwappedWord(Stream, Offsets[1]);

    // write ligature caret list
    WriteSwappedWord(Stream, Offsets[2]);

    // write mark attach class definition
    WriteSwappedWord(Stream, Offsets[3]);

    // write mark glyph set
    WriteSwappedWord(Stream, Offsets[4]);
  end;
end;


{ TCustomOpenTypeLanguageSystemTable }

function TCustomOpenTypeLanguageSystemTable.GetFeatureIndex(Index: Integer): Word;
begin
  if (Index < 0) or (Index > High(FFeatureIndices)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FFeatureIndices[Index];
end;

function TCustomOpenTypeLanguageSystemTable.GetFeatureIndexCount: Integer;
begin
  Result := Length(FFeatureIndices);
end;

procedure TCustomOpenTypeLanguageSystemTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeLanguageSystemTable then
  begin
    FLookupOrder := TCustomOpenTypeLanguageSystemTable(Source).FLookupOrder;
    FReqFeatureIndex := TCustomOpenTypeLanguageSystemTable(Source).FReqFeatureIndex;
    FFeatureIndices := TCustomOpenTypeLanguageSystemTable(Source).FFeatureIndices;
  end;
end;

procedure TCustomOpenTypeLanguageSystemTable.LoadFromStream(Stream: TStream);
var
  FeatureIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 6 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read default language system
    FLookupOrder := ReadSwappedWord(Stream);

    // read index of a feature required for this language system
    FReqFeatureIndex := ReadSwappedWord(Stream);

    // read default language system
    SetLength(FFeatureIndices, ReadSwappedWord(Stream));

    // read default language system
    for FeatureIndex := 0 to High(FFeatureIndices) do
      FFeatureIndices[FeatureIndex] := ReadSwappedWord(Stream);
  end;
end;

procedure TCustomOpenTypeLanguageSystemTable.SaveToStream(Stream: TStream);
var
  FeatureIndex: Integer;
begin
  inherited;

  // write default language system
  WriteSwappedWord(Stream, FLookupOrder);

  // write index of a feature required for this language system
  WriteSwappedWord(Stream, FReqFeatureIndex);

  // write default language system
  WriteSwappedWord(Stream, Length(FFeatureIndices));

  // write default language systems
  for FeatureIndex := 0 to High(FFeatureIndices) do
    WriteSwappedWord(Stream, FFeatureIndices[FeatureIndex]);
end;

procedure TCustomOpenTypeLanguageSystemTable.SetLookupOrder(const Value: Word);
begin
  if FLookupOrder <> Value then
  begin
    FLookupOrder := Value;
    LookupOrderChanged;
  end;
end;

procedure TCustomOpenTypeLanguageSystemTable.SetReqFeatureIndex
  (const Value: Word);
begin
  if FReqFeatureIndex <> Value then
  begin
    FReqFeatureIndex := Value;
    ReqFeatureIndexChanged;
  end;
end;

procedure TCustomOpenTypeLanguageSystemTable.LookupOrderChanged;
begin
  Changed;
end;

procedure TCustomOpenTypeLanguageSystemTable.ReqFeatureIndexChanged;
begin
  Changed;
end;


{ TOpenTypeDefaultLanguageSystemTable }

class function TOpenTypeDefaultLanguageSystemTable.GetDisplayName: string;
begin
  Result := 'Default';
end;

class function TOpenTypeDefaultLanguageSystemTable.GetTableType: TTableType;
begin
  Result := 'DFLT';
end;


{ TOpenTypeDefaultLanguageSystemTables }

class function TOpenTypeDefaultLanguageSystemTables.GetDisplayName: string;
begin
  Result := 'Default';
end;

class function TOpenTypeDefaultLanguageSystemTables.GetTableType: TTableType;
begin
  Result := 'DFLT';
end;

procedure TOpenTypeDefaultLanguageSystemTables.LoadFromStream(Stream: TStream);
begin
  inherited;

  Assert(DefaultLangSys <> nil);
  Assert(LanguageSystemTableCount = 0);
end;


{ TCustomOpenTypeScriptTable }

constructor TCustomOpenTypeScriptTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited Create(AStorage);
  FLanguageSystemTables := TPascalTypeTableInterfaceList<TCustomOpenTypeNamedTable>.Create(AStorage);
end;

destructor TCustomOpenTypeScriptTable.Destroy;
begin
  FreeAndNil(FDefaultLangSys);
  FreeAndNil(FLanguageSystemTables);

  inherited;
end;

function TCustomOpenTypeScriptTable.GetLanguageSystemTable(Index: Integer): TCustomOpenTypeNamedTable;
begin
  if (Index < 0) or (Index >= FLanguageSystemTables.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FLanguageSystemTables[Index];
end;

function TCustomOpenTypeScriptTable.GetLanguageSystemTableCount: Integer;
begin
  Result := FLanguageSystemTables.Count;
end;

procedure TCustomOpenTypeScriptTable.Assign(Source: TPersistent);
var
  SourceLangTable: TCustomOpenTypeNamedTable;
  DestLangTable: TCustomOpenTypeNamedTable;
begin
  inherited;
  if Source is TCustomOpenTypeScriptTable then
  begin
    FLanguageSystemTables.Clear;
    for SourceLangTable in TCustomOpenTypeScriptTable(Source).FLanguageSystemTables do
    begin
      DestLangTable := FLanguageSystemTables.Add;
      DestLangTable.Assign(SourceLangTable);
    end;

    if (TCustomOpenTypeScriptTable(Source).FDefaultLangSys <> nil) then
    begin
      if (FDefaultLangSys = nil) then
        FDefaultLangSys := TOpenTypeDefaultLanguageSystemTable.Create(Storage);

      FDefaultLangSys.Assign(TCustomOpenTypeScriptTable(Source).FDefaultLangSys);
    end else
      FreeAndNil(FDefaultLangSys);
  end;
end;

procedure TCustomOpenTypeScriptTable.LoadFromStream(Stream: TStream);
var
  StartPos      : Int64;
  LangSysIndex  : Integer;
  LangSysRecords: array of TTagOffsetRecord;
  LangTable     : TCustomOpenTypeNamedTable;//TCustomOpenTypeJustificationLanguageSystemTable;
  LangTableClass: TOpenTypeJustificationLanguageSystemTableClass;
  DefaultLangSys: Word;
begin
  inherited;

  with Stream do
  begin
    StartPos := Position;

    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read default language system offset
    DefaultLangSys := ReadSwappedWord(Stream);

    // read language system record count
    SetLength(LangSysRecords, ReadSwappedWord(Stream));

    for LangSysIndex := 0 to High(LangSysRecords) do
    begin
      // read table type
      Read(LangSysRecords[LangSysIndex].Tag, SizeOf(TTableType));

      // read offset
      LangSysRecords[LangSysIndex].Offset := ReadSwappedWord(Stream);
    end;

    // load default language system
    if DefaultLangSys <> 0 then
    begin
      Position := StartPos + DefaultLangSys;

      if (FDefaultLangSys = nil) then
        FDefaultLangSys := TOpenTypeDefaultLanguageSystemTable.Create(Storage);

      FDefaultLangSys.LoadFromStream(Stream);
    end else
      FreeAndNil(FDefaultLangSys);

    // clear existing language tables
    FLanguageSystemTables.Clear;

    for LangSysIndex := 0 to High(LangSysRecords) do
    begin
      LangTableClass := FindJustificationLanguageSystemByType(LangSysRecords[LangSysIndex].Tag);

      if (LangTableClass <> nil) then
      begin
        // create language table entry
        // add to language system tables
        // TODO : Something was wrong here. We are adding TCustomOpenTypeJustificationLanguageSystemTable but the list contains
        // TCustomOpenTypeLanguageSystemTable (per the list getter).
        // I have changed the list and getter to use their common base class: TCustomOpenTypeJustificationLanguageSystemTable
        LangTable := FLanguageSystemTables.Add(LangTableClass);

        // set position
        Position := StartPos + LangSysRecords[LangSysIndex].Offset;

        // read language system table entry from stream
        LangTable.LoadFromStream(Stream);

      end;
    end;
  end;
end;

procedure TCustomOpenTypeScriptTable.SaveToStream(Stream: TStream);
var
  StartPos      : Int64;
  LangSysIndex  : Integer;
  LangSysRecords: array of TTagOffsetRecord;
  Value16       : Word;
begin
  inherited;

  with Stream do
  begin
    // remember start position of the stream
    StartPos := Position;

    // write default language system offset
    if (FDefaultLangSys <> nil) then
      Value16 := 4 + 6 * FLanguageSystemTables.Count
    else
      Value16 := 0;
    Write(Value16, SizeOf(Word));

    // write feature list count
    WriteSwappedWord(Stream, FLanguageSystemTables.Count);

    // leave space for feature directory
    Seek(6 * FLanguageSystemTables.Count, soCurrent);

    // eventually write default language system
    if (FDefaultLangSys <> nil) then
      FDefaultLangSys.SaveToStream(Stream);

    // build directory (to be written later) and write data
    SetLength(LangSysRecords, FLanguageSystemTables.Count);
    for LangSysIndex := 0 to High(LangSysRecords) do
      with TCustomOpenTypeLanguageSystemTable
        (FLanguageSystemTables[LangSysIndex]) do
      begin
        // get table type
        LangSysRecords[LangSysIndex].Tag := TableType;
        LangSysRecords[LangSysIndex].Offset := Position;

        // write feature to stream
        SaveToStream(Stream);
      end;

    // write directory
    Position := StartPos + 4;

    for LangSysIndex := 0 to High(LangSysRecords) do
      with LangSysRecords[LangSysIndex] do
      begin
        // write tag
        Write(Tag, SizeOf(TTableType));

        // write offset
        WriteSwappedWord(Stream, Offset);
      end;
  end;
end;

procedure TCustomOpenTypeScriptTable.SetDefaultLangSys
  (const Value: TCustomOpenTypeLanguageSystemTable);
begin
  FDefaultLangSys.Assign(Value);
  Changed;
end;


{ TOpenTypeScriptListTable }

constructor TOpenTypeScriptListTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited Create(AStorage);
  FLangSysList := TPascalTypeTableInterfaceList<TCustomOpenTypeScriptTable>.Create(AStorage);
end;

destructor TOpenTypeScriptListTable.Destroy;
begin
  FreeAndNil(FLangSysList);
  inherited;
end;

function TOpenTypeScriptListTable.GetLanguageSystem(Index: Integer): TCustomOpenTypeScriptTable;
begin
  if (Index < 0) or (Index >= FLangSysList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FLangSysList[Index];
end;

function TOpenTypeScriptListTable.GetLanguageSystemCount: Integer;
begin
  Result := FLangSysList.Count;
end;

procedure TOpenTypeScriptListTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeScriptListTable then
    FLangSysList.Assign(TOpenTypeScriptListTable(Source).FLangSysList);
end;

procedure TOpenTypeScriptListTable.LoadFromStream(Stream: TStream);
var
  StartPos        : Int64;
  ScriptIndex     : Integer;
  ScriptList      : array of TTagOffsetRecord;
  ScriptTable     : TCustomOpenTypeScriptTable;
  ScriptTableClass: TOpenTypeScriptTableClass;
begin
  inherited;

  with Stream do
  begin
    StartPos := Position;

    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read script list count
    SetLength(ScriptList, ReadSwappedWord(Stream));

    for ScriptIndex := 0 to High(ScriptList) do
    begin
      // read table type
      Read(ScriptList[ScriptIndex].Tag, SizeOf(TTableType));

      // read offset
      ScriptList[ScriptIndex].Offset := ReadSwappedWord(Stream);
    end;

    // clear language system list
    FLangSysList.Clear;

    for ScriptIndex := 0 to High(ScriptList) do
    begin
      // find language class
      ScriptTableClass := FindScriptByType(ScriptList[ScriptIndex].Tag);

      if (ScriptTableClass <> nil) then
      begin
        // create language system entry
        // add to language system list
        ScriptTable := FLangSysList.Add(ScriptTableClass);

        // set position to actual script list entry
        Position := StartPos + ScriptList[ScriptIndex].Offset;

        // load from stream
        ScriptTable.LoadFromStream(Stream);
      end;
    end;
  end;
end;

procedure TOpenTypeScriptListTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TCustomOpenTypeFeatureTable }

constructor TCustomOpenTypeFeatureTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited;
end;

destructor TCustomOpenTypeFeatureTable.Destroy;
begin
  inherited;
end;

procedure TCustomOpenTypeFeatureTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeFeatureTable then
  begin
    FFeatureParams := TCustomOpenTypeFeatureTable(Source).FFeatureParams;
    FLookupListIndex := TCustomOpenTypeFeatureTable(Source).FLookupListIndex;
  end;
end;

function TCustomOpenTypeFeatureTable.GetLookupList(Index: Integer): Word;
begin
  if (Index >= 0) and (Index < Length(FLookupListIndex)) then
    Result := FLookupListIndex[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TCustomOpenTypeFeatureTable.GetLookupListCount: Integer;
begin
  Result := Length(FLookupListIndex);
end;

procedure TCustomOpenTypeFeatureTable.LoadFromStream(Stream: TStream);
var
  LookupIndex: Word;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read feature parameter offset
    FFeatureParams := ReadSwappedWord(Stream);

    // read lookup count
    SetLength(FLookupListIndex, ReadSwappedWord(Stream));

    // read lookup list index offsets
    for LookupIndex := 0 to High(FLookupListIndex) do
      FLookupListIndex[LookupIndex] := ReadSwappedWord(Stream);
  end;
end;

procedure TCustomOpenTypeFeatureTable.SaveToStream(Stream: TStream);
var
  LookupIndex: Word;
begin
  inherited;

  with Stream do
  begin
    // read feature parameter offset
    FFeatureParams := ReadSwappedWord(Stream);

    // read lookup count
    SetLength(FLookupListIndex, ReadSwappedWord(Stream));

    // read lookup list index offsets
    for LookupIndex := 0 to High(FLookupListIndex) do
      FLookupListIndex[LookupIndex] := ReadSwappedWord(Stream);
  end;
end;

procedure TCustomOpenTypeFeatureTable.SetFeatureParams(const Value: Word);
begin
  if FFeatureParams <> Value then
  begin
    FFeatureParams := Value;
    FeatureParamsChanged;
  end;
end;

procedure TCustomOpenTypeFeatureTable.FeatureParamsChanged;
begin
  Changed;
end;


{ TOpenTypeFeatureListTable }

constructor TOpenTypeFeatureListTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited;
  FFeatureList := TPascalTypeTableInterfaceList<TCustomOpenTypeFeatureTable>.Create(AStorage);
end;

destructor TOpenTypeFeatureListTable.Destroy;
begin
  FreeAndNil(FFeatureList);
  inherited;
end;

procedure TOpenTypeFeatureListTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeFeatureListTable then
    FFeatureList.Assign(TOpenTypeFeatureListTable(Source).FFeatureList);
end;

function TOpenTypeFeatureListTable.GetFeature(Index: Integer): TCustomOpenTypeFeatureTable;
begin
  if (Index < 0) or (Index >= FFeatureList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FFeatureList[Index];
end;

function TOpenTypeFeatureListTable.GetFeatureCount: Integer;
begin
  Result := FFeatureList.Count;
end;

procedure TOpenTypeFeatureListTable.LoadFromStream(Stream: TStream);
var
  StartPos    : Int64;
  FeatureIndex: Integer;
  FeatureList : array of TTagOffsetRecord;
  FeatureTable: TCustomOpenTypeFeatureTable;
  FeatureClass: TOpenTypeFeatureTableClass;
begin
  inherited;

  with Stream do
  begin
    StartPos := Position;

    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read feature list count
    SetLength(FeatureList, ReadSwappedWord(Stream));

    for FeatureIndex := 0 to High(FeatureList) do
    begin
      // read table type
      Read(FeatureList[FeatureIndex].Tag, SizeOf(TTableType));

      // read offset
      FeatureList[FeatureIndex].Offset := ReadSwappedWord(Stream);
    end;

    // clear language system list
    FFeatureList.Clear;

    for FeatureIndex := 0 to High(FeatureList) do
    begin
      // find feature class
      FeatureClass := FindFeatureByType(FeatureList[FeatureIndex].Tag);

      if (FeatureClass <> nil) then
      begin
        // create language system entry
        // add to language system list
        FeatureTable := FFeatureList.Add(FeatureClass);

        // set position to actual script list entry
        Position := StartPos + FeatureList[FeatureIndex].Offset;

        // load from stream
        FeatureTable.LoadFromStream(Stream);
      end
      else; // raise EPascalTypeError.Create('Unknown Feature: ' + FeatureList[FeatureIndex].Tag);
    end;
  end;
end;

procedure TOpenTypeFeatureListTable.SaveToStream(Stream: TStream);
var
  StartPos    : Int64;
  FeatureIndex: Integer;
  FeatureList : array of TTagOffsetRecord;
begin
  inherited;

  with Stream do
  begin
    StartPos := Position;

    // write feature list count
    WriteSwappedWord(Stream, FFeatureList.Count);

    // leave space for feature directory
    Seek(FFeatureList.Count * 6, soCurrent);

    // build directory (to be written later) and write data
    SetLength(FeatureList, FFeatureList.Count);
    for FeatureIndex := 0 to FFeatureList.Count - 1 do
      with FFeatureList[FeatureIndex] do
      begin
        // get table type
        FeatureList[FeatureIndex].Tag := TableType;
        FeatureList[FeatureIndex].Offset := Position;

        // write feature to stream
        SaveToStream(Stream);
      end;

    // write directory
    Position := StartPos + 2;

    for FeatureIndex := 0 to High(FeatureList) do
      with FeatureList[FeatureIndex] do
      begin
        // write tag
        Write(Tag, SizeOf(TTableType));

        // write offset
        WriteSwappedWord(Stream, Offset);
      end;
  end;
end;


{ TOpenTypeCoverage1Table }

procedure TOpenTypeCoverage1Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeCoverage1Table then
    FGlyphArray := TOpenTypeCoverage1Table(Source).FGlyphArray;
end;

class function TOpenTypeCoverage1Table.GetCoverageFormat: TCoverageFormat;
begin
  Result := cfList;
end;

function TOpenTypeCoverage1Table.GetGlyph(Index: Integer): Word;
begin
  if (Index < 0) or (Index > High(FGlyphArray)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FGlyphArray[Index];
end;

function TOpenTypeCoverage1Table.GetGlyphCount: Integer;
begin
  Result := Length(FGlyphArray);
end;

procedure TOpenTypeCoverage1Table.LoadFromStream(Stream: TStream);
//var
//  GlyphIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read glyph array count
    SetLength(FGlyphArray, ReadSwappedWord(Stream));

    // yet todo: different types of this table for GPOS and GSUB!!!
    (*
      // read glyph
      for GlyphIndex := 0 to High(FGlyphArray)
      do FGlyphArray[GlyphIndex] := ReadSwappedWord(Stream);
    *)

  end;
end;

procedure TOpenTypeCoverage1Table.SaveToStream(Stream: TStream);
var
  GlyphIndex: Integer;
  Value16   : Word;
begin
  inherited;

  with Stream do
  begin
    // write coverage format
    Value16 := 1;
    Write(Value16, SizeOf(Word));

    // write glyph array count
    Value16 := Length(FGlyphArray);
    Write(Value16, SizeOf(Word));

    // write glyph
    for GlyphIndex := 0 to High(FGlyphArray) do
      WriteSwappedWord(Stream, FGlyphArray[GlyphIndex]);
  end;
end;


{ TOpenTypeCoverage2Table }

procedure TOpenTypeCoverage2Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeCoverage2Table then
    FRangeArray := TOpenTypeCoverage2Table(Source).FRangeArray;
end;

class function TOpenTypeCoverage2Table.GetCoverageFormat: TCoverageFormat;
begin
  Result := cfRange;
end;

function TOpenTypeCoverage2Table.GetRange(Index: Integer): TRangeRecord;
begin
  if (Index < 0) or (Index > High(FRangeArray)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FRangeArray[Index];
end;

function TOpenTypeCoverage2Table.GetRangeCount: Integer;
begin
  Result := Length(FRangeArray);
end;

procedure TOpenTypeCoverage2Table.LoadFromStream(Stream: TStream);
var
  GlyphIndex: Integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read glyph array count
  SetLength(FRangeArray, ReadSwappedWord(Stream));

  for GlyphIndex := 0 to High(FRangeArray) do
  begin
    // read start glyph
    FRangeArray[GlyphIndex].StartGlyph := ReadSwappedWord(Stream);

    // read end glyph
    FRangeArray[GlyphIndex].EndGlyph := ReadSwappedWord(Stream);

    // read start coverage
    FRangeArray[GlyphIndex].StartCoverageIndex := ReadSwappedWord(Stream);
  end;
end;

procedure TOpenTypeCoverage2Table.SaveToStream(Stream: TStream);
var
  GlyphIndex: Integer;
begin
  inherited;

  // read glyph array count
  WriteSwappedWord(Stream, Length(FRangeArray));

  for GlyphIndex := 0 to High(FRangeArray) do
  begin
    // write start glyph
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].StartGlyph);

    // write end glyph
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].EndGlyph);

    // write start coverage
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].StartCoverageIndex);
  end;
end;


{ TOpenTypeLookupTable }

constructor TOpenTypeLookupTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited;
  FSubtableList := TPascalTypeTableList<TCustomOpenTypeCoverageTable>.Create;
end;

destructor TOpenTypeLookupTable.Destroy;
begin
  FreeAndNil(FSubtableList);
  inherited;
end;

function TOpenTypeLookupTable.GetSubtable(Index: Integer): TCustomOpenTypeCoverageTable;
begin
  if (Index < 0) or (Index >= FSubtableList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := TCustomOpenTypeCoverageTable(FSubtableList[Index]);
end;

function TOpenTypeLookupTable.GetSubtableCount: Integer;
begin
  Result := FSubtableList.Count;
end;

procedure TOpenTypeLookupTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeLookupTable then
  begin
    FLookupType := TOpenTypeLookupTable(Source).FLookupType;
    FLookupFlag := TOpenTypeLookupTable(Source).FLookupFlag;
    FMarkFilteringSet := TOpenTypeLookupTable(Source).FMarkFilteringSet;
    FSubtableList.Assign(TOpenTypeLookupTable(Source).FSubtableList);
  end;
end;

procedure TOpenTypeLookupTable.LoadFromStream(Stream: TStream);
var
  StartPos       : Int64;
  LookupIndex    : Word;
  CoverageFormat : Word;
  SubTableOffsets: array of Word;
  SubTableItem   : TCustomOpenTypeCoverageTable;
begin
  inherited;

  StartPos := Stream.Position;

  // check (minimum) table size
  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read lookup type
  FLookupType := ReadSwappedWord(Stream);

  // read lookup flag
  FLookupFlag := ReadSwappedWord(Stream);

  // read subtable count
  SetLength(SubTableOffsets, ReadSwappedWord(Stream));

  // read lookup list index offsets
  for LookupIndex := 0 to High(SubTableOffsets) do
    SubTableOffsets[LookupIndex] := ReadSwappedWord(Stream);

  // eventually read mark filtering set
  if (FLookupFlag and (1 shl 4)) <> 0 then
    FMarkFilteringSet := ReadSwappedWord(Stream);

  for LookupIndex := 0 to High(SubTableOffsets) do
  begin
    // set position to actual script list entry
    Stream.Position := StartPos + SubTableOffsets[LookupIndex];

    // read lookup type
    CoverageFormat := ReadSwappedWord(Stream);

    // create coverage sub table item
    case CoverageFormat of
      1:
        SubTableItem := TOpenTypeCoverage1Table.Create;
      2:
        SubTableItem := TOpenTypeCoverage2Table.Create;
    else
      SubTableItem := nil;
      // else raise EPascalTypeError.Create('Unknown coverage format');
    end;

    if (SubTableItem <> nil) then
    begin
      // add to subtable list
      FSubtableList.Add(SubTableItem);

      // load subtable
      SubTableItem.LoadFromStream(Stream);
    end;
  end;
end;

procedure TOpenTypeLookupTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

procedure TOpenTypeLookupTable.SetLookupFlag(const Value: Word);
begin
  if FLookupFlag <> Value then
  begin
    FLookupFlag := Value;
    LookupFlagChanged;
  end;
end;

procedure TOpenTypeLookupTable.SetLookupType(const Value: Word);
begin
  if FLookupType <> Value then
  begin
    FLookupType := Value;
    LookupTypeChanged;
  end;
end;

procedure TOpenTypeLookupTable.SetMarkFilteringSet(const Value: Word);
begin
  if FMarkFilteringSet <> Value then
  begin
    FMarkFilteringSet := Value;
    MarkFilteringSetChanged;
  end;
end;

procedure TOpenTypeLookupTable.LookupFlagChanged;
begin
  Changed;
end;

procedure TOpenTypeLookupTable.LookupTypeChanged;
begin
  Changed;
end;

procedure TOpenTypeLookupTable.MarkFilteringSetChanged;
begin
  Changed;
end;


{ TOpenTypeLookupListTable }

constructor TOpenTypeLookupListTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited;
  FLookupList := TPascalTypeTableInterfaceList<TOpenTypeLookupTable>.Create(AStorage);
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

function TOpenTypeLookupListTable.GetLookupTable(Index: Integer): TOpenTypeLookupTable;
begin
  if (Index < 0) or (Index >= FLookupList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := TOpenTypeLookupTable(FLookupList[Index]);
end;

function TOpenTypeLookupListTable.GetLookupTableCount: Integer;
begin
  Result := FLookupList.Count;
end;

procedure TOpenTypeLookupListTable.LoadFromStream(Stream: TStream);
var
  StartPos   : Int64;
  LookupIndex: Integer;
  LookupList : array of Word;
  LookupTable: TOpenTypeLookupTable;
begin
  inherited;

  StartPos := Stream.Position;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read lookup list count
  SetLength(LookupList, ReadSwappedWord(Stream));

  // read offsets
  for LookupIndex := 0 to High(LookupList) do
    LookupList[LookupIndex] := ReadSwappedWord(Stream);

  // clear language system list
  FLookupList.Clear;

  for LookupIndex := 0 to High(LookupList) do
  begin
    // create language system entry
    // add to language system list
    LookupTable := FLookupList.Add;

    // set position to actual script list entry
    Stream.Position := StartPos + LookupList[LookupIndex];

    // load from stream
    LookupTable.LoadFromStream(Stream);
  end;
end;

procedure TOpenTypeLookupListTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TCustomOpenTypeCommonTable }

constructor TCustomOpenTypeCommonTable.Create(const AStorage: IPascalTypeStorageTable);
const
  CGlyphPositionDefaultVersion: Cardinal = $10000;
begin
  inherited;

  FVersion.Fixed := CGlyphPositionDefaultVersion;

  FScriptListTable := TOpenTypeScriptListTable.Create(Storage);
  FFeatureListTable := TOpenTypeFeatureListTable.Create(Storage);
  FLookupListTable := TOpenTypeLookupListTable.Create(Storage);
end;

destructor TCustomOpenTypeCommonTable.Destroy;
begin
  FreeAndNil(FScriptListTable);
  FreeAndNil(FFeatureListTable);
  FreeAndNil(FLookupListTable);
  inherited;
end;

procedure TCustomOpenTypeCommonTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeCommonTable then
  begin
    FVersion := TCustomOpenTypeCommonTable(Source).FVersion;
    FScriptListTable.Assign(TCustomOpenTypeCommonTable(Source).FScriptListTable);
    FFeatureListTable.Assign(TCustomOpenTypeCommonTable(Source).FFeatureListTable);
    FLookupListTable.Assign(TCustomOpenTypeCommonTable(Source).FLookupListTable);
  end;
end;

procedure TCustomOpenTypeCommonTable.LoadFromStream(Stream: TStream);
var
  StartPosition : Int64;
  ScriptListPosition : Int64;
  FeatureListPosition: Int64;
  LookupListPosition : Int64;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 10 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  StartPosition := Stream.Position;

  // read version
  FVersion.Fixed := ReadSwappedCardinal(Stream);

  if Version.Value <> 1 then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read script list offset
  ScriptListPosition := StartPosition + ReadSwappedWord(Stream);

  // read feature list offset
  FeatureListPosition := StartPosition + ReadSwappedWord(Stream);

  // read lookup list offset
  LookupListPosition := StartPosition + ReadSwappedWord(Stream);

  // locate script list position
  Stream.Position := ScriptListPosition;

  // load script table
  FScriptListTable.LoadFromStream(Stream);

  // locate feature list position
  Stream.Position := FeatureListPosition;

  // load script table
  FFeatureListTable.LoadFromStream(Stream);

  // locate lookup list position
  Stream.Position := LookupListPosition;

  // load lookup table
  FLookupListTable.LoadFromStream(Stream);
end;

procedure TCustomOpenTypeCommonTable.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
begin
  inherited;

  with Stream do
  begin
    StartPos := Position;

    // write version
    WriteSwappedCardinal(Stream, Cardinal(FVersion));

    // write script list offset (fixed!)
    WriteSwappedWord(Stream, 10);

    Position := StartPos + 10;
    FScriptListTable.SaveToStream(Stream);

    (*
      // write script list offset
      WriteSwappedWord(Stream, FScriptListOffset);

      // write feature list offset
      WriteSwappedWord(Stream, FFeatureListOffset);

      // write lookup list offset
      WriteSwappedWord(Stream, FLookupListOffset);
    *)
  end;
end;

procedure TCustomOpenTypeCommonTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TCustomOpenTypeCommonTable.VersionChanged;
begin
  Changed;
end;


{ TOpenTypeGlyphPositionTable }

class function TOpenTypeGlyphPositionTable.GetTableType: TTableType;
begin
  Result := 'GPOS';
end;


{ TOpenTypeGlyphSubstitutionTable }

class function TOpenTypeGlyphSubstitutionTable.GetTableType: TTableType;
begin
  Result := 'GSUB';
end;


{ TOpenTypeExtenderGlyphTable }

procedure TOpenTypeExtenderGlyphTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeExtenderGlyphTable then
    FGlyphID := TOpenTypeExtenderGlyphTable(Source).FGlyphID;
end;

procedure TOpenTypeExtenderGlyphTable.LoadFromStream(Stream: TStream);
var
  GlyphIdIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // set length of glyphID array
    SetLength(FGlyphID, ReadSwappedWord(Stream));

    // read glyph IDs from stream
    for GlyphIdIndex := 0 to High(FGlyphID) do
      FGlyphID[GlyphIdIndex] := ReadSwappedWord(Stream)
  end;
end;

procedure TOpenTypeExtenderGlyphTable.SaveToStream(Stream: TStream);
var
  GlyphIdIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // write length of glyphID array to stream
    WriteSwappedWord(Stream, Length(FGlyphID));

    // write glyph IDs to stream
    for GlyphIdIndex := 0 to High(FGlyphID) do
      WriteSwappedWord(Stream, FGlyphID[GlyphIdIndex]);
  end;
end;


{ TCustomOpenTypeJustificationLanguageSystemTable }

constructor TCustomOpenTypeJustificationLanguageSystemTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited Create(Storage);
end;

destructor TCustomOpenTypeJustificationLanguageSystemTable.Destroy;
begin
  inherited;
end;

procedure TCustomOpenTypeJustificationLanguageSystemTable.LoadFromStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);
  end;
end;

procedure TCustomOpenTypeJustificationLanguageSystemTable.SaveToStream
  (Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TOpenTypeJustificationLanguageSystemTable }

class function TOpenTypeJustificationLanguageSystemTable.GetDisplayName: string;
begin
  Result := 'Default';
end;

class function TOpenTypeJustificationLanguageSystemTable.GetTableType: TTableType;
begin
  Result := 'DFLT';
end;


{ TCustomOpenTypeJustificationScriptTable }

constructor TCustomOpenTypeJustificationScriptTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited Create(Storage);
  FLanguageSystemTables := TPascalTypeTableInterfaceList<TCustomOpenTypeJustificationLanguageSystemTable>.Create(AStorage);
end;

destructor TCustomOpenTypeJustificationScriptTable.Destroy;
begin
  FreeAndNil(FDefaultLangSys);
  FreeAndNil(FExtenderGlyphTable);
  FreeAndNil(FLanguageSystemTables);

  inherited;
end;

procedure TCustomOpenTypeJustificationScriptTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeJustificationScriptTable then
  begin
    if (TCustomOpenTypeJustificationScriptTable(Source).FExtenderGlyphTable <> nil) then
    begin
      if (FExtenderGlyphTable = nil) then
        FExtenderGlyphTable := TOpenTypeExtenderGlyphTable.Create;

      FExtenderGlyphTable.Assign(TCustomOpenTypeJustificationScriptTable(Source).FExtenderGlyphTable);
    end else
      FreeAndNil(FExtenderGlyphTable);

    if (TCustomOpenTypeJustificationScriptTable(Source).FDefaultLangSys <> nil) then
    begin
      if (FDefaultLangSys = nil) then
        FDefaultLangSys := TOpenTypeJustificationLanguageSystemTable.Create(Storage);

      FDefaultLangSys.Assign(TCustomOpenTypeJustificationScriptTable(Source).FDefaultLangSys);
    end else
      FreeAndNil(FDefaultLangSys);

    FLanguageSystemTables.Assign(TCustomOpenTypeJustificationScriptTable(Source).FLanguageSystemTables);
  end;
end;

function TCustomOpenTypeJustificationScriptTable.GetLanguageSystemTable(Index: Integer): TCustomOpenTypeJustificationLanguageSystemTable;
begin
  if (Index < 0) or (Index >= FLanguageSystemTables.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FLanguageSystemTables[Index];
end;

procedure TCustomOpenTypeJustificationScriptTable.SetDefaultLangSys(const Value: TCustomOpenTypeJustificationLanguageSystemTable);
begin
  if (Value <> nil) then
  begin
    if (FDefaultLangSys = nil) then
      FDefaultLangSys := TOpenTypeJustificationLanguageSystemTable.Create(Storage);
    FDefaultLangSys.Assign(Value);
  end else
    FreeAndNil(FDefaultLangSys);
  Changed;
end;

function TCustomOpenTypeJustificationScriptTable.GetLanguageSystemTableCount: Integer;
begin
  Result := FLanguageSystemTables.Count;
end;

procedure TCustomOpenTypeJustificationScriptTable.LoadFromStream(Stream: TStream);
var
  StartPos      : Int64;
  LangSysIndex  : Integer;
  LangSysRecords: array of TTagOffsetRecord;
  LangTable     : TCustomOpenTypeJustificationLanguageSystemTable;
  LangTableClass: TOpenTypeJustificationLanguageSystemTableClass;
  ExtenderGlyph : Word;
  DefaultLangSys: Word;
begin
  inherited;

  with Stream do
  begin
    StartPos := Position;

    // check (minimum) table size
    if Position + 6 > Size then
      raise EPascalTypeError.Create(RCStrTableIncomplete);

    // read extender glyph offset
    ExtenderGlyph := ReadSwappedWord(Stream);

    // read default language system offset
    DefaultLangSys := ReadSwappedWord(Stream);

    // read language system record count
    SetLength(LangSysRecords, ReadSwappedWord(Stream));

    for LangSysIndex := 0 to High(LangSysRecords) do
    begin
      // read table type
      Read(LangSysRecords[LangSysIndex].Tag, SizeOf(TTableType));

      // read offset
      LangSysRecords[LangSysIndex].Offset := ReadSwappedWord(Stream);
    end;

    // load default language system
    if ExtenderGlyph <> 0 then
    begin
      Position := StartPos + ExtenderGlyph;

      if (FExtenderGlyphTable = nil) then
        FExtenderGlyphTable := TOpenTypeExtenderGlyphTable.Create;

      FExtenderGlyphTable.LoadFromStream(Stream);
    end else
      FreeAndNil(FExtenderGlyphTable);

    // load default language system
    if DefaultLangSys <> 0 then
    begin
      Position := StartPos + DefaultLangSys;

      if (FDefaultLangSys = nil) then
        FDefaultLangSys := TOpenTypeJustificationLanguageSystemTable.Create(Storage);

      FDefaultLangSys.LoadFromStream(Stream);
    end else
      FreeAndNil(FDefaultLangSys);

    // clear existing language tables
    FLanguageSystemTables.Clear;

    for LangSysIndex := 0 to High(LangSysRecords) do
    begin
      LangTableClass := FindJustificationLanguageSystemByType(LangSysRecords[LangSysIndex].Tag);

      if (LangTableClass <> nil) then
      begin
        // create language table entry
        // add to language system tables
        LangTable := FLanguageSystemTables.Add(LangTableClass);

        // set position
        Position := StartPos + LangSysRecords[LangSysIndex].Offset;

        // read language system table entry from stream
        LangTable.LoadFromStream(Stream);
      end;
    end;
  end;
end;

procedure TCustomOpenTypeJustificationScriptTable.SaveToStream(Stream: TStream);
var
  StartPos      : Int64;
  LangSysIndex  : Integer;
  LangSysRecords: array of TTagOffsetRecord;
  Value16       : Word;
  DefLangSysOff : Word;
  ExtGlyphOff   : Word;
begin
  inherited;

  with Stream do
  begin
    // remember start position of the stream
    StartPos := Position;

    // find offset for data
    if (FDefaultLangSys <> nil) then
      Value16 := 2 + 4 * FLanguageSystemTables.Count
    else
      Value16 := 0;
    if (FExtenderGlyphTable <> nil) then
      Value16 := Value16 + 2;

    Position := StartPos + Value16;

    // write extender glyph table
    if (FExtenderGlyphTable <> nil) then
    begin
      ExtGlyphOff := Word(Position - StartPos);
      FExtenderGlyphTable.SaveToStream(Stream);
    end else
      ExtGlyphOff := 0;

    // write default language system table
    if (FDefaultLangSys <> nil) then
    begin
      DefLangSysOff := Word(Position - StartPos);
      FDefaultLangSys.SaveToStream(Stream);
    end else
      DefLangSysOff := 0;

    // build directory (to be written later) and write data
    SetLength(LangSysRecords, FLanguageSystemTables.Count);
    for LangSysIndex := 0 to High(LangSysRecords) do
      with FLanguageSystemTables[LangSysIndex] do
      begin
        // get table type
        LangSysRecords[LangSysIndex].Tag := TableType;
        LangSysRecords[LangSysIndex].Offset := Position;

        // write feature to stream
        SaveToStream(Stream);
      end;

    // write extender glyph offset
    WriteSwappedWord(Stream, ExtGlyphOff);

    // write default language system offset
    WriteSwappedWord(Stream, DefLangSysOff);

    // write directory
    Position := StartPos;

    for LangSysIndex := 0 to High(LangSysRecords) do
      with LangSysRecords[LangSysIndex] do
      begin
        // write tag
        Write(Tag, SizeOf(TTableType));

        // write offset
        WriteSwappedWord(Stream, Offset);
      end;
  end;
end;


{ TOpenTypeJustificationScriptTable }

class function TOpenTypeJustificationScriptTable.GetDisplayName: string;
begin
  Result := 'Default';
end;

class function TOpenTypeJustificationScriptTable.GetTableType: TTableType;
begin
  Result := 'DFLT';
end;


{ TOpenTypeJustificationTable }

constructor TOpenTypeJustificationTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  inherited;
  FVersion.Value := 1;
  FScripts := TPascalTypeTableInterfaceList<TCustomOpenTypeJustificationScriptTable>.Create(AStorage);
end;

destructor TOpenTypeJustificationTable.Destroy;
begin
  FreeAndNil(FScripts);
  inherited;
end;

class function TOpenTypeJustificationTable.GetTableType: TTableType;
begin
  Result := 'JSTF';
end;

procedure TOpenTypeJustificationTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeJustificationTable then
  begin
    FVersion := TOpenTypeJustificationTable(Source).FVersion;
    FScripts.Assign(TOpenTypeJustificationTable(Source).FScripts);
  end;
end;

function TOpenTypeJustificationTable.GetScriptCount: Cardinal;
begin
  Result := FScripts.Count;
end;

procedure TOpenTypeJustificationTable.LoadFromStream(Stream: TStream);
var
  StartPos : Int64;
  DirIndex : Integer;
  Directory: array of TJustificationScriptDirectoryEntry;
  Script   : TCustomOpenTypeJustificationScriptTable;
begin
  inherited;

  with Stream do
  begin
    StartPos := Position;

    if Position + 6 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion.Fixed := ReadSwappedCardinal(Stream);

    if Version.Value <> 1 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read Justification Script Count
    SetLength(Directory, ReadSwappedWord(Stream));

    // check if table is complete
    if Position + Length(Directory) * SizeOf(TJustificationScriptDirectoryEntry) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read directory entry
    for DirIndex := 0 to High(Directory) do
      with Directory[DirIndex] do
      begin
        // read tag
        Read(Tag, SizeOf(Cardinal));

        // read offset
        Offset := ReadSwappedWord(Stream);
      end;

    // clear existing scripts
    FScripts.Clear;

    // read digital scripts
    for DirIndex := 0 to High(Directory) do
      with Directory[DirIndex] do
      begin
        // TODO: Find matching justification script by tag!!!
        Script := FScripts.Add;

        // jump to the right position
        Position := StartPos + Offset;

        // load digital signature from stream
        Script.LoadFromStream(Stream);
      end;
  end;
end;

procedure TOpenTypeJustificationTable.SaveToStream(Stream: TStream);
var
  StartPos : Int64;
  DirIndex : Integer;
  Directory: array of TJustificationScriptDirectoryEntry;
begin
  inherited;

  with Stream do
  begin
    // store stream start position
    StartPos := Position;

    // write version
    WriteSwappedCardinal(Stream, Cardinal(FVersion));

    // write Justification Script Count
    WriteSwappedWord(Stream, Length(Directory));

    // set directory length
    SetLength(Directory, FScripts.Count);

    // offset directory
    Seek(soFromCurrent, FScripts.Count * 3 * SizeOf(Word));

    // build directory and store signature
    for DirIndex := 0 to FScripts.Count - 1 do
    begin
      Directory[DirIndex].Offset := Position - StartPos;
      Directory[DirIndex].Tag := FScripts[DirIndex].GetTableType;
      SaveToStream(Stream);
    end;

    // locate directory
    Position := StartPos + 3 * SizeOf(Word);

    // write directory entries
    for DirIndex := 0 to High(Directory) do
      begin
        // write tag
        Write(Directory[DirIndex].Tag, SizeOf(Cardinal));

        // write offset
        WriteSwappedWord(Stream, Directory[DirIndex].Offset);
      end;
  end;
end;

procedure TOpenTypeJustificationTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TOpenTypeJustificationTable.VersionChanged;
begin
  Changed;
end;

/// /////////////////////////////////////////////////////////////////////////////

function IsLanguageSystemClassRegistered(LanguageSystemClass
  : TOpenTypeLanguageSystemTableClass): Boolean;
var
  TableClassIndex: Integer;
begin
  Result := False;
  for TableClassIndex := 0 to High(GLanguageSystemClasses) do
    if GLanguageSystemClasses[TableClassIndex] = LanguageSystemClass then
    begin
      Result := True;
      Exit;
    end;
end;

procedure RegisterLanguageSystem(LanguageSystemClass
  : TOpenTypeLanguageSystemTableClass);
begin
  Assert(IsLanguageSystemClassRegistered(LanguageSystemClass) = False);
  SetLength(GLanguageSystemClasses, Length(GLanguageSystemClasses) + 1);
  GLanguageSystemClasses[High(GLanguageSystemClasses)] :=
    LanguageSystemClass;
end;

procedure RegisterLanguageSystems(LanguageSystemClasses
  : array of TOpenTypeLanguageSystemTableClass);
var
  LanguageSystemIndex: Integer;
begin
  for LanguageSystemIndex := 0 to High(LanguageSystemClasses) do
    RegisterLanguageSystem(LanguageSystemClasses[LanguageSystemIndex]);
end;

function FindLanguageSystemByType(TableType: TTableType)
  : TOpenTypeLanguageSystemTableClass;
var
  LanguageSystemIndex: Integer;
begin
  Result := nil;
  for LanguageSystemIndex := 0 to High(GLanguageSystemClasses) do
    if GLanguageSystemClasses[LanguageSystemIndex].GetTableType = TableType then
    begin
      Result := GLanguageSystemClasses[LanguageSystemIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown Table Class: ' + TableType);
end;

/// /////////////////////////////////////////////////////////////////////////////

function IsScriptClassRegistered(ScriptClass
  : TOpenTypeScriptTableClass): Boolean;
var
  TableClassIndex: Integer;
begin
  Result := False;
  for TableClassIndex := 0 to High(GScriptClasses) do
    if GScriptClasses[TableClassIndex] = ScriptClass then
    begin
      Result := True;
      Exit;
    end;
end;

procedure RegisterScript(ScriptClass: TOpenTypeScriptTableClass);
begin
  Assert(IsScriptClassRegistered(ScriptClass) = False);
  SetLength(GScriptClasses, Length(GScriptClasses) + 1);
  GScriptClasses[High(GScriptClasses)] := ScriptClass;
end;

procedure RegisterScripts(ScriptClasses: array of TOpenTypeScriptTableClass);
var
  ScriptIndex: Integer;
begin
  for ScriptIndex := 0 to High(ScriptClasses) do
    RegisterScript(ScriptClasses[ScriptIndex]);
end;

function FindScriptByType(TableType: TTableType): TOpenTypeScriptTableClass;
var
  ScriptIndex: Integer;
begin
  Result := nil;
  for ScriptIndex := 0 to High(GScriptClasses) do
    if GScriptClasses[ScriptIndex].GetTableType = TableType then
    begin
      Result := GScriptClasses[ScriptIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown table class: ' + TableType);
end;

/// /////////////////////////////////////////////////////////////////////////////

function IsFeatureClassRegistered(FeatureClass
  : TOpenTypeFeatureTableClass): Boolean;
var
  TableClassIndex: Integer;
begin
  Result := False;
  for TableClassIndex := 0 to High(GFeatureClasses) do
    if GFeatureClasses[TableClassIndex] = FeatureClass then
    begin
      Result := True;
      Exit;
    end;
end;

function CheckFeatureClassesValid: Boolean;
var
  TableClassBaseIndex: Integer;
  TableClassIndex    : Integer;
begin
  Result := True;
  for TableClassBaseIndex := 0 to High(GFeatureClasses) do
    for TableClassIndex := TableClassBaseIndex +
      1 to High(GFeatureClasses) do
      if GFeatureClasses[TableClassBaseIndex] = GFeatureClasses[TableClassIndex]
      then
      begin
        Result := False;
        Exit;
      end;
end;

procedure RegisterFeature(FeatureClass: TOpenTypeFeatureTableClass);
begin
  Assert(IsFeatureClassRegistered(FeatureClass) = False);
  SetLength(GFeatureClasses, Length(GFeatureClasses) + 1);
  GFeatureClasses[High(GFeatureClasses)] := FeatureClass;
end;

procedure RegisterFeatures(FeaturesClasses
  : array of TOpenTypeFeatureTableClass);
var
  FeaturesIndex: Integer;
begin
  SetLength(GFeatureClasses, Length(GFeatureClasses) + Length(FeaturesClasses));
  for FeaturesIndex := 0 to High(FeaturesClasses) do
    GFeatureClasses[Length(GFeatureClasses) - Length(FeaturesClasses) +
      FeaturesIndex] := FeaturesClasses[FeaturesIndex];
  Assert(CheckFeatureClassesValid);
end;

function FindFeatureByType(TableType: TTableType): TOpenTypeFeatureTableClass;
var
  FeaturesIndex: Integer;
begin
  Result := nil;
  for FeaturesIndex := 0 to High(GFeatureClasses) do
    if GFeatureClasses[FeaturesIndex].GetTableType = TableType then
    begin
      Result := GFeatureClasses[FeaturesIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown Table Class: ' + TableType);
end;

/// /////////////////////////////////////////////////////////////////////////////

function IsJustificationLanguageSystemClassRegistered(LanguageSystemClass: TOpenTypeJustificationLanguageSystemTableClass): Boolean;
var
  TableClassIndex: Integer;
begin
  Result := False;
  for TableClassIndex := 0 to High(GJustificationLanguageSystemClasses) do
    if GJustificationLanguageSystemClasses[TableClassIndex] = LanguageSystemClass
    then
    begin
      Result := True;
      Exit;
    end;
end;

procedure RegisterJustificationLanguageSystem(LanguageSystemClass: TOpenTypeJustificationLanguageSystemTableClass);
begin
  Assert(IsJustificationLanguageSystemClassRegistered
    (LanguageSystemClass) = False);
  SetLength(GJustificationLanguageSystemClasses,
    Length(GJustificationLanguageSystemClasses) + 1);
  GJustificationLanguageSystemClasses
    [High(GJustificationLanguageSystemClasses)] := LanguageSystemClass;
end;

procedure RegisterJustificationLanguageSystems(LanguageSystemClasses: array of TOpenTypeJustificationLanguageSystemTableClass);
var
  LangSysIndex: Integer;
begin
  for LangSysIndex := 0 to High(LanguageSystemClasses) do
    RegisterJustificationLanguageSystem(LanguageSystemClasses[LangSysIndex]);
end;

function FindJustificationLanguageSystemByType(TableType: TTableType): TOpenTypeJustificationLanguageSystemTableClass;
var
  LangSysIndex: Integer;
begin
  Result := nil;
  for LangSysIndex := 0 to High(GJustificationLanguageSystemClasses) do
    if GJustificationLanguageSystemClasses[LangSysIndex].GetTableType = TableType then
    begin
      Result := GJustificationLanguageSystemClasses[LangSysIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown Table Class: ' + TableType);
end;

initialization

RegisterPascalTypeTables([TOpenTypeBaselineTable, TOpenTypeGlyphDefinitionTable,
  TOpenTypeGlyphPositionTable, TOpenTypeGlyphSubstitutionTable,
  TOpenTypeJustificationTable]);

RegisterScript(TOpenTypeDefaultLanguageSystemTables);

end.
