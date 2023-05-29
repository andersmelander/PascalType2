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
  Generics.Collections,
  PT_Types,
  PT_Classes,
  PascalType.Unicode,
  PascalType.GlyphString,
  PascalType.FontFace.SFNT,
  PascalType.Tables.OpenType.GSUB,
  PascalType.Tables.OpenType.Feature;


//------------------------------------------------------------------------------
//
//              TPascalTypeShaper
//
//------------------------------------------------------------------------------
type
  TPascalTypeShaper = class
  private
    FScript: TTableType;
    FLanguage: TTableType;
    FFont: TCustomPascalTypeFontFace;
    FFeatures: TDictionary<TTableType, TCustomOpenTypeFeatureTable>;
    FSubstitutionTable: TOpenTypeGlyphSubstitutionTable;
    procedure SetLanguage(const Value: TTableType);
    procedure SetScript(const Value: TTableType);
  protected
    procedure Reset; virtual;
    function DecompositionFilter(CodePoint: TPascalTypeCodePoint): boolean; virtual;
    procedure ProcessCodePoint(var CodePoint: TPascalTypeCodePoint); virtual;
    function CompositionFilter(CodePoint: TPascalTypeCodePoint): boolean; virtual;
    function FindFeature(const ATableType: TTableType): TCustomOpenTypeFeatureTable;

    function CreateGlyphString: TPascalTypeGlyphString; virtual;
    function GetGlyphStringClass: TPascalTypeGlyphStringClass; virtual;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace);
    destructor Destroy; override;

    function Shape(const AText: string): TPascalTypeGlyphString; virtual;

    property Language: TTableType read FLanguage write SetLanguage;
    property Script: TTableType read FScript write SetScript;
    property Font: TCustomPascalTypeFontFace read FFont;
  end;

implementation

uses
  SysUtils,

  PascalType.Tables.OpenType.Script,
  PascalType.Tables.OpenType.LanguageSystem,
  PascalType.Tables.OpenType.Lookup,
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
  // Cache GSUB. We'll use it a lot
  FSubstitutionTable := TOpenTypeGlyphSubstitutionTable(IPascalTypeFontFace(FFont).GetTableByTableType(TOpenTypeGlyphSubstitutionTable.GetTableType));
end;

destructor TPascalTypeShaper.Destroy;
begin
  FFeatures.Free;

  inherited;
end;

function TPascalTypeShaper.CreateGlyphString: TPascalTypeGlyphString;
begin
  Result := GetGlyphStringClass.Create;
end;

function TPascalTypeShaper.GetGlyphStringClass: TPascalTypeGlyphStringClass;
begin
  Result := TPascalTypeGlyphString;
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

function TPascalTypeShaper.FindFeature(const ATableType: TTableType): TCustomOpenTypeFeatureTable;
var
  i: integer;
  ScriptTable: TCustomOpenTypeScriptTable;
  LanguageSystem: TCustomOpenTypeLanguageSystemTable;
  FeatureTable: TCustomOpenTypeFeatureTable;
begin
  if (FFeatures = nil) then
  begin
    FFeatures := TDictionary<TTableType, TCustomOpenTypeFeatureTable>.Create;

    if (FSubstitutionTable <> nil) then
    begin
      // Get script, fallback to default
      ScriptTable := FSubstitutionTable.ScriptListTable.FindScript(Script, True);

      if (ScriptTable <> nil) then
      begin
        // Get language system, fallback to default
        LanguageSystem := ScriptTable.FindLanguageSystem(Language, True);

        if (LanguageSystem <> nil) then
        begin
          for i := 0 to LanguageSystem.FeatureIndexCount-1 do
          begin
            // LanguageSystem feature list contains index numbers into the FeatureListTable
            FeatureTable := FSubstitutionTable.FeatureListTable.Feature[LanguageSystem.FeatureIndex[i]];
            FFeatures.Add(FeatureTable.TableType, FeatureTable);
          end;
        end;
      end;
    end;
  end;

  if (not FFeatures.TryGetValue(ATableType, Result)) then
    Result := nil;
end;

procedure TPascalTypeShaper.ProcessCodePoint(var CodePoint: TPascalTypeCodePoint);
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

procedure TPascalTypeShaper.Reset;
begin
  FreeAndNil(FFeatures);
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

