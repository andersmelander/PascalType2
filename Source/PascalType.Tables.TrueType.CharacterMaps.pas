unit PascalType.Tables.TrueType.CharacterMaps;

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
  Classes, SysUtils,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables,
  PascalType.Unicode,
  PascalType.Tables.TrueType.cmap;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat0CharacterMap
//
//------------------------------------------------------------------------------
// Format 0: Byte encoding table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#format-0-byte-encoding-table
//------------------------------------------------------------------------------
type
  TPascalTypeFormat0CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLength: Word; // This is the length in bytes of the subtable.
    FLanguage: Word; // Please see 'Note on the language field in 'cmap' subtables' in this document.
    FGlyphIdArray: array[Byte] of Byte; // An array that maps character codes to glyph index values.
  protected
    class function GetFormat: Word; override;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; override;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat2CharacterMap
//
//------------------------------------------------------------------------------
// Format 2: High-byte mapping through table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#format-2-high-byte-mapping-through-table
//------------------------------------------------------------------------------
type
  TPascalTypeFormat2CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLength: Word; // This is the length in bytes of the subtable.
    FLanguage: Word; // Please see 'Note on the language field in 'cmap' subtables' in this document.
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; override;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat4CharacterMap
//
//------------------------------------------------------------------------------
// Format 4: Segment mapping to delta values
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#format-4-segment-mapping-to-delta-values
//------------------------------------------------------------------------------
type
  TPascalTypeFormat4CharacterMap = class(TCustomPascalTypeCharacterMap)
  private type
    TSegment = record
      StartCode: Word;
      EndCode: Word;
    end;
  private
    FLength: Word;                    // This is the length in bytes of the subtable.
    FLanguage: Word;                  // Please see 'Note on the language field in 'cmap' subtables' in this document.
    FSegments: TArray<TSegment>;      // Start and End characterCode for each segment, last=0xFFFF.
    FIdDelta: array of SmallInt;      // Delta for all character codes in segment.
    FIdRangeOffset: array of Word;    // Offsets into glyphIdArray or 0
    FGlyphIdArray: TGlyphString;     // Glyph index array (arbitrary length)
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; override;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat6CharacterMap
//
//------------------------------------------------------------------------------
// Format 6: Trimmed table mapping
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#format-6-trimmed-table-mapping
//------------------------------------------------------------------------------
type
  TPascalTypeFormat6CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLanguage: Word;              // Please see “Note on the language field in 'cmap' subtables“ in this document.
    FFirstCode: Word;             // First character code of subrange.
    FGlyphIdArray: TGlyphString;  // Array of glyph index values for character codes in the range.
    function GetEntryCount: Word;
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; override;

    property EntryCount: Word read GetEntryCount;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat12CharacterMap
//
//------------------------------------------------------------------------------
// Format 12: Segmented coverage
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#format-12-segmented-coverage
//------------------------------------------------------------------------------
type
  TCharMapSegmentedCoverageRecord = packed record
    StartCharCode: TPascalTypeCodePoint; // First character code in this group
    EndCharCode: TPascalTypeCodePoint;   // Last character code in this group
    StartGlyphID: Cardinal;  // Glyph index corresponding to the starting character code
  end;

  TPascalTypeFormat12CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLanguage: Cardinal; // Please see “Note on the language field in 'cmap' subtables“ in this document.
    FCoverageArray: array of TCharMapSegmentedCoverageRecord;
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; override;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat14CharacterMap
//
//------------------------------------------------------------------------------
// Format 14: Unicode Variation Sequences
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#format-14-unicode-variation-sequences
//------------------------------------------------------------------------------
type
  TPascalTypeFormat14CharacterMap = class(TCustomPascalTypeCharacterMap)
  private type
    TUnicodeRange = record
      StartUnicodeValue: TPascalTypeCodePoint;  // First value in this range, 24-bit
      AdditionalCount: Byte;                    // Number of additional values in this range
    end;

    TUVSMapping = record
      UnicodeValue: TPascalTypeCodePoint;       // Base Unicode value of the UVS, 24-bit
      GlyphID: Word;                            // Glyph ID of the UVS
    end;

    TVariationSelector = record
      VariationSelector: Cardinal;
      DefaultUVS: TArray<TUnicodeRange>;
      NonDefaultUVS: TArray<TUVSMapping>;
    end;

    TVariationSelectors = TArray<TVariationSelector>;
  private
    FVariationSelectors: TVariationSelectors;
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer; override;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  Math,
  PascalType.ResourceStrings;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat0CharacterMap
