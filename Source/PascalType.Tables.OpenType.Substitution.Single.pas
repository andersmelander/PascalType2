unit PascalType.Tables.OpenType.Substitution.Single;

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
//              TOpenTypeSubstitutionLookupTableSingle
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#lookuptype-1-single-substitution-subtable
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionLookupTableSingle = class(TCustomOpenTypeSubstitutionLookupTable)
  public type
    TGlyphSingleSubstitution = (
      gssInvalid        = 0,
      gssOffset         = 1,
      gssList           = 2
    );
  protected
    function GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass; override;
  public
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableSingleOffset
//
//------------------------------------------------------------------------------
// Single substitution offsetting specified glyph index
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#11-single-substitution-format-1
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableSingleOffset = class(TCustomOpenTypeSubstitutionSubTable)
  private
    FDeltaGlyphID: SmallInt;
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer): boolean; override;

    property DeltaGlyphID: SmallInt read FDeltaGlyphID write FDeltaGlyphID;
  end;

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableSingleList
//
//------------------------------------------------------------------------------
// Single substitution by specified glyph index
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub#12-single-substitution-format-2
//------------------------------------------------------------------------------
type
  TOpenTypeSubstitutionSubTableSingleList = class(TCustomOpenTypeSubstitutionSubTable)
  private
    FSubstituteGlyphIDs: TGlyphString;
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function Apply(GlyphString: TPascalTypeGlyphString; var AIndex: integer): boolean; override;

    property SubstituteGlyphIDs: TGlyphString read FSubstituteGlyphIDs;
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
//              TOpenTypeSubstitutionLookupTableSingle
//
//------------------------------------------------------------------------------
function TOpenTypeSubstitutionLookupTableSingle.GetSubTableClass(ASubFormat: Word): TOpenTypeLookupSubTableClass;
begin
  case TGlyphSingleSubstitution(ASubFormat) of

    gssOffset:
      Result := TOpenTypeSubstitutionSubTableSingleOffset;

    gssList:
      Result := TOpenTypeSubstitutionSubTableSingleList;

  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableSingleOffset
//
//------------------------------------------------------------------------------
procedure TOpenTypeSubstitutionSubTableSingleOffset.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableSingleOffset then
    FDeltaGlyphID := TOpenTypeSubstitutionSubTableSingleOffset(Source).DeltaGlyphID;
end;

procedure TOpenTypeSubstitutionSubTableSingleOffset.LoadFromStream(Stream: TStream);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  FDeltaGlyphID := BigEndianValueReader.ReadSmallInt(Stream);
end;

procedure TOpenTypeSubstitutionSubTableSingleOffset.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedSmallInt(Stream, FDeltaGlyphID);
end;

function TOpenTypeSubstitutionSubTableSingleOffset.Apply(AGlyphString: TPascalTypeGlyphString; var AIndex: integer): boolean;
var
  SubstitutionIndex: integer;
begin
  // The coverage table just tells us if the substitution applies.
  SubstitutionIndex := CoverageTable.IndexOfGlyph(AGlyphString[AIndex].GlyphID);

  if (SubstitutionIndex = -1) then
    Exit(False);

  AGlyphString[AIndex].GlyphID := Word((integer(AGlyphString[AIndex].GlyphID) + integer(FDeltaGlyphID)) and $0000FFFF);
  Inc(AIndex);
  Result := True;
end;

//------------------------------------------------------------------------------
//
//              TOpenTypeSubstitutionSubTableSingleList
//
//------------------------------------------------------------------------------
procedure TOpenTypeSubstitutionSubTableSingleList.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeSubstitutionSubTableSingleList then
    FSubstituteGlyphIDs := TOpenTypeSubstitutionSubTableSingleList(Source).FSubstituteGlyphIDs;
end;

procedure TOpenTypeSubstitutionSubTableSingleList.LoadFromStream(Stream: TStream);
var
  i: integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  SetLength(FSubstituteGlyphIDs, BigEndianValueReader.ReadWord(Stream));
  for i := 0 to High(FSubstituteGlyphIDs) do
    FSubstituteGlyphIDs[i] := BigEndianValueReader.ReadWord(Stream);
end;

procedure TOpenTypeSubstitutionSubTableSingleList.SaveToStream(Stream: TStream);
var
  i: integer;
begin
  inherited;

  WriteSwappedWord(Stream, Length(FSubstituteGlyphIDs));
  for i := 0 to High(FSubstituteGlyphIDs) do
    WriteSwappedWord(Stream, FSubstituteGlyphIDs[i]);
end;

function TOpenTypeSubstitutionSubTableSingleList.Apply(GlyphString: TPascalTypeGlyphString; var AIndex: integer): boolean;
var
  SubstitutionIndex: integer;
begin
  SubstitutionIndex := CoverageTable.IndexOfGlyph(GlyphString[AIndex].GlyphID);
//  if (TArray.BinarySearch<Word>(FSubstituteGlyphIDs, GlyphString[AIndex].GlyphID, Index)) then

  if (SubstitutionIndex = -1) then
    Exit(False);

  GlyphString[AIndex].GlyphID := FSubstituteGlyphIDs[SubstitutionIndex];
  Inc(AIndex);
  Result := True;
end;

//------------------------------------------------------------------------------

initialization
  TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(gsSingle, TOpenTypeSubstitutionLookupTableSingle);
end.

