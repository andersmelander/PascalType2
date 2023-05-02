unit PT_CharacterMap;

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
  Classes, SysUtils, PT_Types, PT_Classes, PT_Tables;

type
  TPascalTypeFormat0CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLength: Word; // This is the length in bytes of the subtable.
    FLanguage: Word; // Please see 'Note on the language field in 'cmap' subtables' in this document.
    FGlyphIdArray: array [0..255] of Byte; // An array that maps character codes to glyph index values.
  protected
    class function GetFormat: Word; override;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(CharacterIndex: Integer): Integer; override;
  end;

  TPascalTypeFormat2CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLength: Word; // This is the length in bytes of the subtable.
    FLanguage: Word; // Please see 'Note on the language field in 'cmap' subtables' in this document.
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(CharacterIndex: Integer): Integer; override;
  end;

  // https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#format-4-segment-mapping-to-delta-values
  TPascalTypeFormat4CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLength: Word;                    // This is the length in bytes of the subtable.
    FLanguage: Word;                  // Please see 'Note on the language field in 'cmap' subtables' in this document.
    FSegCountX2: Word;                // 2 x segCount.
    FSearchRange: Word;               // 2 x (2**floor(log2(segCount)))
    FEntrySelector: Word;             // log2(searchRange / 2)
    FRangeShift: Word;                // 2 x segCount - searchRange
    FEndCount: array of Word;         // End characterCode for each segment, last=0xFFFF.
    FStartCount: array of Word;       // Start character code for each segment.
    FIdDelta: array of SmallInt;      // Delta for all character codes in segment.
    FIdRangeOffset: array of Word;    // Offsets into glyphIdArray or 0
    FGlyphIdArray: array of Word;     // Glyph index array (arbitrary length)  protected
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(CharacterIndex: Integer): Integer; override;
  end;

  // https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#format-6-trimmed-table-mapping
  TPascalTypeFormat6CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLanguage: Word;              // Please see �Note on the language field in 'cmap' subtables� in this document.
    FFirstCode: Word;             // First character code of subrange.
    FGlyphIdArray: array of Word; // Array of glyph index values for character codes in the range.
    function GetEntryCount: Word;
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(CharacterIndex: Integer): Integer; override;

    property EntryCount: Word read GetEntryCount;
  end;

  TCharMapSegmentedCoverageRecord = packed record
    StartCharCode: Cardinal; // First character code in this group
    EndCharCode: Cardinal;   // Last character code in this group
    StartGlyphID: Cardinal;  // Glyph index corresponding to the starting character code
  end;

  TPascalTypeFormat12CharacterMap = class(TCustomPascalTypeCharacterMap)
  private
    FLanguage: Cardinal; // Please see �Note on the language field in 'cmap' subtables� in this document.
    FCoverageArray: array of TCharMapSegmentedCoverageRecord;
  protected
    class function GetFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function CharacterToGlyph(CharacterIndex: Integer): Integer; override;
  end;

implementation

uses
  Math,
  PT_Math,
  PT_ResourceStrings;


{ TPascalTypeFormat0CharacterMap }

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

procedure TPascalTypeFormat0CharacterMap.LoadFromStream(Stream: TStream);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read length
  FLength := ReadSwappedWord(Stream);

  // read language
  FLanguage := ReadSwappedWord(Stream);

  Stream.Read(FGlyphIdArray[0], 256);
end;

procedure TPascalTypeFormat0CharacterMap.SaveToStream(Stream: TStream);
begin
  // write length
  WriteSwappedWord(Stream, FLength);

  // write language
  WriteSwappedWord(Stream, FLanguage);

  Stream.Write(FGlyphIdArray[0], 256);
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

function TPascalTypeFormat0CharacterMap.CharacterToGlyph(CharacterIndex: Integer): Integer;
begin
  if CharacterIndex in [0..255] then
    Result := FGlyphIdArray[CharacterIndex]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [CharacterIndex]);
