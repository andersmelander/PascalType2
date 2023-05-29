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
  PT_Types,
  PT_Classes,
  PascalType.Unicode,
  PascalType.GlyphString,
  PascalType.FontFace.SFNT,
  PascalType.Tables.OpenType.GSUB,
  PascalType.Tables.OpenType.Feature;


type
  TPascalTypeTableNames = array of TTableName;

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
  private
    FStages: TPascalTypeShapingPlanStages;
    FFeatures: TList<TTableName>;
    function GetCount: integer;
    function GetFeature(Index: integer): TTableName;
  public
    constructor Create(AStages: TPascalTypeShapingPlanStages);
    destructor Destroy; override;

    procedure Add(const AKey: TTableName); overload;
    procedure Add(const AKeys: TPascalTypeTableNames); overload;
    procedure Remove(const AKey: TTableName);

    function GetEnumerator: TEnumerator<TTableName>;

    property Count: integer read GetCount;
    property Features[Index: integer]: TTableName read GetFeature; default;
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
    procedure DoAddFeature(const AKey: TTableName; AStage: TPascalTypeShapingPlanStage);
    procedure DoRemoveFeature(const AKey: TTableName);
  public
    constructor Create(APlan: TPascalTypeShapingPlan);
    destructor Destroy; override;

    function AddStage: TPascalTypeShapingPlanStage;

    procedure AddFeature(const AKey: TTableName; AStage: TPascalTypeShapingPlanStage = nil);
    procedure AddFeatures(const AKeys: TPascalTypeTableNames; AStage: TPascalTypeShapingPlanStage = nil);
    procedure RemoveFeature(const AKey: TTableName);
    function HasFeature(const AKey: TTableName): boolean;

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
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddFeature(const AKey: TTableName);
    procedure RemoveFeature(const AKey: TTableName);
    function HasFeature(const AKey: TTableName): boolean;

    property Stages: TPascalTypeShapingPlanStages read FStages;
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
  FFeatures := TList<TTableName>.Create;
end;

destructor TPascalTypeShapingPlanStage.Destroy;
begin
  FFeatures.Free;
  inherited;
end;

procedure TPascalTypeShapingPlanStage.Add(const AKey: TTableName);
var
  Index: integer;
begin
  if (FStages.HasFeature(AKey)) then
    exit;

  if (not FFeatures.BinarySearch(AKey, Index)) then
  begin
    FFeatures.Insert(Index, AKey);
    FStages.DoAddFeature(AKey, Self);
  end;
end;

procedure TPascalTypeShapingPlanStage.Add(const AKeys: TPascalTypeTableNames);
var
  Key: TTableName;
begin
  for Key in AKeys do
    Add(Key);
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

procedure TPascalTypeShapingPlanStage.Remove(const AKey: TTableName);
var
  Index: integer;
begin
  if (FFeatures.BinarySearch(AKey, Index)) then
  begin
    FFeatures.Delete(Index);
    FStages.DoRemoveFeature(AKey);
  end;
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

procedure TPascalTypeShapingPlanStages.AddFeature(const AKey: TTableName; AStage: TPascalTypeShapingPlanStage);
begin
  if (FAllFeatures.ContainsKey(AKey)) then
    exit;

  if (AStage = nil) then
  begin
    if (FStages.Count > 0) then
      AStage := FStages.Last
    else
      AStage := AddStage;
  end;

  AStage.Add(AKey);
end;

procedure TPascalTypeShapingPlanStages.AddFeatures(const AKeys: TPascalTypeTableNames; AStage: TPascalTypeShapingPlanStage);
var
  Key: TTableName;
begin
  if (AStage = nil) then
  begin
    if (FStages.Count > 0) then
      AStage := FStages.Last
    else
      AStage := AddStage;
  end;

  for Key in AKeys do
    AddFeature(Key, AStage);
end;

function TPascalTypeShapingPlanStages.AddStage: TPascalTypeShapingPlanStage;
begin
  Result := TPascalTypeShapingPlanStage.Create(Self);
  FStages.Add(Result);
end;

procedure TPascalTypeShapingPlanStages.DoAddFeature(const AKey: TTableName; AStage: TPascalTypeShapingPlanStage);
begin
  FAllFeatures.Add(AKey, AStage);
end;

procedure TPascalTypeShapingPlanStages.DoRemoveFeature(const AKey: TTableName);
begin
  FAllFeatures.Remove(AKey);
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

function TPascalTypeShapingPlanStages.HasFeature(const AKey: TTableName): boolean;
begin
  Result := FAllFeatures.ContainsKey(AKey);
end;

procedure TPascalTypeShapingPlanStages.RemoveFeature(const AKey: TTableName);
var
  Stage: TPascalTypeShapingPlanStage;
begin
  if (FAllFeatures.TryGetValue(AKey, Stage)) then
    Stage.Remove(AKey);
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

procedure TPascalTypeShapingPlan.AddFeature(const AKey: TTableName);
begin
  FStages.AddFeature(AKey);
end;

function TPascalTypeShapingPlan.HasFeature(const AKey: TTableName): boolean;
begin
  Result := FStages.HasFeature(AKey);
end;

procedure TPascalTypeShapingPlan.RemoveFeature(const AKey: TTableName);
begin
  FStages.RemoveFeature(AKey);
end;

end.

