unit PascalType.Tables.OpenType.Positioning.Context;

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
  PascalType.Tables.OpenType.Coverage;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableContext
//
//------------------------------------------------------------------------------
// Lookup Type 7: Contextual Positioning Subtables
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-7-contextual-positioning-subtables
//------------------------------------------------------------------------------
type
  TOpenTypePositioningLookupTableContext = class(TCustomOpenTypePositioningLookupTable)
  public type
    TGlyphContextPositioning = (
      gcpInvalid        = 0,
      gcpSimple         = 1,
      gcpClass          = 2,
      gcpCoverage       = 3
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableContextSimple
//
//------------------------------------------------------------------------------
// Context Positioning Subtable Format 1: Simple Glyph Contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#pair-adjustment-positioning-format-1-adjustments-for-glyph-pairs
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableContextSimple = class(TCustomOpenTypePositioningSubTable)
  public type
    TSequenceRule = record
      InputSequence: TGlyphString;
      SequenceLookupRecords: TSequenceLookupRecords;
    end;
    TSequenceRuleSet = TArray<TSequenceRule>;
    TSequenceRuleSets = TArray<TSequenceRuleSet>;
  private
    FSequenceRules: TSequenceRuleSets;
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SequenceRules: TSequenceRuleSets read FSequenceRules write FSequenceRules;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableContextClass
//
//------------------------------------------------------------------------------
// Context Positioning Subtable Format 2: Class-based Glyph Contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#context-positioning-subtable-format-2-class-based-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableContextClass = class(TCustomOpenTypePositioningSubTable)
  public type
    TSequenceRule = record
      InputSequence: TGlyphString;
      SequenceLookupRecords: TSequenceLookupRecords;
    end;
    TSequenceRuleSet = TArray<TSequenceRule>;
    TSequenceRuleSets = TArray<TSequenceRuleSet>;
  private
    FSequenceRules: TSequenceRuleSets;
    FClassDefinitions: TCustomOpenTypeClassDefinitionTable;
  protected
    procedure SetClassDefinitions(const Value: TCustomOpenTypeClassDefinitionTable);
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SequenceRules: TSequenceRuleSets read FSequenceRules write FSequenceRules;
    property ClassDefinitions: TCustomOpenTypeClassDefinitionTable read FClassDefinitions write SetClassDefinitions;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableContextCoverage
//
//------------------------------------------------------------------------------
// Context Positioning Subtable Format 3: Coverage-based Glyph Contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#context-positioning-subtable-format-3-coverage-based-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypePositioningSubTableContextCoverage = class(TCustomOpenTypeLookupSubTable)
  private type
    TCoverageTables = TList<TCustomOpenTypeCoverageTable>;
  private
    FSequenceRules: TCustomOpenTypeLookupSubTable.TSequenceLookupRecords;
    FCoverageTables: TCoverageTables;
  protected
    procedure SetCoverageTables(Value: TCoverageTables);
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SequenceRules: TCustomOpenTypeLookupSubTable.TSequenceLookupRecords read FSequenceRules write FSequenceRules;
    property CoverageTables: TCoverageTables read FCoverageTables write SetCoverageTables;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.Unicode,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypePositioningLookupTableContext
//
//------------------------------------------------------------------------------
function TOpenTypePositioningLookupTableContext.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphContextPositioning(ASubFormat) of

    gcpSimple:
      Result := TOpenTypePositioningSubTableContextSimple;

    gcpClass:
      Result := TOpenTypePositioningSubTableContextClass;

    gcpCoverage:
      Result := TOpenTypePositioningSubTableContextCoverage;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableContextSimple
//
//------------------------------------------------------------------------------
procedure TOpenTypePositioningSubTableContextSimple.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypePositioningSubTableContextSimple then
  begin
    FSequenceRules := Copy(TOpenTypePositioningSubTableContextSimple(Source).FSequenceRules);
  end;
end;

procedure TOpenTypePositioningSubTableContextSimple.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  SavePos: Int64;
  i, j, k: integer;
  SequenceRuleSetOffsets: array of Word;
  SequenceRuleOffsets: array of Word;
  Sequence: TGlyphString;
  SequenceLookupRecords: TSequenceLookupRecords;
begin
  SetLength(FSequenceRules, 0);

  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Read list of sequence rule set offsets
  SetLength(SequenceRuleSetOffsets, BigEndianValue.ReadWord(Stream));
  for i := 0 to High(SequenceRuleSetOffsets) do
    SequenceRuleSetOffsets[i] := BigEndianValue.ReadWord(Stream);

  SavePos := Stream.Position;

  SetLength(FSequenceRules, Length(SequenceRuleSetOffsets));

  // Read a lists of Sequence Rule Sets
  for i := 0 to High(SequenceRuleSetOffsets) do
  begin
    if (SequenceRuleSetOffsets[i] = 0) then
      continue;

    Stream.Position := StartPos + SequenceRuleSetOffsets[i];

    // Read list of offsets to Sequence Rule Sets
    // Offsets are from beginning of the Sequence Rule Set table
    SetLength(SequenceRuleOffsets, BigEndianValue.ReadWord(Stream));
    for j := 0 to High(SequenceRuleOffsets) do
      SequenceRuleOffsets[j] := BigEndianValue.ReadWord(Stream);

    // Read a Sequence Rule Set
    SetLength(FSequenceRules[i], Length(SequenceRuleOffsets));
    for j := 0 to High(SequenceRuleOffsets) do
    begin
      if (SequenceRuleOffsets[j] = 0) then
        continue;

      Stream.Position := StartPos + SequenceRuleSetOffsets[i] + SequenceRuleOffsets[j];

      // Read InputSequence and SequenceLookupRecord lengths
      SetLength(FSequenceRules[i][j].InputSequence, BigEndianValue.ReadWord(Stream));
      SetLength(FSequenceRules[i][j].SequenceLookupRecords, BigEndianValue.ReadWord(Stream));

      // Read InputSequence
      Sequence := FSequenceRules[i][j].InputSequence;
      if (Length(Sequence) > 0) then
      begin
        // First component isn't used
        Sequence[0] := 0;

        // Read remaining from input sequence list
        for k := 1 to High(Sequence) do
          Sequence[k] := BigEndianValue.ReadWord(Stream);
      end;

      // Read SequenceLookupRecords
      SequenceLookupRecords := FSequenceRules[i][j].SequenceLookupRecords;
      for k := 0 to High(SequenceLookupRecords) do
      begin
        SequenceLookupRecords[k].SequenceIndex := BigEndianValue.ReadWord(Stream);
        SequenceLookupRecords[k].LookupListIndex := BigEndianValue.ReadWord(Stream);
      end;
    end;
  end;

  Stream.Position := SavePos;
end;

procedure TOpenTypePositioningSubTableContextSimple.SaveToStream(Stream: TStream);
begin
  // TODO
end;

function TOpenTypePositioningSubTableContextSimple.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  SequenceRuleSetIndex: integer;
  SequenceRuleSet: TSequenceRuleSet;
  i: integer;
begin
  Result := False;

  // The coverage table contains the index of the first character of the sequence.
  SequenceRuleSetIndex := CoverageTable.IndexOfGlyph(AGlyphIterator.Glyph.GlyphID);

  if (SequenceRuleSetIndex = -1) then
    Exit;

  // Sequences are grouped by starting character so all members of a group
  // has the same start character.
  SequenceRuleSet := FSequenceRules[SequenceRuleSetIndex];

  for i := 0 to High(SequenceRuleSet) do
  begin
    // Compare each character in the sequence string to the source string
    // Note: We have already implicitly matched the first character via the
    // coverage table, so we skip that here.
    if (not AGlyphIterator.GlyphString.Match(AGlyphIterator, 1, SequenceRuleSet[i].InputSequence, True)) then
      continue;

    // We have a match. Apply the rules.
    Result := ApplyLookupRecords(AGlyphIterator, SequenceRuleSet[i].SequenceLookupRecords);
    break;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableContextClass
//
//------------------------------------------------------------------------------
procedure TOpenTypePositioningSubTableContextClass.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypePositioningSubTableContextClass then
  begin
    FSequenceRules := Copy(TOpenTypePositioningSubTableContextClass(Source).FSequenceRules);
    // Assignment via property setter makes a copy
    SetClassDefinitions(TOpenTypePositioningSubTableContextClass(Source).FClassDefinitions);
  end;
end;

procedure TOpenTypePositioningSubTableContextClass.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  SavePos: Int64;
  i, j, k: integer;
  SequenceRuleSetOffsets: array of Word;
  SequenceRuleOffsets: array of Word;
  Sequence: TGlyphString;
  SequenceLookupRecords: TSequenceLookupRecords;
  ClassDefOffset: Word;
  ClassDefinitionFormat: TClassDefinitionFormat;
  ClassDefinitionTableClass: TOpenTypeClassDefinitionTableClass;
begin
  // Test font: "Arial Unicode MS"
  SetLength(FSequenceRules, 0);
  FreeAndNil(FClassDefinitions);

  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 2 * SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Get the offset to the class definition table
  ClassDefOffset := BigEndianValue.ReadWord(Stream);

  // Read list of sequence rule set offsets
  SetLength(SequenceRuleSetOffsets, BigEndianValue.ReadWord(Stream));
  for i := 0 to High(SequenceRuleSetOffsets) do
    SequenceRuleSetOffsets[i] := BigEndianValue.ReadWord(Stream);

  SavePos := Stream.Position;

  // Read the class definition tables
  Stream.Position := StartPos + ClassDefOffset;
  ClassDefinitionFormat := TClassDefinitionFormat(BigEndianValue.ReadWord(Stream));

  ClassDefinitionTableClass := TCustomOpenTypeClassDefinitionTable.ClassByFormat(ClassDefinitionFormat);
  if (ClassDefinitionTableClass <> nil) then
  begin
    FClassDefinitions := ClassDefinitionTableClass.Create(Self);

    Stream.Position := StartPos + ClassDefOffset;
    FClassDefinitions.LoadFromStream(Stream);
  end;

  // Read a lists of Sequence Rule Sets
  SetLength(FSequenceRules, Length(SequenceRuleSetOffsets));
  for i := 0 to High(SequenceRuleSetOffsets) do
  begin
    if (SequenceRuleSetOffsets[i] = 0) then
      continue;

    Stream.Position := StartPos + SequenceRuleSetOffsets[i];

    // Read list of offsets to Sequence Rule Sets
    // Offsets are from beginning of the Sequence Rule Set table
    SetLength(SequenceRuleOffsets, BigEndianValue.ReadWord(Stream));
    for j := 0 to High(SequenceRuleOffsets) do
      SequenceRuleOffsets[j] := BigEndianValue.ReadWord(Stream);

    // Read a Sequence Rule Set
    SetLength(FSequenceRules[i], Length(SequenceRuleOffsets));
    for j := 0 to High(SequenceRuleOffsets) do
    begin
      if (SequenceRuleOffsets[j] = 0) then
        continue;

      Stream.Position := StartPos + SequenceRuleSetOffsets[i] + SequenceRuleOffsets[j];

      // Read InputSequence and SequenceLookupRecord lengths
      SetLength(FSequenceRules[i][j].InputSequence, BigEndianValue.ReadWord(Stream));
      SetLength(FSequenceRules[i][j].SequenceLookupRecords, BigEndianValue.ReadWord(Stream));

      // Read InputSequence
      Sequence := FSequenceRules[i][j].InputSequence;
      if (Length(Sequence) > 0) then
      begin
        Sequence[0] := 0;

        // Read remaining from input sequence list
        for k := 1 to High(Sequence) do
          Sequence[k] := BigEndianValue.ReadWord(Stream);
      end;

      Sequence := FSequenceRules[i][j].InputSequence;
      for k := 0 to High(Sequence) do
        Sequence[k] := BigEndianValue.ReadWord(Stream);

      // Read SequenceLookupRecords
      SequenceLookupRecords := FSequenceRules[i][j].SequenceLookupRecords;
      for k := 0 to High(SequenceLookupRecords) do
      begin
        SequenceLookupRecords[k].SequenceIndex := BigEndianValue.ReadWord(Stream);
        SequenceLookupRecords[k].LookupListIndex := BigEndianValue.ReadWord(Stream);
      end;
    end;
  end;

  Stream.Position := SavePos;
end;

procedure TOpenTypePositioningSubTableContextClass.SaveToStream(Stream: TStream);
begin
  // TODO
end;

procedure TOpenTypePositioningSubTableContextClass.SetClassDefinitions(const Value: TCustomOpenTypeClassDefinitionTable);
begin
  FreeAndNil(FClassDefinitions);
  if (Value <> nil) then
  begin
    FClassDefinitions := TOpenTypeClassDefinitionTableClass(Value.ClassType).Create(Self);
    FClassDefinitions.Assign(Value);
  end;
end;

function TOpenTypePositioningSubTableContextClass.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  SequenceRuleSetIndex: integer;
  SequenceRuleSet: TSequenceRuleSet;
  i: integer;
begin
  // Test case: "MS Arial Unicode"
  Result := False;

  // The coverage table contains the index of the first character of the sequence.
  // The index itself isn't used. We just need to determine if we should proceed.
  SequenceRuleSetIndex := CoverageTable.IndexOfGlyph(AGlyphIterator.Glyph.GlyphID);

  if (SequenceRuleSetIndex = -1) then
    Exit;

  // Get the class ID of the first character and use that as an index into the
  // rule set table.
  SequenceRuleSetIndex := FClassDefinitions.ClassByGlyphID(AGlyphIterator.Glyph.GlyphID);

  SequenceRuleSet := FSequenceRules[SequenceRuleSetIndex];
  for i := 0 to High(SequenceRuleSet) do
  begin
    // Compare each character in the sequence string to the source string
    // Note: We have already implicitly matched the first character via the
    // coverage table, so we skip that here.
    if (Length(SequenceRuleSet[i].InputSequence) > 1) then
      if (not AGlyphIterator.GlyphString.Match(AGlyphIterator, 1, SequenceRuleSet[i].InputSequence, FClassDefinitions.ClassByGlyphID, True)) then
        continue;

    // We have a match. Apply the rules.
    Result := ApplyLookupRecords(AGlyphIterator, SequenceRuleSet[i].SequenceLookupRecords);
    break;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypePositioningSubTableContextCoverage
//
//------------------------------------------------------------------------------
constructor TOpenTypePositioningSubTableContextCoverage.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;

  FCoverageTables := TObjectList<TCustomOpenTypeCoverageTable>.Create;
end;

destructor TOpenTypePositioningSubTableContextCoverage.Destroy;
begin
  FCoverageTables.Free;

  inherited;
end;

procedure TOpenTypePositioningSubTableContextCoverage.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypePositioningSubTableContextCoverage then
  begin
    FSequenceRules := Copy(TOpenTypePositioningSubTableContextCoverage(Source).FSequenceRules);
    // Assignment via property setter makes a copy
    SetCoverageTables(TOpenTypePositioningSubTableContextCoverage(Source).FCoverageTables);
  end;
end;

procedure TOpenTypePositioningSubTableContextCoverage.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  i: integer;
  CoverageOffsets: array of Word;
  CoverageTable: TCustomOpenTypeCoverageTable;
begin
  // Test font: None found
  SetLength(FSequenceRules, 0);
  FCoverageTables.Clear;

  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 2 * SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Read coverage table and Sequence Rule counts
  SetLength(CoverageOffsets, BigEndianValue.ReadWord(Stream));
  SetLength(FSequenceRules, BigEndianValue.ReadWord(Stream));

  // Read coverage table offsets
  for i := 0 to High(CoverageOffsets) do
    CoverageOffsets[i] := BigEndianValue.ReadWord(Stream);

  // Read sequence rules
  for i := 0 to High(FSequenceRules) do
  begin
    FSequenceRules[i].SequenceIndex := BigEndianValue.ReadWord(Stream);
    FSequenceRules[i].LookupListIndex := BigEndianValue.ReadWord(Stream);
  end;

  // Read the coverage tables
  FCoverageTables.Capacity := Length(CoverageOffsets);
  for i := 0 to High(CoverageOffsets) do
  begin
    Stream.Position := StartPos + CoverageOffsets[i];
    CoverageTable := TCustomOpenTypeCoverageTable.CreateFromStream(Stream);
    FCoverageTables.Add(CoverageTable);
  end;
end;

procedure TOpenTypePositioningSubTableContextCoverage.SaveToStream(Stream: TStream);
begin
  // TODO
end;

procedure TOpenTypePositioningSubTableContextCoverage.SetCoverageTables(Value: TCoverageTables);
var
  CoverageTable: TCustomOpenTypeCoverageTable;
  NewCoverageTable: TCustomOpenTypeCoverageTable;
begin
  FCoverageTables.Clear;

  if (Value = nil) then
    exit;

  for CoverageTable in Value do
  begin
    NewCoverageTable := CoverageTable.Clone;
    FCoverageTables.Add(NewCoverageTable);
  end;
end;

function TOpenTypePositioningSubTableContextCoverage.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  CoverageIndex: integer;
  i: integer;
  Iterator: TPascalTypeGlyphGlyphIterator;
begin
  Result := False;

  if (AGlyphIterator.Index + FCoverageTables.Count > AGlyphIterator.GlyphString.Count) then
    exit;

  // The string is matched, character by character, against the coverage table.
  // The coverage index itself isn't used. We just need to determine if we should proceed.
  Iterator := AGlyphIterator.Clone;
  for i := 0 to FCoverageTables.Count-1 do
  begin
    if (Iterator.EOF) then
      Exit;

    CoverageIndex := FCoverageTables[i].IndexOfGlyph(Iterator.Glyph.GlyphID);

    if (CoverageIndex = -1) then
      Exit;

    Iterator.Next;
  end;

  // We have a match. Apply the rules.
  Result := ApplyLookupRecords(AGlyphIterator, FSequenceRules);
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypePositioningLookupTable.RegisterPositioningFormat(gpContextPositioning, TOpenTypePositioningLookupTableContext);
end.

