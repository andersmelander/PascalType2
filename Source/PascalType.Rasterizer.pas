unit PascalType.Rasterizer;

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
  Classes, Sysutils,
  PT_Types,
  PascalType.FontFace,
  PascalType.FontFace.SFNT,
  PT_Tables,
  PT_CharacterMap,
  PT_TablesOptional;

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

type
  TPascalTypeScaledContour = class(TPersistent)
  protected
//    FPrimitives: TObjectList<>;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TPascalTypeScaledGlyph = class(TPersistent)
  private
    FContours: TObjectList<TPascalTypeScaledContour>;
    function GetContour(Index: Integer): TPascalTypeScaledContour;
    function GetContourCount: Integer;
  protected
    FAdvanceWidth: TScaleType;
    FLeftSideBearing: TScaleType;
    FGlyphName: string;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property AdvanceWidth: TScaleType read FAdvanceWidth;
    property LeftSideBearing: TScaleType read FLeftSideBearing;
    property GlyphName: string read FGlyphName;

    property Contour[Index: Integer]: TPascalTypeScaledContour read GetContour;
    property ContourCount: Integer read GetContourCount;
  end;

//------------------------------------------------------------------------------
//
//              TCustomPascalTypeRasterizer
//
//------------------------------------------------------------------------------
// Abstract rasterizer base class
//------------------------------------------------------------------------------
type
  TCustomPascalTypeRasterizer = class abstract(TInterfacedPersistent)
  private
    FFontFace: TPascalTypeFontFace;
    FFontHeight: Integer;
    FPixelPerInchX: Integer;
    FPixelPerInchY: Integer;
    FScalerX: TScaleType;
    FScalerY: TScaleType;
    FScaledGlyphs: array of TPascalTypeScaledGlyph;
    procedure SetFontSize(const Value: Integer);
    procedure SetPixelPerInchX(const Value: Integer);
    procedure SetPixelPerInchY(const Value: Integer);
    procedure SetFontHeight(const Value: Integer);
    function GetFontSize: Integer;
    procedure SetFontFace(const Value: TPascalTypeFontFace);
  protected
    procedure CalculateScaler;
    procedure CalculateScalerX;
    procedure CalculateScalerY;
    procedure ClearScaledGlyphs;
    procedure PrecalculateScaledGlyphs;

    function RoundedScaleX(Value: Integer): Integer;
    function RoundedScaleY(Value: Integer): Integer;

    function GetGlyphMetric(GlyphIndex: Integer): TGlyphMetric;
    function GetAdvanceWidth(GlyphIndex: Integer): TScaleType;
    function GetKerning(Last, Next: Integer): TScaleType;

    procedure FontHeightChanged; virtual;
    procedure PixelPerInchXChanged; virtual;
    procedure PixelPerInchYChanged; virtual;

    procedure RenderText(const Text: string);
    procedure RenderCharacter(Character: AnsiChar);

    property ScalerX: TScaleType read FScalerX;
    property ScalerY: TScaleType read FScalerY;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property FontFace: TPascalTypeFontFace read FFontFace write SetFontFace;
    property FontHeight: Integer read FFontHeight write SetFontHeight default -11;
    property FontSize: Integer read GetFontSize write SetFontSize stored False;
    property PixelPerInchX: Integer read FPixelPerInchX write SetPixelPerInchX default 96;
    property PixelPerInchY: Integer read FPixelPerInchY write SetPixelPerInchY default 96;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  PT_ResourceStrings;


{ TPascalTypeScaledContour }

constructor TPascalTypeScaledContour.Create;
begin
  inherited;
//  FPrimitives := TObjectList<>.Create;
end;

destructor TPascalTypeScaledContour.Destroy;
begin
//  FreeAndNil(FPrimitives);
  inherited;
end;


{ TPascalTypeScaledGlyph }

constructor TPascalTypeScaledGlyph.Create;
begin
  inherited Create;
  FContours := TObjectList<TPascalTypeScaledContour>.Create;
end;

destructor TPascalTypeScaledGlyph.Destroy;
begin
  FreeAndNil(FContours);
  inherited;
end;

