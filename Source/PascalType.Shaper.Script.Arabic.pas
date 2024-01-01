unit PascalType.Shaper.Script.Arabic;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//      Shaper for Arabic, and other cursive scripts.                         //
//                                                                            //
//      Based on the FontKit Arabic shaper (which in turn is probably based   //
//      on the Harfbuzz Arabic shaper.                                        //
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
//              TPascalTypeArabicShaper
//
//------------------------------------------------------------------------------
type
  TPascalTypeArabicShaper = class(TPascalTypeDefaultShaper)
  private
    function GetShapingClass(ACodePoint: TPascalTypeCodePoint): ArabicShapingClasses.TShapingClass;
  protected
    function NeedUnicodeComposition: boolean; override;
    procedure PlanFeatures(AStage: TPascalTypeShapingPlanStage); override;
    procedure AssignLocalFeatures(AFeatures: TPascalTypeShaperFeatures; var AGlyphs: TPascalTypeGlyphString); override;
  end;


//------------------------------------------------------------------------------
//
//              Arabic feature plans
//
//------------------------------------------------------------------------------
const
  ArabicFeatures: TTableNames = [
    'isol',
    'fina',
    'fin2',
    'fin3',
    'medi',
    'med2',
    'init'
  ];


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  System.Classes,
  PascalType.Shaper.Layout.OpenType;


type
  TState = 0..6;
  TStateEntry = record
    PreviousAction: TTableName;
    CurrentAction: TTableName;
    NextState: TState;
  end;

  TStateEntries = array[ArabicShapingClasses.TShapingClass.scNon_Joining..ArabicShapingClasses.TShapingClass.scDALATH_RISH] of TStateEntry;
  TStateMachine = array[TState] of TStateEntries;

const
  // The shaping state machine was ported from Harfbuzz via FontKit.
  // https://github.com/behdad/harfbuzz/blob/master/src/hb-ot-shape-complex-arabic.cc
  None = #0#0#0#0;
  StateMachine: TStateMachine = (
    //   Non_Joining,                                                Left_Joining,                                                   Right_Joining,                                                  Dual_Joining,                                                   ALAPH,                                                          DALATH RISH
    // State 0: prev was U,  not willing to join.
    ((PreviousAction: None;   CurrentAction: None;   NextState: 0),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 1),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 1),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 6)),

    // State 1: prev was R or 'isol'/ALAPH,  not willing to join.
    ((PreviousAction: None;   CurrentAction: None;   NextState: 0),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 1),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: None;   CurrentAction: 'fin2'; NextState: 5),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 6)),

    // State 2: prev was D/L in 'isol' form,  willing to join.
    ((PreviousAction: None;   CurrentAction: None;   NextState: 0),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: 'init'; CurrentAction: 'fina'; NextState: 1),  (PreviousAction: 'init'; CurrentAction: 'fina'; NextState: 3),  (PreviousAction: 'init'; CurrentAction: 'fina'; NextState: 4),  (PreviousAction: 'init'; CurrentAction: 'fina'; NextState: 6)),

    // State 3: prev was D in 'fina' form,  willing to join.
    ((PreviousAction: None;   CurrentAction: None;   NextState: 0),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: 'medi'; CurrentAction: 'fina'; NextState: 1),  (PreviousAction: 'medi'; CurrentAction: 'fina'; NextState: 3),  (PreviousAction: 'medi'; CurrentAction: 'fina'; NextState: 4),  (PreviousAction: 'medi'; CurrentAction: 'fina'; NextState: 6)),

    // State 4: prev was 'fina' ALAPH,  not willing to join.
    ((PreviousAction: None;   CurrentAction: None;   NextState: 0),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: 'med2'; CurrentAction: 'isol'; NextState: 1),  (PreviousAction: 'med2'; CurrentAction: 'isol'; NextState: 2),  (PreviousAction: 'med2'; CurrentAction: 'fin2'; NextState: 5),  (PreviousAction: 'med2'; CurrentAction: 'isol'; NextState: 6)),

    // State 5: prev was 'fin2'/'fin3' ALAPH,  not willing to join.
    ((PreviousAction: None;   CurrentAction: None;   NextState: 0),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: 'isol'; CurrentAction: 'isol'; NextState: 1),  (PreviousAction: 'isol'; CurrentAction: 'isol'; NextState: 2),  (PreviousAction: 'isol'; CurrentAction: 'fin2'; NextState: 5),  (PreviousAction: 'isol'; CurrentAction: 'isol'; NextState: 6)),

    // State 6: prev was DALATH/RISH,  not willing to join.
    ((PreviousAction: None;   CurrentAction: None;   NextState: 0),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 1),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 2),  (PreviousAction: None;   CurrentAction: 'fin3'; NextState: 5),  (PreviousAction: None;   CurrentAction: 'isol'; NextState: 6))
  );


