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
//  The initial developer of this code is Anders Melander.                    //
//                                                                            //
//  Portions created by Anders Melander are Copyright (C) 2023                //
//  by Anders Melander. All Rights Reserved.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

uses
  System.Classes,
  Generics.Collections,
  PascalType.Types,
  PascalType.Classes,
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
    function GetDirection: TPascalTypeDirection;
    procedure FeaturesChanged(Sender: TObject);
  private
    class constructor Create;
    class destructor Destroy;
  protected
    procedure Reset; virtual;
    function NormalizationFilter(CodePoint: TPascalTypeCodePoint): boolean; virtual;
    function DecompositionFilter(Composite: TPascalTypeCodePoint; CodePoint: TPascalTypeCodePoint): boolean; virtual;
    function CompositionFilter(FirstCodePoint, SecondCodePoint: TPascalTypeCodePoint; var Composite: TPascalTypeCodePoint): boolean; virtual;
    procedure ProcessCodePoints(var CodePoints: TPascalTypeCodePoints); virtual;
    function ProcessUnicode(const UTF32: TPascalTypeCodePoints): TPascalTypeCodePoints; virtual;
    function NeedUnicodeComposition: boolean; virtual; // TODO : Move this to the Layout Engine
    function ZeroMarkWidths: TZeroMarkWidths; virtual;

    function CreateGlyphString(const ACodePoints: TPascalTypeCodePoints): TFontGlyphString;

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

    class procedure RegisterShaperForScript(const Script: TTableType; AShaperClass: TPascalTypeShaperClass);
    class function DetectScript(const UTF32: TPascalTypeCodePoints): TTableType; overload;
    class function DetectScript(const AText: string): TTableType; overload;
    class function GetShaperClass(const Script: TTableType): TPascalTypeShaperClass;
    class function CreateShaper(AFont: TCustomPascalTypeFontFace; const Script: TTableType): TPascalTypeShaper;
    class procedure RegisterDefaultShaperClass(ShaperClass: TPascalTypeShaperClass);

    function TextToGlyphs(const AText: string): TPascalTypeGlyphString; overload;
    function TextToGlyphs(const UTF32: TPascalTypeCodePoints): TPascalTypeGlyphString; overload; virtual;

    function Shape(const AText: string): TPascalTypeGlyphString; overload;
    function Shape(const UTF32: TPascalTypeCodePoints): TPascalTypeGlyphString; overload; virtual;
    procedure Shape(AGlyphs: TPascalTypeGlyphString); overload; virtual;

    property Font: TCustomPascalTypeFontFace read FFont;
    property Script: TTableType read FScript write SetScript;
    property Language: TTableType read FLanguage write SetLanguage;
    property Direction: TPascalTypeDirection read GetDirection write SetDirection;

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
  PascalType.Tables.OpenType.Substitution;

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
  FScript := OpenTypeScript.DefaultScript;
  FLanguage := OpenTypeDefaultLanguageSystem;
  FDirection := PascalTypeDefaultDirection;

  FFeatures := TPascalTypeShaperFeatures.Create;
  TPascalTypeShaperFeaturesCracker(FFeatures).OnChanged := FeaturesChanged;

  // Cache GSUB & GPOS. We'll use it a lot
  FSubstitutionTable := TOpenTypeGlyphSubstitutionTable(IPascalTypeFontFace(FFont).GetTableByTableType(TOpenTypeGlyphSubstitutionTable.GetTableType));
  FPositionTable := TOpenTypeGlyphPositionTable(IPascalTypeFontFace(FFont).GetTableByTableType(TOpenTypeGlyphPositionTable.GetTableType));
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

class procedure TPascalTypeShaper.RegisterShaperForScript(const Script: TTableType; AShaperClass: TPascalTypeShaperClass);
begin
  FShaperClasses.AddOrSetValue(Script.AsCardinal, AShaperClass);
end;

class function TPascalTypeShaper.GetShaperClass(const Script: TTableType): TPascalTypeShaperClass;
begin
  if (not FShaperClasses.TryGetValue(Script.AsCardinal, Result)) then
    Result := FDefaultShaperClass;
