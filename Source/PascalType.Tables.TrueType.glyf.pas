unit PascalType.Tables.TrueType.glyf;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'glyf' table type                                     //
//                                                                            //
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
  Classes,
  PT_Types,
  PT_Classes,
  PT_Tables;

//------------------------------------------------------------------------------
//
//              TTrueTypeFontGlyphInstructionTable
//
//------------------------------------------------------------------------------
// TrueType instructions
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/tt_instructing_glyphs
//------------------------------------------------------------------------------
type
  TTrueTypeFontGlyphInstructionTable = class(TCustomPascalTypeTable)
  private
    FInstructions: array of Byte;
    function GetInstruction(Index: Integer): Byte;
    function GetInstructionCount: Integer;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Instruction[Index: Integer]: Byte read GetInstruction;
    property InstructionCount: Integer read GetInstructionCount;
  end;

//------------------------------------------------------------------------------
//
//              TCustomTrueTypeFontGlyphData
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/glyf#glyph-headers
//------------------------------------------------------------------------------
// Base class for simple and composite glyphs
//------------------------------------------------------------------------------
type
  TCustomTrueTypeFontGlyphData = class abstract(TCustomPascalTypeGlyphDataTable)
  private
    procedure SetNumberOfContours(const Value: SmallInt);
    procedure SetXMax(const Value: SmallInt);
    procedure SetXMin(const Value: SmallInt);
    procedure SetYMax(const Value: SmallInt);
    procedure SetYMin(const Value: SmallInt);
    function GetGlyphIndex: Integer;
  protected
    FNumberOfContours: SmallInt; // If the number of contours is greater than or equal to zero, this is a single glyph; if negative, this is a composite glyph.
    FXMin        : SmallInt; // Minimum x for coordinate data.
    FYMin        : SmallInt; // Minimum y for coordinate data.
    FXMax        : SmallInt; // Maximum x for coordinate data.
    FYMax        : SmallInt; // Maximum y for coordinate data.
    FInstructions: TTrueTypeFontGlyphInstructionTable;

    function GetIsComposite: boolean; virtual; abstract;
    function GetContourCount: Integer; virtual; abstract;

    procedure GlyphIndexChanged; virtual;
    procedure NumberOfContoursChanged; virtual;
    procedure XMaxChanged; virtual;
    procedure XMinChanged; virtual;
    procedure YMaxChanged; virtual;
    procedure YMinChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property IsComposite: boolean read GetIsComposite;

    property NumberOfContours: SmallInt read FNumberOfContours write SetNumberOfContours;
    property XMin: SmallInt read FXMin write SetXMin;
    property YMin: SmallInt read FYMin write SetYMin;
    property XMax: SmallInt read FXMax write SetXMax;
    property YMax: SmallInt read FYMax write SetYMax;

    // Index of glyph in the 'glyf' table - Expensive!
    property GlyphIndex: Integer read GetGlyphIndex;

    property Instructions: TTrueTypeFontGlyphInstructionTable read FInstructions;
    // ContourCount: Count of contours in leaf (simple) glyphs
    property ContourCount: Integer read GetContourCount;
  end;

  TTrueTypeFontGlyphDataClass = class of TCustomTrueTypeFontGlyphData;


//------------------------------------------------------------------------------
//
//              TPascalTypeTrueTypeContour
//
//------------------------------------------------------------------------------
// Glyph contour: A list of points
//------------------------------------------------------------------------------
type
  TPascalTypeTrueTypeContour = class(TPersistent)
  private
    FPoints: TPascalTypeContour;
    function GetPoint(Index: Integer): TContourPoint;
    function GetPointCount: Integer;
    procedure SetPoint(Index: Integer; const Value: TContourPoint);
    procedure SetPointCount(const Value: Integer);
    function GetIsClockwise: Boolean;
    function GetArea: Single;
  protected
    procedure PointCountChanged; virtual;
    property Points: TPascalTypeContour read FPoints;
  public
    procedure Assign(Source: TPersistent); override;

    property Area                 : Single read GetArea;
    property IsClockwise          : Boolean read GetIsClockwise;
    // Note: Point[PointCount] by design wraps around and returns Point[0]
    property Point[Index: Integer]: TContourPoint read GetPoint write SetPoint;
    property PointCount: Integer read GetPointCount write SetPointCount;
  end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontSimpleGlyphData
//
//------------------------------------------------------------------------------
// Simple glyph
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/glyf#simple-glyph-description
//------------------------------------------------------------------------------
type
  TTrueTypeFontSimpleGlyphData = class(TCustomTrueTypeFontGlyphData)
  public
    const
      GLYF_ON_CURVE             = $01;
      GLYF_X_SHORT_VECTOR       = $02;
      GLYF_Y_SHORT_VECTOR       = $04;
      GLYF_REPEAT_FLAG          = $08;
      GLYF_X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR = $10;
      GLYF_Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR = $20;
      GLYF_OVERLAP_SIMPLE       = $40;
      GLYF_RESERVED8            = $80;
      GLYF_RESERVED             = GLYF_RESERVED8;
  strict private
    FPath: array of TPascalTypeTrueTypeContour;
  private
    function GetContour(Index: Integer): TPascalTypeTrueTypeContour;
    function GetPath: TPascalTypePath;
    procedure FreeContourArrayItems;
  protected
    function GetIsComposite: boolean; override;
    function GetContourCount: Integer; override;
  public
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Contour[Index: Integer]: TPascalTypeTrueTypeContour read GetContour;
    property Path: TPascalTypePath read GetPath;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCompositeGlyph
