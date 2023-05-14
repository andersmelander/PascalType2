unit PascalType.Tables.OpenType.Substitution.Ligature;

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
//              TOpenTypeSubstitutionLookupTableLigature
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#LS
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionLookupTableLigature = class(TCustomOpenTypeSubstitutionLookupTable)
  public type
    TGlyphLigatureSubstitution = (
      glsInvalid        = 0,
      glsList           = 1
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableLigatureList
//
//------------------------------------------------------------------------------
// Ligature Substitution Format 1
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#41-ligature-substitution-format-1
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableLigatureList = class(TCustomOpenTypeSubstitutionSubTable)
  private type
    TGlyphLigature = record
      Glyph: Word;
      Components: array of Word;
    end;
    TGlyphLigatures = TList<TGlyphLigature>;
  private
    FLigatures: TGlyphLigatures;
    FLigatureIndex: array of integer;
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Substitute(AGlyphString: TPascalTypeGlyphString; var AIndex: integer): boolean; override;

    property Ligatures: TGlyphLigatures read FLigatures;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_Types,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionLookupTableLigature
//
//------------------------------------------------------------------------------
function TOpenTypeSubstitutionLookupTableLigature.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphLigatureSubstitution(ASubFormat) of

    glsList:
      Result := TOpenTypeSubstitutionSubTableLigatureList;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableLigatureList
//
//------------------------------------------------------------------------------
constructor TOpenTypeSubstitutionSubTableLigatureList.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FLigatures := TGlyphLigatures.Create;
end;

destructor TOpenTypeSubstitutionSubTableLigatureList.Destroy;
begin
  FLigatures.Free;
  inherited;
end;

procedure TOpenTypeSubstitutionSubTableLigatureList.Assign(Source: TPersistent);
var
  Ligature: TGlyphLigature;
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableLigatureList then
  begin
    FLigatures.Clear;

    for Ligature in TOpenTypeSubstitutionSubTableLigatureList(Source).FLigatures do
      // TGlyphLigature is a record; Add() makes a copy.
      FLigatures.Add(Ligature);
  end;
end;

procedure TOpenTypeSubstitutionSubTableLigatureList.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  SavePos: Int64;
  i, j, k: integer;
  OffsetListOffsets: array of Word;
  LigatureOffsets: array of Word;
  Ligature: TGlyphLigature;
begin
  FLigatures.Clear;

  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Read list of offsets to list of offsets to ligatures
  SetLength(OffsetListOffsets, ReadSwappedWord(Stream));
  for i := 0 to High(OffsetListOffsets) do
    OffsetListOffsets[i] := ReadSwappedWord(Stream);

  SavePos := Stream.Position;

  SetLength(FLigatureIndex, Length(OffsetListOffsets));
  for i := 0 to High(OffsetListOffsets) do
  begin

    Stream.Position := StartPos + OffsetListOffsets[i];

    FLigatureIndex[i] := FLigatures.Count; // Save index to first ligature with this start component

    // Read list of offsets to ligatures,
    // Offsets are from beginning of ligatureSet table
    SetLength(LigatureOffsets, ReadSwappedWord(Stream));
    for j := 0 to High(LigatureOffsets) do
      LigatureOffsets[j] := ReadSwappedWord(Stream);

    // Read list of ligature definitions
    for j := 0 to High(LigatureOffsets) do
    begin
      Stream.Position := StartPos + OffsetListOffsets[i] + LigatureOffsets[j];

      // Read ligature glyph
      Ligature.Glyph := ReadSwappedWord(Stream);

      SetLength(Ligature.Components, ReadSwappedWord(Stream));

      if (Length(Ligature.Components) = 0) then
        // This shouldn't happen
        continue;

      // Set first component from coverage table
      Ligature.Components[0] := CoverageTable.GlyphByIndex(i);

      // Read remaining from ligature component list
      for k := 1 to High(Ligature.Components) do
        Ligature.Components[k] := ReadSwappedWord(Stream);

      FLigatures.Add(Ligature);
    end;

  end;

  Stream.Position := SavePos;
end;

procedure TOpenTypeSubstitutionSubTableLigatureList.SaveToStream(Stream: TStream);
begin
  // TODO
end;

function TOpenTypeSubstitutionSubTableLigatureList.Substitute(AGlyphString: TPascalTypeGlyphString;
  var AIndex: integer): boolean;
var
  SubstitutionIndex: integer;
  Glyph: TPascalTypeGlyph;
  i, j: integer;
  Match: boolean;
  LastSameStartCharIndex: integer;
  CodePoints: TPascalTypeCodePoints;
begin
  // Test with Segoe UI: ? ? ? = ???

  // The coverage table contains the index of the first character of the ligature component string.
  SubstitutionIndex := CoverageTable.IndexOfGlyph(AGlyphString[AIndex].GlyphID);

  if (SubstitutionIndex = -1) then
    Exit(False);

  if (SubstitutionIndex < High(FLigatureIndex)) then
    LastSameStartCharIndex := FLigatureIndex[SubstitutionIndex+1]-1
  else
    LastSameStartCharIndex := FLigatures.Count-1;

  for i := FLigatureIndex[SubstitutionIndex] to LastSameStartCharIndex do
  begin
    if (AIndex + High(FLigatures[SubstitutionIndex].Components) >= AGlyphString.Count) then
      continue;

    Match := True;
    for j := 0 to High(FLigatures[SubstitutionIndex].Components) do
      if (AGlyphString[AIndex + j].GlyphID <> FLigatures[i].Components[j]) then
      begin
        Match := False;
        break;
      end;

    if (Match) then
    begin
      // First entry in glyph string is reused
      AGlyphString[AIndex].GlyphID := FLigatures[i].Glyph;

      SetLength(CodePoints, Length(FLigatures[i].Components));
      for j := 0 to High(FLigatures[i].Components) do
        CodePoints[j] := FLigatures[i].Components[j];

      AGlyphString[AIndex].CodePoints := CodePoints;

      // Remaining are deleted
      for j := 1 to High(FLigatures[i].Components) do
        AGlyphString.Delete(AIndex+1);

      Inc(AIndex);

      Exit(True);
    end;
  end;

  Result := False;
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsLigature, TOpenTypeSubstitutionLookupTableLigature);
end.

