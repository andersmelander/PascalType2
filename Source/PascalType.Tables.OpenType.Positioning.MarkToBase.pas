unit PascalType.Tables.OpenType.Positioning.MarkToBase;

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
  PascalType.Tables.OpenType.Coverage,
  PascalType.Tables.OpenType.Common.Mark,
  PascalType.Tables.OpenType.Common.Anchor;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableMarkToBaseAttachment
//
//------------------------------------------------------------------------------
// Lookup Type 4: Mark-to-Base Attachment Positioning Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-4-mark-to-base-attachment-positioning-subtable
//------------------------------------------------------------------------------
type
  TOpenTypePositioningLookupTableMarkToBaseAttachment = class(TCustomOpenTypePositioningLookupTable)
  public type
    TGlyphPositioningFormat = (
      gpmbInvalid       = 0,
      gpmbAttachment    = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableMarkToBaseAttachment
//
//------------------------------------------------------------------------------
// Mark-to-Base Attachment Positioning Format 1: Mark-to-base Attachment Point
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#mark-to-base-attachment-positioning-format-1-mark-to-base-attachment-point
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableMarkToBaseAttachment = class(TCustomOpenTypePositioningSubTable)
  private type
    TAnchorList = TArray<TOpenTypeAnchor>;
  private
    FBaseCoverage: TCustomOpenTypeCoverageTable;
    FBaseRecords: TArray<TAnchorList>;
    FMarks: TOpenTypeMarkList;
  protected
    function GetMarkCoverage: TCustomOpenTypeCoverageTable;
    procedure ClearBaseRecords;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer; ADirection: TPascalTypeDirection): boolean; override;

    property MarkCoverage: TCustomOpenTypeCoverageTable read GetMarkCoverage; // Alias for CoverageTable property
    property BaseCoverage: TCustomOpenTypeCoverageTable read FBaseCoverage;
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
//              TOpenTypePositioningLookupTableMarkToBaseAttachment
//
//------------------------------------------------------------------------------
function TOpenTypePositioningLookupTableMarkToBaseAttachment.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphPositioningFormat(ASubFormat) of

    gpmbAttachment :
      Result := TOpenTypePositioningSubTableMarkToBaseAttachment;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableMarkToBaseAttachment
//
//------------------------------------------------------------------------------
procedure TOpenTypePositioningSubTableMarkToBaseAttachment.Assign(Source: TPersistent);
var
  Anchor: TOpenTypeAnchor;
  NewAnchor: TOpenTypeAnchor;
  i, j: integer;
begin
  inherited;
  if Source is TOpenTypePositioningSubTableMarkToBaseAttachment then
  begin
    ClearBaseRecords;
    FreeAndNil(FBaseCoverage);
    FBaseCoverage := TOpenTypePositioningSubTableMarkToBaseAttachment(Source).FBaseCoverage.Clone(Self);

    FMarks.Assign(TOpenTypePositioningSubTableMarkToBaseAttachment(Source).FMarks);

    SetLength(FBaseRecords, Length(TOpenTypePositioningSubTableMarkToBaseAttachment(Source).FBaseRecords));
    for i := 0 to High(FBaseRecords) do
    begin
      SetLength(FBaseRecords[i], Length(TOpenTypePositioningSubTableMarkToBaseAttachment(Source).FBaseRecords[i]));
      for j := 0 to High(TOpenTypePositioningSubTableMarkToBaseAttachment(Source).FBaseRecords[i]) do
      begin
        Anchor := TOpenTypePositioningSubTableMarkToBaseAttachment(Source).FBaseRecords[i, j];
        if (Anchor <> nil) then
          NewAnchor := Anchor.Clone
        else
          NewAnchor := nil;
        FBaseRecords[i, j] := NewAnchor;
      end;
    end;
  end;
end;

procedure TOpenTypePositioningSubTableMarkToBaseAttachment.ClearBaseRecords;
var
  AnchorList: TAnchorList;
  Anchor: TOpenTypeAnchor;