end;

class function TPascalTypeShaper.CreateShaper(AFont: TCustomPascalTypeFontFace; const Script: TTableType): TPascalTypeShaper;
var
  ShaperClass: TPascalTypeShaperClass;
begin
  ShaperClass := GetShaperClass(Script);
  if (ShaperClass = nil) then
    raise EPascalTypeError.CreateFmt('No shaper available for "%s"', [Script.AsString]);

  Result := ShaperClass.Create(AFont);
end;

class function TPascalTypeShaper.DetectScript(const AText: string): TTableType;
var
  UTF32: TPascalTypeCodePoints;
begin
  UTF32 := PascalTypeUnicode.UTF16ToUTF32(AText);
  Result := DetectScript(UTF32);
end;

class function TPascalTypeShaper.DetectScript(const UTF32: TPascalTypeCodePoints): TTableType;
var
  CodePoint: TPascalTypeCodePoint;
  UnicodeScript: TUnicodeScript;
begin
  for CodePoint in UTF32 do
  begin
    UnicodeScript := PascalTypeUnicode.GetScript(CodePoint);

    if (UnicodeScript <> usZzzz) and (UnicodeScript <> usZyyy) and (UnicodeScript <> usZinh) then
    begin
      Result := OpenTypeScript.UnicodeScriptToOpenTypeScript(UnicodeScript);
      exit;
    end;
  end;

  Result := OpenTypeScript.DefaultScript;
end;

procedure TPascalTypeShaper.FeaturesChanged(Sender: TObject);
begin
  Reset;
end;

procedure TPascalTypeShaper.Reset;
begin
  FreeAndNil(FPlan);
end;

function TPascalTypeShaper.CreateGlyphString(const ACodePoints: TPascalTypeCodePoints): TFontGlyphString;
begin
  Result := Font.CreateGlyphString(ACodePoints);

  Result.Script := Script;
  Result.Language := Language;
  Result.Direction := Direction;
end;

function TPascalTypeShaper.CreateLayoutEngine: TCustomPascalTypeLayoutEngine;
begin
  Result := Font.CreateLayoutEngine as TCustomPascalTypeLayoutEngine;
end;

function TPascalTypeShaper.GetDirection: TPascalTypeDirection;
var
  UnicodeScript: TUnicodeScript;
begin
  Result := FDirection;

  if (Result = dirDefault) then
  begin
    if (FScript.AsCardinal = 0) then
      Exit(dirLeftToRight);

    UnicodeScript := PascalTypeUnicode.ISO15924ToScript(FScript.AsString);

    if PascalTypeUnicode.IsRightToLeft(UnicodeScript) then
      Result := dirRightToLeft
    else
      Result := dirLeftToRight;
  end;
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
  // Harfbuzz by default doesn't compose

  // TODO : I believe Harfbuzz has now been changed to work on composed Unicode; Investigate.
  // See:
  // - Issue #56 Shape composed or decomposed Unicode
  //   https://gitlab.com/anders.bo.melander/pascaltype2/-/issues/56

  Result := False;
end;

function TPascalTypeShaper.NormalizationFilter(CodePoint: TPascalTypeCodePoint): boolean;
begin
  // Do not reorder if codepoiont is a mark
//  Result := not PascalTypeUnicode.IsMark(CodePoint);
  Result := not PascalTypeUnicode.IsDiacritic(CodePoint);
end;

function TPascalTypeShaper.CompositionFilter(FirstCodePoint, SecondCodePoint: TPascalTypeCodePoint; var Composite: TPascalTypeCodePoint): boolean;
begin
  // Harfbuzz doesn't compose a starter with a non-mark.
  if (not PascalTypeUnicode.IsMark(FirstCodePoint)) and (not PascalTypeUnicode.IsMark(SecondCodePoint)) then
    Exit(False);

  // Lookup codepoint in font.
  // Reject if font doesn't contain a glyph for the codepoint
  Result := Font.HasGlyphByCodePoint(Composite);
end;

