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
  PascalType.FontFace.SFNT;


//------------------------------------------------------------------------------
//
//              TPascalTypeShaper
//
//------------------------------------------------------------------------------
type
  TPascalTypeShaper = class
  private
    FFont: TCustomPascalTypeFontFace;
  protected
    function DecompositionFilter(CodePoint: Cardinal): boolean; virtual;
    procedure ProcessCodePoint(var CodePoint: Cardinal); virtual;
    function CompositionFilter(CodePoint: Cardinal): boolean; virtual;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace);

    function NormalizeText(const AText: string): string; virtual;
  end;

implementation

uses
  Windows,
  SysUtils,

  PUCU;

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
          // TODO
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
function TPascalTypeShaper.CompositionFilter(CodePoint: Cardinal): boolean;
begin
  // Lookup codepoint in font.
  // Reject if font doesn't contain a glyph for the codepoint
  Result := (FFont.GetGlyphByCharacter(CodePoint) <> 0);
end;

constructor TPascalTypeShaper.Create(AFont: TCustomPascalTypeFontFace);
begin
  inherited Create;
  FFont := AFont;
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

procedure TPascalTypeShaper.ProcessCodePoint(var CodePoint: Cardinal);
begin
  case CodePoint of
    $2011: // non-breaking hyphen
      // According to:
      //   https://github.com/n8willis/opentype-shaping-documents/blob/master/opentype-shaping-normalization.md
      // the "non-breaking hyphen" character should be replaced with "hyphen". However that
      // just end up displaying the character as "a box".
      // Replacing it with a regular simple hyphen ("hyphen minus") will work though.
      // TODO : Revisit once full substitution has been implemented.
      // CodePoint := $2010; // hyphen
      CodePoint := $002D; // hyphen-minus
  end;
end;

function TPascalTypeShaper.NormalizeText(const AText: string): string;
var
  UTF32: TPUCUUTF32String;
  CodePoint: Cardinal;
  i: integer;
begin
  UTF32 := PUCUUTF16ToUTF32(AText);

  // Decompose and normalize
  UTF32 := PUCUNormalize32(UTF32, False, DecompositionFilter);

  // Process individual codepoints
  for i := 0 to High(UTF32) do
  begin
    CodePoint := UTF32[i];
    ProcessCodePoint(CodePoint);
    UTF32[i] := CodePoint;
  end;

  // Compose
  UTF32 := PUCUNormalize32(UTF32, True, CompositionFilter);

  Result := PUCUUTF32ToUTF16(UTF32);
end;

//------------------------------------------------------------------------------

end.
