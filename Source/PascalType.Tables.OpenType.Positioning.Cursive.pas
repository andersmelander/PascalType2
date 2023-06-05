unit PascalType.Tables.OpenType.Positioning.Cursive;

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
//              TOpenTypePositioningLookupTableCursiveAttachment
//
//------------------------------------------------------------------------------
// Lookup Type 3: Cursive Attachment Positioning Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-3-cursive-attachment-positioning-subtable
//------------------------------------------------------------------------------
type
  TOpenTypePositioningLookupTableCursiveAttachment = class(TCustomOpenTypePositioningLookupTable)
  public type
    TGlyphPairPositioning = (
      gcapInvalid        = 0,
      gcapCursiveAttachment = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableCursiveAttachment
//
//------------------------------------------------------------------------------
// Cursive Attachment Positioning Format1: Cursive attachment
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#cursive-attachment-positioning-format1-cursive-attachment
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableCursiveAttachment = class(TCustomOpenTypePositioningSubTable)
  public type
    TCursiveAttachmentAnchorFormat = (caaDesignUnits, caaDUContourPoints, caaDUDeviceVariantion);

    TAnchorPoint = record
      X: SmallInt;
      Y: SmallInt;
    end;

    TCursiveAttachmentAnchor = class abstract
    private
      FCursiveAttachment: TOpenTypePositioningSubTableCursiveAttachment;
      FAnchorFormat: TCursiveAttachmentAnchorFormat;
    public
      constructor Create(ACursiveAttachment: TOpenTypePositioningSubTableCursiveAttachment; AAnchorFormat: TCursiveAttachmentAnchorFormat); virtual;

      procedure LoadFromStream(Stream: TStream); virtual;
      procedure SaveToStream(Stream: TStream); virtual;

      procedure Assign(Source: TCursiveAttachmentAnchor); virtual;

      function Position: TAnchorPoint; virtual; abstract;

      property CursiveAttachment: TOpenTypePositioningSubTableCursiveAttachment read FCursiveAttachment;
      property AnchorFormat: TCursiveAttachmentAnchorFormat read FAnchorFormat;
    end;
    TCursiveAttachmentAnchorClass = class of TCursiveAttachmentAnchor;

    TCursiveAttachmentAnchorItem = record
      EntryAnchor: TCursiveAttachmentAnchor;
      ExitAnchor: TCursiveAttachmentAnchor;
    end;

  private
    FAnchors: TList<TCursiveAttachmentAnchorItem>;
    function GetAnchor(Index: integer): TCursiveAttachmentAnchorItem;
    function GetCount: integer;
  protected
    procedure ClearAnchors;
    class function AnchorClassByAnchorFormat(AnchorFormat: TCursiveAttachmentAnchorFormat): TCursiveAttachmentAnchorClass;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer; ADirection: TPascalTypeDirection): boolean; override;

    property Count: integer read GetCount;
    property Anchors[Index: integer]: TCursiveAttachmentAnchorItem read GetAnchor;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableCursiveAttachment
//
//------------------------------------------------------------------------------
function TOpenTypePositioningLookupTableCursiveAttachment.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphPairPositioning(ASubFormat) of

    gcapCursiveAttachment :
      Result := TOpenTypePositioningSubTableCursiveAttachment;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//      TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor
//------------------------------------------------------------------------------
procedure TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor.Assign(Source: TCursiveAttachmentAnchor);
begin
  Assert(AnchorFormat = Source.AnchorFormat);
end;

constructor TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor.Create(
  ACursiveAttachment: TOpenTypePositioningSubTableCursiveAttachment; AAnchorFormat: TCursiveAttachmentAnchorFormat);
begin
  inherited Create;
  FCursiveAttachment := ACursiveAttachment;
  FAnchorFormat := AAnchorFormat;
end;

procedure TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor.LoadFromStream(Stream: TStream);
var
  AnchorFormat: TCursiveAttachmentAnchorFormat;
begin
  AnchorFormat := TCursiveAttachmentAnchorFormat(BigEndianValueReader.ReadWord(Stream));
  Assert(AnchorFormat = FAnchorFormat);
end;

procedure TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor.SaveToStream(Stream: TStream);
begin
  WriteSwappedWord(Stream, Ord(AnchorFormat));
end;


