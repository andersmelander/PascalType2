unit PascalType.Renderer;

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
  Classes,
  Graphics,
  PascalType.Types,
  PascalType.Classes,
  PascalType.GlyphString,
  PascalType.Painter,
  PascalType.FontFace,
  PascalType.FontFace.SFNT;

type
  TFontPoint = packed record
    X, Y: TScaleType;
  end;

type
  TGlyphMetric = record
    HorizontalMetric: record
      AdvanceWidth: TScaleType;
      Bearing: TScaleType;
    end;
    VerticalMetric: record
      AdvanceHeight: TScaleType;
      TopSideBearing: TScaleType;
    end;
  end;

//------------------------------------------------------------------------------
//
//              TPascalTypeRenderer
//
//------------------------------------------------------------------------------
// A class that knows how to render a glyph
//------------------------------------------------------------------------------
type
  TPascalTypeFontMetric = record
    Origin: TFloatPoint;                // Offset of origin.
    Baseline: TRenderFloat;             // Base line. All the following are relative to to this value.
    Ascender: TRenderFloat;             // Ascender. Relative to baseline.
    Descender: TRenderFloat;            // Descender.
    XHeight: TRenderFloat;              // Height of minors.
    CapHeight: TRenderFloat;            // Height of majors.
    LineGap: TRenderFLoat;              // Line gap.
  end;

