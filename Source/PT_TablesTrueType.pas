unit PT_TablesTrueType;

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
  Classes, Contnrs, SysUtils, PT_Types, PT_Classes, PT_Tables;

type
  // table 'cvt '

  TTrueTypeFontControlValueTable = class(TCustomPascalTypeNamedTable)
  private
    FControlValues: array of SmallInt;
    function GetControlValue(Index: Integer): SmallInt;
    function GetControlValueCount: Integer;
  protected
    procedure AssignTo(Dest: TPersistent); override;

    procedure ResetToDefaults; override;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property ControlValue[Index: Integer]: SmallInt read GetControlValue;
    property ControlValueCount: Integer read GetControlValueCount;
  end;


  // TCustomTrueTypeFontInstructionTable

  TCustomTrueTypeFontInstructionTable = class(TCustomPascalTypeNamedTable)
  private
    FInstructions: array of Byte;
    function GetInstruction(Index: Integer): Byte;
    function GetInstructionCount: Integer;
  protected
    procedure AssignTo(Dest: TPersistent); override;

    procedure ResetToDefaults; override;
  public
    constructor Create(const AStorage: IPascalTypeStorageTable); override;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Instruction[Index: Integer]: Byte read GetInstruction;
    property InstructionCount: Integer read GetInstructionCount;
  end;


  // table 'fpgm'

  TTrueTypeFontFontProgramTable = class(TCustomTrueTypeFontInstructionTable)
  public
    class function GetTableType: TTableType; override;
  end;


  // table 'glyf'

  // TCustomTrueTypeFontInstructionTable

  TTrueTypeFontGlyphInstructionTable = class(TCustomPascalTypeInterfaceTable)
  private
    FInstructions: array of Byte;
    function GetInstruction(Index: Integer): Byte;
    function GetInstructionCount: Integer;
  protected
    procedure AssignTo(Dest: TPersistent); override;

    procedure ResetToDefaults; override;
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Instruction[Index: Integer]: Byte read GetInstruction;
    property InstructionCount: Integer read GetInstructionCount;
  end;

  TCustomTrueTypeFontGlyphData = class(TCustomPascalTypeGlyphDataTable)
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

    procedure AssignTo(Dest: TPersistent); override;

    procedure ResetToDefaults; override;

    function GetContourCount: Integer; virtual; abstract;

    procedure GlyphIndexChanged; virtual;
    procedure NumberOfContoursChanged; virtual;
    procedure XMaxChanged; virtual;
    procedure XMinChanged; virtual;
    procedure YMaxChanged; virtual;
    procedure YMinChanged; virtual;
  public
    constructor Create(const Storage: IPascalTypeStorageTable); reintroduce; virtual;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property NumberOfContours: SmallInt read FNumberOfContours write SetNumberOfContours;
    property XMin: SmallInt read FXMin write SetXMin;
    property YMin: SmallInt read FYMin write SetYMin;
    property XMax: SmallInt read FXMax write SetXMax;
    property YMax: SmallInt read FYMax write SetYMax;

    property GlyphIndex: Integer read GetGlyphIndex;

    property Instructions: TTrueTypeFontGlyphInstructionTable read FInstructions;
    property ContourCount: Integer read GetContourCount;
  end;

  TTrueTypeFontGlyphDataClass = class of TCustomTrueTypeFontGlyphData;

  TContourPointRecord = record
    XPos: SmallInt;
    YPos: SmallInt;
    Flags: Byte;

    function FlagIsOnCurve: boolean;
  end;

  TPascalTypeTrueTypeContour = class(TPersistent)
  private type
    TContourPointRecordArray = array of TContourPointRecord;
  private
    FPoints: TContourPointRecordArray;
    function GetPoint(Index: Integer): TContourPointRecord;
    function GetPointCount: Integer;
    procedure SetPoint(Index: Integer; const Value: TContourPointRecord);
    procedure SetPointCount(const Value: Integer);
    function GetIsClockwise: Boolean;
    function GetArea: Integer;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure PointCountChanged; virtual;
    property Points: TContourPointRecordArray read FPoints;
  public
    property Area                 : Integer read GetArea;
    property IsClockwise          : Boolean read GetIsClockwise;
    property Point[Index: Integer]: TContourPointRecord read GetPoint write SetPoint;
    property PointCount: Integer read GetPointCount write SetPointCount;
  end;

  TTrueTypeFontSimpleGlyphData = class(TCustomTrueTypeFontGlyphData)
  public
    const
      // Simple glyf flags
      // https://learn.microsoft.com/en-us/typography/opentype/spec/glyf
      GLYF_ON_CURVE             = $01; // Data point is on curve (i.e. not a control point)
      GLYF_X_SHORT_VECTOR       = $02;
      GLYF_Y_SHORT_VECTOR       = $04;
      GLYF_REPEAT_FLAG          = $08;
      GLYF_X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR = $10;
      GLYF_Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR = $20;
      GLYF_OVERLAP_SIMPLE       = $40;
      GLYF_RESERVED8            = $80;
      GLYF_RESERVED             = GLYF_RESERVED8;
  private
    FContours: array of TPascalTypeTrueTypeContour;
    function GetContour(Index: Integer): TPascalTypeTrueTypeContour;
    procedure FreeContourArrayItems;
  protected
    procedure ResetToDefaults; override;
    procedure AssignTo(Dest: TPersistent); override;

    function GetContourCount: Integer; override;
  public
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Contour[Index: Integer]: TPascalTypeTrueTypeContour read GetContour;
  end;

  TPascalTypeCompositeGlyph = class(TCustomPascalTypeTable)
  private
    const
      ARG_1_AND_2_ARE_WORDS     = $0001;
      ARGS_ARE_XY_VALUES        = $0002;
      ROUND_XY_TO_GRID          = $0004;
      WE_HAVE_A_SCALE           = $0008;
      RESERVED5                 = $0010;
      MORE_COMPONENTS           = $0020;
      WE_HAVE_AN_X_AND_Y_SCALE  = $0040;
      WE_HAVE_A_TWO_BY_TWO      = $0080;
      WE_HAVE_INSTRUCTIONS      = $0100;
      USE_MY_METRICS            = $0200;
      OVERLAP_COMPOUND          = $0400;
      SCALED_COMPONENT_OFFSET   = $0800;
      UNSCALED_COMPONENT_OFFSET = $1000;
      RESERVED13                = $2000;
      RESERVED14                = $4000;
      RESERVED15                = $8000;
      RESERVED                  = RESERVED5 or RESERVED13 or RESERVED14 or RESERVED15;
  private
    FFlags     : Word; // Component flag
    FGlyphIndex: Word; // Glyph index of component
    FArgument  : array [0..1] of Integer;
    FScale     : TSmallScaleMatrix;
    procedure SetFlags(const Value: Word);
    procedure SetGlyphIndex(const Value: Word);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure ResetToDefaults; override;

    procedure FlagsChanged; virtual;
    procedure GlyphIndexChanged; virtual;

    function FlagMoreComponents: boolean;
    function FlagHasInstructions: boolean;
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Flags: Word read FFlags write SetFlags;
    property GlyphIndex: Word read FGlyphIndex write SetGlyphIndex;
    property ArgumentX: Integer read FArgument[0];
    property ArgumentY: Integer read FArgument[1];
  end;

  TTrueTypeFontCompositeGlyphData = class(TCustomTrueTypeFontGlyphData)
  private
    FGlyphs: array of TPascalTypeCompositeGlyph;
    function GetGlyphCount: Integer;
    function GetCompositeGlyph(Index: Integer): TPascalTypeCompositeGlyph;
  protected
    procedure AssignTo(Dest: TPersistent); override;

    procedure ResetToDefaults; override;

    function GetContourCount: Integer; override;
  public
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property GlyphCount: Integer read GetGlyphCount;
    property Glyph[Index: Integer]: TPascalTypeCompositeGlyph read GetCompositeGlyph;
  end;

  TTrueTypeFontGlyphDataTable = class(TCustomPascalTypeNamedTable)
  private
    FGlyphDataList: array of TCustomTrueTypeFontGlyphData;
    function GetGlyphDataCount: Integer;
    function GetGlyphData(Index: Integer): TCustomTrueTypeFontGlyphData;
    procedure FreeGlyphDataListItems;
  protected
    procedure AssignTo(Dest: TPersistent); override;

    procedure ResetToDefaults; override;
  public
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property GlyphDataCount: Integer read GetGlyphDataCount;
    property GlyphData[Index: Integer]: TCustomTrueTypeFontGlyphData read GetGlyphData;
  end;


  // table 'loca'

  TTrueTypeFontLocationTable = class(TCustomPascalTypeNamedTable)
  private
    FLocations: array of Cardinal;
    function GetLocation(Index: Integer): Cardinal;
    function GetLocationCount: Cardinal;
  protected
    procedure AssignTo(Dest: TPersistent); override;

    procedure ResetToDefaults; override;
  public
    class function GetTableType: TTableType; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Location[Index: Integer]: Cardinal read GetLocation; default;
    property LocationCount: Cardinal read GetLocationCount;
  end;


  // table 'prep'

  TTrueTypeFontControlValueProgramTable = class
    (TCustomTrueTypeFontInstructionTable)
  public
    class function GetTableType: TTableType; override;
  end;