//------------------------------------------------------------------------------
//      TCursiveAttachmentAnchorDesignUnits
//------------------------------------------------------------------------------
type
  TCursiveAttachmentAnchorDesignUnits = class(TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor)
  private
    FX: SmallInt;
    FY: SmallInt;
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    procedure Assign(Source: TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor); override;

    function Position: TOpenTypePositioningSubTableCursiveAttachment.TAnchorPoint; override;

    property X: SmallInt read FX write FX;
    property Y: SmallInt read FY write FY;
  end;

function TCursiveAttachmentAnchorDesignUnits.Position: TOpenTypePositioningSubTableCursiveAttachment.TAnchorPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

procedure TCursiveAttachmentAnchorDesignUnits.Assign(Source: TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor);
begin
  inherited;
  if (Source is TCursiveAttachmentAnchorDesignUnits) then
  begin
    FX := TCursiveAttachmentAnchorDesignUnits(Source).X;
    FY := TCursiveAttachmentAnchorDesignUnits(Source).Y;
  end;
end;

procedure TCursiveAttachmentAnchorDesignUnits.LoadFromStream(Stream: TStream);
begin
  inherited;

  FX := BigEndianValueReader.ReadSmallInt(Stream);
  FY := BigEndianValueReader.ReadSmallInt(Stream);
end;

procedure TCursiveAttachmentAnchorDesignUnits.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedSmallInt(Stream, FX);
  WriteSwappedSmallInt(Stream, FY);
end;

//------------------------------------------------------------------------------
//      TCursiveAttachmentAnchorDUContourPoints
//------------------------------------------------------------------------------
type
  TCursiveAttachmentAnchorDUContourPoints = class(TCursiveAttachmentAnchorDesignUnits)
  private
    FContourPointIndex: Word;
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    procedure Assign(Source: TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor); override;

    function Position: TOpenTypePositioningSubTableCursiveAttachment.TAnchorPoint; override;

    property ContourPointIndex: Word read FContourPointIndex write FContourPointIndex;
  end;

function TCursiveAttachmentAnchorDUContourPoints.Position: TOpenTypePositioningSubTableCursiveAttachment.TAnchorPoint;
begin
  Result := inherited Position;
  // TODO
end;

procedure TCursiveAttachmentAnchorDUContourPoints.Assign(Source: TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor);
begin
  inherited;
  if (Source is TCursiveAttachmentAnchorDUContourPoints) then
  begin
    FContourPointIndex := TCursiveAttachmentAnchorDUContourPoints(Source).ContourPointIndex;
  end;
end;

procedure TCursiveAttachmentAnchorDUContourPoints.LoadFromStream(Stream: TStream);
begin
  inherited;

  FContourPointIndex := BigEndianValueReader.ReadWord(Stream);
end;

procedure TCursiveAttachmentAnchorDUContourPoints.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedWord(Stream, FContourPointIndex);
end;

//------------------------------------------------------------------------------
//      TCursiveAttachmentAnchorDUDeviceVariantion
//------------------------------------------------------------------------------
type
  TCursiveAttachmentAnchorDUDeviceVariantion = class(TCursiveAttachmentAnchorDesignUnits)
  private
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    procedure Assign(Source: TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor); override;

    function Position: TOpenTypePositioningSubTableCursiveAttachment.TAnchorPoint; override;
  end;

function TCursiveAttachmentAnchorDUDeviceVariantion.Position: TOpenTypePositioningSubTableCursiveAttachment.TAnchorPoint;
begin
  Result := inherited Position;
  // TODO
end;

procedure TCursiveAttachmentAnchorDUDeviceVariantion.Assign(Source: TOpenTypePositioningSubTableCursiveAttachment.TCursiveAttachmentAnchor);
begin
  inherited;
  if (Source is TCursiveAttachmentAnchorDUDeviceVariantion) then
  begin
    // TODO
  end;
end;

procedure TCursiveAttachmentAnchorDUDeviceVariantion.LoadFromStream(Stream: TStream);
var
  XDeviceOffset: Word;
  YDeviceOffset: Word;
begin
  inherited;

  XDeviceOffset := BigEndianValueReader.ReadWord(Stream);
  YDeviceOffset := BigEndianValueReader.ReadWord(Stream);
end;

procedure TCursiveAttachmentAnchorDUDeviceVariantion.SaveToStream(Stream: TStream);
begin
  inherited;

  // TODO
end;