type
  TPascalTypeRenderOptions = set of (roPoints, roFill, roStroke, roColorize, roMetrics);

  TPascalTypeRenderVerticalOrigin = (
    voZero,                     // The normal baseline is used. Top of glyphs might be clipped.
    voAuto,                     // The baseline is adjusted based on glyph path points. Clipping will not occur.
    voTight,                    // The baseline is adjusted based on the font bounding box. Clipping should not occur.
    voCenter,                   // The baseline is shifted down half a line gap.
    voCustom                    // User specified origin value is used.
  );

  TPascalTypeRenderHorizontalOrigin = (
    hoZero,                     // First glyph starts at X=0. Left side of glyphs might be clipped.
    hoAuto,                     // First glyph is positioned so leftmost glyph path point start at x=0. Left side of glyph will not be clipped.
    hoTight,                    // First glyph is positioned so left side bearing starts at X=0. Left side of glyph should not be clipped.
    hoCustom                    // User specified origin value is used.
  );

  TPascalTypeRenderer = class(TInterfacedPersistent, IPascalTypeFontFaceNotification)
  strict private
    class var
      FDebugRectSize: Single;
      FDebugCircleRadius: Single;
      FDebugRectColor: Cardinal;
      FDebugCircleColor: Cardinal;
      FDebugFontMetricsColor: Cardinal;
      FDebugGlyphMetricsColor: Cardinal;
      FDebugGlyphPalette: TArray<Cardinal>;
  public
    class property DebugRectSize: Single read FDebugRectSize write FDebugRectSize;
    class property DebugCircleRadius: Single read FDebugCircleRadius write FDebugCircleRadius;
    class property DebugRectColor: Cardinal read FDebugRectColor write FDebugRectColor;
    class property DebugCircleColor: Cardinal read FDebugCircleColor write FDebugCircleColor;
    class property DebugFontMetricsColor: Cardinal read FDebugFontMetricsColor write FDebugFontMetricsColor;
    class property DebugGlyphMetricsColor: Cardinal read FDebugGlyphMetricsColor write FDebugGlyphMetricsColor;
    class property DebugGlyphPalette: TArray<Cardinal> read FDebugGlyphPalette write FDebugGlyphPalette;
  strict private type
    TRenderFlags = set of (rfHasScalerX, rfHasScalerY, rfHasMetrics);
  strict private
    FOptions: TPascalTypeRenderOptions;
    FFlags: TRenderFlags;
    FFontFace: TPascalTypeFontFace;
    FFontHeight: Integer;
    FPixelPerInchX: Integer;
    FPixelPerInchY: Integer;
    FScalerX: TScaleType;
    FScalerY: TScaleType;
    FVerticalOrigin: TPascalTypeRenderVerticalOrigin;
    FHorizontalOrigin: TPascalTypeRenderHorizontalOrigin;
    FFontMetrics: TPascalTypeFontMetric;
    FCustomOrigin: TFloatPoint;
    procedure SetFontSize(const Value: Integer);
    function GetFontSize: Integer;
    function GetPixelPerInch: Integer;
    procedure SetPixelPerInch(const Value: Integer);
    procedure SetPixelPerInchX(const Value: Integer);
    procedure SetPixelPerInchY(const Value: Integer);
    procedure SetFontHeight(const Value: Integer);
    procedure SetFontFace(const Value: TPascalTypeFontFace);
    procedure SetHorizontalOrigin(const Value: TPascalTypeRenderHorizontalOrigin);
    procedure SetVerticalOrigin(const Value: TPascalTypeRenderVerticalOrigin);
    procedure SetHorizontalOriginValue(const Value: TRenderFloat);
    procedure SetVerticalOriginValue(const Value: TRenderFloat);
    function GetHorizontalOriginValue: TRenderFloat;
    function GetVerticalOriginValue: TRenderFloat;
    function GetScalerX: TScaleType;
    function GetScalerY: TScaleType;
    function GetFontMetrics: TPascalTypeFontMetric;
  private
    // IPascalTypeFontFaceNotification
    procedure FontFaceNotification(Sender: TCustomPascalTypeFontFacePersistent; Notification: TFontFaceNotification);
  protected
    procedure CalculateScalerX;
    procedure CalculateScalerY;
    procedure CalculateMetrics;

    function GetGlyphMetric(GlyphIndex: Integer): TGlyphMetric;
    function GetAdvanceWidth(GlyphIndex: Integer): TScaleType;
    function GetKerning(Last, Next: Integer): TScaleType;

    procedure FontHeightChanged; virtual;
    procedure PixelPerInchXChanged; virtual;
    procedure PixelPerInchYChanged; virtual;
    procedure FontChanged;

    property ScalerX: TScaleType read GetScalerX;
    property ScalerY: TScaleType read GetScalerY;
    property FontMetrics: TPascalTypeFontMetric read GetFontMetrics;
  protected
    procedure RenderGlyph(GlyphIndex: Integer; const Painter: IPascalTypePainter; const Cursor: TFloatPoint);
    procedure RenderGlyphPath(const GlyphPath: TPascalTypePath; const Painter: IPascalTypePainter; const Cursor: TFloatPoint);

    procedure RenderDebugCircle(const Painter: IPascalTypePainter; const p: TFloatPoint);
    procedure RenderDebugRect(const Painter: IPascalTypePainter; const p: TFloatPoint);

    class constructor Create;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure RenderText(const Text: string; const Painter: IPascalTypePainter); overload;
    procedure RenderText(const Text: string; const Painter: IPascalTypePainter; var X, Y: TRenderFloat); overload;

    procedure RenderShapedText(ShapedText: TPascalTypeGlyphString; const Painter: IPascalTypePainter); overload;
    procedure RenderShapedText(ShapedText: TPascalTypeGlyphString; const Painter: IPascalTypePainter; var X, Y: TRenderFloat); overload;

    procedure RenderShapedGlyph(AGlyph: TPascalTypeGlyph; const Painter: IPascalTypePainter; var X, Y: TRenderFloat);

    property Options: TPascalTypeRenderOptions read FOptions write FOptions;
    property VerticalOrigin: TPascalTypeRenderVerticalOrigin read FVerticalOrigin write SetVerticalOrigin;
    property HorizontalOrigin: TPascalTypeRenderHorizontalOrigin read FHorizontalOrigin write SetHorizontalOrigin;
    property VerticalOriginValue: TRenderFloat read GetVerticalOriginValue write SetVerticalOriginValue;
    property HorizontalOriginValue: TRenderFloat read GetHorizontalOriginValue write SetHorizontalOriginValue;

    property FontFace: TPascalTypeFontFace read FFontFace write SetFontFace; // TODO : This ought to be TCustomPascalTypeFontFace
    property FontHeight: Integer read FFontHeight write SetFontHeight default -11;
    property FontSize: Integer read GetFontSize write SetFontSize stored False;
    property PixelPerInch: Integer read GetPixelPerInch write SetPixelPerInch default 96;
    property PixelPerInchX: Integer read FPixelPerInchX write SetPixelPerInchX default 96;
    property PixelPerInchY: Integer read FPixelPerInchY write SetPixelPerInchY default 96;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  Math,
  PascalType.Tables.TrueType.glyf,
  PascalType.ResourceStrings;

