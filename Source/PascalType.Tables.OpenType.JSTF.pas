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
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables,
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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
  PascalType.ResourceStrings;

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

procedure TCustomOpenTypeJustificationLanguageSystemTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);
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

procedure TOpenTypeExtenderGlyphTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  GlyphIdIndex: Integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // set length of glyphID array
  SetLength(FGlyphID, BigEndianValue.ReadWord(Stream));

  // read glyph IDs from stream
  for GlyphIdIndex := 0 to High(FGlyphID) do
    FGlyphID[GlyphIdIndex] := BigEndianValue.ReadWord(Stream)
end;

procedure TOpenTypeExtenderGlyphTable.SaveToStream(Stream: TStream);
var
  GlyphIdIndex: Integer;
begin
  inherited;

  // write length of glyphID array to stream
  BigEndianValue.WriteWord(Stream, Length(FGlyphID));

  // write glyph IDs to stream
  for GlyphIdIndex := 0 to High(FGlyphID) do
    BigEndianValue.WriteWord(Stream, FGlyphID[GlyphIdIndex]);
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

procedure TCustomOpenTypeJustificationScriptTable.LoadFromStream(Stream: TStream; Size: Cardinal);
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

  StartPos := Stream.Position;

  // check (minimum) table size
  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read extender glyph offset
  ExtenderGlyph := BigEndianValue.ReadWord(Stream);

  // read default language system offset
  DefaultLangSys := BigEndianValue.ReadWord(Stream);

  // read language system record count
  SetLength(LangSysRecords, BigEndianValue.ReadWord(Stream));

  for LangSysIndex := 0 to High(LangSysRecords) do
  begin
    // read table type
    Stream.Read(LangSysRecords[LangSysIndex].Tag, SizeOf(TTableType));

    // read offset
    LangSysRecords[LangSysIndex].Offset := BigEndianValue.ReadWord(Stream);
  end;

  // load default language system
  if ExtenderGlyph <> 0 then
  begin
    Stream.Position := StartPos + ExtenderGlyph;

    if (FExtenderGlyphTable = nil) then
      FExtenderGlyphTable := TOpenTypeExtenderGlyphTable.Create;

    FExtenderGlyphTable.LoadFromStream(Stream);
  end else
    FreeAndNil(FExtenderGlyphTable);

  // load default language system
  if DefaultLangSys <> 0 then
  begin
    Stream.Position := StartPos + DefaultLangSys;

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
      Stream.Position := StartPos + LangSysRecords[LangSysIndex].Offset;

      // read language system table entry from stream
      LangTable.LoadFromStream(Stream);
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

  // remember start position of the stream
  StartPos := Stream.Position;

  // find offset for data
  if (FDefaultLangSys <> nil) then
    Value16 := 2 + 4 * FLanguageSystemTables.Count
  else
    Value16 := 0;
  if (FExtenderGlyphTable <> nil) then
    Value16 := Value16 + 2;

  Stream.Position := StartPos + Value16;

  // write extender glyph table
  if (FExtenderGlyphTable <> nil) then
  begin
    ExtGlyphOff := Word(Stream.Position - StartPos);
    FExtenderGlyphTable.SaveToStream(Stream);
  end else
    ExtGlyphOff := 0;

  // write default language system table
  if (FDefaultLangSys <> nil) then
  begin
    DefLangSysOff := Word(Stream.Position - StartPos);
    FDefaultLangSys.SaveToStream(Stream);
  end else
    DefLangSysOff := 0;

  // build directory (to be written later) and write data
  SetLength(LangSysRecords, FLanguageSystemTables.Count);
  for LangSysIndex := 0 to High(LangSysRecords) do
  begin
    var LTable := FLanguageSystemTables[LangSysIndex];
    // get table type
    LangSysRecords[LangSysIndex].Tag := LTable.TableType;
    LangSysRecords[LangSysIndex].Offset := Stream.Position;

    // write feature to stream
    LTable.SaveToStream(Stream);
  end;

  // write extender glyph offset
  BigEndianValue.WriteWord(Stream, ExtGlyphOff);

  // write default language system offset
  BigEndianValue.WriteWord(Stream, DefLangSysOff);

  // write directory
  Stream.Position := StartPos;

  for LangSysIndex := 0 to High(LangSysRecords) do
  begin
    // write tag
    Stream.Write(LangSysRecords[LangSysIndex].Tag, SizeOf(TTableType));

    // write offset
    BigEndianValue.WriteWord(Stream, LangSysRecords[LangSysIndex].Offset);
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

procedure TOpenTypeJustificationTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos : Int64;
  DirIndex : Integer;
  Directory: array of TJustificationScriptDirectoryEntry;
  Script   : TCustomOpenTypeJustificationScriptTable;
begin
  inherited;

  StartPos := Stream.Position;

  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read version
  FVersion.Fixed := BigEndianValue.ReadInteger(Stream);

  if Version.Value <> 1 then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read Justification Script Count
  SetLength(Directory, BigEndianValue.ReadWord(Stream));

  // check if table is complete
  if Stream.Position + Length(Directory) * SizeOf(TJustificationScriptDirectoryEntry) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read directory entry
  for DirIndex := 0 to High(Directory) do
  begin
    // read tag
    Stream.Read(Directory[DirIndex].Tag, SizeOf(Cardinal));

    // read offset
    Directory[DirIndex].Offset := BigEndianValue.ReadWord(Stream);
  end;

  // clear existing scripts
  FScripts.Clear;

  // read digital scripts
  for DirIndex := 0 to High(Directory) do
  begin
    // TODO: Find matching justification script by tag!!!
    Script := FScripts.Add;

    // jump to the right position
    Stream.Position := StartPos + Directory[DirIndex].Offset;

    // load digital signature from stream
    Script.LoadFromStream(Stream);
  end;
end;

procedure TOpenTypeJustificationTable.SaveToStream(Stream: TStream);
var
  StartPos : Int64;
  DirIndex : Integer;
  Directory: array of TJustificationScriptDirectoryEntry;
begin
  inherited;

  // store stream start position
  StartPos := Stream.Position;

  // write version
  BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));

  // write Justification Script Count
  BigEndianValue.WriteWord(Stream, Length(Directory));

  // set directory length
  SetLength(Directory, FScripts.Count);

  // offset directory
  Stream.Seek(soFromCurrent, FScripts.Count * 3 * SizeOf(Word));

  // build directory and store signature
  for DirIndex := 0 to FScripts.Count - 1 do
  begin
    Directory[DirIndex].Offset := Stream.Position - StartPos;
    Directory[DirIndex].Tag := FScripts[DirIndex].TableType;
    SaveToStream(Stream);
  end;

  // locate directory
  Stream.Position := StartPos + 3 * SizeOf(Word);

  // write directory entries
  for DirIndex := 0 to High(Directory) do
  begin
    // write tag
    Stream.Write(Directory[DirIndex].Tag, SizeOf(Cardinal));

    // write offset
    BigEndianValue.WriteWord(Stream, Directory[DirIndex].Offset);
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

  PascalTypeTableClasses.RegisterTables([TOpenTypeJustificationTable]);

end.
