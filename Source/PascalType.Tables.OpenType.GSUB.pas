unit PascalType.Tables.OpenType.GSUB;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'GSUB' table type                                     //
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
//              TOpenTypeGlyphSubstitutionTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gsub
//------------------------------------------------------------------------------
type
  TOpenTypeGlyphSubstitutionTable = class(TCustomOpenTypeCommonTable)
  private
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    function GetLookupTableClass(ALookupType: Word): TOpenTypeLookupTableClass; override;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  PascalType.Tables.OpenType.Substitution;

//------------------------------------------------------------------------------
//
//              TOpenTypeGlyphSubstitutionTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeGlyphSubstitutionTable.Create(AParent: TCustomPascalTypeTable);
const
  CGlyphSubstitutionDefaultVersion: TFixedPoint = (Fixed: $00010000);
begin
  inherited;

  Version := CGlyphSubstitutionDefaultVersion;
end;

function TOpenTypeGlyphSubstitutionTable.GetLookupTableClass(ALookupType: Word): TOpenTypeLookupTableClass;
begin
  Result := TCustomOpenTypeSubstitutionLookupTable.GetSubstitutionLookupTableClass(TGlyphSubstitution(ALookupType));
end;

class function TOpenTypeGlyphSubstitutionTable.GetTableType: TTableType;
begin
  Result := 'GSUB';
end;

//------------------------------------------------------------------------------

initialization

  RegisterPascalTypeTable(TOpenTypeGlyphSubstitutionTable);

end.