//------------------------------------------------------------------------------
//
//              TPascalTypeRenderer
//
//------------------------------------------------------------------------------
class constructor TPascalTypeRenderer.Create;
begin
  FDebugCircleRadius := 2.0;
  FDebugRectSize := 2.0;
  FDebugCircleColor := Cardinal(clRed) or $A0000000;
  FDebugRectColor := Cardinal(clBlue) or $A0000000;
  FDebugFontMetricsColor := Cardinal(clSkyBlue) or $B0000000;
  FDebugGlyphMetricsColor := Cardinal(clGreen) or $B0000000;
  FDebugGlyphPalette := [$FF233BC2, $FF529cc7, $FF52DAEA, $FF3CC003, $FFBE9A57, $FFD76E97];
end;

constructor TPascalTypeRenderer.Create;
begin
  inherited;

  FPixelPerInchX := 96;
  FPixelPerInchY := 96;

  FFontHeight := -11;
end;

destructor TPascalTypeRenderer.Destroy;
begin
  inherited;
end;

procedure TPascalTypeRenderer.SetFontFace(const Value: TPascalTypeFontFace);
begin
  if (FFontFace = Value) then
    exit;

  if (FFontFace <> nil) then
    FFontFace.Unsubscribe(Self);

  FFontFace := Value;

  if (FFontFace <> nil) then
    FFontFace.Subscribe(Self);

  FontChanged;
end;

procedure TPascalTypeRenderer.PixelPerInchXChanged;
begin
  // nothing in here yet (trigger recalculation of cache here soon!)
end;

procedure TPascalTypeRenderer.PixelPerInchYChanged;
begin
  // nothing in here yet (trigger recalculation of cache here soon!)
end;

procedure TPascalTypeRenderer.RenderDebugCircle(const Painter: IPascalTypePainter; const p: TFloatPoint);
begin
  Painter.BeginPath;
  Painter.SetColor(FDebugCircleColor);
  Painter.Circle(p, DebugCircleRadius);
  Painter.EndPath(True);
end;

procedure TPascalTypeRenderer.RenderDebugRect(const Painter: IPascalTypePainter; const p: TFloatPoint);
var
  r: TFloatRect;
begin
  Painter.BeginPath;
  Painter.SetColor(FDebugRectColor);
  r.TopLeft := p;
  r.BottomRight := p;
  r.Inflate(DebugRectSize, DebugRectSize);
  Painter.Rectangle(r);
  Painter.EndPath(True);
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

