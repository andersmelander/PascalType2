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
  PascalType.Shaper.Plan,
  PascalType.Shaper.Layout;


//------------------------------------------------------------------------------
//
//              TShaperGlyphString
//
//------------------------------------------------------------------------------
// A glyph string with knowledge about the font
//------------------------------------------------------------------------------
type
  TShaperGlyphString = class(TPascalTypeGlyphString)
  private
    FFont: TCustomPascalTypeFontFace;
  protected
    function GetGlyphClassID(AGlyph: TPascalTypeGlyph): integer; override;
    function GetMarkAttachmentType(AGlyph: TPascalTypeGlyph): integer; override;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace; const ACodePoints: TPascalTypeCodePoints); virtual;

    procedure HideDefaultIgnorables; override;

    property Font: TCustomPascalTypeFontFace read FFont;
  end;

  TShaperGlyphStringClass = class of TShaperGlyphString;


//------------------------------------------------------------------------------
//
//              TPascalTypeShaper
//
//------------------------------------------------------------------------------
// The shaper represents the script specific layer.
// Each script should have its own concrete shaper implementation, so we need a
// specific shaper for Arabic, a specific shaper for Hangul, etc.
// Scripts that are not handled by one of the script specific ones are handled
// by the default shaper.
//------------------------------------------------------------------------------
type
  TPascalTypeShaper = class;
  TPascalTypeShaperClass = class of TPascalTypeShaper;

  TPascalTypeShaper = class
  private
    class var FDefaultShaperClass: TPascalTypeShaperClass;
    class var FShaperClasses: TDictionary<Cardinal, TPascalTypeShaperClass>;
  private
    FScript: TTableType;
    FLanguage: TTableType;
    FDirection: TPascalTypeDirection;
    FFont: TCustomPascalTypeFontFace;
    FSubstitutionTable: TOpenTypeGlyphSubstitutionTable;
    FPositionTable: TOpenTypeGlyphPositionTable;
    FFeatures: TPascalTypeShaperFeatures;
    FPlan: TPascalTypeShapingPlan;
  private
    procedure SetLanguage(const Value: TTableType);
    procedure SetScript(const Value: TTableType);
    procedure SetDirection(const Value: TPascalTypeDirection);
    procedure FeaturesChanged(Sender: TObject);
  private
    class constructor Create;
    class destructor Destroy;
  protected
    procedure Reset; virtual;
    function NormalizationFilter(CodePoint: TPascalTypeCodePoint): boolean; virtual;
    function DecompositionFilter(CodePoint: TPascalTypeCodePoint): boolean; virtual;
    function CompositionFilter(CodePoint: TPascalTypeCodePoint): boolean; virtual;
    procedure ProcessCodePoints(var CodePoints: TPascalTypeCodePoints); virtual;
    function ProcessUnicode(const AText: string): TPascalTypeCodePoints; virtual;
    function NeedUnicodeComposition: boolean; virtual; // TODO : Move this to the Layout Engine
    function ZeroMarkWidths: TZeroMarkWidths; virtual;

    // TODO : This probably belongs in the font or in the layout engine
    function GetGlyphStringClass: TShaperGlyphStringClass; virtual;
    function CreateGlyphString(const ACodePoints: TPascalTypeCodePoints): TShaperGlyphString; virtual;

    function GetShapingPlanClass: TPascalTypeShapingPlanClass; virtual;
    function CreateShapingPlan: TPascalTypeShapingPlan; virtual;
    procedure SetupPlan(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString; AFeatures: TPascalTypeShaperFeatures); virtual;

    // CreateLayoutEngine really belongs in the font since the concrete layout
    // engine is specific to the font technology (e.g. OpenType, CFF, etc.) but
    // due to unit and class dependencies we need to wrap it here too.
    function CreateLayoutEngine: TCustomPascalTypeLayoutEngine;

    property Plan: TPascalTypeShapingPlan read FPlan;
    property SubstitutionTable: TOpenTypeGlyphSubstitutionTable read FSubstitutionTable;
    property PositionTable: TOpenTypeGlyphPositionTable read FPositionTable;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace);
    destructor Destroy; override;

    class function GetShaperForScript(const Script: TTableType): TPascalTypeShaperClass;
    class procedure RegisterDefaultShaperClass(ShaperClass: TPascalTypeShaperClass);

    function TextToGlyphs(const AText: string): TPascalTypeGlyphString; virtual;

    function Shape(const AText: string): TPascalTypeGlyphString; overload; virtual;
    procedure Shape(AGlyphs: TPascalTypeGlyphString); overload; virtual;

    property Font: TCustomPascalTypeFontFace read FFont;
    property Script: TTableType read FScript write SetScript;
    property Language: TTableType read FLanguage write SetLanguage;
    property Direction: TPascalTypeDirection read FDirection write SetDirection;

    // User feature overrides
    property Features: TPascalTypeShaperFeatures read FFeatures;
  end;