function TPascalTypeScaledGlyph.GetContour(Index: Integer): TPascalTypeScaledContour;
begin
  if (Index < 0) or (Index >= FContours.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FContours[Index];
end;

function TPascalTypeScaledGlyph.GetContourCount: Integer;
begin
  Result := FContours.Count;
end;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeRasterizer
//
//------------------------------------------------------------------------------
constructor TCustomPascalTypeRasterizer.Create;
begin
  inherited;
  // set default pixel per inch
  FPixelPerInchX := 96;
  FPixelPerInchY := 96;
  FFontHeight := -11;
end;

destructor TCustomPascalTypeRasterizer.Destroy;
begin
  inherited;
end;

procedure TCustomPascalTypeRasterizer.SetFontFace(const Value: TPascalTypeFontFace);
begin
  if (FFontFace = Value) then
    exit;

  FFontFace := Value;

  // calculate font depenent variables
  CalculateScaler;
end;

procedure TCustomPascalTypeRasterizer.RenderText(const Text: string);
var
  CharIndex: Integer;
begin
  for CharIndex := 1 to Length(Text) do
  begin
    // RenderCharacter(Text[CharIndex]);
  end;
end;

procedure TCustomPascalTypeRasterizer.RenderCharacter(Character: AnsiChar);
begin
end;

procedure TCustomPascalTypeRasterizer.PixelPerInchXChanged;
begin
  // nothing in here yet (trigger recalculation of cache here soon!)
end;

procedure TCustomPascalTypeRasterizer.PixelPerInchYChanged;
begin
  // nothing in here yet (trigger recalculation of cache here soon!)
end;

procedure TCustomPascalTypeRasterizer.ClearScaledGlyphs;
var
  GlyphIndex: Integer;
begin
  for GlyphIndex := 0 to High(FScaledGlyphs) do
    FreeAndNil(FScaledGlyphs[GlyphIndex]);
  SetLength(FScaledGlyphs, 0);
end;

procedure TCustomPascalTypeRasterizer.PrecalculateScaledGlyphs;
var
  GlyphIndex: Integer;
  // HDMXTable: TPascalTypeHorizontalDeviceMetricsSubTable;
begin
  ClearScaledGlyphs;
  with FontFace do
    for GlyphIndex := 0 to FontFace.GlyphCount - 1 do
    begin
      FScaledGlyphs[GlyphIndex] := TPascalTypeScaledGlyph.Create;

      // get horizontal metrics
      with HorizontalMetrics, FScaledGlyphs[GlyphIndex] do
      begin
        FAdvanceWidth := RoundedScaleX(HorizontalMetric[GlyphIndex].AdvanceWidth);
        FLeftSideBearing := RoundedScaleY(HorizontalMetric[GlyphIndex].AdvanceWidth);
      end;

      if not(htfIntegerScaling in HeaderTable.Flags) then
      begin
        // get scaling from 'hdmx' table here
      end;

      // get glyph data
      // GlyphData[GlyphIndex]
    end;
end;

function TCustomPascalTypeRasterizer.RoundedScaleX(Value: Integer): Integer;
begin
{$IFDEF UseFloatingPoint}
  Result := Round(Value * ScalerX);
{$ELSE}
  Result := Int64(Value shl 6 * ScalerX) shr 6;
{$ENDIF}
end;

function TCustomPascalTypeRasterizer.RoundedScaleY(Value: Integer): Integer;
begin
{$IFDEF UseFloatingPoint}
  Result := Round(Value * ScalerY);
{$ELSE}
  Result := Int64(Value shl 6 * ScalerY) shr 6;
{$ENDIF}
end;

procedure TCustomPascalTypeRasterizer.FontHeightChanged;
begin
  CalculateScaler;
end;

procedure TCustomPascalTypeRasterizer.CalculateScaler;
begin
  CalculateScalerX;
  CalculateScalerY;
end;

procedure TCustomPascalTypeRasterizer.CalculateScalerX;
begin
{$IFDEF UseFloatingPoint}
  FScalerX := Abs(FFontHeight / FFontFace.HeaderTable.UnitsPerEm);
{$ENDIF}
end;

procedure TCustomPascalTypeRasterizer.CalculateScalerY;
begin
{$IFDEF UseFloatingPoint}
  FScalerY := Abs(FFontHeight / FFontFace.HeaderTable.UnitsPerEm);
{$ENDIF}
end;

function TCustomPascalTypeRasterizer.GetAdvanceWidth(GlyphIndex: Integer): TScaleType;
begin
  Result := RoundedScaleX(FontFace.GetAdvanceWidth(GlyphIndex));
end;

function TCustomPascalTypeRasterizer.GetFontSize: Integer;
begin
  Result := -Int64(FFontHeight * 72) div FPixelPerInchY;
end;

function TCustomPascalTypeRasterizer.GetGlyphMetric(GlyphIndex: Integer): TGlyphMetric;
var
  TrueTypeGlyphMetric: TTrueTypeGlyphMetric;
begin
  TrueTypeGlyphMetric := FontFace.GetGlyphMetric(GlyphIndex);

  Result.HorizontalMetric.AdvanceWidth := RoundedScaleX(TrueTypeGlyphMetric.HorizontalMetric.AdvanceWidth);
  Result.HorizontalMetric.Bearing := RoundedScaleX(TrueTypeGlyphMetric.HorizontalMetric.AdvanceWidth);
  Result.VerticalMetric.AdvanceHeight := RoundedScaleY(TrueTypeGlyphMetric.VerticalMetric.AdvanceHeight);
  Result.VerticalMetric.TopSideBearing := RoundedScaleY(TrueTypeGlyphMetric.VerticalMetric.TopSideBearing);
end;

function TCustomPascalTypeRasterizer.GetKerning(Last, Next: Integer): TScaleType;
begin
  Result := RoundedScaleX(FontFace.GetKerning(Last, Next));
end;

procedure TCustomPascalTypeRasterizer.SetFontSize(const Value: Integer);
begin
  FontHeight := -Int64(Value * FPixelPerInchY) div 72;
end;

procedure TCustomPascalTypeRasterizer.SetFontHeight(const Value: Integer);
begin
  if FFontHeight <> Value then
  begin
    FFontHeight := Value;
    FontHeightChanged;
  end;
end;

procedure TCustomPascalTypeRasterizer.SetPixelPerInchX(const Value: Integer);
begin
  if FPixelPerInchX <> Value then
  begin
    FPixelPerInchX := Value;
    PixelPerInchXChanged;
  end;
end;

procedure TCustomPascalTypeRasterizer.SetPixelPerInchY(const Value: Integer);
begin
  if FPixelPerInchY <> Value then
  begin
    FPixelPerInchY := Value;
    PixelPerInchYChanged;
  end;
end;

end.