begin
  for AnchorList in FBaseRecords do
    for Anchor in AnchorList do
      Anchor.Free;
  SetLength(FBaseRecords, 0);
end;

constructor TOpenTypePositioningSubTableMarkToBaseAttachment.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FMarks := TOpenTypeMarkList.Create;
end;

destructor TOpenTypePositioningSubTableMarkToBaseAttachment.Destroy;
begin
  FBaseCoverage.Free;
  FMarks.Free;
  ClearBaseRecords;
  inherited;
end;

function TOpenTypePositioningSubTableMarkToBaseAttachment.GetMarkCoverage: TCustomOpenTypeCoverageTable;
begin
  Result := CoverageTable;
end;

function TOpenTypePositioningSubTableMarkToBaseAttachment.Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer; ADirection: TPascalTypeDirection): boolean;

  procedure ApplyAnchor(MarkAnchor, BaseAnchor: TOpenTypeAnchor; MarkIndex, BaseIndex: integer);
  var
    MarkPos, BasePos: TAnchorPoint;
    Glyph: TPascalTypeGlyph;
  begin
    MarkPos := MarkAnchor.Position;
    BasePos := BaseAnchor.Position;

    Glyph := AGlyphString[MarkIndex];
    Glyph.XOffset := BasePos.X - MarkPos.X;
    Glyph.YOffset := BasePos.Y - MarkPos.Y;

    Glyph.MarkAttachment := BaseIndex;
  end;

var
  MarkGlyph: TPascalTypeGlyph;
  BaseGlyph: TPascalTypeGlyph;
  MarkIndex: integer;
  BaseIndex: integer;
  BaseGlyphIndex: integer;
  Mark: TOpenTypeMark;
  BaseAnchor: TOpenTypeAnchor;
begin
  if (AIndex < 1) then
    Exit(False);

  MarkGlyph := AGlyphString[AIndex];
  MarkIndex := MarkCoverage.IndexOfGlyph(MarkGlyph.GlyphID);
  if (MarkIndex = -1) then
    Exit(False);

  // Scan backward for a base glyph
  BaseGlyphIndex := AIndex-1;
  while (BaseGlyphIndex >= 0) and ((AGlyphString[BaseGlyphIndex].IsMark) or (AGlyphString[BaseGlyphIndex].LigatureComponent > 0)) do
    Dec(BaseGlyphIndex);
  if (BaseGlyphIndex < 0) then
    Exit(False);

  BaseGlyph := AGlyphString[BaseGlyphIndex];
  BaseIndex := BaseCoverage.IndexOfGlyph(BaseGlyph.GlyphID);
  if (BaseIndex = -1) then
    Exit(False);

  Mark := FMarks[MarkIndex];
  BaseAnchor := FBaseRecords[BaseIndex][Mark.MarkClass];
  if (BaseAnchor = nil) then
    Exit(False);

  ApplyAnchor(Mark.Anchor, BaseAnchor, AIndex, BaseGlyphIndex);

  Result := True;
  Inc(AIndex);
end;

