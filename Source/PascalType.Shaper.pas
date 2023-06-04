unit PascalType.Shaper;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      Typographic shaper                                    //
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

uses
  System.Classes,
  Generics.Collections,
  PT_Types,
  PT_Classes,
  PascalType.Unicode,
  PascalType.GlyphString,
  PascalType.FontFace.SFNT,
  PascalType.Tables.OpenType.Common,
  PascalType.Tables.OpenType.GSUB,
  PascalType.Tables.OpenType.GPOS,
  PascalType.Tables.OpenType.Feature,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Shaper.Plan;


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
//
//              TPascalTypeShaper
//
//------------------------------------------------------------------------------
type
  TPascalTypeShaper = class
  private type
    TPascalTypeShaperFeatures = class
    private
      FShaper: TPascalTypeShaper;
      FFeatures: TDictionary<TTableName, boolean>;
      FEnableAll: boolean;
      function GetFeatureEnabled(const AKey: TTableName): boolean;
      procedure SetFeatureEnabled(const AKey: TTableName; const Value: boolean);
    public
      constructor Create(AShaper: TPascalTypeShaper);
      destructor Destroy; override;
      function GetEnumerator: TEnumerator<TTableName>;
      function IsEnabled(const AKey: TTableName; ADefault: boolean): boolean;
      property Enabled[const AKey: TTableName]: boolean read GetFeatureEnabled write SetFeatureEnabled; default;
      property EnableAll: boolean read FEnableAll write FEnableAll;
    end;

    TPlannedFeatures = TList<TCustomOpenTypeFeatureTable>;
  private
    FScript: TTableType;
    FLanguage: TTableType;
    FDirection: TPascalTypeDirection;
    FFont: TCustomPascalTypeFontFace;
    FSubstitutionTable: TOpenTypeGlyphSubstitutionTable;
    FPositionTable: TOpenTypeGlyphPositionTable;
    FFeatures: TPascalTypeShaperFeatures;
    FPlan: TPascalTypeShapingPlan;
    FPlannedSubstitutionFeatures: TPlannedFeatures;
    FPlannedPositioningFeatures: TPlannedFeatures;
  private
    procedure SetLanguage(const Value: TTableType);
    procedure SetScript(const Value: TTableType);
    procedure SetDirection(const Value: TPascalTypeDirection);
  protected
    function CreatePlannedFeatureList(APlan: TPascalTypeShapingPlan; AGlobalTable: TCustomOpenTypeCommonTable): TPlannedFeatures;

    procedure Reset; virtual;
    function DecompositionFilter(CodePoint: TPascalTypeCodePoint): boolean; virtual;
    function CompositionFilter(CodePoint: TPascalTypeCodePoint): boolean; virtual;
    procedure ProcessCodePoints(var CodePoints: TPascalTypeCodePoints); virtual;
    function ProcessUnicode(const AText: string): TPascalTypeCodePoints; virtual;
    procedure ApplyLookups(ALookupListTable: TOpenTypeLookupListTable; AFeatures: TPlannedFeatures; var AGlyphs: TPascalTypeGlyphString);
    procedure ApplySubstitution(AFeatures: TPlannedFeatures; var AGlyphs: TPascalTypeGlyphString); virtual;
    procedure ApplyPositioning(AFeatures: TPlannedFeatures; var AGlyphs: TPascalTypeGlyphString); virtual;

    function CreateGlyphString(const ACodePoints: TPascalTypeCodePoints): TPascalTypeGlyphString; virtual;
    function GetGlyphStringClass: TPascalTypeGlyphStringClass; virtual;

    function GetShapingPlanClass: TPascalTypeShapingPlanClass; virtual;
    function CreateShapingPlan: TPascalTypeShapingPlan; virtual;

    procedure SetupPlan(APlan: TPascalTypeShapingPlan); virtual;
    procedure PlanPreprocessing(AStage: TPascalTypeShapingPlanStage);
    procedure PlanFeatures(AStage: TPascalTypeShapingPlanStage); virtual;
    procedure PlanPostprocessing(AStage: TPascalTypeShapingPlanStage);
    procedure PlanApplyOptions(APlan: TPascalTypeShapingPlan);

    property Plan: TPascalTypeShapingPlan read FPlan;
    property SubstitutionTable: TOpenTypeGlyphSubstitutionTable read FSubstitutionTable;
    property PositionTable: TOpenTypeGlyphPositionTable read FPositionTable;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace);
    destructor Destroy; override;

    function Shape(const AText: string): TPascalTypeGlyphString; virtual;

    property Language: TTableType read FLanguage write SetLanguage;
    property Script: TTableType read FScript write SetScript;
    property Direction: TPascalTypeDirection read FDirection write SetDirection;
    property Font: TCustomPascalTypeFontFace read FFont;

    // User feature overrides
    property Features: TPascalTypeShaperFeatures read FFeatures;
  end;