implementation

uses
  System.SysUtils,
{$ifdef DEBUG}
  WinApi.Windows,
{$endif DEBUG}

  PascalType.Tables.OpenType.Script,
  PascalType.Tables.OpenType.LanguageSystem,
  PascalType.Tables.OpenType.Substitution,
  PascalType.Tables.OpenType.GDEF;

//------------------------------------------------------------------------------
//
//              TShaperGlyphString
//
//------------------------------------------------------------------------------
constructor TShaperGlyphString.Create(AFont: TCustomPascalTypeFontFace; const ACodePoints: TPascalTypeCodePoints);
begin
  FFont := AFont;
  inherited Create(ACodePoints);
end;

function TShaperGlyphString.GetGlyphClassID(AGlyph: TPascalTypeGlyph): integer;
var
  GDEF: TOpenTypeGlyphDefinitionTable;
begin
  GDEF := Font.GetTableByTableType('GDEF') as TOpenTypeGlyphDefinitionTable;
  if (GDEF <> nil) and (GDEF.GlyphClassDefinition <> nil) then
    Result := GDEF.GlyphClassDefinition.GetClassID(AGlyph.GlyphID)
  else
    Result := inherited GetGlyphClassID(AGlyph);
end;

function TShaperGlyphString.GetMarkAttachmentType(AGlyph: TPascalTypeGlyph): integer;
var
  GDEF: TOpenTypeGlyphDefinitionTable;
begin
  GDEF := Font.GetTableByTableType('GDEF') as TOpenTypeGlyphDefinitionTable;
  if (GDEF <> nil) and (GDEF.MarkAttachmentClassDefinition <> nil) then
    Result := GDEF.MarkAttachmentClassDefinition.GetClassID(AGlyph.GlyphID)
  else
    Result := inherited GetMarkAttachmentType(AGlyph);
end;

procedure TShaperGlyphString.HideDefaultIgnorables;
var
  SpaceGlyph: Word;
  Glyph: TPascalTypeGlyph;
begin
  SpaceGlyph := Font.GetGlyphByCharacter(32);
  for Glyph in Self do
    if (Length(Glyph.CodePoints) > 0) and (PascalTypeUnicode.IsDefaultIgnorable(Glyph.CodePoints[0])) then
    begin
      Glyph.GlyphID := SpaceGlyph;
      Glyph.XAdvance := 0;
      Glyph.YAdvance := 0;
    end;
end;

//------------------------------------------------------------------------------
//
//              TPascalTypeShaper
//
//------------------------------------------------------------------------------
type
  TPascalTypeShaperFeaturesCracker = class(TPascalTypeShaperFeatures);

class constructor TPascalTypeShaper.Create;
begin
  FShaperClasses := TDictionary<Cardinal, TPascalTypeShaperClass>.Create;
end;

class destructor TPascalTypeShaper.Destroy;
begin
  FShaperClasses.Free;
end;

constructor TPascalTypeShaper.Create(AFont: TCustomPascalTypeFontFace);
begin
  inherited Create;

  FFont := AFont;
  FScript := OpenTypeDefaultScript;
  FLanguage := OpenTypeDefaultLanguageSystem;
  FDirection := PascalTypeDefaultDirection;

  FFeatures := TPascalTypeShaperFeatures.Create;
  TPascalTypeShaperFeaturesCracker(FFeatures).OnChanged := FeaturesChanged;

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

  inherited;
end;

class procedure TPascalTypeShaper.RegisterDefaultShaperClass(ShaperClass: TPascalTypeShaperClass);
begin
  FDefaultShaperClass := ShaperClass;
end;

class function TPascalTypeShaper.GetShaperForScript(const Script: TTableType): TPascalTypeShaperClass;
begin
  if (not FShaperClasses.TryGetValue(Script.AsCardinal, Result)) then
    Result := FDefaultShaperClass;
