unit PascalType.Shaper.Script.Hangul;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//      Shaper for Hangul.                                                    //
//                                                                            //
//      Based on the FontKit Hangul shaper (which in turn is probably based   //
//      on the Harfbuzz Hangul shaper.                                        //
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
//  The initial developer of this code is Anders Melander.                    //
//                                                                            //
//  Portions created by Anders Melander are Copyright (C) 2023                //
//  by Anders Melander. All Rights Reserved.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

uses
  PascalType.Types,
  PascalType.Unicode,
  PascalType.GlyphString,
  PascalType.Shaper,
  PascalType.Shaper.Script.Default,
  PascalType.Shaper.Plan,
  PascalType.Shaper.Layout;


//------------------------------------------------------------------------------
//
//              TPascalTypeHangulShaper
//
//------------------------------------------------------------------------------
//
// This is a shaper for the Hangul script, used by the Korean language.
//
// It does the following:
//   - decompose if unsupported by the font:
//     <LV>   -> <L,V>
//     <LVT>  -> <L,V,T>
//     <LV,T> -> <L,V,T>
//
//   - compose if supported by the font:
//     <L,V>   -> <LV>
//     <L,V,T> -> <LVT>
//     <LV,T>  -> <LVT>
//
//   - reorder tone marks (S is any valid syllable):
//     <S, M> -> <M, S>
//
//   - apply ljmo, vjmo, and tjmo OpenType features to decomposed Jamo sequences.
//
// This logic is based on the following documents:
//   - http://www.microsoft.com/typography/OpenTypeDev/hangul/intro.htm
//   - http://ktug.org/~nomos/harfbuzz-hangul/hangulshaper.pdf
//
//------------------------------------------------------------------------------
type
  TPascalTypeHangulShaper = class(TPascalTypeDefaultShaper)
  private
    function Decompose(var AGlyphs: TPascalTypeGlyphString; Index: integer): integer;
    function Compose(var AGlyphs: TPascalTypeGlyphString; Index: integer): integer;
    function InsertDottedCircle(var AGlyphs: TPascalTypeGlyphString; Index: integer): integer;
    procedure ReorderToneMark(var AGlyphs: TPascalTypeGlyphString; Index: integer);
  protected
    function ZeroMarkWidths: TZeroMarkWidths; override;
    function NeedUnicodeComposition: boolean; override;
    procedure PlanFeatures(AStage: TPascalTypeShapingPlanStage); override;
    procedure AssignLocalFeatures(var AGlyphs: TPascalTypeGlyphString); override;
  end;


//------------------------------------------------------------------------------
//
//              Hangul feature plans
//
//------------------------------------------------------------------------------
const
  HangulFeatures: TTableNames = [
    'ljmo',
    'vjmo',
    'tjmo'
  ];


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  System.Classes,
  PascalType.Shaper.Layout.OpenType;


// Character categories
type
  THangulCategory = (
    hcX,        // Other character
    hcL,        // Leading consonant
    hcV,        // Medial vowel
    hcT,        // Trailing consonant
    hcLV,       // Composed <LV> syllable
    hcLVT,      // Composed <LVT> syllable
    hcM         // Tone mark
  );

// This function classifies a character using the above categories.
function GetHangulCategory(ACodePoint: TPascalTypeCodePoint): THangulCategory;
begin
  if (Hangul.IsL(ACodePoint)) then
    Result := hcL
  else
  if (Hangul.IsV(ACodePoint)) then
    Result := hcV
  else
  if (Hangul.IsT(ACodePoint)) then
    Result := hcT
  else
  if (Hangul.IsHangulLV(ACodePoint)) then
    Result := hcLV
  else
  if (Hangul.IsHangul(ACodePoint)) then
    Result := hcLVT
  else
  if (Hangul.IsTone(ACodePoint)) then
    Result := hcM
  else
    Result := hcX;
end;

type
  TState = (sStart, sL, sLV, sLVT);
  // State machine actions
  TStateAction = (saNone, saDecompose, saCompose, saToneMark, saInvalid);

  TStateEntry = record
    Action: TStateAction;
    NextState: TState;
  end;

  TStateEntries = array[THangulCategory] of TStateEntry;
  TStateMachine = array[TState] of TStateEntries;

