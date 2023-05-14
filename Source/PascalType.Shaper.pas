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
    function DecompositionFilter(CodePoint: Cardinal): boolean; virtual;
    procedure ProcessCodePoint(var CodePoint: Cardinal); virtual;
    function CompositionFilter(CodePoint: Cardinal): boolean; virtual;
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
  Windows,
  Character,
  SysUtils,

  PUCU,

  PascalType.Tables.OpenType.Script,
  PascalType.Tables.OpenType.LanguageSystem,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Substitution;

{$ifdef WIN32_NORMALIZESTRING}
type
  TNormalization = (
    NormalizationOther    = 0,
    NormalizationC        = 1,
    NormalizationD        = 2,
    NormalizationKC       = 5,
    NormalizationKD       = 6
  );

type
  NORM_FORM = Cardinal;
  TNormForm = NORM_FORM;

function NormalizeString(NormForm: TNormForm; lpSrcString: PWideChar; cwSrcLength: Integer; lpDstString: PWideChar; cwDstLength: Integer): Integer; stdcall; external 'normaliz.dll';

function Normalize(Normalization: TNormalization; const AText: string): string;
begin
  var Size := NormalizeString(Ord(Normalization), PChar(AText), Length(AText), nil, 0);
  if (Size <= 0) and (GetLastError <> ERROR_INSUFFICIENT_BUFFER) then
    RaiseLastOSError;

  while (True) do
  begin
    SetLength(Result, Size);

    Size := NormalizeString(Ord(Normalization), PChar(AText), Length(AText), PChar(Result), Size);

    if (Size > 0) then
    begin
      SetLength(Result, Size);
      break
    end;

    if (GetLastError <> ERROR_INSUFFICIENT_BUFFER) then
      RaiseLastOSError;

    Size := -Size;
  end;
end;
{$endif WIN32_NORMALIZESTRING}

//------------------------------------------------------------------------------
//
//              PUCUNormalize32
//
//------------------------------------------------------------------------------
// Based on PUCUUTF32Normalize from the PUCU library
//------------------------------------------------------------------------------
type
  TCodePointFilter = reference to function(CodePoint: Cardinal): boolean;

function PUCUNormalize32(const AString: TPUCUUTF32String; const ACompose: boolean; Filter: TCodePointFilter = nil): TPUCUUTF32String;

  procedure SetCodePoint(AIndex: integer; const ACodePoint: TPUCUUTF32Char);
  begin
    if (AIndex > Length(Result)-1) then
      // Grow output buffer exponentially
      SetLength(Result, (AIndex + 1) * 2);

    Result[AIndex] := ACodePoint;
  end;

  procedure AddCodePoint(var AIndex: integer; const ACodePoint: TPUCUUTF32Char);
  begin
    SetCodePoint(AIndex, ACodePoint);
    Inc(AIndex);
  end;

var
  Len: integer;
  Index, SubIndex, StartIndex, EndIndex, TargetIndex: integer;
  DecompositionTableStartIndex: integer;
  DecompositionTableItemLength: integer;
  CompositionSequenceIndex: integer;
  CodePointClass, LastClass: integer; //TPUCUInt32;
  CodePoint: Cardinal;//TPUCUUTF32Char;
  StartCodePoint: Cardinal; // TPUCUUTF32Char;
  CompositeCodePoint: Cardinal; // TPUCUUTF32Char;
  CharacterCompositionSequence: PPUCUUnicodeCharacterCompositionSequence;