function TPascalTypeShaper.DecompositionFilter(Composite: TPascalTypeCodePoint; CodePoint: TPascalTypeCodePoint): boolean;
begin
  if (CodePoint = 0) then
  begin
    // Prefiltering
    case Composite of
      $0931: Result := False; // devanagari letter rra
      $09DC: Result := False; // bengali letter rra
      $09DD: Result := False; // bengali letter rha
      $0B94: Result := False; // tamil letter au
    else
      Result := True;
    end;
  end else
  begin
    // Decomposition filtering
    Result := Font.HasGlyphByCodePoint(CodePoint);
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
        if (Font.HasGlyphByCodePoint($2010)) then
          CodePoint := $2010 // hyphen
        else
        if (Font.HasGlyphByCodePoint($002D)) then
          CodePoint := $002D; // hyphen-minus
    else
      // TODO : Harfbuzz stores the space type for later use. I don't know the purpose of this yet.
      // Actually, I don't even know the purpose of replacing "blank" codepoints in the first place...
      if (PascalTypeUnicode.IsBlank(CodePoint)) and (PascalTypeUnicode.GetSpaceType(CodePoint) <> ustNOT_SPACE) and
        (Font.HasGlyphByCodePoint($0020)) then
          // TODO : We probably need to handle the difference in width
          CodePoint := $0020; // Regular space
    end;
  end;

var
  i: integer;
begin
  for i := Low(CodePoints) to High(CodePoints) do
    ProcessCodePoint(CodePoints[i]);
end;

function TPascalTypeShaper.ProcessUnicode(const UTF32: TPascalTypeCodePoints): TPascalTypeCodePoints;
begin
  (*
  ** Unicode decompose
  *)
  Result := PascalTypeUnicode.Decompose(UTF32, DecompositionFilter);

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
  // TODO : If the font doesn't contain one or both of the decomposed
  // codepoints but does contain the composed codepoint, should we
  // fall back to composing the particular pair?
  if (NeedUnicodeComposition) then
  begin
    Result := PascalTypeUnicode.Compose(Result, CompositionFilter);

    PascalTypeUnicode.Normalize(Result, NormalizationFilter);
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

procedure TPascalTypeShaper.SetupPlan(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString; AFeatures: TPascalTypeShaperFeatures);
begin
end;

function TPascalTypeShaper.Shape(const AText: string): TPascalTypeGlyphString;
var
  UTF32: TPascalTypeCodePoints;
begin
  UTF32 := PascalTypeUnicode.UTF16ToUTF32(AText);

  Result := Shape(UTF32);
end;

function TPascalTypeShaper.Shape(const UTF32: TPascalTypeCodePoints): TPascalTypeGlyphString;
begin
  (*
  ** Convert from Unicode codepoints to glyph IDs.
  *)
  Result := TextToGlyphs(UTF32);
  try

    (*
    ** Shape glyphs.
    *)
    Shape(Result);

  except
    Result.Free;
    raise;
  end;
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

function TPascalTypeShaper.TextToGlyphs(const UTF32: TPascalTypeCodePoints): TPascalTypeGlyphString;
var
  Normalized: TPascalTypeCodePoints;
begin
  (*
  ** Unicode normalization-
  *)
  Normalized := ProcessUnicode(UTF32);

  (*
  ** Convert from Unicode codepoints to glyph IDs.
  *)
  Result := CreateGlyphString(Normalized);
end;

function TPascalTypeShaper.TextToGlyphs(const AText: string): TPascalTypeGlyphString;
var
  UTF32: TPascalTypeCodePoints;
begin
  (*
  ** Convert UTF16 unicode string to UCS-4/UTF32 unicode string
  *)
  UTF32 := PascalTypeUnicode.UTF16ToUTF32(AText);

  (*
  ** Normalize and convert from Unicode codepoints to glyph IDs.
  *)
  Result := TextToGlyphs(UTF32);
end;

function TPascalTypeShaper.ZeroMarkWidths: TZeroMarkWidths;
begin
  Result := zmwAfterPositioning;
end;

//------------------------------------------------------------------------------

end.
