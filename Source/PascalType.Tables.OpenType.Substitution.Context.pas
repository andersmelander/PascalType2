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
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Substitution;

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
      gcsSimple         = 1
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
// Context Substitution Format 1: Simple Glyph Contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#51-context-substitution-format-1-simple-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableContextSimple = class(TCustomOpenTypeSubstitutionSubTable)
  public type
    TSequenceLookupRecord = record
      SequenceIndex: Word;
      LookupListIndex: Word;
    end;
    TSequenceRule = record
      InputSequence: TGlyphString;
      SequenceLookupRecords: TArray<TSequenceLookupRecord>;
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

    function Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer): boolean; override;

    property SequenceRules: TSequenceRuleSets read FSequenceRules write FSequenceRules;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_Types,
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
  SequenceLookupRecords: TArray<TSequenceLookupRecord>;
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

    Stream.Position := StartPos + SequenceRuleSetOffsets[i];

    // Read list of offsets to Sequence Rule Sets
    // Offsets are from beginning of the Sequence Rule Set table
    SetLength(SequenceRuleOffsets, BigEndianValueReader.ReadWord(Stream));
    for j := 0 to High(SequenceRuleOffsets) do
      SequenceRuleOffsets[j] := BigEndianValueReader.ReadWord(Stream);

    StartGlyph := CoverageTable.GlyphByIndex(i);

    // Read a Sequence Rule Set
    SetLength(FSequenceRules[i], length(SequenceRuleOffsets));
    for j := 0 to High(SequenceRuleOffsets) do
    begin
      Stream.Position := StartPos + SequenceRuleSetOffsets[i] + SequenceRuleOffsets[j];

      // Read InputSequence and SequenceLookupRecord lengths
      SetLength(FSequenceRules[i][j].InputSequence, BigEndianValueReader.ReadWord(Stream));
      SetLength(FSequenceRules[i][j].SequenceLookupRecords, BigEndianValueReader.ReadWord(Stream));

      // Read InputSequence
      if (Length(FSequenceRules[i][j].InputSequence) > 0) then
      begin
        // Set first component from coverage table
        FSequenceRules[i][j].InputSequence[0] := StartGlyph;

        // Read remaining from input sequence list
        for k := 1 to High(FSequenceRules[i][j].InputSequence) do
          FSequenceRules[i][j].InputSequence[k] := BigEndianValueReader.ReadWord(Stream);
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

function TOpenTypeSubstitutionSubTableContextSimple.Apply(AGlyphString: TPascalTypeGlyphString;
  var AIndex: integer): boolean;
var
  SequenceRuleSetIndex: integer;
  SequenceRuleSet: TSequenceRuleSet;
  InputSequence: TGlyphString;
  SequenceLookupRecords: TArray<TSequenceLookupRecord>;
  i, j: integer;
  Match: boolean;
  LookupSubTable: TCustomOpenTypeLookupSubTable;
begin
  // The coverage table contains the index of the first character of the sequence.
  SequenceRuleSetIndex := CoverageTable.IndexOfGlyph(AGlyphString[AIndex].GlyphID);

  if (SequenceRuleSetIndex = -1) then
    Exit(False);

  // Sequences are grouped by starting character so all members of a group
  // has the same start character.
  SequenceRuleSet := FSequenceRules[SequenceRuleSetIndex];

  for i := 0 to High(SequenceRuleSet) do
  begin
    InputSequence := SequenceRuleSet[i].InputSequence;
    // If the end of this sequence is past our source string then there can be no match
    if (AIndex + Length(InputSequence) > AGlyphString.Count) then
      continue;

    // Compare each character in the sequence string to the source string
    Match := True;
    // Note: We have already implicitly matched the first character via the
    // coverage table, so we could start at index 1 here
    for j := 0 to High(InputSequence) do
      if (AGlyphString[AIndex + j].GlyphID <> InputSequence[j]) then
      begin
        Match := False;
        break;
      end;

    if (not Match) then
      continue;

    // We have a match. Apply the rules.
    SequenceLookupRecords := SequenceRuleSet[i].SequenceLookupRecords;
    for j := 0 to High(SequenceLookupRecords) do
    begin
      // Adjust the glyph index
      Inc(AIndex, SequenceLookupRecords[j].SequenceIndex);

      // Get the referenced lookup
      LookupSubTable := LookupTable.SubTables[SequenceLookupRecords[j].LookupListIndex];

      // Recursively apply
      // TODO : What to do about True/False here?
      Result := LookupSubTable.Apply(AGlyphString, AIndex);
    end;

    Exit(True);
  end;

  Result := False;
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsContext, TOpenTypeSubstitutionLookupTableContext);
end.

