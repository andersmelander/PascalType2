unit PascalType.Painter;

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

//------------------------------------------------------------------------------
//
//              IPascalTypePainter
//
//------------------------------------------------------------------------------
// Represents the object used to paint a glyph.
//------------------------------------------------------------------------------
type
  TRenderFloat = Single;

  TFloatPoint = record
    X, Y: TRenderFloat;
  end;

  TFloatRect = record
    procedure Inflate(dx, dy: TRenderFloat);
  public
    case integer of
      0: (Left, Top, Right, Bottom: TRenderFloat);
      1: (TopLeft, BottomRight: TFloatPoint);
  end;

  IPascalTypePainter = interface
    ['{E16C8963-A9E5-407A-84C4-FEDDE957B7CF}']
    procedure BeginUpdate;
    procedure EndUpdate;

    procedure BeginGlyph;
    procedure EndGlyph;

    procedure BeginPath;
    procedure EndPath;

    procedure SetColor(Color: Cardinal);

    procedure MoveTo(const p: TFloatPoint);
    procedure LineTo(const p: TFloatPoint);
    procedure QuadraticBezierTo(const ControlPoint, p: TFloatPoint);
    procedure CubicBezierTo(const ControlPoint1, ControlPoint2, p: TFloatPoint);
    procedure Rectangle(const r: TFloatRect);
    procedure Circle(const p: TFloatPoint; Radius: TRenderFloat);
  end;

implementation

//------------------------------------------------------------------------------
//
//              TFloatRect
//
//------------------------------------------------------------------------------
procedure TFloatRect.Inflate(dx, dy: TRenderFloat);
begin
  if (dx <> 0) then
  begin
    Left := Left - dx;
    Right := Right + dx;
  end;
  if (dy <> 0) then
  begin
    Top := Top - dy;
    Bottom := Bottom + dy;
  end;
end;

end.
