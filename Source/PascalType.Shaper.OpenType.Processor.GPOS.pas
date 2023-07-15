unit PascalType.Shaper.OpenType.Processor.GPOS;

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

uses
  PascalType.Types,
  PascalType.GlyphString,
  PascalType.FontFace.SFNT,
  PascalType.Tables.OpenType.Common,
  PascalType.Tables.OpenType.GPOS,
  PascalType.Shaper.OpenType.Processor;


//------------------------------------------------------------------------------
//
//              TPascalTypeOpenTypeProcessorGPOS
//
//------------------------------------------------------------------------------
// GPOS table processor
//------------------------------------------------------------------------------
type
  TPascalTypeOpenTypeProcessorGPOS = class(TCustomPascalTypeOpenTypeProcessor)
  private
    FPositionTable: TOpenTypeGlyphPositionTable;
  protected
    function GetTable: TCustomOpenTypeCommonTable; override;
    function GetAvailableFeatures: TPascalTypeFeatures; override;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace; AScript: TTableType; ALanguage: TTableType; ADirection: TPascalTypeDirection); override;

    function ApplyFeatures(const AUserFeatures: TPascalTypeFeatures; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures; override;

    property PositionTable: TOpenTypeGlyphPositionTable read FPositionTable;
  end;

implementation

uses
  Generics.Defaults,
{$ifdef DEBUG}
  WinApi.Windows,
{$endif DEBUG}
  System.SysUtils,
  PascalType.Classes;


//------------------------------------------------------------------------------
//
//              TPascalTypeOpenTypeProcessorGPOS
//
//------------------------------------------------------------------------------
constructor TPascalTypeOpenTypeProcessorGPOS.Create(AFont: TCustomPascalTypeFontFace; AScript: TTableType; ALanguage: TTableType; ADirection: TPascalTypeDirection);
begin
  inherited;

  FPositionTable := Font.GetTableByTableType(TOpenTypeGlyphPositionTable.GetTableType) as TOpenTypeGlyphPositionTable;
end;

function TPascalTypeOpenTypeProcessorGPOS.GetAvailableFeatures: TPascalTypeFeatures;
begin
  Result := inherited GetAvailableFeatures;

  // If we do not have a 'kern' lookup, but we have an old-style kern table, then
  // we indicate that we are able to apply the 'kern' feature.
  if (not Result.Contains('kern')) and (Font.GetTableByTableType('kern') <> nil) then
    Result.Add('kern');
end;

function TPascalTypeOpenTypeProcessorGPOS.GetTable: TCustomOpenTypeCommonTable;
begin
  Result := FPositionTable;
end;

function TPascalTypeOpenTypeProcessorGPOS.ApplyFeatures(const AUserFeatures: TPascalTypeFeatures; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures;

  procedure FixupCursiveAttachment(Glyph: TPascalTypeGlyph);
  var
    CursiveAttachmentGlyph: TPascalTypeGlyph;
  begin
    if (Glyph.CursiveAttachment = -1) then
      exit;

    CursiveAttachmentGlyph := AGlyphs[Glyph.CursiveAttachment];

    Glyph.CursiveAttachment := -1;

    FixupCursiveAttachment(CursiveAttachmentGlyph);

    Glyph.YOffset := Glyph.YOffset + CursiveAttachmentGlyph.YOffset;
  end;

  procedure FixupCursiveAttachments;
  var
    Glyph: TPascalTypeGlyph;
  begin
    for Glyph in AGlyphs do
      FixupCursiveAttachment(Glyph);
  end;

  procedure FixupMarkAttachments;
  var
    i, j: integer;
    Glyph: TPascalTypeGlyph;
  begin
    for i := 0 to AGlyphs.Count-1 do
    begin
      Glyph := AGlyphs[i];

      if (Glyph.MarkAttachment = -1) then
        continue;

      Glyph.XOffset := Glyph.XOffset + AGlyphs[Glyph.MarkAttachment].XOffset;
      Glyph.YOffset := Glyph.YOffset + AGlyphs[Glyph.MarkAttachment].YOffset;

      if (Direction = dirLeftToRight) then
      begin
        for j := Glyph.MarkAttachment to i-1 do
        begin
          Glyph.XOffset := Glyph.XOffset - AGlyphs[j].XAdvance;
          Glyph.YOffset := Glyph.YOffset - AGlyphs[j].YAdvance;
        end;
      end else
      begin
        for j := Glyph.MarkAttachment+1 to i do
        begin
          Glyph.XOffset := Glyph.XOffset + AGlyphs[j].XAdvance;
          Glyph.YOffset := Glyph.YOffset + AGlyphs[j].YAdvance;
        end;
      end;
    end;
  end;

begin
  Result := inherited ApplyFeatures(AUserFeatures, AGlyphs);

  FixupCursiveAttachments;
  FixupMarkAttachments;
end;

end.