implementation

uses
  SysUtils,

  PascalType.Tables.OpenType.Script,
  PascalType.Tables.OpenType.LanguageSystem,
  PascalType.Tables.OpenType.Substitution;

//------------------------------------------------------------------------------
//
//              TPascalTypeShaper
//
//------------------------------------------------------------------------------
constructor TPascalTypeShaper.Create(AFont: TCustomPascalTypeFontFace);
begin
  inherited Create;
  FFont := AFont;
  FScript := OpenTypeDefaultScript;
  FLanguage := OpenTypeDefaultLanguageSystem;
  FFeatures := TPascalTypeShaperFeatures.Create(Self);
  // Cache GSUB & GPOS. We'll use it a lot
  FSubstitutionTable := TOpenTypeGlyphSubstitutionTable(IPascalTypeFontFace(FFont).GetTableByTableType(TOpenTypeGlyphSubstitutionTable.GetTableType));
  FPositionTable := TOpenTypeGlyphPositionTable(IPascalTypeFontFace(FFont).GetTableByTableType(TOpenTypeGlyphPositionTable.GetTableType));

  // TODO : Test only. Set up test features
  Features['liga'] := True;
end;

destructor TPascalTypeShaper.Destroy;
begin
  FPlan.Free;
  FFeatures.Free;
  FPlannedSubstitutionFeatures.Free;
  FPlannedPositioningFeatures.Free;

  inherited;
end;

procedure TPascalTypeShaper.Reset;
begin
  FreeAndNil(FPlannedSubstitutionFeatures);
  FreeAndNil(FPlannedPositioningFeatures);
  FreeAndNil(FPlan);
end;

function TPascalTypeShaper.CreateGlyphString(const ACodePoints: TPascalTypeCodePoints): TPascalTypeGlyphString;
var
  Glyph: TPascalTypeGlyph;
begin
  Result := GetGlyphStringClass.Create(ACodePoints);

  // Map Unicode CodePoints to Glyph IDs
  for Glyph in Result do
    Glyph.GlyphID := Font.GetGlyphByCharacter(Glyph.CodePoints[0]);
end;

function TPascalTypeShaper.GetGlyphStringClass: TPascalTypeGlyphStringClass;
begin
  Result := TPascalTypeGlyphString;
end;

function TPascalTypeShaper.CreateShapingPlan: TPascalTypeShapingPlan;
begin
  Result := GetShapingPlanClass.Create;
  SetupPlan(Result);
end;

function TPascalTypeShaper.GetShapingPlanClass: TPascalTypeShapingPlanClass;
begin
  Result := TPascalTypeShapingPlan;
end;

function TPascalTypeShaper.CompositionFilter(CodePoint: TPascalTypeCodePoint): boolean;
begin
  // Lookup codepoint in font.
  // Reject if font doesn't contain a glyph for the codepoint
  Result := Font.HasGlyphByCharacter(CodePoint);
end;

function TPascalTypeShaper.DecompositionFilter(CodePoint: TPascalTypeCodePoint): boolean;
begin
  // https://graphemica.com
  case CodePoint of
    $0931: Result := False; // devanagari letter rra
    $09DC: Result := False; // bengali letter rra
    $09DD: Result := False; // bengali letter rha
    $0B94: Result := False; // tamil letter au
  else
    Result := True;
  end;
end;

