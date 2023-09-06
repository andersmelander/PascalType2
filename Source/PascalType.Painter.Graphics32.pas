unit PascalType.Painter.Graphics32;

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

{$define FILL_PATH}
{-$define STROKE_PATH}

uses
  {$IFDEF FPC}LCLIntf, LCLType, {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  {$ELSE}Windows, {$ENDIF} Classes, Controls, Sysutils, Graphics,

  GR32,
  GR32_Brushes,
  GR32_Paths,

  PascalType.Painter;

//------------------------------------------------------------------------------
//
//              TCustomPascalTypePainterCanvas32
//
//------------------------------------------------------------------------------
// Abstract Graphics32 font rasterizer base class
//------------------------------------------------------------------------------
type
  TCustomPascalTypePainterCanvas32 = class abstract(TInterfacedObject, IPascalTypePainter)
  private
    FCanvas: TCustomPath;
    FFillBrush: TSolidBrush;
    FStrokeBrush: TStrokeBrush;
  protected
    property Canvas: TCustomPath read FCanvas;
    property FillBrush: TSolidBrush read FFillBrush;
    property StrokeBrush: TStrokeBrush read FStrokeBrush;
  protected
    // IPascalTypePainter
    procedure BeginUpdate;
    procedure EndUpdate;

    procedure BeginGlyph;
    procedure EndGlyph;

    procedure BeginPath;
    procedure EndPath(AClose: boolean);

    procedure MoveTo(const p: TFloatPoint);
    procedure LineTo(const p: TFloatPoint);
    procedure QuadraticBezierTo(const ControlPoint, p: TFloatPoint);
    procedure CubicBezierTo(const ControlPoint1, ControlPoint2, p: TFloatPoint);
    procedure Rectangle(const r: TFloatRect);
    procedure Circle(const p: TFloatPoint; Radius: TRenderFloat);

    procedure SetColor(Color: Cardinal);
    function GetColor: Cardinal;
    procedure SetStrokeColor(Color: Cardinal);
    function GetStrokeColor: Cardinal;

  protected
    constructor Create(ACanvas: TCustomPath; AFillBrush: TSolidBrush = nil; AStrokeBrush: TStrokeBrush = nil);
  public
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypePainterCanvas32
//
//------------------------------------------------------------------------------
// Font rasterizer targeting a Graphics32 canvas
//------------------------------------------------------------------------------
type
  TPascalTypePainterCanvas32 = class(TCustomPascalTypePainterCanvas32)
  public
    constructor Create(ACanvas: TCustomPath; AFillBrush: TSolidBrush = nil; AStrokeBrush: TStrokeBrush = nil);
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypePainterBitmap32
//
//------------------------------------------------------------------------------
// Font rasterizer targeting a Graphics32 bitmap
//------------------------------------------------------------------------------
type
  TPascalTypePainterBitmap32 = class(TCustomPascalTypePainterCanvas32)
  private
    FCanvas32: TCanvas32;
  public
    constructor Create(ABitmap32: TBitmap32);
    destructor Destroy; override;
  end;

implementation

uses
  GR32_Polygons;

(*
function ConvertLocalPointerToGlobalPointer(Local, Base: Pointer): Pointer;
begin
  Result := Pointer(Integer(Base) + Integer(Local));
end;


function TPascalTypeRasterizerGraphics32.GetTextMetrics(var TextMetric: TTextMetricW): Boolean;
begin
  Result := False;

  if (FontFace.OS2Table = nil) then
    exit;

  with FontFace, OS2Table, TextMetric do
  begin
    // find right ascent/descent pair and calculate leading
    if fsfUseTypoMetrics in FontSelectionFlags then
    begin
      tmAscent := RoundedScaleY(TypographicAscent);
      tmDescent := RoundedScaleY(TypographicDescent);
      tmInternalLeading := RoundedScaleY(TypographicAscent + TypographicDescent - HeaderTable.UnitsPerEm);
      tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap - ((TypographicAscent + TypographicDescent) - (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
    end else
    begin
      if (WindowsAscent + WindowsDescent) = 0 then
      begin
        tmAscent := RoundedScaleY(HorizontalHeader.Ascent);
        tmDescent := RoundedScaleY(-HorizontalHeader.Descent);
        tmInternalLeading := RoundedScaleY(HorizontalHeader.Ascent + HorizontalHeader.Descent - HeaderTable.UnitsPerEm);
        tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap - ((HorizontalHeader.Ascent + HorizontalHeader.Descent) - (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
      end else
      begin
        tmAscent := RoundedScaleY(WindowsAscent);
        tmDescent := RoundedScaleY(WindowsDescent);
        tmInternalLeading := RoundedScaleY(WindowsAscent + WindowsDescent - HeaderTable.UnitsPerEm);
        tmExternalLeading := Max(0, RoundedScaleY(HorizontalHeader.LineGap - ((WindowsAscent + WindowsDescent) - (HorizontalHeader.Ascent - HorizontalHeader.Descent))));
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
    if (Self.FontFace.PostScriptTable.IsFixedPitch = 0) then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_FIXED_PITCH;
    if Self.FontFace.ContainsTable('glyf') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_VECTOR + TMPF_TRUETYPE;
    if Self.FontFace.ContainsTable('CFF ') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_VECTOR;
    if Self.FontFace.ContainsTable('HDMX') then
      tmPitchAndFamily := tmPitchAndFamily + TMPF_DEVICE;

    if Assigned(AddendumTable) then
    begin
      tmBreakChar := WideChar(AddendumTable.BreakChar);
      tmDefaultChar := WChar(Integer(tmBreakChar) - 1);
      // WideChar(AddendumTable.DefaultChar);
    end else
    begin
      if tmFirstChar <= #1 then
        tmBreakChar := WChar(Integer(tmFirstChar) + 2)
      else
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

function TPascalTypeRasterizerGraphics32.GetOutlineTextMetrics(Buffersize: Cardinal; OutlineTextMetric: Pointer): Cardinal;
var
  FamilyNameStr: WideString;
  FaceNameStr: WideString;
  StyleNameStr: WideString;
  FullNameStr: WideString;
  ResultSize: Cardinal;
begin
  Result := 0;
  // check if OS/2 table exists (as it is not necessary in the true type spec
  if not Assigned(FontFace.OS2Table) then
  begin
    FillChar(OutlineTextMetric^, Buffersize, 0);
    Exit;
  end;

  // get font string information
  with FontFace, OS2Table do
  begin
    FamilyNameStr := FontFamilyName + #0;
    FaceNameStr   := FontName + #0;
    StyleNameStr  := FontSubFamilyName + #0;
    FullNameStr   := UniqueIdentifier + #0;
  end;

  ResultSize := SizeOf(TOutlineTextmetricW) + 2 * (Length(FamilyNameStr) +
    Length(FaceNameStr) + Length(StyleNameStr) + Length(FullNameStr));

  // check if OutlineTextMetric buffer is passed, if not return the necessary size
  if OutlineTextMetric = nil then
  begin
    Result := ResultSize;
    Exit;
  end;

  if (Buffersize < ResultSize) then
    Exit;

  // check if OS/2 table exists (as it is not necessary in the true type spec
  if (Buffersize < SizeOf(TOutlineTextmetricW)) then
  begin
    FillChar(OutlineTextMetric^, Buffersize, 0);
    Exit;
  end;

  with FontFace, OS2Table, POutlineTextmetricW(OutlineTextMetric)^ do
  begin
    otmSize := SizeOf(TOutlineTextmetricW) + 2 * (Length(FamilyNameStr) +
      Length(FaceNameStr) + Length(StyleNameStr) + Length(FullNameStr));

    // get text metrics
    GetTextMetrics(otmTextMetrics);

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
    Panose := Self.FontFace.Panose;
    if Assigned(Self.FontFace.Panose) then
      with otmPanoseNumber, Self.FontFace.Panose do
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
      Exit; // TODO : Why?

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

    Result := ResultSize;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TPascalTypeRasterizerGraphics32.GetTextExtentPoint32(Text: WideString;
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
    GlyphIndex := FontFace.GetGlyphByCharacter(Text[1]);
    Advance := GetAdvanceWidth(GlyphIndex);
    CharIndex := 2;

    while CharIndex < Length(Text) do
    begin
      GlyphIndex := FontFace.GetGlyphByCharacter(Text[CharIndex]);
      Advance := Advance + GetAdvanceWidth(GlyphIndex);

      Inc(CharIndex);
    end;

    Size.cy := Abs(FontHeight);
    Size.cx := Round(Advance);
  except
    Result := False;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TPascalTypeRasterizerGraphics32.GetGlyphOutline(Character: Cardinal;
  Format: TGetGlyphOutlineUnion; out GlyphMetrics: TGlyphMetrics;
  BufferSize: Cardinal; Buffer: Pointer;
  const TransformationMatrix: TTransformationMatrix): Cardinal;
begin
  // TODO
  Result := 0;

  // get glyph index
  if (ggoGlyphIndex in Format.Flags) then
    GlyphIndex := Character
  else
    GlyphIndex := FontFace.GetGlyphByCharacter(Character);

  with GlyphMetrics, TCustomTrueTypeFontGlyphData(FontFace.GlyphData[GlyphIndex]) do
  begin
    gmptGlyphOrigin.X := RoundedScaleX(XMin);
    gmptGlyphOrigin.Y := RoundedScaleX(YMin);
    gmBlackBoxX := RoundedScaleX(XMax);
    gmBlackBoxY := RoundedScaleX(YMax);
    gmCellIncX := RoundedScaleX(XMax);
    gmCellIncY := 0;
  end;

 if Buffer = nil then
  case Format.Format of
   ggoBitmap

  end;
end;

*)

////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
//              TCustomPascalTypePainterCanvas32
//
//------------------------------------------------------------------------------
constructor TPascalTypePainterCanvas32.Create(ACanvas: TCustomPath; AFillBrush: TSolidBrush = nil; AStrokeBrush: TStrokeBrush = nil);
begin
  inherited Create(ACanvas, AFillBrush, AStrokeBrush);
end;

{ TCustomPascalTypePainterCanvas32 }

constructor TCustomPascalTypePainterCanvas32.Create(ACanvas: TCustomPath; AFillBrush: TSolidBrush; AStrokeBrush: TStrokeBrush);
begin
  inherited Create;
  FCanvas := ACanvas;
  FFillBrush := AFillBrush;
  FStrokeBrush := AStrokeBrush;
end;

procedure TCustomPascalTypePainterCanvas32.BeginGlyph;
begin
  BeginUpdate;
end;

procedure TCustomPascalTypePainterCanvas32.EndGlyph;
begin
  EndUpdate;
end;

procedure TCustomPascalTypePainterCanvas32.BeginPath;
begin

end;

procedure TCustomPascalTypePainterCanvas32.EndPath(AClose: boolean);
begin
  Canvas.EndPath(AClose);
end;

procedure TCustomPascalTypePainterCanvas32.BeginUpdate;
begin
  Canvas.BeginUpdate;
end;

procedure TCustomPascalTypePainterCanvas32.EndUpdate;
begin
  Canvas.EndUpdate;
end;

procedure TCustomPascalTypePainterCanvas32.SetColor(Color: Cardinal);
begin
  if (FFillBrush <> nil) then
  begin
    FFillBrush.FillColor := (Color32(TColor(Color and $00FFFFFF)) and $00FFFFFF) or (Color and $FF000000);
    FFillBrush.Visible := (FFillBrush.FillColor and $FF000000 <> 0);
  end;
end;

function TCustomPascalTypePainterCanvas32.GetColor: Cardinal;
begin
  if (FFillBrush <> nil) then
    Result := Cardinal(WinColor(FFillBrush.FillColor) and $00FFFFFF) or Cardinal(FFillBrush.FillColor and $FF000000)
  else
    Result := $FF000000;
end;

procedure TCustomPascalTypePainterCanvas32.SetStrokeColor(Color: Cardinal);
begin
  if (FStrokeBrush <> nil) then
  begin
    FStrokeBrush.FillColor := (Color32(TColor(Color and $00FFFFFF)) and $00FFFFFF) or (Color and $FF000000);
    FStrokeBrush.Visible := (FStrokeBrush.FillColor and $FF000000 <> 0);
  end;
end;

function TCustomPascalTypePainterCanvas32.GetStrokeColor: Cardinal;
begin
  if (FStrokeBrush <> nil) then
    Result := Cardinal(WinColor(FStrokeBrush.FillColor) and $00FFFFFF) or Cardinal(FStrokeBrush.FillColor and $FF000000)
  else
    Result := $FF000000;
end;

procedure TCustomPascalTypePainterCanvas32.Circle(const p: TFloatPoint; Radius: TRenderFloat);
begin
  Canvas.Circle(p.X, p.Y, Radius);
end;

procedure TCustomPascalTypePainterCanvas32.CubicBezierTo(const ControlPoint1, ControlPoint2, p: TFloatPoint);
begin
  Canvas.CurveTo(ControlPoint1.X, ControlPoint1.Y, ControlPoint2.X, ControlPoint2.Y, p.X, p.Y);
end;

procedure TCustomPascalTypePainterCanvas32.LineTo(const p: TFloatPoint);
begin
  Canvas.LineTo(p.X, p.Y);
end;

procedure TCustomPascalTypePainterCanvas32.MoveTo(const p: TFloatPoint);
begin
  Canvas.MoveTo(p.X, p.Y);
end;

procedure TCustomPascalTypePainterCanvas32.QuadraticBezierTo(const ControlPoint, p: TFloatPoint);
begin
  Canvas.ConicTo(ControlPoint.X, ControlPoint.Y, p.X, p.Y);
end;

procedure TCustomPascalTypePainterCanvas32.Rectangle(const r: TFloatRect);
begin
  Canvas.Rectangle(GR32.FloatRect(r.Left, r.Top, r.Right, r.Bottom));
end;

//------------------------------------------------------------------------------
//
//              TPascalTypePainterBitmap32
//
//------------------------------------------------------------------------------
constructor TPascalTypePainterBitmap32.Create(ABitmap32: TBitmap32);
var
  BrushFill: TSolidBrush;
  BrushStroke: TStrokeBrush;
begin
  FCanvas32 := TCanvas32.Create(ABitmap32);

  BrushFill := FCanvas32.Brushes.Add(TSolidBrush) as TSolidBrush;
  BrushFill.FillColor := clBlack32;
  BrushFill.FillMode := pfNonZero;

  BrushStroke := FCanvas32.Brushes.Add(TStrokeBrush) as TStrokeBrush;
  BrushStroke.FillColor := 0;
  BrushStroke.StrokeWidth := 1;
  BrushStroke.JoinStyle := jsMiter;
  BrushStroke.EndStyle := esButt;
  BrushStroke.Visible := False;

  inherited Create(FCanvas32, BrushFill, BrushStroke);
end;

destructor TPascalTypePainterBitmap32.Destroy;
begin
  FCanvas32.Free;
  inherited;
end;

end.
