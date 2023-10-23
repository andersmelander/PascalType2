unit PascalType.Tables.OpenType.Substitution.ReverseChainedContext;

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
//              TOpenTypeSubstitutionLookupTableReverseChainedContext
//
//------------------------------------------------------------------------------
// LookupType 8: Reverse Chaining Contextual Single Substitution Subtable
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#lookuptype-8-reverse-chaining-contextual-single-substitution-subtable
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionLookupTableReverseChainedContext = class(TCustomOpenTypeSubstitutionLookupTable)
  public type
    TGlyphContextSubstitution = (
      grccsInvalid        = 0,
      grccsCoverage       = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
    function GetUseReverseDirection: boolean; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableReverseChainedContextCoverage
//
//------------------------------------------------------------------------------
// Reverse Chaining Contextual Single Substitution Format 1: Coverage-based Glyph Contexts
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#81-reverse-chaining-contextual-single-substitution-format-1-coverage-based-glyph-contexts
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableReverseChainedContextCoverage = class(TCustomOpenTypeLookupSubTable)
  private type
    TCoverageTables = TList<TCustomOpenTypeCoverageTable>;
    TContextPart = (cpBacktrack, cpInput, cpLookahead);
  private
    FCoverageTables: array[TContextPart] of TCoverageTables;
    FSubstituteGlyphIDs: TGlyphString;
  protected
    procedure SetCoverageTables(Index: TContextPart; Value: TCoverageTables);
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean; override;

    property BacktrackCoverageTables: TCoverageTables index cpBacktrack read FCoverageTables[cpBacktrack] write SetCoverageTables;
    property InputCoverageTables: TCoverageTables index cpInput read FCoverageTables[cpInput] write SetCoverageTables;
    property LookaheadCoverageTables: TCoverageTables index cpLookahead read FCoverageTables[cpLookahead] write SetCoverageTables;
    property Substitution: TGlyphString read FSubstituteGlyphIDs write FSubstituteGlyphIDs;
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
//              TOpenTypeSubstitutionLookupTableReverseChainedContext
//
//------------------------------------------------------------------------------
function TOpenTypeSubstitutionLookupTableReverseChainedContext.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphContextSubstitution(ASubFormat) of

    grccsCoverage:
      Result := TOpenTypeSubstitutionSubTableReverseChainedContextCoverage;

  else
    Result := nil;
  end;
end;

function TOpenTypeSubstitutionLookupTableReverseChainedContext.GetUseReverseDirection: boolean;
begin
  Result := True;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableReverseChainedContextCoverage
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableReverseChainedContextCoverage.Create(AParent: TCustomPascalTypeTable);
var
  Part: TContextPart;
begin
  inherited;

  for Part := Low(TContextPart) to High(TContextPart) do
    FCoverageTables[Part] := TObjectList<TCustomOpenTypeCoverageTable>.Create;
end;

destructor TOpenTypeSubstitutionSubTableReverseChainedContextCoverage.Destroy;
var
  Part: TContextPart;
begin
  for Part := Low(TContextPart) to High(TContextPart) do
    FCoverageTables[Part].Free;

  inherited;
end;

procedure TOpenTypeSubstitutionSubTableReverseChainedContextCoverage.Assign(Source: TPersistent);
var
  Part: TContextPart;
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableReverseChainedContextCoverage then
  begin
    FSubstituteGlyphIDs := Copy(TOpenTypeSubstitutionSubTableReverseChainedContextCoverage(Source).Substitution);
    // Assignment via property setter makes a copy
    for Part := Low(TContextPart) to High(TContextPart) do
      SetCoverageTables(Part, TOpenTypeSubstitutionSubTableReverseChainedContextCoverage(Source).FCoverageTables[Part]);
  end;
end;

procedure TOpenTypeSubstitutionSubTableReverseChainedContextCoverage.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  Part: TContextPart;
  i: integer;
  CoverageOffsets: array[TContextPart] of array of Word;
  CoverageTable: TCustomOpenTypeCoverageTable;
begin
  // +----------+-----------------------------------------------+----------------------------------------------+
  // | Type     | Name                                          | Description                                  |
  // +==========+===============================================+==============================================+
  // | uint16   | substFormat                                   | Format identifier: format = 1                |
  // +----------+-----------------------------------------------+----------------------------------------------+
  // | Offset16 | coverageOffset                                | Offset to Coverage table, from beginning     |
  // |          |                                               | of substitution subtable.                    |
  // +----------+-----------------------------------------------+----------------------------------------------+
  // | uint16   | backtrackGlyphCount                           | Number of glyphs in the backtrack sequence.  |
  // +----------+-----------------------------------------------+----------------------------------------------+
  // | Offset16 | backtrackCoverageOffsets[backtrackGlyphCount] | Array of offsets to coverage tables in       |
  // |          |                                               | backtrack sequence, in glyph sequence        |
  // |          |                                               | order.                                       |
  // +----------+-----------------------------------------------+----------------------------------------------+
  // | uint16   | lookaheadGlyphCount                           | Number of glyphs in lookahead sequence.      |
  // +----------+-----------------------------------------------+----------------------------------------------+
  // | Offset16 | lookaheadCoverageOffsets[lookaheadGlyphCount] | Array of offsets to coverage tables in       |
  // |          |                                               | lookahead sequence, in glyph sequence order. |
  // +----------+-----------------------------------------------+----------------------------------------------+
  // | uint16   | glyphCount                                    | Number of glyph IDs in the                   |
  // |          |                                               | substituteGlyphIDs array.                    |
  // +----------+-----------------------------------------------+----------------------------------------------+
  // | uint16   | substituteGlyphIDs[glyphCount]                | Array of substitute glyph IDs — ordered      |
  // |          |                                               | by Coverage index.                           |
  // +----------+-----------------------------------------------+----------------------------------------------+

  // Test font: "Numderline"
  SetLength(FSubstituteGlyphIDs, 0);
  for Part := Low(FCoverageTables) to High(FCoverageTables) do
    FCoverageTables[Part].Clear;

  StartPos := Stream.Position;

  inherited;

  // Read coverage table offsets
  SetLength(CoverageOffsets[cpInput], 1);
  CoverageOffsets[cpInput][0] := BigEndianValue.ReadWord(Stream);

  SetLength(CoverageOffsets[cpBacktrack], BigEndianValue.ReadWord(Stream));
  for i := 0 to High(CoverageOffsets[cpBacktrack]) do
    CoverageOffsets[cpBacktrack][i] := BigEndianValue.ReadWord(Stream);

  SetLength(CoverageOffsets[cpLookahead], BigEndianValue.ReadWord(Stream));
  for i := 0 to High(CoverageOffsets[cpLookahead]) do
    CoverageOffsets[cpLookahead][i] := BigEndianValue.ReadWord(Stream);

  // Read substitution
  SetLength(FSubstituteGlyphIDs, BigEndianValue.ReadWord(Stream));
  for i := 0 to High(FSubstituteGlyphIDs) do
    FSubstituteGlyphIDs[i] := BigEndianValue.ReadWord(Stream);

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

procedure TOpenTypeSubstitutionSubTableReverseChainedContextCoverage.SaveToStream(Stream: TStream);
begin
  // TODO
end;

procedure TOpenTypeSubstitutionSubTableReverseChainedContextCoverage.SetCoverageTables(Index: TContextPart; Value: TCoverageTables);
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

function TOpenTypeSubstitutionSubTableReverseChainedContextCoverage.Apply(var AGlyphIterator: TPascalTypeGlyphGlyphIterator): boolean;
var
  ReplacementIndex: integer;
  CoverageIndex: integer;
  i: integer;
  Iterator: TPascalTypeGlyphGlyphIterator;
  SaveIndex: integer;
begin
  Result := False;

  Assert(LookupTable.UseReverseDirection);

  if (AGlyphIterator.Index + FCoverageTables[cpInput].Count + FCoverageTables[cpLookahead].Count > AGlyphIterator.GlyphString.Count) then
    exit;

  if (AGlyphIterator.Index - FCoverageTables[cpBacktrack].Count < 0) then
    exit;

  if (AGlyphIterator.EOF) then
    exit;

  Iterator := AGlyphIterator.Clone;

  // Input
  // The coverage index we get here specifies the (single) replacement character index.
  // Note that we know there is just a single coverage table.
  ReplacementIndex := FCoverageTables[cpInput][0].IndexOfGlyph(Iterator.Glyph.GlyphID);
  if (ReplacementIndex = -1) then
    exit;

  // The string is matched, character by character, against the backtrack and lookahead coverage tables.
  // The coverage index itself isn't used. We just need to determine if we should proceed.
  SaveIndex := Iterator.Index;

  // Backtrack
  for i := 0 to FCoverageTables[cpBacktrack].Count-1 do
  begin
    Iterator.Previous;
    if (Iterator.EOF) then
      exit;

    CoverageIndex := FCoverageTables[cpBacktrack][i].IndexOfGlyph(Iterator.Glyph.GlyphID);
    if (CoverageIndex = -1) then
      exit;
  end;

  Iterator.Index := SaveIndex;

  // Lookahead
  for i := 0 to FCoverageTables[cpLookahead].Count-1 do
  begin
    Iterator.Next;
    if (Iterator.EOF) then
      exit;

    CoverageIndex := FCoverageTables[cpLookahead][i].IndexOfGlyph(Iterator.Glyph.GlyphID);
    if (CoverageIndex = -1) then
      exit;
  end;

  // We have a match. Apply the substitution.
  Result := True;

  AGlyphIterator.Glyph.GlyphID := FSubstituteGlyphIDs[ReplacementIndex];
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsReverseChainingContextSingle, TOpenTypeSubstitutionLookupTableReverseChainedContext);
end.