procedure TPascalTypeRenderer.RenderGlyphPath(const GlyphPath: TPascalTypePath; const Painter: IPascalTypePainter; const Cursor: TFloatPoint);
var
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
  if (Length(GlyphPath) = 0) then
    exit;

  Origin.X := Cursor.X + FontMetrics.Origin.X;
  Origin.Y := Cursor.Y + FontMetrics.Origin.Y + FontMetrics.Baseline;

  if (not (roPoints in FOptions)) then
    Painter.BeginGlyph;

  for Contour in GlyphPath do
  begin
    if (Length(Contour) < 2) then
      continue;

    CurrentPoint.X := Origin.X + Contour[0].XPos * ScalerX;
{$ifdef Inverse_Y_axis}
    CurrentPoint.Y := Origin.Y - Contour[0].YPos * ScalerY;
{$else Inverse_Y_axis}
    CurrentPoint.Y := Origin.Y + Contour[0].YPos * ScalerY;
{$endif Inverse_Y_axis}

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
{$ifdef Inverse_Y_axis}
        CurrentPoint.Y := Origin.Y - Contour[High(Contour)].YPos * ScalerY;
{$else Inverse_Y_axis}
        CurrentPoint.Y := Origin.Y + Contour[High(Contour)].YPos * ScalerY;
{$endif Inverse_Y_axis}
      end else
      begin
        // Both first and last points are control-points.
        // Synthesize a curve-point in between the two control-points.
        // Seen with: SimSun-ExtB, small letter "a"
        CurrentPoint.X := Origin.X + (Contour[0].XPos + Contour[High(Contour)].XPos) * 0.5 * ScalerX;
{$ifdef Inverse_Y_axis}
        CurrentPoint.Y := Origin.Y - (Contour[0].YPos + Contour[High(Contour)].YPos) * 0.5 * ScalerY;
{$else Inverse_Y_axis}
        CurrentPoint.Y := Origin.Y + (Contour[0].YPos + Contour[High(Contour)].YPos) * 0.5 * ScalerY;
{$endif Inverse_Y_axis}
      end;
      PathState := psControl;
    end;

    // Move to the first curve-point (the one we just found above)
    if (not (roPoints in FOptions)) then
      Painter.BeginPath;

    if (roPoints in FOptions) then
      RenderDebugCircle(Painter, CurrentPoint)
    else
      Painter.MoveTo(CurrentPoint);

    // Note that PointIndex wraps around to zero
    PointIndex := 1;
    for i := 0 to High(Contour) do
    begin
      // Get the next point
      CurrentPoint.X := Origin.X + Contour[PointIndex].XPos * ScalerX;
{$ifdef Inverse_Y_axis}
      CurrentPoint.Y := Origin.Y - Contour[PointIndex].YPos * ScalerY;
{$else Inverse_Y_axis}
      CurrentPoint.Y := Origin.Y + Contour[PointIndex].YPos * ScalerY;
{$endif Inverse_Y_axis}

      // Is it a curve-point?
      IsOnCurve := (Contour[PointIndex].Flags and TTrueTypeFontSimpleGlyphData.GLYF_ON_CURVE <> 0);

      StateTransition := StateMachine[IsOnCurve, PathState];
      PathState := StateTransition.NextState;

      case StateTransition.Emit of
        emitNone:
          begin
            ControlPoint := CurrentPoint;
            if (roPoints in FOptions) then
              RenderDebugRect(Painter, ControlPoint);
          end;

        emitLine:
          begin
            if (roPoints in FOptions) then
              RenderDebugCircle(Painter, CurrentPoint)
            else
              Painter.LineTo(CurrentPoint);
          end;

        emitQuadratic:
          begin
            if (roPoints in FOptions) then
              RenderDebugCircle(Painter, CurrentPoint)
            else
              Painter.QuadraticBezierTo(ControlPoint, CurrentPoint);
          end;

        emitHalfway:
          begin
            MidPoint.X := (ControlPoint.X + CurrentPoint.X) * 0.5;
            MidPoint.Y := (ControlPoint.Y + CurrentPoint.Y) * 0.5;
            if (roPoints in FOptions) then
            begin
              RenderDebugCircle(Painter, MidPoint);
              RenderDebugRect(Painter, CurrentPoint);
            end else
              Painter.QuadraticBezierTo(ControlPoint, MidPoint);
            ControlPoint := CurrentPoint;
          end;
      end;
      PointIndex := (PointIndex + 1) mod Length(Contour);
    end;

    if (not (roPoints in FOptions)) then
      Painter.EndPath(True);
  end;

  if (not (roPoints in FOptions)) then
    Painter.EndGlyph;
end;

procedure TPascalTypeRenderer.RenderGlyph(GlyphIndex: Integer; const Painter: IPascalTypePainter; const Cursor: TFloatPoint);
var
  GlyphPath: TPascalTypePath;
begin
  GlyphPath := FontFace.GetGlyphPath(GlyphIndex);
  RenderGlyphPath(GlyphPath, Painter, Cursor);
end;

procedure TPascalTypeRenderer.RenderShapedGlyph(AGlyph: TPascalTypeGlyph; const Painter: IPascalTypePainter; var X, Y: TRenderFloat);
var
  Cursor: TFloatPoint;
begin
  if (FontFace = nil) then
    exit;

  // Position glyph relative to cursor
  Cursor.X := X + ScalerX * AGlyph.XOffset;
{$ifdef Inverse_Y_axis}
  Cursor.Y := Y - ScalerY * AGlyph.YOffset;
{$else Inverse_Y_axis}
  Cursor.Y := Y + ScalerY * AGlyph.YOffset;
{$endif Inverse_Y_axis}

  // Rasterize glyph
  RenderGlyph(AGlyph.GlyphID, Painter, Cursor);

  // Advance cursor
  X := X + ScalerX * AGlyph.XAdvance;
  Y := Y + ScalerY * AGlyph.YAdvance;
end;

procedure TPascalTypeRenderer.RenderShapedText(ShapedText: TPascalTypeGlyphString; const Painter: IPascalTypePainter);
var
  X, Y: TRenderFloat;
begin
  X := 0;
  Y := 0;
  RenderShapedText(ShapedText, Painter, X, Y);
end;

