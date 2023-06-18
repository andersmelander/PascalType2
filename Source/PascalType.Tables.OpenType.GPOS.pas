unit PascalType.Tables.OpenType.GPOS;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'GPOS' table type                                     //
//                                                                            //
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
  PT_Types,
  PT_Classes,
  PT_Tables,
  PascalType.Tables.OpenType,
  PascalType.Tables.OpenType.Common,
  PascalType.Tables.OpenType.Lookup;


//------------------------------------------------------------------------------
//
//              TOpenTypeGlyphPositionTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos
//------------------------------------------------------------------------------
type
  TOpenTypeGlyphPositionTable = class(TCustomOpenTypeCommonTable)
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    function IsExtensionLookupType(LookupType: Word): boolean; override;
    function GetLookupTableClass(ALookupType: Word): TOpenTypeLookupTableClass; override;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  PascalType.Tables.OpenType.Positioning;

//------------------------------------------------------------------------------
//
//              TOpenTypeGlyphPositionTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeGlyphPositionTable.Create(AParent: TCustomPascalTypeTable);
const
  CGlyphPositionDefaultVersion: TFixedPoint = (Fixed: $00010000);
begin
  inherited;

  Version := CGlyphPositionDefaultVersion;
end;

function TOpenTypeGlyphPositionTable.GetLookupTableClass(ALookupType: Word): TOpenTypeLookupTableClass;
begin
  Result := TCustomOpenTypePositioningLookupTable.GetPositioningLookupTableClass(TGlyphPositioning(ALookupType));
end;

class function TOpenTypeGlyphPositionTable.GetTableType: TTableType;
begin
  Result := 'GPOS';
end;

function TOpenTypeGlyphPositionTable.IsExtensionLookupType(LookupType: Word): boolean;
begin
  Result := (TGlyphPositioning(LookupType) = gpExtensionPositioning);
end;

//------------------------------------------------------------------------------

initialization

  RegisterPascalTypeTable(TOpenTypeGlyphPositionTable);

end.
