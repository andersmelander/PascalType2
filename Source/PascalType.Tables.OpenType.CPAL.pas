unit PascalType.Tables.OpenType.CPAL;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'CPAL' table type                                     //
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
//              TOpenTypeColorCPALTable
//
//------------------------------------------------------------------------------
// Microsoft Color Palette table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/CPAL
//------------------------------------------------------------------------------
type
  TPaletteColor = packed record
    Blue: Byte;
    Green: Byte;
    Red: Byte;
    Alpha: Byte;
  end;

{$MINENUMSIZE 4}
// CPAL version 0 does not have any flags indicating intended usage
// but by convention, for CPAL version 0, and CPAL version 1 with no
// flags
// - Palette #0: Dark on light (i.e. Light color scheme)
// - Palette #1: Light on dark (i.e. Dark color scheme)
type
  TColorPaletteFlag = (
    cpfUsableWithLightBackground,       // Palette is appropriate to use when displaying the font on a light background such as white.
    cpfUsableWithDarkBackground         // Palette is appropriate to use when displaying the font on a dark background such as black.
  );
  TColorPaletteFlags = set of TColorPaletteFlag;

  TColorPalette = record
    FirstColorIndex: integer;
    NameIndex: integer;
    Flags: TColorPaletteFlags;
  end;

type
  TOpenTypeColorCPALTable = class(TCustomOpenTypeNamedTable)
  private
    FVersion: Word;
    FColors: TArray<TPaletteColor>;
    FPalettes: TArray<TColorPalette>;
    FColorNames: TArray<integer>;
    FPaletteSize: integer;
  protected
    function GetColor(Index: integer): TPaletteColor;
    function GetColorCount: integer;
    function GetPalette(Index: integer): TColorPalette;
    function GetPaletteCount: integer;
    function GetPaletteColor(PaletteIndex, ColorIndex: integer): TPaletteColor;
    function GetColorName(Index: integer): integer;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

//    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
//    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write FVersion;

    property PaletteSize: integer read FPaletteSize write FPaletteSize;
    property ColorNames[Index: integer]: integer read GetColorName;

    property ColorCount: integer read GetColorCount;
    property Colors[Index: integer]: TPaletteColor read GetColor;

    property PaletteCount: integer read GetPaletteCount;
    property Palettes[Index: integer]: TColorPalette read GetPalette;

    property PaletteColors[PaletteIndex, ColorIndex: integer]: TPaletteColor read GetPaletteColor;
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
//              TOpenTypeColorCPALTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeColorCPALTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;

end;

destructor TOpenTypeColorCPALTable.Destroy;
begin

  inherited;
end;

//------------------------------------------------------------------------------

class function TOpenTypeColorCPALTable.GetTableType: TTableType;
begin
  Result := 'CPAL';
end;

//------------------------------------------------------------------------------

function TOpenTypeColorCPALTable.GetColorCount: integer;
begin
  Result := Length(FColors);
end;

function TOpenTypeColorCPALTable.GetColor(Index: integer): TPaletteColor;
begin
  Result := FColors[Index];
end;

//------------------------------------------------------------------------------

function TOpenTypeColorCPALTable.GetPaletteCount: integer;
begin
  Result := Length(FPalettes);
end;

function TOpenTypeColorCPALTable.GetPalette(Index: integer): TColorPalette;
begin
  Result := FPalettes[Index];
end;

//------------------------------------------------------------------------------

function TOpenTypeColorCPALTable.GetColorName(Index: integer): integer;
begin
  Result := FColorNames[Index];
end;

//------------------------------------------------------------------------------

function TOpenTypeColorCPALTable.GetPaletteColor(PaletteIndex, ColorIndex: integer): TPaletteColor;
begin
  var FirstIndex := FPalettes[PaletteIndex].FirstColorIndex;
  Result := FColors[FirstIndex + ColorIndex];
end;

//------------------------------------------------------------------------------

procedure TOpenTypeColorCPALTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  colorRecordsArrayOffset: integer;
  offsetPaletteTypeArray: integer;
  offsetPaletteLabelArray: integer;
  offsetPaletteEntryLabelArray: integer;