procedure TPascalTypeRenderer.RenderShapedText(ShapedText: TPascalTypeGlyphString; const Painter: IPascalTypePainter; var X, Y: TRenderFloat);
var
  OriginX: TRenderFloat;

  function FloatPoint(X, Y: TRenderFloat): TFloatPoint;
  begin
    Result.X := X;
    Result.Y := Y;
  end;

  procedure DrawLineHorizontal(X1, X2, Y: TRenderFloat; const Caption: string = '');
  begin
    Painter.BeginPath;

    Painter.MoveTo(FloatPoint(X1, Y));
    Painter.LineTo(FloatPoint(X2, Y));

    Painter.EndPath(False);
  end;

  procedure DrawGlyphMetrics;
  var
    Cursor: TFloatPoint;
    StartX, StartY: TRenderFloat;
    i: integer;
    Glyph: TPascalTypeGlyph;
  begin
    Cursor.X := X + FontMetrics.Origin.X + OriginX;
    Cursor.Y := Y + FontMetrics.Origin.Y + FontMetrics.Baseline;

    for i := 0 to ShapedText.Count-1 do
    begin
      Glyph := ShapedText[i];

      // Position glyph relative to cursor
      StartX := Cursor.X + ScalerX * Glyph.XOffset;
    {$ifdef Inverse_Y_axis}
      StartY := Cursor.Y - ScalerY * Glyph.YOffset;
    {$else Inverse_Y_axis}
      StartY := Cursor.Y + ScalerY * Glyph.YOffset;
    {$endif Inverse_Y_axis}

      Painter.BeginPath;
      Painter.MoveTo(FloatPoint(StartX, StartY-5));
      Painter.LineTo(FloatPoint(StartX, StartY));
      Painter.LineTo(FloatPoint(StartX+5, StartY));
      Painter.EndPath(False);

      // Advance cursor
      Cursor.X := Cursor.X + ScalerX * Glyph.XAdvance;
      Cursor.Y := Cursor.Y + ScalerY * Glyph.YAdvance;

      Painter.BeginPath;
      Painter.MoveTo(FloatPoint(Cursor.X-5, Cursor.Y));
      Painter.LineTo(Cursor);
      Painter.LineTo(FloatPoint(Cursor.X, Cursor.Y+5));
      Painter.EndPath(False);
    end;
  end;

var
  Cursor: TFloatPoint;
  SaveColor: Cardinal;
  i: integer;
begin
  if (FontFace = nil) then
    exit;

  if (ShapedText.Count = 0) then
    exit;

  Cursor.X := X;
  Cursor.Y := Y;

  if (FHorizontalOrigin = hoTight) and (FontFace.HorizontalMetrics <> nil) then
  begin
    // If 'hmtx' table contains fewer entries that there are glyphs, then the last
    // entry repeats.
    i := Min(ShapedText[0].GlyphID, FontFace.HorizontalMetrics.HorizontalMetricCount-1);
    OriginX := -FontFace.HorizontalMetrics[i].Bearing * ScalerX;
    Cursor.X := Cursor.X + OriginX;
  end else
    OriginX := 0;

  SaveColor := 0;
  if (roColorize in FOptions) then
    SaveColor := Painter.Color
  else
  if (not (roPoints in FOptions)) then // rmPoints needs to be able to draw each point in a different color
    Painter.BeginUpdate;
  try

    for i := 0 to ShapedText.Count-1 do
    begin
      if (roColorize in FOptions) then
        Painter.Color := FDebugGlyphPalette[i mod Length(FDebugGlyphPalette)];

      RenderShapedGlyph(ShapedText[i], Painter, Cursor.X, Cursor.Y);
    end;

  finally
    if (roColorize in FOptions) then
      Painter.Color := SaveColor
    else
    if (not (roPoints in FOptions)) then
      Painter.EndUpdate;
  end;

  if (roMetrics in FOptions) then
  begin
    SaveColor := Painter.Color;
    Painter.Color := 0;
    Painter.StrokeColor := DebugFontMetricsColor;