//------------------------------------------------------------------------------
//
//              TPascalTypeArabicShaper
//
//------------------------------------------------------------------------------
procedure TPascalTypeArabicShaper.PlanFeatures(AStage: TPascalTypeShapingPlanStage);
var
  Feature: TTableName;
  Stage: TPascalTypeShapingPlanStage;
const
  FeatureCCMP = 'ccmp';
  FeatureLOCL = 'locl';
  FeatureMSET = 'mset';
begin
  AStage.Add([FeatureCCMP, FeatureLOCL]);

  for Feature in ArabicFeatures do
  begin
    Stage := AStage.Plan.Stages.Add;
    Stage.Add(Feature, False);
  end;

  Stage := AStage.Plan.Stages.Add;
  Stage.Add(FeatureMSET);
end;

procedure TPascalTypeArabicShaper.AssignLocalFeatures(AFeatures: TPascalTypeShaperFeatures; var AGlyphs: TPascalTypeGlyphString);
var
  Actions: TArray<TTableType>;
  State: TState;
  PreviousIndex: integer;
  i: integer;
  Glyph: TPascalTypeGlyph;
  ShapingClass: ArabicShapingClasses.TShapingClass;
  StateEntry: TStateEntry;
begin
  inherited AssignLocalFeatures(AFeatures, AGlyphs);

  // Apply the state machine to map glyphs to features
  SetLength(Actions, AGlyphs.Count);
  State := 0;
  PreviousIndex := -1;

  for i := 0 to AGlyphs.Count-1 do
  begin
    Glyph := AGlyphs[i];
    ShapingClass := GetShapingClass(Glyph.CodePoints[0]);

    if (ShapingClass = scTransparent) then
    begin
      Actions[i] := 0;
      continue;
    end;

    StateEntry := StateMachine[State, ShapingClass];
    State := StateEntry.NextState;

    if (TTableType(StateEntry.PreviousAction) <> 0) and (PreviousIndex <> -1) then
      Actions[PreviousIndex] := StateEntry.PreviousAction;

    Actions[i] := StateEntry.CurrentAction;
    PreviousIndex := i;
  end;

  // Apply the chosen features to their respective glyphs
  for i := 0 to AGlyphs.Count-1 do
    if (Actions[i] <> 0) then
      AGlyphs[i].Features.Add(Actions[i]);
end;

function TPascalTypeArabicShaper.GetShapingClass(ACodePoint: TPascalTypeCodePoint): ArabicShapingClasses.TShapingClass;
var
  Category: TCharacterCategories;
begin
  if (not ArabicShapingClasses.Trie.Loaded) then
    ArabicShapingClasses.Load;

  if (ArabicShapingClasses.Trie.TryGetValue(ACodePoint, Result)) and (Result > Low(Result)) then
    Exit(Pred(Result));

  Category := PascalTypeUnicode.GetCategory(ACodePoint);

  if (Category * [ccMarkNonSpacing, ccMarkEnclosing, ccOtherFormat] <> []) then
    Result := scTransparent
  else
    Result := scNon_Joining;
end;

function TPascalTypeArabicShaper.NeedUnicodeComposition: boolean;
begin
  Result := False;
end;

initialization
  TPascalTypeShaper.RegisterShaperForScript('arab',  TPascalTypeArabicShaper); // Arabic
  TPascalTypeShaper.RegisterShaperForScript('mong',  TPascalTypeArabicShaper); // Mongolian
  TPascalTypeShaper.RegisterShaperForScript('syrc',  TPascalTypeArabicShaper); // Syriac
  TPascalTypeShaper.RegisterShaperForScript('nko ',  TPascalTypeArabicShaper); // N'Ko
  TPascalTypeShaper.RegisterShaperForScript('phag',  TPascalTypeArabicShaper); // Phags Pa
  TPascalTypeShaper.RegisterShaperForScript('mand',  TPascalTypeArabicShaper); // Mandaic
  TPascalTypeShaper.RegisterShaperForScript('mani',  TPascalTypeArabicShaper); // Manichaean
  TPascalTypeShaper.RegisterShaperForScript('phlp',  TPascalTypeArabicShaper); // Psalter Pahlavi
end.
