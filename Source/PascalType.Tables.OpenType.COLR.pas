unit PascalType.Tables.OpenType.COLR;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'COLR' table type                                     //
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
//  The initial developer of this code is Anders Melander.                    //
//                                                                            //
//  Portions created by Anders Melander are Copyright (C) 2024                //
//  by Anders Melander. All Rights Reserved.                                  //
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
  PascalType.Tables,
  PascalType.Tables.OpenType,
  PascalType.Tables.OpenType.Common;

//------------------------------------------------------------------------------
//
//              TOpenTypeColorCOLRTable
//
//------------------------------------------------------------------------------
// Microsoft Color table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/COLR
//------------------------------------------------------------------------------
type
  TColorBaseGlyph = record
    GlyphID: TGlyphID;
    FirstLayerIndex: integer;
    LayerCount: integer;
  end;

  TColorGlyphLayer = record
    GlyphID: TGlyphID;
    PaletteIndex: Word; // FFFF = Use default
  end;

type
  TOpenTypeColorCOLRTable = class(TCustomOpenTypeNamedTable)
  private
    FVersion: Word;
    FGlyphs: TArray<TColorBaseGlyph>;
    FLayers: TArray<TColorGlyphLayer>;
  protected
    function GetGlyph(Index: integer): TColorBaseGlyph;
    function GetGlyphCount: integer;
    function GetLayer(Index: integer): TColorGlyphLayer;
    function GetLayerCount: integer;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

//    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
//    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write FVersion;

    property GlyphCount: integer read GetGlyphCount;
    property Glyphs[Index: integer]: TColorBaseGlyph read GetGlyph;

    property LayerCount: integer read GetLayerCount;
    property Layers[Index: integer]: TColorGlyphLayer read GetLayer;
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
//              TOpenTypeColorCOLRTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeColorCOLRTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;

end;

destructor TOpenTypeColorCOLRTable.Destroy;
begin

  inherited;
end;

//------------------------------------------------------------------------------

class function TOpenTypeColorCOLRTable.GetTableType: TTableType;
begin
  Result := 'COLR';
end;

//------------------------------------------------------------------------------

function TOpenTypeColorCOLRTable.GetGlyphCount: integer;
begin
  Result := Length(FGlyphs);
end;

function TOpenTypeColorCOLRTable.GetGlyph(Index: integer): TColorBaseGlyph;
begin
  Result := FGlyphs[Index];
end;

//------------------------------------------------------------------------------

function TOpenTypeColorCOLRTable.GetLayerCount: integer;
begin
  Result := Length(FLayers);
end;

function TOpenTypeColorCOLRTable.GetLayer(Index: integer): TColorGlyphLayer;
begin
  Result := FLayers[Index];
end;

//------------------------------------------------------------------------------

procedure TOpenTypeColorCOLRTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  baseGlyphRecordsOffset: integer;
  layerRecordsOffset: integer;
  baseGlyphListOffset: integer;
  layerListOffset: integer;
  varIndexMapOffset: integer;
  itemVariationStoreOffset: integer;
