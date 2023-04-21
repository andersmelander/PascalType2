unit PascalType.Tables.OpenType.BASE;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'BASE' table type                                     //
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
//              TOpenTypeBaselineTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeBaselineTagListTable = class(TCustomPascalTypeTable)
  private
    FBaseLineTags: array of TTableType;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeBaselineScriptListTable
//
//------------------------------------------------------------------------------
type
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


//------------------------------------------------------------------------------
//
//              TOpenTypeAxisTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeAxisTable = class(TCustomPascalTypeTable)
  private
    FBaseLineTagList: TOpenTypeBaselineTagListTable;
  public
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeBaselineTable
//
//------------------------------------------------------------------------------
type
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


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypeBaselineTable
//
//------------------------------------------------------------------------------
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


//------------------------------------------------------------------------------
//
//              TOpenTypeBaselineScriptListTable
//
//------------------------------------------------------------------------------
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


//------------------------------------------------------------------------------
//
//              TOpenTypeAxisTable
//
//------------------------------------------------------------------------------
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


//------------------------------------------------------------------------------
//
//              TOpenTypeBaselineTable
//
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------

initialization

  RegisterPascalTypeTable(TOpenTypeBaselineTable);

end.