//    Painter.BeginUpdate;

    // Baseline
    DrawLineHorizontal(X, Cursor.X, FontMetrics.Origin.Y + FontMetrics.Baseline, 'baseline');

    // Ascentder
    if (FontMetrics.Baseline <> FontMetrics.Ascender) then
      DrawLineHorizontal(X, Cursor.X, FontMetrics.Origin.Y + FontMetrics.Baseline - FontMetrics.Ascender, 'ascender height');

    // Descender
    DrawLineHorizontal(X, Cursor.X, FontMetrics.Origin.Y + FontMetrics.Baseline + FontMetrics.Descender, 'descender depth');

    // LineGap
    if (FontMetrics.LineGap <> 0) then
      DrawLineHorizontal(X, Cursor.X, FontMetrics.Origin.Y + FontMetrics.Baseline + FontMetrics.LineGap, 'Line gap');

    // Lower- and uppercase heights
    if (FontMetrics.XHeight <> 0) then
      DrawLineHorizontal(X, Cursor.X, FontMetrics.Origin.Y + FontMetrics.Baseline - FontMetrics.XHeight, 'x-height');
    if (FontMetrics.CapHeight <> 0) then
      DrawLineHorizontal(X, Cursor.X, FontMetrics.Origin.Y + FontMetrics.Baseline - FontMetrics.CapHeight, 'cap height');

    // Glyph metrics
    Painter.StrokeColor := DebugGlyphMetricsColor;
    DrawGlyphMetrics;

//    Painter.EndUpdate;
    Painter.StrokeColor := 0;
    Painter.Color := SaveColor
  end;

  X := Cursor.X;
  Y := Cursor.Y;
end;

procedure TPascalTypeRenderer.RenderText(const Text: string; const Painter: IPascalTypePainter);
var
  X, Y: TRenderFloat;
begin
  X := 0;
  Y := 0;
  RenderText(Text, Painter, X, Y);
end;

procedure TPascalTypeRenderer.RenderText(const Text: string; const Painter: IPascalTypePainter; var X, Y: TRenderFloat);
var
  CharIndex: Integer;
  GlyphIndex: Integer;
  Cursor: TFloatPoint;
  GlyphMetric: TGlyphMetric;
  SaveColor: Cardinal;
begin
  if (FontFace = nil) then
    exit;

  Cursor.X := X;
  Cursor.Y := Y;

  SaveColor := 0;
  if (roColorize in FOptions) then
    SaveColor := Painter.Color
  else
    Painter.BeginUpdate;
  try

    for CharIndex := 1 to Length(Text) do
    begin
      if Text[CharIndex] <= #31 then
      begin
        case Text[CharIndex] of
          #10: ;// handle CR
          #13: ;// handle LF
        end;
      end else
      begin
        if (roColorize in FOptions) then
          Painter.Color := FDebugGlyphPalette[(CharIndex-1) mod Length(FDebugGlyphPalette)];

        // Get glyph index
        GlyphIndex := FontFace.GetGlyphByCharacter(Text[CharIndex]);

        // Rasterize character
        RenderGlyph(GlyphIndex, Painter, Cursor);

        // Aadvance cursor
        GlyphMetric := GetGlyphMetric(GlyphIndex);
        Cursor.X := Cursor.X + GlyphMetric.HorizontalMetric.AdvanceWidth;
      end;
    end;

  finally
    if (roColorize in FOptions) then
      Painter.Color := SaveColor
    else
      Painter.EndUpdate;
  end;

  X := Cursor.X;
  Y := Cursor.Y;
end;

procedure TPascalTypeRenderer.FontChanged;
begin
  Exclude(FFlags, rfHasScalerX);
  Exclude(FFlags, rfHasScalerY);
  Exclude(FFlags, rfHasMetrics);
end;

procedure TPascalTypeRenderer.FontFaceNotification(Sender: TCustomPascalTypeFontFacePersistent; Notification: TFontFaceNotification);
begin
  case Notification of
    fnDestroy:
      FontFace := nil;

    fnChanged:
      FontChanged;
  end;
end;

procedure TPascalTypeRenderer.FontHeightChanged;
begin
  Exclude(FFlags, rfHasScalerX);
  Exclude(FFlags, rfHasScalerY);
  Exclude(FFlags, rfHasMetrics);
end;

procedure TPascalTypeRenderer.CalculateMetrics;
var
  LineGap: TRenderFLoat;