end;

procedure TPascalTypeShaper.FeaturesChanged(Sender: TObject);
begin
  Reset;
end;

procedure TPascalTypeShaper.Reset;
begin
  FreeAndNil(FPlan);
end;

function TPascalTypeShaper.CreateGlyphString(const ACodePoints: TPascalTypeCodePoints): TShaperGlyphString;
var
  Glyph: TPascalTypeGlyph;
begin
  Result := GetGlyphStringClass.Create(Font, ACodePoints);

  Result.Script := Script;
  Result.Language := Language;
  Result.Direction := Direction;

  // Map Unicode CodePoints to Glyph IDs
  for Glyph in Result do
    Glyph.GlyphID := Font.GetGlyphByCharacter(Glyph.CodePoints[0]);
end;

function TPascalTypeShaper.CreateLayoutEngine: TCustomPascalTypeLayoutEngine;
begin
  Result := Font.CreateLayoutEngine as TCustomPascalTypeLayoutEngine;
end;

function TPascalTypeShaper.GetGlyphStringClass: TShaperGlyphStringClass;
begin
  Result := TShaperGlyphString;
end;

function TPascalTypeShaper.CreateShapingPlan: TPascalTypeShapingPlan;
begin
  Result := GetShapingPlanClass.Create;
end;

function TPascalTypeShaper.GetShapingPlanClass: TPascalTypeShapingPlanClass;
begin
  Result := TPascalTypeShapingPlan;
end;

function TPascalTypeShaper.NeedUnicodeComposition: boolean;
begin
  // TODO : This decision belongs in the Layout Engine
  Result := True;
end;

function TPascalTypeShaper.NormalizationFilter(CodePoint: TPascalTypeCodePoint): boolean;
begin
  // Do not reorder is codepoiont is a mark
  Result := not PascalTypeUnicode.IsMark(CodePoint);
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
  ** Unicode decompose
  *)
  Result := PascalTypeUnicode.Decompose(Result, DecompositionFilter);

  (*
  ** Unicode normalization
  *)
  PascalTypeUnicode.Normalize(Result, NormalizationFilter);

  (*
  ** Process individual codepoints
  *)
  ProcessCodePoints(Result);

  (*
  ** Unicode composition (optional)
  *)
  if (NeedUnicodeComposition) then
    Result := PascalTypeUnicode.Compose(Result, CompositionFilter);
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

procedure TPascalTypeShaper.SetupPlan(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString; AFeatures: TPascalTypeShaperFeatures);
begin
end;

procedure TPascalTypeShaper.Shape(AGlyphs: TPascalTypeGlyphString);
var
  LayoutEngine: TCustomPascalTypeLayoutEngine;
begin
  (*
  ** Create a shaping plan.
  ** The plan contains a collection of plan stages and each plan stage contains
  ** a list of features that belong to that stage.
  *)
  if (FPlan = nil) then
    FPlan := CreateShapingPlan;

  SetupPlan(FPlan, AGlyphs, FFeatures);

  // TODO : Create LayoutEngine once, free on reset
  LayoutEngine := CreateLayoutEngine;
  try
    LayoutEngine.ZeroMarkWidths := ZeroMarkWidths;

    LayoutEngine.Layout(FPlan, AGlyphs);
  finally
    LayoutEngine.Free;
  end;
end;

function TPascalTypeShaper.TextToGlyphs(const AText: string): TPascalTypeGlyphString;
var
  UTF32: TPascalTypeCodePoints;
begin
  (*
  ** Process UTF16 unicode string and return a normalized UCS-4/UTF32 string
  *)
  UTF32 := ProcessUnicode(AText);

  (*
  ** Convert from Unicode codepoints to glyph IDs.
  *)
  Result := CreateGlyphString(UTF32);
end;

function TPascalTypeShaper.Shape(const AText: string): TPascalTypeGlyphString;
begin
  (*
  ** Convert from text to Unicode codepoints to glyph IDs.
  *)
  Result := TextToGlyphs(AText);
  try

    Shape(Result);

  except
    Result.Free;
    raise;
  end;
end;

function TPascalTypeShaper.ZeroMarkWidths: TZeroMarkWidths;
begin
  Result := zmwAfterPositioning;
end;

//------------------------------------------------------------------------------

end.