implementation

uses
  PT_Math, PT_ResourceStrings;


{ TTrueTypeFontControlValueTable }

constructor TTrueTypeFontControlValueTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  // nothing in here yet
  inherited;
end;

destructor TTrueTypeFontControlValueTable.Destroy;
begin
  // nothing in here yet
  inherited;
end;

procedure TTrueTypeFontControlValueTable.AssignTo(Dest: TPersistent);
begin
  if Dest is Self.ClassType then
    with TTrueTypeFontControlValueTable(Dest) do
    begin
      FControlValues := Self.FControlValues;
    end
  else
    inherited;
end;

class function TTrueTypeFontControlValueTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'cvt ';
end;

procedure TTrueTypeFontControlValueTable.ResetToDefaults;
begin
  SetLength(FControlValues, 0);
end;

function TTrueTypeFontControlValueTable.GetControlValue(Index: Integer)
  : SmallInt;
begin
  if (Index < Length(FControlValues)) then
    Result := Swap16(FControlValues[Index])
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TTrueTypeFontControlValueTable.GetControlValueCount: Integer;
begin
  Result := Length(FControlValues);
end;

procedure TTrueTypeFontControlValueTable.LoadFromStream(Stream: TStream);
begin
  with Stream do
  begin
    SetLength(FControlValues, Size div 2);

    // check for minimal table size
    if Position + Length(FControlValues) * SizeOf(Word) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read control values
    Read(FControlValues[0], Length(FControlValues) * SizeOf(Word));
  end;