begin

  SetLength(Result, Length(AString));

  if (Length(AString) = 0) then
    Exit;

  Len := 0;

  (*
  ** Decompose
  *)
  if not ACompose then
  begin
    for Index := 0 to Length(AString) - 1 do
    begin
      CodePoint := AString[Index];

      if (Assigned(Filter)) and (not Filter(CodePoint)) then
      begin
        AddCodePoint(Len, CodePoint);
        continue;
      end;

      case CodePoint of
        $AC00 .. $D7A4: // Hangul
          begin
            CodePoint := CodePoint - $AC00;
            AddCodePoint(Len, $1100 + (CodePoint div 588));
            AddCodePoint(Len, $1161 + ((CodePoint mod 588) div 28));
            CodePoint := CodePoint mod 28;
            if (CodePoint <> 0) then
              AddCodePoint(Len, CodePoint + $11A7);
          end;
      else
        DecompositionTableStartIndex := PUCUUnicodeGetDecompositionStartFromTable(CodePoint);

        if (DecompositionTableStartIndex > 0) then
        begin
          DecompositionTableItemLength := (DecompositionTableStartIndex shr 14) + 1;
          DecompositionTableStartIndex := DecompositionTableStartIndex and ((1 shl 14) - 1);
          for SubIndex := 0 to DecompositionTableItemLength - 1 do
            AddCodePoint(Len, PUCUUnicodeDecompositionSequenceArrayData[DecompositionTableStartIndex + SubIndex]);
        end else
          AddCodePoint(Len, CodePoint);
      end;
    end;

    // Truncate output buffer
    SetLength(Result, Len);

    (*
    ** Normalize
    *)
    StartIndex := 0;
    while (StartIndex < Length(Result)) do
    begin
      if PUCUUnicodeGetCanonicalCombiningClassFromTable(Result[StartIndex]) = 0 then
      begin
        Inc(StartIndex);
        continue;
      end;

      EndIndex := StartIndex + 1;
      while (EndIndex < Length(Result)) and (PUCUUnicodeGetCanonicalCombiningClassFromTable(Result[EndIndex]) <> 0) do
        Inc(EndIndex);

      if (EndIndex - StartIndex > 1) then
      begin
        Index := StartIndex;

        // Looks like bubblesort...?
        while (Index  < EndIndex-1) do
        begin
          if PUCUUnicodeGetCanonicalCombiningClassFromTable(Result[Index]) >= PUCUUnicodeGetCanonicalCombiningClassFromTable(Result[Index + 1]) then
          begin
            CodePoint := Result[Index];
            Result[Index] := Result[Index + 1];
            Result[Index + 1] := CodePoint;

            if (Index > StartIndex) then
              Dec(Index)
            else
              Inc(Index);
          end else
            Inc(Index);
        end;
      end;

      StartIndex := EndIndex + 1;
    end;
  end else
    // Assume input is already decomposed and normalized
    Result := Copy(AString);

  (*
  ** Compose
  *)
  if ACompose then
  begin
    Index := 1;
    LastClass := -1;
    StartIndex := 0;
    TargetIndex := 1;

    StartCodePoint := Result[0];

    while (Index < Length(Result)) do
    begin
      CodePoint := Result[Index];
      CodePointClass := PUCUUnicodeGetCanonicalCombiningClassFromTable(CodePoint);

      if (StartCodePoint >= $1100) and (StartCodePoint < $1113) and (CodePoint >= $1161) and (CodePoint < $1176) then
        CompositeCodePoint := (((((StartCodePoint - $1100) * 21) + CodePoint) - $1161) * 28) + $AC00
      else
      if (StartCodePoint >= $AC00) and (StartCodePoint < $D7A4) and (((StartCodePoint - $AC00) mod 28) = 0) and (CodePoint >= $11A8) and (CodePoint < $11C3) then
        CompositeCodePoint := (StartCodePoint + CodePoint) - $11A7
      else
      begin
        CompositeCodePoint := 0;
        CompositionSequenceIndex :=
          PUCUUnicodeCharacterCompositionHashTableData[
            // Note: Promotion to 64-bit to avoid integer overflow
            TPUCUUInt32((TPUCUUInt64(StartCodePoint) * 98303927) xor (TPUCUUInt64(CodePoint) * 24710753)) and PUCUUnicodeCharacterCompositionHashTableMask
            ];

        while (CompositionSequenceIndex > 0) and (CompositionSequenceIndex < PUCUUnicodeCharacterCompositionSequenceCount) do
        begin
          CharacterCompositionSequence := @PUCUUnicodeCharacterCompositionSequences[CompositionSequenceIndex];
          if (longword(CharacterCompositionSequence^.Sequence[0]) = longword(StartCodePoint)) and
            (longword(CharacterCompositionSequence^.Sequence[1]) = longword(CodePoint)) then
          begin
            CompositeCodePoint := CharacterCompositionSequence^.CodePoint;
            break;
          end else
            CompositionSequenceIndex := PUCUUnicodeCharacterCompositionSequences[CompositionSequenceIndex].Next;
        end;
      end;

      if (CompositeCodePoint <> 0) and (LastClass < CodePointClass) then
      begin
        if (not Assigned(Filter)) or (Filter(CompositeCodePoint)) then
        begin
          SetCodePoint(StartIndex, CompositeCodePoint);
          StartCodePoint := CompositeCodePoint;
        end else
        begin
          // Do not recompose the codepoints. Add them decomposed instead.
          // TODO : Verify that this is correct
          Inc(StartIndex);
          Inc(TargetIndex);
          StartCodePoint := CodePoint;
          LastClass := -1;
        end;
      end else
      if (CodePointClass = 0) then
      begin
        StartIndex := TargetIndex;
        StartCodePoint := CodePoint;
        LastClass := -1;

        AddCodePoint(TargetIndex, CodePoint);
      end else
      begin
        LastClass := CodePointClass;

        AddCodePoint(TargetIndex, CodePoint);
      end;

      Inc(Index);
    end;

    SetLength(Result, TargetIndex);
  end;

