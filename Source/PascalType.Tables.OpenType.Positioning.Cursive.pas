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
  PascalType.Tables.OpenType.ClassDefinition,
  PascalType.Tables.OpenType.Common.Anchor;


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
    TCursiveAttachmentAnchorItem = record
      EntryAnchor: TOpenTypeAnchor;
      ExitAnchor: TOpenTypeAnchor;
    end;

  private
    FAnchors: TList<TCursiveAttachmentAnchorItem>;
    function GetAnchor(Index: integer): TCursiveAttachmentAnchorItem;
    function GetCount: integer;
  protected
    procedure ClearAnchors;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

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
      NewAnchorItem := Default(TCursiveAttachmentAnchorItem);
      try
        NewAnchorItem.EntryAnchor := SourceAnchorItem.EntryAnchor.Clone;
        NewAnchorItem.ExitAnchor := SourceAnchorItem.ExitAnchor.Clone;
      except
        NewAnchorItem.EntryAnchor.Free;
        NewAnchorItem.ExitAnchor.Free;
        raise;
      end;
      FAnchors.Add(NewAnchorItem);
    end;
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

function TOpenTypePositioningSubTableCursiveAttachment.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  CurrentGlyph: TPascalTypeGlyph;
  NextIndex: integer;
  NextGlyph: TPascalTypeGlyph;
  CoverageIndex: integer;
  AnchorItem: TCursiveAttachmentAnchorItem;
  EntryAnchor: TOpenTypeAnchor;
  ExitAnchor: TOpenTypeAnchor;
  EntryAnchorPoint: TAnchorPoint;
  ExitAnchorPoint: TAnchorPoint;
  Delta: integer;
begin
  if (AGlyphIterator.Index >= AGlyphIterator.GlyphString.Count-1) then
    Exit(False);

  CurrentGlyph := AGlyphIterator.Glyph;
  CoverageIndex := CoverageTable.IndexOfGlyph(CurrentGlyph.GlyphID);
  if (CoverageIndex = -1) then
    Exit(False);

  AnchorItem := FAnchors[CoverageIndex];
  ExitAnchor := AnchorItem.ExitAnchor;
  if (ExitAnchor = nil) then
    Exit(False);

  NextIndex := AGlyphIterator.Peek;
  if (NextIndex = -1) then
    Exit(False);
  NextGlyph := AGlyphIterator.GlyphString[NextIndex];
  CoverageIndex := CoverageTable.IndexOfGlyph(NextGlyph.GlyphID);
  if (CoverageIndex = -1) then
    Exit(False);

  AnchorItem := FAnchors[CoverageIndex];
  EntryAnchor := AnchorItem.EntryAnchor;
  if (EntryAnchor = nil) then
    Exit(False);

  // Align exit anchor-point with entry anchor-point
  EntryAnchorPoint := EntryAnchor.Position;
  ExitAnchorPoint := ExitAnchor.Position;

  case AGlyphIterator.GlyphString.Direction of
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

  if (LookupTable.LookupFlags and TCustomOpenTypeLookupTable.RIGHT_TO_LEFT <> 0) then
  begin
    CurrentGlyph.CursiveAttachment := NextIndex;
    CurrentGlyph.YOffset := EntryAnchorPoint.Y - ExitAnchorPoint.Y;
  end else
  begin
    NextGlyph.CursiveAttachment := AGlyphIterator.Index;
    CurrentGlyph.YOffset := ExitAnchorPoint.Y - EntryAnchorPoint.Y;
  end;

{$ifdef ApplyIncrements}
  AGlyphIterator.Next;
{$endif ApplyIncrements}

  Result := True;
end;

procedure TOpenTypePositioningSubTableCursiveAttachment.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  EntryExitRecordOffsets: array of record
    EntryAnchorOffset: Word;
    ExitAnchorOffset: Word;
  end;
  i: integer;
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
        Anchor.EntryAnchor := TOpenTypeAnchor.CreateFromStream(Stream);
      end;

      // Read exit anchor
      if (EntryExitRecordOffsets[i].ExitAnchorOffset <> 0) then
      begin
        Stream.Position := StartPos + EntryExitRecordOffsets[i].ExitAnchorOffset;
        Anchor.ExitAnchor := TOpenTypeAnchor.CreateFromStream(Stream);
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
//var
//  StartPos: Int64;
begin
//  StartPos := Stream.Position;

  inherited;

  // TODO
end;


//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpCursiveAttachment, TOpenTypePositioningLookupTableCursiveAttachment);
end.

