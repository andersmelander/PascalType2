unit PascalType.Unicode;

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


//------------------------------------------------------------------------------
//
//              TPascalTypeCodePoint
//
//------------------------------------------------------------------------------
// A Unicode 2.0 codepoint - 32 bits wide
//------------------------------------------------------------------------------
type
  // A Unicode code point
  TPascalTypeCodePoint = Cardinal;

  TPascalTypeCodePoints = array of TPascalTypeCodePoint;


//------------------------------------------------------------------------------
//
//              Normalization filter
//
//------------------------------------------------------------------------------
// Used both by decomposition and composition.
//
// - Decomposition:
//   Returns True if the codepoint should be decomposed, False if it should kept
//   as-is.
//
// - Composition:
//   Returns True if the composed codepoint can be used, False if the decomposed
//   characters should be kept as-is.
//------------------------------------------------------------------------------
type
  TCodePointFilter = reference to function(CodePoint: TPascalTypeCodePoint): boolean;


type
  PascalTypeUnicode = record

    //------------------------------------------------------------------------------
    //
    //              Normalization
    //
    //------------------------------------------------------------------------------
    // UnicodeDecompose: Decomposes and normalizes.
    // UnicodeCompose: Composes. It is assumed that the input has already been normalized.
    //------------------------------------------------------------------------------
    class function Decompose(const AString: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints; static;
    class function Compose(const AString: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints; static;


    //------------------------------------------------------------------------------
    //
    //              String conversion
    //
    //------------------------------------------------------------------------------
    // Convert between 16-bit Unicode (native char/string) and 32-bit Unicode
    //------------------------------------------------------------------------------
    class function UTF16ToUTF32(const AText: string): TPascalTypeCodePoints; static;
    class function UTF32ToUTF16(const AText: TPascalTypeCodePoints): string; static;


    //------------------------------------------------------------------------------
    //
    //              Categorization
    //
    //------------------------------------------------------------------------------
    class function IsWhiteSpace(const AChar: TPascalTypeCodePoint): boolean; static;
    class function IsMark(const AChar: TPascalTypeCodePoint): boolean; static;
    class function IsDefaultIgnorable(const AChar: TPascalTypeCodePoint): boolean; static;

  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
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
// Redirect incorrect PUCU types
type
  TPUCUUTF32Char = TPascalTypeCodePoint;        // PUCU declares it as LongInt. We need it to be Cardinal.
  TPUCUUTF32String = TPascalTypeCodePoints;     //
  TPUCUInt32 = integer;                         // PUCU declares it as LongInt. We need it to be Integer.

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
  CodePointClass, LastClass: TPUCUInt32;
  CodePoint: TPUCUUTF32Char;
  StartCodePoint: TPUCUUTF32Char;
  CompositeCodePoint: TPUCUUTF32Char;
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

      // Filter codepoint
      if (Assigned(Filter)) and (not Filter(CodePoint)) then
      begin
        // Keep codepoint composed
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
        // Filter codepoint
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

//------------------------------------------------------------------------------
//
//              Decompose
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.Decompose(const AString: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints;
begin
  Result := PUCUNormalize32(AString, False, Filter);
end;

//------------------------------------------------------------------------------
//
//              Compose
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.Compose(const AString: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints;
begin
  Result := PUCUNormalize32(AString, True, Filter);
end;


//------------------------------------------------------------------------------
//
//              String conversion
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.UTF16ToUTF32(const AText: string): TPascalTypeCodePoints;
var
  UTF32: PUCU.TPUCUUTF32String absolute Result; // Dirty hack but we know they are the same
begin
  Assert(SizeOf(UTF32[0]) = SizeOf(Result[0]));
  UTF32 := PUCUUTF16ToUTF32(AText);
end;

class function PascalTypeUnicode.UTF32ToUTF16(const AText: TPascalTypeCodePoints): string;
var
  UTF32: PUCU.TPUCUUTF32String absolute AText; // Dirty hack but we know they are the same
begin
  Assert(SizeOf(UTF32[0]) = SizeOf(AText[0]));
  Result := PUCUUTF32ToUTF16(UTF32);
end;


//------------------------------------------------------------------------------
//
//              Categorization
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.IsMark(const AChar: TPascalTypeCodePoint): boolean;
begin
  Result := (PUCUUnicodeGetCategoryFromTable(AChar) in [PUCUUnicodeCategoryMn, PUCUUnicodeCategoryMe, PUCUUnicodeCategoryMc]);
end;

class function PascalTypeUnicode.IsWhiteSpace(const AChar: TPascalTypeCodePoint): boolean;
begin
  Result := PUCUUnicodeIsWhiteSpace(AChar);
end;

class function PascalTypeUnicode.IsDefaultIgnorable(const AChar: TPascalTypeCodePoint): boolean;
var
  UnicodePlane: Word;
begin
  // From DerivedCoreProperties.txt in the Unicode database,
  // minus U+115F, U+1160, U+3164 and U+FFA0, which is what
  // Harfbuzz and Uniscribe do.
  UnicodePlane := AChar shr 16;
  if (UnicodePlane = 0) then
  begin
    // BMP
    case AChar shr 8 of
      $00: Result := (AChar = $00AD);
      $03: Result := (AChar = $034F);
      $06: Result := (AChar = $061C);
      $17: Result := (AChar >= $17B4) and (AChar <= $17B5);
      $18: Result := (AChar >= $180B) and (AChar <= $180E);
      $20: Result := ((AChar >= $200B) and (AChar <= $200F)) or ((AChar >= $202A) and (AChar <= $202E)) or ((AChar >= $2060) and (AChar <= $206F));
      $FE: Result := (AChar >= $FE00) and (AChar <= $FE0F) or (AChar = $FEFF);
      $FF: Result := (AChar >= $FFF0) and (AChar <= $FFF8);
    else
      Result := False;
    end;
  end else
  begin
    // Other planes
    case UnicodePlane of
      $01: Result := ((AChar >= $1BCA0) and (AChar <= $1BCA3)) or ((AChar >= $1D173) and (AChar <= $1D17A));
      $0E: Result := (AChar >= $E0000) and (AChar <= $E0FFF);
    else
      Result := False;
    end;
  end;
end;

end.
