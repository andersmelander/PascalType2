unit PascalType.Tables.OpenType.Common;

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
  PascalType.Tables.OpenType.Feature,
  PascalType.Tables.OpenType.Script,
  PascalType.Tables.OpenType.Lookup;

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeCommonTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2
//------------------------------------------------------------------------------
type
  TCustomOpenTypeCommonTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion          : TFixedPoint;
    FScriptListTable  : TOpenTypeScriptListTable;
    FFeatureListTable : TOpenTypeFeatureListTable;
    FLookupListTable  : TOpenTypeLookupListTable;
    procedure SetVersion(const Value: TFixedPoint);
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function GetLookupTableClass(ALookupType: Word): TOpenTypeLookupTableClass; virtual; abstract;
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; virtual; abstract;

    property Version: TFixedPoint read FVersion write SetVersion;
    property ScriptListTable: TOpenTypeScriptListTable read FScriptListTable;
    property FeatureListTable: TOpenTypeFeatureListTable read FFeatureListTable;
    property LookupListTable: TOpenTypeLookupListTable read FLookupListTable;
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
//              TCustomOpenTypeCommonTable
//
//------------------------------------------------------------------------------
constructor TCustomOpenTypeCommonTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;

  FScriptListTable := TOpenTypeScriptListTable.Create(Self);
  FFeatureListTable := TOpenTypeFeatureListTable.Create(Self);
  FLookupListTable := TOpenTypeLookupListTable.Create(Self);
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

  ScriptListPosition := StartPosition + ReadSwappedWord(Stream);
  FeatureListPosition := StartPosition + ReadSwappedWord(Stream);
  LookupListPosition := StartPosition + ReadSwappedWord(Stream);

  // For version 1.1 there will be a 32-bit "featureVariationsOffset" here
  // if (FVersion.Fract >= 1) then
  //   FeatureVariationsPosition := StartPosition + ReadSwappedCardinal(Stream);
  // else
  //   FeatureVariationsPosition := 0;

  // load script table
  Stream.Position := ScriptListPosition;
  FScriptListTable.LoadFromStream(Stream);

  // load script table
  Stream.Position := FeatureListPosition;
  FFeatureListTable.LoadFromStream(Stream);

  // load lookup table
  Stream.Position := LookupListPosition;
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
  if (FVersion.Fixed <> Value.Fixed) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TCustomOpenTypeCommonTable.VersionChanged;
begin
  Changed;
end;

//------------------------------------------------------------------------------

end.
