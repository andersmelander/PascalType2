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
  PascalType.Tables.OpenType.Coverage,
  PascalType.Tables.OpenType.Common.Mark,
  PascalType.Tables.OpenType.Common.Anchor,
  PascalType.Tables.OpenType.Positioning,
  PascalType.Tables.OpenType.Positioning.Mark;


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
  TOpenTypePositioningSubTableMarkToBaseAttachment = class(TCustomOpenTypePositioningSubTableMarkAttachment)
  private type
    TBaseRecords = TArray<TAnchorList>;
  private
    FBaseRecords: TBaseRecords;
  protected
    procedure ClearBaseRecords; override;
    procedure LoadBaseArrayFromStream(Stream: TStream); override;
    procedure SaveBaseArrayToStream(Stream: TStream); override;
    property BaseRecords: TBaseRecords read FBaseRecords;
  public
    procedure Assign(Source: TPersistent); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;
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

function TOpenTypePositioningSubTableMarkToBaseAttachment.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  MarkGlyph: TPascalTypeGlyph;
  BaseGlyph: TPascalTypeGlyph;
  MarkIndex: integer;
  BaseIndex: integer;
  BaseGlyphIndex: integer;
  Mark: TOpenTypeMark;
  BaseAnchor: TOpenTypeAnchor;
begin
  if (AGlyphIterator.Index < 1) then
    Exit(False);

  MarkGlyph := AGlyphIterator.Glyph;
  MarkIndex := MarkCoverage.IndexOfGlyph(MarkGlyph.GlyphID);
  if (MarkIndex = -1) then
    Exit(False);

  // Scan backward for a base glyph
  BaseGlyphIndex := AGlyphIterator.Index - 1;
  while (BaseGlyphIndex >= 0) and ((AGlyphIterator.GlyphString[BaseGlyphIndex].IsMark) or (AGlyphIterator.GlyphString[BaseGlyphIndex].LigatureComponent > 0)) do
    Dec(BaseGlyphIndex);
  if (BaseGlyphIndex < 0) then
    Exit(False);

  BaseGlyph := AGlyphIterator.GlyphString[BaseGlyphIndex];
  BaseIndex := BaseCoverage.IndexOfGlyph(BaseGlyph.GlyphID);
  if (BaseIndex = -1) then
    Exit(False);

  Mark := Marks[MarkIndex];
  BaseAnchor := FBaseRecords[BaseIndex][Mark.MarkClass];
  if (BaseAnchor = nil) then
    Exit(False);

  MarkGlyph.ApplyAnchor(Mark.Anchor, BaseAnchor, BaseGlyphIndex);

{$ifdef ApplyIncrements}
  AGlyphIterator.Next;
{$endif ApplyIncrements}

  Result := True;
end;

procedure TOpenTypePositioningSubTableMarkToBaseAttachment.LoadBaseArrayFromStream(Stream: TStream);
var
  StartPos: Int64;
  BaseRecordOffsets: array of array of Word;
  i, j: integer;
  Anchor: TOpenTypeAnchor;
begin
  StartPos := Stream.Position;

  // BaseArray Table
  SetLength(BaseRecordOffsets, BigEndianValueReader.ReadWord(Stream));
  for i := 0 to High(BaseRecordOffsets) do
  begin
    // BaseRecord
    SetLength(BaseRecordOffsets[i], MarkClassCount);
    for j := 0 to High(BaseRecordOffsets[i]) do
      BaseRecordOffsets[i, j] := BigEndianValueReader.ReadWord(Stream);
  end;

  // Base records
  SetLength(FBaseRecords, Length(BaseRecordOffsets));
  for i := 0 to High(BaseRecordOffsets) do
  begin
    SetLength(FBaseRecords[i], Length(BaseRecordOffsets[i]));
    for j := 0 to High(BaseRecordOffsets[i]) do
    begin
      if (BaseRecordOffsets[i, j] <> 0) then
      begin
        Stream.Position := StartPos + BaseRecordOffsets[i, j];
        Anchor := TOpenTypeAnchor.CreateFromStream(Stream);
      end else
        Anchor := nil;

      FBaseRecords[i, j] := Anchor;
    end;
  end;
end;

procedure TOpenTypePositioningSubTableMarkToBaseAttachment.SaveBaseArrayToStream(Stream: TStream);
var
  StartPos: Int64;
  BaseRecordOffsets: array of array of Word;
  i, j: integer;
begin
  StartPos := Stream.Position;

  WriteSwappedWord(Stream, Length(FBaseRecords));

  Stream.Position := Stream.Position + SizeOf(Word) * Length(FBaseRecords) * MarkClassCount;
  for i := 0 to High(FBaseRecords) do
    for j := 0 to High(FBaseRecords[i]) do
    begin
      if (FBaseRecords[i, j] <> nil) then
      begin
        BaseRecordOffsets[i, j] := Stream.Position - StartPos;
        FBaseRecords[i, j].SaveToStream(Stream);
      end else
        BaseRecordOffsets[i, j] := 0;
    end;

  Stream.Position := StartPos + SizeOf(Word);
  for i := 0 to High(BaseRecordOffsets) do
    for j := 0 to High(BaseRecordOffsets[i]) do
      WriteSwappedWord(Stream, BaseRecordOffsets[i, j]);
end;


//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpMarkToBaseAttachment, TOpenTypePositioningLookupTableMarkToBaseAttachment);
end.