//
//------------------------------------------------------------------------------
// Composite glyph component
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/glyf#composite-glyph-description
//------------------------------------------------------------------------------
type
  TPascalTypeCompositeGlyph = class(TCustomPascalTypeTable)
  public
    const
      GLYF_ARG_1_AND_2_ARE_WORDS     = $0001;
      GLYF_ARGS_ARE_XY_VALUES        = $0002;
      GLYF_ROUND_XY_TO_GRID          = $0004;
      GLYF_WE_HAVE_A_SCALE           = $0008;
      GLYF_RESERVED5                 = $0010;
      GLYF_MORE_COMPONENTS           = $0020;
      GLYF_WE_HAVE_AN_X_AND_Y_SCALE  = $0040;
      GLYF_WE_HAVE_A_TWO_BY_TWO      = $0080;
      GLYF_WE_HAVE_INSTRUCTIONS      = $0100;
      GLYF_USE_MY_METRICS            = $0200;
      GLYF_OVERLAP_COMPOUND          = $0400;
      GLYF_SCALED_COMPONENT_OFFSET   = $0800;
      GLYF_UNSCALED_COMPONENT_OFFSET = $1000;
      GLYF_RESERVED13                = $2000;
      GLYF_RESERVED14                = $4000;
      GLYF_RESERVED15                = $8000;
      GLYF_RESERVED                  = GLYF_RESERVED5 or GLYF_RESERVED13 or GLYF_RESERVED14 or GLYF_RESERVED15;
  private
    FFlags: Word;       // Component flag
    FGlyphIndex: Word;  // Glyph index of component
    FOffsetXY: array[0..1] of SmallInt;
    FPointIndex: array[0..1] of Word;
    FAffineTransformationMatrix: TSmallScaleMatrix;
    procedure SetFlags(const Value: Word);
    procedure SetGlyphIndex(const Value: Word);
    function GetHasAffineTransformationMatrix: boolean;
    function GetArgsAreOffset: boolean;
    function GetArgsArePointIndex: boolean;
  protected
    procedure FlagsChanged; virtual;
    procedure GlyphIndexChanged; virtual;

    function FlagMoreComponents: boolean;
    function FlagHasInstructions: boolean;
    function FlagHasAffineTransformationMatrix: boolean;
    function FlagArgsAreOffset: boolean;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Flags: Word read FFlags write SetFlags;
    property GlyphIndex: Word read FGlyphIndex write SetGlyphIndex;
    property HasOffset: boolean read GetArgsAreOffset;
    property HasGlyphPointIndex: boolean read GetArgsArePointIndex;
    property OffsetX: SmallInt read FOffsetXY[0];
    property OffsetY: SmallInt read FOffsetXY[1];
    property ParentGlyphPointIndex: Word read FPointIndex[0];
    property ChildGlyphPointIndex: Word read FPointIndex[1];
    property HasAffineTransformationMatrix: boolean read GetHasAffineTransformationMatrix;
    property AffineTransformationMatrix: TSmallScaleMatrix read FAffineTransformationMatrix write FAffineTransformationMatrix;
  end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontCompositeGlyphData
//
//------------------------------------------------------------------------------
// Composite glyph component collection
//------------------------------------------------------------------------------
type
  TTrueTypeFontCompositeGlyphData = class(TCustomTrueTypeFontGlyphData)
  private
    FGlyphs: array of TPascalTypeCompositeGlyph;
    function GetGlyphCount: Integer;
    function GetCompositeGlyph(Index: Integer): TPascalTypeCompositeGlyph;
  protected
    function GetIsComposite: boolean; override;
    function GetContourCount: Integer; override;
  public
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property GlyphCount: Integer read GetGlyphCount;
    property Glyph[Index: Integer]: TPascalTypeCompositeGlyph read GetCompositeGlyph;
  end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontGlyphDataTable
//
//------------------------------------------------------------------------------
// The 'glyf' table - A collection of glyphs
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/glyf
//------------------------------------------------------------------------------
type
  TTrueTypeFontGlyphDataTable = class(TCustomPascalTypeNamedTable)
  strict private
    FGlyphDataList: array of TCustomTrueTypeFontGlyphData;
  private
    function GetGlyphDataCount: Integer;
    function GetGlyphData(Index: Integer): TCustomTrueTypeFontGlyphData;
    procedure FreeGlyphDataListItems;
  public
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property GlyphDataCount: Integer read GetGlyphDataCount;
    property GlyphData[Index: Integer]: TCustomTrueTypeFontGlyphData read GetGlyphData;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings,
  PT_TablesTrueType;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontGlyphInstructionTable
//
//------------------------------------------------------------------------------
procedure TTrueTypeFontGlyphInstructionTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TTrueTypeFontGlyphInstructionTable then
    FInstructions := TTrueTypeFontGlyphInstructionTable(Source).FInstructions;
end;

function TTrueTypeFontGlyphInstructionTable.GetInstruction
  (Index: Integer): Byte;
