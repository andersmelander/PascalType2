unit PascalType.Tables.OpenType.Positioning.Single;

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
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Positioning;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableSingle
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#lookuptype-1-single-substitution-subtable
//------------------------------------------------------------------------------
type
  TOpenTypePositioningLookupTableSingle = class(TCustomOpenTypePositioningLookupTable)
  public type
    TGlyphSinglePositioning = (
      gpsInvalid        = 0,
      gpsSingle         = 1,
      gpsList           = 2
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableSingleSingle
//
//------------------------------------------------------------------------------
// Single substitution offsetting specified glyph index
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#11-single-substitution-format-1
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableSingleSingle = class(TCustomOpenTypePositioningSubTable)
  private
    FValueRecord: TOpenTypeValueRecord;
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property ValueRecord: TOpenTypeValueRecord read FValueRecord write FValueRecord;
  end;

//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableSingleList
//
//------------------------------------------------------------------------------
// Single substitution by specified glyph index
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#12-single-substitution-format-2
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableSingleList = class(TCustomOpenTypePositioningSubTable)
  private type
    TOpenTypeValueRecords = array of TOpenTypeValueRecord;
  private
    FValueRecords: TOpenTypeValueRecords;
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property ValueRecords: TOpenTypeValueRecords read FValueRecords write FValueRecords;
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
//              TOpenTypePositioningLookupTableSingle
//
//------------------------------------------------------------------------------
function TOpenTypePositioningLookupTableSingle.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphSinglePositioning(ASubFormat) of

    gpsSingle:
      Result := TOpenTypePositioningSubTableSingleSingle;

    gpsList:
      Result := TOpenTypePositioningSubTableSingleList;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableSingleSingle
//
//------------------------------------------------------------------------------
procedure TOpenTypePositioningSubTableSingleSingle.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypePositioningSubTableSingleSingle then
    FValueRecord := TOpenTypePositioningSubTableSingleSingle(Source).ValueRecord;
end;

procedure TOpenTypePositioningSubTableSingleSingle.LoadFromStream(Stream: TStream);
var
  ValueFormat: Word;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  ValueFormat := ReadSwappedWord(Stream);

  LoadValueRecordFromStream(Stream, FValueRecord, ValueFormat);
end;

procedure TOpenTypePositioningSubTableSingleSingle.SaveToStream(Stream: TStream);
var
  ValueFormat: Word;
begin
  inherited;

  CreateValueFormat(FValueRecord, ValueFormat);
  WriteSwappedWord(Stream, ValueFormat);

  SaveValueRecordToStream(Stream, FValueRecord, ValueFormat);
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableSingleList
//
//------------------------------------------------------------------------------
procedure TOpenTypePositioningSubTableSingleList.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypePositioningSubTableSingleList then
    FValueRecords := TOpenTypePositioningSubTableSingleList(Source).ValueRecords;
end;

procedure TOpenTypePositioningSubTableSingleList.LoadFromStream(Stream: TStream);
var
  ValueFormat: Word;
  i: integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  ValueFormat := ReadSwappedWord(Stream);

  SetLength(FValueRecords, ReadSwappedWord(Stream));

  for i := 0 to High(FValueRecords) do
    LoadValueRecordFromStream(Stream, FValueRecords[i], ValueFormat);
end;

procedure TOpenTypePositioningSubTableSingleList.SaveToStream(Stream: TStream);
var
  ValueFormat: Word;
  i: integer;
begin
  inherited;

  if (Length(FValueRecords) > 0) then
    CreateValueFormat(FValueRecords[0], ValueFormat)
  else
    ValueFormat := 0;

  WriteSwappedWord(Stream, ValueFormat);

  WriteSwappedWord(Stream, Length(FValueRecords));

  for i := 0 to High(FValueRecords) do
    SaveValueRecordToStream(Stream, FValueRecords[i], ValueFormat);
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpSingleAdjustment, TOpenTypePositioningLookupTableSingle);
end.