//
//------------------------------------------------------------------------------
constructor TPascalTypeFormat0CharacterMap.Create(AParent: TCustomPascalTypeTable);
var
  GlyphIdIndex: Byte;
begin
  inherited;

  for GlyphIdIndex := Low(Byte) to High(Byte) do
    FGlyphIdArray[GlyphIdIndex] := GlyphIdIndex;
end;

class function TPascalTypeFormat0CharacterMap.GetFormat: Word;
begin
  Result := 0;
end;

procedure TPascalTypeFormat0CharacterMap.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2*SizeOf(Word) + SizeOf(FGlyphIdArray) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read length
  FLength := BigEndianValue.ReadWord(Stream);

  // read language
  FLanguage := BigEndianValue.ReadWord(Stream);

  Stream.Read(FGlyphIdArray, SizeOf(FGlyphIdArray));
end;

procedure TPascalTypeFormat0CharacterMap.SaveToStream(Stream: TStream);
begin
  // write length
  BigEndianValue.WriteWord(Stream, FLength);

  // write language
  BigEndianValue.WriteWord(Stream, FLanguage);

  Stream.Write(FGlyphIdArray, SizeOf(FGlyphIdArray));
end;

procedure TPascalTypeFormat0CharacterMap.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFormat0CharacterMap then
  begin
    FLength := TPascalTypeFormat0CharacterMap(Source).FLength;
    FLanguage := TPascalTypeFormat0CharacterMap(Source).FLanguage;
    FGlyphIdArray := TPascalTypeFormat0CharacterMap(Source).FGlyphIdArray;
  end;
end;

function TPascalTypeFormat0CharacterMap.CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer;
begin
  if (ACodePoint > High(Byte)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [ACodePoint]);
  Result := FGlyphIdArray[ACodePoint];
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat2CharacterMap
//
//------------------------------------------------------------------------------
class function TPascalTypeFormat2CharacterMap.GetFormat: Word;
begin
  Result := 2;
end;

procedure TPascalTypeFormat2CharacterMap.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFormat2CharacterMap then
  begin
    FLength := TPascalTypeFormat2CharacterMap(Source).FLength;
    FLanguage := TPascalTypeFormat2CharacterMap(Source).FLanguage;
  end;
end;

function TPascalTypeFormat2CharacterMap.CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer;
begin
  Result := ACodePoint;
end;

procedure TPascalTypeFormat2CharacterMap.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read length
  FLength := BigEndianValue.ReadWord(Stream);

  // read language
  FLanguage := BigEndianValue.ReadWord(Stream);
end;

procedure TPascalTypeFormat2CharacterMap.SaveToStream(Stream: TStream);
begin
  // write length
  BigEndianValue.WriteWord(Stream, FLength);

  // write language
  BigEndianValue.WriteWord(Stream, FLanguage);
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat4CharacterMap
//
//------------------------------------------------------------------------------
class function TPascalTypeFormat4CharacterMap.GetFormat: Word;
begin
  Result := 4;
end;

procedure TPascalTypeFormat4CharacterMap.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFormat4CharacterMap then
  begin
    FLength := TPascalTypeFormat4CharacterMap(Source).FLength;
    FLanguage := TPascalTypeFormat4CharacterMap(Source).FLanguage;
    FSegments := TPascalTypeFormat4CharacterMap(Source).FSegments;
    FIdDelta := TPascalTypeFormat4CharacterMap(Source).FIdDelta;
    FIdRangeOffset := TPascalTypeFormat4CharacterMap(Source).FIdRangeOffset;
    FGlyphIdArray := TPascalTypeFormat4CharacterMap(Source).FGlyphIdArray;
  end;
end;

function TPascalTypeFormat4CharacterMap.CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer;
var
  SegmentIndex: Word;
  GlyphIndex: integer;
  Lo, Hi: Integer;
