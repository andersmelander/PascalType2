unit PascalType.Tables.OpenType.Positioning.Pair;

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
  PascalType.Tables.OpenType.Common.ValueRecord,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Positioning,
  PascalType.Tables.OpenType.ClassDefinition;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTablePair
//
//------------------------------------------------------------------------------
// Lookup Type 2: Pair Adjustment Positioning Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-2-pair-adjustment-positioning-subtable
//------------------------------------------------------------------------------
type
  TOpenTypePositioningLookupTablePair = class(TCustomOpenTypePositioningLookupTable)
  public type
    TGlyphPairPositioning = (
      gppInvalid        = 0,
      gppSingle         = 1,
      gppClass          = 2
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTablePairSingle
//
//------------------------------------------------------------------------------
// Pair Adjustment Positioning Format 1: Adjustments for Glyph Pairs
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#pair-adjustment-positioning-format-1-adjustments-for-glyph-pairs
//------------------------------------------------------------------------------
type
  TPairValueRecord = record
    SecondGlyphID: Word;
    FirstValueRecord: TOpenTypeValueRecord;
    SecondValueRecord: TOpenTypeValueRecord;
  end;

  TOpenTypePositioningSubTablePairSingle = class(TCustomOpenTypePositioningSubTable)
  private type
    TPairValues = array of array of TPairValueRecord;
  private
    FPairValues: TPairValues;
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property PairValues: TPairValues read FPairValues write FPairValues;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTablePairClass
//
//------------------------------------------------------------------------------
// Pair Adjustment Positioning Format 2: Class Pair Adjustment
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#pair-adjustment-positioning-format-2-class-pair-adjustment
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTablePairClass = class(TCustomOpenTypePositioningSubTable)
  public type
    TClassValueRecord = record
      FirstValueRecord: TOpenTypeValueRecord;
      SecondValueRecord: TOpenTypeValueRecord;
    end;
  private type
    TClassValueRecords = array of array of TClassValueRecord;
  private
    FFirstClassDefinitions: TCustomOpenTypeClassDefinitionTable;
    FSecondClassDefinitions: TCustomOpenTypeClassDefinitionTable;
    FClassValueRecords: TClassValueRecords;
    procedure SetFirstClassDefinitions(const Value: TCustomOpenTypeClassDefinitionTable);
    procedure SetSecondClassDefinitions(const Value: TCustomOpenTypeClassDefinitionTable);
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property FirstClassDefinitions: TCustomOpenTypeClassDefinitionTable read FFirstClassDefinitions write SetFirstClassDefinitions;
    property SecondClassDefinitions: TCustomOpenTypeClassDefinitionTable read FSecondClassDefinitions write SetSecondClassDefinitions;
    property ClassValueRecords: TClassValueRecords read FClassValueRecords write FClassValueRecords;
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
//              TOpenTypePositioningLookupTablePair
//
//------------------------------------------------------------------------------
function TOpenTypePositioningLookupTablePair.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphPairPositioning(ASubFormat) of

    gppSingle:
      Result := TOpenTypePositioningSubTablePairSingle;

    gppClass:
      Result := TOpenTypePositioningSubTablePairClass;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTablePairSingle
//
//------------------------------------------------------------------------------
procedure TOpenTypePositioningSubTablePairSingle.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypePositioningSubTablePairSingle then
    FPairValues := TOpenTypePositioningSubTablePairSingle(Source).PairValues;
end;

function TOpenTypePositioningSubTablePairSingle.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  CoverageIndex: integer;
  i: integer;
  SecondGlyphID: Word;
  SecondGlyph: TPascalTypeGlyph;
begin
  Result := False;

  if (AGlyphIterator.Index >= AGlyphIterator.GlyphString.Count-1) then
    Exit;

  CoverageIndex := CoverageTable.IndexOfGlyph(AGlyphIterator.Glyph.GlyphID);
  if (CoverageIndex = -1) then
    Exit;

  SecondGlyph := AGlyphIterator.PeekGlyph;
  if (SecondGlyph = nil) then
    Exit;

  for i := 0 to High(FPairValues[CoverageIndex]) do
  begin
    SecondGlyphID := FPairValues[CoverageIndex, i].SecondGlyphID;

    if (SecondGlyphID >= SecondGlyph.GlyphID) then
    begin
      if (SecondGlyphID = SecondGlyph.GlyphID) then
      begin
        AGlyphIterator.Glyph.ApplyPositioning(FPairValues[CoverageIndex, i].FirstValueRecord);
{$ifdef ApplyIncrements}
        AGlyphIterator.Next;
{$endif ApplyIncrements}

        if (not FPairValues[CoverageIndex, i].SecondValueRecord.IsEmpty) then
        begin
          SecondGlyph.ApplyPositioning(FPairValues[CoverageIndex, i].SecondValueRecord);
{$ifdef ApplyIncrements}
          AGlyphIterator.Next;
{$endif ApplyIncrements}
        end;

        Result := True;
      end;

      break;
    end;
  end;
end;

procedure TOpenTypePositioningSubTablePairSingle.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  ValueFormat1: Word;
  ValueFormat2: Word;
  PairSetOffsets: array of Word;
  i, j: integer;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  ValueFormat1 := BigEndianValue.ReadWord(Stream);
  ValueFormat2 := BigEndianValue.ReadWord(Stream);

  SetLength(PairSetOffsets, BigEndianValue.ReadWord(Stream));

  for i := 0 to High(PairSetOffsets) do
    PairSetOffsets[i] := BigEndianValue.ReadWord(Stream);

  SetLength(FPairValues, Length(PairSetOffsets));

  for i := 0 to High(PairSetOffsets) do
  begin
    Stream.Position := StartPos + PairSetOffsets[i];

    SetLength(FPairValues[i], BigEndianValue.ReadWord(Stream));

    for j := 0 to High(FPairValues[i]) do
    begin
      FPairValues[i, j].SecondGlyphID := BigEndianValue.ReadWord(Stream);
      FPairValues[i, j].FirstValueRecord.LoadFromStream(Stream, ValueFormat1);
      FPairValues[i, j].SecondValueRecord.LoadFromStream(Stream, ValueFormat2);
    end;
  end;
end;

procedure TOpenTypePositioningSubTablePairSingle.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
  OffsetPos: Int64;
  SavePos: Int64;
  ValueFormat: Word;
  ValueFormat1: Word;
  ValueFormat2: Word;
  PairSetOffsets: array of Word;
  i, j: integer;
begin
  StartPos := Stream.Position;

  inherited;

  ValueFormat1 := 0;
  ValueFormat2 := 0;
  for i := 0 to High(FPairValues) do
    for j := 0 to High(FPairValues[i]) do
    begin
      FPairValues[i, j].FirstValueRecord.BuildValueFormat(ValueFormat);
      ValueFormat1 := ValueFormat1 or ValueFormat;

      FPairValues[i, j].SecondValueRecord.BuildValueFormat(ValueFormat);
      ValueFormat2 := ValueFormat2 or ValueFormat;
    end;
  BigEndianValue.WriteWord(Stream, ValueFormat1);
  BigEndianValue.WriteWord(Stream, ValueFormat2);

  SetLength(PairSetOffsets, Length(FPairValues));
  BigEndianValue.WriteWord(Stream, Length(PairSetOffsets));

  OffsetPos := Stream.Position;
  Stream.Position := Stream.Position + Length(PairSetOffsets) * SizeOf(Word);

  for i := 0 to High(PairSetOffsets) do
  begin
    PairSetOffsets[i] := Stream.Position - StartPos;

    BigEndianValue.WriteWord(Stream, Length(FPairValues[i]));

    for j := 0 to High(FPairValues[i]) do
    begin
      BigEndianValue.WriteWord(Stream, FPairValues[i, j].SecondGlyphID);
      FPairValues[i, j].FirstValueRecord.SaveToStream(Stream, ValueFormat1);
      FPairValues[i, j].SecondValueRecord.SaveToStream(Stream, ValueFormat2);
    end;
  end;

  SavePos := Stream.Position;
  Stream.Position := OffsetPos;
  for i := 0 to High(PairSetOffsets) do
    BigEndianValue.WriteWord(Stream, PairSetOffsets[i]);
  Stream.Position := SavePos;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTablePairClass
//
//------------------------------------------------------------------------------
constructor TOpenTypePositioningSubTablePairClass.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;

end;

destructor TOpenTypePositioningSubTablePairClass.Destroy;
begin
  FFirstClassDefinitions.Free;
  FSecondClassDefinitions.Free;

  inherited;
end;

procedure TOpenTypePositioningSubTablePairClass.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypePositioningSubTablePairClass then
  begin
    FClassValueRecords := TOpenTypePositioningSubTablePairClass(Source).ClassValueRecords;

    // Assignment via property setter makes a copy
    FirstClassDefinitions := TOpenTypePositioningSubTablePairClass(Source).FirstClassDefinitions;
    SecondClassDefinitions := TOpenTypePositioningSubTablePairClass(Source).SecondClassDefinitions;
  end;
end;

function TOpenTypePositioningSubTablePairClass.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  CoverageIndex: integer;
  FirstClassID, SecondClassID: integer;
  ClassValueRecord: TClassValueRecord;
  SecondGlyph: TPascalTypeGlyph;
begin
  Result := False;

  if (AGlyphIterator.Index >= AGlyphIterator.GlyphString.Count-1) then
    Exit;

  CoverageIndex := CoverageTable.IndexOfGlyph(AGlyphIterator.Glyph.GlyphID);
  if (CoverageIndex = -1) then
    Exit;

  FirstClassID := FFirstClassDefinitions.ClassByGlyphID(AGlyphIterator.Glyph.GlyphID);

  SecondGlyph := AGlyphIterator.PeekGlyph;
  if (SecondGlyph = nil) then
    Exit;
  SecondClassID := FSecondClassDefinitions.ClassByGlyphID(SecondGlyph.GlyphID);

  ClassValueRecord := FClassValueRecords[FirstClassID, SecondClassID];

  // TODO : I can't find any criteria documented besides the coverage table, so this is a guess:
  if (ClassValueRecord.FirstValueRecord.IsEmpty) and (ClassValueRecord.SecondValueRecord.IsEmpty) then
    Exit(False);

  AGlyphIterator.Glyph.ApplyPositioning(ClassValueRecord.FirstValueRecord);
{$ifdef ApplyIncrements}
  AGlyphIterator.Next;
{$endif ApplyIncrements}

  if (not ClassValueRecord.SecondValueRecord.IsEmpty) then
  begin
    SecondGlyph.ApplyPositioning(ClassValueRecord.SecondValueRecord);
{$ifdef ApplyIncrements}
    AGlyphIterator.Next;
{$endif ApplyIncrements}
  end;

  Result := True;
end;

procedure TOpenTypePositioningSubTablePairClass.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  ValueFormat1: Word;
  ValueFormat2: Word;
  FirstClassDefOffset: Word;
  SecondClassDefOffset: Word;
  Class1Count: Word;
  Class2Count: Word;
  i, j: integer;
  ClassDefinitionFormat: TClassDefinitionFormat;
  ClassDefinitionTableClass: TOpenTypeClassDefinitionTableClass;
begin
  StartPos := Stream.Position;

  FreeAndNil(FFirstClassDefinitions);
  FreeAndNil(FSecondClassDefinitions);

  inherited;

  // check (minimum) table size
  if Stream.Position + 12 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // TODO : Possibly surface these as properties
  ValueFormat1 := BigEndianValue.ReadWord(Stream);
  ValueFormat2 := BigEndianValue.ReadWord(Stream);

  FirstClassDefOffset := BigEndianValue.ReadWord(Stream);
  SecondClassDefOffset := BigEndianValue.ReadWord(Stream);

  Class1Count := BigEndianValue.ReadWord(Stream);
  Class2Count := BigEndianValue.ReadWord(Stream);

  SetLength(FClassValueRecords, Class1Count);
  for i := 0 to High(FClassValueRecords) do
  begin
    SetLength(FClassValueRecords[i], Class2Count);

    for j := 0 to High(FClassValueRecords[i]) do
    begin
      FClassValueRecords[i, j].FirstValueRecord.LoadFromStream(Stream, ValueFormat1);
      FClassValueRecords[i, j].SecondValueRecord.LoadFromStream(Stream, ValueFormat2);
    end;
  end;

  if (Class1Count > 0) then
  begin
    Stream.Position := StartPos + FirstClassDefOffset;
    ClassDefinitionFormat := TClassDefinitionFormat(BigEndianValue.ReadWord(Stream));

    ClassDefinitionTableClass := TCustomOpenTypeClassDefinitionTable.ClassByFormat(ClassDefinitionFormat);
    if (ClassDefinitionTableClass <> nil) then
    begin
      FFirstClassDefinitions := ClassDefinitionTableClass.Create(Self);

      Stream.Position := StartPos + FirstClassDefOffset;
      FFirstClassDefinitions.LoadFromStream(Stream);
    end;
  end;

  if (Class2Count > 0) then
  begin
    Stream.Position := StartPos + SecondClassDefOffset;
    ClassDefinitionFormat := TClassDefinitionFormat(BigEndianValue.ReadWord(Stream));

    ClassDefinitionTableClass := TCustomOpenTypeClassDefinitionTable.ClassByFormat(ClassDefinitionFormat);
    if (ClassDefinitionTableClass <> nil) then
    begin
      FSecondClassDefinitions := ClassDefinitionTableClass.Create(Self);

      Stream.Position := StartPos + SecondClassDefOffset;
      FSecondClassDefinitions.LoadFromStream(Stream);
    end;
  end;
end;

procedure TOpenTypePositioningSubTablePairClass.SaveToStream(Stream: TStream);
begin
  inherited;
  // TODO
end;

procedure TOpenTypePositioningSubTablePairClass.SetFirstClassDefinitions(const Value: TCustomOpenTypeClassDefinitionTable);
begin
  FreeAndNil(FFirstClassDefinitions);
  if (Value <> nil) then
  begin
    FFirstClassDefinitions := TOpenTypeClassDefinitionTableClass(Value.ClassType).Create(Self);
    FFirstClassDefinitions.Assign(Value);
  end;
end;

procedure TOpenTypePositioningSubTablePairClass.SetSecondClassDefinitions(const Value: TCustomOpenTypeClassDefinitionTable);
begin
  FreeAndNil(FSecondClassDefinitions);
  if (Value <> nil) then
  begin
    FSecondClassDefinitions := TOpenTypeClassDefinitionTableClass(Value.ClassType).Create(Self);
    FSecondClassDefinitions.Assign(Value);
  end;
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpPairAdjustment, TOpenTypePositioningLookupTablePair);
end.