//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableCursiveAttachment
//
//------------------------------------------------------------------------------
procedure TOpenTypePositioningSubTableCursiveAttachment.Assign(Source: TPersistent);
var
  SourceAnchorItem: TCursiveAttachmentAnchorItem;
  NewAnchorItem: TCursiveAttachmentAnchorItem;
begin
  inherited;
  if Source is TOpenTypePositioningSubTableCursiveAttachment then
  begin
    ClearAnchors;
    for SourceAnchorItem in TOpenTypePositioningSubTableCursiveAttachment(Source).FAnchors do
    begin
      NewAnchorItem.EntryAnchor := AnchorClassByAnchorFormat(SourceAnchorItem.EntryAnchor.AnchorFormat).Create(Self, SourceAnchorItem.EntryAnchor.AnchorFormat);
      NewAnchorItem.ExitAnchor := AnchorClassByAnchorFormat(SourceAnchorItem.ExitAnchor.AnchorFormat).Create(Self, SourceAnchorItem.ExitAnchor.AnchorFormat);
      FAnchors.Add(NewAnchorItem);
      NewAnchorItem.EntryAnchor.Assign(SourceAnchorItem.EntryAnchor);
      NewAnchorItem.ExitAnchor.Assign(SourceAnchorItem.ExitAnchor);
    end;
  end;
end;

class function TOpenTypePositioningSubTableCursiveAttachment.AnchorClassByAnchorFormat(AnchorFormat: TCursiveAttachmentAnchorFormat): TCursiveAttachmentAnchorClass;
begin
  case AnchorFormat of
    caaDesignUnits:
      Result := TCursiveAttachmentAnchorDesignUnits;

    caaDUContourPoints:
      Result := TCursiveAttachmentAnchorDUContourPoints;

    caaDUDeviceVariantion:
      Result := TCursiveAttachmentAnchorDUDeviceVariantion;

  else
    Result := nil;
  end;
end;

procedure TOpenTypePositioningSubTableCursiveAttachment.ClearAnchors;
var
  AnchorItem: TCursiveAttachmentAnchorItem;
begin
  for AnchorItem in FAnchors do
  begin
    AnchorItem.EntryAnchor.Free;
    AnchorItem.ExitAnchor.Free;
  end;
  FAnchors.Clear;
end;

constructor TOpenTypePositioningSubTableCursiveAttachment.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FAnchors := TList<TCursiveAttachmentAnchorItem>.Create;
end;

destructor TOpenTypePositioningSubTableCursiveAttachment.Destroy;
begin
  ClearAnchors;
  FAnchors.Free;
  inherited;
end;

function TOpenTypePositioningSubTableCursiveAttachment.GetAnchor(Index: integer): TCursiveAttachmentAnchorItem;
begin
  Result := FAnchors[Index];
end;

function TOpenTypePositioningSubTableCursiveAttachment.GetCount: integer;
begin
  Result := FAnchors.Count;
end;

function TOpenTypePositioningSubTableCursiveAttachment.Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer; ADirection: TPascalTypeDirection): boolean;
var
  CurrentGlyph: TPascalTypeGlyph;
  NextGlyph: TPascalTypeGlyph;
  CoverageIndex: integer;
  AnchorItem: TCursiveAttachmentAnchorItem;
  EntryAnchor: TCursiveAttachmentAnchor;
  ExitAnchor: TCursiveAttachmentAnchor;
  EntryAnchorPoint: TAnchorPoint;
  ExitAnchorPoint: TAnchorPoint;
  Delta: integer;