begin
  if (ACodePoint > High(Word)) then
    Exit(0);

  // Binary search
  Lo := Low(FSegments);
  Hi := High(FSegments);
  SegmentIndex := 0;
  while (Lo <= Hi) do
  begin
    SegmentIndex := (Lo + Hi) div 2;
    if (ACodePoint > FSegments[SegmentIndex].EndCode) then
      Lo := Succ(SegmentIndex)
    else
    if (ACodePoint < FSegments[SegmentIndex].StartCode) then
      Hi := Pred(SegmentIndex)
    else
      break;
  end;

  if (Lo > Hi) then
    // Missing glyph
    Exit(0);

  var RangeOffset := FIdRangeOffset[SegmentIndex];
  if RangeOffset <> 0 then
  begin
    // Thank you Apple and Microsoft for the completely bonkers definition
    // of this value.
    GlyphIndex := (
        (RangeOffset div 2 - Length(FIdRangeOffset)) +
        integer(SegmentIndex + ACodePoint - FSegments[SegmentIndex].StartCode)
      ) and $0000FFFF;

    Result := FGlyphIdArray[GlyphIndex];

    // Check for missing character and add offset
    if (Result <> 0) then
      Result := (Result + FIdDelta[SegmentIndex]) and $0000FFFF;
  end else
    Result := (integer(ACodePoint) + FIdDelta[SegmentIndex]) and $0000FFFF;
end;

procedure TPascalTypeFormat4CharacterMap.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  SegIndex: Integer;
{$IFDEF AmbigiousExceptions}
  Value16: Word;
{$ENDIF}
  Count: integer;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 2*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read length
  FLength := BigEndianValue.ReadWord(Stream);

  // check (minimum) table size
  if StartPos + FLength > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read language
  FLanguage := BigEndianValue.ReadWord(Stream);

  Count := BigEndianValue.ReadWord(Stream) div 2;
  Stream.Seek(3*SizeOf(Word), soFromCurrent);

  SetLength(FSegments, Count);
  SetLength(FIdDelta, Count);
  SetLength(FIdRangeOffset, Count);

  // read end count
  for SegIndex := 0 to High(FSegments) do
    FSegments[SegIndex].EndCode := BigEndianValue.ReadWord(Stream);

  // confirm end code is valid (required for binary search)
  if FSegments[High(FSegments)].EndCode <> $FFFF then
    raise EPascalTypeError.CreateFmt(RCStrCharMapErrorEndCount, [FSegments[High(FSegments)].EndCode]);

{$IFDEF AmbigiousExceptions}
  // read reserved
  Value16 := BigEndianValue.ReadWord(Stream);

  // confirm reserved value is valid
  if Value16 <> 0 then
    raise EPascalTypeError.CreateFmt(RCStrCharMapErrorReserved, [Value16]);
{$ELSE}
  // skip reserved
  Stream.Seek(2, soFromCurrent);
{$ENDIF}

  // read start count
  for SegIndex := 0 to High(FSegments) do
  begin
    FSegments[SegIndex].StartCode := BigEndianValue.ReadWord(Stream);

{$IFDEF AmbigiousExceptions}
    // confirm start count is valid
    if FSegments[SegIndex].StartCode > FSegments[SegIndex].EndCode then
      raise EPascalTypeError.CreateFmt(RCStrCharMapErrorStartCount, [FSegments[SegIndex].StartCode]);
{$ENDIF}
  end;

  // read ID delta
  for SegIndex := 0 to High(FIdDelta) do
    Word(FIdDelta[SegIndex]) := BigEndianValue.ReadWord(Stream);

{$IFDEF AmbigiousExceptions}
(*
Disabled: I see no reason why the last entry must be 1. It isn't documented either.
A value of 0 has been observed in the Architecture font. Actually the whole FIdDelta table is zero.
  // confirm ID delta is valid
  if FIdDelta[High(FIdDelta)] <> 1 then
    raise EPascalTypeError.CreateFmt(RCStrCharMapErrorIdDelta, [FIdDelta[High(FIdDelta)]]);
*)
{$ENDIF}

  // read ID range offset
  for SegIndex := 0 to High(FIdRangeOffset) do
    FIdRangeOffset[SegIndex] := BigEndianValue.ReadWord(Stream);

  SetLength(FGlyphIdArray, (FLength - (Stream.Position - StartPos)) div SizeOf(Word));

  // read glyph ID array
  for SegIndex := 0 to High(FGlyphIdArray) do
    FGlyphIdArray[SegIndex] := BigEndianValue.ReadWord(Stream);
