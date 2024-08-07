unit PascalType.Tables.OpenType.Substitution.ChainedContext;

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
  PascalType.Classes,
  PascalType.Types,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Substitution,
  PascalType.Tables.OpenType.ClassDefinition,
  PascalType.Tables.OpenType.Coverage;

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionLookupTableChainedContext
//
//------------------------------------------------------------------------------
// LookupType 6: Chained Contexts Substitution Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#lookuptype-6-chained-contexts-substitution-subtable
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionLookupTableChainedContext = class(TCustomOpenTypeSubstitutionLookupTable)
  public type
    TGlyphContextSubstitution = (
      gccsInvalid        = 0,
      gccsSimple         = 1,
      gccsClass          = 2,
      gccsCoverage       = 3
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


type
  TContextPart = (cpBacktrack, cpInput, cpLookahead);

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableChainedContextSimple
//
//------------------------------------------------------------------------------
// Chained Contexts Substitution Format 1: Simple Glyph Contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#61-chained-contexts-substitution-format-1-simple-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableChainedContextSimple = class(TCustomOpenTypeSubstitutionSubTable)
  public type
    TChainedSequenceRule = record
      BacktrackSequence: TGlyphString;
      InputSequence: TGlyphString;
      LookaheadSequence: TGlyphString;
      SequenceLookupRecords: TSequenceLookupRecords;
    end;
    TChainedSequenceRuleSet = TArray<TChainedSequenceRule>;
    TChainedSequenceRuleSets = TArray<TChainedSequenceRuleSet>;
  private
    FSequenceRules: TChainedSequenceRuleSets;
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SequenceRules: TChainedSequenceRuleSets read FSequenceRules write FSequenceRules;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableChainedContextClass
//
//------------------------------------------------------------------------------
// Chained Sequence Context Format 2: class-based glyph contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#chained-sequence-context-format-2-class-based-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableChainedContextClass = class(TCustomOpenTypeSubstitutionSubTable)
  public type
    TChainedSequenceRule = record
      InputSequence: TGlyphString;
      BacktrackSequence: TGlyphString;
      LookaheadSequence: TGlyphString;
      SequenceLookupRecords: TSequenceLookupRecords;
    end;
    TChainedSequenceRuleSet = TArray<TChainedSequenceRule>;
    TChainedSequenceRuleSets = TArray<TChainedSequenceRuleSet>;
  private
    FSequenceRules: TChainedSequenceRuleSets;
    FClassDefinitions: array[TContextPart] of TCustomOpenTypeClassDefinitionTable;
  protected
    procedure SetClassDefinitions(Index: TContextPart; const Value: TCustomOpenTypeClassDefinitionTable);
    function Match(const AGlyphIterator: TPascalTypeGlyphGlyphIterator; const Rule: TChainedSequenceRule): boolean;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SequenceRules: TChainedSequenceRuleSets read FSequenceRules write FSequenceRules;
    property BacktrackClassDefinitions: TCustomOpenTypeClassDefinitionTable index cpBacktrack read FClassDefinitions[cpBacktrack] write SetClassDefinitions;
    property InputClassDefinitions: TCustomOpenTypeClassDefinitionTable index cpInput read FClassDefinitions[cpInput] write SetClassDefinitions;
    property LookaheadClassDefinitions: TCustomOpenTypeClassDefinitionTable index cpLookahead read FClassDefinitions[cpLookahead] write SetClassDefinitions;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableChainedContextCoverage
//
//------------------------------------------------------------------------------
// Chained Sequence Context Format 3: coverage-based glyph contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#chained-sequence-context-format-3-coverage-based-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableChainedContextCoverage = class(TCustomOpenTypeLookupSubTable)
  private type
    TCoverageTables = TList<TCustomOpenTypeCoverageTable>;
  private
    FSequenceRules: TCustomOpenTypeLookupSubTable.TSequenceLookupRecords;
    FCoverageTables: array[TContextPart] of TCoverageTables;
  protected
    procedure SetCoverageTables(Index: TContextPart; Value: TCoverageTables);
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property SequenceRules: TCustomOpenTypeLookupSubTable.TSequenceLookupRecords read FSequenceRules write FSequenceRules;
    property BacktrackCoverageTables: TCoverageTables index cpBacktrack read FCoverageTables[cpBacktrack] write SetCoverageTables;
    property InputCoverageTables: TCoverageTables index cpInput read FCoverageTables[cpInput] write SetCoverageTables;
    property LookaheadCoverageTables: TCoverageTables index cpLookahead read FCoverageTables[cpLookahead] write SetCoverageTables;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.Unicode,
  PascalType.ResourceStrings,
  PascalType.Tables.OpenType.GSUB;

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionLookupTableChainedContext
//
//------------------------------------------------------------------------------
function TOpenTypeSubstitutionLookupTableChainedContext.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphContextSubstitution(ASubFormat) of

    gccsSimple:
      Result := TOpenTypeSubstitutionSubTableChainedContextSimple;

    gccsClass:
      Result := TOpenTypeSubstitutionSubTableChainedContextClass;

    gccsCoverage:
      Result := TOpenTypeSubstitutionSubTableChainedContextCoverage;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableChainedContextSimple
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableChainedContextSimple.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
end;

destructor TOpenTypeSubstitutionSubTableChainedContextSimple.Destroy;
begin
  inherited;
end;

procedure TOpenTypeSubstitutionSubTableChainedContextSimple.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableChainedContextSimple then
  begin
    FSequenceRules := Copy(TOpenTypeSubstitutionSubTableChainedContextSimple(Source).FSequenceRules);
  end;
end;

procedure TOpenTypeSubstitutionSubTableChainedContextSimple.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  SavePos: Int64;
  i, j, k: integer;
  SequenceRuleSetOffsets: array of Word;
  SequenceRuleOffsets: array of Word;
  Sequence: TGlyphString;
  SequenceLookupRecords: TArray<TSequenceLookupRecord>;
begin
  // Test font: "Monoid Regular" (font does not appears to contain valid data for this table)

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

    Stream.Position := StartPos + SequenceRuleSetOffsets[i];

    // Read list of offsets to Sequence Rule Sets
    // Offsets are from beginning of the Sequence Rule Set table
    SetLength(SequenceRuleOffsets, BigEndianValue.ReadWord(Stream));
    for j := 0 to High(SequenceRuleOffsets) do
      SequenceRuleOffsets[j] := BigEndianValue.ReadWord(Stream);

    // Read a Sequence Rule Set
    SetLength(FSequenceRules[i], length(SequenceRuleOffsets));
    for j := 0 to High(SequenceRuleOffsets) do
    begin
      if (SequenceRuleOffsets[j] = 0) then
        continue;

      Stream.Position := StartPos + SequenceRuleSetOffsets[i] + SequenceRuleOffsets[j];

      // Read BacktrackSequence
      SetLength(FSequenceRules[i][j].BacktrackSequence, BigEndianValue.ReadWord(Stream));
      Sequence := FSequenceRules[i][j].BacktrackSequence;
      for k := 0 to High(Sequence) do
        Sequence[k] := BigEndianValue.ReadWord(Stream);

      // Read InputSequence
      SetLength(FSequenceRules[i][j].InputSequence, BigEndianValue.ReadWord(Stream));
      Sequence := FSequenceRules[i][j].InputSequence;
      if (Length(Sequence) > 0) then
      begin
        // First component isn't used
        Sequence[0] := 0;

        // Read remaining from input sequence list
        for k := 1 to High(Sequence) do
          Sequence[k] := BigEndianValue.ReadWord(Stream);
      end;

      // Read LookaheadSequence
      SetLength(FSequenceRules[i][j].LookaheadSequence, BigEndianValue.ReadWord(Stream));
      Sequence := FSequenceRules[i][j].LookaheadSequence;
      for k := 0 to High(Sequence) do
        Sequence[k] := BigEndianValue.ReadWord(Stream);

      // Read SequenceLookupRecords
      SetLength(FSequenceRules[i][j].SequenceLookupRecords, BigEndianValue.ReadWord(Stream));
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

procedure TOpenTypeSubstitutionSubTableChainedContextSimple.SaveToStream(Stream: TStream);
begin
  // TODO
end;

function TOpenTypeSubstitutionSubTableChainedContextSimple.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  SequenceRuleSetIndex: integer;
  SequenceRuleSet: TChainedSequenceRuleSet;
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
    if (Length(SequenceRuleSet[i].InputSequence) > 1) then
      if (not AGlyphIterator.GlyphString.Match(AGlyphIterator, 1, SequenceRuleSet[i].InputSequence, True)) then
        continue;

    // Backtrack
    if (Length(SequenceRuleSet[i].BacktrackSequence) > 0) then
      if (not AGlyphIterator.GlyphString.Match(AGlyphIterator, -Length(SequenceRuleSet[i].BacktrackSequence), SequenceRuleSet[i].BacktrackSequence)) then
        continue;

    // Lookahead
    if (Length(SequenceRuleSet[i].LookaheadSequence) > 0) then
      if (not AGlyphIterator.GlyphString.Match(AGlyphIterator, 1+Length(SequenceRuleSet[i].InputSequence), SequenceRuleSet[i].LookaheadSequence)) then
        continue;

    // We have a match. Apply the rules.
    Result := ApplyLookupRecords(AGlyphIterator, SequenceRuleSet[i].SequenceLookupRecords);
    break;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableChainedContextClass
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableChainedContextClass.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
end;

destructor TOpenTypeSubstitutionSubTableChainedContextClass.Destroy;
begin
  inherited;
end;

procedure TOpenTypeSubstitutionSubTableChainedContextClass.Assign(Source: TPersistent);
var
  Part: TContextPart;
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableChainedContextClass then
  begin
    FSequenceRules := Copy(TOpenTypeSubstitutionSubTableChainedContextClass(Source).FSequenceRules);
    // Assignment via property setter makes a copy
    for Part := Low(TContextPart) to High(TContextPart) do
      SetClassDefinitions(Part, TOpenTypeSubstitutionSubTableChainedContextClass(Source).FClassDefinitions[Part]);
  end;
end;

procedure TOpenTypeSubstitutionSubTableChainedContextClass.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  SavePos: Int64;
  Part: TContextPart;
  i, j, k: integer;
  SequenceRuleSetOffsets: array of Word;
  SequenceRuleOffsets: array of Word;
  Sequence: TGlyphString;
  SequenceLookupRecords: TArray<TSequenceLookupRecord>;
  ClassDefOffset: array[TContextPart] of Word;
  ClassDefinitionFormat: TClassDefinitionFormat;
  ClassDefinitionTableClass: TOpenTypeClassDefinitionTableClass;
begin
  // Test font: "Arial Unicode MS", "Segoe UI Variable" (i� j� i�)
  SetLength(FSequenceRules, 0);
  for Part := Low(FClassDefinitions) to High(FClassDefinitions) do
    FreeAndNil(FClassDefinitions[Part]);

  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 4 * SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Get the offsets to the class definition tables
  for Part := Low(ClassDefOffset) to High(ClassDefOffset) do
    ClassDefOffset[Part] := BigEndianValue.ReadWord(Stream);

  // Read list of sequence rule set offsets
  SetLength(SequenceRuleSetOffsets, BigEndianValue.ReadWord(Stream));
  for i := 0 to High(SequenceRuleSetOffsets) do
    SequenceRuleSetOffsets[i] := BigEndianValue.ReadWord(Stream);

  SavePos := Stream.Position;

  // Read the class definition tables
  for Part := Low(FClassDefinitions) to High(FClassDefinitions) do
  begin
    Stream.Position := StartPos + ClassDefOffset[Part];
    ClassDefinitionFormat := TClassDefinitionFormat(BigEndianValue.ReadWord(Stream));

    ClassDefinitionTableClass := TCustomOpenTypeClassDefinitionTable.ClassByFormat(ClassDefinitionFormat);
    if (ClassDefinitionTableClass <> nil) then
    begin
      FClassDefinitions[Part] := ClassDefinitionTableClass.Create(Self);

      Stream.Position := StartPos + ClassDefOffset[Part];
      FClassDefinitions[Part].LoadFromStream(Stream);
    end;
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

      // Read BacktrackSequence
      SetLength(FSequenceRules[i][j].BacktrackSequence, BigEndianValue.ReadWord(Stream));
      Sequence := FSequenceRules[i][j].BacktrackSequence;
      for k := 0 to High(Sequence) do
        Sequence[k] := BigEndianValue.ReadWord(Stream);

      // Read InputSequence
      SetLength(FSequenceRules[i][j].InputSequence, BigEndianValue.ReadWord(Stream));
      Sequence := FSequenceRules[i][j].InputSequence;
      if (Length(Sequence) > 0) then
      begin
        // First component is matched via coverage table
        Sequence[0] := 0;

        // Read remaining from input sequence list
        for k := 1 to High(Sequence) do
          Sequence[k] := BigEndianValue.ReadWord(Stream);
      end;

      // Read LookaheadSequence
      SetLength(FSequenceRules[i][j].LookaheadSequence, BigEndianValue.ReadWord(Stream));
      Sequence := FSequenceRules[i][j].LookaheadSequence;
      for k := 0 to High(Sequence) do
        Sequence[k] := BigEndianValue.ReadWord(Stream);

      // Read SequenceLookupRecords
      SetLength(FSequenceRules[i][j].SequenceLookupRecords, BigEndianValue.ReadWord(Stream));
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

function TOpenTypeSubstitutionSubTableChainedContextClass.Match(const AGlyphIterator: TPascalTypeGlyphGlyphIterator; const Rule: TChainedSequenceRule): boolean;
var
  Iterator: TPascalTypeGlyphGlyphIterator;
begin
  Result := False;
  Iterator := AGlyphIterator.Clone;

  // Backtrack
  if (Length(Rule.BacktrackSequence) > 0) then
    if (not Iterator.GlyphString.Match(Iterator, -Length(Rule.BacktrackSequence), Rule.BacktrackSequence, FClassDefinitions[cpBacktrack].ClassByGlyphID, False, True)) then
      exit;

  // Input
  if (Length(Rule.InputSequence) > 1) then
  begin
    // Note: We have already implicitly matched the first character via the
    // coverage table, so we skip that here.
    if (not Iterator.GlyphString.Match(Iterator, 0, Rule.InputSequence, FClassDefinitions[cpInput].ClassByGlyphID, True, True)) then
      exit;
  end else
    Iterator.Next;

  // Lookahead
  if (Length(Rule.LookaheadSequence) > 0) then
    if (not Iterator.GlyphString.Match(Iterator, 0, Rule.LookaheadSequence, FClassDefinitions[cpLookahead].ClassByGlyphID)) then
      exit;

  Result := True;
end;

procedure TOpenTypeSubstitutionSubTableChainedContextClass.SaveToStream(Stream: TStream);
begin
  // TODO
end;

procedure TOpenTypeSubstitutionSubTableChainedContextClass.SetClassDefinitions(Index: TContextPart; const Value: TCustomOpenTypeClassDefinitionTable);
begin
  FreeAndNil(FClassDefinitions[Index]);
  if (Value <> nil) then
  begin
    FClassDefinitions[Index] := TOpenTypeClassDefinitionTableClass(Value.ClassType).Create(Self);
    FClassDefinitions[Index].Assign(Value);
  end;
end;

function TOpenTypeSubstitutionSubTableChainedContextClass.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  SequenceRuleSetIndex: integer;
  SequenceRuleSet: TChainedSequenceRuleSet;
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
  SequenceRuleSetIndex := FClassDefinitions[cpInput].ClassByGlyphID(AGlyphIterator.Glyph.GlyphID);

  SequenceRuleSet := FSequenceRules[SequenceRuleSetIndex];
  for i := 0 to High(SequenceRuleSet) do
  begin
    // Compare each character class in the sequence strings to the source string
    if (not Match(AGlyphIterator, SequenceRuleSet[i])) then
      continue;

    // We have a match. Apply the rules.
    Result := ApplyLookupRecords(AGlyphIterator, SequenceRuleSet[i].SequenceLookupRecords);
    break;
  end;
end;

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableChainedContextCoverage
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableChainedContextCoverage.Create(AParent: TCustomPascalTypeTable);
var
  Part: TContextPart;
begin
  inherited;

  for Part := Low(TContextPart) to High(TContextPart) do
    FCoverageTables[Part] := TObjectList<TCustomOpenTypeCoverageTable>.Create;
end;

destructor TOpenTypeSubstitutionSubTableChainedContextCoverage.Destroy;
var
  Part: TContextPart;
begin
  for Part := Low(TContextPart) to High(TContextPart) do
    FCoverageTables[Part].Free;

  inherited;
end;

procedure TOpenTypeSubstitutionSubTableChainedContextCoverage.Assign(Source: TPersistent);
var
  Part: TContextPart;
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableChainedContextCoverage then
  begin
    FSequenceRules := Copy(TOpenTypeSubstitutionSubTableChainedContextCoverage(Source).FSequenceRules);
    // Assignment via property setter makes a copy
    for Part := Low(TContextPart) to High(TContextPart) do
      SetCoverageTables(Part, TOpenTypeSubstitutionSubTableChainedContextCoverage(Source).FCoverageTables[Part]);
  end;
end;

procedure TOpenTypeSubstitutionSubTableChainedContextCoverage.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  Part: TContextPart;
  i: integer;
  CoverageOffsets: array[TContextPart] of array of Word;
  CoverageTable: TCustomOpenTypeCoverageTable;
begin
  // Test font: "Arial"
  SetLength(FSequenceRules, 0);
  for Part := Low(FCoverageTables) to High(FCoverageTables) do
    FCoverageTables[Part].Clear;

  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 4 * SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Read coverage table offsets
  for Part := Low(FCoverageTables) to High(FCoverageTables) do
  begin
    SetLength(CoverageOffsets[Part], BigEndianValue.ReadWord(Stream));
    for i := 0 to High(CoverageOffsets[Part]) do
      CoverageOffsets[Part][i] := BigEndianValue.ReadWord(Stream);
  end;

  // Read Sequence Rule
  SetLength(FSequenceRules, BigEndianValue.ReadWord(Stream));
  for i := 0 to High(FSequenceRules) do
  begin
    FSequenceRules[i].SequenceIndex := BigEndianValue.ReadWord(Stream);
    FSequenceRules[i].LookupListIndex := BigEndianValue.ReadWord(Stream);
  end;


  // Read the coverage tables
  for Part := Low(FCoverageTables) to High(FCoverageTables) do
  begin
    FCoverageTables[Part].Capacity := Length(CoverageOffsets[Part]);
    for i := 0 to High(CoverageOffsets[Part]) do
    begin
      Stream.Position := StartPos + CoverageOffsets[Part][i];
      CoverageTable := TCustomOpenTypeCoverageTable.CreateFromStream(Stream);
      FCoverageTables[Part].Add(CoverageTable);
    end;
  end;
end;

procedure TOpenTypeSubstitutionSubTableChainedContextCoverage.SaveToStream(Stream: TStream);
begin
  // TODO
end;

procedure TOpenTypeSubstitutionSubTableChainedContextCoverage.SetCoverageTables(Index: TContextPart; Value: TCoverageTables);
var
  CoverageTable: TCustomOpenTypeCoverageTable;
  NewCoverageTable: TCustomOpenTypeCoverageTable;
begin
  FCoverageTables[Index].Clear;

  if (Value = nil) then
    exit;

  for CoverageTable in Value do
  begin
    NewCoverageTable := CoverageTable.Clone;
    FCoverageTables[Index].Add(NewCoverageTable);
  end;
end;

function TOpenTypeSubstitutionSubTableChainedContextCoverage.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  CoverageIndex: integer;
  i: integer;
  Iterator: TPascalTypeGlyphGlyphIterator;
begin
  Result := False;

  if (AGlyphIterator.Index + FCoverageTables[cpInput].Count + FCoverageTables[cpLookahead].Count > AGlyphIterator.GlyphString.Count) then
    exit;

  if (AGlyphIterator.Index - FCoverageTables[cpBacktrack].Count < 0) then
    exit;

  Iterator := AGlyphIterator.Clone;

  Iterator.Previous(FCoverageTables[cpBacktrack].Count);
  if (Iterator.EOF) then
    exit;

  // The strings are matched, character by character, against the coverage tables.
  // The coverage index itself isn't used. We just need to determine if we should proceed.

  // Backtrack
  for i := 0 to FCoverageTables[cpBacktrack].Count-1 do
  begin
    CoverageIndex := FCoverageTables[cpBacktrack][i].IndexOfGlyph(Iterator.Glyph.GlyphID);

    if (CoverageIndex = -1) then
      exit;

    Iterator.Next;
  end;

  // Input
  for i := 0 to FCoverageTables[cpInput].Count-1 do
  begin
    if (Iterator.EOF) then
      exit;

    CoverageIndex := FCoverageTables[cpInput][i].IndexOfGlyph(Iterator.Glyph.GlyphID);

    if (CoverageIndex = -1) then
      exit;

    Iterator.Next;
  end;

  // Lookahead
  for i := 0 to FCoverageTables[cpLookahead].Count-1 do
  begin
    if (Iterator.EOF) then
      exit;

    CoverageIndex := FCoverageTables[cpLookahead][i].IndexOfGlyph(Iterator.Glyph.GlyphID);

    if (CoverageIndex = -1) then
      exit;

    Iterator.Next;
  end;

  // We have a match. Apply the rules.
  Result := ApplyLookupRecords(AGlyphIterator, FSequenceRules);
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsChainingContext, TOpenTypeSubstitutionLookupTableChainedContext);
end.

