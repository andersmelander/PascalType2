unit PascalType.Tables.OpenType.Substitution;

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
  PascalType.Types,
  PascalType.Tables,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Coverage,
  PascalType.Tables.OpenType.Lookup;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeSubstitutionLookupTable
//
//------------------------------------------------------------------------------
// Common base class for GSUB lookup tables
//------------------------------------------------------------------------------
type
  TCustomOpenTypeSubstitutionLookupTable = class;
  TOpenTypeSubstitutionLookupTableClass = class of TCustomOpenTypeSubstitutionLookupTable;

  TCustomOpenTypeSubstitutionLookupTable = class abstract(TCustomOpenTypeLookupTable)
  private
    class var
      FSubstitutionFormatRegistry: TDictionary<TGlyphSubstitution, TOpenTypeSubstitutionLookupTableClass>;
  protected
    function GetSubstitutionFormat: TGlyphSubstitution;
  public
    class destructor Destroy;

    class procedure RegisterSubstitutionFormat(ASubstFormat: TGlyphSubstitution; ASubstitutionTableClass: TOpenTypeSubstitutionLookupTableClass);
    class function GetSubstitutionLookupTableClass(ASubstFormat: TGlyphSubstitution): TOpenTypeSubstitutionLookupTableClass;

    property SubstitutionFormat: TGlyphSubstitution read GetSubstitutionFormat;
  end;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeSubstitutionSubTable
//
//------------------------------------------------------------------------------
// GSUB lookup sub tables
//------------------------------------------------------------------------------
type
  TCustomOpenTypeSubstitutionSubTable = class abstract(TCustomOpenTypeLookupSubTableWithCoverage)
  private
  protected
  public
  end;

  TOpenTypeSubstitutionSubTableClass = class of TCustomOpenTypeSubstitutionSubTable;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  System.SysUtils,
{$ifdef DEBUG}
  WinApi.Windows,
  TypInfo,
{$endif DEBUG}
  PascalType.ResourceStrings;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypeSubstitutionLookupTable
//
//------------------------------------------------------------------------------
class destructor TCustomOpenTypeSubstitutionLookupTable.Destroy;
begin
  FreeAndNil(FSubstitutionFormatRegistry);
end;

function TCustomOpenTypeSubstitutionLookupTable.GetSubstitutionFormat: TGlyphSubstitution;
begin
  Result := TGlyphSubstitution(LookupType);
end;


class function TCustomOpenTypeSubstitutionLookupTable.GetSubstitutionLookupTableClass(ASubstFormat: TGlyphSubstitution): TOpenTypeSubstitutionLookupTableClass;
begin
  if (FSubstitutionFormatRegistry = nil) or (not FSubstitutionFormatRegistry.TryGetValue(ASubstFormat, Result)) then
    Result := nil;
{$ifdef DEBUG}
  if (Result = nil) then
    OutputDebugString(PChar(Format('GSUB format type not implemented:  %d (%s)', [Ord(ASubstFormat), GetEnumName(TypeInfo(TGlyphSubstitution), Ord(ASubstFormat))])));
{$endif DEBUG}
end;

class procedure TCustomOpenTypeSubstitutionLookupTable.RegisterSubstitutionFormat(ASubstFormat: TGlyphSubstitution;
  ASubstitutionTableClass: TOpenTypeSubstitutionLookupTableClass);
begin
  if (FSubstitutionFormatRegistry = nil) then
    FSubstitutionFormatRegistry := TDictionary<TGlyphSubstitution, TOpenTypeSubstitutionLookupTableClass>.Create;

  FSubstitutionFormatRegistry.AddOrSetValue(ASubstFormat, ASubstitutionTableClass);
end;


//------------------------------------------------------------------------------

end.
