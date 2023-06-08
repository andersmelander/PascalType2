unit PascalType.Tables.OpenType.Common.Anchor;

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
  Generics.Collections,
  Generics.Defaults,
  Classes,
  PT_Types,
  PT_Classes,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Positioning,
  PascalType.Tables.OpenType.ClassDefinition;


//------------------------------------------------------------------------------
//
//              TOpenTypeAnchor
//
//------------------------------------------------------------------------------
// Shared Tables: Anchor Table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#shared-tables-value-record-anchor-table-and-mark-array-table
//------------------------------------------------------------------------------
(*
  A GPOS table uses anchor points to position one glyph with respect to another.
  Each glyph defines an anchor point, and the text-processing client attaches the
  glyphs by aligning their corresponding anchor points.

  To describe an anchor point, an Anchor table can use one of three formats. The
  first format uses X and Y coordinates, in design units, to specify a location
  for the anchor point in relation to the location of the outline for a given
  glyph. The other two formats refine the location of the anchor point using
  contour points (Format 2) or Device tables (Format 3). In a variable font, the
  third format uses a VariationIndex table (a variant of a Device table) to
  reference variation data for adjustment of the anchor position for the current
  variation instance, as needed.
*)
type
  TOpenTypeAnchorFormat = (caaInvalid, caaDesignUnits, caaDUContourPoints, caaDUDeviceVariantion);

type
  TAnchorPoint = record
    X: SmallInt;
    Y: SmallInt;
  end;

type
  TOpenTypeAnchor = class;
  TOpenTypeAnchorClass = class of TOpenTypeAnchor;

  TOpenTypeAnchor = class abstract
  private
    FAnchorFormat: TOpenTypeAnchorFormat;
  public
    constructor Create(AAnchorFormat: TOpenTypeAnchorFormat); virtual;

    class function AnchorClassByAnchorFormat(AnchorFormat: TOpenTypeAnchorFormat): TOpenTypeAnchorClass;
    class function CreateFromStream(Stream: TStream): TOpenTypeAnchor;

    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;

    procedure Assign(Source: TOpenTypeAnchor); virtual;

    function Position: TAnchorPoint; virtual; abstract;

    function Clone: TOpenTypeAnchor;

    property AnchorFormat: TOpenTypeAnchorFormat read FAnchorFormat;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//      TOpenTypeAnchorDesignUnits
//------------------------------------------------------------------------------
type
  TOpenTypeAnchorDesignUnits = class(TOpenTypeAnchor)
  private
    FX: SmallInt;
    FY: SmallInt;
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    procedure Assign(Source: TOpenTypeAnchor); override;

    function Position: TAnchorPoint; override;

    property X: SmallInt read FX write FX;
    property Y: SmallInt read FY write FY;
  end;

function TOpenTypeAnchorDesignUnits.Position: TAnchorPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

procedure TOpenTypeAnchorDesignUnits.Assign(Source: TOpenTypeAnchor);
begin
  inherited;
  if (Source is TOpenTypeAnchorDesignUnits) then
  begin
    FX := TOpenTypeAnchorDesignUnits(Source).X;
    FY := TOpenTypeAnchorDesignUnits(Source).Y;
  end;
end;

procedure TOpenTypeAnchorDesignUnits.LoadFromStream(Stream: TStream);
begin
  inherited;

  FX := BigEndianValueReader.ReadSmallInt(Stream);
  FY := BigEndianValueReader.ReadSmallInt(Stream);
end;

procedure TOpenTypeAnchorDesignUnits.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedSmallInt(Stream, FX);
  WriteSwappedSmallInt(Stream, FY);
end;


//------------------------------------------------------------------------------
//      TOpenTypeAnchorDUContourPoint
//------------------------------------------------------------------------------
type
  TOpenTypeAnchorDUContourPoint = class(TOpenTypeAnchorDesignUnits)
  private
    FContourPointIndex: Word;
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    procedure Assign(Source: TOpenTypeAnchor); override;

    function Position: TAnchorPoint; override;

    property ContourPointIndex: Word read FContourPointIndex write FContourPointIndex;
  end;

function TOpenTypeAnchorDUContourPoint.Position: TAnchorPoint;
begin
  Result := inherited Position;
  // TODO
end;