procedure TPascalTypeShaper.ProcessCodePoints(var CodePoints: TPascalTypeCodePoints);

  procedure ProcessCodePoint(var CodePoint: TPascalTypeCodePoint);
  begin
    case CodePoint of
      $2011: // non-breaking hyphen
        // According to https://github.com/n8willis/opentype-shaping-documents/blob/master/opentype-shaping-normalization.md
        //
        //   The "non-breaking hyphen" character should be replaced with "hyphen"
        //
        // HARFBUZZ states:
        //
        //   U+2011 is the only sensible character that is a no-break version of another character
        //   and not a space.  The space ones are handled already.  Handle this lone one.
        //
        // ...and replaces it with U+2010
        //
        // However my tests show that currently U+2010 is just displayed as "a box" (i.e. missing glyph).
        // This may well be because my implementation is currently incomplete.
        // TODO : Revisit once full substitution has been implemented.
        // For now we replace with a regular simple hyphen ("hyphen minus") instead.
        //
        if (Font.HasGlyphByCharacter($2010)) then
          CodePoint := $2010 // hyphen
        else
        if (Font.HasGlyphByCharacter($002D)) then
          CodePoint := $002D; // hyphen-minus
    else
      if (PascalTypeUnicode.IsWhiteSpace(CodePoint)) then
      begin
        if (not Font.HasGlyphByCharacter(CodePoint)) then
          // TODO : We need to handle the difference in width
          CodePoint := $0020; // Regular space
      end;
    end;
  end;

var
  i: integer;
begin
  for i := Low(CodePoints) to High(CodePoints) do
    ProcessCodePoint(CodePoints[i]);
end;

function TPascalTypeShaper.ProcessUnicode(const AText: string): TPascalTypeCodePoints;
begin
  (*
  ** Convert UTF16 to UTF32
  *)
  Result := PascalTypeUnicode.UTF16ToUTF32(AText);

  (*
  ** Unicode decompose and normalization
  *)
  Result := PascalTypeUnicode.Decompose(Result, DecompositionFilter);

  (*
  ** Process individual codepoints
  *)
  ProcessCodePoints(Result);

  (*
  ** Unicode composition
  *)
  Result := PascalTypeUnicode.Compose(Result, CompositionFilter);
end;

function TPascalTypeShaper.CreatePlannedFeatureList(APlan: TPascalTypeShapingPlan; AGlobalTable: TCustomOpenTypeCommonTable): TPlannedFeatures;
var
  FeatureMap: TDictionary<TTableType, TCustomOpenTypeFeatureTable>;
  ScriptTable: TCustomOpenTypeScriptTable;
  LanguageSystem: TCustomOpenTypeLanguageSystemTable;
  i: integer;
  FeatureTable: TCustomOpenTypeFeatureTable;
  Stage: TPascalTypeShapingPlanStage;
  Feature: TTableName;
begin
  Assert(AGlobalTable <> nil);

  Result := TPlannedFeatures.Create;
  try

    // Create a feature map (tag->table) for the current script and language
    FeatureMap := TDictionary<TTableType, TCustomOpenTypeFeatureTable>.Create;
    try

      // Get script, fallback to default
      ScriptTable := AGlobalTable.ScriptListTable.FindScript(Script, True);

      if (ScriptTable <> nil) then
      begin
        // Get language system, fallback to default
        LanguageSystem := ScriptTable.FindLanguageSystem(Language, True);

        if (LanguageSystem <> nil) then
        begin
          for i := 0 to LanguageSystem.FeatureIndexCount-1 do
          begin
            // LanguageSystem feature list contains index numbers into the FeatureListTable
            FeatureTable := AGlobalTable.FeatureListTable.Feature[LanguageSystem.FeatureIndex[i]];

            // Ignore features that does not occur in the plan
            if (APlan.Stages.HasFeature(FeatureTable.TableType.AsAnsiChar)) then
              FeatureMap.Add(FeatureTable.TableType, FeatureTable);
          end;
        end;
      end;

      // Convert the stage feature tags into a sequential list of feature tables.
      // The list will contain the intersection between the features supported by
      // the fonts script/language and the featuirs in the shaping plan.
      for Stage in APlan.Stages do
        for Feature in Stage do
          if (FeatureMap.TryGetValue(Feature, FeatureTable)) then
            Result.Add(FeatureTable);

    finally
      FeatureMap.Free;
    end;

  except
    Result.Free;
    raise;
  end;
end;

procedure TPascalTypeShaper.SetDirection(const Value: TPascalTypeDirection);
begin
  Reset;
  FDirection := Value;
end;