procedure TOpenTypePositioningSubTableMarkToBaseAttachment.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  CoverageOffset: Word;
  MarkClassCount: Word;
  MarkArrayOffset: Word;
  BaseArrayOffset: Word;
  BaseRecordOffsets: array of array of Word;
  i, j: integer;
  Anchor: TOpenTypeAnchor;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 4 * SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Offsets and count
  CoverageOffset := BigEndianValueReader.ReadWord(Stream);
  MarkClassCount := BigEndianValueReader.ReadWord(Stream);
  MarkArrayOffset := BigEndianValueReader.ReadWord(Stream);
  BaseArrayOffset := BigEndianValueReader.ReadWord(Stream);

  // Coverage table
  Stream.Position := StartPos + CoverageOffset;
  FBaseCoverage := TCustomOpenTypeCoverageTable.CreateFromStream(Stream, Self);

  // Mark array
  Stream.Position := StartPos + MarkArrayOffset;
  FMarks.LoadFromStream(Stream);

  // Base offset array
  Stream.Position := StartPos + BaseArrayOffset;
  SetLength(BaseRecordOffsets, BigEndianValueReader.ReadWord(Stream));
  for i := 0 to High(BaseRecordOffsets) do
  begin
    SetLength(BaseRecordOffsets[i], MarkClassCount);
    for j := 0 to MarkClassCount-1 do
      BaseRecordOffsets[i, j] := BigEndianValueReader.ReadWord(Stream);
  end;

  // Base records
  SetLength(FBaseRecords, Length(BaseRecordOffsets));
  for i := 0 to High(BaseRecordOffsets) do
  begin
    SetLength(FBaseRecords[i], MarkClassCount);
    for j := 0 to MarkClassCount-1 do
    begin
      if (BaseRecordOffsets[i, j] <> 0) then
      begin
        Stream.Position := StartPos + BaseArrayOffset + BaseRecordOffsets[i, j];
        Anchor := TOpenTypeAnchor.CreateFromStream(Stream);
      end else
        Anchor := nil;

      FBaseRecords[i, j] := Anchor;
    end;
  end;
end;

procedure TOpenTypePositioningSubTableMarkToBaseAttachment.SaveToStream(Stream: TStream);
var
  StartPos, SavePos: Int64;
  CoverageOffsetOffset: Int64;
  MarkArrayOffsetOffset: Int64;
  BaseArrayOffsetOffset: Int64;
  CoverageOffset: Word;
  MarkArrayOffset: Word;
  BaseArrayOffset: Word;
  BaseRecordOffsets: array of array of Word;
  i, j: integer;
begin
  StartPos := Stream.Position;

  inherited;

  CoverageOffsetOffset := Stream.Position;
  Stream.Position := Stream.Position + SizeOf(Word);

  WriteSwappedWord(Stream, FMarks.Count);

  MarkArrayOffsetOffset := Stream.Position;
  Stream.Position := Stream.Position + SizeOf(Word);

  BaseArrayOffsetOffset := Stream.Position;
  Stream.Position := Stream.Position + SizeOf(Word);

  CoverageOffset := Stream.Position - StartPos;
  FBaseCoverage.SaveToStream(Stream);

  MarkArrayOffset := Stream.Position - StartPos;
  FMarks.SaveToStream(Stream);

  BaseArrayOffset := Stream.Position - StartPos;
  WriteSwappedWord(Stream, Length(FBaseRecords));
  Stream.Position := Stream.Position + SizeOf(Word) * Length(FBaseRecords) * FMarks.Count;
  for i := 0 to High(FBaseRecords) do
    for j := 0 to FMarks.Count-1 do
    begin
      if (FBaseRecords[i][j] <> nil) then
      begin
        BaseRecordOffsets[i, j] := Stream.Position - StartPos - BaseArrayOffset;
        FBaseRecords[i][j].SaveToStream(Stream);
      end else
        BaseRecordOffsets[i, j] := 0;
    end;

  SavePos := Stream.Position;

  Stream.Position := CoverageOffsetOffset;
  WriteSwappedWord(Stream, CoverageOffset);

  Stream.Position := MarkArrayOffsetOffset;
  WriteSwappedWord(Stream, MarkArrayOffset);

  Stream.Position := BaseArrayOffsetOffset;
  WriteSwappedWord(Stream, BaseArrayOffset);

  Stream.Position := BaseArrayOffset + SizeOf(Word);
  for i := 0 to High(FBaseRecords) do
    for j := 0 to FMarks.Count-1 do
      WriteSwappedWord(Stream, BaseRecordOffsets[i, j]);

  Stream.Position := SavePos;
end;


//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpMarkToBaseAttachment, TOpenTypePositioningLookupTableMarkToBaseAttachment);
end.