const
  // A state machine that accepts valid syllables, and applies actions along the way.
  // Ported from FontKit.
  None = #0#0#0#0;
  StateMachine: TStateMachine = (
    //       X                            L                                V                                    T                                    LV                                     LVT                                     M
    // State 0: start state
    ((Action: saNone; NextState: sStart), (Action: saNone; NextState: sL), (Action: saNone; NextState: sStart), (Action: saNone; NextState: sStart), (Action: saDecompose; NextState: sLV), (Action: saDecompose; NextState: sLVT), (Action: saInvalid; NextState: sStart)),

    // State 1: <L>
    ((Action: saNone; NextState: sStart), (Action: saNone; NextState: sL), (Action: saCompose; NextState: sLV), (Action: saNone; NextState: sStart), (Action: saDecompose; NextState: sLV), (Action: saDecompose; NextState: sLVT), (Action: saInvalid; NextState: sStart)),

    // State 2: <L,V> or <LV>
    ((Action: saNone; NextState: sStart), (Action: saNone; NextState: sL), (Action: saNone; NextState: sStart), (Action: saCompose; NextState: sLVT), (Action: saDecompose; NextState: sLV), (Action: saDecompose; NextState: sLVT), (Action: saToneMark; NextState: sStart)),

    // State 3: <L,V,T> or <LVT>
    ((Action: saNone; NextState: sStart), (Action: saNone; NextState: sL), (Action: saNone; NextState: sStart), (Action: saNone; NextState: sStart), (Action: saDecompose; NextState: sLV), (Action: saDecompose; NextState: sLVT), (Action: saToneMark; NextState: sStart))
  );


//------------------------------------------------------------------------------
//
//              TPascalTypeHangulShaper
//
//------------------------------------------------------------------------------
procedure TPascalTypeHangulShaper.PlanFeatures(AStage: TPascalTypeShapingPlanStage);
begin
  AStage.Add(HangulFeatures);
end;

function TPascalTypeHangulShaper.ZeroMarkWidths: TZeroMarkWidths;
begin
  Result := zmwNever;
end;

function TPascalTypeHangulShaper.Decompose(var AGlyphs: TPascalTypeGlyphString; Index: integer): integer;
var
  SIndex, TIndex: Integer;
  LCodePoint, VCodePoint, TCodePoint: TPascalTypeCodePoint;
  Glyph: TPascalTypeGlyph;
  LGlyphID, VGlyphID, TGlyphID: Cardinal;
  Features: TPascalTypeFeatures;
begin
  Result := Index;

  Glyph := AGlyphs[Index];

  // Copied from PascalType.Unicode DecomposeHangul
  SIndex := Glyph.CodePoints[0] - Hangul.HangulSBase;

  LCodePoint := Hangul.JamoLBase + (SIndex div Hangul.JamoNCount);
  VCodePoint := Hangul.JamoVBase + ((SIndex mod Hangul.JamoNCount) div Hangul.JamoTCount);
  TIndex := SIndex mod Hangul.JamoTCount;
  if TIndex <> 0 then
    TCodePoint := Hangul.JamoTBase + TIndex
  else
    TCodePoint := 0;

  // Keep original glyph if font doesn't have the decomposed glyphs
  LGlyphID := Font.GetGlyphByCharacter(LCodePoint);
  if (LGlyphID = 0) then
    exit;
  VGlyphID := Font.GetGlyphByCharacter(VCodePoint);
  if (VGlyphID = 0) then
    exit;
  if (TCodePoint <> 0) then
  begin
    TGlyphID := Font.GetGlyphByCharacter(TCodePoint);
    if (TGlyphID = 0) then
      exit;
  end else
    TGlyphID := 0;

  // Replace the current glyph with decomposed L, V, and T glyphs,
  // and apply the proper OpenType features to each component.
  Features := AGlyphs[Index].Features;
  AGlyphs.Delete(Index);

  Glyph := AGlyphs.CreateGlyph;
  Glyph.GlyphID := LGlyphID;
  Glyph.CodePoints := [LCodePoint];
  Glyph.Features := Features;
  Glyph.Features.Add('ljmo');
  AGlyphs.Insert(Result, Glyph);
  Inc(Result);

  Glyph := AGlyphs.CreateGlyph;
  Glyph.GlyphID := VGlyphID;
  Glyph.CodePoints := [VCodePoint];
  Glyph.Features := Features;
  Glyph.Features.Add('vjmo');
  AGlyphs.Insert(Result, Glyph);
  Inc(Result);

  if (TCodePoint <> 0) then
  begin
    Glyph := AGlyphs.CreateGlyph;
    Glyph.GlyphID := TGlyphID;
    Glyph.CodePoints := [VCodePoint];
    Glyph.Features := Features;
    Glyph.Features.Add('tjmo');
    AGlyphs.Insert(Result, Glyph);
    Inc(Result);
  end;

  Dec(Result); // Offset the +1 that is applied after we return
