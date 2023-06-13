unit PascalType.Shaper.Layout.OpenType;

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
  PT_Types,
  PascalType.FontFace.SFNT,
  PascalType.GlyphString,
  PascalType.Shaper.Plan,
  PascalType.Shaper.Layout,
  PascalType.Shaper.OpenType.Processor;


//------------------------------------------------------------------------------
//
//              TPascalTypeOpenTypeLayoutEngine
//
//------------------------------------------------------------------------------
type
  TPascalTypeOpenTypeLayoutEngine = class(TCustomPascalTypeLayoutEngine)
  private
    FGSUBProcessor: TCustomPascalTypeOpenTypeProcessor;
    FGPOSProcessor: TCustomPascalTypeOpenTypeProcessor;
  protected
    function GetAvailableFeatures: TTableNames; override;
    procedure Setup(var AGlyphs: TPascalTypeGlyphString); override;
    procedure Reset; override;
    function ApplySubstitution(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TTableNames; override;
    function ApplyPositioning(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TTableNames; override;
    procedure PreProcessPositioning(var AGlyphs: TPascalTypeGlyphString); override;
    procedure PostProcessPositioning(var AGlyphs: TPascalTypeGlyphString; var AAppliedFeatures: TTableNames); override;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace); override;
    destructor Destroy; override;

    procedure Layout(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString); override;
  end;

implementation

uses
  System.SysUtils,
  PascalType.Shaper.OpenType.Processor.GSUB,
  PascalType.Shaper.OpenType.Processor.GPOS;

//------------------------------------------------------------------------------
//
//              TCustomPascalTypeLayoutEngine
//
//------------------------------------------------------------------------------
constructor TPascalTypeOpenTypeLayoutEngine.Create(AFont: TCustomPascalTypeFontFace);
begin
  inherited Create(AFont);

end;

destructor TPascalTypeOpenTypeLayoutEngine.Destroy;
begin
  FGSUBProcessor.Free;
  FGPOSProcessor.Free;
  inherited;
end;

procedure TPascalTypeOpenTypeLayoutEngine.Setup(var AGlyphs: TPascalTypeGlyphString);
begin
  inherited;

  if (Font.GetTableByTableType('GSUB') <> nil) then
  begin
    Assert(FGSUBProcessor = nil);
    FGSUBProcessor := TPascalTypeOpenTypeProcessorGSUB.Create(Font, AGlyphs.Script, AGlyphs.Language, AGlyphs.Direction);
  end;

  if (Font.GetTableByTableType('GPOS') <> nil) then
  begin
    Assert(FGPOSProcessor = nil);
    FGPOSProcessor := TPascalTypeOpenTypeProcessorGPOS.Create(Font, AGlyphs.Script, AGlyphs.Language, AGlyphs.Direction);
  end;
end;

procedure TPascalTypeOpenTypeLayoutEngine.Reset;
begin
  inherited;

  FreeAndNil(FGSUBProcessor);
  FreeAndNil(FGPOSProcessor);
end;

function TPascalTypeOpenTypeLayoutEngine.GetAvailableFeatures: TTableNames;
begin
  Result := [];

  if (FGSUBProcessor <> nil) then
    Result := Result + FGSUBProcessor.AvailableFeatures;

  if (FGPOSProcessor <> nil) then
    Result := Result + FGPOSProcessor.AvailableFeatures;
end;

procedure TPascalTypeOpenTypeLayoutEngine.Layout(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString);
begin
  inherited;

  // Reverse output string if direction is RTL
  ApplyRightToLeft(AGlyphs);
end;

procedure TPascalTypeOpenTypeLayoutEngine.PreProcessPositioning(var AGlyphs: TPascalTypeGlyphString);
begin
  inherited;

  if (ZeroMarkWidths = zmwBeforePositioning) then
    ClearMarkAdvance(AGlyphs);
end;

function TPascalTypeOpenTypeLayoutEngine.ApplyPositioning(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TTableNames;
begin
  if (FGPOSProcessor = nil) then
    Exit(nil);

  Result := FGPOSProcessor.ExecutePlan(APlan, AGlyphs);
end;

procedure TPascalTypeOpenTypeLayoutEngine.PostProcessPositioning(var AGlyphs: TPascalTypeGlyphString; var AAppliedFeatures: TTableNames);
begin
  if (ZeroMarkWidths = zmwAfterPositioning) then
    ClearMarkAdvance(AGlyphs);

  inherited;
end;

function TPascalTypeOpenTypeLayoutEngine.ApplySubstitution(APlan: TPascalTypeShapingPlan; var AGlyphs: TPascalTypeGlyphString): TTableNames;
begin
  if (FGSUBProcessor = nil) then
    Exit(nil);

  Result := FGSUBProcessor.ExecutePlan(APlan, AGlyphs);
end;

end.


