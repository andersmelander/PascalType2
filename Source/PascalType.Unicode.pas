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

// Select Unicode library. One of these must be defined.
{.$define UNICODE_PUCU}
{$define UNICODE_JEDI}

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

  TPascalTypeCodePoints = TArray<TPascalTypeCodePoint>;


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
    class procedure Normalize(ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil); static;
    class function Decompose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints; static;
    class function Compose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints; static;


    //------------------------------------------------------------------------------
    //
    //              String conversion
    //
    //------------------------------------------------------------------------------
    // Convert between 16-bit Unicode (native char/string) and 32-bit Unicode
    //------------------------------------------------------------------------------
    class function UTF16ToUTF32(const AText: string): TPascalTypeCodePoints; static;
    class function UTF32ToUTF16(const ACodePoints: TPascalTypeCodePoints): string; static;


    //------------------------------------------------------------------------------
    //
    //              Categorization
    //
    //------------------------------------------------------------------------------
    class function IsDigit(const ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsWhiteSpace(const ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsMark(const ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsDefaultIgnorable(const ACodePoint: TPascalTypeCodePoint): boolean; static;

  private
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
{$if defined(UNICODE_PUCU)}
  ..\..\Source\Externals\pucu\src\PUCU;
{$elseif defined(UNICODE_JEDI)}
  jclUnicode;
{$else}
{$message fatal 'Missing Unicode implementation'}
{$ifend}

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

{$ifdef UNICODE_PUCU}
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

function PUCUNormalize32(const ACodePoints: TPUCUUTF32String; const ACompose: boolean; Filter: TCodePointFilter = nil): TPUCUUTF32String;

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

  SetLength(Result, Length(ACodePoints));

  if (Length(ACodePoints) = 0) then
    Exit;

  Len := 0;

  (*
  ** Decompose
  *)
  if not ACompose then
  begin
    for Index := 0 to Length(ACodePoints) - 1 do
    begin
      CodePoint := ACodePoints[Index];

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
    Result := Copy(ACodePoints);

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
class function PascalTypeUnicode.Decompose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints;
begin
  Result := PUCUNormalize32(ACodePoints, False, Filter);
end;

//------------------------------------------------------------------------------
//
//              Compose
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.Compose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints;
begin
  Result := PUCUNormalize32(ACodePoints, True, Filter);
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
class function PascalTypeUnicode.IsMark(const ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := (PUCUUnicodeGetCategoryFromTable(ACodePoint) in [PUCUUnicodeCategoryMn, PUCUUnicodeCategoryMe, PUCUUnicodeCategoryMc]);
end;

class function PascalTypeUnicode.IsWhiteSpace(const ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := PUCUUnicodeIsWhiteSpace(ACodePoint);
end;

class function PascalTypeUnicode.IsDigit(const ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := (PUCUUnicodeGetCategoryFromTable(ACodePoint) = PUCUUnicodeCategoryNd);
end;
{$endif UNICODE_PUCU}


{$ifdef UNICODE_JEDI}
//------------------------------------------------------------------------------
//
//              Normalization
//
//------------------------------------------------------------------------------
class procedure PascalTypeUnicode.Normalize(ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter);
var
  StartIndex: integer;
  EndIndex: integer;
  Outer, Inner: integer;
  CodePoint: UCS4;
begin
  StartIndex := 0;
  while (StartIndex < Length(ACodePoints)) do
  begin
    // Find the start of a group. A group follows a codepoint[class=0] and contains one or more codepoint[class<>0].
    if CanonicalCombiningClass(ACodePoints[StartIndex]) = 0 then
    begin
      Inc(StartIndex);
      continue;
    end;

    // Find the end of the group
    EndIndex := StartIndex + 1;
    // OpenType: Do not reorder marks
    while (EndIndex < Length(ACodePoints)) and ((not Assigned(Filter)) or (Filter(ACodePoints[EndIndex]))) and (CanonicalCombiningClass(ACodePoints[EndIndex]) <> 0) do
      Inc(EndIndex);

    // There's nothing to reorder unless group has 2 or more codepoints in it
    if (EndIndex - StartIndex > 1) then
    begin
      // Bubble sort
      for Outer := EndIndex-1 downto StartIndex do
        for Inner := StartIndex to Outer-1 do
          if CanonicalCombiningClass(ACodePoints[Inner]) > CanonicalCombiningClass(ACodePoints[Inner+1]) then
          begin
            // Swap
            CodePoint := ACodePoints[Inner];
            ACodePoints[Inner] := ACodePoints[Inner + 1];
            ACodePoints[Inner + 1] := CodePoint;
          end;
    end;

    StartIndex := EndIndex + 1;
  end;
end;

//------------------------------------------------------------------------------
//
//              Decompose
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.Decompose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints;
begin
  Result := UnicodeDecompose(ACodePoints, False);//, Filter);
end;

//------------------------------------------------------------------------------
//
//              Compose
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.Compose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints;
begin
  Result := UnicodeCompose(ACodePoints, False);//, Filter);
end;


//------------------------------------------------------------------------------
//
//              String conversion
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.UTF16ToUTF32(const AText: string): TPascalTypeCodePoints;
var
  i, j: integer;
  w: Cardinal;
begin
  i := 1;
  j := 0;

  SetLength(Result, Length(AText));

  while i <= Length(AText) do
  begin
    w := Ord(AText[i]);
    Inc(i);

    if (i <= Length(AText)) and (w and $fc00 = $d800) and (Word(Ord(AText[i])) and $fc00 = $dc00) then
    begin
      w := (Cardinal(Cardinal(w and $3ff) shl 10) or Cardinal(Ord(AText[i]) and $3ff)) + $10000;
      inc(i);
    end;

    Result[j] := UCS4(w);
    inc(j);
  end;

  SetLength(Result, j);
end;

class function PascalTypeUnicode.UTF32ToUTF16(const ACodePoints: TPascalTypeCodePoints): string;
var
  i, j: integer;
  w: Cardinal;
begin
  Result := '';

  j := 0;
  for i := 0 to High(ACodePoints) do
  begin
    w := ACodePoints[i];
    if w <= $D7FF then
      Inc(j)
    else
    if w <= $DFFF then
      Inc(j)
    else
    if w <= $FFFD then
      Inc(j)
    else
    if w <= $FFFF then
      Inc(j)
    else
    if w <= $10FFFF then
      Inc(j, 2)
    else
      Inc(j);
  end;

  SetLength(Result, j);
  j := 0;
  for i := 0 to High(ACodePoints) do
  begin
    w := ACodePoints[i];
    if w <= $D7FF then
    begin
      Inc(j);
      Result[j] := Char(w);
    end else
    if w <= $DFFF then
    begin
      Inc(j);
      Result[j] := #$fffd;
    end else
    if w <= $FFFD then
    begin
      Inc(j);
      Result[j] := Char(w);
    end else
    if w <= $FFFF then
    begin
      Inc(j);
      Result[j] := #$fffd;
    end else
    if w <= $10FFFF then
    begin
      Dec(w, $10000);
      Inc(j);
      Result[j] := Char((w shr 10) or $D800);
      Inc(j);
      Result[j] := Char((w and $3FF) or $DC00);
    end else
    begin
      Inc(j);
      Result[j] := #$fffd;
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//              Categorization
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.IsMark(const ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := UnicodeIsMark(ACodePoint);
end;

class function PascalTypeUnicode.IsWhiteSpace(const ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := UnicodeIsWhiteSpace(ACodePoint);
end;

class function PascalTypeUnicode.IsDigit(const ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := UnicodeIsDigit(ACodePoint);
end;
{$endif UNICODE_JEDI}

class function PascalTypeUnicode.IsDefaultIgnorable(const ACodePoint: TPascalTypeCodePoint): boolean;
var
  UnicodePlane: Word;
begin
  // From DerivedCoreProperties.txt in the Unicode database,
  // minus U+115F, U+1160, U+3164 and U+FFA0, which is what
  // Harfbuzz and Uniscribe do.
  UnicodePlane := ACodePoint shr 16;
  if (UnicodePlane = 0) then
  begin
    // BMP
    case ACodePoint shr 8 of
      $00: Result := (ACodePoint = $00AD);
      $03: Result := (ACodePoint = $034F);
      $06: Result := (ACodePoint = $061C);
      $17: Result := (ACodePoint >= $17B4) and (ACodePoint <= $17B5);
      $18: Result := (ACodePoint >= $180B) and (ACodePoint <= $180E);
      $20: Result := ((ACodePoint >= $200B) and (ACodePoint <= $200F)) or ((ACodePoint >= $202A) and (ACodePoint <= $202E)) or ((ACodePoint >= $2060) and (ACodePoint <= $206F));
      $FE: Result := (ACodePoint >= $FE00) and (ACodePoint <= $FE0F) or (ACodePoint = $FEFF);
      $FF: Result := (ACodePoint >= $FFF0) and (ACodePoint <= $FFF8);
    else
      Result := False;
    end;
  end else
  begin
    // Other planes
    case UnicodePlane of
      $01: Result := ((ACodePoint >= $1BCA0) and (ACodePoint <= $1BCA3)) or ((ACodePoint >= $1D173) and (ACodePoint <= $1D17A));
      $0E: Result := (ACodePoint >= $E0000) and (ACodePoint <= $E0FFF);
    else
      Result := False;
    end;
  end;
end;

end.
