unit PascalType.Tables.OpenType.LanguageSystem;

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
  PascalType.Tables.OpenType;

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLanguageSystemTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#language-system-table
//------------------------------------------------------------------------------
type
  TCustomOpenTypeLanguageSystemTable = class abstract(TCustomOpenTypeNamedTable)
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property LookupOrder: Word read FLookupOrder write SetLookupOrder;
    property RequiredFeatureIndex: Word read FReqFeatureIndex write SetReqFeatureIndex;
    property FeatureIndexCount: Integer read GetFeatureIndexCount;
    property FeatureIndex[Index: Integer]: Word read GetFeatureIndex;
  end;

  TOpenTypeLanguageSystemTableClass = class of TCustomOpenTypeLanguageSystemTable;


//------------------------------------------------------------------------------
//
//              TOpenTypeDefaultLanguageSystemTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeDefaultLanguageSystemTable = class(TCustomOpenTypeLanguageSystemTable)
  protected
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;
  end;


//------------------------------------------------------------------------------
//
//              Language system
//
//------------------------------------------------------------------------------
const
  // https://learn.microsoft.com/en-us/typography/opentype/spec/languagetags
  // Note: The tags 'dflt' and 'DFLT', as language system tags, are permanently
  // reserved and are not used in OpenType fonts.
  // An OpenType font should never include language system records with the
  // 'dflt' or 'DFLT' tag.
  OpenTypeDefaultLanguageSystem: TTableType = (AsAnsiChar: 'dflt');

procedure RegisterLanguageSystem(LanguageSystemClass: TOpenTypeLanguageSystemTableClass);
procedure RegisterLanguageSystems(LanguageSystemClasses: array of TOpenTypeLanguageSystemTableClass);
function FindLanguageSystemByType(TableType: TTableType): TOpenTypeLanguageSystemTableClass;

var
  GLanguageSystemClasses : array of TOpenTypeLanguageSystemTableClass;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.ResourceStrings;

//------------------------------------------------------------------------------
//
//              Language system
//
//------------------------------------------------------------------------------
function IsLanguageSystemClassRegistered(LanguageSystemClass: TOpenTypeLanguageSystemTableClass): Boolean;
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

procedure RegisterLanguageSystem(LanguageSystemClass: TOpenTypeLanguageSystemTableClass);
begin
  Assert(IsLanguageSystemClassRegistered(LanguageSystemClass) = False);
  SetLength(GLanguageSystemClasses, Length(GLanguageSystemClasses) + 1);
  GLanguageSystemClasses[High(GLanguageSystemClasses)] := LanguageSystemClass;
end;

procedure RegisterLanguageSystems(LanguageSystemClasses: array of TOpenTypeLanguageSystemTableClass);
var
  LanguageSystemIndex: Integer;
begin
  for LanguageSystemIndex := 0 to High(LanguageSystemClasses) do
    RegisterLanguageSystem(LanguageSystemClasses[LanguageSystemIndex]);
end;

function FindLanguageSystemByType(TableType: TTableType): TOpenTypeLanguageSystemTableClass;
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


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeLanguageSystemTable
//
//------------------------------------------------------------------------------
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

procedure TCustomOpenTypeLanguageSystemTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  FeatureIndex: Integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read default language system
  FLookupOrder := BigEndianValue.ReadWord(Stream);

  // read index of a feature required for this language system
  FReqFeatureIndex := BigEndianValue.ReadWord(Stream);

  // read default language system
  SetLength(FFeatureIndices, BigEndianValue.ReadWord(Stream));

  // read default language system
  for FeatureIndex := 0 to High(FFeatureIndices) do
    FFeatureIndices[FeatureIndex] := BigEndianValue.ReadWord(Stream);
end;

procedure TCustomOpenTypeLanguageSystemTable.SaveToStream(Stream: TStream);
var
  FeatureIndex: Integer;
begin
  inherited;

  // write default language system
  BigEndianValue.WriteWord(Stream, FLookupOrder);

  // write index of a feature required for this language system
  BigEndianValue.WriteWord(Stream, FReqFeatureIndex);

  // write default language system
  BigEndianValue.WriteWord(Stream, Length(FFeatureIndices));

  // write default language systems
  for FeatureIndex := 0 to High(FFeatureIndices) do
    BigEndianValue.WriteWord(Stream, FFeatureIndices[FeatureIndex]);
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


//------------------------------------------------------------------------------
//
//              TOpenTypeDefaultLanguageSystemTable
//
//------------------------------------------------------------------------------
class function TOpenTypeDefaultLanguageSystemTable.GetDisplayName: string;
begin
  Result := 'Default';
end;

class function TOpenTypeDefaultLanguageSystemTable.GetTableType: TTableType;
begin
  Result := OpenTypeDefaultLanguageSystem; // Was: 'DFLT'
end;

//------------------------------------------------------------------------------

end.
