unit PascalType.Tables.TrueType.post;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'post' table type                                     //
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
//  The initial developer of this code is Christian-W. Budde                  //
//                                                                            //
//  Portions created by Christian-W. Budde are Copyright (C) 2010-2017        //
//  by Christian-W. Budde. All Rights Reserved.                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface


{$I PT_Compiler.inc}

uses
  Classes,
  PT_Types,
  PT_Classes,
  PascalType.Tables;

//------------------------------------------------------------------------------
//
//              TPascalTypePostscriptTable
//
//------------------------------------------------------------------------------
// post — PostScript Table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/post
// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6post.html
//------------------------------------------------------------------------------
type
  TPascalTypePostscriptVersion2Table = class(TCustomPascalTypeTable)
  private
    FGlyphNameIndex: array of Word; // This is not an offset, but is the ordinal number of the glyph in 'post' string tables.
    FNames: array of ShortString;
    function GetGlyphIndexCount: Integer; // Glyph names with length bytes [variable] (a Pascal string).
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function GlyphIndexToString(GlyphIndex: Integer): string;

    property GlyphIndexCount: Integer read GetGlyphIndexCount;
  end;

  TPascalTypePostscriptTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion            : TFixedPoint; // Format of this table
    FItalicAngle        : TFixedPoint; // Italic angle in degrees
    FUnderlinePosition  : SmallInt;    // Underline position
    FUnderlineThickness : SmallInt;    // Underline thickness
    FIsFixedPitch       : Cardinal;     // Font is monospaced; set to 1 if the font is monospaced and 0 otherwise (N.B., to maintain compatibility with older versions of the TrueType spec, accept any non-zero value as meaning that the font is monospaced)
    FMinMemType42       : Cardinal;     // Minimum memory usage when a TrueType font is downloaded as a Type 42 font
    FMaxMemType42       : Cardinal;     // Maximum memory usage when a TrueType font is downloaded as a Type 42 font
    FMinMemType1        : Cardinal;     // Minimum memory usage when a TrueType font is downloaded as a Type 1 font
    FMaxMemType1        : Cardinal;     // Maximum memory usage when a TrueType font is downloaded as a Type 1 font
    FPostscriptV2Table  : TPascalTypePostscriptVersion2Table;
    procedure SetVersion(const Value: TFixedPoint);
    procedure SetIsFixedPitch(const Value: Cardinal);
    procedure SetItalicAngle(const Value: TFixedPoint);
    procedure SetMaxMemType1(const Value: Cardinal);
    procedure SetMaxMemType42(const Value: Cardinal);
    procedure SetMinMemType1(const Value: Cardinal);
    procedure SetMinMemType42(const Value: Cardinal);
    procedure SetUnderlinePosition(const Value: SmallInt);
    procedure SetUnderlineThickness(const Value: SmallInt);
  protected
    procedure VersionChanged; virtual;
    procedure IsFixedPitchChanged; virtual;
    procedure ItalicAngleChanged; virtual;
    procedure MaxMemType1Changed; virtual;
    procedure MaxMemType42Changed; virtual;
    procedure MinMemType1Changed; virtual;
    procedure MinMemType42Changed; virtual;
    procedure UnderlinePositionChanged; virtual;
    procedure UnderlineThicknessChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
    property ItalicAngle: TFixedPoint read FItalicAngle write SetItalicAngle;
    property UnderlinePosition: SmallInt read FUnderlinePosition write SetUnderlinePosition;
    property UnderlineThickness: SmallInt read FUnderlineThickness write SetUnderlineThickness;
    property IsFixedPitch: Cardinal read FIsFixedPitch write SetIsFixedPitch;
    property MinMemType42: Cardinal read FMinMemType42 write SetMinMemType42;
    property MaxMemType42: Cardinal read FMaxMemType42 write SetMaxMemType42;
    property MinMemType1: Cardinal read FMinMemType1 write SetMinMemType1;
    property MaxMemType1: Cardinal read FMaxMemType1 write SetMaxMemType1;
    property PostscriptV2Table: TPascalTypePostscriptVersion2Table read FPostscriptV2Table;
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
//              TPascalTypePostscriptVersion2Table
//
//------------------------------------------------------------------------------
function TPascalTypePostscriptVersion2Table.GetGlyphIndexCount: Integer;
begin
  Result := Length(FGlyphNameIndex);
end;

