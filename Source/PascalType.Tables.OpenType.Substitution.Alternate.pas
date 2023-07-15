unit PascalType.Tables.OpenType.Substitution.Alternate;

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
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Substitution;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionLookupTableAlternate
//
//------------------------------------------------------------------------------
// LookupType 3: Alternate Substitution Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#lookuptype-3-alternate-substitution-subtable
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionLookupTableAlternate = class(TCustomOpenTypeSubstitutionLookupTable)
  public type
    TGlyphAlternateSubstitution = (
      gasInvalid        = 0,
      gasList           = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableAlternateList
//
//------------------------------------------------------------------------------
// 3.1 Alternate Substitution Format 1
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#31-alternate-substitution-format-1
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableAlternateList = class(TCustomOpenTypeSubstitutionSubTable)
  private
    FAlternateGlyphIDs: TGlyphStrings;
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property AlternateGlyphIDs: TGlyphStrings read FAlternateGlyphIDs;
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
//              TOpenTypeSubstitutionLookupTableAlternate
//
//------------------------------------------------------------------------------
function TOpenTypeSubstitutionLookupTableAlternate.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphAlternateSubstitution(ASubFormat) of

    gasList:
      Result := TOpenTypeSubstitutionSubTableAlternateList;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableAlternateList
//
//------------------------------------------------------------------------------
procedure TOpenTypeSubstitutionSubTableAlternateList.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableAlternateList then
    FAlternateGlyphIDs := Copy(TOpenTypeSubstitutionSubTableAlternateList(Source).FAlternateGlyphIDs);
end;

procedure TOpenTypeSubstitutionSubTableAlternateList.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  i, j: integer;
  Offsets: TArray<Word>;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  SetLength(Offsets, BigEndianValue.ReadWord(Stream));
  for i := 0 to High(Offsets) do
    Offsets[i] := BigEndianValue.ReadWord(Stream);

  SetLength(FAlternateGlyphIDs, Length(Offsets));
  for i := 0 to High(Offsets) do
  begin
    Stream.Position := StartPos + Offsets[i];

    SetLength(FAlternateGlyphIDs[i], BigEndianValue.ReadWord(Stream));
    for j := 0 to High(FAlternateGlyphIDs[i]) do
      FAlternateGlyphIDs[i, j] := BigEndianValue.ReadWord(Stream);
  end;
end;

procedure TOpenTypeSubstitutionSubTableAlternateList.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
  OffsetPos: Int64;
  SavePos: Int64;
  i, j: integer;
  Offsets: TArray<Word>;
begin
  StartPos := Stream.Position;

  inherited;

  SetLength(Offsets, Length(FAlternateGlyphIDs));
  BigEndianValue.WriteWord(Stream, Length(Offsets));

  OffsetPos := Stream.Position;
  Stream.Position := Stream.Position + SizeOf(Word)*Length(Offsets);

  for i := 0 to High(FAlternateGlyphIDs) do
  begin
    Offsets[i] := Stream.Position - StartPos;

    BigEndianValue.WriteWord(Stream, Length(FAlternateGlyphIDs[i]));
    for j := 0 to High(FAlternateGlyphIDs[i]) do
      BigEndianValue.WriteWord(Stream, FAlternateGlyphIDs[i, j]);
  end;

  SavePos := Stream.Position;
  Stream.Position := OffsetPos;
  for i := 0 to High(Offsets) do
    BigEndianValue.WriteWord(Stream, Offsets[i]);

  Stream.Position := SavePos;
end;

function TOpenTypeSubstitutionSubTableAlternateList.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  SubstitutionIndex: integer;
  AlternateIndex: integer;
begin
  SubstitutionIndex := CoverageTable.IndexOfGlyph(AGlyphIterator.Glyph.GlyphID);

  if (SubstitutionIndex = -1) or (Length(FAlternateGlyphIDs[SubstitutionIndex]) = 0) then
    Exit(False);

  AlternateIndex := AGlyphIterator.Glyph.AlternateIndex;
  if (AlternateIndex = -1) then
    AlternateIndex := AGlyphIterator.GlyphString.AlternateIndex;

  if (AlternateIndex < 0) or (AlternateIndex > High(FAlternateGlyphIDs[SubstitutionIndex])) then
    AlternateIndex := 0;

  AGlyphIterator.Glyph.GlyphID := FAlternateGlyphIDs[SubstitutionIndex, AlternateIndex];
{$ifdef ApplyIncrements}
  AGlyphIterator.Next;
{$endif ApplyIncrements}
  Result := True;
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsAlternate, TOpenTypeSubstitutionLookupTableAlternate);
end.

