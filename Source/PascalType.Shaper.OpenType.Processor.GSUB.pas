unit PascalType.Shaper.OpenType.Processor.GSUB;

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
  PascalType.Tables.OpenType.Common,
  PascalType.Tables.OpenType.GSUB,
  PascalType.Shaper.OpenType.Processor;


//------------------------------------------------------------------------------
//
//              TPascalTypeOpenTypeProcessorGSUB
//
//------------------------------------------------------------------------------
// GSUB table processor
//------------------------------------------------------------------------------
type
  TPascalTypeOpenTypeProcessorGSUB = class(TCustomPascalTypeOpenTypeProcessor)
  private
    FSubstitutionTable: TOpenTypeGlyphSubstitutionTable;
  protected
    function GetTable: TCustomOpenTypeCommonTable; override;
  public
    constructor Create(AFont: TCustomPascalTypeFontFace; AScript: TTableType; ALanguage: TTableType; ADirection: TPascalTypeDirection); override;

    property SubstitutionTable: TOpenTypeGlyphSubstitutionTable read FSubstitutionTable;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  PT_Classes;

//------------------------------------------------------------------------------
//
//              TPascalTypeOpenTypeProcessorGSUB
//
//------------------------------------------------------------------------------
constructor TPascalTypeOpenTypeProcessorGSUB.Create(AFont: TCustomPascalTypeFontFace; AScript: TTableType; ALanguage: TTableType; ADirection: TPascalTypeDirection);
begin
  inherited;

  FSubstitutionTable := Font.GetTableByTableType(TOpenTypeGlyphSubstitutionTable.GetTableType) as TOpenTypeGlyphSubstitutionTable;
end;

function TPascalTypeOpenTypeProcessorGSUB.GetTable: TCustomOpenTypeCommonTable;
begin
  Result := FSubstitutionTable;
end;

end.
