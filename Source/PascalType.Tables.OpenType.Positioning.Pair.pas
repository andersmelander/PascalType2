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
  PT_Types,
  PT_Classes,
  PascalType.GlyphString,
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

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer; ADirection: TPascalTypeDirection): boolean; override;

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

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer; ADirection: TPascalTypeDirection): boolean; override;

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
  PT_ResourceStrings;

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

function TOpenTypePositioningSubTablePairSingle.Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer; ADirection: TPascalTypeDirection): boolean;
var
  CoverageIndex: integer;
  i: integer;
  SecondGlyphID: Word;
begin
  // Test font: "Arial" ("TA "), "Input" ("F_", "_V_")
  if (AIndex >= AGlyphString.Count-1) then
    Exit(False);

  CoverageIndex := CoverageTable.IndexOfGlyph(AGlyphString[AIndex].GlyphID);
  if (CoverageIndex = -1) then
    Exit(False);

  Result := False;

  for i := 0 to High(FPairValues[CoverageIndex]) do
  begin
    SecondGlyphID := FPairValues[CoverageIndex, i].SecondGlyphID;

    if (SecondGlyphID >= AGlyphString[AIndex+1].GlyphID) then
    begin
      if (SecondGlyphID = AGlyphString[AIndex+1].GlyphID) then
      begin
        AGlyphString[AIndex].ApplyPositioning(FPairValues[CoverageIndex, i].FirstValueRecord);
        Inc(AIndex);

        if (not FPairValues[CoverageIndex, i].SecondValueRecord.IsEmpty) then
        begin
          AGlyphString[AIndex].ApplyPositioning(FPairValues[CoverageIndex, i].SecondValueRecord);
          Inc(AIndex);
        end;

        Result := True;
      end;

      break;
    end;
  end;
end;

procedure TOpenTypePositioningSubTablePairSingle.LoadFromStream(Stream: TStream);
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

  ValueFormat1 := BigEndianValueReader.ReadWord(Stream);
  ValueFormat2 := BigEndianValueReader.ReadWord(Stream);

  SetLength(PairSetOffsets, BigEndianValueReader.ReadWord(Stream));

  for i := 0 to High(PairSetOffsets) do
    PairSetOffsets[i] := BigEndianValueReader.ReadWord(Stream);

  SetLength(FPairValues, Length(PairSetOffsets));

  for i := 0 to High(PairSetOffsets) do
  begin
    Stream.Position := StartPos + PairSetOffsets[i];

    SetLength(FPairValues[i], BigEndianValueReader.ReadWord(Stream));

    for j := 0 to High(FPairValues[i]) do
    begin
      FPairValues[i, j].SecondGlyphID := BigEndianValueReader.ReadWord(Stream);
      LoadValueRecordFromStream(Stream, FPairValues[i, j].FirstValueRecord, ValueFormat1);
      LoadValueRecordFromStream(Stream, FPairValues[i, j].SecondValueRecord, ValueFormat2);
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
      CreateValueFormat(FPairValues[i, j].FirstValueRecord, ValueFormat);
      ValueFormat1 := ValueFormat1 or ValueFormat;

      CreateValueFormat(FPairValues[i, j].SecondValueRecord, ValueFormat);
      ValueFormat2 := ValueFormat2 or ValueFormat;
    end;
  WriteSwappedWord(Stream, ValueFormat1);
  WriteSwappedWord(Stream, ValueFormat2);

  SetLength(PairSetOffsets, Length(FPairValues));
  WriteSwappedWord(Stream, Length(PairSetOffsets));

  OffsetPos := Stream.Position;
  Stream.Position := Stream.Position + Length(PairSetOffsets) * SizeOf(Word);

  for i := 0 to High(PairSetOffsets) do
  begin
    PairSetOffsets[i] := Stream.Position - StartPos;

    WriteSwappedWord(Stream, Length(FPairValues[i]));

    for j := 0 to High(FPairValues[i]) do
    begin
      WriteSwappedWord(Stream, FPairValues[i, j].SecondGlyphID);
      SaveValueRecordToStream(Stream, FPairValues[i, j].FirstValueRecord, ValueFormat1);
      SaveValueRecordToStream(Stream, FPairValues[i, j].SecondValueRecord, ValueFormat2);
    end;
  end;

  SavePos := Stream.Position;
  Stream.Position := OffsetPos;
  for i := 0 to High(PairSetOffsets) do
    WriteSwappedWord(Stream, PairSetOffsets[i]);
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

