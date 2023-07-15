unit PascalType.Tables.OpenType.Positioning.MarkToLigature;

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
  System.Classes,
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
//              TOpenTypePositioningLookupTableMarkToLigatureAttachment
//
//------------------------------------------------------------------------------
// Lookup Type 5: Mark-to-Ligature Attachment Positioning Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-5-mark-to-ligature-attachment-positioning-subtable
//------------------------------------------------------------------------------
type
  TOpenTypePositioningLookupTableMarkToLigatureAttachment = class(TCustomOpenTypePositioningLookupTable)
  public type
    TGlyphPositioningFormat = (
      gpmlInvalid       = 0,
      gpmlAttachment    = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableMarkToLigatureAttachment
//
//------------------------------------------------------------------------------
// Mark-To-Ligature Attachment Positioning Format 1: Mark-to-Ligature Attachment
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#mark-to-ligature-attachment-positioning-format-1-mark-to-ligature-attachment
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableMarkToLigatureAttachment = class(TCustomOpenTypePositioningSubTableMarkAttachment)
  private type
    TComponentRecords = TArray<TAnchorList>;
    TLigatureAttachments = TArray<TComponentRecords>;
  private
    FLigatureAttachments: TLigatureAttachments;
  protected
    procedure ClearBaseRecords; override;
    procedure LoadBaseArrayFromStream(Stream: TStream); override;
    procedure SaveBaseArrayToStream(Stream: TStream); override;
    function GetMarkCoverage: TCustomOpenTypeCoverageTable;
    function GetLigatureCoverage: TCustomOpenTypeCoverageTable;
    property LigatureAttachments: TLigatureAttachments read FLigatureAttachments;
  public
    procedure Assign(Source: TPersistent); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property MarkCoverage: TCustomOpenTypeCoverageTable read GetMarkCoverage;
    property LigatureCoverage: TCustomOpenTypeCoverageTable read GetLigatureCoverage;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  System.Math,
  System.SysUtils,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableMarkToLigatureAttachment
//
//------------------------------------------------------------------------------
function TOpenTypePositioningLookupTableMarkToLigatureAttachment.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphPositioningFormat(ASubFormat) of

    gpmlAttachment :
      Result := TOpenTypePositioningSubTableMarkToLigatureAttachment;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableMarkToLigatureAttachment
//
//------------------------------------------------------------------------------
function TOpenTypePositioningSubTableMarkToLigatureAttachment.GetMarkCoverage: TCustomOpenTypeCoverageTable;
begin
  Result := inherited MarkCoverage;
end;

procedure TOpenTypePositioningSubTableMarkToLigatureAttachment.Assign(Source: TPersistent);
var
  Anchor: TOpenTypeAnchor;
  NewAnchor: TOpenTypeAnchor;
  i, j, k: integer;
begin
  inherited;
  if Source is TOpenTypePositioningSubTableMarkToLigatureAttachment then
  begin
    SetLength(FLigatureAttachments, Length(TOpenTypePositioningSubTableMarkToLigatureAttachment(Source).FLigatureAttachments));
    for i := 0 to High(FLigatureAttachments) do
    begin
      SetLength(FLigatureAttachments[i], Length(TOpenTypePositioningSubTableMarkToLigatureAttachment(Source).FLigatureAttachments[i]));
      for j := 0 to High(TOpenTypePositioningSubTableMarkToLigatureAttachment(Source).FLigatureAttachments[i]) do
      begin
        SetLength(FLigatureAttachments[i, j], Length(TOpenTypePositioningSubTableMarkToLigatureAttachment(Source).FLigatureAttachments[i, j]));
        for k := 0 to High(TOpenTypePositioningSubTableMarkToLigatureAttachment(Source).FLigatureAttachments[i, j]) do
        begin
          Anchor := TOpenTypePositioningSubTableMarkToLigatureAttachment(Source).FLigatureAttachments[i, j, k];
          if (Anchor <> nil) then
            NewAnchor := Anchor.Clone
          else
            NewAnchor := nil;
          FLigatureAttachments[i, j, k] := NewAnchor;
        end;
      end;
    end;
  end;
end;


procedure TOpenTypePositioningSubTableMarkToLigatureAttachment.ClearBaseRecords;
var
  Component: TComponentRecords;
  AnchorList: TAnchorList;
  Anchor: TOpenTypeAnchor;
begin
  for Component in FLigatureAttachments do
    for AnchorList in Component do
      for Anchor in AnchorList do
        Anchor.Free;
  SetLength(FLigatureAttachments, 0);
end;

procedure TOpenTypePositioningSubTableMarkToLigatureAttachment.LoadBaseArrayFromStream(Stream: TStream);
var
  StartPos: Int64;
  LigatureAttachOffsets: array of Word;
  LigatureAnchorOffsets: array of array of Word;
  i, j, k: integer;
  Anchor: TOpenTypeAnchor;
begin
  StartPos := Stream.Position;

  // LigatureArray table
  SetLength(LigatureAttachOffsets, BigEndianValue.ReadWord(Stream));
  for i := 0 to High(LigatureAttachOffsets) do
    LigatureAttachOffsets[i] := BigEndianValue.ReadWord(Stream);

  // LigatureArray table
  SetLength(FLigatureAttachments, Length(LigatureAttachOffsets));
  for i := 0 to High(LigatureAttachOffsets) do
  begin
    Stream.Position := StartPos + LigatureAttachOffsets[i];

    // LigatureAttach table
    SetLength(LigatureAnchorOffsets, BigEndianValue.ReadWord(Stream));
    SetLength(FLigatureAttachments[i], Length(LigatureAnchorOffsets));
    for j := 0 to High(LigatureAnchorOffsets) do
    begin
      // ComponentRecord
      SetLength(LigatureAnchorOffsets[j], MarkClassCount);
      for k := 0 to MarkClassCount-1 do
        LigatureAnchorOffsets[j, k] := BigEndianValue.ReadWord(Stream);

    end;

    for j := 0 to High(LigatureAnchorOffsets) do
    begin
      SetLength(FLigatureAttachments[i, j], Length(LigatureAnchorOffsets[j]));
      for k := 0 to High(LigatureAnchorOffsets[j]) do
      begin

        if (LigatureAnchorOffsets[j, k] <> 0) then
        begin
          Stream.Position := StartPos + LigatureAttachOffsets[i] + LigatureAnchorOffsets[j, k];
          Anchor := TOpenTypeAnchor.CreateFromStream(Stream);
        end else
          Anchor := nil;

        FLigatureAttachments[i, j, k] := Anchor;
      end;
    end;
  end;
end;

procedure TOpenTypePositioningSubTableMarkToLigatureAttachment.SaveBaseArrayToStream(Stream: TStream);
var
  StartPos: Int64;
  TableSize: Word;
  Offsets: array of array of array of Word;
  i, j, k: integer;
begin
  StartPos := Stream.Position;

  BigEndianValue.WriteWord(Stream, Length(FLigatureAttachments));

  TableSize := 0;
  for i := 0 to High(FLigatureAttachments) do
  begin
    Inc(TableSize, SizeOf(Word));
    for j := 0 to High(FLigatureAttachments[i]) do
      for k := 0 to High(FLigatureAttachments[i, j]) do
        Inc(TableSize, SizeOf(Word));
  end;

  Stream.Position := Stream.Position + TableSize;
  for i := 0 to High(FLigatureAttachments) do
  begin
    BigEndianValue.WriteWord(Stream, Length(FLigatureAttachments[i]));
    for j := 0 to High(FLigatureAttachments[i]) do
      for k := 0 to High(FLigatureAttachments[i, j]) do
      begin
        if (FLigatureAttachments[i, j, k] <> nil) then
        begin
          Offsets[i, j, k] := Stream.Position - StartPos;
          FLigatureAttachments[i, j, k].SaveToStream(Stream);
        end else
          Offsets[i, j, k] := 0;
      end;
  end;

  Stream.Position := StartPos + SizeOf(Word);
  for i := 0 to High(FLigatureAttachments) do
    for j := 0 to High(FLigatureAttachments[i]) do
      for k := 0 to High(FLigatureAttachments[i, j]) do
        BigEndianValue.WriteWord(Stream, Offsets[i, j, k]);
end;

function TOpenTypePositioningSubTableMarkToLigatureAttachment.GetLigatureCoverage: TCustomOpenTypeCoverageTable;
begin
  Result := inherited BaseCoverage;
end;

function TOpenTypePositioningSubTableMarkToLigatureAttachment.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  MarkGlyph: TPascalTypeGlyph;
  LigatureGlyph: TPascalTypeGlyph;
  MarkIndex: integer;
  LigatureIndex: integer;
  LigatureAttachment: TComponentRecords;
  LigatureGlyphIndex: integer;
  ComponentIndex: integer;
  Mark: TOpenTypeMark;
  LigatureAnchor: TOpenTypeAnchor;
begin
  if (AGlyphIterator.Index < 1) then
    Exit(False);

  MarkGlyph := AGlyphIterator.Glyph;
  MarkIndex := MarkCoverage.IndexOfGlyph(MarkGlyph.GlyphID);
  if (MarkIndex = -1) then
    Exit(False);

  // Scan backward for a ligature glyph
  LigatureGlyphIndex := AGlyphIterator.Index - 1;
  while (LigatureGlyphIndex >= 0) and (AGlyphIterator.GlyphString[LigatureGlyphIndex].IsMark) do
    Dec(LigatureGlyphIndex);
  if (LigatureGlyphIndex < 0) then
    Exit(False);

  LigatureGlyph := AGlyphIterator.GlyphString[LigatureGlyphIndex];
  LigatureIndex := BaseCoverage.IndexOfGlyph(LigatureGlyph.GlyphID);
  if (LigatureIndex = -1) then
    Exit(False);

  LigatureAttachment := FLigatureAttachments[LigatureIndex];

  // Find out which ligature component the mark should attach to.
  if (LigatureGlyph.LigatureID <> -1) and (LigatureGlyph.LigatureID = MarkGlyph.LigatureID) and (MarkGlyph.LigatureComponent <> -1) then
    ComponentIndex := Min(MarkGlyph.LigatureComponent, Length(LigatureGlyph.CodePoints)) - 1
  else
    ComponentIndex := Length(LigatureGlyph.CodePoints) - 1;

  if (ComponentIndex > High(LigatureAttachment)) then
    Exit(False); // This is a bug. Either in the font or in the code.

  Mark := Marks[MarkIndex];
  LigatureAnchor := LigatureAttachment[ComponentIndex][Mark.MarkClass];
  if (LigatureAnchor = nil) then
    Exit(False);

  MarkGlyph.ApplyAnchor(Mark.Anchor, LigatureAnchor, LigatureGlyphIndex);

{$ifdef ApplyIncrements}
  AGlyphIterator.Next;
{$endif ApplyIncrements}

  Result := True;
end;


//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpMarkToLigatureAttachment, TOpenTypePositioningLookupTableMarkToLigatureAttachment);
end.

