unit PascalType.Shaper.Plan;

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
  Generics.Defaults,
  Generics.Collections,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Unicode,
  PascalType.GlyphString,
  PascalType.FontFace.SFNT,
  PascalType.Tables.OpenType.GSUB,
  PascalType.Tables.OpenType.Feature;


//------------------------------------------------------------------------------
//
//              TPascalTypeShaperFeatures
//
//------------------------------------------------------------------------------
// A collection of user features.
// Each feature is associated with a boolean state. True=Enable feature,
// False=disable feature.
//------------------------------------------------------------------------------
type
  TPascalTypeShaperFeatures = class
  private
    FFeatures: TDictionary<TTableName, boolean>;
    FEnableAll: boolean;
    function GetFeatureEnabled(const AKey: TTableName): boolean;
    procedure SetFeatureEnabled(const AKey: TTableName; const Value: boolean);
  protected
    FOnChanged: TNotifyEvent;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    procedure Changed;
  public
    constructor Create;
    destructor Destroy; override;
    function GetEnumerator: TEnumerator<TTableName>;
    function IsEnabled(const AKey: TTableName; ADefault: boolean): boolean;
    property Enabled[const AKey: TTableName]: boolean read GetFeatureEnabled write SetFeatureEnabled; default;
    property EnableAll: boolean read FEnableAll write FEnableAll;
  end;

//------------------------------------------------------------------------------
//
//              TPascalTypeShapingPlanStage
//
//------------------------------------------------------------------------------
// A collection of features.
//------------------------------------------------------------------------------
type
  TPascalTypeShapingPlanStages = class;
  TPascalTypeShapingPlan = class;

  TPascalTypeShapingPlanStage = class
  public type
    TPascalTypeShapingPlanDelegate = function(AProcessor: TObject; var AGlyphs: TPascalTypeGlyphString): TTableNames;
  private
    FStages: TPascalTypeShapingPlanStages;
    FFeatures: TPascalTypeFeatures;
    FDelegate: TPascalTypeShapingPlanDelegate;
    function GetCount: integer;
    function GetFeature(Index: integer): TTableName;
    function GetPlan: TPascalTypeShapingPlan;
  public
    constructor Create(AStages: TPascalTypeShapingPlanStages);

    procedure Add(const AFeature: TTableName; AGlobal: boolean = True); overload;
    procedure Add(const AFeatures: TTableNames; AGlobal: boolean = True); overload;
    procedure Remove(const AFeature: TTableName);

    function GetEnumerator: TEnumerator<TTableName>;

    property Plan: TPascalTypeShapingPlan read GetPlan;

    property Delegate: TPascalTypeShapingPlanDelegate read FDelegate write FDelegate;

    property Count: integer read GetCount;
    property FeatureList[Index: integer]: TTableName read GetFeature; default;
    property Features: TPascalTypeFeatures read FFeatures;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeShapingPlanStages
//
//------------------------------------------------------------------------------
// A list of feature stages.
//------------------------------------------------------------------------------
  TPascalTypeShapingPlanStages = class
  private
    FPlan: TPascalTypeShapingPlan;
    FStages: TList<TPascalTypeShapingPlanStage>;
    FAllFeatures: TDictionary<TTableName, TPascalTypeShapingPlanStage>;
    function GetCount: integer;
    function GetStage(Index: integer): TPascalTypeShapingPlanStage;
  protected
    procedure DoAddFeature(const AFeature: TTableName; AGlobal: boolean; AStage: TPascalTypeShapingPlanStage);
    procedure DoRemoveFeature(const AFeature: TTableName);
    procedure RemoveFeature(const AFeature: TTableName);
    function HasFeature(const AFeature: TTableName): boolean;
    property Plan: TPascalTypeShapingPlan read FPlan;
  public
    constructor Create(APlan: TPascalTypeShapingPlan);
    destructor Destroy; override;

    function Add: TPascalTypeShapingPlanStage;

    function GetEnumerator: TEnumerator<TPascalTypeShapingPlanStage>;

    property Count: integer read GetCount;
    property Stages[Index: integer]: TPascalTypeShapingPlanStage read GetStage; default;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeShapingPlan
//
//------------------------------------------------------------------------------
// A collection of feature stages to be applied as part of the shaping. Each
// stage contains a number of features. The shaper applies the stages
// sequentially.
// Inspired by FontKit.
//------------------------------------------------------------------------------
  TPascalTypeShapingPlan = class
  private
    FStages: TPascalTypeShapingPlanStages;
    FGlobalFeatures: TPascalTypeFeatures;
  protected
    procedure DoAddFeature(const AFeature: TTableName; AGlobal: boolean; AStage: TPascalTypeShapingPlanStage);
    procedure DoRemoveFeature(const AFeature: TTableName);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddFeature(const AFeature: TTableName; AGlobal: boolean = True; AStage: TPascalTypeShapingPlanStage = nil);
    procedure AddFeatures(const AFeatures: TTableNames; AGlobal: boolean = True; AStage: TPascalTypeShapingPlanStage = nil);
    procedure RemoveFeature(const AFeature: TTableName);
    function HasFeature(const AFeature: TTableName): boolean;

    procedure ApplyUserFeatures(AFeatures: TPascalTypeShaperFeatures);

    function GetEnumerator: TEnumerator<TPascalTypeShapingPlanStage>;

    property Stages: TPascalTypeShapingPlanStages read FStages;
    property GlobalFeatures: TPascalTypeFeatures read FGlobalFeatures;
  end;

type
  TPascalTypeShapingPlanClass = class of TPascalTypeShapingPlan;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

//------------------------------------------------------------------------------
//
//              TPascalTypeShapingPlanStage
//
//------------------------------------------------------------------------------
constructor TPascalTypeShapingPlanStage.Create(AStages: TPascalTypeShapingPlanStages);
begin
  inherited Create;
  FStages := AStages;
end;

procedure TPascalTypeShapingPlanStage.Add(const AFeature: TTableName; AGlobal: boolean);
begin
  if (FStages.HasFeature(AFeature)) then
    exit;

  FFeatures.Add(AFeature);
  FStages.DoAddFeature(AFeature, AGlobal, Self);
end;

procedure TPascalTypeShapingPlanStage.Add(const AFeatures: TTableNames; AGlobal: boolean);
var
  Feature: TTableName;
begin
  for Feature in AFeatures do
    Add(Feature, AGlobal);
end;

function TPascalTypeShapingPlanStage.GetCount: integer;
begin
  Result := FFeatures.Count;
end;

function TPascalTypeShapingPlanStage.GetEnumerator: TEnumerator<TTableName>;
begin
  Result := FFeatures.GetEnumerator;
end;

function TPascalTypeShapingPlanStage.GetFeature(Index: integer): TTableName;
begin
  Result := FFeatures[Index];
end;

function TPascalTypeShapingPlanStage.GetPlan: TPascalTypeShapingPlan;
begin
  Result := FStages.Plan;
end;

procedure TPascalTypeShapingPlanStage.Remove(const AFeature: TTableName);
begin
  FFeatures.Remove(AFeature);
  FStages.DoRemoveFeature(AFeature);
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeShapingPlanStages
//
//------------------------------------------------------------------------------
constructor TPascalTypeShapingPlanStages.Create(APlan: TPascalTypeShapingPlan);
begin
  inherited Create;
  FPlan := APlan;
  FStages := TObjectList<TPascalTypeShapingPlanStage>.Create;
  FAllFeatures := TDictionary<TTableName, TPascalTypeShapingPlanStage>.Create;
end;

destructor TPascalTypeShapingPlanStages.Destroy;
begin
  FStages.Free;
  FAllFeatures.Free;
  inherited;
end;

function TPascalTypeShapingPlanStages.Add: TPascalTypeShapingPlanStage;
begin
  Result := TPascalTypeShapingPlanStage.Create(Self);
  FStages.Add(Result);
end;

procedure TPascalTypeShapingPlanStages.DoAddFeature(const AFeature: TTableName; AGlobal: boolean; AStage: TPascalTypeShapingPlanStage);
begin
  FAllFeatures.Add(AFeature, AStage);
  Plan.DoAddFeature(AFeature, AGlobal, AStage);
end;

procedure TPascalTypeShapingPlanStages.DoRemoveFeature(const AFeature: TTableName);
begin
  FAllFeatures.Remove(AFeature);
  Plan.DoRemoveFeature(AFeature);
end;

function TPascalTypeShapingPlanStages.GetCount: integer;
begin
  Result := FStages.Count;
end;

function TPascalTypeShapingPlanStages.GetEnumerator: TEnumerator<TPascalTypeShapingPlanStage>;
begin
  Result := FStages.GetEnumerator;
end;

function TPascalTypeShapingPlanStages.GetStage(Index: integer): TPascalTypeShapingPlanStage;
begin
  Result := FStages[Index];