procedure TPascalTypeShaper.SetLanguage(const Value: TTableType);
begin
  Reset;
  FLanguage := Value;
end;

procedure TPascalTypeShaper.SetScript(const Value: TTableType);
begin
  Reset;
  FScript := Value;
end;

procedure TPascalTypeShaper.PlanPreprocessing(AStage: TPascalTypeShapingPlanStage);
begin
  AStage.Add(VariationFeatures);
  AStage.Add(DirectionalFeatures[FDirection]);
  AStage.Add(FractionalFeatures);
end;

procedure TPascalTypeShaper.PlanFeatures(AStage: TPascalTypeShapingPlanStage);
begin
  // Do nothing by default
end;

procedure TPascalTypeShaper.PlanPostprocessing(AStage: TPascalTypeShapingPlanStage);
begin
  AStage.Add(CommonFeatures);
  AStage.Add(HorizontalFeatures);
end;

procedure TPascalTypeShaper.PlanApplyOptions(APlan: TPascalTypeShapingPlan);
var
  Key: TTableName;
begin
  // Apply options; Some features are optional, other are mandatory. E.g. 'liga' is optional.
  // We allow the user to disable any feature. Even mandatory ones.
  for Key in Features do
    if (Features[Key]) then
      APlan.AddFeature(Key)
    else
      APlan.RemoveFeature(Key);
end;

procedure TPascalTypeShaper.SetupPlan(APlan: TPascalTypeShapingPlan);
var
  StagePreprocessing: TPascalTypeShapingPlanStage;
  StageFeatures: TPascalTypeShapingPlanStage;
  StagePostprocessing: TPascalTypeShapingPlanStage;
begin
  StagePreprocessing := APlan.Stages.AddStage;
  StageFeatures := APlan.Stages.AddStage;
  StagePostprocessing := APlan.Stages.AddStage;

  PlanPreprocessing(StagePreprocessing);
  PlanFeatures(StageFeatures);
  PlanPostprocessing(StagePostprocessing);

  PlanApplyOptions(APlan);
end;


procedure TPascalTypeShaper.ApplyLookups(ALookupListTable: TOpenTypeLookupListTable; AFeatures: TPlannedFeatures;
  var AGlyphs: TPascalTypeGlyphString);
var
  FeatureTable: TCustomOpenTypeFeatureTable;
  i: integer;
  LookupTable: TCustomOpenTypeLookupTable;
  GlyphIndex, NextGlyphIndex: integer;
  GlyphHandled: boolean;
  LoopCount: integer;
const
  MaxLoop = 10;
begin
  Assert(ALookupListTable <> nil);

  // Iterate over each feature and apply it to the individual glyphs.
  // Each glyph is only processed once by a feature, but it can be
  // processed multiple times by different features.
  for FeatureTable in AFeatures do
  begin

    GlyphIndex := 0;
    NextGlyphIndex := 0;
    LoopCount := 0;
    while (GlyphIndex < AGlyphs.Count) do
    begin
      GlyphHandled := False;

      // A series of substitution operations on the same glyph or string requires multiple
      // lookups, one for each separate action. Each lookup has a different array index
      // in the LookupList table and is applied in the LookupList order.
      for i := 0 to FeatureTable.LookupListCount-1 do
      begin
        // During text processing, a client applies a lookup to each glyph in the string
        // before moving to the next lookup. A lookup is finished for a glyph after the
        // client locates the target glyph or glyph context and performs a substitution,
        // if specified. To move to the “next” glyph, the client will typically skip all
        // the glyphs that participated in the lookup operation: glyphs that were
        // substituted as well as any other glyphs that formed a context for the operation.
        LookupTable := ALookupListTable.LookupTables[FeatureTable.LookupList[i]];

        NextGlyphIndex := GlyphIndex;
        if (LookupTable.Apply(AGlyphs, NextGlyphIndex)) then
        begin
          GlyphHandled := True;
          break;
        end;
      end;

      if (GlyphHandled) then
      begin
        // It's legal to modify the glyph and not increment the index.
        // It's not legal to decrement the index.
        if (NextGlyphIndex <= GlyphIndex) then
          Inc(LoopCount);

        if (LoopCount >= MaxLoop) then
          // Something's wrong. Get out of Dodge!
          break;

        GlyphIndex := NextGlyphIndex;
      end else
        Inc(GlyphIndex);
    end;
  end;
