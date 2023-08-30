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
  TPascalTypeRenderMode = (rmNormal, rmPoints);

  TPascalTypeRenderer = class(TInterfacedPersistent)
  strict private
    class var
      FDebugRectSize: Single;
      FDebugCircleRadius: Single;
      FDebugRectColor: Cardinal;
      FDebugCircleColor: Cardinal;
  public
    class property DebugRectSize: Single read FDebugRectSize write FDebugRectSize;
    class property DebugCircleRadius: Single read FDebugCircleRadius write FDebugCircleRadius;
    class property DebugRectColor: Cardinal read FDebugRectColor write FDebugRectColor;
    class property DebugCircleColor: Cardinal read FDebugCircleColor write FDebugCircleColor;
  strict private
    FRenderMode: TPascalTypeRenderMode;
    FFontFace: TPascalTypeFontFace;
    FFontHeight: Integer;
    FPixelPerInchX: Integer;
    FPixelPerInchY: Integer;
    FScalerX: TScaleType;
    FScalerY: TScaleType;
    procedure SetFontSize(const Value: Integer);
    procedure SetPixelPerInchX(const Value: Integer);
    procedure SetPixelPerInchY(const Value: Integer);
    procedure SetFontHeight(const Value: Integer);
    function GetFontSize: Integer;
    procedure SetFontFace(const Value: TPascalTypeFontFace);
    function GetPixelPerInch: Integer;
    procedure SetPixelPerInch(const Value: Integer);
  protected
    procedure CalculateScaler;
    procedure CalculateScalerX;
    procedure CalculateScalerY;

    function RoundedScaleX(Value: Integer): Integer;
    function RoundedScaleY(Value: Integer): Integer;

    function GetGlyphMetric(GlyphIndex: Integer): TGlyphMetric;
    function GetAdvanceWidth(GlyphIndex: Integer): TScaleType;
    function GetKerning(Last, Next: Integer): TScaleType;

    procedure FontHeightChanged; virtual;
    procedure PixelPerInchXChanged; virtual;
    procedure PixelPerInchYChanged; virtual;

    property ScalerX: TScaleType read FScalerX;
    property ScalerY: TScaleType read FScalerY;

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

    property RenderMode: TPascalTypeRenderMode read FRenderMode write FRenderMode;

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
  FDebugCircleColor := Cardinal(clRed) or $7F000000;
  FDebugRectColor := Cardinal(clBlue) or $7F000000;
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

  FFontFace := Value;

  // calculate font depenent variables
  CalculateScaler;
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
  Painter.EndPath;
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
  Painter.EndPath;
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
  if (Length(GlyphPath) = 0) then
    exit;

  Ascent := Max(TPascalTypeFontFace(FontFace).HeaderTable.YMax, TPascalTypeFontFace(FontFace).HorizontalHeader.Ascent);
  Origin.X := Cursor.X;
  Origin.Y := Cursor.Y + Ascent * ScalerY;

  if (FRenderMode <> rmPoints) then
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
    if (FRenderMode <> rmPoints) then
      Painter.BeginPath;

    if (FRenderMode = rmPoints) then
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
            if (FRenderMode = rmPoints) then
              RenderDebugRect(Painter, ControlPoint);
          end;

        emitLine:
          begin
            if (FRenderMode = rmPoints) then
              RenderDebugCircle(Painter, CurrentPoint)
            else
              Painter.LineTo(CurrentPoint);
          end;

        emitQuadratic:
          begin
            if (FRenderMode = rmPoints) then
              RenderDebugCircle(Painter, CurrentPoint)
            else
              Painter.QuadraticBezierTo(ControlPoint, CurrentPoint);
          end;

        emitHalfway:
          begin
            MidPoint.X := (ControlPoint.X + CurrentPoint.X) * 0.5;
            MidPoint.Y := (ControlPoint.Y + CurrentPoint.Y) * 0.5;
            if (FRenderMode = rmPoints) then
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

    if (FRenderMode <> rmPoints) then
      Painter.EndPath;
  end;

  if (FRenderMode <> rmPoints) then
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
  // Position glyph relative to cursor
  Cursor.X := X + ScalerX * AGlyph.XOffset;
{$ifdef Inverse_Y_axis}
  Cursor.Y := Y - ScalerY * AGlyph.YOffset;
{$else Inverse_Y_axis}
  Cursor.Y := Y + ScalerY * Glyph.YOffset;
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
  Cursor: TFloatPoint;
  Glyph: TPascalTypeGlyph;
begin
  Cursor.X := X;
  Cursor.Y := Y;

  if (FRenderMode <> rmPoints) then // rmPoints needs to be able to draw each point in a different color
    Painter.BeginUpdate;
  try

    for Glyph in ShapedText do
      RenderShapedGlyph(Glyph, Painter, Cursor.X, Cursor.Y);

  finally
    if (FRenderMode <> rmPoints) then
      Painter.EndUpdate;
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
begin
  Cursor.X := X;
  Cursor.Y := Y;

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
    Painter.EndUpdate;
  end;

  X := Cursor.X;
  Y := Cursor.Y;
end;

function TPascalTypeRenderer.RoundedScaleX(Value: Integer): Integer;
begin
{$IFDEF UseFloatingPoint}
  Result := Round(Value * ScalerX);
{$ELSE}
  Result := Int64(Value shl 6 * ScalerX) shr 6;
{$ENDIF}
end;

function TPascalTypeRenderer.RoundedScaleY(Value: Integer): Integer;
begin
{$IFDEF UseFloatingPoint}
  Result := Round(Value * ScalerY);
{$ELSE}
  Result := Int64(Value shl 6 * ScalerY) shr 6;
{$ENDIF}
end;

procedure TPascalTypeRenderer.FontHeightChanged;
begin
  CalculateScaler;
end;

procedure TPascalTypeRenderer.CalculateScaler;
begin
  CalculateScalerX;
  CalculateScalerY;
end;

procedure TPascalTypeRenderer.CalculateScalerX;
begin
{$IFDEF UseFloatingPoint}
  if (FFontFace.HeaderTable <> nil) then // We might get called before font has been loaded
    FScalerX := Abs(FFontHeight / FFontFace.HeaderTable.UnitsPerEm)
  else
    FScalerX := 1.0;
{$ENDIF}
end;

procedure TPascalTypeRenderer.CalculateScalerY;
begin
{$IFDEF UseFloatingPoint}
  if (FFontFace.HeaderTable <> nil) then // We might get called before font has been loaded
    FScalerY := Abs(FFontHeight / FFontFace.HeaderTable.UnitsPerEm)
  else
    FScalerY := 1.0;
{$ENDIF}
end;

function TPascalTypeRenderer.GetAdvanceWidth(GlyphIndex: Integer): TScaleType;
begin
  Result := ScalerX * FontFace.GetAdvanceWidth(GlyphIndex);
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

function TPascalTypeRenderer.GetKerning(Last, Next: Integer): TScaleType;
begin
  Result := ScalerX * FontFace.GetKerning(Last, Next);
end;

function TPascalTypeRenderer.GetPixelPerInch: Integer;
begin
  Result := (FPixelPerInchX + FPixelPerInchY) div 2;
end;

procedure TPascalTypeRenderer.SetFontSize(const Value: Integer);
begin
  FontHeight := -Int64(Value * FPixelPerInchY) div 72;
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

end.