end;


{ TPascalTypeFormat2CharacterMap }

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

function TPascalTypeFormat2CharacterMap.CharacterToGlyph(CharacterIndex: Integer): Integer;
begin
  Result := CharacterIndex;
end;

procedure TPascalTypeFormat2CharacterMap.LoadFromStream(Stream: TStream);
begin
  // check (minimum) table size
  if Stream.Position + 2*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read length
  FLength := ReadSwappedWord(Stream);

  // read language
  FLanguage := ReadSwappedWord(Stream);
end;

procedure TPascalTypeFormat2CharacterMap.SaveToStream(Stream: TStream);
begin
  // write length
  WriteSwappedWord(Stream, FLength);

  // write language
  WriteSwappedWord(Stream, FLanguage);
end;


{ TPascalTypeFormat4CharacterMap }

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
    FSegCountX2 := TPascalTypeFormat4CharacterMap(Source).FSegCountX2;
    FSearchRange := TPascalTypeFormat4CharacterMap(Source).FSearchRange;
    FEntrySelector := TPascalTypeFormat4CharacterMap(Source).FEntrySelector;
    FRangeShift := TPascalTypeFormat4CharacterMap(Source).FRangeShift;
    FEndCount := TPascalTypeFormat4CharacterMap(Source).FEndCount;
    FStartCount := TPascalTypeFormat4CharacterMap(Source).FStartCount;
    FIdDelta := TPascalTypeFormat4CharacterMap(Source).FIdDelta;
    FIdRangeOffset := TPascalTypeFormat4CharacterMap(Source).FIdRangeOffset;
    FGlyphIdArray := TPascalTypeFormat4CharacterMap(Source).FGlyphIdArray;
  end;
end;

function TPascalTypeFormat4CharacterMap.CharacterToGlyph(CharacterIndex: Integer): Integer;
var
  SegmentIndex: Integer;
begin
  SegmentIndex := 0;
  while (SegmentIndex < Length(FEndCount)) do
    if (CharacterIndex <= FEndCount[SegmentIndex]) then
      Break
    else
      Inc(SegmentIndex);

  if (CharacterIndex < FStartCount[SegmentIndex]) then
  begin
    // missing glyph
    Result := 0;
    Exit;
  end;

  if FIdRangeOffset[SegmentIndex] = 0 then
  begin
    Result := (FIdDelta[SegmentIndex] + CharacterIndex) and $0000FFFF;
  end else
  begin
    (*
    ** Issue #5: The following maps to the wrong GlypgID

    Result := (FIdRangeOffset[SegmentIndex] + (CharacterIndex - FStartCount[SegmentIndex])) and $0000FFFF;

    ** but this works:

    Result := FGlyphIdArray[(CharacterIndex - FStartCount[SegmentIndex]) and $0000FFFF];

    *)
    // TODO : This doesn't work with "Input", small letter "a"
    Result := FGlyphIdArray[(CharacterIndex - FStartCount[SegmentIndex]) and $0000FFFF];

    // check for missing character and add offset eventually
    (*
    ** The following has been disabled as I cannot find rationale for it in the
    ** documentation:

    if Result = 0 then
      Result := FIdDelta[SegmentIndex] and $0000FFFF;

    *)
  end;
end;

procedure TPascalTypeFormat4CharacterMap.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  SegIndex: Integer;
{$IFDEF AmbigiousExceptions}
  Value16: Word;
{$ENDIF}
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 2*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read length
  FLength := ReadSwappedWord(Stream);

  // check (minimum) table size
  if StartPos + FLength > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read language
  FLanguage := ReadSwappedWord(Stream);

  // read segCountX2
  FSegCountX2 := ReadSwappedWord(Stream);

  // read search range
  FSearchRange := ReadSwappedWord(Stream);

  // confirm search range has a valid value
  if FSearchRange <> 2 * (1 shl FloorLog2(FSegCountX2 div 2)) then
    raise EPascalTypeError.Create(RCStrCharMapError + ': ' + 'wrong search range!');

  // read entry selector
  FEntrySelector := ReadSwappedWord(Stream);

  // confirm entry selector has a valid value
  if 2 shl FEntrySelector <> FSearchRange then
    raise EPascalTypeError.Create(RCStrCharMapError + ': ' + 'wrong entry selector!');

  // read range shift
  FRangeShift := ReadSwappedWord(Stream);

