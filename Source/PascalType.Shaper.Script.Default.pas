unit PascalType.Shaper.Script.Default;

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

uses
  PT_Types,
  PascalType.GlyphString,
  PascalType.Shaper, // ShapeShifter
  PascalType.Shaper.Plan,
  PascalType.Shaper.Layout;


//------------------------------------------------------------------------------
//
//              TPascalTypeDefaultShaper
//
//------------------------------------------------------------------------------
// The default shaper. Handles non-complex scripts.
//------------------------------------------------------------------------------
type
  TPascalTypeDefaultShaper = class(TPascalTypeShaper)
  protected
    function NeedUnicodeComposition: boolean; override;
    procedure SetupPlan(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString; AFeatures: TPascalTypeShaperFeatures); override;
    procedure PlanPreprocessing(AStage: TPascalTypeShapingPlanStage);
    procedure PlanFeatures(AStage: TPascalTypeShapingPlanStage); virtual;
    procedure PlanPostprocessing(AStage: TPascalTypeShapingPlanStage);
    procedure AssignLocalFeatures(var AGlyphs: TPascalTypeGlyphString);
  end;


//------------------------------------------------------------------------------
//
//              Default feature plans
//
//------------------------------------------------------------------------------
const
  VariationFeatures: TTableNames = [
    'rvrn'      // Required Variation Alternates
  ];

  CommonFeatures: TTableNames = [
    'ccmp',     // Glyph Composition/Decomposition
    'locl',     // Localized Forms
    'rlig',     // Required Ligatures
    'mark',     // Mark Positioning
    'mkmk'      // Mark to Mark Positioning
  ];

  FractionalFeatures: TTableNames = [
    'frac',     // Fractions, optional
    'numr',     // Numerators, applied when 'frac' is used
    'dnom'      // Denominators, applied when 'frac' is used
  ];

  HorizontalFeatures: TTableNames = [
    'calt',     // Contextual Alternates
    'clig',     // Contextual Ligatures
    'liga',     // Standard Ligatures, optional
    'rclt',     // Required Contextual Alternates
    'curs',     // Cursive Positioning
    'kern'      // Kerning, optional, enabled by default
  ];

  VerticalFeatures: TTableNames = [
    'vert'      // Vertical Alternates
  ];

  DirectionalFeatures: array[TPascalTypeDirection] of TTableNames = (
    [
      'ltra',   // Left-to-right glyph alternates
      'ltrm'    // Left-to-right mirrored forms
    ], [
      'rtla',   // Right-to-left alternates
      'rtlm'    // Right-to-left mirrored forms
    ]);


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  PascalType.Unicode,
  PascalType.Shaper.Layout.OpenType;


//------------------------------------------------------------------------------
//
//              TPascalTypeDefaultShaper
//
//------------------------------------------------------------------------------
procedure TPascalTypeDefaultShaper.SetupPlan(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString; AFeatures: TPascalTypeShaperFeatures);

  procedure AssignGlobalFeatures;
  var
    Features: TTableNames;
    Glyph: TPascalTypeGlyph;
  begin
    Features := APlan.GlobalFeatures;
    for Glyph in AGlyphs do
      Glyph.Features := Features;
  end;

var
  Stage: TPascalTypeShapingPlanStage;
begin
  Stage := APlan.Stages.Add;

  // Add plan features
  PlanPreprocessing(Stage);
  PlanFeatures(Stage);
  PlanPostprocessing(Stage);

  // Add/Remove user specified features
  APlan.ApplyUserFeatures(AFeatures);

  // The plan is now complete

  // Assign the global features to all the glyphs
  AssignGlobalFeatures;

  // Assign "some" features to "some" glyphs
  AssignLocalFeatures(AGlyphs);
end;

procedure TPascalTypeDefaultShaper.PlanPreprocessing(AStage: TPascalTypeShapingPlanStage);
begin
  AStage.Add(VariationFeatures);
  AStage.Add(DirectionalFeatures[Direction]);

  AStage.Add(FractionalFeatures, False);
end;

procedure TPascalTypeDefaultShaper.PlanFeatures(AStage: TPascalTypeShapingPlanStage);
begin
  // Do nothing by default
end;

procedure TPascalTypeDefaultShaper.PlanPostprocessing(AStage: TPascalTypeShapingPlanStage);
begin
  AStage.Add(CommonFeatures);
  AStage.Add(HorizontalFeatures);
end;

procedure TPascalTypeDefaultShaper.AssignLocalFeatures(var AGlyphs: TPascalTypeGlyphString);
var
  i: integer;
  First: integer;
  Last: integer;
begin
  // Enable contextual fractions
  i := 0;
  while (i < AGlyphs.Count) do
  begin
    if (AGlyphs[i].CodePoints[0] = $002F) or (AGlyphs[i].CodePoints[0] = $2044) then // slash or fraction slash
    begin
      First := i;
      Last := i + 1;

      // Apply numerator
      while (First > 0) and (PascalTypeUnicode.IsDigit(AGlyphs[First-1].CodePoints[0])) do
      begin
        AGlyphs[First-1].Features.Add('numr');
        AGlyphs[First-1].Features.Add('frac');
        Dec(First);
      end;

      // Apply denominator
      while (Last < AGlyphs.Count) and (PascalTypeUnicode.IsDigit(AGlyphs[Last].CodePoints[0])) do
      begin
        AGlyphs[Last].Features.Add('dnom');
        AGlyphs[Last].Features.Add('frac');
        Inc(Last);
      end;

      // Apply fraction slash
      AGlyphs[i].Features.Add('frac');

      i := Last;
    end else
      Inc(i);
  end;
end;

function TPascalTypeDefaultShaper.NeedUnicodeComposition: boolean;
begin
  // OpenType appears to work best with decomposed Unicode
  // TODO : This decision belongs in the Layout Engine
  Result := False;
end;

initialization
  TPascalTypeShaper.RegisterDefaultShaperClass(TPascalTypeDefaultShaper);
end.