end;

(*
function PUCUNormalize(const AText: string; const ACompose: boolean): string;
var
  UTF32: TPUCUUTF32String;
begin
  UTF32 := PUCUUTF16ToUTF32(AText);
  UTF32 := PUCUNormalize32(UTF32, ACompose, DecompositionFilter);
  Result := PUCUUTF32ToUTF16(UTF32);
end;
*)

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

function TPascalTypeShaper.CompositionFilter(CodePoint: Cardinal): boolean;
begin
  // Lookup codepoint in font.
  // Reject if font doesn't contain a glyph for the codepoint
  Result := Font.HasGlyphByCharacter(CodePoint);
end;

function TPascalTypeShaper.DecompositionFilter(CodePoint: Cardinal): boolean;
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

procedure TPascalTypeShaper.ProcessCodePoint(var CodePoint: Cardinal);
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
    // TODO : Find out when TCharacter was deprecated
{$if defined(TCHARACTER_DEPRECATED)}
    if (Char(CodePoint).IsWhiteSpace(CodePoint)) then
{$else TCHARACTER_DEPRECATED}
    if (TCharacter.IsWhiteSpace(CodePoint)) then
{$ifend TCHARACTER_DEPRECATED}
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
  UTF32: TPUCUUTF32String;
  CodePoint: Cardinal;
  i, j: integer;
  FeatureTable: TCustomOpenTypeFeatureTable;
  Feature: TTableName;
  LookupTable: TCustomOpenTypeLookupTable;
  GlyphIndex, NextGlyphIndex: integer;
  GlyphHandled: boolean;
  Glyph: TPascalTypeGlyph;
const
  Features: array of TTableName =
    ['ccmp', 'locl'];
begin
  UTF32 := PUCUUTF16ToUTF32(AText);

  (*
  ** Unicode decompose and normalization
  *)
  UTF32 := PUCUNormalize32(UTF32, False, DecompositionFilter);


  (*
  ** Process individual codepoints
  *)
  for i := 0 to High(UTF32) do
  begin
    CodePoint := UTF32[i];
    ProcessCodePoint(CodePoint);
    UTF32[i] := CodePoint;
  end;


  (*
  ** Unicode composition
  *)
  UTF32 := PUCUNormalize32(UTF32, True, CompositionFilter);


  (*
  ** From here on we are done with Unicode codepoints and are working with glyph IDs.
  *)
  Result := CreateGlyphString;
  try
    Result.SetLength(Length(UTF32));

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


    (*
    ** Post-processing: Normalization-related GSUB features and other font-specific considerations
    *)
    if (FSubstitutionTable <> nil) then
    for Feature in Features do
    begin
      FeatureTable := FindFeature(Feature);

      if (FeatureTable <> nil) then
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
            // This also handles advancement if the substitution forget to do it
            Inc(GlyphIndex);
        end;
      end;
    end;

  except
    Result.Free;
    raise;
  end;
end;

//------------------------------------------------------------------------------

end.