begin

  StartPos := Stream.Position;
  inherited;

  // HEADER
  // Version 0:
  // ----------+-------------------------+----------------------------------------------------------------------------------------------------
  // Type      | Name                    | Description
  // ----------+-------------------------+----------------------------------------------------------------------------------------------------
  // uint16    | version                 | Table version number(starts at 0).
  // uint16    | numBaseGlyphRecords     | Number of Base Glyph Records.
  // Offset32  | baseGlyphRecordsOffset  | Offset(from beginning of COLR table) to Base Glyph records.
  // Offset32  | layerRecordsOffset      | Offset(from beginning of COLR table) to Layer Records.
  // uint16    | numLayerRecords         | Number of Layer Records.
  // ----------+-------------------------+----------------------------------------------------------------------------------------------------
  // Version 1:
  // Offset32  | baseGlyphListOffset     | Offset to BaseGlyphList table, from beginning of COLR table.
  // Offset32  | layerListOffset         | Offset to LayerList table, from beginning of COLR table (may be NULL).
  // Offset32  | clipListOffset          | Offset to ClipList table, from beginning of COLR table (may be NULL).
  // Offset32  | varIndexMapOffset       | Offset to DeltaSetIndexMap table, from beginning of COLR table (may be NULL).
  // Offset32  | itemVariationStoreOffset| Offset to ItemVariationStore, from beginning of COLR table (may be NULL).
  // ----------+-------------------------+----------------------------------------------------------------------------------------------------

  // version
  FVersion := BigEndianValue.ReadWord(Stream);

  if (Version <> 0) and (Version <> 1) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // numBaseGlyphRecords
  SetLength(FGlyphs, BigEndianValue.ReadWord(Stream));

  // baseGlyphRecordsOffset
  baseGlyphRecordsOffset := BigEndianValue.ReadInteger(Stream);

  // layerRecordsOffset
  layerRecordsOffset := BigEndianValue.ReadInteger(Stream);

  // numLayerRecords
  SetLength(FLayers, BigEndianValue.ReadWord(Stream));

  if (Version > 0) then
  begin
    baseGlyphListOffset := BigEndianValue.ReadInteger(Stream);
    layerListOffset := BigEndianValue.ReadInteger(Stream);
    varIndexMapOffset := BigEndianValue.ReadInteger(Stream);
    itemVariationStoreOffset := BigEndianValue.ReadInteger(Stream);
  end else
  begin
    baseGlyphListOffset := 0;
    layerListOffset := 0;
    varIndexMapOffset := 0;
    itemVariationStoreOffset := 0;
  end;


  // Base Glyph Record
  // ----------+------------------------+----------------------------------------------------------------------------------------------------
  // Type      | Name                   | Description
  // ----------+------------------------+----------------------------------------------------------------------------------------------------
  // uint16    | gID                    | Glyph ID of reference glyph. This glyph is for reference only and is not rendered for color.
  // uint16    | firstLayerIndex        | Index(from beginning of the Layer Records) to the layer record. There will be numLayers consecutive entries for this base glyph.
  // uint16    | numLayers              | Number of color layers associated with this glyph.
  // ----------+------------------------+----------------------------------------------------------------------------------------------------
  if (baseGlyphRecordsOffset <> 0) then
  begin
    Stream.Position := StartPos + baseGlyphRecordsOffset;
    for var i := 0 to High(FGlyphs) do
    begin
      FGlyphs[i].GlyphID := BigEndianValue.ReadWord(Stream);
      FGlyphs[i].FirstLayerIndex := BigEndianValue.ReadWord(Stream);
      FGlyphs[i].LayerCount := BigEndianValue.ReadWord(Stream);
    end;
  end;

  // Layer Record
  // ----------+------------------------+----------------------------------------------------------------------------------------------------
  // Type      | Name                   | Description
  // ----------+------------------------+----------------------------------------------------------------------------------------------------
  // uint16    | gID                    | Glyph ID of layer glyph (must be in z-order from bottom to top).
  // uint16    | paletteIndex           | Index value to use with a selected color palette. This value must be less than numPaletteEntries in
  //           |                        | the CPAL table. A palette entry index value of 0xFFFF is a special case indicating that the text
  //           |                        | foreground color (defined by a higher-level client) should be used and shall not be treated as
  //           |                        | actual index into CPAL ColorRecord array.
  // ----------+------------------------+----------------------------------------------------------------------------------------------------
  if (layerRecordsOffset <> 0) then
  begin
    Stream.Position := StartPos + layerRecordsOffset;
    for var i := 0 to High(FLayers) do
    begin
      FLayers[i].GlyphID := BigEndianValue.ReadWord(Stream);
      FLayers[i].PaletteIndex := BigEndianValue.ReadWord(Stream);
    end;
  end;

end;

initialization

  PascalTypeTableClasses.RegisterTables([TOpenTypeColorCOLRTable]);

end.