end;

procedure TPascalTypeShaper.ApplySubstitution(AFeatures: TPlannedFeatures; var AGlyphs: TPascalTypeGlyphString);
begin
  if (FSubstitutionTable <> nil) then
    ApplyLookups(FSubstitutionTable.LookupListTable, AFeatures, AGlyphs);
end;

procedure TPascalTypeShaper.ApplyPositioning(AFeatures: TPlannedFeatures; var AGlyphs: TPascalTypeGlyphString);
begin
  if (FPositionTable <> nil) then
    ApplyLookups(FPositionTable.LookupListTable, AFeatures, AGlyphs);
end;

function TPascalTypeShaper.Shape(const AText: string): TPascalTypeGlyphString;
var
  UTF32: TPascalTypeCodePoints;
begin
  (*
  ** Process UTF16 unicode string and return a normalized UCS-4/UTF32 string
  *)
  UTF32 := ProcessUnicode(AText);


  (*
  ** Convert from Unicode codepoints to glyph IDs.
  ** From here on we are done with Unicode codepoints and are working with glyph IDs.
  *)
  Result := CreateGlyphString(UTF32);
  try
    SetLength(UTF32, 0);


    (*
    ** Apply first GSUB features and then GPOS features
    *)
    if (FSubstitutionTable <> nil) or (FPositionTable <> nil) then
    begin

      (*
      ** Create a shaping plan.
      ** The plan contains a collection of plan stages and each plan stage contains
      ** a list of features that belong to that stage.
      *)
      if (FPlan = nil) then
        FPlan := CreateShapingPlan;


      (*
      ** Execute substitution plan.
      ** The substitution plan is the intersection between the features in the plan
      ** and the features supported by the font (via the GSUB table).
      *)
      if (FSubstitutionTable <> nil) then
      begin
        // Build ordered list of features supported by the font.
        // This is only done once per "session". No need to do it once per character.
        if (FPlannedSubstitutionFeatures = nil) then
          FPlannedSubstitutionFeatures := CreatePlannedFeatureList(FPlan, FSubstitutionTable);

        ApplySubstitution(FPlannedSubstitutionFeatures, Result);
      end;


      (*
      ** Execute positioning plan.
      ** The positioning plan is the intersection between the features in the plan
      ** and the features supported by the font (via the GPOS table).
      *)
      if (FPositionTable <> nil) then
      begin
        if (FPlannedPositioningFeatures = nil) then
          FPlannedPositioningFeatures := CreatePlannedFeatureList(FPlan, FPositionTable);

        ApplyPositioning(FPlannedPositioningFeatures, Result);
      end;

    end;

  except
    Result.Free;
    raise;
  end;
end;

//------------------------------------------------------------------------------
//              TPascalTypeShaper.TPascalTypeShaperFeatures
//------------------------------------------------------------------------------
constructor TPascalTypeShaper.TPascalTypeShaperFeatures.Create(AShaper: TPascalTypeShaper);
begin
  inherited Create;
  FShaper := AShaper;
  FFeatures := TDictionary<TTableName, boolean>.Create;
end;

destructor TPascalTypeShaper.TPascalTypeShaperFeatures.Destroy;
begin
  FFeatures.Free;
  inherited;
end;

function TPascalTypeShaper.TPascalTypeShaperFeatures.GetEnumerator: TEnumerator<TTableName>;
begin
  Result := FFeatures.Keys.GetEnumerator;
end;

function TPascalTypeShaper.TPascalTypeShaperFeatures.GetFeatureEnabled(const AKey: TTableName): boolean;
begin
  Result := IsEnabled(AKey, FEnableAll);
end;

function TPascalTypeShaper.TPascalTypeShaperFeatures.IsEnabled(const AKey: TTableName; ADefault: boolean): boolean;
begin
  if (not FFeatures.TryGetValue(AKey, Result)) then
    Result := ADefault;
end;

procedure TPascalTypeShaper.TPascalTypeShaperFeatures.SetFeatureEnabled(const AKey: TTableName; const Value: boolean);
begin
  FFeatures.AddOrSetValue(AKey, Value);
  FShaper.Reset;
end;

//------------------------------------------------------------------------------

end.