{$IFDEF AmbigiousExceptions}
  // confirm range shift has a valid value
  if FRangeShift <> FSegCountX2 - FSearchRange then
    raise EPascalTypeError.Create(RCStrCharMapError + ': ' + 'wrong range shift!');
{$ENDIF}

  SetLength(FEndCount, FSegCountX2 div 2);
  SetLength(FStartCount, FSegCountX2 div 2);
  SetLength(FIdDelta, FSegCountX2 div 2);
  SetLength(FIdRangeOffset, FSegCountX2 div 2);

  // read end count
  for SegIndex := 0 to High(FEndCount) do
    FEndCount[SegIndex] := ReadSwappedWord(Stream);

  // confirm end count is valid
  if FEndCount[High(FEndCount)] <> $FFFF then
    raise EPascalTypeError.CreateFmt(RCStrCharMapErrorEndCount, [FEndCount[High(FEndCount)]]);

{$IFDEF AmbigiousExceptions}
  // read reserved
  Value16 := ReadSwappedWord(Stream);

  // confirm reserved value is valid
  if Value16 <> 0 then
    raise EPascalTypeError.CreateFmt(RCStrCharMapErrorReserved, [Value16]);
{$ELSE}
  // skip reserved
  Stream.Seek(2, soFromCurrent);
{$ENDIF}

  // read start count
  for SegIndex := 0 to High(FStartCount) do
  begin
    FStartCount[SegIndex] := ReadSwappedWord(Stream);

{$IFDEF AmbigiousExceptions}
    // confirm start count is valid
    if FStartCount[SegIndex] > FEndCount[SegIndex] then
      raise EPascalTypeError.CreateFmt(RCStrCharMapErrorStartCount, [FStartCount[SegIndex]]);
{$ENDIF}
  end;

  // read ID delta
  for SegIndex := 0 to High(FIdDelta) do
    Word(FIdDelta[SegIndex]) := ReadSwappedWord(Stream);

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
    FIdRangeOffset[SegIndex] := ReadSwappedWord(Stream);

  SetLength(FGlyphIdArray, (FLength - (Stream.Position - StartPos)) div SizeOf(Word));

  // read glyph ID array
  for SegIndex := 0 to High(FGlyphIdArray) do
    FGlyphIdArray[SegIndex] := ReadSwappedWord(Stream);
end;

procedure TPascalTypeFormat4CharacterMap.SaveToStream(Stream: TStream);
begin
  // write length
  WriteSwappedWord(Stream, FLength);

  // write language
  WriteSwappedWord(Stream, FLanguage);

  // TODO : ...
end;


{ TPascalTypeFormat6CharacterMap }

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

function TPascalTypeFormat6CharacterMap.CharacterToGlyph(CharacterIndex: Integer): Integer;
begin
  Result := 0;
  if CharacterIndex >= FFirstCode then
    if CharacterIndex < FFirstCode + Length(FGlyphIdArray) then
      Result := FGlyphIdArray[CharacterIndex - FFirstCode];
end;

function TPascalTypeFormat6CharacterMap.GetEntryCount: Word;
begin
  Result := Length(FGlyphIdArray);
end;

class function TPascalTypeFormat6CharacterMap.GetFormat: Word;
begin
  Result := 6
end;

procedure TPascalTypeFormat6CharacterMap.LoadFromStream(Stream: TStream);
var
  EntryIndex: Integer;
  TableLength: Word;