begin
  if (AIndex >= AGlyphString.Count-1) then
    Exit(False);

  CurrentGlyph := AGlyphString[AIndex];
  CoverageIndex := CoverageTable.IndexOfGlyph(CurrentGlyph.GlyphID);
  if (CoverageIndex = -1) then
    Exit(False);

  AnchorItem := FAnchors[CoverageIndex];
  ExitAnchor := AnchorItem.ExitAnchor;
  if (ExitAnchor = nil) then
    Exit(False);

  NextGlyph := AGlyphString[AIndex+1];
  CoverageIndex := CoverageTable.IndexOfGlyph(NextGlyph.GlyphID);
  if (CoverageIndex = -1) then
    Exit(False);

  AnchorItem := FAnchors[CoverageIndex];
  EntryAnchor := AnchorItem.EntryAnchor;
  if (EntryAnchor = nil) then
    Exit(False);

  // Align entry anchor-point with exit anchor-point
  EntryAnchorPoint := EntryAnchor.Position;
  ExitAnchorPoint := ExitAnchor.Position;

  case ADirection of
    dirLeftToRight:
      begin
        CurrentGlyph.XAdvance := ExitAnchorPoint.X + CurrentGlyph.XOffset;
        Delta := EntryAnchorPoint.X + NextGlyph.XOffset;
        NextGlyph.XAdvance := NextGlyph.XAdvance - Delta;
        NextGlyph.XOffset := NextGlyph.XOffset - Delta;
      end;

    dirRightToLeft:
      begin
        Delta := ExitAnchorPoint.X + CurrentGlyph.XOffset;
        CurrentGlyph.XAdvance := CurrentGlyph.XAdvance - Delta;
        CurrentGlyph.XOffset := CurrentGlyph.XOffset - Delta;
        NextGlyph.XAdvance := EntryAnchorPoint.X + NextGlyph.XOffset;
      end;
  end;

  if (LookupTable.LookupFlag and TCustomOpenTypeLookupTable.RIGHT_TO_LEFT <> 0) then
  begin
    // TODO
//    CurrentGlyph.CursiveAttachment := AIndex + 1;
    CurrentGlyph.YOffset := EntryAnchorPoint.Y - ExitAnchorPoint.Y;
  end else
  begin
//    NextGlyph.CursiveAttachment := AIndex;
    CurrentGlyph.YOffset := ExitAnchorPoint.Y - EntryAnchorPoint.Y;
  end;

  Result := True;
  Inc(AIndex);
end;

procedure TOpenTypePositioningSubTableCursiveAttachment.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  EntryExitRecordOffsets: array of record
    EntryAnchorOffset: Word;
    ExitAnchorOffset: Word;
  end;
  i: integer;
  AnchorFormat: TCursiveAttachmentAnchorFormat;
  Anchor: TCursiveAttachmentAnchorItem;
begin
  // Test font: "Arabic Typesetting"
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  SetLength(EntryExitRecordOffsets, BigEndianValueReader.ReadWord(Stream));
  for i := 0 to High(EntryExitRecordOffsets) do
  begin
    EntryExitRecordOffsets[i].EntryAnchorOffset := BigEndianValueReader.ReadWord(Stream);
    EntryExitRecordOffsets[i].ExitAnchorOffset := BigEndianValueReader.ReadWord(Stream);
  end;

  for i := 0 to High(EntryExitRecordOffsets) do
  begin
    Anchor := Default(TCursiveAttachmentAnchorItem);
    try
      // Read entry anchor
      if (EntryExitRecordOffsets[i].EntryAnchorOffset <> 0) then
      begin
        Stream.Position := StartPos + EntryExitRecordOffsets[i].EntryAnchorOffset;

        AnchorFormat := TCursiveAttachmentAnchorFormat(BigEndianValueReader.ReadWord(Stream));
        Anchor.EntryAnchor := AnchorClassByAnchorFormat(AnchorFormat).Create(Self, AnchorFormat);

        Stream.Position := StartPos + EntryExitRecordOffsets[i].EntryAnchorOffset;
        Anchor.EntryAnchor.LoadFromStream(Stream);
      end;

      // Read exit anchor
      if (EntryExitRecordOffsets[i].ExitAnchorOffset <> 0) then
      begin
        Stream.Position := StartPos + EntryExitRecordOffsets[i].ExitAnchorOffset;

        AnchorFormat := TCursiveAttachmentAnchorFormat(BigEndianValueReader.ReadWord(Stream));
        Anchor.ExitAnchor := AnchorClassByAnchorFormat(AnchorFormat).Create(Self, AnchorFormat);

        Stream.Position := StartPos + EntryExitRecordOffsets[i].ExitAnchorOffset;
        Anchor.ExitAnchor.LoadFromStream(Stream);
      end;

      FAnchors.Add(Anchor);
    except
      Anchor.EntryAnchor.Free;
      Anchor.ExitAnchor.Free;
      raise;
    end;
  end;
end;

procedure TOpenTypePositioningSubTableCursiveAttachment.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
begin
  StartPos := Stream.Position;

  inherited;

  // TODO
end;


//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpCursiveAttachment, TOpenTypePositioningLookupTableCursiveAttachment);
end.