end;

procedure TTrueTypeFontControlValueTable.SaveToStream(Stream: TStream);
begin
  // write control values
  Stream.Write(FControlValues[0], Length(FControlValues) * SizeOf(Word));
end;


{ TCustomTrueTypeFontInstructionTable }

constructor TCustomTrueTypeFontInstructionTable.Create(const AStorage: IPascalTypeStorageTable);
begin
  // nothing in here yet
  inherited;
end;

destructor TCustomTrueTypeFontInstructionTable.Destroy;
begin
  // nothing in here yet
  inherited;
end;

procedure TCustomTrueTypeFontInstructionTable.AssignTo(Dest: TPersistent);
begin
  if Dest is Self.ClassType then
    with TCustomTrueTypeFontInstructionTable(Dest) do
    begin
      FInstructions := Self.FInstructions;
    end
  else
    inherited;
end;

procedure TCustomTrueTypeFontInstructionTable.ResetToDefaults;
begin
  SetLength(FInstructions, 0);
end;

function TCustomTrueTypeFontInstructionTable.GetInstruction
  (Index: Integer): Byte;
begin
  if (Index < Length(FInstructions)) then
    Result := FInstructions[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TCustomTrueTypeFontInstructionTable.GetInstructionCount: Integer;
begin
  Result := Length(FInstructions);
end;

procedure TCustomTrueTypeFontInstructionTable.LoadFromStream(Stream: TStream);
begin
  with Stream do
  begin
    SetLength(FInstructions, Size);

    // check for minimal table size
    if Position + Length(FInstructions) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read control values
    Read(FInstructions[0], Length(FInstructions) * SizeOf(Word));
  end;
end;

procedure TCustomTrueTypeFontInstructionTable.SaveToStream(Stream: TStream);
begin
  // write instructions
  Stream.Write(FInstructions[0], Length(FInstructions));
end;


{ TTrueTypeFontFontProgramTable }

class function TTrueTypeFontFontProgramTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'fpgm';
end;


{ TTrueTypeFontGlyphInstructionTable }

procedure TTrueTypeFontGlyphInstructionTable.AssignTo(Dest: TPersistent);
begin
  if Dest is Self.ClassType then
    with TTrueTypeFontGlyphInstructionTable(Dest) do
    begin
      FInstructions := Self.FInstructions;
    end
  else
    inherited;
end;

function TTrueTypeFontGlyphInstructionTable.GetInstruction
  (Index: Integer): Byte;
begin
  if (Index < Length(FInstructions)) then
    Result := FInstructions[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TTrueTypeFontGlyphInstructionTable.GetInstructionCount: Integer;
begin
  Result := Length(FInstructions);
end;

procedure TTrueTypeFontGlyphInstructionTable.ResetToDefaults;
begin
  SetLength(FInstructions, 0);
end;

procedure TTrueTypeFontGlyphInstructionTable.LoadFromStream(Stream: TStream);
var
  Value16   : Word;
  MaxProfile: TPascalTypeMaximumProfileTable;
begin
  MaxProfile := TPascalTypeMaximumProfileTable(Storage.GetTableByTableName('maxp'));
  Assert(MaxProfile <> nil);

  // read instruction size
  Value16 := ReadSwappedWord(Stream);

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


{ TCustomTrueTypeFontGlyphData }

constructor TCustomTrueTypeFontGlyphData.Create(const Storage: IPascalTypeStorageTable);
begin
  FInstructions := TTrueTypeFontGlyphInstructionTable.Create(Storage);
  inherited Create(Storage);
end;

destructor TCustomTrueTypeFontGlyphData.Destroy;
begin
  FreeAndNil(FInstructions);
  inherited;
end;

function TCustomTrueTypeFontGlyphData.GetGlyphIndex: Integer;
var
  GlyphDataTable: TTrueTypeFontGlyphDataTable;
  GlyphIndex    : Integer;
begin
  GlyphDataTable := TTrueTypeFontGlyphDataTable(Storage.GetTableByTableName('glyf'));
  Result := -1;
  if (GlyphDataTable <> nil) then
    for GlyphIndex := 0 to GlyphDataTable.GlyphDataCount - 1 do
      if GlyphDataTable.GlyphData[GlyphIndex] = Self then
      begin
        Result := GlyphIndex;
        Exit;
      end;
end;

procedure TCustomTrueTypeFontGlyphData.GlyphIndexChanged;
begin
  Changed;
end;

procedure TCustomTrueTypeFontGlyphData.AssignTo(Dest: TPersistent);
begin
  if Dest is Self.ClassType then
    with TCustomTrueTypeFontGlyphData(Dest) do
    begin
      FNumberOfContours := Self.FNumberOfContours;
      FXMin := Self.FXMin;
      FYMin := Self.FYMin;
      FXMax := Self.FXMax;
      FYMax := Self.FYMax;
    end
  else
    inherited;
end;

procedure TCustomTrueTypeFontGlyphData.ResetToDefaults;
begin
  FNumberOfContours := 0;
  FXMin := 0;
  FYMin := 0;
  FXMax := 0;
  FYMax := 0;
end;

procedure TCustomTrueTypeFontGlyphData.LoadFromStream(Stream: TStream);
var
  MaxProfile: TPascalTypeMaximumProfileTable;
begin
  // get maximum profile
  MaxProfile := TPascalTypeMaximumProfileTable(Storage.GetTableByTableClass(TPascalTypeMaximumProfileTable));

  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read number of contours
  FNumberOfContours := ReadSwappedSmallInt(Stream);

  // check if maximum number of contours are exceeded
  if (FNumberOfContours > 0) and (Word(FNumberOfContours) > MaxProfile.MaxContours) then
    raise EPascalTypeError.CreateFmt(RCStrTooManyContours, [FNumberOfContours, MaxProfile.MaxContours]);

  // check if glyph contains any information at all
  if FNumberOfContours = 0 then
    Exit;

  if Stream.Position + 8 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read XMin
  FXMin := ReadSwappedSmallInt(Stream);

  // read YMin
  FYMin := ReadSwappedSmallInt(Stream);

  // read XMax
  FXMax := ReadSwappedSmallInt(Stream);

  // read YMax
  FYMax := ReadSwappedSmallInt(Stream);

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


{ TContourPointRecord }

function TContourPointRecord.FlagIsOnCurve: boolean;
begin
  Result := (Flags and TTrueTypeFontSimpleGlyphData.GLYF_ON_CURVE <> 0);
end;

{ TPascalTypeTrueTypeContour }

procedure TPascalTypeTrueTypeContour.AssignTo(Dest: TPersistent);
begin
  if Dest is Self.ClassType then
    with TPascalTypeTrueTypeContour(Dest) do
    begin
      FPoints := Self.FPoints;
    end
  else
    inherited;
end;

function TPascalTypeTrueTypeContour.GetArea: Integer;
var
  PointIndex: Integer;
begin

  if Length(FPoints) < 3 then
  begin
    Result := 0;
    Exit;
  end;

  Result := (FPoints[0].XPos * FPoints[1].YPos - FPoints[1].XPos * FPoints[0].YPos) div 2;
  for PointIndex := 1 to High(FPoints) - 1 do
    Result := Result * (FPoints[0].XPos * FPoints[1].YPos - FPoints[1].XPos * FPoints[0].YPos);
end;

function TPascalTypeTrueTypeContour.GetIsClockwise: Boolean;
begin
  Result := (Area >= 0);
end;

function TPascalTypeTrueTypeContour.GetPoint(Index: Integer): TContourPointRecord;
begin
  if (Index >= 0) and (Index <= High(FPoints)) then
    Result := FPoints[Index]
  else
  if (Index = Length(FPoints)) then
    Result := FPoints[0] // Wrap around to first
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

procedure TPascalTypeTrueTypeContour.SetPoint(Index: Integer; const Value: TContourPointRecord);
begin
  if (Index < 0) or (Index > High(FPoints)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
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


{ TTrueTypeFontSimpleGlyphData }

destructor TTrueTypeFontSimpleGlyphData.Destroy;
begin
  FreeContourArrayItems;
  inherited;
end;

procedure TTrueTypeFontSimpleGlyphData.AssignTo(Dest: TPersistent);
var
  ContourIndex: Integer;
begin
  if Dest is Self.ClassType then
    with TTrueTypeFontSimpleGlyphData(Dest) do
    begin
      // eventually clear not used contours
      for ContourIndex := Length(Self.FContours) to High(FContours) do
        FreeAndNil(FContours[ContourIndex]);

      // set length of countour array
      SetLength(FContours, Length(Self.FContours));

      // assign contours
      for ContourIndex := 0 to High(Self.FContours) do
      begin
        // eventually create the contour
        if (FContours[ContourIndex] = nil) then
          FContours[ContourIndex] := TPascalTypeTrueTypeContour.Create;

        // assign contour
        FContours[ContourIndex].Assign(Self.FContours[ContourIndex]);
      end;
    end
  else
    inherited;
end;

procedure TTrueTypeFontSimpleGlyphData.FreeContourArrayItems;
var
  ContourIndex: Integer;
begin
  for ContourIndex := 0 to High(FContours) do
    FreeAndNil(FContours[ContourIndex]);
end;

procedure TTrueTypeFontSimpleGlyphData.ResetToDefaults;
begin
  FInstructions.ResetToDefaults;

  // free contour list
  FreeContourArrayItems;
  SetLength(FContours, 0);
end;

function TTrueTypeFontSimpleGlyphData.GetContour(Index: Integer): TPascalTypeTrueTypeContour;
begin
  if (Index < 0) or (Index > High(FContours)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FContours[Index];
end;

function TTrueTypeFontSimpleGlyphData.GetContourCount: Integer;
begin
  Result := Length(FContours);
end;

procedure TTrueTypeFontSimpleGlyphData.LoadFromStream(Stream: TStream);
var
  ContourIndex: Integer;
  PointIndex  : Integer;
  CntrPntIndex: Integer;
  PointCount  : Integer;
  LastPoint   : Integer;
  Contour     : TPascalTypeTrueTypeContour;
  MaxProfile  : TPascalTypeMaximumProfileTable;
  EndPtsOfCont: array of SmallInt;
  Flag        : Byte;
  FlagCount   : Byte;
  Value8      : Byte absolute FlagCount;
begin
  inherited;

  // get maximum profile
  MaxProfile := TPascalTypeMaximumProfileTable(Storage.GetTableByTableClass(TPascalTypeMaximumProfileTable));

  // check if glyph contains any information at all
  if FNumberOfContours = 0 then
    Exit;

  // set end points of contours array size
  SetLength(EndPtsOfCont, FNumberOfContours);

  // reset point count
  PointCount := -1;

  // read end points
  for ContourIndex := 0 to FNumberOfContours - 1 do
  begin
    // read number of contours
    PointCount := ReadSwappedWord(Stream);
    EndPtsOfCont[ContourIndex] := PointCount;
  end;

  // increase last end point to get the true point count
  Inc(PointCount);

  // check if maximum points are exceeded
  if PointCount > MaxProfile.MaxPoints then
    raise EPascalTypeError.CreateFmt(RCStrTooManyPoints, [PointCount]);

  // read instructions
  FInstructions.LoadFromStream(Stream);

  // clear eventuall existing contours
  for ContourIndex := FNumberOfContours to High(FContours) do
    FreeAndNil(FContours[ContourIndex]);
  SetLength(FContours, FNumberOfContours);

  for ContourIndex := 0 to FNumberOfContours - 1 do
  begin
    // eventually create new contour
    Contour := FContours[ContourIndex];
    if (Contour = nil) then
    begin
      Contour := TPascalTypeTrueTypeContour.Create;
      FContours[ContourIndex] := Contour;
    end;

    // set contour point count
    if ContourIndex = 0 then
      Contour.PointCount := EndPtsOfCont[ContourIndex] + 1
    else
      Contour.PointCount := (EndPtsOfCont[ContourIndex] - EndPtsOfCont[ContourIndex - 1]);
  end;

  // reset point and contour index
  PointIndex := 0;
  ContourIndex := 0;
  CntrPntIndex := 0;

  // set first contour
  Contour := TPascalTypeTrueTypeContour(FContours[ContourIndex]);

  while PointIndex < PointCount do
  begin
    // eventually increase contour index
    if PointIndex > EndPtsOfCont[ContourIndex] then
    begin
      Inc(ContourIndex);
      CntrPntIndex := 0;

      // set next contour
      Contour := TPascalTypeTrueTypeContour(FContours[ContourIndex]);
    end;

    // read flag value
    Stream.Read(Flag, 1);

{$IFDEF AmbigiousExceptions}
    if (Flag and GLYF_RESERVED <> 0) then
      raise EPascalTypeError.CreateFmt(RCStrGlyphDataFlagReservedError, [PointIndex, PointCount]);
{$ENDIF}
    // set flags
    Contour.FPoints[CntrPntIndex].Flags := Flag;

    // increase point index
    Inc(PointIndex);
    Inc(CntrPntIndex);

    // check for 'repeat' flag
    if (Flag and GLYF_REPEAT_FLAG <> 0) then
    begin
      // read repeat count
      Stream.Read(FlagCount, 1);

      if (PointIndex + FlagCount > PointCount) then
        raise EPascalTypeError.CreateFmt(RCStrGlyphDataFlagRepeatError, [PointIndex + FlagCount, PointCount]);

      while FlagCount > 0 do
      begin
        // eventually increase contour index
        if PointIndex > EndPtsOfCont[ContourIndex] then
        begin
          Inc(ContourIndex);
          CntrPntIndex := 0;

          // set next contour
          Contour := TPascalTypeTrueTypeContour(FContours[ContourIndex]);
        end;

        // set flags
        Contour.FPoints[CntrPntIndex].Flags := Flag;

        Inc(PointIndex);
        Inc(CntrPntIndex);
        Dec(FlagCount);
      end
    end
  end;

  // reset contour and point index
  ContourIndex := 0;
  CntrPntIndex := 0;

  // set first contour
  Contour := TPascalTypeTrueTypeContour(FContours[ContourIndex]);

  // reset last point
  LastPoint := 0;

  // read x-coordinates
  for PointIndex := 0 to PointCount - 1 do
  begin
    // eventually increase contour
    if PointIndex > EndPtsOfCont[ContourIndex] then
    begin
      Inc(ContourIndex);
      CntrPntIndex := 0;

      // set next contour
      Contour := TPascalTypeTrueTypeContour(FContours[ContourIndex])
    end;

    // check for short or long version
    with Contour, FPoints[CntrPntIndex] do
    begin
      if (Flags and GLYF_X_SHORT_VECTOR <> 0) then
      begin
        Stream.Read(Value8, 1);

        // eventually change sign
        if (Flags and GLYF_X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR <> 0) then
          XPos := LastPoint + Value8
        else
          XPos := LastPoint - Value8;
      end else
      begin
        // eventually use last point
        if (Flags and GLYF_X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR <> 0) then
          XPos := LastPoint
        else
          XPos := LastPoint + ReadSwappedSmallInt(Stream);
      end;
      LastPoint := XPos;

      Inc(CntrPntIndex);
    end;
  end;

  // reset contour and point index
  ContourIndex := 0;
  CntrPntIndex := 0;

  // set first contour
  Contour := TPascalTypeTrueTypeContour(FContours[ContourIndex]);

  // reset last point
  LastPoint := 0;

  // read y-coordinates
  for PointIndex := 0 to PointCount - 1 do
  begin
    // eventually increase contour
    if PointIndex > EndPtsOfCont[ContourIndex] then
    begin
      Inc(ContourIndex);
      CntrPntIndex := 0;

      // set next contour
      Contour := TPascalTypeTrueTypeContour(FContours[ContourIndex])
    end;

    // check for short or long version
    with Contour, FPoints[CntrPntIndex] do
    begin
      if (Flags and GLYF_Y_SHORT_VECTOR <> 0) then
      begin
        Stream.Read(Value8, 1);

        // eventually change sign
        if (Flags and GLYF_Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR <> 0) then
          YPos := LastPoint + Value8
        else
          YPos := LastPoint - Value8;
      end else
      begin
        // eventually use last point
        if (Flags and GLYF_Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR <> 0) then
          YPos := LastPoint
        else
          YPos := LastPoint + ReadSwappedSmallInt(Stream);
      end;
      LastPoint := YPos;

      Inc(CntrPntIndex);
    end;

  end;
end;

procedure TTrueTypeFontSimpleGlyphData.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeCompositeGlyph }

procedure TPascalTypeCompositeGlyph.AssignTo(Dest: TPersistent);
begin
  if Dest is Self.ClassType then
    with TTrueTypeFontCompositeGlyphData(Dest) do
    begin
      FFlags := Self.FFlags;
      FGlyphIndex := Self.FGlyphIndex;
      FArgument := Self.FArgument;
    end
  else
    inherited;
end;

procedure TPascalTypeCompositeGlyph.ResetToDefaults;
begin
  FFlags := 0;
  FGlyphIndex := 0;
  FArgument[0] := 0;
  FArgument[1] := 0;
end;

procedure TPascalTypeCompositeGlyph.LoadFromStream(Stream: TStream);
var
  Argument: array [0..1] of SmallInt;
  Bytes: array [0..1] of byte;
{$IFDEF UseFloatingPoint}
const
  CFixedPoint2Dot14Scale: Single = 1 / 16384;
{$ENDIF}
begin
  inherited;

  // read flags
  FFlags := ReadSwappedWord(Stream);

{$IFDEF AmbigiousExceptions}
  // make sure the reserved flag is set to 0
  // if (FFlags and RESERVED <> 0) then
  //   raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
{$ENDIF}
  // read glyph index
  FGlyphIndex := ReadSwappedWord(Stream);

  // read argument 1
  if (FFlags and ARG_1_AND_2_ARE_WORDS <> 0) then
  begin
    Argument[0] := ReadSwappedSmallInt(Stream);
    Argument[1] := ReadSwappedSmallInt(Stream);
  end else
  begin
    Stream.Read(Bytes[0], 1);
    Stream.Read(Bytes[1], 1);
    Argument[0] := Bytes[0];
    Argument[1] := Bytes[1];
  end;

  if (FFlags and WE_HAVE_A_SCALE <> 0) then
  begin
    // read scale
{$IFDEF UseFloatingPoint}
    FScale[0, 0] := ReadSwappedSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FScale[0, 0] := ReadSwappedSmallInt(Stream);
{$ENDIF}
    // set other values implicitly
    FScale[0, 1] := 0;
    FScale[1, 0] := 0;
    FScale[1, 1] := FScale[0, 0];

{$IFDEF AmbigiousExceptions}
    // make sure the reserved flag is set to 0
    if (FFlags and WE_HAVE_AN_X_AND_Y_SCALE <> 0) then
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
    if (FFlags and WE_HAVE_A_TWO_BY_TWO <> 0) then
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
{$ENDIF}
  end else
  if (FFlags and WE_HAVE_AN_X_AND_Y_SCALE <> 0) then
  begin
    // read x-scale
{$IFDEF UseFloatingPoint}
    FScale[0, 0] := ReadSwappedSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FScale[0, 0] := ReadSwappedSmallInt(Stream);
{$ENDIF}

    // read y-scale
{$IFDEF UseFloatingPoint}
    FScale[1, 1] := ReadSwappedSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FScale[1, 1] := ReadSwappedSmallInt(Stream);
{$ENDIF}
    // set other values implicitly
    FScale[0, 1] := 0;
    FScale[1, 0] := 0;

{$IFDEF AmbigiousExceptions}
    // make sure the reserved flag is set to 0
    if (FFlags and WE_HAVE_A_SCALE <> 0) then // Unnecessary: We have already tested for this above...
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
    if (FFlags and WE_HAVE_A_TWO_BY_TWO <> 0) then
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
{$ENDIF}
  end else
  if (FFlags and WE_HAVE_A_TWO_BY_TWO <> 0) then
  begin
    // read x-scale
{$IFDEF UseFloatingPoint}
    FScale[0, 0] := ReadSwappedSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FScale[0, 0] := ReadSwappedSmallInt(Stream);
{$ENDIF}

    // read scale01
{$IFDEF UseFloatingPoint}
    FScale[0, 1] := ReadSwappedSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FScale[0, 1] := ReadSwappedSmallInt(Stream);
{$ENDIF}

    // read scale10
{$IFDEF UseFloatingPoint}
    FScale[1, 0] := ReadSwappedSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FScale[1, 0] := ReadSwappedSmallInt(Stream);
{$ENDIF}

    // read y-scale
{$IFDEF UseFloatingPoint}
    FScale[1, 1] := ReadSwappedSmallInt(Stream) * CFixedPoint2Dot14Scale;
{$ELSE}
    FScale[1, 1] := ReadSwappedSmallInt(Stream);
{$ENDIF}
{$IFDEF AmbigiousExceptions}
    // make sure the reserved flag is set to 0
    if (FFlags and WE_HAVE_A_SCALE <> 0) then // Unnecessary: We have already tested for this above...
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
    if (FFlags and WE_HAVE_AN_X_AND_Y_SCALE <> 0) then // Unnecessary: We have already tested for this above...
      raise EPascalTypeError.Create(RCStrCompositeGlyphFlagError);
{$ENDIF}
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

function TPascalTypeCompositeGlyph.FlagHasInstructions: boolean;
begin
  Result := (FFlags and WE_HAVE_INSTRUCTIONS <> 0);
end;

function TPascalTypeCompositeGlyph.FlagMoreComponents: boolean;
begin
  Result := (FFlags and MORE_COMPONENTS <> 0);
end;

procedure TPascalTypeCompositeGlyph.FlagsChanged;
begin
  Changed;
end;

procedure TPascalTypeCompositeGlyph.GlyphIndexChanged;
begin
  Changed;
end;


{ TTrueTypeFontCompositeGlyphData }

destructor TTrueTypeFontCompositeGlyphData.Destroy;
var
  ContourIndex: Integer;
begin
  for ContourIndex := 0 to High(FGlyphs) do
    FreeAndNil(FGlyphs[ContourIndex]);
  inherited;
end;

procedure TTrueTypeFontCompositeGlyphData.AssignTo(Dest: TPersistent);
var
  GlyphsIndex: Integer;
begin
  if Dest is Self.ClassType then
    with TTrueTypeFontCompositeGlyphData(Dest) do
    begin
      // eventually clear not used contours
      for GlyphsIndex := Length(Self.FGlyphs) to High(FGlyphs) do
        FreeAndNil(FGlyphs[GlyphsIndex]);

      // set length of countour array
      SetLength(FGlyphs, Length(Self.FGlyphs));

      // assign contours
      for GlyphsIndex := 0 to High(Self.FGlyphs) do
      begin
        // eventually create the contour
        if (FGlyphs[GlyphsIndex] = nil) then
          FGlyphs[GlyphsIndex] := TPascalTypeCompositeGlyph.Create;

        // assign contour
        FGlyphs[GlyphsIndex].Assign(Self.FGlyphs[GlyphsIndex]);
      end;
    end
  else
    inherited;
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
  SubGlyphIndex : Integer;
  GlyphScanIndex: Integer;
begin
  Result := 0;
  GlyphDataTable := TTrueTypeFontGlyphDataTable(Storage.GetTableByTableName('glyf'));
  if (GlyphDataTable <> nil) then
    for SubGlyphIndex := 0 to GetGlyphCount - 1 do
      for GlyphScanIndex := 0 to GlyphDataTable.GetGlyphDataCount - 1 do
        if GlyphScanIndex = Glyph[SubGlyphIndex].FGlyphIndex then
        begin
          Result := Result + GlyphDataTable.GlyphData[GlyphScanIndex].ContourCount;
          Break;
        end;
end;

function TTrueTypeFontCompositeGlyphData.GetGlyphCount: Integer;
begin
  Result := Length(FGlyphs);
end;

procedure TTrueTypeFontCompositeGlyphData.ResetToDefaults;
var
  SubGlyphIndex: Integer;
begin
  FInstructions.ResetToDefaults;

  // free Glyph list
  for SubGlyphIndex := 0 to High(FGlyphs) do
    FreeAndNil(FGlyphs[SubGlyphIndex]);
  SetLength(FGlyphs, 0);
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


{ TTrueTypeFontGlyphDataTable }

destructor TTrueTypeFontGlyphDataTable.Destroy;
begin
  FreeGlyphDataListItems;
  inherited;
end;

procedure TTrueTypeFontGlyphDataTable.AssignTo(Dest: TPersistent);
var
  GlyphsIndex: Integer;
  GlyphClass : TTrueTypeFontGlyphDataClass;
begin
  if Dest is Self.ClassType then
    with TTrueTypeFontGlyphDataTable(Dest) do
    begin
      // free all glyph data
      FreeGlyphDataListItems;

      // set length of countour array
      SetLength(FGlyphDataList, Length(Self.FGlyphDataList));

      // assign contours
      for GlyphsIndex := 0 to Length(Self.FGlyphDataList) - 1 do
      begin
        GlyphClass := TTrueTypeFontGlyphDataClass(Self.FGlyphDataList[GlyphsIndex].ClassType);

        // eventually create the contour
        FGlyphDataList[GlyphsIndex] := GlyphClass.Create(Storage);

        // assign contour
        FGlyphDataList[GlyphsIndex].Assign(Self.FGlyphDataList[GlyphsIndex]);
      end;
    end
  else
    inherited;
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

procedure TTrueTypeFontGlyphDataTable.ResetToDefaults;
begin
  // free glyph list items
  FreeGlyphDataListItems;

  // set glyph data list length to zero
  SetLength(FGlyphDataList, 0);
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
  Locations := TTrueTypeFontLocationTable(Storage.GetTableByTableName('loca'));
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
      FGlyphDataList[LocIndex] := TTrueTypeFontSimpleGlyphData.Create(Storage);
      continue;
    end;

    Stream.Position := StartPos + Locations[LocIndex];

    Value16 := ReadSwappedSmallInt(Stream);

    if (Value16 < -1) then
      raise EPascalTypeError.CreateFmt(RCStrUnknownGlyphDataType, [Value16]);

    // set position before number of contours
    Stream.Seek(-2, soFromCurrent);

    // read number of contours and create glyph data object
    if Value16 > 0 then
      FGlyphDataList[LocIndex] := TTrueTypeFontSimpleGlyphData.Create(Storage)
    else
      FGlyphDataList[LocIndex] := TTrueTypeFontCompositeGlyphData.Create(Storage);

    try
      FGlyphDataList[LocIndex].LoadFromStream(Stream);
    except
      on e: EPascalTypeError do
        raise EPascalTypeError.CreateFmt('Error loading glyph #%d'#10 + e.Message, [LocIndex]);
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


{ TTrueTypeFontLocationTable }

procedure TTrueTypeFontLocationTable.ResetToDefaults;
begin
  SetLength(FLocations, 0);
end;

procedure TTrueTypeFontLocationTable.AssignTo(Dest: TPersistent);
begin
  if Dest is Self.ClassType then
    with TTrueTypeFontLocationTable(Dest) do
    begin
      FLocations := Self.FLocations;
    end
  else
    inherited;
end;

function TTrueTypeFontLocationTable.GetLocation(Index: Integer): Cardinal;
begin
  if (Index < 0) or (Index > High(FLocations)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FLocations[Index];
end;

function TTrueTypeFontLocationTable.GetLocationCount: Cardinal;
begin
  Result := Length(FLocations);
end;

class function TTrueTypeFontLocationTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'loca';
end;

procedure TTrueTypeFontLocationTable.LoadFromStream(Stream: TStream);
var
  LocationIndex: Integer;
  HeaderTable  : TPascalTypeHeaderTable;
  MaxProfTable : TPascalTypeMaximumProfileTable;
begin
  // get header table
  HeaderTable := TPascalTypeHeaderTable(Storage.GetTableByTableName('head'));
  Assert(HeaderTable <> nil);

  // get maximum profile table
  MaxProfTable := TPascalTypeMaximumProfileTable(Storage.GetTableByTableName('maxp'));
  Assert(MaxProfTable <> nil);

  case HeaderTable.IndexToLocationFormat of
    ilShort:
      begin
        // check (minimum) table size
        if (MaxProfTable.NumGlyphs + 1) * SizeOf(Word) > Stream.Size then
          raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

        // set location array length
        SetLength(FLocations, MaxProfTable.NumGlyphs + 1);

        // read location array data
        for LocationIndex := 0 to High(FLocations) do
          FLocations[LocationIndex] := 2 * ReadSwappedWord(Stream);
      end;

    ilLong:
      begin
        // check (minimum) table size
        if (MaxProfTable.NumGlyphs + 1) * SizeOf(Cardinal) > Stream.Size then
          raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

        // set location array length
        SetLength(FLocations, MaxProfTable.NumGlyphs + 1);

        // read location array data
        for LocationIndex := 0 to High(FLocations) do
          FLocations[LocationIndex] := ReadSwappedCardinal(Stream);
      end;
  end;

{$IFDEF AmbigiousExceptions}
  // verify that the locations are stored in ascending order
  for LocationIndex := 1 to High(FLocations) do
    if FLocations[LocationIndex - 1] > FLocations[LocationIndex] then
      raise EPascalTypeError.Create(RCStrLocationOffsetError);
{$ENDIF}
end;

procedure TTrueTypeFontLocationTable.SaveToStream(Stream: TStream);
var
  LocationIndex: Integer;
  HeaderTable  : TPascalTypeHeaderTable;
  MaxProfTable : TPascalTypeMaximumProfileTable;
begin
  // get header table
  HeaderTable := TPascalTypeHeaderTable(Storage.GetTableByTableName('head'));
  Assert(HeaderTable <> nil);

  // get maximum profile table
  MaxProfTable := TPascalTypeMaximumProfileTable(Storage.GetTableByTableName('maxp'));
  Assert(MaxProfTable <> nil);

  // check whether the number of glyps matches the location array length
  if (MaxProfTable.NumGlyphs + 1) <> Length(FLocations) then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  case HeaderTable.IndexToLocationFormat of
    ilShort:
      begin
        // write location array data
        for LocationIndex := 0 to High(FLocations) do
          WriteSwappedWord(Stream, FLocations[LocationIndex] div 2);
      end;

    ilLong:
      begin
        // write location array data
        for LocationIndex := 0 to High(FLocations) do
          WriteSwappedCardinal(Stream, FLocations[LocationIndex]);
      end;
  end;
end;


{ TTrueTypeFontControlValueProgramTable }

class function TTrueTypeFontControlValueProgramTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'prep';
end;

initialization

  RegisterPascalTypeTables([TTrueTypeFontControlValueTable,
    TTrueTypeFontFontProgramTable, TTrueTypeFontGlyphDataTable,
    TTrueTypeFontLocationTable, TTrueTypeFontControlValueProgramTable]);

end.
