unit PascalType.Tables.Postscript.Operands;

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
  Classes,
  SysUtils,
  PT_Types,
  PT_Classes,
  PascalType.Tables,
  PascalType.Tables.Postscript;

type
  TPascalTypePostscriptOperandShortInt = class(TCustomPascalTypePostscriptDictOperand)
  private
    FValue: ShortInt;
  protected
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsSingle: Single; override;
  public
    procedure Assign(Source: TPersistent); override;

    property Value: ShortInt read FValue write FValue;
  end;

  TPascalTypePostscriptOperandComposite = class(TCustomPascalTypePostscriptDictOperand)
  private
    FValue: SmallInt;
  protected
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsSingle: Single; override;
  public
    procedure Assign(Source: TPersistent); override;

    property Value: SmallInt read FValue write FValue;
  end;

  TPascalTypePostscriptOperandSmallInt = class(TCustomPascalTypePostscriptDictOperand)
  private
    FValue: SmallInt;
  protected
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsSingle: Single; override;
  public
    procedure Assign(Source: TPersistent); override;

    property Value: SmallInt read FValue write FValue;
  end;

  TPascalTypePostscriptOperandInteger = class(TCustomPascalTypePostscriptDictOperand)
  private
    FValue: Integer;
  protected
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsSingle: Single; override;
  public
    procedure Assign(Source: TPersistent); override;

    property Value: Integer read FValue write FValue;
  end;

  TPascalTypePostscriptOperandBCD = class(TCustomPascalTypePostscriptDictOperand)
  private
    FValue: string;
  protected
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsSingle: Single; override;
  public
    procedure Assign(Source: TPersistent); override;

    property Value: string read FValue write FValue;
  end;

implementation

{ TPascalTypePostscriptOperandShortInt }

procedure TPascalTypePostscriptOperandShortInt.Assign(Source: TPersistent);
begin
  if Source is TPascalTypePostscriptOperandShortInt then
    FValue := TPascalTypePostscriptOperandShortInt(Source).FValue
  else
    inherited;
end;

function TPascalTypePostscriptOperandShortInt.GetAsInteger: Integer;
begin
  Result := FValue;
end;

function TPascalTypePostscriptOperandShortInt.GetAsSingle: Single;
begin
  Result := FValue;
end;

function TPascalTypePostscriptOperandShortInt.GetAsString: string;
begin
  Result := IntToStr(FValue);
end;


{ TPascalTypePostscriptOperandComposite }

procedure TPascalTypePostscriptOperandComposite.Assign(Source: TPersistent);
begin
  if Source is TPascalTypePostscriptOperandComposite then
    FValue := TPascalTypePostscriptOperandComposite(Source).FValue
  else
    inherited;
end;

function TPascalTypePostscriptOperandComposite.GetAsInteger: Integer;
begin
  Result := FValue;
end;

function TPascalTypePostscriptOperandComposite.GetAsSingle: Single;
begin
  Result := FValue;
end;

function TPascalTypePostscriptOperandComposite.GetAsString: string;
begin
  Result := IntToStr(FValue);
end;


{ TPascalTypePostscriptOperandSmallInt }

procedure TPascalTypePostscriptOperandSmallInt.Assign(Source: TPersistent);
begin
  if Source is TPascalTypePostscriptOperandSmallInt then
    FValue := TPascalTypePostscriptOperandSmallInt(Source).FValue
  else
    inherited;
end;

function TPascalTypePostscriptOperandSmallInt.GetAsInteger: Integer;
begin
  Result := FValue;
end;

function TPascalTypePostscriptOperandSmallInt.GetAsSingle: Single;
begin
  Result := FValue;
end;

function TPascalTypePostscriptOperandSmallInt.GetAsString: string;
begin
  Result := IntToStr(FValue);
end;


{ TPascalTypePostscriptOperandInteger }

procedure TPascalTypePostscriptOperandInteger.Assign(Source: TPersistent);
begin
  if Source is TPascalTypePostscriptOperandInteger then
    FValue := TPascalTypePostscriptOperandInteger(Source).FValue
  else
    inherited;
end;

function TPascalTypePostscriptOperandInteger.GetAsInteger: Integer;
begin
  Result := FValue;
end;

function TPascalTypePostscriptOperandInteger.GetAsSingle: Single;
begin
  Result := FValue;
end;

function TPascalTypePostscriptOperandInteger.GetAsString: string;
begin
  Result := IntToStr(FValue);
end;


{ TPascalTypePostscriptOperandBCD }

procedure TPascalTypePostscriptOperandBCD.Assign(Source: TPersistent);
begin
  if Source is TPascalTypePostscriptOperandBCD then
    FValue := TPascalTypePostscriptOperandBCD(Source).FValue
  else
    inherited;
end;

function TPascalTypePostscriptOperandBCD.GetAsInteger: Integer;
begin
  Result := Round(GetAsSingle);
end;

function TPascalTypePostscriptOperandBCD.GetAsSingle: Single;
begin
  Result := StrToFloat(FValue);
end;

function TPascalTypePostscriptOperandBCD.GetAsString: string;
begin
  Result := FValue;
end;

end.
