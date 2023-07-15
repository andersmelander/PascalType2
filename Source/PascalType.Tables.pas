unit PascalType.Tables;

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
  Classes, SysUtils,
  PascalType.Types,
  PascalType.Classes;

//------------------------------------------------------------------------------
//
//              TPascalTypeUnknownTable
//
//------------------------------------------------------------------------------
// Unknown/unsupported table type
//------------------------------------------------------------------------------
type
  TPascalTypeUnknownTable = class(TCustomPascalTypeNamedTable)
  private
    FTableType: TTableType;
    FStream: TMemoryStream;
  protected
    function GetInternalTableType: TTableType; override;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Stream: TMemoryStream read FStream;
    property TableType: TTableType read GetInternalTableType write FTableType;
  end;


//------------------------------------------------------------------------------
//
//              Table class registration
//
//------------------------------------------------------------------------------
type
  PascalTypeTableClasses = record
    class procedure RegisterTable(TableClass: TCustomPascalTypeNamedTableClass); static;
    class procedure RegisterTables(const TableClasses: array of TCustomPascalTypeNamedTableClass); static;
    class function FindTableByType(const TableType: TTableType): TCustomPascalTypeNamedTableClass; static;
  end;

implementation

uses
  Generics.Collections;

//------------------------------------------------------------------------------
//
//              Table class registration
//
//------------------------------------------------------------------------------
var
  FTableClasses: TDictionary<TTableType, TCustomPascalTypeNamedTableClass> = nil;

function IsPascalTypeTableRegistered(TableClass: TCustomPascalTypeNamedTableClass): Boolean;
begin
  Result := (FTableClasses <> nil) and (FTableClasses.ContainsKey(TableClass.GetTableType));
end;

class procedure PascalTypeTableClasses.RegisterTable(TableClass: TCustomPascalTypeNamedTableClass);
begin
  if (FTableClasses = nil) then
    FTableClasses := TDictionary<TTableType, TCustomPascalTypeNamedTableClass>.Create;

  FTableClasses.AddOrSetValue(TableClass.GetTableType, TableClass);
end;

class procedure PascalTypeTableClasses.RegisterTables(const TableClasses: array of TCustomPascalTypeNamedTableClass);
var
  TableClass: TCustomPascalTypeNamedTableClass;
begin
  for TableClass in TableClasses do
    RegisterTable(TableClass);
end;

class function PascalTypeTableClasses.FindTableByType(const TableType: TTableType): TCustomPascalTypeNamedTableClass;
begin
  if (FTableClasses = nil) or (not FTableClasses.TryGetValue(TableType, Result)) then
    Result := nil;
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeUnknownTable
//
//------------------------------------------------------------------------------
constructor TPascalTypeUnknownTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited Create(AParent);
  FStream := TMemoryStream.Create;
end;

destructor TPascalTypeUnknownTable.Destroy;
begin
  FreeAndNil(FStream);
  inherited;
end;

procedure TPascalTypeUnknownTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeUnknownTable then
  begin
    FTableType := TPascalTypeUnknownTable(Source).FTableType;

    FStream.Seek(0, soFromBeginning);
    TPascalTypeUnknownTable(Source).FStream.Seek(0, soFromBeginning);
    FStream.CopyFrom(TPascalTypeUnknownTable(Source).FStream, 0);
  end;
end;

function TPascalTypeUnknownTable.GetInternalTableType: TTableType;
begin
  Result := FTableType;
end;

class function TPascalTypeUnknownTable.GetTableType: TTableType;
begin
  Result.AsInteger := 0;
end;

procedure TPascalTypeUnknownTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  FStream.Size := 0;
  if (Size > 0) then
    FStream.CopyFrom(Stream, Size);
end;

procedure TPascalTypeUnknownTable.SaveToStream(Stream: TStream);
begin
  FStream.Seek(0, soFromBeginning);
  Stream.CopyFrom(Stream, FStream.Size);
end;


initialization
finalization
  FTableClasses.Free;
end.