end;

function TPascalTypeHangulShaper.Compose(var AGlyphs: TPascalTypeGlyphString; Index: integer): integer;
var
  Glyph: TPascalTypeGlyph;
  Category, PrevCategory: THangulCategory;
  PrevCodePoint: TPascalTypeCodePoint;
  LVCodePoint, LCodePoint, VCodePoint, TCodePoint, SCodePoint: TPascalTypeCodePoint;
  LjmoGlyph, VjmoGlyph, TjmoGlyph: TPascalTypeGlyph;
  Features: TPascalTypeFeatures;
  GlyphID: Cardinal;
  Count: integer;
begin
  Assert(Index > 0);

  Result := Index;

  Glyph := AGlyphs[Index];
  Category := GetHangulCategory(Glyph.CodePoints[0]);

  PrevCodePoint := AGlyphs[Index-1].CodePoints[0];
  PrevCategory := GetHangulCategory(PrevCodePoint);

  // Figure out what type of syllable we're dealing with
  if (PrevCategory = hcLV) and (Category = hcT) then
  begin
    // <LV,T>
    LVCodePoint := PrevCodePoint;
    LjmoGlyph := nil;
    VjmoGlyph := nil;
    TjmoGlyph := Glyph;
  end else
  begin

    if (Category = hcV) then
    begin
      // <L,V>
      LjmoGlyph := AGlyphs[Index-1];
      VjmoGlyph := Glyph;
      TjmoGlyph := nil;
    end else
    begin
      // <L,V,T>
      LjmoGlyph := AGlyphs[Index-2];
      VjmoGlyph := AGlyphs[Index-1];
      TjmoGlyph := Glyph;
    end;

    LCodePoint := LjmoGlyph.CodePoints[0];
    VCodePoint := VjmoGlyph.CodePoints[0];

    // Make sure L and V are combining characters
    if (Hangul.IsJamoL(LCodePoint) and Hangul.IsJamoV(VCodePoint)) then
      LVCodePoint := Hangul.HangulSBase + ((LCodePoint - Hangul.JamoLBase) * Hangul.JamoVCount + (VCodePoint - Hangul.JamoVBase)) * Hangul.JamoTCount
    else
      LVCodePoint := 0;

  end;

  if (TjmoGlyph <> nil) then
    TCodePoint := TjmoGlyph.CodePoints[0]
  else
    TCodePoint := Hangul.JamoTBase;

  if (LVCodePoint <> 0) and ((TCodePoint = Hangul.JamoTBase) or Hangul.IsJamoT(TCodePoint)) then
  begin
    SCodePoint := LVCodePoint + (TCodePoint - Hangul.JamoTBase);

    // Replace with a composed glyph if supported by the font,
    // otherwise apply the proper OpenType features to each component.
    GlyphID := Font.GetGlyphByCharacter(SCodePoint);
    if (GlyphID <> 0) then
    begin
      Features := Glyph.Features;
      if (PrevCategory = hcV) then
        Count := 3
      else
        Count := 2;
      // Delete the glyphs we just matched, i.e. backward up to and including the current glyph
      Dec(Index, Count-1);
      AGlyphs.Delete(Index, Count);

      Glyph := AGlyphs.CreateGlyph;
      Glyph.Features := Features;
      Glyph.CodePoints := [SCodePoint];
      Glyph.GlyphID := GlyphID;

      AGlyphs.Insert(Index, Glyph);

      Result := Index - Count + 1;
      exit;
    end;
  end;

  // Didn't compose (either a non-combining component or unsupported by font).
  if (LjmoGlyph <> nil) then
    LjmoGlyph.Features.Add('ljmo');

  if (VjmoGlyph <> nil) then
    VjmoGlyph.Features.Add('vjmo');

  if (TjmoGlyph <> nil) then
    TjmoGlyph.Features.Add('tjmo');

  if (PrevCategory = hcLV) then
  begin
    // Sequence was originally <L,V>, which got combined earlier.
    // Either the T was non-combining, or the LVT glyph wasn't supported.
    // Decompose the glyph again and apply OT features.
    Decompose(AGlyphs, Index - 1);

    Result := Index + 1;
  end;
