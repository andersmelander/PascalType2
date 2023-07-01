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
  PT_Types,
  PT_Classes,
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
      LookupTable: TCustomOpenTypeLookupTable;
{$ifdef DEBUG}
      FeatureTable: TCustomOpenTypeFeatureTable;
      LookupListIndex: integer;
{$endif DEBUG}
    end;
    TLookupItems = TArray<TLookupItem>;
    TFeatureMap = TDictionary<TTableName, TCustomOpenTypeFeatureTable>;
  private
    FFont: TCustomPascalTypeFontFace;
    FScript: TTableType;
    FLanguage: TTableType;
    FDirection: TPascalTypeDirection;
    FFeatureMap: TFeatureMap;
  protected
    procedure LoadFeatureMap;
    function GetAvailableFeatures: TPascalTypeFeatures; virtual;
    function GetLookupsByFeatures(AFeatures: TPascalTypeFeatures): TLookupItems;
    function ApplyLookups(const ALookups: TLookupItems; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures;
    function ApplyLookup(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ALookupTable: TCustomOpenTypeLookupTable): boolean; virtual;
    function GetTable: TCustomOpenTypeCommonTable; virtual; abstract;
    property FeatureMap: TFeatureMap read FFeatureMap;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace; AScript: TTableType; ALanguage: TTableType; ADirection: TPascalTypeDirection); virtual;
    destructor Destroy; override;

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

  FFeatureMap := TFeatureMap.Create;
end;

destructor TCustomPascalTypeOpenTypeProcessor.Destroy;
begin
  FFeatureMap.Free;

  inherited;
end;

function TCustomPascalTypeOpenTypeProcessor.ExecutePlan(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TPascalTypeFeatures;
var
  Stage: TPascalTypeShapingPlanStage;
begin
  Result := [];

  LoadFeatureMap;

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
  GlyphIterator: TPascalTypeGlyphGlyphIterator;
  Handled: boolean;
begin
  Result := nil;

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
    GlyphIterator.Reset(LookupItem.LookupTable.LookupFlags);

    // For each glyph...
    while (not GlyphIterator.EOF) do
    begin
      Handled := False;
      // If the glyph is tagged with the feature...
      if (GlyphIterator.Glyph.Features.Contains(LookupItem.FeatureTag)) then
        // For each lookup sub-table, apply the lookup until one of them succeeds
        Handled := ApplyLookup(GlyphIterator, LookupItem.LookupTable);

      if (Handled) then
        Result.Add(LookupItem.FeatureTag);

{$ifdef DEBUG}
      if (Handled) then
        OutputDebugString(PChar(Format('%d: Applied feature %s (%s), lookup %d: %s', [GlyphIterator.Index, string(LookupItem.FeatureTag), LookupItem.FeatureTable.DisplayName, LookupItem.LookupListIndex, LookupItem.LookupTable.ClassName])));
{$endif DEBUG}

{$ifdef ApplyIncrements}
      if (not Handled) then
{$endif ApplyIncrements}
        GlyphIterator.Next;
    end;

  end;

end;

function TCustomPascalTypeOpenTypeProcessor.ApplyLookup(var AGlyphIterator: TPascalTypeGlyphGlyphIterator; ALookupTable: TCustomOpenTypeLookupTable): boolean;
begin
  Result := ALookupTable.Apply(AGlyphIterator);
end;

function TCustomPascalTypeOpenTypeProcessor.GetAvailableFeatures: TPascalTypeFeatures;
begin
  Result := FFeatureMap.Keys.ToArray;
end;

function TCustomPascalTypeOpenTypeProcessor.GetLookupsByFeatures(AFeatures: TPascalTypeFeatures): TLookupItems;
type
  TLookupSortItem = record
    LookupIndex: integer;
    LookupItem: TLookupItem;
  end;
var
  LookupList: TList<TLookupSortItem>;
  Tag: TTableName;
  FeatureListIndex: integer;
  Item: TLookupSortItem;
  FeatureTable: TCustomOpenTypeFeatureTable;
  i: integer;
begin
  LookupList := TList<TLookupSortItem>.Create;
  try

    for Tag in AFeatures do
    begin
      // Intersect the requested features with the ones that are available in the font
      if (not FeatureMap.TryGetValue(Tag, FeatureTable)) then
        continue;

      for FeatureListIndex in FeatureTable do
      begin
        Item.LookupIndex := FeatureListIndex;
        Item.LookupItem.FeatureTag := Tag;
        Item.LookupItem.LookupTable := Table.LookupListTable[FeatureListIndex];
{$ifdef DEBUG}
        Item.LookupItem.FeatureTable := FeatureTable;
        Item.LookupItem.LookupListIndex := FeatureListIndex;
{$endif DEBUG}
        LookupList.Add(Item);
      end;
    end;

    // Sort lookups by index so they are applied in the correct order
    LookupList.Sort(TComparer<TLookupSortItem>.Construct(
      function(const A, B: TLookupSortItem): integer
      begin
        Result := (A.LookupIndex - B.LookupIndex);
      end));

    // List to array (and discard the field we used to sort by)
    SetLength(Result, LookupList.Count);
    for i := 0 to LookupList.Count-1 do
      Result[i] := LookupList[i].LookupItem;

  finally
    LookupList.Free;
  end;
end;

procedure TCustomPascalTypeOpenTypeProcessor.LoadFeatureMap;
var
  ScriptTable: TCustomOpenTypeScriptTable;
  LanguageSystem: TCustomOpenTypeLanguageSystemTable;
  i: integer;
  FeatureTable: TCustomOpenTypeFeatureTable;
begin
  FFeatureMap.Clear;

  // Get script, fallback to default
  ScriptTable := Table.ScriptListTable.FindScript(Script, True);

  if (ScriptTable = nil) then
    Exit;

  // Get language system, fallback to default
  LanguageSystem := ScriptTable.FindLanguageSystem(Language, True);

  if (LanguageSystem = nil) then
    Exit;

  FFeatureMap.Capacity := LanguageSystem.FeatureIndexCount;
  for i := 0 to LanguageSystem.FeatureIndexCount-1 do
  begin
    // LanguageSystem feature list contains index numbers into the FeatureListTable
    FeatureTable := Table.FeatureListTable.Feature[LanguageSystem.FeatureIndex[i]];

    FFeatureMap.Add(FeatureTable.TableType.AsAnsiChar, FeatureTable);
  end;
end;

end.
