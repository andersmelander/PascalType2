unit PT_FontEngineGR32;

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

{-$define DEBUG_CURVE}

uses
  {$IFDEF FPC}LCLIntf, LCLType, {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  {$ELSE}Windows, {$ENDIF} Classes, Contnrs, Sysutils, Graphics,

  GR32_Paths,

  PT_Types,
  PT_Classes,
  PT_Storage,
  PT_FontEngine,
  PT_Tables,
  PT_TablesTrueType;

type
  TPascalTypeFontEngineGR32 = class(TCustomPascalTypeFontEngine)
  protected
    procedure RasterizeGlyph(GlyphIndex: Integer; Canvas: TCustomPath; X, Y: Integer);
    procedure RasterizeGlyphPath(const GlyphPath: TPascalTypePath; Canvas: TCustomPath; X, Y: Single);
  public
    procedure RenderText(Text: string; Canvas: TCustomPath); overload; virtual;
    procedure RenderText(Text: string; Canvas: TCustomPath; X, Y: Integer); overload; virtual;

    // GDI like functions
    function GetGlyphOutlineA(Character: Cardinal; Format: TGetGlyphOutlineUnion;
      out GlyphMetrics: TGlyphMetrics; BufferSize: Cardinal; Buffer: Pointer;
      const TransformationMatrix: TTransformationMatrix): Cardinal;
    function GetGlyphOutlineW(Character: Cardinal; Format: TGetGlyphOutlineUnion;
      out GlyphMetrics: TGlyphMetrics; BufferSize: Cardinal; Buffer: Pointer;
      const TransformationMatrix: TTransformationMatrix): Cardinal;

    function GetTextMetricsA(var TextMetric: TTextMetricA): Boolean;
    function GetTextMetricsW(var TextMetric: TTextMetricW): Boolean;
    function GetOutlineTextMetricsA(Buffersize: Cardinal; OutlineTextMetric: Pointer): Cardinal;
    function GetOutlineTextMetricsW(Buffersize: Cardinal; OutlineTextMetric: Pointer): Cardinal;
    function GetTextExtentPoint32A(Text: string; var Size: TSize): Boolean;
    function GetTextExtentPoint32W(Text: WideString; var Size: TSize): Boolean;
  end;

function ConvertLocalPointerToGlobalPointer(Local, Base: Pointer): Pointer;

implementation

uses
  Math,
  GR32,
  PT_StorageSFNT,
  PascalType.Tables.TrueType.glyf,
  PascalType.Tables.TrueType.hhea;

function ConvertLocalPointerToGlobalPointer(Local, Base: Pointer): Pointer;
begin
  Result := Pointer(Integer(Base) + Integer(Local));
end;


{ TPascalTypeFontEngineGR32 }

function TPascalTypeFontEngineGR32.GetTextMetricsA(
  var TextMetric: TTextMetricA): Boolean;
begin
  Result := False;

  if Assigned(Storage.OS2Table) then
    with Storage, OS2Table, TextMetric do
    begin
      // find right ascent/descent pair and calculate leading
      if fsfUseTypoMetrics in FontSelectionFlags then
      begin
        tmAscent := RoundedScaleY(TypographicAscent);
        tmDescent := RoundedScaleY(TypographicDescent);
        tmInternalLeading := RoundedScaleY(TypographicAscent + TypographicDescent - HeaderTable.UnitsPerEm);
        tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap -
          ((TypographicAscent + TypographicDescent) -
           (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
      end
      else
      begin
        if (WindowsAscent + WindowsDescent) = 0 then
        begin
          tmAscent := RoundedScaleY(HorizontalHeader.Ascent);
          tmDescent := RoundedScaleY(-HorizontalHeader.Descent);
          tmInternalLeading := RoundedScaleY(HorizontalHeader.Ascent + HorizontalHeader.Descent - HeaderTable.UnitsPerEm);
          tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap -
            ((HorizontalHeader.Ascent + HorizontalHeader.Descent) -
             (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
        end
        else
        begin
          tmAscent := RoundedScaleY(WindowsAscent);
          tmDescent := RoundedScaleY(WindowsDescent);
          tmInternalLeading := RoundedScaleY(WindowsAscent + WindowsDescent - HeaderTable.UnitsPerEm);
          tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap -
            ((WindowsAscent + WindowsDescent) -
             (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
        end;
      end;

    tmHeight := tmAscent + tmDescent;

    tmAveCharWidth := RoundedScaleX(AverageCharacterWidth);
    if tmAveCharWidth = 0 then
      tmAveCharWidth := 1;

    tmMaxCharWidth := RoundedScaleX(HorizontalHeader.AdvanceWidthMax);
    tmWeight := Weight;
    tmOverhang := 0;
    tmDigitizedAspectX := PixelPerInchX;
    tmDigitizedAspectY := PixelPerInchY;

    {$IFDEF FPC}
    if WideChar(UnicodeFirstCharacterIndex) < #$FF then
      tmFirstChar := BCHAR(UnicodeFirstCharacterIndex)
    else
      tmFirstChar := $FF;

    if WideChar(UnicodeLastCharacterIndex) < #$FF then
      tmLastChar := BCHAR(UnicodeLastCharacterIndex)
    else
      tmLastChar := $FF;
    {$ELSE}
    if WideChar(UnicodeFirstCharacterIndex) < #$FF then
      tmFirstChar := AnsiChar(UnicodeFirstCharacterIndex)
    else
      tmFirstChar := #$FF;

    if WideChar(UnicodeLastCharacterIndex) < #$FF then
      tmLastChar := AnsiChar(UnicodeLastCharacterIndex)
    else
      tmLastChar := #$FF;
    {$ENDIF}

    tmItalic := Integer(fsfItalic in FontSelectionFlags);
    tmUnderlined := Integer(fsfUnderscore in FontSelectionFlags);
    tmStruckOut := Integer(fsfStrikeout in FontSelectionFlags);

    case FontFamilyClassID of
      9, 12:
        tmPitchAndFamily := FF_DECORATIVE;
      10:
        tmPitchAndFamily := FF_SCRIPT;
      8:
        tmPitchAndFamily := FF_SWISS;
      3, 7:
        tmPitchAndFamily := FF_MODERN; // monospaced!
      1, 2, 4, 5:
        tmPitchAndFamily := FF_ROMAN;
      else
        tmPitchAndFamily := 0;
    end;

    if (Self.Storage.PostScriptTable.IsFixedPitch = 0) then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_FIXED_PITCH;
    if Self.Storage.ContainsTable('glyf') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_VECTOR + TMPF_TRUETYPE;
    if Self.Storage.ContainsTable('CFF ') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_VECTOR;
    if Self.Storage.ContainsTable('HDMX') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_DEVICE;

(*
    if Assigned(AddendumTable) then
     begin
      tmBreakChar := Char(AddendumTable.BreakChar);
      tmDefaultChar := Char(Integer(tmBreakChar) - 1); // WideChar(AddendumTable.DefaultChar);
     end
    else
     begin
      if tmFirstChar <= #1
       then tmBreakChar := WChar(Integer(tmFirstChar) + 2) else
      if tmFirstChar > #$FF
       then tmBreakChar := #$20
       else tmBreakChar := tmFirstChar;
      tmDefaultChar := WChar(Integer(tmBreakChar) - 1);
     end;
*)

    if Assigned(CodePageRange) and (CodePageRange.SupportsLatin1) then
      tmCharSet := 0;
   end;

 Result := True;
end;

function TPascalTypeFontEngineGR32.GetTextMetricsW(
  var TextMetric: TTextMetricW): Boolean;
begin
  Result := False;

  if Assigned(Storage.OS2Table) then
    with Storage, OS2Table, TextMetric do
    begin
      // find right ascent/descent pair and calculate leading
      if fsfUseTypoMetrics in FontSelectionFlags then
      begin
        tmAscent := RoundedScaleY(TypographicAscent);
        tmDescent := RoundedScaleY(TypographicDescent);
        tmInternalLeading := RoundedScaleY(TypographicAscent + TypographicDescent - HeaderTable.UnitsPerEm);
        tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap -
          ((TypographicAscent + TypographicDescent) -
           (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
      end
      else
      begin
      if (WindowsAscent + WindowsDescent) = 0 then
      begin
        tmAscent := RoundedScaleY(HorizontalHeader.Ascent);
        tmDescent := RoundedScaleY(-HorizontalHeader.Descent);
        tmInternalLeading := RoundedScaleY(HorizontalHeader.Ascent + HorizontalHeader.Descent - HeaderTable.UnitsPerEm);
        tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap -
          ((HorizontalHeader.Ascent + HorizontalHeader.Descent) -
           (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
      end
      else
      begin
        tmAscent := RoundedScaleY(WindowsAscent);
        tmDescent := RoundedScaleY(WindowsDescent);
        tmInternalLeading := RoundedScaleY(WindowsAscent + WindowsDescent - HeaderTable.UnitsPerEm);
        tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap -
          ((WindowsAscent + WindowsDescent) -
           (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
      end;
    end;

    tmHeight := tmAscent + tmDescent;

    tmAveCharWidth := RoundedScaleX(AverageCharacterWidth);
    if tmAveCharWidth = 0 then
      tmAveCharWidth := 1;

    tmMaxCharWidth := RoundedScaleX(HorizontalHeader.AdvanceWidthMax);
    tmWeight := Weight;
    tmOverhang := 0;
    tmDigitizedAspectX := PixelPerInchX;
    tmDigitizedAspectY := PixelPerInchY;

    tmFirstChar := WideChar(UnicodeFirstCharacterIndex);
    tmLastChar := WideChar(UnicodeLastCharacterIndex);

    tmItalic := Integer(fsfItalic in FontSelectionFlags);
    tmUnderlined := Integer(fsfUnderscore in FontSelectionFlags);
    tmStruckOut := Integer(fsfStrikeout in FontSelectionFlags);

    case FontFamilyClassID of
      9, 12:
        tmPitchAndFamily := FF_DECORATIVE;
      10:
        tmPitchAndFamily := FF_SCRIPT;
      8:
        tmPitchAndFamily := FF_SWISS;
      3, 7:
        tmPitchAndFamily := FF_MODERN;
      1, 2, 4, 5:
        tmPitchAndFamily := FF_ROMAN;
      else
        tmPitchAndFamily := 0;
    end;
    if (Self.Storage.PostScriptTable.IsFixedPitch = 0) then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_FIXED_PITCH;
    if Self.Storage.ContainsTable('glyf') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_VECTOR + TMPF_TRUETYPE;
    if Self.Storage.ContainsTable('CFF ') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_VECTOR;
    if Self.Storage.ContainsTable('HDMX') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_DEVICE;

    if Assigned(AddendumTable) then
    begin
      tmBreakChar := WideChar(AddendumTable.BreakChar);
      tmDefaultChar := WChar(Integer(tmBreakChar) - 1); // WideChar(AddendumTable.DefaultChar);
    end
    else
    begin
      if tmFirstChar <= #1 then
        tmBreakChar := WChar(Integer(tmFirstChar) + 2) else
      if tmFirstChar > #$FF then
        tmBreakChar := #$20
      else
        tmBreakChar := tmFirstChar;
      tmDefaultChar := WChar(Integer(tmBreakChar) - 1);
    end;

    if Assigned(CodePageRange) and (CodePageRange.SupportsLatin1) then
      tmCharSet := 0;
   end;

 Result := True;
end;

////////////////////////////////////////////////////////////////////////////////

function TPascalTypeFontEngineGR32.GetOutlineTextMetricsA(
  Buffersize: Cardinal; OutlineTextMetric: Pointer): Cardinal;
begin
  if OutlineTextMetric = nil then
  begin
    Result := SizeOf(TOutlineTextmetricA);
    Exit;
  end;

  if not Assigned(Storage.OS2Table) or (Buffersize < SizeOf(TOutlineTextmetricA)) then
  begin
    Result := 0;
    if Buffersize < SizeOf(TOutlineTextmetricA) then
      FillChar(OutlineTextMetric^, Buffersize, 0) else
    FillChar(OutlineTextMetric^, SizeOf(TOutlineTextmetricW), 0);
    Exit;
  end;

  with Storage, OS2Table, POutlineTextmetricA(OutlineTextMetric)^ do
  begin
    otmSize := SizeOf(TOutlineTextmetricA);

    // get text metrics
    GetTextMetricsA(otmTextMetrics);

    // set padding filler to zero
    otmFiller := 0;

    // set font selection
    otmfsSelection := FontSelection;

    // set font embedding rights
    otmfsType := FontEmbeddingFlags;

    // set caret slope rise/run
    otmsCharSlopeRise := HorizontalHeader.CaretSlopeRise;
    otmsCharSlopeRun := HorizontalHeader.CaretSlopeRun;

    // set italic angle (fixed point with MS compatibility fix)
    with PostScriptTable.ItalicAngle do
      otmItalicAngle := Round(10 * (Value + Fract / (1 shl 16)));

    otmEMSquare := HeaderTable.UnitsPerEm;
    otmAscent := RoundedScaleY(OS2Table.TypographicAscent);
    otmDescent := RoundedScaleY(OS2Table.TypographicDescent);
    otmLineGap := RoundedScaleY(OS2Table.TypographicLineGap);
    if Assigned(AddendumTable) then
    begin
      otmsXHeight := RoundedScaleY(AddendumTable.XHeight);
      otmsCapEmHeight := RoundedScaleY(AddendumTable.CapHeight);
    end
    else
    begin
      otmsXHeight := 0;
      otmsCapEmHeight := 0;
    end;

    otmrcFontBox.Left := RoundedScaleX(HeaderTable.XMin);
    otmrcFontBox.Top := RoundedScaleY(HeaderTable.YMax);
    otmrcFontBox.Right := RoundedScaleX(HeaderTable.XMax);
    otmrcFontBox.Bottom := RoundedScaleY(HeaderTable.YMin);
    otmMacAscent := RoundedScaleY(HorizontalHeader.Ascent);
    otmMacDescent := RoundedScaleY(HorizontalHeader.Descent);
    otmMacLineGap := RoundedScaleY(HorizontalHeader.LineGap);
    otmusMinimumPPEM := HeaderTable.LowestRecPPEM;
    otmptSubscriptSize.X := RoundedScaleX(SubScriptSizeX);
    otmptSubscriptSize.Y := RoundedScaleY(SubScriptSizeY);
    otmptSubscriptOffset.X := RoundedScaleX(SubScriptOffsetX);
    otmptSubscriptOffset.Y := RoundedScaleY(SubScriptOffsetY);
    otmptSuperscriptSize.X := RoundedScaleX(SuperScriptSizeX);
    otmptSuperscriptSize.Y := RoundedScaleY(SuperScriptSizeY);
    otmptSuperscriptOffset.X := RoundedScaleX(SuperScriptOffsetX);
    otmptSuperscriptOffset.Y := RoundedScaleY(SuperScriptOffsetY);
    otmsStrikeoutSize := RoundedScaleY(StrikeoutSize);
    otmsStrikeoutPosition := RoundedScaleY(StrikeoutPosition);
    otmsUnderscoreSize := RoundedScaleY(PostScriptTable.UnderlineThickness);
    otmsUnderscorePosition := RoundedScaleY(PostScriptTable.UnderlinePosition);

    // copy panose data
    Panose := Self.Storage.Panose;
    if Assigned(Panose) then
      with otmPanoseNumber, Panose do
      begin
        bFamilyType      := FamilyType;
        bSerifStyle      := Data[0];
        bWeight          := Data[1];
        bProportion      := Data[2];
        bContrast        := Data[3];
        bStrokeVariation := Data[4];
        bArmStyle        := Data[5];
        bLetterform      := Data[6];
        bMidline         := Data[7];
        bXHeight         := Data[8];
      end
    else
      Exit;

    // do not fill strings yet
    otmpFamilyName := nil;
    otmpFaceName := nil;
    otmpStyleName := nil;
    otmpFullName := nil;

    Result := 0;
  end;
end;

function TPascalTypeFontEngineGR32.GetOutlineTextMetricsW(
  Buffersize: Cardinal; OutlineTextMetric: Pointer): Cardinal;
var
  FamilyNameStr: WideString;
  FaceNameStr: WideString;
  StyleNameStr: WideString;
  FullNameStr: WideString;
begin
  // check if OS/2 table exists (as it is not necessary in the true type spec
  if not Assigned(Storage.OS2Table) then
  begin
    Result := 0;
    FillChar(OutlineTextMetric^, Buffersize, 0);
    Exit;
  end;

  // get font string information
  with Storage, OS2Table do
  begin
    FamilyNameStr := FontFamilyName + #0;
    FaceNameStr   := FontName + #0;
    StyleNameStr  := FontSubFamilyName + #0;
    FullNameStr   := UniqueIdentifier + #0;
  end;

  // check if OutlineTextMetric buffer is passed, if not return the necessary size
  if OutlineTextMetric = nil then
  begin
    Result := SizeOf(TOutlineTextmetricW) + 2 * (Length(FamilyNameStr) +
      Length(FaceNameStr) + Length(StyleNameStr) + Length(FullNameStr));
    Exit;
  end;

  // check if OS/2 table exists (as it is not necessary in the true type spec
  if (Buffersize < SizeOf(TOutlineTextmetricW)) then
  begin
    Result := 0;
    if Buffersize < SizeOf(TOutlineTextmetricW) then
      FillChar(OutlineTextMetric^, Buffersize, 0)
    else
      FillChar(OutlineTextMetric^, SizeOf(TOutlineTextmetricW), 0);
    Exit;
  end;

  with Storage, OS2Table, POutlineTextmetricW(OutlineTextMetric)^ do
  begin
    otmSize := SizeOf(TOutlineTextmetricW) + 2 * (Length(FamilyNameStr) +
      Length(FaceNameStr) + Length(StyleNameStr) + Length(FullNameStr));

    // get text metrics
    GetTextMetricsW(otmTextMetrics);

    // set padding filler to zero
    otmFiller := 0;

    // set font selection
    otmfsSelection := FontSelection;

    // set font embedding rights
    otmfsType := FontEmbeddingFlags;

    // set caret slope rise/run
    otmsCharSlopeRise := HorizontalHeader.CaretSlopeRise;
    otmsCharSlopeRun := HorizontalHeader.CaretSlopeRun;

    // set italic angle (fixed point with MS compatibility fix)
    with PostScriptTable.ItalicAngle do
      otmItalicAngle := Round(10 * (Value + Fract / (1 shl 16)));

    otmEMSquare := HeaderTable.UnitsPerEm;
    otmAscent := RoundedScaleY(OS2Table.TypographicAscent);
    otmDescent := RoundedScaleY(OS2Table.TypographicDescent);
    otmLineGap := RoundedScaleY(OS2Table.TypographicLineGap);
    if Assigned(AddendumTable) then
    begin
      otmsXHeight := RoundedScaleY(AddendumTable.XHeight);
      otmsCapEmHeight := RoundedScaleY(AddendumTable.CapHeight);
    end
    else
    begin
      otmsXHeight := 0;
      otmsCapEmHeight := 0;
    end;

    otmrcFontBox.Left := RoundedScaleX(HeaderTable.XMin);
    otmrcFontBox.Top := RoundedScaleY(HeaderTable.YMax);
    otmrcFontBox.Right := RoundedScaleX(HeaderTable.XMax);
    otmrcFontBox.Bottom := RoundedScaleY(HeaderTable.YMin);
    otmMacAscent := RoundedScaleY(HorizontalHeader.Ascent);
    otmMacDescent := RoundedScaleY(HorizontalHeader.Descent);
    otmMacLineGap := RoundedScaleY(HorizontalHeader.LineGap);
    otmusMinimumPPEM := HeaderTable.LowestRecPPEM;
    otmptSubscriptSize.X := RoundedScaleX(SubScriptSizeX);
    otmptSubscriptSize.Y := RoundedScaleY(SubScriptSizeY);
    otmptSubscriptOffset.X := RoundedScaleX(SubScriptOffsetX);
    otmptSubscriptOffset.Y := RoundedScaleY(SubScriptOffsetY);
    otmptSuperscriptSize.X := RoundedScaleX(SuperScriptSizeX);
    otmptSuperscriptSize.Y := RoundedScaleY(SuperScriptSizeY);
    otmptSuperscriptOffset.X := RoundedScaleX(SuperScriptOffsetX);
    otmptSuperscriptOffset.Y := RoundedScaleY(SuperScriptOffsetY);
    otmsStrikeoutSize := RoundedScaleY(StrikeoutSize);
    otmsStrikeoutPosition := RoundedScaleY(StrikeoutPosition);
    otmsUnderscoreSize := RoundedScaleY(PostScriptTable.UnderlineThickness);
    otmsUnderscorePosition := RoundedScaleY(PostScriptTable.UnderlinePosition);

    // copy panose data
    Panose := Self.Storage.Panose;
    if Assigned(Self.Storage.Panose) then
      with otmPanoseNumber, Self.Storage.Panose do
      begin
        bFamilyType      := FamilyType;
        bSerifStyle      := Data[0];
        bWeight          := Data[1];
        bProportion      := Data[2];
        bContrast        := Data[3];
        bStrokeVariation := Data[4];
        bArmStyle        := Data[5];
        bLetterform      := Data[6];
        bMidline         := Data[7];
        bXHeight         := Data[8];
      end
    else
      Exit;

    // do not fill strings yet
    otmpFamilyName := PAnsiChar(SizeOf(TOutlineTextmetricW));
    otmpFaceName := PAnsiChar(SizeOf(TOutlineTextmetricW) + 2 * Length(FamilyNameStr));
    otmpStyleName := PAnsiChar(SizeOf(TOutlineTextmetricW) + 2 * (Length(FamilyNameStr) + Length(FaceNameStr)));
    otmpFullName := PAnsiChar(SizeOf(TOutlineTextmetricW) + 2 * (Length(FamilyNameStr) + Length(FaceNameStr) + Length(StyleNameStr)));

    // copy string data
    StrPCopy(ConvertLocalPointerToGlobalPointer(otmpFamilyName, OutlineTextMetric), FamilyNameStr);
    StrPCopy(ConvertLocalPointerToGlobalPointer(otmpFaceName, OutlineTextMetric), FaceNameStr);
    StrPCopy(ConvertLocalPointerToGlobalPointer(otmpStyleName, OutlineTextMetric), StyleNameStr);
    StrPCopy(ConvertLocalPointerToGlobalPointer(otmpFullName, OutlineTextMetric), FullNameStr);

    Result := 0;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TPascalTypeFontEngineGR32.GetTextExtentPoint32A(Text: string;
  var Size: TSize): Boolean;
var
  GlyphIndex: Integer;
begin
// GlyphIndex := GetGlyphByCharacter(Character);
  Result := False;
end;

function TPascalTypeFontEngineGR32.GetTextExtentPoint32W(Text: WideString;
  var Size: TSize): Boolean;
var
  CharIndex: Integer;
  Advance: TScaleType;
  GlyphIndex: Integer;
begin
  Result := True;

  if Length(Text) = 0 then
  begin
    Size.cy := 0;
    Size.cx := 0;
    Exit;
  end;

  try
    GlyphIndex := GetGlyphByCharacter(Text[1]);
    Advance := GetAdvanceWidth(GlyphIndex);
    CharIndex := 2;

    while CharIndex < Length(Text) do
    begin
      GlyphIndex := GetGlyphByCharacter(Text[CharIndex]);
      Advance := Advance + GetAdvanceWidth(GlyphIndex);

(*
        Advance := Advance + GetKerningWidth(GlyphIndex);
*)

      Inc(CharIndex);
    end;

    Size.cy := Abs(FontHeight);
    Size.cx := Round(Advance);
  except
    Result := False;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TPascalTypeFontEngineGR32.GetGlyphOutlineA(Character: Cardinal;
  Format: TGetGlyphOutlineUnion; out GlyphMetrics: TGlyphMetrics;
  BufferSize: Cardinal; Buffer: Pointer;
  const TransformationMatrix: TTransformationMatrix): Cardinal;
var
  GlyphIndex: Integer;
begin
  // get glyph index
  if (ggoGlyphIndex in Format.Flags) then
    GlyphIndex := Character
  else
    GlyphIndex := GetGlyphByCharacter(Character);

(*
 if Buffer = nil then
  case Format.Format of


  end;
*)
end;

function TPascalTypeFontEngineGR32.GetGlyphOutlineW(Character: Cardinal;
  Format: TGetGlyphOutlineUnion; out GlyphMetrics: TGlyphMetrics;
  BufferSize: Cardinal; Buffer: Pointer;
  const TransformationMatrix: TTransformationMatrix): Cardinal;
var
  GlyphIndex: Integer;
begin
  // get glyph index
  if (ggoGlyphIndex in Format.Flags) then
    GlyphIndex := Character
  else
    GlyphIndex := GetGlyphByCharacter(Character);

  with GlyphMetrics, TCustomTrueTypeFontGlyphData(Storage.GlyphData[GlyphIndex]) do
  begin
    gmptGlyphOrigin.X := RoundedScaleX(XMin);
    gmptGlyphOrigin.Y := RoundedScaleX(YMin);
    gmBlackBoxX := RoundedScaleX(XMax);
    gmBlackBoxY := RoundedScaleX(YMax);
    gmCellIncX := RoundedScaleX(XMax);
    gmCellIncY := 0;
  end;

(*
 if Buffer = nil then
  case Format.Format of
   ggoBitmap

  end;
*)
end;

////////////////////////////////////////////////////////////////////////////////
procedure TPascalTypeFontEngineGR32.RasterizeGlyph(GlyphIndex: Integer; Canvas: TCustomPath; X, Y: Integer);
var
  GlyphPath: TPascalTypePath;
begin
  GlyphPath := Storage.GetGlyphPath(GlyphIndex);
  RasterizeGlyphPath(GlyphPath, Canvas, X, Y);
end;

type
  TPathState = (
    psCurve,            // The previous point was a curve-point.
    psControl           // The previous point was a control-point.
  );

  TPathEmit = (
    emitNone,           // Draw nothing.
    emitLine,           // Draw a line.
    emitQuadratic,      // Draw a Quadratic bezier.
    emitHalfway         // Draw a Quadratic bezier.
                        // The two previous points were control-points; This
                        // implies an implicit curve-point halfway between the
                        // control-points.
  );

  TStateTransition = record
    NextState: TPathState;
    Emit: TPathEmit;
  end;

const
  StateMachine: array[boolean, TPathState] of TStateTransition = (
    // False: Current point is a control-point
    ((NextState: psControl;     Emit: emitNone),        // psCurve -> psControl
     (NextState: psControl;     Emit: emitHalfway)),    // psControl -> psControl: synthesize point, emitQuadratic
    // True: Current point is a curve-point
    ((NextState: psCurve;       Emit: emitLine),        // psCurve -> psCurve: emitLine
     (NextState: psCurve;       Emit: emitQuadratic))   // psControl -> psCurve: emitQuadratic
  );


procedure TPascalTypeFontEngineGR32.RasterizeGlyphPath(const GlyphPath: TPascalTypePath; Canvas: TCustomPath; X, Y: Single);
var
  Ascent: integer;
  Origin: TFloatPoint;
  PointIndex: Integer;
  CurrentPoint: TFloatPoint;
  ControlPoint: TFloatPoint;
  MidPoint: TFloatPoint;
  IsOnCurve: Boolean;
  Contour: TPascalTypeContour;
  PathState: TPathState;
  StateTransition: TStateTransition;
  i: integer;
begin
  Ascent := Max(TPascalTypeHeaderTable(TPascalTypeStorage(Storage).HeaderTable).YMax,
    TPascalTypeHorizontalHeaderTable(TPascalTypeStorage(Storage).HorizontalHeader).Ascent);
  Origin.X := X;
  Origin.Y := Y + Ascent * ScalerY;

{$ifdef DEBUG_CURVE}
  var DebugPath := TFlattenedPath.Create;
{$endif DEBUG_CURVE}

  for Contour in GlyphPath do
  begin
    if (Length(Contour) < 2) then
      continue;

    CurrentPoint.X := Origin.X + Contour[0].XPos * ScalerX;
    CurrentPoint.Y := Origin.Y - Contour[0].YPos * ScalerY;

    // Process the start point
    if (Contour[0].Flags and TTrueTypeFontSimpleGlyphData.GLYF_ON_CURVE <> 0) then
    begin
      // It's a curve-point
      PathState := psCurve;
    end else
    begin
      ControlPoint := CurrentPoint;
      // It's a control-point. See if the prior point in the closed polygon
      // (i.e. last point in the array) is a curve-point.
      if (Contour[High(Contour)].Flags and TTrueTypeFontSimpleGlyphData.GLYF_ON_CURVE <> 0) then
      begin
        // Last point was a curve-point. Use it as the current point and use
        // the first point as the control-point.
        // Seen with: Kalinga Bold, small letter "r"
        CurrentPoint.X := Origin.X + Contour[High(Contour)].XPos * ScalerX;
        CurrentPoint.Y := Origin.Y - Contour[High(Contour)].YPos * ScalerY;
      end else
      begin
        // Both first and last points are control-points.
        // Synthesize a curve-point in between the two control-points.
        // Seen with: SimSun-ExtB, small letter "a"
        CurrentPoint.X := Origin.X + (Contour[0].XPos + Contour[High(Contour)].XPos) * 0.5 * ScalerX;
        CurrentPoint.Y := Origin.Y - (Contour[0].YPos + Contour[High(Contour)].YPos) * 0.5 * ScalerY;
      end;
      PathState := psControl;
    end;

    // Move to the first curve-point (the one we just found above)
    Canvas.MoveTo(CurrentPoint.X, CurrentPoint.Y);
{$ifdef DEBUG_CURVE}
    DebugPath.Circle(CurrentPoint, 3);
{$endif DEBUG_CURVE}

    // Note that PointIndex wraps around to zero
    PointIndex := 1;
    for i := 0 to High(Contour) do
    begin
      // Get the next point
      CurrentPoint.X := Origin.X + Round(Contour[PointIndex].XPos * ScalerX);
      CurrentPoint.Y := Origin.Y - Round(Contour[PointIndex].YPos * ScalerY);

      // Is it a curve-point?
      IsOnCurve := (Contour[PointIndex].Flags and TTrueTypeFontSimpleGlyphData.GLYF_ON_CURVE <> 0);

      StateTransition := StateMachine[IsOnCurve, PathState];
      PathState := StateTransition.NextState;

      case StateTransition.Emit of
        emitNone:
          begin
            ControlPoint := CurrentPoint;
{$ifdef DEBUG_CURVE}
            var r: TFloatRect;
            r.TopLeft := ControlPoint;
            r.BottomRight := ControlPoint;
            InflateRect(r, 2, 2);
            DebugPath.Rectangle(r);
{$endif DEBUG_CURVE}
          end;

        emitLine:
          begin
            Canvas.LineTo(CurrentPoint.X, CurrentPoint.Y);
{$ifdef DEBUG_CURVE}
            DebugPath.Circle(CurrentPoint, 3);
{$endif DEBUG_CURVE}
          end;

        emitQuadratic:
          begin
            Canvas.ConicTo(ControlPoint, CurrentPoint);
{$ifdef DEBUG_CURVE}
            DebugPath.Circle(CurrentPoint, 3);
{$endif DEBUG_CURVE}
          end;

        emitHalfway:
          begin
            MidPoint.X := (ControlPoint.X + CurrentPoint.X) * 0.5;
            MidPoint.Y := (ControlPoint.Y + CurrentPoint.Y) * 0.5;
            Canvas.ConicTo(ControlPoint, MidPoint);
            ControlPoint := CurrentPoint;
{$ifdef DEBUG_CURVE}
            DebugPath.Circle(MidPoint, 3);
            var r: TFloatRect;
            r.TopLeft := ControlPoint;
            r.BottomRight := ControlPoint;
            InflateRect(r, 2, 2);
            DebugPath.Rectangle(r);
{$endif DEBUG_CURVE}
          end;
      end;
      PointIndex := (PointIndex + 1) mod Length(Contour);
    end;

    Canvas.EndPath(True);
  end;
{$ifdef DEBUG_CURVE}
  for var i := 0 to High(DebugPath.Path) do
    if (DebugPath.PathClosed[i]) then
      Canvas.Polygon(DebugPath.Path[i])
    else
      Canvas.Polyline(DebugPath.Path[i]);
  DebugPath.Free;
{$endif DEBUG_CURVE}
end;

////////////////////////////////////////////////////////////////////////////////

procedure TPascalTypeFontEngineGR32.RenderText(Text: string; Canvas: TCustomPath);
begin
  RenderText(Text, Canvas, 0, 0);
end;

procedure TPascalTypeFontEngineGR32.RenderText(Text: string; Canvas: TCustomPath; X,
  Y: Integer);
var
  CharIndex: Integer;
  GlyphIndex: Integer;
  Pos: TFloatPoint;
begin
  Canvas.BeginUpdate;
  try
    Pos.X := X;
    Pos.Y := Y;
    for CharIndex := 1 to Length(Text) do
    begin
      if Text[CharIndex] <= #31 then
        case Text[CharIndex] of
          #10: ;// handle CR
          #13: ;// handle LF
        end
      else
      begin
        // get glyph index
        GlyphIndex := GetGlyphByCharacter(Text[CharIndex]);

        // rasterize character
        RasterizeGlyph(GlyphIndex, Canvas, Round(Pos.X), Round(Pos.Y));

        // advance cursor
        Pos.X := Pos.X + GetAdvanceWidth(GlyphIndex);
      end;
    end;

  finally
    Canvas.EndUpdate;
  end;
end;

end.