end;

procedure TPascalTypeFormat4CharacterMap.SaveToStream(Stream: TStream);
begin
  // write length
  BigEndianValue.WriteWord(Stream, FLength);

  // write language
  BigEndianValue.WriteWord(Stream, FLanguage);

  // TODO : ...
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat6CharacterMap
//
//------------------------------------------------------------------------------
procedure TPascalTypeFormat6CharacterMap.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFormat6CharacterMap then
  begin
    FLanguage := TPascalTypeFormat6CharacterMap(Source).FLanguage;
    FFirstCode := TPascalTypeFormat6CharacterMap(Source).FFirstCode;
    FGlyphIdArray := TPascalTypeFormat6CharacterMap(Source).FGlyphIdArray;
  end;
end;

function TPascalTypeFormat6CharacterMap.CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer;
begin
  Result := 0;
  if (ACodePoint >= FFirstCode) and (integer(ACodePoint - FFirstCode) <= High(FGlyphIdArray)) then
    Result := FGlyphIdArray[ACodePoint - FFirstCode];
end;

function TPascalTypeFormat6CharacterMap.GetEntryCount: Word;
begin
  Result := Length(FGlyphIdArray);
end;

class function TPascalTypeFormat6CharacterMap.GetFormat: Word;
begin
  Result := 6
end;

procedure TPascalTypeFormat6CharacterMap.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  EntryIndex: Integer;
begin
  inherited;

  // read table size
  // TableLength := BigEndianValue.ReadWord(Stream);
  Stream.Seek(SizeOf(Word), soFromCurrent);

  // read language
  FLanguage := BigEndianValue.ReadWord(Stream);

  // read first code
  FFirstCode := BigEndianValue.ReadWord(Stream);

  // read number of character codes in subrange
  SetLength(FGlyphIdArray, BigEndianValue.ReadWord(Stream));

  for EntryIndex := 0 to High(FGlyphIdArray) do
    FGlyphIdArray[EntryIndex] := BigEndianValue.ReadWord(Stream);
end;

procedure TPascalTypeFormat6CharacterMap.SaveToStream(Stream: TStream);
var
  EntryIndex: Integer;
begin
  inherited;

  // write table size
  BigEndianValue.WriteWord(Stream, 8 + 2 * Length(FGlyphIdArray));

  // write language
  BigEndianValue.WriteWord(Stream, FLanguage);

  // write first code
  BigEndianValue.WriteWord(Stream, FFirstCode);

  // write number of character codes in subrange
  BigEndianValue.WriteWord(Stream, Length(FGlyphIdArray));

  // write glyph indices
  for EntryIndex := 0 to High(FGlyphIdArray) do
    BigEndianValue.WriteWord(Stream, FGlyphIdArray[EntryIndex]);
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat12CharacterMap
//
//------------------------------------------------------------------------------
procedure TPascalTypeFormat12CharacterMap.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFormat12CharacterMap then
  begin
    FLanguage := TPascalTypeFormat12CharacterMap(Source).FLanguage;
    FCoverageArray := TPascalTypeFormat12CharacterMap(Source).FCoverageArray;
  end;
end;

function TPascalTypeFormat12CharacterMap.CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer;
var
  Lo, Hi, Mid: Integer;
begin
  // Binary search
  Lo := Low(FCoverageArray);
  Hi := High(FCoverageArray);
  while (Lo <= Hi) do
  begin
    Mid := (Lo + Hi) div 2;
    if (ACodePoint > FCoverageArray[Mid].EndCharCode) then
      Lo := Succ(Mid)
    else
    if (ACodePoint < FCoverageArray[Mid].StartCharCode) then
      Hi := Pred(Mid)
    else
      Exit(FCoverageArray[Mid].StartGlyphID + (ACodePoint - FCoverageArray[Mid].StartCharCode));
  end;

  Result := 0;
end;

class function TPascalTypeFormat12CharacterMap.GetFormat: Word;
begin
  Result := 12;
end;

procedure TPascalTypeFormat12CharacterMap.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  TableLength: Cardinal;
  GroupIndex: Cardinal;
begin
  StartPos := Stream.Position;

  inherited;