begin
  inherited;

  // read table size
  TableLength := ReadSwappedWord(Stream);

  // read language
  FLanguage := ReadSwappedWord(Stream);

  // read first code
  FFirstCode := ReadSwappedWord(Stream);

  // read number of character codes in subrange
  SetLength(FGlyphIdArray, ReadSwappedWord(Stream));

  for EntryIndex := 0 to High(FGlyphIdArray) do
    FGlyphIdArray[EntryIndex] := ReadSwappedWord(Stream);
end;

procedure TPascalTypeFormat6CharacterMap.SaveToStream(Stream: TStream);
var
  EntryIndex: Integer;
begin
  inherited;

  // write table size
  WriteSwappedWord(Stream, 8 + 2 * Length(FGlyphIdArray));

  // write language
  WriteSwappedWord(Stream, FLanguage);

  // write first code
  WriteSwappedWord(Stream, FFirstCode);

  // write number of character codes in subrange
  WriteSwappedWord(Stream, Length(FGlyphIdArray));

  // write glyph indices
  for EntryIndex := 0 to High(FGlyphIdArray) do
    WriteSwappedWord(Stream, FGlyphIdArray[EntryIndex]);
end;


{ TPascalTypeFormat12CharacterMap }

procedure TPascalTypeFormat12CharacterMap.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFormat12CharacterMap then
  begin
    FLanguage := TPascalTypeFormat12CharacterMap(Source).FLanguage;
    FCoverageArray := TPascalTypeFormat12CharacterMap(Source).FCoverageArray;
  end;
end;

function TPascalTypeFormat12CharacterMap.CharacterToGlyph(CharacterIndex: Integer): Integer;
var
  GroupIndex: Integer;
begin
  Result := 0;
  GroupIndex := 0;

  while GroupIndex < Length(FCoverageArray) do
    with FCoverageArray[GroupIndex] do
    begin
      if CharacterIndex >= Integer(StartCharCode) then
      begin
        if CharacterIndex < Integer(EndCharCode) then
          Result := Integer(StartGlyphID) +
            (CharacterIndex - Integer(StartCharCode));

        Exit;
      end;
      Inc(GroupIndex);
    end;
end;

class function TPascalTypeFormat12CharacterMap.GetFormat: Word;
begin
  Result := 12;
end;

procedure TPascalTypeFormat12CharacterMap.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  TableLength: Cardinal;
  GroupIndex: Cardinal;
begin
  StartPos := Stream.Position;

  inherited;

{$IFDEF AmbigiousExceptions}
  if ReadSwappedWord(Stream) <> 0 then
    raise EPascalTypeError.Create(RCStrReservedValueError);
{$ELSE}
  Stream.Seek(2, soFromCurrent);
{$ENDIF}
  // read table length
  TableLength := ReadSwappedCardinal(Stream);

  // read language
  FLanguage := ReadSwappedCardinal(Stream);

  // read group count
  SetLength(FCoverageArray, ReadSwappedCardinal(Stream));

  for GroupIndex := 0 to High(FCoverageArray) do
    with FCoverageArray[GroupIndex] do
    begin
      // read start character code
      StartCharCode := ReadSwappedCardinal(Stream);

      // read end character code
      EndCharCode := ReadSwappedCardinal(Stream);

      // read start glyph ID
      StartGlyphID := ReadSwappedCardinal(Stream);
    end;

  // seek end of this table
  // TODO : Why?
  Stream.Position := StartPos + TableLength;
end;

procedure TPascalTypeFormat12CharacterMap.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

initialization

RegisterPascalTypeCharacterMaps([TPascalTypeFormat0CharacterMap,
  TPascalTypeFormat2CharacterMap, TPascalTypeFormat4CharacterMap,
  TPascalTypeFormat6CharacterMap, TPascalTypeFormat12CharacterMap]);

end.
