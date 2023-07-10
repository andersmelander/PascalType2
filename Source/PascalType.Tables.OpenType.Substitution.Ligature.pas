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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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

procedure TOpenTypeSubstitutionSubTableLigatureList.LoadFromStream(Stream: TStream; Size: Cardinal);
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

      // First component isn't used
      Ligature.Components[0] := 0;

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

  procedure UpdateLigatureState(Glyph: TPascalTypeGlyph; const MatchedIndices: TArray<integer>);
  var
    IsBaseLigature: boolean;
    IsMarkLigature: boolean;
    IsLigature: boolean;
    i: integer;
    NewLigatureID: integer;
    LastLigatureID: integer;
    LastComponentCount: integer;
    ComponentCount: integer;
    MatchIndex: integer;
    GlyphLigatureComponent: integer;
    LigatureComponent: integer;
  begin
    // Note: This is based on the corresponding code in Harfbuzz. The code in
    // FontKit is a bit different, and slightly less complex, but buggy.


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

    IsBaseLigature := AGlyphIterator.GlyphString[MatchedIndices[0]].IsMark;
    IsMarkLigature := True;
    for MatchIndex in MatchedIndices do
    begin
      IsMarkLigature := AGlyphIterator.GlyphString[MatchIndex].IsMark;
      if (not IsMarkLigature) then
      begin
        IsBaseLigature := False;
        break;
      end;
    end;

    IsLigature := (not IsBaseLigature) and (not IsMarkLigature);

    if (IsLigature) then
      NewLigatureID := AGlyphIterator.GlyphString.GetNextLigatureID
    else
      NewLigatureID := -1;

    LastLigatureID := Glyph.LigatureID;
    LastComponentCount := Length(Glyph.CodePoints);
    ComponentCount := LastComponentCount;

    if (IsLigature) then
      Glyph.LigatureID := NewLigatureID;

    // Note: The following code assumes that we are using an iterator that skips certain glyphs
    // (which is what Harfbuzz and FontKit does). I'm not doing that (yet) so the operation
    // is pretty pointless. However, I've chosed to include the code in case we later introduce
    // an iterator.
    // Hurray! We're now using a skipping iterator.

    // Set LigatureID and LigatureComponent on glyphs that were skipped in the matched sequence.
    // This allows GPOS to attach marks to the correct ligature components.
    var Iterator := AGlyphIterator.Clone;
    Iterator.Step;

    for i := 1 to High(MatchedIndices) do
    begin
      MatchIndex := MatchedIndices[i];

      while (Iterator.Index < MatchIndex) and (not Iterator.EOF) do
      begin
        // Don't assign new ligature components for mark ligatures (see above)
        if (IsLigature) then
        begin
          GlyphLigatureComponent := Iterator.Glyph.LigatureComponent;
          if (GlyphLigatureComponent = -1) then
            GlyphLigatureComponent := LastComponentCount;

          LigatureComponent := ComponentCount - LastComponentCount + Min(GlyphLigatureComponent, LastComponentCount);

          Iterator.Glyph.LigatureID := NewLigatureID;
          Iterator.Glyph.LigatureComponent := LigatureComponent;
        end;

        Iterator.Next;
      end;

      LastLigatureID := Iterator.Glyph.LigatureID;
      LastComponentCount := Length(Iterator.Glyph.CodePoints);
      ComponentCount := ComponentCount + LastComponentCount;

      Iterator.Step; // skip base glyph
    end;

    // Adjust ligature components for any marks following
    if (LastLigatureID <> -1) and (not IsMarkLigature) then
      while (not Iterator.EOF) do
      begin
        if (Iterator.Glyph.LigatureID <> LastLigatureID) then
          break;

        GlyphLigatureComponent := Iterator.Glyph.LigatureComponent;
        if (GlyphLigatureComponent = -1) then
          break;

        LigatureComponent := ComponentCount - LastComponentCount + Min(GlyphLigatureComponent, LastComponentCount);
        Iterator.Glyph.LigatureComponent := LigatureComponent;

        Iterator.Step;
      end;
  end;

var
  SubstitutionIndex: integer;
  Glyph: TPascalTypeGlyph;
  MatchedGlyph: TPascalTypeGlyph;
  i, j: integer;
  Match: boolean;
  LastSameStartCharIndex: integer;
  CodePoints: TPascalTypeCodePoints;
  Count: integer;
  Iterator: TPascalTypeGlyphGlyphIterator;
  MatchedIndices: TArray<integer>;
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
    SetLength(MatchedIndices, Length(FLigatures[i].Components));

    // We have already matched the first character via the coverage table so skip that
    MatchedIndices[0] := Iterator.Index;
    Iterator.Next;

    j := 1;
    while (not Iterator.EOF) and (j <= High(FLigatures[i].Components)) do
    begin
      if (Iterator.Glyph.GlyphID <> FLigatures[i].Components[j]) then
      begin
        Match := False;
        break;
      end else
      begin
        MatchedIndices[j] := Iterator.Index;
        Iterator.Next;
      end;
      Inc(j);
    end;

    if (Match) then
    begin
      // We have a match. Replace the source character with the ligature string

      Glyph := AGlyphIterator.Glyph;

      // Save a list of the codepoints we're replacing
      Count := 0;
      SetLength(CodePoints, Length(MatchedIndices));
      for j := 0 to High(MatchedIndices) do
      begin
        MatchedGlyph := AGlyphIterator.GlyphString[MatchedIndices[j]];

        // CodePoints might be empty if we are substituting an already substituted glyph.
        // See: TOpenTypeSubstitutionSubTableMultipleList.Apply
        if (Length(MatchedGlyph.CodePoints) > 0) then
        begin
          if (Count + Length(MatchedGlyph.CodePoints) > Length(CodePoints)) then
            SetLength(CodePoints, Count + Length(MatchedGlyph.CodePoints) * 2); // * 2 = allocate more than we need in order to reduce reallocations

          Move(MatchedGlyph.CodePoints[0], CodePoints[Count],
            Length(MatchedGlyph.CodePoints) * SizeOf(TPascalTypeCodePoint));

          Inc(Count, Length(MatchedGlyph.CodePoints));
        end;
      end;
      SetLength(CodePoints, Count);

      Glyph.IsLigated := True;
      Glyph.IsSubstituted := True;

      UpdateLigatureState(Glyph, MatchedIndices);

      // First entry in glyph string is reused...
      Glyph.GlyphID := FLigatures[i].Glyph;
      Glyph.CodePoints := CodePoints;

      // ...Remaining are deleted
      for j := High(MatchedIndices) downto 1 do
        AGlyphIterator.GlyphString.Delete(MatchedIndices[j], 1);

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