{$IFDEF AmbigiousExceptions}
  if BigEndianValue.ReadWord(Stream) <> 0 then
    raise EPascalTypeError.Create(RCStrReservedValueError);
{$ELSE}
  Stream.Seek(2, soFromCurrent);
{$ENDIF}
  // read table length
  TableLength := BigEndianValue.ReadCardinal(Stream);

  // read language
  FLanguage := BigEndianValue.ReadCardinal(Stream);

  // read group count
  SetLength(FCoverageArray, BigEndianValue.ReadCardinal(Stream));

  for GroupIndex := 0 to High(FCoverageArray) do
  begin
    FCoverageArray[GroupIndex].StartCharCode := BigEndianValue.ReadCardinal(Stream);
    FCoverageArray[GroupIndex].EndCharCode := BigEndianValue.ReadCardinal(Stream);
    FCoverageArray[GroupIndex].StartGlyphID := BigEndianValue.ReadCardinal(Stream);
  end;

  // seek end of this table
  // TODO : Why?
  Stream.Position := StartPos + TableLength;
end;

procedure TPascalTypeFormat12CharacterMap.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeFormat14CharacterMap
//
//------------------------------------------------------------------------------
procedure TPascalTypeFormat14CharacterMap.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFormat14CharacterMap then
  begin
    FVariationSelectors := Copy(TPascalTypeFormat14CharacterMap(Source).FVariationSelectors);
  end;
end;

function TPascalTypeFormat14CharacterMap.CharacterToGlyph(ACodePoint: TPascalTypeCodePoint): Integer;
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

class function TPascalTypeFormat14CharacterMap.GetFormat: Word;
begin
  Result := 14;
end;

procedure TPascalTypeFormat14CharacterMap.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
//  TableLength: Cardinal;
  i, j: integer;
  Offsets: array of record
    DefaultUVSOffset: Cardinal;
    NonDefaultUVSOffset: Cardinal;
  end;
begin
  StartPos := Stream.Position;

  inherited;

  {TableLength := }BigEndianValue.ReadCardinal(Stream);

  SetLength(FVariationSelectors, BigEndianValue.ReadCardinal(Stream));
  SetLength(Offsets, Length(FVariationSelectors));

  for i := 0 to High(FVariationSelectors) do
  begin
    FVariationSelectors[i].VariationSelector := BigEndianValue.ReadUInt24(Stream);

    Offsets[i].DefaultUVSOffset := BigEndianValue.ReadCardinal(Stream);
    Offsets[i].NonDefaultUVSOffset := BigEndianValue.ReadCardinal(Stream);
  end;

  for i := 0 to High(FVariationSelectors) do
  begin
    if (Offsets[i].DefaultUVSOffset <> 0) then
    begin
      Stream.Position := StartPos + Offsets[i].DefaultUVSOffset;

      SetLength(FVariationSelectors[i].DefaultUVS, BigEndianValue.ReadCardinal(Stream));
      for j := 0 to High(FVariationSelectors[i].DefaultUVS) do
      begin
        FVariationSelectors[i].DefaultUVS[j].StartUnicodeValue := BigEndianValue.ReadUInt24(Stream);
        FVariationSelectors[i].DefaultUVS[j].AdditionalCount := BigEndianValue.ReadByte(Stream);
      end;
    end;

    if (Offsets[i].NonDefaultUVSOffset <> 0) then
    begin
      Stream.Position := StartPos + Offsets[i].NonDefaultUVSOffset;

      SetLength(FVariationSelectors[i].NonDefaultUVS, BigEndianValue.ReadCardinal(Stream));
      for j := 0 to High(FVariationSelectors[i].NonDefaultUVS) do
      begin
        FVariationSelectors[i].NonDefaultUVS[j].UnicodeValue := BigEndianValue.ReadUInt24(Stream);
        FVariationSelectors[i].NonDefaultUVS[j].GlyphID := BigEndianValue.ReadWord(Stream);
      end;
    end;
  end;
end;

procedure TPascalTypeFormat14CharacterMap.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

initialization

  PascalTypeCharacterMaps.RegisterCharacterMaps([
    TPascalTypeFormat0CharacterMap, TPascalTypeFormat2CharacterMap, TPascalTypeFormat4CharacterMap,
    TPascalTypeFormat6CharacterMap, TPascalTypeFormat12CharacterMap, TPascalTypeFormat14CharacterMap]);

end.