begin

  StartPos := Stream.Position;
  inherited;

  // Header
  // Version 0:
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // Type      | Name                            | Description
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // uint16    | version                         | Table version number (=0).
  // uint16    | numPaletteEntries               | Number of palette entries in each palette.
  // uint16    | numPalettes                     | Number of palettes in the table.
  // uint16    | numColorRecords                 | Total number of Colors records, combined for all palettes.
  // Offset32  | colorRecordsArrayOffset         | Offset from the beginning of CPAL table to the first ColorRecord.
  // uint16    | colorRecordIndices[numPalettes] | Index of each palette’s first Colors record in the combined Colors record array.
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // Version 1:
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // Offset32  | offsetPaletteTypeArray          | Offset from the beginning of CPAL table to the Palette Type Array. Set to 0 if no array is provided.
  // Offset32  | offsetPaletteLabelArray         | Offset from the beginning of CPAL table to the Palette Labels Array. Set to 0 if no array is provided.
  // Offset32  | offsetPaletteEntryLabelArray    | Offset from the beginning of CPAL table to the Palette Entry Label Array.Set to 0 if no array is provided.
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------

  // version
  FVersion := BigEndianValue.ReadWord(Stream);

  if (Version <> 0) and (Version <> 1) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // numPaletteEntries
  FPaletteSize := BigEndianValue.ReadWord(Stream);

  // numPalettes
  SetLength(FPalettes, BigEndianValue.ReadWord(Stream));

  // numColorRecords
  SetLength(FColors, BigEndianValue.ReadWord(Stream));

  // colorRecordsArrayOffset
  colorRecordsArrayOffset := BigEndianValue.ReadInteger(Stream);

  if (Version > 0) then
  begin
    offsetPaletteTypeArray := BigEndianValue.ReadInteger(Stream);
    offsetPaletteLabelArray := BigEndianValue.ReadInteger(Stream);
    offsetPaletteEntryLabelArray := BigEndianValue.ReadInteger(Stream);
  end else
  begin
    offsetPaletteTypeArray := 0;
    offsetPaletteLabelArray := 0;
    offsetPaletteEntryLabelArray := 0;
  end;

  // colorRecordIndices[numPalettes]
  for var i := 0 to High(FPalettes) do
  begin
    FPalettes[i].FirstColorIndex := BigEndianValue.ReadWord(Stream);
    FPalettes[i].NameIndex := -1;
    FPalettes[i].Flags := [];
  end;

  // -----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // Type       | Name                            | Description
  // -----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // ColorRecord| colorRecords[numColorRecords]   | Color records for all palettes.
  // -----------+---------------------------------+----------------------------------------------------------------------------------------------------
  Stream.Position := StartPos + colorRecordsArrayOffset;
  for var i := 0 to High(FColors) do
  begin
    FColors[i].Blue := BigEndianValue.ReadByte(Stream);
    FColors[i].Green := BigEndianValue.ReadByte(Stream);
    FColors[i].Red := BigEndianValue.ReadByte(Stream);
    FColors[i].Alpha := BigEndianValue.ReadByte(Stream);
  end;

  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // Type      | Name                            | Description
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // uint32    | paletteTypes[numPalettes]       | Array of 32-bit flag fields that describe properties of each palette.
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  if (offsetPaletteTypeArray <> 0) then
  begin
    Stream.Position := StartPos + offsetPaletteTypeArray;
    for var i := 0 to High(FPalettes) do
      // {$MINENUMSIZE 4} should have made the byte cast unnecessary - but it doesn't
      FPalettes[i].Flags := TColorPaletteFlags(Byte(BigEndianValue.ReadCardinal(Stream)));
  end;

  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // Type      | Name                            | Description
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  // uint16    | paletteLabels[numPalettes]      | Array of 'name' table IDs. Use 0xFFFF for a particular palette if no string is provided.
  // ----------+---------------------------------+----------------------------------------------------------------------------------------------------
  if (offsetPaletteLabelArray <> 0) then
  begin
    Stream.Position := StartPos + offsetPaletteLabelArray;
    for var i := 0 to High(FPalettes) do
    begin
      var Index := BigEndianValue.ReadWord(Stream);
      if (Index <> $FFFF) then
        FPalettes[i].NameIndex := Index;
    end;
  end;

  // ----------+---------------------------------------+----------------------------------------------------------------------------------------------------
  // Type      | Name                                  | Description
  // ----------+---------------------------------------+----------------------------------------------------------------------------------------------------
  // uint16    | paletteEntryLabels[numPaletteEntries] | Array of 'name' table IDs. Use 0xFFFF for a particular entry if no string is provided.
  // ----------+---------------------------------------+----------------------------------------------------------------------------------------------------
  if (offsetPaletteEntryLabelArray <> 0) then
  begin
    Setlength(FColorNames, FPaletteSize);

    Stream.Position := StartPos + offsetPaletteEntryLabelArray;
    for var i := 0 to High(FColorNames) do
    begin
      var Index := BigEndianValue.ReadWord(Stream);
      if (Index <> $FFFF) then
        FColorNames[i] := Index
      else
        FColorNames[i] := -1;
    end;
  end else
    Setlength(FColorNames, 0);

end;

initialization

  PascalTypeTableClasses.RegisterTables([TOpenTypeColorCPALTable]);

end.
