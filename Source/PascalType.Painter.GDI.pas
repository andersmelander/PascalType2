unit PascalType.Painter.GDI;

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

uses
  {$IFDEF FPC}LCLIntf, LCLType, {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  {$ELSE}Windows, {$ENDIF} Classes, Sysutils, Graphics,
  PascalType.Types,
  PascalType.FontFace,
  PascalType.Painter,
  PascalType.Tables,
  PascalType.Tables.TrueType,
  PascalType.Tables.TrueType.glyf;

//------------------------------------------------------------------------------
//
//              TPascalTypePainterGDI
//
//------------------------------------------------------------------------------
// GDI font rasterizer
//------------------------------------------------------------------------------
type
  TPascalTypePainterGDI = class abstract(TInterfacedObject, IPascalTypePainter)
  private
    FCanvas: TCanvas;
  protected
    property Canvas: TCanvas read FCanvas;
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

  public
    constructor Create(ACanvas: TCanvas);
  end;

implementation

uses
  UITypes,
  Math,
  PascalType.FontFace.SFNT,
  PascalType.Tables.TrueType.hhea;

//------------------------------------------------------------------------------
//
//              TPascalTypePainterGDI
//
//------------------------------------------------------------------------------
constructor TPascalTypePainterGDI.Create(ACanvas: TCanvas);
begin
  inherited Create;
  FCanvas := ACanvas;
  FCanvas.Brush.Color := clBlack;
  FCanvas.Brush.Style := bsSolid;
  Windows.SetPolyFillMode(FCanvas.Handle, WINDING);
end;

procedure TPascalTypePainterGDI.BeginGlyph;
begin
  Windows.BeginPath(FCanvas.Handle);
end;

procedure TPascalTypePainterGDI.EndGlyph;
begin
  Windows.EndPath(FCanvas.Handle);
  Windows.FillPath(FCanvas.Handle);
end;

procedure TPascalTypePainterGDI.BeginPath;
begin
end;

procedure TPascalTypePainterGDI.EndPath(AClose: boolean);
begin
  if (AClose) then
    Windows.CloseFigure(FCanvas.Handle);
end;

procedure TPascalTypePainterGDI.BeginUpdate;
begin
end;

procedure TPascalTypePainterGDI.EndUpdate;
begin
end;

procedure TPascalTypePainterGDI.SetColor(Color: Cardinal);
begin
  Canvas.Brush.Color := Color and $00FFFFFF;
end;

function TPascalTypePainterGDI.GetColor: Cardinal;
begin
  Result := Cardinal(Canvas.Brush.Color) or $FF000000;
end;

procedure TPascalTypePainterGDI.SetStrokeColor(Color: Cardinal);
begin
  Canvas.Pen.Color := Color and $00FFFFFF;
end;

function TPascalTypePainterGDI.GetStrokeColor: Cardinal;
begin
  Result := Cardinal(Canvas.Pen.Color) or $FF000000;
end;

procedure TPascalTypePainterGDI.Circle(const p: TFloatPoint; Radius: TRenderFloat);
var
  r: TRect;
begin
  r.Left := Floor(p.X - Radius);
  r.Top := Floor(p.Y - Radius);
  r.Right := Ceil(p.X + Radius);
  r.Bottom := Ceil(p.Y + Radius);
  Canvas.Ellipse(r);
end;

procedure TPascalTypePainterGDI.CubicBezierTo(const ControlPoint1, ControlPoint2, p: TFloatPoint);
var
  cp1, cp2, pp: TPoint;
begin
  cp1.X := Round(ControlPoint1.X);
  cp1.Y := Round(ControlPoint1.Y);
  cp2.X := Round(ControlPoint2.X);
  cp2.Y := Round(ControlPoint2.Y);
  pp.X := Round(p.X);
  pp.Y := Round(p.Y);
  Canvas.PolyBezierTo([cp1, cp2, pp])
end;

procedure TPascalTypePainterGDI.LineTo(const p: TFloatPoint);
begin
  Canvas.LineTo(Round(p.X), Round(p.Y));
end;

procedure TPascalTypePainterGDI.MoveTo(const p: TFloatPoint);
begin
  Canvas.MoveTo(Round(p.X), Round(p.Y));
end;

procedure TPascalTypePainterGDI.QuadraticBezierTo(const ControlPoint, p: TFloatPoint);
var
  cp, pp: TPoint;
begin
  cp.X := Round(ControlPoint.X);
  cp.Y := Round(ControlPoint.Y);
  pp.X := Round(p.X);
  pp.Y := Round(p.Y);
  Canvas.PolyBezierTo([cp, pp, pp])
end;

procedure TPascalTypePainterGDI.Rectangle(const r: TFloatRect);
var
  r2: TRect;
begin
  r2.Left := Floor(r.Left);
  r2.Top := Floor(r.Top);
  r2.Right := Ceil(r.Right);
  r2.Bottom := Ceil(r.Bottom);
  Canvas.Rectangle(r2);
end;

end.