begin
  if (rfHasMetrics in FFlags) then
    exit;
  Include(FFlags, rfHasMetrics);

  FFontMetrics := Default(TPascalTypeFontMetric);

  if (FontFace.OS2Table <> nil) then
  begin
    if (fsfUseTypoMetrics in FontFace.OS2Table.FontSelectionFlags) then
    begin
      FFontMetrics.Baseline := FontFace.OS2Table.TypographicAscent * ScalerY;
      FFontMetrics.Descender := -FontFace.OS2Table.TypographicDescent * ScalerY;
    end else
    begin
      FFontMetrics.Baseline := FontFace.OS2Table.WindowsAscent * ScalerY;
      FFontMetrics.Descender := FontFace.OS2Table.WindowsDescent * ScalerY;
    end;

    FFontMetrics.Ascender := Min(FontFace.OS2Table.TypographicAscent, FontFace.OS2Table.WindowsAscent) * ScalerY;

    if (FontFace.OS2Table.AddendumTable <> nil) then
    begin
      FFontMetrics.XHeight := FontFace.OS2Table.AddendumTable.XHeight * ScalerY;
      FFontMetrics.CapHeight := FontFace.OS2Table.AddendumTable.CapHeight * ScalerY;
    end;
  end else
  if (FontFace.HorizontalHeader <> nil) then
  begin
    FFontMetrics.Baseline := FontFace.HorizontalHeader.Ascent * ScalerY;
    FFontMetrics.Ascender := FFontMetrics.Baseline;
    FFontMetrics.Descender := -FontFace.HorizontalHeader.Descent * ScalerY;
  end else
  begin
    FFontMetrics.Baseline := FontFace.HeaderTable.YMax * ScalerY;
    FFontMetrics.Ascender := FFontMetrics.Baseline;
    FFontMetrics.Descender := -FontFace.HeaderTable.YMin * ScalerY;
  end;

  if (FontFace.OS2Table <> nil) and (fsfUseTypoMetrics in FontFace.OS2Table.FontSelectionFlags) then
  begin
    LineGap := FontFace.OS2Table.TypographicLineGap * ScalerY;
    FFontMetrics.LineGap := FFontMetrics.Descender + LineGap;
  end else
  if (FontFace.HorizontalHeader <> nil) then
  begin
    LineGap := FontFace.HorizontalHeader.LineGap * ScalerY;
    FFontMetrics.LineGap := FFontMetrics.Descender + LineGap;
  end else
    LineGap := 0;

  case FVerticalOrigin of
    voAuto:
      // TODO : Doesn't really work. We will need to examine the individual glyphs.
      // FFontMetrics.Origin.Y := Max(FontFace.OS2Table.TypographicAscent, FontFace.OS2Table.WindowsAscent) * ScalerY - FFontMetrics.Ascent;
      ; // TODO : Not implemented

    voTight:
      FFontMetrics.Origin.Y := FontFace.HeaderTable.YMax * ScalerY - FFontMetrics.Baseline;

    voCenter:
      // The following is based on https://glyphsapp.com/learn/vertical-metrics#g-the-webfontstrategy-2019
      FFontMetrics.Origin.Y := LineGap / 2;

    voCustom:
      FFontMetrics.Origin.Y := FCustomOrigin.Y;
  end;

  case FHorizontalOrigin of
    hoAuto:
      ; // TODO : Not implemented

    hoCustom:
      FFontMetrics.Origin.X := FCustomOrigin.X;
  end;
end;

procedure TPascalTypeRenderer.CalculateScalerX;
begin
  Include(FFlags, rfHasScalerX);
{$IFDEF UseFloatingPoint}
  if (FFontFace <> nil) and (FFontFace.HeaderTable <> nil) then // We might get called before font has been assigned/loaded
    FScalerX := Abs(FFontHeight / FFontFace.HeaderTable.UnitsPerEm)
  else
    FScalerX := 1.0;
{$ENDIF}
end;

procedure TPascalTypeRenderer.CalculateScalerY;
begin
  Include(FFlags, rfHasScalerY);
{$IFDEF UseFloatingPoint}
  if (FFontFace <> nil) and (FFontFace.HeaderTable <> nil) then // We might get called before font has been assigned/loaded
    FScalerY := Abs(FFontHeight / FFontFace.HeaderTable.UnitsPerEm)
  else
    FScalerY := 1.0;
{$ENDIF}
end;

function TPascalTypeRenderer.GetAdvanceWidth(GlyphIndex: Integer): TScaleType;
begin
  Result := ScalerX * FontFace.GetAdvanceWidth(GlyphIndex);
end;

function TPascalTypeRenderer.GetFontMetrics: TPascalTypeFontMetric;
begin
  if (not (rfHasMetrics in FFlags)) then
    CalculateMetrics;
  Result := FFontMetrics;
