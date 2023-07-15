unit PascalType.Tables.OpenType.Positioning.MarkToMark;

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
  PascalType.Types,
  PascalType.Classes,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Positioning,
  PascalType.Tables.OpenType.Coverage,
  PascalType.Tables.OpenType.Common.Mark,
  PascalType.Tables.OpenType.Common.Anchor,
  PascalType.Tables.OpenType.Positioning.MarkToBase;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableMarkToMarkAttachment
//
//------------------------------------------------------------------------------
// Lookup Type 6: Mark-to-Mark Attachment Positioning Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-6-mark-to-mark-attachment-positioning-subtable
//------------------------------------------------------------------------------
type
  TOpenTypePositioningLookupTableMarkToMarkAttachment = class(TCustomOpenTypePositioningLookupTable)
  public type
    TGlyphPositioningFormat = (
      gpmmInvalid       = 0,
      gpmmAttachment    = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableMarkToMarkAttachment
//
//------------------------------------------------------------------------------
// Mark-to-Mark Attachment Positioning Format 1: Mark-to-Mark Attachment
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#mark-to-mark-attachment-positioning-format-1-mark-to-mark-attachment
//------------------------------------------------------------------------------
// Identical in layout to the Mark to Base format.
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableMarkToMarkAttachment = class(TOpenTypePositioningSubTableMarkToBaseAttachment)
  private
  protected
    function GetMark1Coverage: TCustomOpenTypeCoverageTable;
    function GetMark2Coverage: TCustomOpenTypeCoverageTable;
  public
    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property Mark1Coverage: TCustomOpenTypeCoverageTable read GetMark1Coverage;
    property Mark2Coverage: TCustomOpenTypeCoverageTable read GetMark2Coverage;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableMarkToMarkAttachment
//
//------------------------------------------------------------------------------
function TOpenTypePositioningLookupTableMarkToMarkAttachment.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphPositioningFormat(ASubFormat) of

    gpmmAttachment :
      Result := TOpenTypePositioningSubTableMarkToMarkAttachment;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableMarkToMarkAttachment
//
//------------------------------------------------------------------------------
function TOpenTypePositioningSubTableMarkToMarkAttachment.GetMark1Coverage: TCustomOpenTypeCoverageTable;
begin
  Result := inherited MarkCoverage;
end;

function TOpenTypePositioningSubTableMarkToMarkAttachment.GetMark2Coverage: TCustomOpenTypeCoverageTable;
begin
  Result := inherited BaseCoverage;
end;

function TOpenTypePositioningSubTableMarkToMarkAttachment.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  Mark1Glyph: TPascalTypeGlyph;
  Mark2Glyph: TPascalTypeGlyph;
  Mark1Index: integer;
  Mark2Index: integer;
  Mark2GlyphIndex: integer;
  Mark1: TOpenTypeMark;
  Mark2Anchor: TOpenTypeAnchor;
begin
  if (AGlyphIterator.Index < 1) then
    Exit(False);

  Mark1Glyph := AGlyphIterator.Glyph;
  Mark1Index := Mark1Coverage.IndexOfGlyph(Mark1Glyph.GlyphID);
  if (Mark1Index = -1) then
    Exit(False);

  // Get previous mark to attach to
  Mark2GlyphIndex := AGlyphIterator.Peek(-1);
  Mark2Glyph := AGlyphIterator.GlyphString[Mark2GlyphIndex];
  if (Mark2Glyph = nil) or (not Mark2Glyph.IsMark) then
    Exit(False);

  // The following logic was borrowed from Harfbuzz
  var Found := False;

  if (Mark1Glyph.LigatureID = Mark2Glyph.LigatureID) then
  begin
    if (Mark1Glyph.LigatureID = -1) then
      // Marks belonging to the same base
      Found := True
    else
    if (Mark1Glyph.LigatureComponent = Mark2Glyph.LigatureComponent) then
      // Marks belonging to the same ligature component
      Found := True;
  end else
  begin
    // If ligature ids don't match, it may be the case that one of the marks
    // itself is a ligature, in which case match.
    if ((Mark1Glyph.LigatureID <> -1) and (Mark1Glyph.LigatureComponent = -1)) or
       ((Mark2Glyph.LigatureID <> -1) and (Mark2Glyph.LigatureComponent = -1)) then
      Found := True;
  end;

  if (not Found) then
    Exit(False);

  Mark2Index := BaseCoverage.IndexOfGlyph(Mark2Glyph.GlyphID);
  if (Mark2Index = -1) then
    Exit(False);

  Mark1 := Marks[Mark1Index];
  Mark2Anchor := BaseRecords[Mark2Index][Mark1.MarkClass];
  if (Mark2Anchor = nil) then
    Exit(False);

  Mark1Glyph.ApplyAnchor(Mark1.Anchor, Mark2Anchor, Mark2GlyphIndex);

{$ifdef ApplyIncrements}
  AGlyphIterator.Next;
{$endif ApplyIncrements}

  Result := True;
end;


//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpMarkToMarkAttachment, TOpenTypePositioningLookupTableMarkToMarkAttachment);
end.