function TOpenTypePositioningSubTablePairClass.Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer; ADirection: TPascalTypeDirection): boolean;
var
  CoverageIndex: integer;
  FirstClassID, SecondClassID: integer;
  ClassValueRecord: TClassValueRecord;
begin
  // Test font: "Input" (all matches does nothing...), "Roboto Regular" ("P,", "PA", "?m" (Greek Capital Letter Gamma, m))
  if (AIndex >= AGlyphString.Count-1) then
    Exit(False);

  CoverageIndex := CoverageTable.IndexOfGlyph(AGlyphString[AIndex].GlyphID);
  if (CoverageIndex = -1) then
    Exit(False);

  FirstClassID := FFirstClassDefinitions.ClassByGlyphID(AGlyphString[AIndex].GlyphID);
  SecondClassID := FSecondClassDefinitions.ClassByGlyphID(AGlyphString[AIndex+1].GlyphID);

  ClassValueRecord := FClassValueRecords[FirstClassID, SecondClassID];

  // TODO : I can't find any criteria documented besides the coverage table, so this is a guess:
  if (ClassValueRecord.FirstValueRecord.IsEmpty) and (ClassValueRecord.SecondValueRecord.IsEmpty) then
    Exit(False);

  AGlyphString[AIndex].ApplyPositioning(ClassValueRecord.FirstValueRecord);
  Inc(AIndex);

  if (not ClassValueRecord.SecondValueRecord.IsEmpty) then
  begin
    AGlyphString[AIndex].ApplyPositioning(ClassValueRecord.SecondValueRecord);
    Inc(AIndex);
  end;

  Result := True;
end;

procedure TOpenTypePositioningSubTablePairClass.LoadFromStream(Stream: TStream);
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
  ValueFormat1 := BigEndianValueReader.ReadWord(Stream);
  ValueFormat2 := BigEndianValueReader.ReadWord(Stream);

  FirstClassDefOffset := StartPos + BigEndianValueReader.ReadWord(Stream);
  SecondClassDefOffset := StartPos + BigEndianValueReader.ReadWord(Stream);

  Class1Count := BigEndianValueReader.ReadWord(Stream);
  Class2Count := BigEndianValueReader.ReadWord(Stream);

  SetLength(FClassValueRecords, Class1Count);
  for i := 0 to High(FClassValueRecords) do
  begin
    SetLength(FClassValueRecords[i], Class2Count);

    for j := 0 to High(FClassValueRecords[i]) do
    begin
      LoadValueRecordFromStream(Stream, FClassValueRecords[i, j].FirstValueRecord, ValueFormat1);
      LoadValueRecordFromStream(Stream, FClassValueRecords[i, j].SecondValueRecord, ValueFormat2);
    end;
  end;

  if (Class1Count > 0) then
  begin
    Stream.Position := FirstClassDefOffset;
    ClassDefinitionFormat := TClassDefinitionFormat(BigEndianValueReader.ReadWord(Stream));

    ClassDefinitionTableClass := TCustomOpenTypeClassDefinitionTable.ClassByFormat(ClassDefinitionFormat);
    if (ClassDefinitionTableClass <> nil) then
    begin
      FFirstClassDefinitions := ClassDefinitionTableClass.Create(Self);

      Stream.Position := FirstClassDefOffset;
      FFirstClassDefinitions.LoadFromStream(Stream);
    end;
  end;

  if (Class2Count > 0) then
  begin
    Stream.Position := SecondClassDefOffset;
    ClassDefinitionFormat := TClassDefinitionFormat(BigEndianValueReader.ReadWord(Stream));

    ClassDefinitionTableClass := TCustomOpenTypeClassDefinitionTable.ClassByFormat(ClassDefinitionFormat);
    if (ClassDefinitionTableClass <> nil) then
    begin
      FSecondClassDefinitions := ClassDefinitionTableClass.Create(Self);

      Stream.Position := SecondClassDefOffset;
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

