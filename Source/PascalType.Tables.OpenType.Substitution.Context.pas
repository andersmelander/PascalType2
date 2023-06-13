unit PascalType.Tables.OpenType.Substitution.Context;

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
  PT_Classes,
  PT_Types,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Substitution,
  PascalType.Tables.OpenType.ClassDefinition,
  PascalType.Tables.OpenType.Coverage;

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionLookupTableContext
//
//------------------------------------------------------------------------------
// LookupType 5: Contextual Substitution Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#lookuptype-5-contextual-substitution-subtable
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionLookupTableContext = class(TCustomOpenTypeSubstitutionLookupTable)
  public type
    TGlyphContextSubstitution = (
      gcsInvalid        = 0,
      gcsSimple         = 1,
      gcsClass          = 2,
      gcsCoverage       = 3
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableContextList
//
//------------------------------------------------------------------------------
// Sequence Context Format 1: simple glyph contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#51-context-substitution-format-1-simple-glyph-contexts
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#sequence-context-format-1-simple-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableContextSimple = class(TCustomOpenTypeSubstitutionSubTable)
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
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SequenceRules: TSequenceRuleSets read FSequenceRules write FSequenceRules;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableContextClass
//
//------------------------------------------------------------------------------
// Sequence Context Format 2: class-based glyph contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#seqctxt2
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableContextClass = class(TCustomOpenTypeSubstitutionSubTable)
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
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SequenceRules: TSequenceRuleSets read FSequenceRules write FSequenceRules;
    property ClassDefinitions: TCustomOpenTypeClassDefinitionTable read FClassDefinitions write SetClassDefinitions;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableContextCoverage
//
//------------------------------------------------------------------------------
// Sequence Context Format 3: coverage-based glyph contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#sequence-context-format-3-coverage-based-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableContextCoverage = class(TCustomOpenTypeLookupSubTable)
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

    procedure LoadFromStream(Stream: TStream); override;
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
//              TOpenTypeSubstitutionLookupTableContext
//
//------------------------------------------------------------------------------
function TOpenTypeSubstitutionLookupTableContext.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphContextSubstitution(ASubFormat) of

    gcsSimple:
      Result := TOpenTypeSubstitutionSubTableContextSimple;

    gcsClass:
      Result := TOpenTypeSubstitutionSubTableContextClass;

    gcsCoverage:
      Result := TOpenTypeSubstitutionSubTableContextCoverage;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableContextSimple
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableContextSimple.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
end;

destructor TOpenTypeSubstitutionSubTableContextSimple.Destroy;
begin
  inherited;
end;

procedure TOpenTypeSubstitutionSubTableContextSimple.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableContextSimple then
  begin
    FSequenceRules := Copy(TOpenTypeSubstitutionSubTableContextSimple(Source).FSequenceRules);
  end;
end;

procedure TOpenTypeSubstitutionSubTableContextSimple.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  SavePos: Int64;
  i, j, k: integer;
  SequenceRuleSetOffsets: array of Word;
  SequenceRuleOffsets: array of Word;
  StartGlyph: Word;
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
  SetLength(SequenceRuleSetOffsets, BigEndianValueReader.ReadWord(Stream));
  for i := 0 to High(SequenceRuleSetOffsets) do
    SequenceRuleSetOffsets[i] := BigEndianValueReader.ReadWord(Stream);

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
    SetLength(SequenceRuleOffsets, BigEndianValueReader.ReadWord(Stream));
    for j := 0 to High(SequenceRuleOffsets) do
      SequenceRuleOffsets[j] := BigEndianValueReader.ReadWord(Stream);

    StartGlyph := CoverageTable.GlyphByIndex(i);

    // Read a Sequence Rule Set
    SetLength(FSequenceRules[i], Length(SequenceRuleOffsets));
    for j := 0 to High(SequenceRuleOffsets) do
    begin
      if (SequenceRuleOffsets[j] = 0) then
        continue;

      Stream.Position := StartPos + SequenceRuleSetOffsets[i] + SequenceRuleOffsets[j];

      // Read InputSequence and SequenceLookupRecord lengths
      SetLength(FSequenceRules[i][j].InputSequence, BigEndianValueReader.ReadWord(Stream));
      SetLength(FSequenceRules[i][j].SequenceLookupRecords, BigEndianValueReader.ReadWord(Stream));

      // Read InputSequence
      Sequence := FSequenceRules[i][j].InputSequence;
      if (Length(Sequence) > 0) then
      begin
        // Set first component from coverage table
        Sequence[0] := StartGlyph;

        // Read remaining from input sequence list
        for k := 1 to High(Sequence) do
          Sequence[k] := BigEndianValueReader.ReadWord(Stream);
      end;

      // Read SequenceLookupRecords
      SequenceLookupRecords := FSequenceRules[i][j].SequenceLookupRecords;
      for k := 0 to High(SequenceLookupRecords) do
      begin
        SequenceLookupRecords[k].SequenceIndex := BigEndianValueReader.ReadWord(Stream);
        SequenceLookupRecords[k].LookupListIndex := BigEndianValueReader.ReadWord(Stream);
      end;
    end;
  end;

  Stream.Position := SavePos;
end;

procedure TOpenTypeSubstitutionSubTableContextSimple.SaveToStream(Stream: TStream);
begin
  // TODO
end;

function TOpenTypeSubstitutionSubTableContextSimple.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
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
    if (not AGlyphIterator.GlyphString.Match(AGlyphIterator, 1, SequenceRuleSet[i].InputSequence)) then
      continue;

    // We have a match. Apply the rules.
    Result := ApplyLookupRecords(AGlyphIterator, SequenceRuleSet[i].SequenceLookupRecords);
    break;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableContextClass
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableContextClass.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
end;

destructor TOpenTypeSubstitutionSubTableContextClass.Destroy;
begin
  inherited;
end;

procedure TOpenTypeSubstitutionSubTableContextClass.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableContextClass then
  begin
    FSequenceRules := Copy(TOpenTypeSubstitutionSubTableContextClass(Source).FSequenceRules);
    // Assignment via property setter makes a copy
    SetClassDefinitions(TOpenTypeSubstitutionSubTableContextClass(Source).FClassDefinitions);
  end;
end;

procedure TOpenTypeSubstitutionSubTableContextClass.LoadFromStream(Stream: TStream);
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
  ClassDefOffset := BigEndianValueReader.ReadWord(Stream);

  // Read list of sequence rule set offsets
  SetLength(SequenceRuleSetOffsets, BigEndianValueReader.ReadWord(Stream));
  for i := 0 to High(SequenceRuleSetOffsets) do
    SequenceRuleSetOffsets[i] := BigEndianValueReader.ReadWord(Stream);

  SavePos := Stream.Position;

  // Read the class definition tables
  Stream.Position := StartPos + ClassDefOffset;
  ClassDefinitionFormat := TClassDefinitionFormat(BigEndianValueReader.ReadWord(Stream));

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
    SetLength(SequenceRuleOffsets, BigEndianValueReader.ReadWord(Stream));
    for j := 0 to High(SequenceRuleOffsets) do
      SequenceRuleOffsets[j] := BigEndianValueReader.ReadWord(Stream);

    // Read a Sequence Rule Set
    SetLength(FSequenceRules[i], Length(SequenceRuleOffsets));
    for j := 0 to High(SequenceRuleOffsets) do
    begin
      if (SequenceRuleOffsets[j] = 0) then
        continue;

      Stream.Position := StartPos + SequenceRuleSetOffsets[i] + SequenceRuleOffsets[j];

      // Read InputSequence and SequenceLookupRecord lengths
      SetLength(FSequenceRules[i][j].InputSequence, BigEndianValueReader.ReadWord(Stream));
      SetLength(FSequenceRules[i][j].SequenceLookupRecords, BigEndianValueReader.ReadWord(Stream));

      // Read InputSequence
      Sequence := FSequenceRules[i][j].InputSequence;
      if (Length(Sequence) > 0) then
      begin
        Sequence[0] := 0;

        // Read remaining from input sequence list
        for k := 1 to High(Sequence) do
          Sequence[k] := BigEndianValueReader.ReadWord(Stream);
      end;

      Sequence := FSequenceRules[i][j].InputSequence;
      for k := 0 to High(Sequence) do
        Sequence[k] := BigEndianValueReader.ReadWord(Stream);

      // Read SequenceLookupRecords
      SequenceLookupRecords := FSequenceRules[i][j].SequenceLookupRecords;
      for k := 0 to High(SequenceLookupRecords) do
      begin
        SequenceLookupRecords[k].SequenceIndex := BigEndianValueReader.ReadWord(Stream);
        SequenceLookupRecords[k].LookupListIndex := BigEndianValueReader.ReadWord(Stream);
      end;
    end;
  end;

  Stream.Position := SavePos;
end;

procedure TOpenTypeSubstitutionSubTableContextClass.SaveToStream(Stream: TStream);
begin
  // TODO
end;

procedure TOpenTypeSubstitutionSubTableContextClass.SetClassDefinitions(const Value: TCustomOpenTypeClassDefinitionTable);
begin
  FreeAndNil(FClassDefinitions);
  if (Value <> nil) then
  begin
    FClassDefinitions := TOpenTypeClassDefinitionTableClass(Value.ClassType).Create(Self);
    FClassDefinitions.Assign(Value);
  end;
end;

function TOpenTypeSubstitutionSubTableContextClass.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  SequenceRuleSetIndex: integer;
  SequenceRuleSet: TSequenceRuleSet;
  i: integer;
begin
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
    // TODO : Skip first entry in InputSequence?
    if (Length(SequenceRuleSet[i].InputSequence) > 1) then
      if (not AGlyphIterator.GlyphString.Match(AGlyphIterator, 1, SequenceRuleSet[i].InputSequence, FClassDefinitions.ClassByGlyphID)) then
        continue;

    // We have a match. Apply the rules.
    Result := ApplyLookupRecords(AGlyphIterator, SequenceRuleSet[i].SequenceLookupRecords);
    break;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableContextCoverage
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableContextCoverage.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;

  FCoverageTables := TObjectList<TCustomOpenTypeCoverageTable>.Create;
end;

destructor TOpenTypeSubstitutionSubTableContextCoverage.Destroy;
begin
  FCoverageTables.Free;

  inherited;
end;

procedure TOpenTypeSubstitutionSubTableContextCoverage.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableContextCoverage then
  begin
    FSequenceRules := Copy(TOpenTypeSubstitutionSubTableContextCoverage(Source).FSequenceRules);
    // Assignment via property setter makes a copy
    SetCoverageTables(TOpenTypeSubstitutionSubTableContextCoverage(Source).FCoverageTables);
  end;
end;

procedure TOpenTypeSubstitutionSubTableContextCoverage.LoadFromStream(Stream: TStream);
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
  SetLength(CoverageOffsets, BigEndianValueReader.ReadWord(Stream));
  SetLength(FSequenceRules, BigEndianValueReader.ReadWord(Stream));

  // Read coverage table offsets
  for i := 0 to High(CoverageOffsets) do
    CoverageOffsets[i] := BigEndianValueReader.ReadWord(Stream);

  // Read sequence rules
  for i := 0 to High(FSequenceRules) do
  begin
    FSequenceRules[i].SequenceIndex := BigEndianValueReader.ReadWord(Stream);
    FSequenceRules[i].LookupListIndex := BigEndianValueReader.ReadWord(Stream);
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

procedure TOpenTypeSubstitutionSubTableContextCoverage.SaveToStream(Stream: TStream);
begin
  // TODO
end;

procedure TOpenTypeSubstitutionSubTableContextCoverage.SetCoverageTables(Value: TCoverageTables);
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

function TOpenTypeSubstitutionSubTableContextCoverage.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
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
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsContext, TOpenTypeSubstitutionLookupTableContext);
end.

