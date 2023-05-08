unit PascalType.Tables.OpenType.Script;

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
  PascalType.Tables.OpenType.LanguageSystem;

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeScriptTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#script-table-and-language-system-record
//------------------------------------------------------------------------------
type
  TCustomOpenTypeScriptTable = class(TCustomOpenTypeNamedTable)
  private
    FDefaultLangSys      : TCustomOpenTypeLanguageSystemTable;
    FLanguageSystemTables: TPascalTypeTableInterfaceList<TCustomOpenTypeLanguageSystemTable>;
    function GetLanguageSystemTable(Index: Integer): TCustomOpenTypeLanguageSystemTable;
    function GetLanguageSystemTableCount: Integer;
    procedure SetDefaultLangSys(const Value: TCustomOpenTypeLanguageSystemTable);
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function FindLanguageSystem(const ATableType: TTableType): TCustomOpenTypeLanguageSystemTable;

    property DefaultLangSys: TCustomOpenTypeLanguageSystemTable read FDefaultLangSys write SetDefaultLangSys;
    property LanguageSystemTableCount: Integer read GetLanguageSystemTableCount;
    property LanguageSystemTable[Index: Integer]: TCustomOpenTypeLanguageSystemTable read GetLanguageSystemTable;
  end;

  TOpenTypeScriptTableClass = class of TCustomOpenTypeScriptTable;


//------------------------------------------------------------------------------
//
//              TOpenTypeDefaultLanguageSystemTables
//
//------------------------------------------------------------------------------
type
  TOpenTypeDefaultLanguageSystemTables = class(TCustomOpenTypeScriptTable)
  protected
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;

    procedure LoadFromStream(Stream: TStream); override;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeScriptListTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeScriptListTable = class(TCustomPascalTypeTable)
  private
    FLangSysList: TPascalTypeTableInterfaceList<TCustomOpenTypeScriptTable>;
    function GetLanguageSystemCount: Integer;
    function GetLanguageSystem(Index: Integer): TCustomOpenTypeScriptTable;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function FindScript(const ATableType: TTableType): TCustomOpenTypeScriptTable;

    property LanguageSystemCount: Integer read GetLanguageSystemCount;
    property LanguageSystems[Index: Integer]: TCustomOpenTypeScriptTable read GetLanguageSystem;
  end;



//------------------------------------------------------------------------------
//
//      scripts
//
//------------------------------------------------------------------------------
procedure RegisterScript(ScriptClass: TOpenTypeScriptTableClass);
procedure RegisterScripts(ScriptClasses: array of TOpenTypeScriptTableClass);
function FindScriptByType(TableType: TTableType): TOpenTypeScriptTableClass;

var
  GScriptClasses         : array of TOpenTypeScriptTableClass;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings,
  PascalType.Tables.OpenType.JSTF;

//------------------------------------------------------------------------------
//
//      scripts
//
//------------------------------------------------------------------------------
function IsScriptClassRegistered(ScriptClass: TOpenTypeScriptTableClass): Boolean;
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


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeScriptTable
//
//------------------------------------------------------------------------------
{ TCustomOpenTypeScriptTable }

constructor TCustomOpenTypeScriptTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FLanguageSystemTables := TPascalTypeTableInterfaceList<TCustomOpenTypeLanguageSystemTable>.Create(Self);
end;

destructor TCustomOpenTypeScriptTable.Destroy;
begin
  FreeAndNil(FDefaultLangSys);
  FreeAndNil(FLanguageSystemTables);

  inherited;
end;

function TCustomOpenTypeScriptTable.FindLanguageSystem(const ATableType: TTableType): TCustomOpenTypeLanguageSystemTable;
begin
  for Result in FLanguageSystemTables do
    if (Result.TableType = ATableType) then
      exit;
  Result := nil;
end;