end;

function TPascalTypeShapingPlanStages.HasFeature(const AFeature: TTableName): boolean;
begin
  Result := FAllFeatures.ContainsKey(AFeature);
end;

procedure TPascalTypeShapingPlanStages.RemoveFeature(const AFeature: TTableName);
var
  Stage: TPascalTypeShapingPlanStage;
begin
  if (FAllFeatures.TryGetValue(AFeature, Stage)) then
    Stage.Remove(AFeature);
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeShapingPlan
//
//------------------------------------------------------------------------------
constructor TPascalTypeShapingPlan.Create;
begin
  inherited Create;
  FStages := TPascalTypeShapingPlanStages.Create(Self);
end;

destructor TPascalTypeShapingPlan.Destroy;
begin
  FStages.Free;
  inherited;
end;

procedure TPascalTypeShapingPlan.DoAddFeature(const AFeature: TTableName; AGlobal: boolean; AStage: TPascalTypeShapingPlanStage);
begin
  if (AGlobal) then
    FGlobalFeatures.Add(AFeature);
end;

procedure TPascalTypeShapingPlan.DoRemoveFeature(const AFeature: TTableName);
begin
  FGlobalFeatures.Remove(AFeature);
end;

function TPascalTypeShapingPlan.GetEnumerator: TEnumerator<TPascalTypeShapingPlanStage>;
begin
  Result := FStages.GetEnumerator;
end;

procedure TPascalTypeShapingPlan.AddFeature(const AFeature: TTableName; AGlobal: boolean; AStage: TPascalTypeShapingPlanStage);
begin
  // Stage.Add also checks for this but since we would like to
  // avoid adding a new empty space if the feature already exist
  // we need to do it here too.
  if (HasFeature(AFeature)) then
    exit;

  if (AStage = nil) then
  begin
    if (FStages.Count > 0) then
      AStage := FStages[FStages.Count-1]
    else
      AStage := FStages.Add;
  end;

  AStage.Add(AFeature, AGlobal);
end;

procedure TPascalTypeShapingPlan.AddFeatures(const AFeatures: TTableNames; AGlobal: boolean; AStage: TPascalTypeShapingPlanStage);
var
  Feature: TTableName;
begin
  for Feature in AFeatures do
    AddFeature(Feature, AGlobal, AStage);
end;

procedure TPascalTypeShapingPlan.ApplyUserFeatures(AFeatures: TPascalTypeShaperFeatures);
var
  Feature: TTableName;
begin
  // We use a feature dictionary because we need the ability to associate a boolean
  // value with the feature tag in order to allow the user to disable features.
  for Feature in AFeatures do
    if (AFeatures[Feature]) then
      AddFeature(Feature)
    else
      RemoveFeature(Feature);
end;

function TPascalTypeShapingPlan.HasFeature(const AFeature: TTableName): boolean;
begin
  Result := FStages.HasFeature(AFeature);
end;

procedure TPascalTypeShapingPlan.RemoveFeature(const AFeature: TTableName);
begin
  FStages.RemoveFeature(AFeature);
end;

//------------------------------------------------------------------------------
//
//              TPascalTypeShaperFeatures
//
//------------------------------------------------------------------------------
procedure TPascalTypeShaperFeatures.Changed;
begin
  if (Assigned(FOnChanged)) then
    FOnChanged(Self);
end;

constructor TPascalTypeShaperFeatures.Create;
begin
  inherited Create;
  FFeatures := TDictionary<TTableName, boolean>.Create;
end;

destructor TPascalTypeShaperFeatures.Destroy;
begin
  FFeatures.Free;
  inherited;
end;

function TPascalTypeShaperFeatures.GetEnumerator: TEnumerator<TTableName>;
begin
  Result := FFeatures.Keys.GetEnumerator;
end;

function TPascalTypeShaperFeatures.GetFeatureEnabled(const AKey: TTableName): boolean;
begin
  Result := IsEnabled(AKey, FEnableAll);
end;

function TPascalTypeShaperFeatures.IsEnabled(const AKey: TTableName; ADefault: boolean): boolean;
begin
  if (not FFeatures.TryGetValue(AKey, Result)) then
    Result := ADefault;
end;

procedure TPascalTypeShaperFeatures.SetFeatureEnabled(const AKey: TTableName; const Value: boolean);
begin
  FFeatures.AddOrSetValue(AKey, Value);
  Changed;
end;

end.

