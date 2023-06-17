unit PascalType.Shaper.Layout;

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
  PascalType.Tables.OpenType.Common,
  PascalType.Tables.OpenType.GSUB,
  PascalType.Tables.OpenType.GPOS,
  PascalType.Tables.OpenType.Feature,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Shaper.Plan;


type
  TZeroMarkWidths = (zmwNever, zmwBeforePositioning, zmwAfterPositioning);

//------------------------------------------------------------------------------
//
//              TCustomPascalTypeLayoutEngine
//
//------------------------------------------------------------------------------
// The layout engine represent the font technology specific layer.
// Each font technology (OpenType, CFF, etc.) will have its own concrete
// layout engine class.
// Due to the unit and class dependencies we cannot have the font create the
// engine, so instead it is created by hardcoded rules in the shaper (for now).
//------------------------------------------------------------------------------
type
  TCustomPascalTypeLayoutEngine = class abstract
  private
    FFont: TCustomPascalTypeFontFace;
    FZeroMarkWidths: TZeroMarkWidths;
  private
  protected
    function GetAvailableFeatures: TTableNames; virtual;
    procedure Setup(var AGlyphs: TPascalTypeGlyphString); virtual;
    procedure Reset; virtual;
    procedure ExecuteSubstitution(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString);
    procedure ExecutePositioning(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString);
    function ApplySubstitution(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TTableNames; virtual; abstract;
    function ApplyPositioning(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TTableNames; virtual; abstract;
    procedure PreProcessPositioning(var AGlyphs: TPascalTypeGlyphString); virtual;
    procedure PostProcessPositioning(var AGlyphs: TPascalTypeGlyphString; var AAppliedFeatures: TTableNames); virtual;
    procedure ClearMarkAdvance(var AGlyphs: TPascalTypeGlyphString);
    procedure ApplyKerning(var AGlyphs: TPascalTypeGlyphString);
    procedure ApplyRightToLeft(var AGlyphs: TPascalTypeGlyphString);
  public
    constructor Create(AFont: TCustomPascalTypeFontFace); virtual;
    destructor Destroy; override;

    procedure Layout(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString); virtual;

    property Font: TCustomPascalTypeFontFace read FFont;
    property ZeroMarkWidths: TZeroMarkWidths read FZeroMarkWidths write FZeroMarkWidths;

    property AvailableFeatures: TTableNames read GetAvailableFeatures;
  end;


implementation

uses
  System.Math,
{$ifdef DEBUG}
  WinApi.Windows,
{$endif DEBUG}
  PascalType.Tables.OpenType.Script,
  PascalType.Tables.OpenType.LanguageSystem,
  PascalType.Tables.TrueType.kern; // TPascalTypeKerningTable


//------------------------------------------------------------------------------
//
//              TCustomPascalTypeLayoutEngine
//
//------------------------------------------------------------------------------
constructor TCustomPascalTypeLayoutEngine.Create(AFont: TCustomPascalTypeFontFace);
begin
  inherited Create;

  FFont := AFont;
end;

destructor TCustomPascalTypeLayoutEngine.Destroy;
begin

  inherited;
end;

procedure TCustomPascalTypeLayoutEngine.Reset;
begin
end;

procedure TCustomPascalTypeLayoutEngine.ApplyKerning(var AGlyphs: TPascalTypeGlyphString);
var
  KerningTable: TPascalTypeKerningTable;
  KerningSubTable: TPascalTypeKerningSubTable;
  i, j: integer;
  Delta: integer;
{$ifdef DEBUG}
  AnyApplied: boolean;
{$endif DEBUG}
begin
  // TODO : Move this to another unit
{$ifdef DEBUG}
  AnyApplied := False;
{$endif DEBUG}

  KerningTable := Font.GetTableByTableType('kern') as TPascalTypeKerningTable;

  for i := 0 to AGlyphs.Count-2 do
  begin
    for j := 0 to KerningTable.KerningSubtableCount-1 do
    begin
      KerningSubTable := KerningTable.KerningSubtable[j];

      // Ignore vertical kerning
      if (KerningSubTable.IsCrossStream) then
        continue;

      case KerningSubTable.Version of
        0:
          if (not KerningSubTable.IsHorizontal) then
            continue;

      else
        continue;
      end;

      // TODO : GetKerningValue should return a boolean indicating match/no-match
      Delta := KerningSubTable.FormatTable.GetKerningValue(AGlyphs[i].GlyphID, AGlyphs[i+1].GlyphID);

      if (Delta <> 0) then
      begin
{$ifdef DEBUG}
        AnyApplied := True;
{$endif DEBUG}
        if (KerningSubTable.IsMinimum) then
          AGlyphs[i].XAdvance := Max(Delta, AGlyphs[i].XAdvance)
        else
        if (KerningSubTable.IsReplace) then
          AGlyphs[i].XAdvance := Delta
        else
          AGlyphs[i].XAdvance := AGlyphs[i].XAdvance + Delta;
      end;
    end;
  end;
{$ifdef DEBUG}
  if (AnyApplied) then
    OutputDebugString('Applied kern table');
{$endif DEBUG}
end;

procedure TCustomPascalTypeLayoutEngine.ApplyRightToLeft(var AGlyphs: TPascalTypeGlyphString);
begin
  if (AGlyphs.Direction = dirRightToLeft) then
    AGlyphs.Reverse;
end;

procedure TCustomPascalTypeLayoutEngine.ClearMarkAdvance(var AGlyphs: TPascalTypeGlyphString);
var
  Glyph: TPascalTypeGlyph;
begin
  for Glyph in AGlyphs do
    if (Glyph.IsMark) then
    begin
      Glyph.XAdvance := 0;
      Glyph.YAdvance := 0;
    end;
end;

procedure TCustomPascalTypeLayoutEngine.Layout(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString);
begin
  if (AGlyphs.Count = 0) then
    exit;


  Setup(AGlyphs);


  (*
  ** Substitute glyphs
  *)
  ExecuteSubstitution(APlan, AGlyphs);


  (*
  ** Position glyphs
  *)
  ExecutePositioning(APlan, AGlyphs);


  (*
  ** Hide do-nothing characters
  *)
  // TODO : Why not do this earlier?
  AGlyphs.HideDefaultIgnorables;
end;

procedure TCustomPascalTypeLayoutEngine.Setup(var AGlyphs: TPascalTypeGlyphString);
begin
end;

procedure TCustomPascalTypeLayoutEngine.ExecuteSubstitution(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString);
begin
  ApplySubstitution(APlan, AGlyphs);
end;

function TCustomPascalTypeLayoutEngine.GetAvailableFeatures: TTableNames;
begin
  Result := nil;
end;

procedure TCustomPascalTypeLayoutEngine.ExecutePositioning(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString);
var
  AppliedFeatures: TTableNames;
begin
  PreProcessPositioning(AGlyphs);

  AppliedFeatures := ApplyPositioning(APlan, AGlyphs);

  PostProcessPositioning(AGlyphs, AppliedFeatures);
end;

procedure TCustomPascalTypeLayoutEngine.PreProcessPositioning(var AGlyphs: TPascalTypeGlyphString);
var
  Glyph: TPascalTypeGlyph;
begin
  // Get default positions
  for Glyph in AGlyphs do
    Glyph.XAdvance := Font.GetAdvanceWidth(Glyph.GlyphID);
end;

procedure TCustomPascalTypeLayoutEngine.PostProcessPositioning(var AGlyphs: TPascalTypeGlyphString; var AAppliedFeatures: TTableNames);
begin
  // Use unicode properties to position marks if no features were applied (i.e. no GPOS table)
(* TODO
  if (AAppliedFeatures = []) and (FallbackPosition) then
  begin
    if (FUnicodeLayoutEngine = nil) then
      FUnicodeLayoutEngine := TPascalTypeUnicodeLayoutEngine.Create();

    FUnicodeLayoutEngine.PositionGlyphs(AGlyphs);
  end;
*)

  // Apply old-style TrueType/AAT kerning table if kerning is eabled in features but GPOS didn't have a kern lookup.
  if (not AAppliedFeatures.Contains('kern')) and (Font.GetTableByTableName('kern') <> nil) then
  begin
    ApplyKerning(AGlyphs);
    AAppliedFeatures.Add('kern');
  end;
end;

end.
