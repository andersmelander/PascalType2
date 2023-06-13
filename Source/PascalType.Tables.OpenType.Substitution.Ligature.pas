unit PascalType.Tables.OpenType.Substitution.Ligature;

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
//              TOpenTypeSubstitutionLookupTableLigature
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#LS
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionLookupTableLigature = class(TCustomOpenTypeSubstitutionLookupTable)
  public type
    TGlyphLigatureSubstitution = (
      glsInvalid        = 0,
      glsList           = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableLigatureList
//
//------------------------------------------------------------------------------
// Ligature Substitution Format 1
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#41-ligature-substitution-format-1
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableLigatureList = class(TCustomOpenTypeSubstitutionSubTable)
  private type
    TGlyphLigature = record
      Glyph: Word;
      Components: TGlyphString;
    end;
    TGlyphLigatures = TList<TGlyphLigature>;
  private
    FLigatures: TGlyphLigatures;
    FLigatureIndex: array of integer;
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property Ligatures: TGlyphLigatures read FLigatures;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  System.Math,
  System.SysUtils,
  PascalType.Unicode,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionLookupTableLigature
//
//------------------------------------------------------------------------------
function TOpenTypeSubstitutionLookupTableLigature.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphLigatureSubstitution(ASubFormat) of

    glsList:
      Result := TOpenTypeSubstitutionSubTableLigatureList;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableLigatureList
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableLigatureList.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FLigatures := TGlyphLigatures.Create;
end;

destructor TOpenTypeSubstitutionSubTableLigatureList.Destroy;
begin
  FLigatures.Free;
  inherited;
end;

procedure TOpenTypeSubstitutionSubTableLigatureList.Assign(Source: TPersistent);
var
  Ligature: TGlyphLigature;
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableLigatureList then
  begin
    FLigatures.Clear;

    for Ligature in TOpenTypeSubstitutionSubTableLigatureList(Source).FLigatures do
      // TGlyphLigature is a record; Add() makes a copy.
      FLigatures.Add(Ligature);
  end;
end;

procedure TOpenTypeSubstitutionSubTableLigatureList.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  SavePos: Int64;
  i, j, k: integer;
  OffsetListOffsets: array of Word;
  LigatureOffsets: array of Word;
  Ligature: TGlyphLigature;
begin
  FLigatures.Clear;

  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Read list of offsets to list of offsets to ligatures
  SetLength(OffsetListOffsets, BigEndianValueReader.ReadWord(Stream));
  for i := 0 to High(OffsetListOffsets) do
    OffsetListOffsets[i] := BigEndianValueReader.ReadWord(Stream);

  SavePos := Stream.Position;

  SetLength(FLigatureIndex, Length(OffsetListOffsets));
  for i := 0 to High(OffsetListOffsets) do
  begin

    Stream.Position := StartPos + OffsetListOffsets[i];

    FLigatureIndex[i] := FLigatures.Count; // Save index to first ligature with this start component

    // Read list of offsets to ligatures,
    // Offsets are from beginning of ligatureSet table
    SetLength(LigatureOffsets, BigEndianValueReader.ReadWord(Stream));
    for j := 0 to High(LigatureOffsets) do
      LigatureOffsets[j] := BigEndianValueReader.ReadWord(Stream);

    // Read list of ligature definitions
    for j := 0 to High(LigatureOffsets) do
    begin
      Stream.Position := StartPos + OffsetListOffsets[i] + LigatureOffsets[j];

      // Read ligature glyph
      Ligature.Glyph := BigEndianValueReader.ReadWord(Stream);

      SetLength(Ligature.Components, BigEndianValueReader.ReadWord(Stream));

      if (Length(Ligature.Components) = 0) then
        // This shouldn't happen
        continue;

      // Set first component from coverage table
      Ligature.Components[0] := CoverageTable.GlyphByIndex(i);

      // Read remaining from ligature component list
      for k := 1 to High(Ligature.Components) do
        Ligature.Components[k] := BigEndianValueReader.ReadWord(Stream);

      FLigatures.Add(Ligature);
    end;

  end;

  Stream.Position := SavePos;
end;

procedure TOpenTypeSubstitutionSubTableLigatureList.SaveToStream(Stream: TStream);
begin
  // TODO
end;

function TOpenTypeSubstitutionSubTableLigatureList.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;

  procedure UpdateLigatureState(Glyph: TPascalTypeGlyph);
  var
    IsMarkLigature: boolean;
    i: integer;
    LastLigatureID: integer;
    LastComponentCount: integer;
    ComponentCount: integer;
    Index: integer;
    MatchIndex: integer;
    GlyphLigatureComponent: integer;
    LigatureComponent: integer;
  begin
    // From Harfbuzz:
    // - If it *is* a mark ligature, we don't allocate a new ligature id, and leave
    //   the ligature to keep its old ligature id.  This will allow it to attach to
    //   a base ligature in GPOS.  Eg. if the sequence is: LAM,LAM,SHADDA,FATHA,HEH,
    //   and LAM,LAM,HEH for a ligature, they will leave SHADDA and FATHA with a
    //   ligature id and component value of 2.  Then if SHADDA,FATHA form a ligature
    //   later, we don't want them to lose their ligature id/component, otherwise
    //   GPOS will fail to correctly position the mark ligature on top of the
    //   LAM,LAM,HEH ligature. See https://bugzilla.gnome.org/show_bug.cgi?id=676343
    //
    // - If a ligature is formed of components, some of which are also ligatures
    //   themselves, and those ligature components had marks attached to *their*
    //   components, we have to attach the marks to the new ligature component
    //   positions!  Now *that*'s tricky!  And these marks may be following the
    //   last component of the whole sequence, so we should loop forward looking
    //   for them and update them.
    //
    //   Eg. the sequence is LAM,LAM,SHADDA,FATHA,HEH, and the font first forms a
    //   'calt' ligature of LAM,HEH, leaving the SHADDA and FATHA with a ligature
    //   id and component == 1.  Now, during 'liga', the LAM and the LAM-HEH ligature
    //   form a LAM-LAM-HEH ligature.  We need to reassign the SHADDA and FATHA to
    //   the new ligature with a component value of 2.
    //
    //   This in fact happened to a font...  See https://bugzilla.gnome.org/show_bug.cgi?id=437633

    IsMarkLigature := Glyph.IsMark;
    i := 1;
    while (IsMarkLigature) and (i < Length(Glyph.CodePoints)) do
    begin
      IsMarkLigature := AGlyphIterator.GlyphString[AGlyphIterator.Index + i].IsMark;
      Inc(i);
    end;

    if (IsMarkLigature) then
      Glyph.LigatureID := -1
    else
      Glyph.LigatureID := AGlyphIterator.GlyphString.GetNextLigatureID;

    LastLigatureID := Glyph.LigatureID;
    LastComponentCount := Length(Glyph.CodePoints);
    ComponentCount := LastComponentCount;
    Index := AGlyphIterator.Index + 1;

    // Note: The following code assumes that we are using an iterator that skips certain glyphs
    // (which is what Harfbuzz and FontKit does). I'm not doing that (yet) so the operation
    // is pretty pointless. However, I've chosed to include the code in case we later introduce
    // an iterator.
    // Hurray! We're now using a skipping iterator.

    // Set ligatureID and LigatureComponent on glyphs that were skipped in the matched sequence.
    // This allows GPOS to attach marks to the correct ligature components.
    for MatchIndex := AGlyphIterator.Index to AGlyphIterator.Index+Length(Glyph.CodePoints)-1 do
    begin
      // Don't assign new ligature components for mark ligatures (see above)
      if (IsMarkLigature) then
        Index := MatchIndex
      else
      begin
        while (Index < MatchIndex) do
        begin
          GlyphLigatureComponent := Max(1, AGlyphIterator.GlyphString[Index].LigatureComponent);
          LigatureComponent := ComponentCount - LastComponentCount + Min(GlyphLigatureComponent, LastComponentCount);
          AGlyphIterator.GlyphString[Index].LigatureID := Glyph.LigatureID;
          AGlyphIterator.GlyphString[Index].LigatureComponent := LigatureComponent;
          Inc(Index);
        end;
      end;

      LastLigatureID := AGlyphIterator.GlyphString[Index].LigatureID;
      LastComponentCount := Length(AGlyphIterator.GlyphString[Index].CodePoints);
      ComponentCount := ComponentCount + LastComponentCount;
      Inc(Index); // skip base glyph
    end;

    // Adjust ligature components for any marks following
    if (LastLigatureID <> -1) and (not IsMarkLigature) then
      for i := Index to AGlyphIterator.GlyphString.Count-1 do
      begin
        if (AGlyphIterator.GlyphString[i].LigatureID <> LastLigatureID) then
          break;

        GlyphLigatureComponent := Max(1, AGlyphIterator.GlyphString[i].LigatureComponent);
        LigatureComponent := ComponentCount - LastComponentCount + Min(GlyphLigatureComponent, LastComponentCount);
        AGlyphIterator.GlyphString[i].LigatureComponent := LigatureComponent;
      end;
  end;

var
  SubstitutionIndex: integer;
  Glyph: TPascalTypeGlyph;
  i, j: integer;
  Match: boolean;
  LastSameStartCharIndex: integer;
  CodePoints: TPascalTypeCodePoints;
  Iterator: TPascalTypeGlyphGlyphIterator;
begin
  // Test with :
  // - Segoe Script: ffl
  // - Arabic typesetting: ff
  // - Palatino Linotype Italic: ff

  // The coverage table contains the index of the first character of the ligature component string.
  SubstitutionIndex := CoverageTable.IndexOfGlyph(AGlyphIterator.Glyph.GlyphID);

  if (SubstitutionIndex = -1) then
    Exit(False);

  // Ligature strings are grouped by starting character so all members of a group
  // has the same start character. The FLigatureIndex[] array contains the index
  // of the first entry in the group.

  // We found the index of the first string in the group above via the coverage table.
  // The index of the last ligature string is either...
  if (SubstitutionIndex < High(FLigatureIndex)) then
    // ... the index right before the first in the next group or...
    LastSameStartCharIndex := FLigatureIndex[SubstitutionIndex+1]-1
  else
    // ... the last possible index if there are no next group.
    LastSameStartCharIndex := FLigatures.Count-1;

  // For each ligature string...
  for i := FLigatureIndex[SubstitutionIndex] to LastSameStartCharIndex do
  begin
    // If the end of this ligature string is past our source string then there can be no match
    if (AGlyphIterator.Index + Length(FLigatures[i].Components) > AGlyphIterator.GlyphString.Count) then
      continue;

    // Compare each character in the ligature string to the source string
    Match := True;
    Iterator := AGlyphIterator.Clone; // It's too costly to repeatedly call Peek with increasing increment. Clone is cheaper.
    for j := 0 to High(FLigatures[i].Components) do
      if (Iterator.Glyph.GlyphID <> FLigatures[i].Components[j]) then
      begin
        Match := False;
        break;
      end else
        Iterator.Next;

    if (Match) then
    begin
      // We have a match. Replace the source character with the ligature string

      Glyph := AGlyphIterator.Glyph;

      // Save a list of the codepoints we're replacing
      SetLength(CodePoints, Length(FLigatures[i].Components));
      for j := 0 to High(FLigatures[i].Components) do
        CodePoints[j] := FLigatures[i].Components[j];
      Glyph.CodePoints := CodePoints;

      Glyph.IsLigated := True;
      Glyph.IsSubstituted := True;

      UpdateLigatureState(Glyph);

      // First entry in glyph string is reused...
      Glyph.GlyphID := FLigatures[i].Glyph;

      // ...Remaining are deleted
      AGlyphIterator.GlyphString.Delete(AGlyphIterator.Index+1, Length(FLigatures[i].Components)-1);

      // Advance past the character we just processed.
      // Note that we only advance one position because we have deleted the remaining characters that were processed.
{$ifdef ApplyIncrements}
      AGlyphIterator.Next;
{$endif ApplyIncrements}

      Exit(True);
    end;
  end;

  Result := False;
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsLigature, TOpenTypeSubstitutionLookupTableLigature);
end.

