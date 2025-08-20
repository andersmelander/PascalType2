unit PascalType.Types.Color;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      Color support                                         //
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
//  The initial developer of this code is Anders Melander.                    //
//                                                                            //
//  Portions created by Anders Melander are Copyright (C) 2024                //
//  by Anders Melander. All Rights Reserved.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

{$I PT_Compiler.inc}

uses
  Generics.Collections,
  Generics.Defaults,
  Classes,
  PascalType.Types,
  PascalType.Classes;

type
  TColoredGlyph = record
    GlyphID: TGlyphID;
    PaletteIndex: integer;
  end;
  TColoredGlyphs = TArray<TColoredGlyph>;

  IPascalTypeColorGlyphLookup = interface
    ['{2A647E57-E177-4269-B88E-AA8BF1D44B80}']
    function GetColoredGlyph(GlyphID: TGlyphID; var ColoredGlyphs: TColoredGlyphs): boolean;
  end;

  IPascalTypeColorGlyphProvider = interface
    ['{C6849FB3-4E80-446D-966A-C0DD946FD6AE}']
    function GetColorGlyphLookup: IPascalTypeColorGlyphLookup;
  end;

type
  TPaletteColor = packed record
    case Integer of
      0: (B, G, R, A: Byte);
      1: (Blue, Green, Red, Alpha: Byte);
      2: (ARGB: Cardinal);
  end;

  IPascalTypeColorLookup = interface
    ['{A3068043-83C2-4447-9770-12F55010FD41}']
    function GetPaletteColor(PaletteIndex: integer; ColorIndex: integer): TPaletteColor;
    property PaletteColors[PaletteIndex, ColorIndex: integer]: TPaletteColor read GetPaletteColor;
  end;

  IPascalTypeColorProvider = interface
    ['{7B35D3D7-0B04-479B-8DBA-E5F43B9ADE3A}']
    function GetColorLookup: IPascalTypeColorLookup;
  end;

implementation

end.