procedure TOpenTypeAnchorDUContourPoint.Assign(Source: TOpenTypeAnchor);
begin
  inherited;
  if (Source is TOpenTypeAnchorDUContourPoint) then
  begin
    FContourPointIndex := TOpenTypeAnchorDUContourPoint(Source).ContourPointIndex;
  end;
end;

procedure TOpenTypeAnchorDUContourPoint.LoadFromStream(Stream: TStream);
begin
  inherited;

  FContourPointIndex := BigEndianValueReader.ReadWord(Stream);
end;

procedure TOpenTypeAnchorDUContourPoint.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedWord(Stream, FContourPointIndex);
end;


//------------------------------------------------------------------------------
//      TOpenTypeAnchorDUDeviceVariantion
//------------------------------------------------------------------------------
type
  TOpenTypeAnchorDUDeviceVariantion = class(TOpenTypeAnchorDesignUnits)
  private
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    procedure Assign(Source: TOpenTypeAnchor); override;

    function Position: TAnchorPoint; override;
  end;

function TOpenTypeAnchorDUDeviceVariantion.Position: TAnchorPoint;
begin
  Result := inherited Position;
  // TODO
end;

procedure TOpenTypeAnchorDUDeviceVariantion.Assign(Source: TOpenTypeAnchor);
begin
  inherited;
  if (Source is TOpenTypeAnchorDUDeviceVariantion) then
  begin
    // TODO
  end;
end;

procedure TOpenTypeAnchorDUDeviceVariantion.LoadFromStream(Stream: TStream);
var
  XDeviceOffset: Word;
  YDeviceOffset: Word;
begin
  inherited;

  XDeviceOffset := BigEndianValueReader.ReadWord(Stream);
  YDeviceOffset := BigEndianValueReader.ReadWord(Stream);
end;

procedure TOpenTypeAnchorDUDeviceVariantion.SaveToStream(Stream: TStream);
begin
  inherited;

  // TODO
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeAnchor
//
//------------------------------------------------------------------------------
class function TOpenTypeAnchor.AnchorClassByAnchorFormat(AnchorFormat: TOpenTypeAnchorFormat): TOpenTypeAnchorClass;
begin
  case AnchorFormat of
    caaDesignUnits:
      Result := TOpenTypeAnchorDesignUnits;

    caaDUContourPoints:
      Result := TOpenTypeAnchorDUContourPoint;

    caaDUDeviceVariantion:
      Result := TOpenTypeAnchorDUDeviceVariantion;

  else
    raise EPascalTypeError.CreateFmt('Invalid anchor format: %d', [Ord(AnchorFormat)]);
  end;
end;

procedure TOpenTypeAnchor.Assign(Source: TOpenTypeAnchor);
begin
  Assert(AnchorFormat = Source.AnchorFormat);
end;

function TOpenTypeAnchor.Clone: TOpenTypeAnchor;
begin
  Result := AnchorClassByAnchorFormat(AnchorFormat).Create(AnchorFormat);
  try
    Result.Assign(Self);
  except
    Result.Free;
    raise;
  end;
end;

constructor TOpenTypeAnchor.Create(AAnchorFormat: TOpenTypeAnchorFormat);
begin
  inherited Create;
  FAnchorFormat := AAnchorFormat;
end;

class function TOpenTypeAnchor.CreateFromStream(Stream: TStream): TOpenTypeAnchor;
var
  SavePos: Int64;
  AnchorFormat: TOpenTypeAnchorFormat;
begin
  SavePos := Stream.Position;

  AnchorFormat := TOpenTypeAnchorFormat(BigEndianValueReader.ReadWord(Stream));

  Result := AnchorClassByAnchorFormat(AnchorFormat).Create(AnchorFormat);
  try

    Stream.Position := SavePos;
    Result.LoadFromStream(Stream);

  except
    Result.Free;
    raise;
  end;
end;

procedure TOpenTypeAnchor.LoadFromStream(Stream: TStream);
var
  AnchorFormat: TOpenTypeAnchorFormat;
begin
  AnchorFormat := TOpenTypeAnchorFormat(BigEndianValueReader.ReadWord(Stream));
  Assert(AnchorFormat = FAnchorFormat);
end;

procedure TOpenTypeAnchor.SaveToStream(Stream: TStream);
begin
  WriteSwappedWord(Stream, Ord(AnchorFormat));
end;


//------------------------------------------------------------------------------

end.

