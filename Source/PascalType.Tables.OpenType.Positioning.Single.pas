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
  Classes,
  PascalType.Classes,
  PascalType.Types,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Common.ValueRecord,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Positioning;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableSingle
//
//------------------------------------------------------------------------------
// Lookup Type 1: Single Adjustment Positioning Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#lookuptype-1-single-substitution-subtable
//------------------------------------------------------------------------------
type
  TOpenTypePositioningLookupTableSingle = class(TCustomOpenTypePositioningLookupTable)
  public type
    TGlyphSinglePositioning = (
      gppInvalid        = 0,
      gppSingle         = 1,
      gppList           = 2
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypePositioningSubTableSingle
//
//------------------------------------------------------------------------------
type
  TCustomOpenTypePositioningSubTableSingle = class(TCustomOpenTypePositioningSubTable)
  private
  protected
    function DoApply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ACoverageIndex: integer): boolean; virtual; abstract;
  public
    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableSingleSingle
//
//------------------------------------------------------------------------------
// Single Adjustment Positioning Format 1: Single Positioning Value
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#single-adjustment-positioning-format-1-single-positioning-value
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableSingleSingle = class(TCustomOpenTypePositioningSubTableSingle)
  private
    FValueRecord: TOpenTypeValueRecord;
  protected
    function DoApply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ACoverageIndex: integer): boolean; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property ValueRecord: TOpenTypeValueRecord read FValueRecord write FValueRecord;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableSingleList
//
//------------------------------------------------------------------------------
// Single Adjustment Positioning Format 2: Array of Positioning Values
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#single-adjustment-positioning-format-2-array-of-positioning-values
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableSingleList = class(TCustomOpenTypePositioningSubTableSingle)
  private type
    TOpenTypeValueRecords = array of TOpenTypeValueRecord;
  private
    FValueRecords: TOpenTypeValueRecords;
  protected
    function DoApply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ACoverageIndex: integer): boolean; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property ValueRecords: TOpenTypeValueRecords read FValueRecords write FValueRecords;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableSingle
//
//------------------------------------------------------------------------------
function TOpenTypePositioningLookupTableSingle.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphSinglePositioning(ASubFormat) of

    gppSingle:
      Result := TOpenTypePositioningSubTableSingleSingle;

    gppList:
      Result := TOpenTypePositioningSubTableSingleList;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypePositioningSubTableSingle
//
//------------------------------------------------------------------------------
function TCustomOpenTypePositioningSubTableSingle.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  CoverageIndex: integer;
begin
  CoverageIndex := CoverageTable.IndexOfGlyph(AGlyphIterator.Glyph.GlyphID);

  if (CoverageIndex <> -1) then
    Result := DoApply(AGlyphIterator, CoverageIndex)
  else
    Result := False;
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

function TOpenTypePositioningSubTableSingleSingle.DoApply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ACoverageIndex: integer): boolean;
begin
  AGlyphIterator.Glyph.ApplyPositioning(FValueRecord);
{$ifdef ApplyIncrements}
  AGlyphIterator.Next;
{$endif ApplyIncrements}
  Result := True;
end;

procedure TOpenTypePositioningSubTableSingleSingle.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  ValueFormat: Word;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  ValueFormat := BigEndianValue.ReadWord(Stream);

  FValueRecord.LoadFromStream(Stream, ValueFormat);
end;

procedure TOpenTypePositioningSubTableSingleSingle.SaveToStream(Stream: TStream);
var
  ValueFormat: Word;
begin
  inherited;

  FValueRecord.BuildValueFormat(ValueFormat);
  BigEndianValue.WriteWord(Stream, ValueFormat);

  FValueRecord.SaveToStream(Stream, ValueFormat);
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

function TOpenTypePositioningSubTableSingleList.DoApply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ACoverageIndex: integer): boolean;
begin
  AGlyphIterator.Glyph.ApplyPositioning(FValueRecords[ACoverageIndex]);
{$ifdef ApplyIncrements}
  AGlyphIterator.Next;
{$endif ApplyIncrements}
  Result := True;
end;

procedure TOpenTypePositioningSubTableSingleList.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  ValueFormat: Word;
  i: integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2 * SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  ValueFormat := BigEndianValue.ReadWord(Stream);

  SetLength(FValueRecords, BigEndianValue.ReadWord(Stream));

  for i := 0 to High(FValueRecords) do
    FValueRecords[i].LoadFromStream(Stream, ValueFormat);
end;

procedure TOpenTypePositioningSubTableSingleList.SaveToStream(Stream: TStream);
var
  ValueFormat: Word;
  i: integer;
begin
  inherited;

  if (Length(FValueRecords) > 0) then
    FValueRecords[0].BuildValueFormat(ValueFormat)
  else
    ValueFormat := 0;

  BigEndianValue.WriteWord(Stream, ValueFormat);

  BigEndianValue.WriteWord(Stream, Length(FValueRecords));

  for i := 0 to High(FValueRecords) do
    FValueRecords[i].SaveToStream(Stream, ValueFormat);
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpSingleAdjustment, TOpenTypePositioningLookupTableSingle);
end.