function TPascalTypePostscriptVersion2Table.GlyphIndexToString(GlyphIndex: Integer): string;
begin
  if FGlyphNameIndex[GlyphIndex] < 258 then
    Result := DefaultGlyphName(FGlyphNameIndex[GlyphIndex])
  else
    Result := string(FNames[FGlyphNameIndex[GlyphIndex] - 258]);
end;

procedure TPascalTypePostscriptVersion2Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypePostscriptVersion2Table then
  begin
    FGlyphNameIndex := TPascalTypePostscriptVersion2Table(Source).FGlyphNameIndex;
    FNames := TPascalTypePostscriptVersion2Table(Source).FNames;
  end;
end;

procedure TPascalTypePostscriptVersion2Table.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  i: Integer;
  Value8: Byte;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // load number of glyphs
  SetLength(FGlyphNameIndex, BigEndianValue.ReadWord(Stream));

  // read glyph name index array
  for i := 0 to High(FGlyphNameIndex) do
    FGlyphNameIndex[i] := BigEndianValue.ReadWord(Stream);

  Dec(Size, (Length(FGlyphNameIndex) + 1) * SizeOf(Word));

  while Size > 0 do
  begin
    Stream.Read(Value8, SizeOf(Byte));

    SetLength(FNames, Length(FNames) + 1);
    SetLength(FNames[High(FNames)], Value8);

    Stream.Read(FNames[High(FNames)][1], Value8);

    Dec(Size, Value8 + 1);
  end;
end;

procedure TPascalTypePostscriptVersion2Table.SaveToStream(Stream: TStream);
begin
  inherited;

  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


//------------------------------------------------------------------------------
//
//              TPascalTypePostscriptTable
//
//------------------------------------------------------------------------------
constructor TPascalTypePostscriptTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 2;
end;

destructor TPascalTypePostscriptTable.Destroy;
begin
  FPostscriptV2Table.Free;
  inherited;
end;

class function TPascalTypePostscriptTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'post';
end;

procedure TPascalTypePostscriptTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypePostscriptTable then
  begin
    FVersion := TPascalTypePostscriptTable(Source).FVersion;
    FItalicAngle := TPascalTypePostscriptTable(Source).FItalicAngle;
    FUnderlinePosition := TPascalTypePostscriptTable(Source).FUnderlinePosition;
    FUnderlineThickness := TPascalTypePostscriptTable(Source).FUnderlineThickness;
    FIsFixedPitch := TPascalTypePostscriptTable(Source).FIsFixedPitch;
    FMinMemType42 := TPascalTypePostscriptTable(Source).FMinMemType42;
    FMaxMemType42 := TPascalTypePostscriptTable(Source).FMaxMemType42;
    FMinMemType1 := TPascalTypePostscriptTable(Source).FMinMemType1;
    FMaxMemType1 := TPascalTypePostscriptTable(Source).FMaxMemType1;
    if (TPascalTypePostscriptTable(Source).FPostscriptV2Table <> nil) then
    begin
      if (FPostscriptV2Table = nil) then
        FPostscriptV2Table := TPascalTypePostscriptVersion2Table.Create(Self);
      FPostscriptV2Table.Assign(TPascalTypePostscriptTable(Source).FPostscriptV2Table);
    end else
      FreeAndNil(FPostscriptV2Table);
  end;
end;

{$IFOPT R+}
{$DEFINE R_PLUS}
{$RANGECHECKS OFF}
{$ENDIF}
procedure TPascalTypePostscriptTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  FVersion.Fixed := BigEndianValue.ReadInteger(Stream);;
  FItalicAngle.Fixed := BigEndianValue.ReadInteger(Stream);;
  FUnderlinePosition := BigEndianValue.ReadWord(Stream);
  FUnderlineThickness := BigEndianValue.ReadWord(Stream);
  FIsFixedPitch := BigEndianValue.ReadCardinal(Stream);
  FMinMemType42 := BigEndianValue.ReadCardinal(Stream);
  FMaxMemType42 := BigEndianValue.ReadCardinal(Stream);
  FMinMemType1 := BigEndianValue.ReadCardinal(Stream);
  FMaxMemType1 := BigEndianValue.ReadCardinal(Stream);

  (*
  ** Version 1.0 is used in order to supply PostScript glyph names when the font file contains exactly
  ** the 258 glyphs in the standard Macintosh TrueType font file (see 'post' Format 1 in Apple’s
  ** specification for a list of the 258 Macintosh glyph names), and the font does not otherwise supply
  ** glyph names.
  **
  ** Version 2.0 is used for fonts that use glyph names that are not in the set of Macintosh glyph names.
  **
  ** Version 2.5 has been deprecated as of OpenType Specification v1.3.
  **
  ** Version 3.0 specifies that no PostScript name information is provided for the glyphs in this font file.
  *)

  if FVersion.Value = 2 then
  begin
    Dec(Size, 2*SizeOf(Integer));
    Dec(Size, 2*SizeOf(Word));
    Dec(Size, 5*SizeOf(Cardinal));

    if (FPostscriptV2Table = nil) then
      FPostscriptV2Table := TPascalTypePostscriptVersion2Table.Create(Self);
    FPostscriptV2Table.LoadFromStream(Stream, Size);
  end else
    FreeAndNil(FPostscriptV2Table);
