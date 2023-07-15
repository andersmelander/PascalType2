unit PascalType.Tables.OpenType.Substitution.Multiple;

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
  PT_Classes,
  PT_Types,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Substitution;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionLookupTableMultiple
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#MS
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionLookupTableMultiple = class(TCustomOpenTypeSubstitutionLookupTable)
  public type
    TGlyphMultipleSubstitution = (
      gmsInvalid        = 0,
      gmsList           = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableMultipleList
//
//------------------------------------------------------------------------------
// Substitution by multiple output glyphs
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#21-multiple-substitution-format-1
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableMultipleList = class(TCustomOpenTypeSubstitutionSubTable)
  private type
    TGlyphSequences = array of TGlyphString;
  private
    FSequenceList: TGlyphSequences;
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SubstituteSequenceList: TGlyphSequences read FSequenceList;
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
//              TOpenTypeSubstitutionLookupTableMultiple
//
//------------------------------------------------------------------------------
function TOpenTypeSubstitutionLookupTableMultiple.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphMultipleSubstitution(ASubFormat) of

    gmsList:
      Result := TOpenTypeSubstitutionSubTableMultipleList;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableMultipleList
//
//------------------------------------------------------------------------------
procedure TOpenTypeSubstitutionSubTableMultipleList.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableMultipleList then
    FSequenceList := TOpenTypeSubstitutionSubTableMultipleList(Source).SubstituteSequenceList;
end;

procedure TOpenTypeSubstitutionSubTableMultipleList.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  i, j: integer;
  SequenceOffsets: array of Word;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  SetLength(SequenceOffsets, BigEndianValue.ReadWord(Stream));
  for i := 0 to High(SequenceOffsets) do
    SequenceOffsets[i] := BigEndianValue.ReadWord(Stream);

  SetLength(FSequenceList, Length(SequenceOffsets));
  for i := 0 to High(FSequenceList) do
  begin
    Stream.Position := StartPos + SequenceOffsets[i];

    SetLength(FSequenceList[i], BigEndianValue.ReadWord(Stream));

    for j := 0 to High(FSequenceList[i]) do
      FSequenceList[i][j] := BigEndianValue.ReadWord(Stream);
  end;
end;

procedure TOpenTypeSubstitutionSubTableMultipleList.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
  i, j: integer;
  Size: Cardinal;
  SequenceListPos: Int64;
  SavePos: Int64;
  SequenceOffsets: array of Word;
begin
  StartPos := Stream.Position;

  inherited;

  BigEndianValue.WriteWord(Stream, Length(FSequenceList));

  SequenceListPos := Stream.Position;
  Size := 0;
  for i := 0 to High(FSequenceList) do
    Inc(Size, SizeOf(Word) + Length(FSequenceList[i]) * SizeOf(Word));
  // Make room for offset table
  Stream.Seek(Size, soFromCurrent);

  SetLength(SequenceOffsets, Length(FSequenceList));

  for i := 0 to High(FSequenceList) do
  begin
    SequenceOffsets[i] := Stream.Position - StartPos;

    BigEndianValue.WriteWord(Stream, Length(FSequenceList[i]));
    for j := 0 to High(FSequenceList[i]) do
      BigEndianValue.WriteWord(Stream, FSequenceList[i][j]);
  end;

  // Save offset table
  SavePos := Stream.Position;
  Stream.Position := SequenceListPos;

  BigEndianValue.WriteWord(Stream, Length(SequenceOffsets));
  for i := 0 to High(FSequenceList) do
    BigEndianValue.WriteWord(Stream, SequenceOffsets[i]);

  Stream.Position := SavePos;
end;

function TOpenTypeSubstitutionSubTableMultipleList.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  SubstitutionIndex: integer;
  Sequence: TGlyphString;
  Glyph: TPascalTypeGlyph;
  i: integer;
begin
  // The coverage table just tells us if the substitution applies.
  SubstitutionIndex := CoverageTable.IndexOfGlyph(AGlyphIterator.Glyph.GlyphID);

  if (SubstitutionIndex = -1) then
    Exit(False);

  // Get the replacement sequence
  Sequence := FSequenceList[SubstitutionIndex];

  if (Length(Sequence) > 0) then
  begin

    // First entry in glyph string is reused
    AGlyphIterator.Glyph.GlyphID := Sequence[0];
    AGlyphIterator.Glyph.LigatureComponent := 0;

    // Remaining are inserted
    for i := 1 to High(Sequence) do
    begin
      Glyph := AGlyphIterator.GlyphString.CreateGlyph;
      Glyph.GlyphID := Sequence[i];
      Glyph.Features := AGlyphIterator.Glyph.Features;
      Glyph.Cluster := AGlyphIterator.Glyph.Cluster;
      Glyph.IsLigated := AGlyphIterator.Glyph.IsLigated;
      Glyph.LigatureComponent := i;
      Glyph.IsSubstituted := True;
      Glyph.IsMultiplied := True;

      AGlyphIterator.GlyphString.Insert(AGlyphIterator.Index+i, Glyph);
    end;

  end else
  begin
    // If the sequence length is zero, delete the glyph.
    // The OpenType specs disallow this but it seems Harfbuzz and Uniscribe allow it.
    AGlyphIterator.GlyphString.Delete(AGlyphIterator.Index);
  end;

{$ifdef ApplyIncrements}
  AGlyphIterator.Next(Length(Sequence));
{$endif ApplyIncrements}

  Result := True;
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsMultiple, TOpenTypeSubstitutionLookupTableMultiple);
end.

