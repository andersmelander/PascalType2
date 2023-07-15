unit PascalType.Tables.TrueType.Panose;

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
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypePanoseTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/os2#panose
//------------------------------------------------------------------------------
// OS/2 panose sub-tables
//------------------------------------------------------------------------------
type
  TCustomPascalTypePanoseTable = class abstract(TCustomPascalTypeTable)
  private type
    TPanoseArray = array[0..9] of Byte;
  private
    function GetData(Index: Byte): Byte;
    procedure SetData(Index: Byte; const Value: Byte);
  protected
    FData: TPanoseArray;

    function GetInternalFamilyType: Byte; virtual;
    class function GetFamilyType: Byte; virtual; abstract;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Data[Index: Byte]: Byte read GetData write SetData;
    property FamilyType: Byte read GetInternalFamilyType;
  end;

  TPascalTypePanoseClass = class of TCustomPascalTypePanoseTable;


//------------------------------------------------------------------------------
//
//              TPascalTypeDefaultPanoseTable
//
//------------------------------------------------------------------------------
type
  TPascalTypeDefaultPanoseTable = class(TCustomPascalTypePanoseTable)
  private
    FFamilyType: Byte;
  protected
    function GetInternalFamilyType: Byte; override;
  public
    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
    class function GetFamilyType: Byte; override;

    property FamilyType: Byte read FFamilyType;
  end;


//------------------------------------------------------------------------------
//
//              Panose class registration
//
//------------------------------------------------------------------------------
// https://monotype.github.io/panose/pan1.htm
//------------------------------------------------------------------------------
procedure RegisterPascalTypePanose(PanoseClass: TPascalTypePanoseClass);
procedure RegisterPascalTypePanoses(PanoseClasses: array of TPascalTypePanoseClass);
function FindPascalTypePanoseByType(PanoseType: Byte): TPascalTypePanoseClass;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.ResourceStrings;

//------------------------------------------------------------------------------
//
//              Panose class registration
//
//------------------------------------------------------------------------------
var
  GPanoseClasses: array of TPascalTypePanoseClass;

function IsPascalTypePanoseRegistered(PanoseClass: TPascalTypePanoseClass): Boolean;
var
  PanoseClassIndex: Integer;
begin
  Result := False;
  for PanoseClassIndex := 0 to High(GPanoseClasses) do
    if GPanoseClasses[PanoseClassIndex] = PanoseClass then
    begin
      Result := True;
      Exit;
    end;
end;

procedure RegisterPascalTypePanose(PanoseClass: TPascalTypePanoseClass);
begin
  Assert(IsPascalTypePanoseRegistered(PanoseClass) = False);
  SetLength(GPanoseClasses, Length(GPanoseClasses) + 1);
  GPanoseClasses[High(GPanoseClasses)] := PanoseClass;
end;

procedure RegisterPascalTypePanoses(PanoseClasses: array of TPascalTypePanoseClass);
var
  PanoseClassIndex: Integer;
begin
  for PanoseClassIndex := 0 to High(PanoseClasses) do
    RegisterPascalTypePanose(PanoseClasses[PanoseClassIndex]);
end;

function FindPascalTypePanoseByType(PanoseType: Byte): TPascalTypePanoseClass;
var
  PanoseClassIndex: Integer;
begin
  Result := nil;
  for PanoseClassIndex := 0 to High(GPanoseClasses) do
    if GPanoseClasses[PanoseClassIndex].GetFamilyType = PanoseType then
    begin
      Result := GPanoseClasses[PanoseClassIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown Table Class: ' + TableType);
end;


//------------------------------------------------------------------------------
//
//              TCustomPascalTypePanoseTable
//
//------------------------------------------------------------------------------
procedure TCustomPascalTypePanoseTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomPascalTypePanoseTable then
    FData := TCustomPascalTypePanoseTable(Source).FData;
end;

function TCustomPascalTypePanoseTable.GetData(Index: Byte): Byte;
begin
  if not(Index in [Low(TPanoseArray)..High(TPanoseArray)]) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FData[Index];
end;

function TCustomPascalTypePanoseTable.GetInternalFamilyType: Byte;
begin
  Result := GetFamilyType;
end;

procedure TCustomPascalTypePanoseTable.SetData(Index: Byte; const Value: Byte);
begin
  if not(Index in [Low(TPanoseArray)..High(TPanoseArray)]) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  FData[Index] := Value;
end;

procedure TCustomPascalTypePanoseTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  Stream.Read(FData[0], SizeOf(TPanoseArray));
end;

procedure TCustomPascalTypePanoseTable.SaveToStream(Stream: TStream);
begin
  inherited;

  Stream.Write(FData[0], SizeOf(TPanoseArray));
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeDefaultPanoseTable
//
//------------------------------------------------------------------------------
function TPascalTypeDefaultPanoseTable.GetInternalFamilyType: Byte;
begin
  Result := FFamilyType;
end;

class function TPascalTypeDefaultPanoseTable.GetFamilyType: Byte;
begin
  Result := 0; // not specified and thus identifier for unknown panose type
end;

procedure TPascalTypeDefaultPanoseTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  // read family type frem stream prior to any other data
  Stream.Read(FFamilyType, 1);

  inherited;
end;

procedure TPascalTypeDefaultPanoseTable.SaveToStream(Stream: TStream);
begin
  // write family type frem stream prior to any other data
  Stream.Write(FFamilyType, 1);

  inherited;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

end.
