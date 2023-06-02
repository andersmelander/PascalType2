unit PascalType.Tables.OpenType.JSTF;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'JSTF' table type                                     //
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
  Generics.Collections,
  Generics.Defaults,
  Classes,
  PT_Types,
  PT_Classes,
  PT_Tables,
  PascalType.Tables.OpenType,
  PascalType.Tables.OpenType.Common;

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeJustificationLanguageSystemTable
//
//------------------------------------------------------------------------------
type
  // not entirely implemented, for more information see
  // http://www.microsoft.com/typography/otspec/jstf.htm

  TCustomOpenTypeJustificationLanguageSystemTable = class(TCustomOpenTypeNamedTable)
  private
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TOpenTypeJustificationLanguageSystemTableClass = class of TCustomOpenTypeJustificationLanguageSystemTable;


//------------------------------------------------------------------------------
//
//              TOpenTypeJustificationLanguageSystemTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeJustificationLanguageSystemTable = class(TCustomOpenTypeJustificationLanguageSystemTable)
  protected
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeExtenderGlyphTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeExtenderGlyphTable = class(TCustomPascalTypeTable)
  private
    FGlyphID: TGlyphString; // GlyphIDs-in increasing numerical order
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeJustificationScriptTable
//
//------------------------------------------------------------------------------
type
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
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property DefaultLangSys: TCustomOpenTypeJustificationLanguageSystemTable read FDefaultLangSys write SetDefaultLangSys;
    property LanguageSystemTableCount: Integer read GetLanguageSystemTableCount;
    property LanguageSystemTable[Index: Integer]: TCustomOpenTypeJustificationLanguageSystemTable read GetLanguageSystemTable;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeJustificationScriptTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeJustificationScriptTable = class(TCustomOpenTypeJustificationScriptTable)
  protected
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeJustificationTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeJustificationTable = class(TCustomPascalTypeNamedTable)
  private type
    TJustificationScriptDirectoryEntry = packed record
      Tag: TTableType;
      Offset: Word;
    end;

  private
    FVersion : TFixedPoint; // Version of the JSTF table-initially set to 0x00010000
    FScripts : TPascalTypeTableInterfaceList<TCustomOpenTypeJustificationScriptTable>;
    procedure SetVersion(const Value: TFixedPoint);
    function GetScriptCount: Cardinal;
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
    property ScriptCount: Cardinal read GetScriptCount;
  end;


//------------------------------------------------------------------------------
//
//      Justification language system
//
//------------------------------------------------------------------------------

procedure RegisterJustificationLanguageSystem(LanguageSystemClass: TOpenTypeJustificationLanguageSystemTableClass);
procedure RegisterJustificationLanguageSystems(LanguageSystemClasses: array of TOpenTypeJustificationLanguageSystemTableClass);
function FindJustificationLanguageSystemByType(TableType: TTableType): TOpenTypeJustificationLanguageSystemTableClass;

var
  GJustificationLanguageSystemClasses: array of TOpenTypeJustificationLanguageSystemTableClass;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//      Justification language system
//
//------------------------------------------------------------------------------
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
  Assert(IsJustificationLanguageSystemClassRegistered(LanguageSystemClass) = False);
  SetLength(GJustificationLanguageSystemClasses, Length(GJustificationLanguageSystemClasses) + 1);
  GJustificationLanguageSystemClasses[High(GJustificationLanguageSystemClasses)] := LanguageSystemClass;
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


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeJustificationLanguageSystemTable
//
//------------------------------------------------------------------------------
constructor TCustomOpenTypeJustificationLanguageSystemTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
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


//------------------------------------------------------------------------------
//
//              TOpenTypeJustificationLanguageSystemTable
//
//------------------------------------------------------------------------------
class function TOpenTypeJustificationLanguageSystemTable.GetDisplayName: string;
begin
  Result := 'Default';
end;

class function TOpenTypeJustificationLanguageSystemTable.GetTableType: TTableType;
begin
  Result := 'DFLT';
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeExtenderGlyphTable
//
//------------------------------------------------------------------------------
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
    SetLength(FGlyphID, BigEndianValueReader.ReadWord(Stream));

    // read glyph IDs from stream
    for GlyphIdIndex := 0 to High(FGlyphID) do
      FGlyphID[GlyphIdIndex] := BigEndianValueReader.ReadWord(Stream)
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


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeJustificationScriptTable
//
//------------------------------------------------------------------------------
constructor TCustomOpenTypeJustificationScriptTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FLanguageSystemTables := TPascalTypeTableInterfaceList<TCustomOpenTypeJustificationLanguageSystemTable>.Create(Self);
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
        FDefaultLangSys := TOpenTypeJustificationLanguageSystemTable.Create(Self);

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
      FDefaultLangSys := TOpenTypeJustificationLanguageSystemTable.Create(Self);
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
    ExtenderGlyph := BigEndianValueReader.ReadWord(Stream);

    // read default language system offset
    DefaultLangSys := BigEndianValueReader.ReadWord(Stream);

    // read language system record count
    SetLength(LangSysRecords, BigEndianValueReader.ReadWord(Stream));

    for LangSysIndex := 0 to High(LangSysRecords) do
    begin
      // read table type
      Read(LangSysRecords[LangSysIndex].Tag, SizeOf(TTableType));

      // read offset
      LangSysRecords[LangSysIndex].Offset := BigEndianValueReader.ReadWord(Stream);
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
        FDefaultLangSys := TOpenTypeJustificationLanguageSystemTable.Create(Self);

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


//------------------------------------------------------------------------------
//
//              TOpenTypeJustificationScriptTable
//
//------------------------------------------------------------------------------
class function TOpenTypeJustificationScriptTable.GetDisplayName: string;
begin
  Result := 'Default';
end;

class function TOpenTypeJustificationScriptTable.GetTableType: TTableType;
begin
  Result := 'DFLT';
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeJustificationTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeJustificationTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 1;
  FScripts := TPascalTypeTableInterfaceList<TCustomOpenTypeJustificationScriptTable>.Create(Self);
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
    FVersion.Fixed := BigEndianValueReader.ReadCardinal(Stream);

    if Version.Value <> 1 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read Justification Script Count
    SetLength(Directory, BigEndianValueReader.ReadWord(Stream));

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
        Offset := BigEndianValueReader.ReadWord(Stream);
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
      Directory[DirIndex].Tag := FScripts[DirIndex].TableType;
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

//------------------------------------------------------------------------------

initialization

  RegisterPascalTypeTables([TOpenTypeJustificationTable]);

end.