end;
{$IFDEF R_PLUS}
{$RANGECHECKS ON}
{$UNDEF R_PLUS}
{$ENDIF}

procedure TPascalTypePostscriptTable.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));
  BigEndianValue.WriteCardinal(Stream, Cardinal(FItalicAngle));
  BigEndianValue.WriteWord(Stream, FUnderlinePosition);
  BigEndianValue.WriteWord(Stream, FUnderlineThickness);
  BigEndianValue.WriteCardinal(Stream, FIsFixedPitch);
  BigEndianValue.WriteCardinal(Stream, FMinMemType42);
  BigEndianValue.WriteCardinal(Stream, FMaxMemType42);
  BigEndianValue.WriteCardinal(Stream, FMinMemType1);
  BigEndianValue.WriteCardinal(Stream, FMaxMemType1);
end;

procedure TPascalTypePostscriptTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Value <> Value.Value) or (FVersion.Fract <> Value.Fract) then
  begin
    Version := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypePostscriptTable.SetIsFixedPitch(const Value: Cardinal);
begin
  if FIsFixedPitch <> Value then
  begin
    FIsFixedPitch := Value;
    IsFixedPitchChanged;
  end;
end;

procedure TPascalTypePostscriptTable.SetItalicAngle(const Value: TFixedPoint);
begin
  if (FItalicAngle.Value <> Value.Value) or (FItalicAngle.Fract <> Value.Fract) then
  begin
    FItalicAngle := Value;
    ItalicAngleChanged;
  end;
end;

procedure TPascalTypePostscriptTable.SetMaxMemType1(const Value: Cardinal);
begin
  if FMaxMemType1 <> Value then
  begin
    FMaxMemType1 := Value;
    MaxMemType1Changed;
  end;
end;

procedure TPascalTypePostscriptTable.SetMaxMemType42(const Value: Cardinal);
begin
  if FMaxMemType42 <> Value then
  begin
    FMaxMemType42 := Value;
    MaxMemType42Changed;
  end;
end;

procedure TPascalTypePostscriptTable.SetMinMemType1(const Value: Cardinal);
begin
  if FMinMemType1 <> Value then
  begin
    FMinMemType1 := Value;
    MinMemType1Changed;
  end;
end;

procedure TPascalTypePostscriptTable.SetMinMemType42(const Value: Cardinal);
begin
  if FMinMemType42 <> Value then
  begin
    FMinMemType42 := Value;
    MinMemType42Changed;
  end;
end;

procedure TPascalTypePostscriptTable.SetUnderlinePosition(const Value: SmallInt);
begin
  if FUnderlinePosition <> Value then
  begin
    FUnderlinePosition := Value;
    UnderlinePositionChanged;
  end;
end;

procedure TPascalTypePostscriptTable.SetUnderlineThickness(const Value: SmallInt);
begin
  if FUnderlineThickness <> Value then
  begin
    FUnderlineThickness := Value;
    UnderlineThicknessChanged;
  end;
end;

procedure TPascalTypePostscriptTable.VersionChanged;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.IsFixedPitchChanged;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.ItalicAngleChanged;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.MaxMemType1Changed;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.MaxMemType42Changed;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.MinMemType1Changed;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.MinMemType42Changed;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.UnderlinePositionChanged;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.UnderlineThicknessChanged;
begin
  Changed;
end;

initialization

  PascalTypeTableClasses.RegisterTable(TPascalTypePostscriptTable);

end.

