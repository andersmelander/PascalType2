unit PascalType.Shaper.OpenType.Processor;

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

uses
  System.Classes,
  Generics.Collections,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Unicode,
  PascalType.GlyphString,
  PascalType.FontFace.SFNT,
  PascalType.Shaper.Plan,
  PascalType.Tables.OpenType.Common,
  PascalType.Tables.OpenType.GSUB,
  PascalType.Tables.OpenType.GPOS,
  PascalType.Tables.OpenType.Feature,
  PascalType.Tables.OpenType.Lookup;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeOpenTypeProcessor
//
//------------------------------------------------------------------------------
// Base class for GSUB and GPOS table processors
//------------------------------------------------------------------------------
type
  TCustomPascalTypeOpenTypeProcessor = class abstract
  protected type
    TLookupItem = record
      FeatureTag: TTableName;
      FeatureTable: TCustomOpenTypeFeatureTable;
    end;
    TLookupItems = TArray<TLookupItem>;
    TFeatureList = TArray<Word>;
  private
    FFont: TCustomPascalTypeFontFace;
    FScript: TTableType;
    FLanguage: TTableType;
    FDirection: TPascalTypeDirection;
    // Note: Don't use TPascalTypeFeatures for FFeatureList.
    // We need to maintain the original order of the features in it.
    FFeatureList: TFeatureList;
  protected
    procedure LoadFeatureList;
    function GetAvailableFeatures: TPascalTypeFeatures; virtual;
    function GetLookupsByFeatures(const AFeatures: TPascalTypeFeatures): TLookupItems;
    function ApplyLookups(const ALookups: TLookupItems; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures;
    function ApplyLookup(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ALookupTable: TCustomOpenTypeLookupTable): boolean; virtual;
    function GetTable: TCustomOpenTypeCommonTable; virtual; abstract;
    property FeatureList: TFeatureList read FFeatureList; // Ordered list of features
  public
    constructor Create(AFont: TCustomPascalTypeFontFace; AScript: TTableType; ALanguage: TTableType; ADirection: TPascalTypeDirection); virtual;

    // Applies the specified features, using the lookups in the table, and
    // returns a list of features applied.
    function ApplyFeatures(const AFeatures: TPascalTypeFeatures; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures; virtual;

    // Applies the features in the specified plan features, using the lookups in the table, and
    // returns a list of features applied.
    function ExecutePlan(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures; virtual;

    property Font: TCustomPascalTypeFontFace read FFont;
    property Script: TTableType read FScript write FScript;
    property Language: TTableType read FLanguage write FLanguage;
    property Direction: TPascalTypeDirection read FDirection write FDirection;

    property Table: TCustomOpenTypeCommonTable read GetTable;
    property AvailableFeatures: TPascalTypeFeatures read GetAvailableFeatures;
  end;

implementation

uses
  Generics.Defaults,
{$ifdef DEBUG}
  WinApi.Windows,
{$endif DEBUG}
  System.SysUtils,
  PascalType.Tables.OpenType.Script,
  PascalType.Tables.OpenType.LanguageSystem;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeOpenTypeProcessor
//
//------------------------------------------------------------------------------
constructor TCustomPascalTypeOpenTypeProcessor.Create(AFont: TCustomPascalTypeFontFace; AScript: TTableType; ALanguage: TTableType; ADirection: TPascalTypeDirection);
begin
  inherited Create;
  FFont := AFont;
  FScript := AScript;
  FLanguage := ALanguage;
  FDirection := ADirection;
end;

function TCustomPascalTypeOpenTypeProcessor.ExecutePlan(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures;
var
  Stage: TPascalTypeShapingPlanStage;
begin
  Result := [];

  LoadFeatureList;

  for Stage in APlan do
  begin
    if (Assigned(Stage.Delegate)) then
      Stage.Delegate(Self, AGlyphs);

    if (Stage.Count > 0) then
      Result := Result + ApplyFeatures(Stage.Features, AGlyphs);
  end;
end;

function TCustomPascalTypeOpenTypeProcessor.ApplyFeatures(const AFeatures: TPascalTypeFeatures; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures;
var
  LookupItems: TLookupItems;
begin
  if (Table = nil) then
    Exit(nil);

  LookupItems := GetLookupsByFeatures(AFeatures);

  Result := ApplyLookups(LookupItems, AGlyphs);
end;

function TCustomPascalTypeOpenTypeProcessor.ApplyLookups(const ALookups: TLookupItems; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures;
var
  LookupItem: TLookupItem;
  LookupListIndex: integer;
  LookupIndex: integer;
  LookupTable: TCustomOpenTypeLookupTable;
  GlyphIterator: TPascalTypeGlyphGlyphIterator;
  Handled: boolean;
begin
  Result := nil;

  if (Length(ALookups) = 0) then
    exit;

  // Iterate over each feature and apply it to the individual glyphs.
  // Each glyph is only processed once by a feature, but it can be
  // processed multiple times by different features.
  GlyphIterator := AGlyphs.CreateIterator;

  // A series of substitution operations on the same glyph or string requires multiple
  // lookups, one for each separate action. Each lookup has a different array index
  // in the LookupList table and is applied in the LookupList order.
  //
  // During text processing, a client applies a lookup to each glyph in the string
  // before moving to the next lookup. A lookup is finished for a glyph after the
  // client locates the target glyph or glyph context and performs a substitution,
  // if specified. To move to the “next” glyph, the client will typically skip all
  // the glyphs that participated in the lookup operation: glyphs that were
  // substituted as well as any other glyphs that formed a context for the operation.

  // For each feature...
  for LookupItem in ALookups do
  begin
    // For each lookup...
    for LookupListIndex := 0 to LookupItem.FeatureTable.LookupListCount-1 do
    begin
      // Get the index of the lookup table
      LookupIndex := LookupItem.FeatureTable.LookupList[LookupListIndex];
      // Get the lookup table
      LookupTable := Table.LookupListTable.LookupTables[LookupIndex];

      GlyphIterator.Reset(LookupTable.LookupFlags);

      // For each glyph...
      while (not GlyphIterator.EOF) do
      begin
        Handled := False;
        // If the glyph is tagged with the feature...
        if (GlyphIterator.Glyph.Features.Contains(LookupItem.FeatureTag)) then
          // For each lookup sub-table, apply the lookup until one of them succeeds
          Handled := ApplyLookup(GlyphIterator, LookupTable);

        if (Handled) then
          Result.Add(LookupItem.FeatureTag);

  {$ifdef DEBUG}
        if (Handled) then
          OutputDebugString(PChar(Format('%d: Applied feature %s (%s), lookup %d: %s', [GlyphIterator.Index, string(LookupItem.FeatureTag), LookupItem.FeatureTable.DisplayName, LookupListIndex, LookupTable.ClassName])));
  {$endif DEBUG}

  {$ifdef ApplyIncrements}
        if (not Handled) then
  {$endif ApplyIncrements}
          GlyphIterator.Next;
      end;
    end;

  end;

end;

function TCustomPascalTypeOpenTypeProcessor.ApplyLookup(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ALookupTable: TCustomOpenTypeLookupTable): boolean;
begin
  Result := ALookupTable.Apply(AGlyphIterator);
end;

function TCustomPascalTypeOpenTypeProcessor.GetAvailableFeatures: TPascalTypeFeatures;
var
  FeatureIndex: Word;
  FeatureTable: TCustomOpenTypeFeatureTable;
begin
  for FeatureIndex in FeatureList do
  begin
    FeatureTable := Table.FeatureListTable.Feature[FeatureIndex];
    Result.Add(FeatureTable.TableType);
  end;
end;

function TCustomPascalTypeOpenTypeProcessor.GetLookupsByFeatures(const AFeatures: TPascalTypeFeatures): TLookupItems;
var
  Count: integer;
  FeatureIndex: Word;
  FeatureTable: TCustomOpenTypeFeatureTable;
  Tag: TTableName;
begin
  SetLength(Result, Length(FeatureList));
  Count := 0;

  for FeatureIndex in FeatureList do
  begin
    FeatureTable := Table.FeatureListTable.Feature[FeatureIndex];
    Tag := FeatureTable.TableType.AsAnsiChar;

    // Intersect the requested features with the ones that are available in the font
    if (AFeatures.Contains(Tag)) then
    begin
      Result[Count].FeatureTag := Tag;
      Result[Count].FeatureTable := FeatureTable;
      Inc(Count);
    end;
  end;

  SetLength(Result, Count);
end;

procedure TCustomPascalTypeOpenTypeProcessor.LoadFeatureList;
var
  ScriptTable: TCustomOpenTypeScriptTable;
  LanguageSystem: TCustomOpenTypeLanguageSystemTable;
  i: integer;
begin
  FFeatureList := nil;

  // Get script, fallback to default
  ScriptTable := Table.ScriptListTable.FindScript(Script, True);

  if (ScriptTable = nil) then
    Exit;

  // Get language system, fallback to default
  LanguageSystem := ScriptTable.FindLanguageSystem(Language, True);

  if (LanguageSystem = nil) then
    Exit;

  // Create an ordered list of features to be applied
  SetLength(FFeatureList, LanguageSystem.FeatureIndexCount);
  for i := 0 to LanguageSystem.FeatureIndexCount-1 do
    FFeatureList[i] := LanguageSystem.FeatureIndex[i];
end;

end.
