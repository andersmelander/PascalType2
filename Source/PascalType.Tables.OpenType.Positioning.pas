unit PascalType.Tables.OpenType.Positioning;

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
  PascalType.Tables.OpenType.Coverage,
  PascalType.Tables.OpenType.Lookup;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypePositioningLookupTable
//
//------------------------------------------------------------------------------
// Common base class for GPOS lookup tables
//------------------------------------------------------------------------------
type
  TCustomOpenTypePositioningLookupTable = class;
  TOpenTypePositioningLookupTableClass = class of TCustomOpenTypePositioningLookupTable;

  TCustomOpenTypePositioningLookupTable = class abstract(TCustomOpenTypeLookupTable)
  private
    class var
      FPositioningFormatRegistry: TDictionary<TGlyphPositioning, TOpenTypePositioningLookupTableClass>;
  protected
    function GetPositioningFormat: TGlyphPositioning;
  public
    class destructor Destroy;

    class procedure RegisterPositioningFormat(APositioningFormat: TGlyphPositioning; APositioningTableClass: TOpenTypePositioningLookupTableClass);
    class function GetPositioningLookupTableClass(APositioningFormat: TGlyphPositioning): TOpenTypePositioningLookupTableClass;

    property PositioningFormat: TGlyphPositioning read GetPositioningFormat;
  end;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypePositioningSubTable
//
//------------------------------------------------------------------------------
// GPOS lookup sub tables
//------------------------------------------------------------------------------
type
  TCustomOpenTypePositioningSubTable = class abstract(TCustomOpenTypeLookupSubTableWithCoverage)
  private
  protected
    class function LoadValueRecordFromStream(Stream: TStream; var ValueRecord: TOpenTypeValueRecord; ValueFormat: Word): integer;
    class function SaveValueRecordToStream(Stream: TStream; const ValueRecord: TOpenTypeValueRecord; ValueFormat: Word): integer;
    class function CreateValueFormat(const ValueRecord: TOpenTypeValueRecord; var ValueFormat: Word): integer;
  public
  end;

  TOpenTypePositioningSubTableClass = class of TCustomOpenTypePositioningSubTable;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypePositioningLookupTable
//
//------------------------------------------------------------------------------
class destructor TCustomOpenTypePositioningLookupTable.Destroy;
begin
  FreeAndNil(FPositioningFormatRegistry);
end;

function TCustomOpenTypePositioningLookupTable.GetPositioningFormat: TGlyphPositioning;
begin
  Result := TGlyphPositioning(LookupType);
end;


class function TCustomOpenTypePositioningLookupTable.GetPositioningLookupTableClass(APositioningFormat: TGlyphPositioning): TOpenTypePositioningLookupTableClass;
begin
  if (FPositioningFormatRegistry = nil) or (not FPositioningFormatRegistry.TryGetValue(APositioningFormat, Result)) then
    Result := nil;
end;

class procedure TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(APositioningFormat: TGlyphPositioning;
  APositioningTableClass: TOpenTypePositioningLookupTableClass);
begin
  if (FPositioningFormatRegistry = nil) then
    FPositioningFormatRegistry := TDictionary<TGlyphPositioning, TOpenTypePositioningLookupTableClass>.Create;

  FPositioningFormatRegistry.AddOrSetValue(APositioningFormat, APositioningTableClass);
end;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypePositioningSubTable
//
//------------------------------------------------------------------------------
class function TCustomOpenTypePositioningSubTable.CreateValueFormat(const ValueRecord: TOpenTypeValueRecord; var ValueFormat: Word): integer;
var
  pValue: PWord;
  Mask: Word;
begin
  Result := 0;
  ValueFormat := 0;
  Mask := $0001;
  pValue := PWord(@ValueRecord);
  while (Mask and VALUEFORMAT_Reserved = 0) do
  begin
    if (pValue^ <> 0) then
    begin
      ValueFormat := ValueFormat or Mask;
      Inc(Result, SizeOf(Word));
    end;

    Mask := Mask shl 1;
    Inc(pValue);
  end;
end;

class function TCustomOpenTypePositioningSubTable.LoadValueRecordFromStream(Stream: TStream; var ValueRecord: TOpenTypeValueRecord;
  ValueFormat: Word): integer;
var
  pValue: PWord;
begin
  ValueRecord := Default(TOpenTypeValueRecord);
  ValueFormat := ValueFormat and (not VALUEFORMAT_Reserved);

  Result := 0;
  pValue := PWord(@ValueRecord);
  while (ValueFormat <> 0) do
  begin
    if (ValueFormat and $0001 <> 0) then
    begin
      pValue^ := ReadSwappedWord(Stream);
      Inc(Result, SizeOf(Word));
    end;

    ValueFormat := ValueFormat shr 1;
    Inc(pValue);
  end;
end;

class function TCustomOpenTypePositioningSubTable.SaveValueRecordToStream(Stream: TStream; const ValueRecord: TOpenTypeValueRecord;
  ValueFormat: Word): integer;
var
  pValue: PWord;
begin
  Result := 0;
  ValueFormat := ValueFormat and (not VALUEFORMAT_Reserved);
  pValue := PWord(@ValueRecord);
  while (ValueFormat <> 0) do
  begin
    if (ValueFormat and $0001 <> 0) then
    begin
      WriteSwappedWord(Stream, pValue^);
      Inc(Result, SizeOf(Word));
    end;

    ValueFormat := ValueFormat shr 1;
    Inc(pValue);
  end;
end;

//------------------------------------------------------------------------------

end.