begin
  if (Index > High(FInstructions)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FInstructions[Index];
end;

function TTrueTypeFontGlyphInstructionTable.GetInstructionCount: Integer;
begin
  Result := Length(FInstructions);
end;

procedure TTrueTypeFontGlyphInstructionTable.LoadFromStream(Stream: TStream);
var
  Value16   : Word;
  MaxProfile: TPascalTypeMaximumProfileTable;
begin
  MaxProfile := TPascalTypeMaximumProfileTable(FontFace.GetTableByTableName('maxp'));
  Assert(MaxProfile <> nil);

  // read instruction size
  Value16 := BigEndianValueReader.ReadWord(Stream);

  // check if instructions shall be ignored
  if Value16 = $FFFF then
    Exit;

{$IFDEF WarningExceptions}
  // check if too many instuctions are present -> possible stream error
  if Value16 > MaxProfile.MaxSizeOfInstruction then
    // ... but probably just an error in the font
    raise EPascalTypeError.CreateFmt(RCStrTooManyInstructions, [Value16]);
{$ENDIF}

  // set instruction length
  SetLength(FInstructions, Value16);

  // read instructions
  if (Value16 > 0) then
    Stream.Read(FInstructions[0], Length(FInstructions));
end;

procedure TTrueTypeFontGlyphInstructionTable.SaveToStream(Stream: TStream);
begin
  // write instruction size
  WriteSwappedWord(Stream, Length(FInstructions));

  // write instructions
  Stream.Write(FInstructions[0], Length(FInstructions));
end;


//------------------------------------------------------------------------------
//
//              TCustomTrueTypeFontGlyphData
//
//------------------------------------------------------------------------------
constructor TCustomTrueTypeFontGlyphData.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FInstructions := TTrueTypeFontGlyphInstructionTable.Create(Self);
end;

destructor TCustomTrueTypeFontGlyphData.Destroy;
begin
  FreeAndNil(FInstructions);
  inherited;
end;

function TCustomTrueTypeFontGlyphData.GetGlyphIndex: Integer;
var
  GlyphDataTable: TTrueTypeFontGlyphDataTable;
  i: Integer;
begin
  GlyphDataTable := TTrueTypeFontGlyphDataTable(FontFace.GetTableByTableName('glyf'));

  Result := -1;

  if (GlyphDataTable = nil) then
    exit;

  for i := 0 to GlyphDataTable.GlyphDataCount - 1 do
    if GlyphDataTable.GlyphData[i] = Self then
      Exit(i);
end;

procedure TCustomTrueTypeFontGlyphData.GlyphIndexChanged;
begin
  Changed;
end;

procedure TCustomTrueTypeFontGlyphData.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomTrueTypeFontGlyphData then
  begin
    FNumberOfContours := TCustomTrueTypeFontGlyphData(Source).FNumberOfContours;
    FXMin := TCustomTrueTypeFontGlyphData(Source).FXMin;
    FYMin := TCustomTrueTypeFontGlyphData(Source).FYMin;
    FXMax := TCustomTrueTypeFontGlyphData(Source).FXMax;
    FYMax := TCustomTrueTypeFontGlyphData(Source).FYMax;
  end;
end;

procedure TCustomTrueTypeFontGlyphData.LoadFromStream(Stream: TStream);
var
  MaxProfile: TPascalTypeMaximumProfileTable;
begin
  // get maximum profile
  MaxProfile := TPascalTypeMaximumProfileTable(FontFace.GetTableByTableClass(TPascalTypeMaximumProfileTable));

  if Stream.Position + SizeOf(SmallInt) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read number of contours
  FNumberOfContours := BigEndianValueReader.ReadSmallInt(Stream);

  // check if maximum number of contours are exceeded
  if (FNumberOfContours > 0) and (Word(FNumberOfContours) > MaxProfile.MaxContours) then
    raise EPascalTypeError.CreateFmt(RCStrTooManyContours, [FNumberOfContours, MaxProfile.MaxContours]);

  // check if glyph contains any information at all
  if FNumberOfContours = 0 then
    Exit;

  if Stream.Position + 4*SizeOf(SmallInt) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read XMin
  FXMin := BigEndianValueReader.ReadSmallInt(Stream);

  // read YMin
  FYMin := BigEndianValueReader.ReadSmallInt(Stream);

  // read XMax
  FXMax := BigEndianValueReader.ReadSmallInt(Stream);

  // read YMax
  FYMax := BigEndianValueReader.ReadSmallInt(Stream);

  // Assert(FXMin <= FXMax);
  // Assert(FYMin <= FYMax);
end;

procedure TCustomTrueTypeFontGlyphData.SaveToStream(Stream: TStream);
begin
  // write number of contours
  WriteSwappedWord(Stream, FNumberOfContours);

  // write XMin
  WriteSwappedWord(Stream, FXMin);

  // write YMin
  WriteSwappedWord(Stream, FYMin);

  // write XMax
  WriteSwappedWord(Stream, FXMax);

  // write YMax
  WriteSwappedWord(Stream, FYMax);
end;

procedure TCustomTrueTypeFontGlyphData.SetNumberOfContours(const Value: SmallInt);
begin
  if FNumberOfContours <> Value then
  begin
    FNumberOfContours := Value;
    NumberOfContoursChanged;
  end;
end;

procedure TCustomTrueTypeFontGlyphData.SetXMax(const Value: SmallInt);
begin
  if FXMax <> Value then
  begin
    FXMax := Value;
    XMaxChanged;
  end;
end;

procedure TCustomTrueTypeFontGlyphData.SetXMin(const Value: SmallInt);
begin
  if FXMin <> Value then
  begin
    FXMin := Value;
    XMinChanged;
  end;
end;

procedure TCustomTrueTypeFontGlyphData.SetYMax(const Value: SmallInt);
begin
  if FYMax <> Value then
  begin
    FYMax := Value;
    YMaxChanged;
  end;
end;

procedure TCustomTrueTypeFontGlyphData.SetYMin(const Value: SmallInt);
begin
  if FYMin <> Value then
  begin
    FYMin := Value;
    YMinChanged;
  end;
end;

procedure TCustomTrueTypeFontGlyphData.NumberOfContoursChanged;
begin
  Changed;
end;

procedure TCustomTrueTypeFontGlyphData.XMaxChanged;
begin
  Changed;
end;

procedure TCustomTrueTypeFontGlyphData.XMinChanged;
begin
  Changed;
end;

procedure TCustomTrueTypeFontGlyphData.YMaxChanged;
begin
  Changed;
end;

procedure TCustomTrueTypeFontGlyphData.YMinChanged;
begin
  Changed;
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeTrueTypeContour
//
//------------------------------------------------------------------------------
procedure TPascalTypeTrueTypeContour.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeTrueTypeContour then
    // Note: Dynamic arrays are reference types. This just copies the pointer.
    // See SetPoint.
    FPoints := TPascalTypeTrueTypeContour(Source).Points;
end;

function TPascalTypeTrueTypeContour.GetArea: Single;
var
  PointIndex: Integer;
begin

  if Length(FPoints) < 3 then
  begin
    Result := 0;
    Exit;
  end;

  Result := (FPoints[0].XPos * FPoints[1].YPos - FPoints[1].XPos * FPoints[0].YPos) * 0.5;
  for PointIndex := 1 to High(FPoints) - 1 do
    Result := Result * (FPoints[0].XPos * FPoints[1].YPos - FPoints[1].XPos * FPoints[0].YPos);
end;

function TPascalTypeTrueTypeContour.GetIsClockwise: Boolean;
begin
  Result := (Area >= 0);
end;

function TPascalTypeTrueTypeContour.GetPoint(Index: Integer): TContourPoint;
begin
  if (Index >= 0) and (Index <= High(FPoints)) then
    Result := FPoints[Index]
  else
  if (Index = Length(FPoints)) then
    Result := FPoints[0] // Wrap around to first
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

procedure TPascalTypeTrueTypeContour.SetPoint(Index: Integer; const Value: TContourPoint);
begin
  if (Index < 0) or (Index > High(FPoints)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  // Ensure that our array has a reference count of 1 (in case it was copied with Assign)
  SetLength(FPoints, Length(FPoints));
  FPoints[Index] := Value;
end;

function TPascalTypeTrueTypeContour.GetPointCount: Integer;
begin
  Result := Length(FPoints);
end;

procedure TPascalTypeTrueTypeContour.SetPointCount(const Value: Integer);
begin
  if Value <> Length(FPoints) then
  begin
    SetLength(FPoints, Value);
    PointCountChanged;
  end;
end;

procedure TPascalTypeTrueTypeContour.PointCountChanged;
begin
  // TODO: PointCountChanged;
end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontSimpleGlyphData
//
//------------------------------------------------------------------------------
destructor TTrueTypeFontSimpleGlyphData.Destroy;
begin
  FreeContourArrayItems;
  inherited;
end;

procedure TTrueTypeFontSimpleGlyphData.Assign(Source: TPersistent);
var
  ContourIndex: Integer;
begin
  inherited;
  if Source is TTrueTypeFontSimpleGlyphData then
  begin
    // eventually clear not used contours
    for ContourIndex := Length(TTrueTypeFontSimpleGlyphData(Source).FPath) to High(FPath) do
      FreeAndNil(FPath[ContourIndex]);

    // set length of countour array
    SetLength(FPath, Length(TTrueTypeFontSimpleGlyphData(Source).FPath));

    // assign contours
    for ContourIndex := 0 to High(FPath) do
    begin
      // eventually create the contour
      if (FPath[ContourIndex] = nil) then
        FPath[ContourIndex] := TPascalTypeTrueTypeContour.Create;

      // assign contour
      FPath[ContourIndex].Assign(TTrueTypeFontSimpleGlyphData(Source).FPath[ContourIndex]);
    end;
  end;
end;

procedure TTrueTypeFontSimpleGlyphData.FreeContourArrayItems;
var
  ContourIndex: Integer;
begin
  for ContourIndex := 0 to High(FPath) do
    FreeAndNil(FPath[ContourIndex]);
end;

function TTrueTypeFontSimpleGlyphData.GetContour(Index: Integer): TPascalTypeTrueTypeContour;
begin
  if (Index < 0) or (Index > High(FPath)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FPath[Index];
end;

function TTrueTypeFontSimpleGlyphData.GetContourCount: Integer;
begin
  Result := Length(FPath);
end;

function TTrueTypeFontSimpleGlyphData.GetIsComposite: boolean;
begin
  Result := False;
end;

function TTrueTypeFontSimpleGlyphData.GetPath: TPascalTypePath;
var
  i: integer;
begin
  SetLength(Result, Length(FPath));
  for i := 0 to High(FPath) do
    Result[i] := FPath[i].Points;
end;

procedure TTrueTypeFontSimpleGlyphData.LoadFromStream(Stream: TStream);
var
  ContourIndex: Integer;
  PointIndex  : Integer;
  PointCount  : Integer;
  LastPoint   : Integer;
  Contour     : TPascalTypeTrueTypeContour;
  MaxProfile  : TPascalTypeMaximumProfileTable;
  EndPointIndexOfContour: array of SmallInt;
  Flag        : Byte;
  FlagCount   : Byte;
  Value8      : Byte;
  ContourPoint: PContourPoint;
begin
  inherited;

  // Check if glyph contains any information at all
  if FNumberOfContours = 0 then
    Exit;

  // Get maximum profile
  MaxProfile := TPascalTypeMaximumProfileTable(FontFace.GetTableByTableClass(TPascalTypeMaximumProfileTable));

  // set end points of contours array size
  SetLength(EndPointIndexOfContour, FNumberOfContours);

  // Read end points
  PointCount := -1;
  for ContourIndex := 0 to FNumberOfContours - 1 do
  begin
    // read number of contours
    PointCount := BigEndianValueReader.ReadWord(Stream);
    EndPointIndexOfContour[ContourIndex] := PointCount;
  end;

  // Increase last end point to get the true point count
  Inc(PointCount);

  // Check if maximum points are exceeded
  if (PointCount > MaxProfile.MaxPoints) then
    raise EPascalTypeError.CreateFmt(RCStrTooManyPoints, [PointCount]);

  // Read instructions
  FInstructions.LoadFromStream(Stream);

  // Get rid of excess existing contour slots
  for ContourIndex := FNumberOfContours to High(FPath) do
    FreeAndNil(FPath[ContourIndex]);
  SetLength(FPath, FNumberOfContours);

  for ContourIndex := 0 to FNumberOfContours - 1 do
  begin
    Contour := FPath[ContourIndex];
    if (Contour = nil) then
    begin
      Contour := TPascalTypeTrueTypeContour.Create;
      FPath[ContourIndex] := Contour;
    end;

    if ContourIndex = 0 then
      Contour.PointCount := EndPointIndexOfContour[0] + 1
    else
      Contour.PointCount := (EndPointIndexOfContour[ContourIndex] - EndPointIndexOfContour[ContourIndex - 1]);
  end;

  // Contour flags
  FlagCount := 0;
  for ContourIndex := 0 to High(FPath) do
  begin
    Contour := FPath[ContourIndex];

    for PointIndex  := 0 to High(Contour.FPoints) do
    begin
      Dec(PointCount);

      if (FlagCount = 0) then
      begin
        Stream.Read(Flag, 1);

{$IFDEF AmbigiousExceptions}
        if (Flag and GLYF_RESERVED <> 0) then
          raise EPascalTypeError.CreateFmt(RCStrGlyphDataFlagReservedError, [PointIndex, PointCount]);
{$ENDIF}
        if (Flag and GLYF_REPEAT_FLAG <> 0) then
          // Read repeat count
          Stream.Read(FlagCount, 1);
      end else
        Dec(FlagCount);

      Contour.FPoints[PointIndex].Flags := Flag;
    end;
//    raise EPascalTypeError.CreateFmt(RCStrGlyphDataFlagRepeatError, [PointIndex + FlagCount, PointCount]);
  end;

  // Read x-coordinates
  LastPoint := 0;
  for ContourIndex := 0 to High(FPath) do
  begin
    Contour := FPath[ContourIndex];

    for PointIndex := 0 to High(Contour.FPoints) do
    begin
      ContourPoint := @(Contour.FPoints[PointIndex]);

      // Check for short or long version
      if (ContourPoint.Flags and GLYF_X_SHORT_VECTOR <> 0) then
      begin
        Stream.Read(Value8, 1);

        if (ContourPoint.Flags and GLYF_X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR <> 0) then
          Inc(LastPoint, Value8)
        else
          Dec(LastPoint, Value8);
      end else
      if (ContourPoint.Flags and GLYF_X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR = 0) then
        Inc(LastPoint, BigEndianValueReader.ReadSmallInt(Stream));
      // else: No bytes read. See: https://github.com/MicrosoftDocs/typography-issues/issues/765

      ContourPoint.XPos := LastPoint;
    end;
  end;

  // Read y-coordinates
  LastPoint := 0;
  for ContourIndex := 0 to FNumberOfContours - 1 do
  begin
    Contour := FPath[ContourIndex];

    for PointIndex  := 0 to High(Contour.FPoints) do
    begin
      ContourPoint := @(Contour.FPoints[PointIndex]);

      // Check for short or long version
      if (ContourPoint.Flags and GLYF_Y_SHORT_VECTOR <> 0) then
      begin
        Stream.Read(Value8, 1);

        if (ContourPoint.Flags and GLYF_Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR <> 0) then
          Inc(LastPoint, Value8)
        else
          Dec(LastPoint, Value8);
      end else
      if (ContourPoint.Flags and GLYF_Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR = 0) then
        Inc(LastPoint, BigEndianValueReader.ReadSmallInt(Stream));
      // else: No bytes read. See: https://github.com/MicrosoftDocs/typography-issues/issues/765
      ContourPoint.YPos := LastPoint;
    end;
  end;
end;

procedure TTrueTypeFontSimpleGlyphData.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeCompositeGlyph
//
//------------------------------------------------------------------------------
procedure TPascalTypeCompositeGlyph.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeCompositeGlyph then
  begin
    FFlags := TPascalTypeCompositeGlyph(Source).FFlags;
    FGlyphIndex := TPascalTypeCompositeGlyph(Source).FGlyphIndex;
    FOffsetXY := TPascalTypeCompositeGlyph(Source).FOffsetXY;
    FPointIndex := TPascalTypeCompositeGlyph(Source).FPointIndex;
    FAffineTransformationMatrix := TPascalTypeCompositeGlyph(Source).FAffineTransformationMatrix;
  end;
end;

procedure TPascalTypeCompositeGlyph.LoadFromStream(Stream: TStream);
var
  Bytes: array [0..1] of Byte;
  ShortInts: array [0..1] of ShortInt;
{$IFDEF UseFloatingPoint}
const
  CFixedPoint2Dot14Scale: Single = 1 / 16384;
{$ENDIF}
begin
  inherited;

  // read flags
  FFlags := BigEndianValueReader.ReadWord(Stream);

{$IFDEF AmbigiousExceptions}
  // make sure the GLYF_RESERVED flag is set to 0
  // if (FFlags and GLYF_RESERVED <> 0) then
  //   raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
{$ENDIF}
  // read glyph index
  FGlyphIndex := BigEndianValueReader.ReadWord(Stream);

  // read argument 1
  if (FFlags and GLYF_ARG_1_AND_2_ARE_WORDS <> 0) then
  begin
    if (FFlags and GLYF_ARGS_ARE_XY_VALUES <> 0) then
    begin
      FOffsetXY[0] := BigEndianValueReader.ReadSmallInt(Stream);
      FOffsetXY[1] := BigEndianValueReader.ReadSmallInt(Stream);
      FPointIndex[0] := 0;
      FPointIndex[1] := 0;
    end else
    begin
      FPointIndex[0] := BigEndianValueReader.ReadWord(Stream);
      FPointIndex[1] := BigEndianValueReader.ReadWord(Stream);
      FOffsetXY[0] := 0;
      FOffsetXY[1] := 0;
    end;
  end else
  begin
    if (FFlags and GLYF_ARGS_ARE_XY_VALUES <> 0) then
    begin
      Stream.Read(ShortInts[0], 1);
      Stream.Read(ShortInts[1], 1);
      FOffsetXY[0] := ShortInts[0];
      FOffsetXY[1] := ShortInts[1];
      FPointIndex[0] := 0;
      FPointIndex[1] := 0;
    end else
    begin
      Stream.Read(Bytes[0], 1);
      Stream.Read(Bytes[1], 1);
      FPointIndex[0] := Bytes[0];
      FPointIndex[1] := Bytes[1];
      FOffsetXY[0] := 0;
      FOffsetXY[1] := 0;
    end;
  end;

  if (FFlags and GLYF_WE_HAVE_A_SCALE <> 0) then
  begin
    // read scale
{$IFDEF UseFloatingPoint}
    FAffineTransformationMatrix[0, 0] := BigEndianValueReader.ReadSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FAffineTransformationMatrix[0, 0] := BigEndianValueReader.ReadSmallInt(Stream);
{$ENDIF}
    // set other values implicitly
    FAffineTransformationMatrix[0, 1] := 0;
    FAffineTransformationMatrix[1, 0] := 0;
    FAffineTransformationMatrix[1, 1] := FAffineTransformationMatrix[0, 0];

{$IFDEF AmbigiousExceptions}
    // GLYF_WE_HAVE_A_SCALE and GLYF_WE_HAVE_AN_X_AND_Y_SCALE are mutually exclusive
    if (FFlags and GLYF_WE_HAVE_AN_X_AND_Y_SCALE <> 0) then
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
    // GLYF_WE_HAVE_A_SCALE and GLYF_WE_HAVE_A_TWO_BY_TWO are mutually exclusive
    if (FFlags and GLYF_WE_HAVE_A_TWO_BY_TWO <> 0) then
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
{$ENDIF}
  end else
  if (FFlags and GLYF_WE_HAVE_AN_X_AND_Y_SCALE <> 0) then
  begin
    // read x-scale
{$IFDEF UseFloatingPoint}
    FAffineTransformationMatrix[0, 0] := BigEndianValueReader.ReadSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FAffineTransformationMatrix[0, 0] := BigEndianValueReader.ReadSmallInt(Stream);
{$ENDIF}

    // read y-scale
{$IFDEF UseFloatingPoint}
    FAffineTransformationMatrix[1, 1] := BigEndianValueReader.ReadSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FAffineTransformationMatrix[1, 1] := BigEndianValueReader.ReadSmallInt(Stream);
{$ENDIF}
    // set other values implicitly
    FAffineTransformationMatrix[0, 1] := 0;
    FAffineTransformationMatrix[1, 0] := 0;

{$IFDEF AmbigiousExceptions}
    // make sure the GLYF_RESERVED flag is set to 0
    if (FFlags and GLYF_WE_HAVE_A_SCALE <> 0) then // Unnecessary: We have already tested for this above...
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
    if (FFlags and GLYF_WE_HAVE_A_TWO_BY_TWO <> 0) then
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
{$ENDIF}
  end else
  if (FFlags and GLYF_WE_HAVE_A_TWO_BY_TWO <> 0) then
  begin
    // read x-scale
{$IFDEF UseFloatingPoint}
    FAffineTransformationMatrix[0, 0] := BigEndianValueReader.ReadSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FAffineTransformationMatrix[0, 0] := BigEndianValueReader.ReadSmallInt(Stream);
{$ENDIF}

    // read scale01
{$IFDEF UseFloatingPoint}
    FAffineTransformationMatrix[0, 1] := BigEndianValueReader.ReadSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FAffineTransformationMatrix[0, 1] := BigEndianValueReader.ReadSmallInt(Stream);
{$ENDIF}

    // read scale10
{$IFDEF UseFloatingPoint}
    FAffineTransformationMatrix[1, 0] := BigEndianValueReader.ReadSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FAffineTransformationMatrix[1, 0] := BigEndianValueReader.ReadSmallInt(Stream);
{$ENDIF}

    // read y-scale
{$IFDEF UseFloatingPoint}
    FAffineTransformationMatrix[1, 1] := BigEndianValueReader.ReadSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FAffineTransformationMatrix[1, 1] := BigEndianValueReader.ReadSmallInt(Stream);
{$ENDIF}
{$IFDEF AmbigiousExceptions}
    // GLYF_WE_HAVE_A_TWO_BY_TWO and GLYF_WE_HAVE_A_SCALE are mutually exclusive
    if (FFlags and GLYF_WE_HAVE_A_SCALE <> 0) then // Unnecessary: We have already tested for this above...
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
    // GLYF_WE_HAVE_A_TWO_BY_TWO and GLYF_WE_HAVE_AN_X_AND_Y_SCALE are mutually exclusive
    if (FFlags and GLYF_WE_HAVE_AN_X_AND_Y_SCALE <> 0) then // Unnecessary: We have already tested for this above...
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
{$ENDIF}
  end else
  begin
    FAffineTransformationMatrix[0, 0] := 1;
    FAffineTransformationMatrix[0, 1] := 0;
    FAffineTransformationMatrix[1, 0] := 0;
    FAffineTransformationMatrix[1, 1] := 1;
  end;

  if (FFlags and GLYF_ARGS_ARE_XY_VALUES <> 0) then
  begin
    FAffineTransformationMatrix[0, 2] := FOffsetXY[0];
    FAffineTransformationMatrix[1, 2] := FOffsetXY[1];
  end else
  begin
    // TODO: Implement point-to-point positioning. See issue #27, #31
    // I have not found a single font that actually uses this feature
    // so punting it for now.
    FAffineTransformationMatrix[0, 2] := 0;
    FAffineTransformationMatrix[1, 2] := 0;
  end;
end;

procedure TPascalTypeCompositeGlyph.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

procedure TPascalTypeCompositeGlyph.SetFlags(const Value: Word);
begin
  if FFlags <> Value then
  begin
    FFlags := Value;
    FlagsChanged;
  end;
end;

procedure TPascalTypeCompositeGlyph.SetGlyphIndex(const Value: Word);
begin
  if FGlyphIndex <> Value then
  begin
    FGlyphIndex := Value;
    GlyphIndexChanged;
  end;
end;

function TPascalTypeCompositeGlyph.FlagArgsAreOffset: boolean;
begin
  Result := (FFlags and GLYF_ARGS_ARE_XY_VALUES <> 0);
end;

function TPascalTypeCompositeGlyph.FlagHasAffineTransformationMatrix: boolean;
begin
  Result := (FFlags and (GLYF_WE_HAVE_A_SCALE or GLYF_WE_HAVE_AN_X_AND_Y_SCALE or GLYF_WE_HAVE_A_TWO_BY_TWO) <> 0);
end;

function TPascalTypeCompositeGlyph.FlagHasInstructions: boolean;
begin
  Result := (FFlags and GLYF_WE_HAVE_INSTRUCTIONS <> 0);
end;

function TPascalTypeCompositeGlyph.FlagMoreComponents: boolean;
begin
  Result := (FFlags and GLYF_MORE_COMPONENTS <> 0);
end;

procedure TPascalTypeCompositeGlyph.FlagsChanged;
begin
  Changed;
end;

function TPascalTypeCompositeGlyph.GetArgsAreOffset: boolean;
begin
  Result := FlagArgsAreOffset and ((OffsetX <> 0) or (OffsetY <> 0));
end;

function TPascalTypeCompositeGlyph.GetArgsArePointIndex: boolean;
begin
  Result := (not FlagArgsAreOffset);
end;

function TPascalTypeCompositeGlyph.GetHasAffineTransformationMatrix: boolean;
begin
  Result := FlagHasAffineTransformationMatrix;
end;

procedure TPascalTypeCompositeGlyph.GlyphIndexChanged;
begin
  Changed;
end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontCompositeGlyphData
//
//------------------------------------------------------------------------------
destructor TTrueTypeFontCompositeGlyphData.Destroy;
var
  ContourIndex: Integer;
begin
  for ContourIndex := 0 to High(FGlyphs) do
    FreeAndNil(FGlyphs[ContourIndex]);
  inherited;
end;

procedure TTrueTypeFontCompositeGlyphData.Assign(Source: TPersistent);
var
  GlyphsIndex: Integer;
begin
  inherited;
  if Source is Self.ClassType then
  begin
    // eventually clear not used contours
    for GlyphsIndex := Length(TTrueTypeFontCompositeGlyphData(Source).FGlyphs) to High(FGlyphs) do
      FreeAndNil(FGlyphs[GlyphsIndex]);

    // set length of countour array
    SetLength(FGlyphs, Length(TTrueTypeFontCompositeGlyphData(Source).FGlyphs));

    // assign contours
    for GlyphsIndex := 0 to High(FGlyphs) do
    begin
      // eventually create the contour
      if (FGlyphs[GlyphsIndex] = nil) then
        FGlyphs[GlyphsIndex] := TPascalTypeCompositeGlyph.Create;

      // assign contour
      FGlyphs[GlyphsIndex].Assign(TTrueTypeFontCompositeGlyphData(Source).FGlyphs[GlyphsIndex]);
    end;
  end;
end;

function TTrueTypeFontCompositeGlyphData.GetCompositeGlyph(Index: Integer): TPascalTypeCompositeGlyph;
begin
  if (Index < 0) or (Index > High(FGlyphs)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FGlyphs[Index];
end;

function TTrueTypeFontCompositeGlyphData.GetContourCount: Integer;
var
  GlyphDataTable: TTrueTypeFontGlyphDataTable;
  Glyph: TPascalTypeCompositeGlyph;
begin
  Result := 0;


  GlyphDataTable := TTrueTypeFontGlyphDataTable(FontFace.GetTableByTableName('glyf'));
  if (GlyphDataTable = nil) then
    exit;

  for Glyph in FGlyphs do
    Result := Result + GlyphDataTable.GlyphData[Glyph.GlyphIndex].ContourCount;
end;

function TTrueTypeFontCompositeGlyphData.GetGlyphCount: Integer;
begin
  Result := Length(FGlyphs);
end;

function TTrueTypeFontCompositeGlyphData.GetIsComposite: boolean;
begin
  Result := True;
end;

procedure TTrueTypeFontCompositeGlyphData.LoadFromStream(Stream: TStream);
var
  GlyphIndex     : Integer;
  HasInstructions: Boolean;
  MoreComponents: boolean;
  Glyph: TPascalTypeCompositeGlyph;
begin
  inherited;

  // a default glyph does not contain instructions
  HasInstructions := False;

  // clear existing glyphs
  for GlyphIndex := 0 to High(FGlyphs) do
    FreeAndNil(FGlyphs[GlyphIndex]);
  SetLength(FGlyphs, 0);

  MoreComponents := True;
  while (MoreComponents) do
  begin
    // add new array element
    SetLength(FGlyphs, Length(FGlyphs) + 1);

    // create composite glyph
    Glyph := TPascalTypeCompositeGlyph.Create;
    FGlyphs[High(FGlyphs)] := Glyph;

    // load composite glyph from stream
    Glyph.LoadFromStream(Stream);

    HasInstructions := HasInstructions or Glyph.FlagHasInstructions;
    MoreComponents := Glyph.FlagMoreComponents;
  end;

  // eventually read instructions
  if HasInstructions then
    FInstructions.LoadFromStream(Stream);
end;

procedure TTrueTypeFontCompositeGlyphData.SaveToStream(Stream: TStream);
var
  GlyphIndex: Integer;
begin
  // save glyphs
  for GlyphIndex := 0 to High(FGlyphs) do
    FGlyphs[GlyphIndex].SaveToStream(Stream);

  // save instructions to stream
  FInstructions.SaveToStream(Stream);
end;


//------------------------------------------------------------------------------
//
//              TTrueTypeFontGlyphDataTable
//
//------------------------------------------------------------------------------
destructor TTrueTypeFontGlyphDataTable.Destroy;
begin
  FreeGlyphDataListItems;
  inherited;
end;

procedure TTrueTypeFontGlyphDataTable.Assign(Source: TPersistent);
var
  GlyphsIndex: Integer;
  GlyphClass : TTrueTypeFontGlyphDataClass;
begin
  inherited;
  if Source is TTrueTypeFontGlyphDataTable then
  begin
    // free all glyph data
    FreeGlyphDataListItems;

    // set length of countour array
    SetLength(FGlyphDataList, Length(TTrueTypeFontGlyphDataTable(Source).FGlyphDataList));

    // assign contours
    for GlyphsIndex := 0 to Length(FGlyphDataList) - 1 do
    begin
      GlyphClass := TTrueTypeFontGlyphDataClass(TTrueTypeFontGlyphDataTable(Source).FGlyphDataList[GlyphsIndex].ClassType);

      // eventually create the contour
      FGlyphDataList[GlyphsIndex] := GlyphClass.Create(Self);

      // assign contour
      FGlyphDataList[GlyphsIndex].Assign(TTrueTypeFontGlyphDataTable(Source).FGlyphDataList[GlyphsIndex]);
    end;
  end;
end;

function TTrueTypeFontGlyphDataTable.GetGlyphData(Index: Integer): TCustomTrueTypeFontGlyphData;
begin
  if (Index < 0) or (Index > High(FGlyphDataList)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := TCustomTrueTypeFontGlyphData(FGlyphDataList[Index]);
end;

function TTrueTypeFontGlyphDataTable.GetGlyphDataCount: Integer;
begin
  Result := Length(FGlyphDataList);
end;

class function TTrueTypeFontGlyphDataTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'glyf';
end;

procedure TTrueTypeFontGlyphDataTable.FreeGlyphDataListItems;
var
  GlyphIndex: Integer;
begin
  for GlyphIndex := 0 to High(FGlyphDataList) do
    FreeAndNil(FGlyphDataList[GlyphIndex]);
end;

procedure TTrueTypeFontGlyphDataTable.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  Locations: TTrueTypeFontLocationTable;
  LocIndex : Integer;
  Value16  : SmallInt;
begin
  // get location table
  Locations := TTrueTypeFontLocationTable(FontFace.GetTableByTableName('loca'));
  if (Locations = nil) then
    raise EPascalTypeError.Create(RCStrNoIndexToLocationTable);

  // store initil position
  StartPos := Stream.Position;

  // check (minimum) table size
  if Stream.Position + 10 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // clear glyph data list length
  for LocIndex := 0 to High(FGlyphDataList) do
    FreeAndNil(FGlyphDataList[LocIndex]);
  SetLength(FGlyphDataList, Locations.LocationCount - 1);

  for LocIndex := 0 to Locations.LocationCount - 2 do
  begin
    if (Locations[LocIndex] = Locations[LocIndex+1]) then
    begin
      // Empty glyph
      FGlyphDataList[LocIndex] := TTrueTypeFontSimpleGlyphData.Create(Self);
      continue;
    end;

    Stream.Position := StartPos + Locations[LocIndex];

    Value16 := BigEndianValueReader.ReadSmallInt(Stream);

    if (Value16 < -1) then
      raise EPascalTypeError.CreateFmt(RCStrUnknownGlyphDataType, [Value16]);

    // set position before number of contours
    Stream.Seek(-2, soFromCurrent);

    // read number of contours and create glyph data object
    if Value16 > 0 then
      FGlyphDataList[LocIndex] := TTrueTypeFontSimpleGlyphData.Create(Self)
    else
      FGlyphDataList[LocIndex] := TTrueTypeFontCompositeGlyphData.Create(Self);

    try
      FGlyphDataList[LocIndex].LoadFromStream(Stream);
    except
      on e: EPascalTypeError do
        Exception.RaiseOuterException(EPascalTypeError.CreateFmt('Error loading glyph #%d'#10 + e.Message, [LocIndex]));
    end;
  end;

{$IFDEF AmbigiousExceptions}
  if Locations[Locations.LocationCount - 1] > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);
{$ENDIF}
end;

procedure TTrueTypeFontGlyphDataTable.SaveToStream(Stream: TStream);
var
  GlyphDataIndex: Integer;
begin
  for GlyphDataIndex := 0 to High(FGlyphDataList) do
    FGlyphDataList[GlyphDataIndex].SaveToStream(Stream);
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

initialization

  RegisterPascalTypeTables([TTrueTypeFontGlyphDataTable]);

end.