end;

procedure TPascalTypeHangulShaper.ReorderToneMark(var AGlyphs: TPascalTypeGlyphString; Index: integer);

  function GetLength(CodePoint: TPascalTypeCodePoint): integer;
  begin
    case GetHangulCategory(CodePoint) of
      hcLV, hcLVT:
        Result := 1;

      hcV:
        Result := 2;

      hcT:
        Result := 3;
    else
      Result := 0;
    end;
  end;

var
  GlyphIndex: integer;
  PrevCodePoint: TPascalTypeCodePoint;
  Count: integer;
begin
  Assert(Index > 0);

  // Move tone mark to the beginning of the previous syllable, unless it is zero width
  GlyphIndex := Font.GetGlyphByCharacter(AGlyphs[Index].CodePoints[0]);
  if (GlyphIndex = 0) or (Font.GetAdvanceWidth(GlyphIndex) = 0) then
    exit;

  PrevCodePoint := AGlyphs[Index-1].CodePoints[0];
  Count := GetLength(PrevCodePoint);

  AGlyphs.Move(Index, Index-Count);
end;

function TPascalTypeHangulShaper.InsertDottedCircle(var AGlyphs: TPascalTypeGlyphString; Index: integer): integer;
var
  GlyphID: integer;
  Glyph: TPascalTypeGlyph;
begin
  Assert(Index > 0);

  Result := Index;

  GlyphID := Font.GetGlyphByCharacter(PascalTypeUnicode.cpDottedCircle);
  if (GlyphID = 0) then
    exit;

  Glyph := AGlyphs.CreateGlyph;
  Glyph.GlyphID := GlyphID;
  Glyph.CodePoints := [PascalTypeUnicode.cpDottedCircle];
  Glyph.Features := AGlyphs[Index].Features;

  // If the tone mark is zero width, insert the dotted circle before, otherwise after
  if (Font.GetAdvanceWidth(GlyphID) = 0) then
    AGlyphs.Insert(Index, Glyph)
  else
    AGlyphs.Insert(Index+1, Glyph);

  Inc(Result);
end;

procedure TPascalTypeHangulShaper.AssignLocalFeatures(var AGlyphs: TPascalTypeGlyphString);
var
  StateEntry: TStateEntry;
  Category: THangulCategory;
  Glyph: TPascalTypeGlyph;
  CodePoint: TPascalTypeCodePoint;
  i: integer;
begin
  inherited AssignLocalFeatures(AGlyphs);

  // Apply the state machine to map glyphs to features
  StateEntry.NextState := sStart;
  i := 0;
  while (i < AGlyphs.Count) do
  begin
    Glyph := AGlyphs[i];
    CodePoint := Glyph.CodePoints[0];
    Category := GetHangulCategory(CodePoint);

    StateEntry := StateMachine[StateEntry.NextState, Category];

    case StateEntry.Action of
      saDecompose:
        // Decompose the composed syllable if it is not supported by the font.
        if (not Font.HasGlyphByCharacter(CodePoint)) then
          i := Decompose(AGlyphs, i);

      saCompose:
        // Found a decomposed syllable.
        // Try to compose if supported by the font.
        i := Compose(AGlyphs, i);

      saToneMark:
        // Got a valid syllable, followed by a tone mark.
        // Move the tone mark to the beginning of the syllable.
        ReorderToneMark(AGlyphs, i);

      saInvalid:
        // Tone mark has no valid syllable to attach to, so insert a dotted circle
        i := InsertDottedCircle(AGlyphs, i);
    end;

    Inc(i);
  end;
end;

function TPascalTypeHangulShaper.NeedUnicodeComposition: boolean;
begin
  Result := True;
end;

initialization
  TPascalTypeShaper.RegisterShaperForScript('hang',  TPascalTypeHangulShaper); // Hangul
end.