function TCustomOpenTypeScriptTable.GetLanguageSystemTable(Index: Integer): TCustomOpenTypeLanguageSystemTable;
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
        FDefaultLangSys := TOpenTypeDefaultLanguageSystemTable.Create(Self);

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
  LangTable     : TCustomOpenTypeLanguageSystemTable;
  LangTableClass: TOpenTypeLanguageSystemTableClass;
  DefaultLangSys: Word;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read default language system offset
  DefaultLangSys := ReadSwappedWord(Stream);

  // read language system record count
  SetLength(LangSysRecords, ReadSwappedWord(Stream));

  for LangSysIndex := 0 to High(LangSysRecords) do
  begin
    // read table type
    Stream.Read(LangSysRecords[LangSysIndex].Tag, SizeOf(TTableType));

    // read offset
    LangSysRecords[LangSysIndex].Offset := ReadSwappedWord(Stream);
  end;

  // load default language system
  if DefaultLangSys <> 0 then
  begin
    Stream.Position := StartPos + DefaultLangSys;

    if (FDefaultLangSys = nil) then
      FDefaultLangSys := TOpenTypeDefaultLanguageSystemTable.Create(Self);

    FDefaultLangSys.LoadFromStream(Stream);
  end else
    FreeAndNil(FDefaultLangSys);

  // clear existing language tables
  FLanguageSystemTables.Clear;

  for LangSysIndex := 0 to High(LangSysRecords) do
  begin
    LangTableClass := FindLanguageSystemByType(LangSysRecords[LangSysIndex].Tag);

    if (LangTableClass <> nil) then
    begin
      // create language table entry
      // add to language system tables
      // DONE : Something was wrong here. We are adding TCustomOpenTypeJustificationLanguageSystemTable but the list contains
      // TCustomOpenTypeLanguageSystemTable (per the list getter).
      // - I have changed the list and getter to use their common base class: TCustomOpenTypeJustificationLanguageSystemTable
      // - I have now changed it to use FindLanguageSystemByType and TCustomOpenTypeLanguageSystemTable
      LangTable := FLanguageSystemTables.Add(LangTableClass);

      // set position
      Stream.Position := StartPos + LangSysRecords[LangSysIndex].Offset;

      // read language system table entry from stream
      LangTable.LoadFromStream(Stream);
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

procedure TCustomOpenTypeScriptTable.SetDefaultLangSys(const Value: TCustomOpenTypeLanguageSystemTable);
begin
  FDefaultLangSys.Assign(Value);
  Changed;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeDefaultLanguageSystemTables
//
//------------------------------------------------------------------------------
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


//------------------------------------------------------------------------------
//
//              TOpenTypeScriptListTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeScriptListTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FLangSysList := TPascalTypeTableInterfaceList<TCustomOpenTypeScriptTable>.Create(Self);
end;

destructor TOpenTypeScriptListTable.Destroy;
begin
  FreeAndNil(FLangSysList);
  inherited;
end;

function TOpenTypeScriptListTable.FindScript(const ATableType: TTableType): TCustomOpenTypeScriptTable;
begin
  for Result in FLangSysList do
    if (Result.TableType = ATableType) then
      exit;
  Result := nil;
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
  ScriptTableTagOffsets: array of TTagOffsetRecord;
  ScriptTable     : TCustomOpenTypeScriptTable;
  ScriptTableClass: TOpenTypeScriptTableClass;
begin
  inherited;

  StartPos := Stream.Position;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read script list count
  SetLength(ScriptTableTagOffsets, ReadSwappedWord(Stream));

  for ScriptIndex := 0 to High(ScriptTableTagOffsets) do
  begin
    // read table type
    Stream.Read(ScriptTableTagOffsets[ScriptIndex].Tag, SizeOf(TTableType));

    // read offset
    ScriptTableTagOffsets[ScriptIndex].Offset := ReadSwappedWord(Stream);
  end;

  // clear language system list
  FLangSysList.Clear;

  for ScriptIndex := 0 to High(ScriptTableTagOffsets) do
  begin
    // find language class
    ScriptTableClass := FindScriptByType(ScriptTableTagOffsets[ScriptIndex].Tag);

    if (ScriptTableClass <> nil) then
    begin
      // create language system entry
      // add to language system list
      ScriptTable := FLangSysList.Add(ScriptTableClass);

      // set position to actual script list entry
      Stream.Position := StartPos + ScriptTableTagOffsets[ScriptIndex].Offset;

      // load from stream
      ScriptTable.LoadFromStream(Stream);
    end;
  end;
end;

procedure TOpenTypeScriptListTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


//------------------------------------------------------------------------------

initialization

  RegisterScript(TOpenTypeDefaultLanguageSystemTables);

end.
