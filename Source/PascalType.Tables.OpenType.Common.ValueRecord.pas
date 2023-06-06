unit PascalType.Tables.OpenType.Common.ValueRecord;

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

//------------------------------------------------------------------------------
//
//              TOpenTypeValueRecord
//
//------------------------------------------------------------------------------
// Shared Tables: Value Record
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#value-record
//------------------------------------------------------------------------------
(*
  GPOS subtables use ValueRecords to describe all the variables and values used
  to adjust the position of a glyph or set of glyphs. A ValueRecord may define
  any combination of X and Y values (in design units) to add to (positive
  values) or subtract from (negative values) the placement and advance values
  provided in the font. In non-variable fonts, a ValueRecord may also contain
  an offset to a Device table for each of the specified values. In a variable
  font, it may also contain an offset to a VariationIndex table for each of the
  specified values.

  Note that all fields of a ValueRecord are optional: to save space, only the
  fields that are required need be included in a given instance. Because the
  GPOS table uses ValueRecords for many purposes, the sizes and contents of
  ValueRecords may vary from subtable to subtable. A ValueRecord is always
  accompanied by a ValueFormat flags field that specifies which of the
  ValueRecord fields is present. If a ValueRecord specifies more than one
  value, the values must be listed in the order shown in the ValueRecord
  definition. If the associated ValueFormat flags indicate that a field is not
  present, then the next present field follows immediately after the last
  preceding, present field. The text-processing client must be aware of the
  flexible and variable nature of ValueRecords in the GPOS table.
*)
type
  TOpenTypeValueRecord = packed record
  private
    function GetEmpty: boolean;
  public
    xPlacement: SmallInt;       // Horizontal adjustment for placement, in design units.
    yPlacement: SmallInt;       // Vertical adjustment for placement, in design units.
    xAdvance: SmallInt;         // Horizontal adjustment for advance, in design units - only used for horizontal layout.
    yAdvance: SmallInt;         // Vertical adjustment for advance, in design units - only used for vertical layout.
    xPlaDeviceOffset: Word;     // Offset to Device table (non-variable font) / VariationIndex table (variable font) for horizontal placement, from beginning of the immediate parent table (SinglePos or PairPosFormat2 lookup subtable, PairSet table within a PairPosFormat1 lookup subtable) — may be NULL.
    yPlaDeviceOffset: Word;     // Offset to Device table (non-variable font) / VariationIndex table (variable font) for vertical placement, from beginning of the immediate parent table (SinglePos or PairPosFormat2 lookup subtable, PairSet table within a PairPosFormat1 lookup subtable) — may be NULL.
    xAdvDeviceOffset: Word;     // Offset to Device table (non-variable font) / VariationIndex table (variable font) for horizontal advance, from beginning of the immediate parent table (SinglePos or PairPosFormat2 lookup subtable, PairSet table within a PairPosFormat1 lookup subtable) — may be NULL.
    yAdvDeviceOffset: Word;     // Offset to Device table (non-variable font) / VariationIndex table (variable font) for vertical advance, from beginning of the immediate parent table (SinglePos or PairPosFormat2 lookup subtable, PairSet table within a PairPosFormat1 lookup subtable) — may be NULL.

    property IsEmpty: boolean read GetEmpty;
  end;

const
  VALUEFORMAT_X_PLACEMENT       = $0001;        // Includes horizontal adjustment for placement
  VALUEFORMAT_Y_PLACEMENT       = $0002;        // Includes vertical adjustment for placement
  VALUEFORMAT_X_ADVANCE         = $0004;        // Includes horizontal adjustment for advance
  VALUEFORMAT_Y_ADVANCE         = $0008;        // Includes vertical adjustment for advance
  VALUEFORMAT_X_PLACEMENT_DEVICE= $0010;        // Includes Device table (non-variable font) / VariationIndex table (variable font) for horizontal placement
  VALUEFORMAT_Y_PLACEMENT_DEVICE= $0020;        // Includes Device table (non-variable font) / VariationIndex table (variable font) for vertical placement
  VALUEFORMAT_X_ADVANCE_DEVICE  = $0040;        // Includes Device table (non-variable font) / VariationIndex table (variable font) for horizontal advance
  VALUEFORMAT_Y_ADVANCE_DEVICE  = $0080;        // Includes Device table (non-variable font) / VariationIndex table (variable font) for vertical advance
  VALUEFORMAT_Reserved          = $FF00;        // For future use (set to zero)


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

function TOpenTypeValueRecord.GetEmpty: boolean;
begin
  Result := (xPlacement = 0) and (yPlacement = 0) and (xAdvance = 0) and (yAdvance = 0);
end;

//------------------------------------------------------------------------------

end.