end;

function TPascalTypeRenderer.GetFontSize: Integer;
begin
  Result := -Int64(FFontHeight * 72) div FPixelPerInchY;
end;

function TPascalTypeRenderer.GetGlyphMetric(GlyphIndex: Integer): TGlyphMetric;
var
  TrueTypeGlyphMetric: TTrueTypeGlyphMetric;
begin
  TrueTypeGlyphMetric := FontFace.GetGlyphMetric(GlyphIndex);

  Result.HorizontalMetric.AdvanceWidth := ScalerX * TrueTypeGlyphMetric.HorizontalMetric.AdvanceWidth;
  Result.HorizontalMetric.Bearing := ScalerX * TrueTypeGlyphMetric.HorizontalMetric.AdvanceWidth;
  Result.VerticalMetric.AdvanceHeight := ScalerY * TrueTypeGlyphMetric.VerticalMetric.AdvanceHeight;
  Result.VerticalMetric.TopSideBearing := ScalerY * TrueTypeGlyphMetric.VerticalMetric.TopSideBearing;
end;

function TPascalTypeRenderer.GetHorizontalOriginValue: TRenderFloat;
begin
  Result := FontMetrics.Origin.X;
end;

function TPascalTypeRenderer.GetKerning(Last, Next: Integer): TScaleType;
begin
  Result := ScalerX * FontFace.GetKerning(Last, Next);
end;

function TPascalTypeRenderer.GetPixelPerInch: Integer;
begin
  Result := (FPixelPerInchX + FPixelPerInchY) div 2;
end;

function TPascalTypeRenderer.GetScalerX: TScaleType;
begin
  if (not (rfHasScalerX in FFlags)) then
    CalculateScalerX;
  Result := FScalerX;
end;

function TPascalTypeRenderer.GetScalerY: TScaleType;
begin
  if (not (rfHasScalerY in FFlags)) then
    CalculateScalerY;
  Result := FScalerY;
end;

function TPascalTypeRenderer.GetVerticalOriginValue: TRenderFloat;
begin
  Result := FontMetrics.Origin.Y;
end;

procedure TPascalTypeRenderer.SetFontSize(const Value: Integer);
begin
  FontHeight := -Int64(Value * FPixelPerInchY) div 72;
end;

procedure TPascalTypeRenderer.SetHorizontalOrigin(const Value: TPascalTypeRenderHorizontalOrigin);
begin
  if (FHorizontalOrigin = Value) then
    exit;
  FHorizontalOrigin := Value;
  Exclude(FFlags, rfHasMetrics);
end;

procedure TPascalTypeRenderer.SetHorizontalOriginValue(const Value: TRenderFloat);
begin
  FCustomOrigin.X := Value;
  FFontMetrics.Origin.X := Value;
  FHorizontalOrigin := hoCustom;
end;

procedure TPascalTypeRenderer.SetFontHeight(const Value: Integer);
begin
  if FFontHeight <> Value then
  begin
    FFontHeight := Value;
    FontHeightChanged;
  end;
end;

procedure TPascalTypeRenderer.SetPixelPerInch(const Value: Integer);
begin
  if (FPixelPerInchX = Value) and (FPixelPerInchY = Value) then
    exit;

  PixelPerInchX := Value;
  PixelPerInchY := Value;
end;

procedure TPascalTypeRenderer.SetPixelPerInchX(const Value: Integer);
begin
  if FPixelPerInchX <> Value then
  begin
    FPixelPerInchX := Value;
    PixelPerInchXChanged;
  end;
end;

procedure TPascalTypeRenderer.SetPixelPerInchY(const Value: Integer);
begin
  if FPixelPerInchY <> Value then
  begin
    FPixelPerInchY := Value;
    PixelPerInchYChanged;
  end;
end;

procedure TPascalTypeRenderer.SetVerticalOrigin(const Value: TPascalTypeRenderVerticalOrigin);
begin
  if (FVerticalOrigin = Value) then
    exit;
  FVerticalOrigin := Value;
  Exclude(FFlags, rfHasMetrics);
end;

procedure TPascalTypeRenderer.SetVerticalOriginValue(const Value: TRenderFloat);
begin
  FCustomOrigin.Y := Value;
  FFontMetrics.Origin.Y := Value;
  FVerticalOrigin := voCustom;
end;

end.