function TPascalTypeShaper.Shape(const AText: string): TPascalTypeGlyphString;
var
  UTF32: TPascalTypeCodePoints;
  i, j: integer;
  FeatureTable: TCustomOpenTypeFeatureTable;
  Feature: TTableName;
  LookupTable: TCustomOpenTypeLookupTable;
  GlyphIndex, NextGlyphIndex: integer;
  GlyphHandled: boolean;
  Glyph: TPascalTypeGlyph;
  Features: TList<TCustomOpenTypeFeatureTable>;
const
  DefaultFeatures: array of TTableName = [
    'ccmp',     // Glyph Composition/Decomposition
    'clig',     // Contextual Ligatures
    'liga',     // Standard Ligatures
    'locl',     // Localized Forms
    'calt'      // Contextual Alternates
  ];
begin
  UTF32 := PascalTypeUnicode.UTF16ToUTF32(AText);

  (*
  ** Unicode decompose and normalization
  *)
  UTF32 := PascalTypeUnicode.Decompose(UTF32, DecompositionFilter);


  (*
  ** Process individual codepoints
  *)
  for i := 0 to High(UTF32) do
    ProcessCodePoint(UTF32[i]);


  (*
  ** Unicode composition
  *)
  UTF32 := PascalTypeUnicode.Compose(UTF32, CompositionFilter);


  Result := CreateGlyphString;
  try
    Result.SetLength(Length(UTF32));

    (*
    ** Convert from Unicode codepoints to glyph IDs.
    ** From here on we are done with Unicode codepoints and are working with glyph IDs.
    *)
    for i := 0 to High(UTF32) do
    begin
      Glyph := Result[i];
      Glyph.CodePoints := [UTF32[i]];
      Glyph.GlyphID := Font.GetGlyphByCharacter(Result[i].CodePoints[0]);
      Glyph.Group := i;

      // DONE : TPascalTypeGlyph and TPascalTypeGlyphString should be objects created by the shaper.
      // The individual shaper may have need to store information in the string and glyph that can not be generalized.
      // function TCustomPascalTypeShaper.CreateGlyphString: TCustomPascalTypeGlyphString;
      // function TCustomPascalTypeGlyphString.CreateGlyph: TCustomPascalTypeGlyph;
    end;

    SetLength(UTF32, 0);


    (*
    ** Post-processing: Normalization-related GSUB features and other font-specific considerations
    *)
    if (FSubstitutionTable <> nil) then
    begin
      Features := TList<TCustomOpenTypeFeatureTable>.Create;
      try

        // Build ordered list of features supported by the font
        // TODO : This should only be done once per "session". No need to do it once per character.
        // TODO : Apply options. Some features are optional. Other are mandatory. E.g. 'liga' is optional.
        for Feature in DefaultFeatures do
        begin
          FeatureTable := FindFeature(Feature);

          if (FeatureTable <> nil) then
            Features.Add(FeatureTable);
        end;

        // Iterate over each feature and apply it to the individual glyphs.
        // Each glyph is only processed once by a feature, but it can be
        // processed multiple times by different features.
        for FeatureTable in Features do
        begin

          GlyphIndex := 0;
          while (GlyphIndex < Result.Count) do
          begin
            GlyphHandled := False;
            NextGlyphIndex := GlyphIndex;

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
              LookupTable := FSubstitutionTable.LookupListTable.LookupTables[FeatureTable.LookupList[i]];

              for j := 0 to LookupTable.SubTableCount-1 do
                if (LookupTable.SubTables[j] is TCustomOpenTypeSubstitutionSubTable) then
                begin
                  if (TCustomOpenTypeSubstitutionSubTable(LookupTable.SubTables[j]).Substitute(Result, NextGlyphIndex)) then
                  begin
                    GlyphHandled := True;
                    break;
                  end;
                end;

              if (GlyphHandled) then
                break;
            end;

            if (GlyphHandled) and (NextGlyphIndex > GlyphIndex) then
              GlyphIndex := NextGlyphIndex
            else
              // This also handles advancement if the substitution forgot to do it
              Inc(GlyphIndex);
          end;
        end;

      finally
        Features.Free;
      end;
    end;

  except
    Result.Free;
    raise;
  end;
end;

//------------------------------------------------------------------------------

end.
