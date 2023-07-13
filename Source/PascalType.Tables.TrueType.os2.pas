unit PascalType.Tables.TrueType.os2;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'OS/2' table type                                     //
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
  Classes,
  PT_Types,
  PT_Classes,
  PT_Tables,
  PascalType.Tables.TrueType.Panose;

//------------------------------------------------------------------------------
//
//              TPascalTypeOS2Table
//
//------------------------------------------------------------------------------
// OS/2 and Windows Metrics Table, required on Windows, optional on Apple
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/os2
// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6OS2.html
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//              TPascalTypeUnicodeRangeTable
//------------------------------------------------------------------------------
type
  TPascalTypeUnicodeRangeTable = class(TCustomPascalTypeTable)
  private
    FUnicodeRange: TOS2UnicodeRange;
    // Field is split into two bit fields of 96 and 36 bits each.
    // The low 96 bits are used to specify the Unicode blocks encompassed by the
    // font file. The high 32 bits are used to specify the character or script
    // sets covered by the font file. Bit assignments are pending. Set to 01

    function GetAsCardinal(Index: Byte): Cardinal;
    procedure SetAsCardinal(Index: Byte; const Value: Cardinal);
    function GetAsString: string;
    function GetSupportsAegeanNumbers: Boolean;
    function GetSupportsAlphabeticPresentationForms: Boolean;
    function GetSupportsAncientGreekNumbers: Boolean;
    function GetSupportsAncientSymbols: Boolean;
    function GetSupportsArabic: Boolean;
    function GetSupportsArabicPresentationFormsA: Boolean;
    function GetSupportsArabicPresentationFormsB: Boolean;
    function GetSupportsArabicSupplement: Boolean;
    function GetSupportsArmenian: Boolean;
    function GetSupportsArrows: Boolean;
    function GetSupportsBalinese: Boolean;
    function GetSupportsBasicLatin: Boolean;
    function GetSupportsBengali: Boolean;
    function GetSupportsBlockElements: Boolean;
    function GetSupportsBopomofo: Boolean;
    function GetSupportsBopomofoExtended: Boolean;
    function GetSupportsBoxDrawing: Boolean;
    function GetSupportsBraillePatterns: Boolean;
    function GetSupportsBuginese: Boolean;
    function GetSupportsBuhid: Boolean;
    function GetSupportsCarian: Boolean;
    function GetSupportsCham: Boolean;
    function GetSupportsCherokee: Boolean;
    function GetSupportsCJKCompatibility: Boolean;
    function GetSupportsCJKCompatibilityForms: Boolean;
    function GetSupportsCJKCompatibilityIdeographs: Boolean;
    function GetSupportsCJKCompatibilityIdeographsSupplement: Boolean;
    function GetSupportsCJKRadicalsSupplement: Boolean;
    function GetSupportsCJKStrokes: Boolean;
    function GetSupportsCJKSymbolsAndPunctuation: Boolean;
    function GetSupportsCJKUnifiedIdeographs: Boolean;
    function GetSupportsCombiningDiacriticalMarks: Boolean;
    function GetSupportsCombiningDiacriticalMarksForSymbols: Boolean;
    function GetSupportsCombiningDiacriticalMarksSupplement: Boolean;
    function GetSupportsCombiningHalfMarks: Boolean;
    function GetSupportsControlPictures: Boolean;
    function GetSupportsCoptic: Boolean;
    function GetSupportsCountingRodNumerals: Boolean;
    function GetSupportsCuneiform: Boolean;
    function GetSupportsCypriotSyllabary: Boolean;
    function GetSupportsCyrillic: Boolean;
    function GetSupportsCyrillicExtendedA: Boolean;
    function GetSupportsCyrillicExtendedB: Boolean;
    function GetSupportsCyrillicSupplement: Boolean;
    function GetSupportsDeseret: Boolean;
    function GetSupportsDevanagari: Boolean;
    function GetSupportsDingbats: Boolean;
    function GetSupportsDominoTiles: Boolean;
    function GetSupportsEnclosedAlphanumerics: Boolean;
    function GetSupportsEthiopic: Boolean;
    function GetSupportsEthiopicExtended: Boolean;
    function GetSupportsEthiopicSupplement: Boolean;
    function GetSupportsGeneralPunctuation: Boolean;
    function GetSupportsGeometricShapes: Boolean;
    function GetSupportsGeorgian: Boolean;
    function GetSupportsGeorgianSupplement: Boolean;
    function GetSupportsGlagolitic: Boolean;
    function GetSupportsGothic: Boolean;
    function GetSupportsGreekandCoptic: Boolean;
    function GetSupportsGreekExtended: Boolean;
    function GetSupportsGujarati: Boolean;
    function GetSupportsGurmukhi: Boolean;
    function GetSupportsHalfwidthAndFullwidthForms: Boolean;
    function GetSupportsHangulCompatibilityJamo: Boolean;
    function GetSupportsHangulJamo: Boolean;
    function GetSupportsHangulSyllables: Boolean;
    function GetSupportsHanunoo: Boolean;
    function GetSupportsHebrew: Boolean;
    function GetSupportsHiragana: Boolean;
    function GetSupportsIPAExtensions: Boolean;
    function GetSupportsKanbun: Boolean;
    function GetSupportsKangxiRadicals: Boolean;
    function GetSupportsKannada: Boolean;
    function GetSupportsKatakana: Boolean;
    function GetSupportsKatakanaPhoneticExtensions: Boolean;
    function GetSupportsKayahLi: Boolean;
    function GetSupportsKharoshthi: Boolean;
    function GetSupportsKhmer: Boolean;
    function GetSupportsKhmerSymbols: Boolean;
    function GetSupportsLao: Boolean;
    function GetSupportsLatin1Supplement: Boolean;
    function GetSupportsLatinExtendedA: Boolean;
    function GetSupportsLatinExtendedAdditional: Boolean;
    function GetSupportsLatinExtendedB: Boolean;
    function GetSupportsLatinExtendedC: Boolean;
    function GetSupportsLatinExtendedD: Boolean;
    function GetSupportsLepcha: Boolean;
    function GetSupportsLetterlikeSymbols: Boolean;
    function GetSupportsLimbu: Boolean;
    function GetSupportsLinearBIdeograms: Boolean;
    function GetSupportsLinearBSyllabary: Boolean;
    function GetSupportsLycian: Boolean;
    function GetSupportsLydian: Boolean;
    function GetSupportsMahjongTiles: Boolean;
    function GetSupportsMalayalam: Boolean;
    function GetSupportsMathematicalOperators: Boolean;
    function GetSupportsMiscellaneousMathematicalSymbolsA: Boolean;
    function GetSupportsMiscellaneousMathematicalSymbolsB: Boolean;
    function GetSupportsMiscellaneousSymbols: Boolean;
    function GetSupportsMiscellaneousSymbolsAndArrows: Boolean;
    function GetSupportsMiscellaneousTechnical: Boolean;
    function GetSupportsModifierToneLetters: Boolean;
    function GetSupportsMongolian: Boolean;
    function GetSupportsMusicalSymbols: Boolean;
    function GetSupportsMyanmar: Boolean;
    function GetSupportsNKo: Boolean;
    function GetSupportsNonPlane0: Boolean;
    function GetSupportsOgham: Boolean;
    function GetSupportsOlChiki: Boolean;
    function GetSupportsOldItalic: Boolean;
    function GetSupportsOldPersian: Boolean;
    function GetSupportsOpticalCharacterRecognition: Boolean;
    function GetSupportsOriya: Boolean;
    function GetSupportsOsmanya: Boolean;
    function GetSupportsPhagsPa: Boolean;
    function GetSupportsPhaistosDisc: Boolean;
    function GetSupportsPhoenician: Boolean;
    function GetSupportsPhoneticExtensions: Boolean;
    function GetSupportsPhoneticExtensionsSupplement: Boolean;
    function GetSupportsPrivateUseAreaPlane0: Boolean;
    function GetSupportsPrivateUsePlane15: Boolean;
    function GetSupportsPrivateUsePlane16: Boolean;
    function GetSupportsRejang: Boolean;
    function GetSupportsRunic: Boolean;
    function GetSupportsSaurashtra: Boolean;
    function GetSupportsShavian: Boolean;
    function GetSupportsSinhala: Boolean;
    function GetSupportsSmallFormVariants: Boolean;
    function GetSupportsSpacingModifierLetters: Boolean;
    function GetSupportsSpecials: Boolean;
    function GetSupportsSundanese: Boolean;
    function GetSupportsSuperscriptsAndSubscripts: Boolean;
    function GetSupportsSupplementalArrowsA: Boolean;
    function GetSupportsSupplementalArrowsB: Boolean;
    function GetSupportsSupplementalMathematicalOperators: Boolean;
    function GetSupportsSupplementalPunctuation: Boolean;
    function GetSupportsSylotiNagri: Boolean;
    function GetSupportsSyriac: Boolean;
    function GetSupportsTagalog: Boolean;
    function GetSupportsTagbanwa: Boolean;
    function GetSupportsTags: Boolean;
    function GetSupportsTaiLe: Boolean;
    function GetSupportsTaiXuanJingSymbols: Boolean;
    function GetSupportsTamil: Boolean;
    function GetSupportsTelugu: Boolean;
    function GetSupportsThaana: Boolean;
    function GetSupportsThai: Boolean;
    function GetSupportsTibetan: Boolean;
    function GetSupportsTifinagh: Boolean;
    function GetSupportsUgaritic: Boolean;
    function GetSupportsUnifiedCanadianAboriginalSyllabics: Boolean;
    function GetSupportsVai: Boolean;
    function GetSupportsVariationSelectors: Boolean;
    function GetSupportsVariationSelectorsSupplement: Boolean;
    function GetSupportsVerticalForms: Boolean;
    function GetSupportsYijingHexagramSymbols: Boolean;
    function GetSupportsYiRadicals: Boolean;
    function GetSupportsYiSyllables: Boolean;
    function GetSupportsCurrencySymbols: Boolean;
    function GetSupportsNumberForms: Boolean;
    function GetSupportsEnclosedCJKLettersAndMonths: Boolean;
    function GetSupportsIdeographicDescriptionCharacters: Boolean;
    function GetSupportsCJKUnifiedIdeographsExtensionA: Boolean;
    function GetSupportsCJKUnifiedIdeographsExtensionB: Boolean;
    function GetSupportsAncientGreekMusicalNotation: Boolean;
    function GetSupportsByzantineMusicalSymbols: Boolean;
    function GetSupportsMathematicalAlphanumericSymbols: Boolean;
    function GetSupportsNewTaiLue: Boolean;
    function GetSupportsCuneiformNumbersAndPunctuation: Boolean;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property AsCardinal[Index: Byte]: Cardinal read GetAsCardinal write SetAsCardinal;
    property AsString: string read GetAsString;

    property SupportsBasicLatin: Boolean read GetSupportsBasicLatin;
    property SupportsLatin1Supplement: Boolean read GetSupportsLatin1Supplement;
    property SupportsLatinExtendedA: Boolean read GetSupportsLatinExtendedA;
    property SupportsLatinExtendedB: Boolean read GetSupportsLatinExtendedB;
    property SupportsIPAExtensions: Boolean read GetSupportsIPAExtensions;
    property SupportsPhoneticExtensions: Boolean read GetSupportsPhoneticExtensions;
    property SupportsPhoneticExtensionsSupplement: Boolean read GetSupportsPhoneticExtensionsSupplement;
    property SupportsSpacingModifierLetters: Boolean read GetSupportsSpacingModifierLetters;
    property SupportsModifierToneLetters: Boolean read GetSupportsModifierToneLetters;
    property SupportsCombiningDiacriticalMarks: Boolean read GetSupportsCombiningDiacriticalMarks;
    property SupportsCombiningDiacriticalMarksSupplement: Boolean read GetSupportsCombiningDiacriticalMarksSupplement;
    property SupportsGreekandCoptic: Boolean read GetSupportsGreekandCoptic;
    property SupportsCoptic: Boolean read GetSupportsCoptic;
    property SupportsCyrillic: Boolean read GetSupportsCyrillic;
    property SupportsCyrillicSupplement: Boolean read GetSupportsCyrillicSupplement;
    property SupportsCyrillicExtendedA: Boolean read GetSupportsCyrillicExtendedA;
    property SupportsCyrillicExtendedB: Boolean read GetSupportsCyrillicExtendedB;
    property SupportsArmenian: Boolean read GetSupportsArmenian;
    property SupportsHebrew: Boolean read GetSupportsHebrew;
    property SupportsVai: Boolean read GetSupportsVai;
    property SupportsArabic: Boolean read GetSupportsArabic;
    property SupportsArabicSupplement: Boolean read GetSupportsArabicSupplement;
    property SupportsNKo: Boolean read GetSupportsNKo;
    property SupportsDevanagari: Boolean read GetSupportsDevanagari;
    property SupportsBengali: Boolean read GetSupportsBengali;
    property SupportsGurmukhi: Boolean read GetSupportsGurmukhi;
    property SupportsGujarati: Boolean read GetSupportsGujarati;
    property SupportsOriya: Boolean read GetSupportsOriya;
    property SupportsTamil: Boolean read GetSupportsTamil;
    property SupportsTelugu: Boolean read GetSupportsTelugu;
    property SupportsKannada: Boolean read GetSupportsKannada;
    property SupportsMalayalam: Boolean read GetSupportsMalayalam;
    property SupportsThai: Boolean read GetSupportsThai;
    property SupportsLao: Boolean read GetSupportsLao;
    property SupportsGeorgian: Boolean read GetSupportsGeorgian;
    property SupportsGeorgianSupplement: Boolean read GetSupportsGeorgianSupplement;
    property SupportsBalinese: Boolean read GetSupportsBalinese;
    property SupportsHangulJamo: Boolean read GetSupportsHangulJamo;
    property SupportsLatinExtendedAdditional: Boolean read GetSupportsLatinExtendedAdditional;
    property SupportsLatinExtendedC: Boolean read GetSupportsLatinExtendedC;
    property SupportsLatinExtendedD: Boolean read GetSupportsLatinExtendedD;
    property SupportsGreekExtended: Boolean read GetSupportsGreekExtended;
    property SupportsGeneralPunctuation: Boolean read GetSupportsGeneralPunctuation;
    property SupportsSupplementalPunctuation: Boolean read GetSupportsSupplementalPunctuation;
    property SupportsSuperscriptsAndSubscripts: Boolean read GetSupportsSuperscriptsAndSubscripts;
    property SupportsCurrencySymbols: Boolean read GetSupportsCurrencySymbols;
    property SupportsCombiningDiacriticalMarksForSymbols: Boolean read GetSupportsCombiningDiacriticalMarksForSymbols;
    property SupportsLetterlikeSymbols: Boolean read GetSupportsLetterlikeSymbols;
    property SupportsNumberForms: Boolean read GetSupportsNumberForms;
    property SupportsArrows: Boolean read GetSupportsArrows;
    property SupportsSupplementalArrowsA: Boolean read GetSupportsSupplementalArrowsA;
    property SupportsSupplementalArrowsB: Boolean read GetSupportsSupplementalArrowsB;
    property SupportsMiscellaneousSymbolsAndArrows: Boolean read GetSupportsMiscellaneousSymbolsAndArrows;
    property SupportsMathematicalOperators: Boolean read GetSupportsMathematicalOperators;
    property SupportsSupplementalMathematicalOperators: Boolean read GetSupportsSupplementalMathematicalOperators;
    property SupportsMiscellaneousMathematicalSymbolsA: Boolean read GetSupportsMiscellaneousMathematicalSymbolsA;
    property SupportsMiscellaneousMathematicalSymbolsB: Boolean read GetSupportsMiscellaneousMathematicalSymbolsB;
    property SupportsMiscellaneousTechnical: Boolean read GetSupportsMiscellaneousTechnical;
    property SupportsControlPictures: Boolean read GetSupportsControlPictures;
    property SupportsOpticalCharacterRecognition: Boolean read GetSupportsOpticalCharacterRecognition;
    property SupportsEnclosedAlphanumerics: Boolean read GetSupportsEnclosedAlphanumerics;
    property SupportsBoxDrawing: Boolean read GetSupportsBoxDrawing;
    property SupportsBlockElements: Boolean read GetSupportsBlockElements;
    property SupportsGeometricShapes: Boolean read GetSupportsGeometricShapes;
    property SupportsMiscellaneousSymbols: Boolean read GetSupportsMiscellaneousSymbols;
    property SupportsDingbats: Boolean read GetSupportsDingbats;
    property SupportsCJKSymbolsAndPunctuation: Boolean read GetSupportsCJKSymbolsAndPunctuation;
    property SupportsHiragana: Boolean read GetSupportsHiragana;
    property SupportsKatakana: Boolean read GetSupportsKatakana;
    property SupportsKatakanaPhoneticExtensions: Boolean read GetSupportsKatakanaPhoneticExtensions;
    property SupportsBopomofo: Boolean read GetSupportsBopomofo;
    property SupportsBopomofoExtended: Boolean read GetSupportsBopomofoExtended;
    property SupportsHangulCompatibilityJamo: Boolean read GetSupportsHangulCompatibilityJamo;
    property SupportsPhagsPa: Boolean read GetSupportsPhagsPa;
    property SupportsEnclosedCJKLettersAndMonths: Boolean read GetSupportsEnclosedCJKLettersAndMonths;
    property SupportsCJKCompatibility: Boolean read GetSupportsCJKCompatibility;
    property SupportsHangulSyllables: Boolean read GetSupportsHangulSyllables;
    property SupportsNonPlane0: Boolean read GetSupportsNonPlane0;
    property SupportsPhoenician: Boolean read GetSupportsPhoenician;
    property SupportsCJKUnifiedIdeographs: Boolean read GetSupportsCJKUnifiedIdeographs;
    property SupportsCJKRadicalsSupplement: Boolean read GetSupportsCJKRadicalsSupplement;
    property SupportsKangxiRadicals: Boolean read GetSupportsKangxiRadicals;
    property SupportsIdeographicDescriptionCharacters: Boolean read GetSupportsIdeographicDescriptionCharacters;
    property SupportsCJKUnifiedIdeographsExtensionA: Boolean read GetSupportsCJKUnifiedIdeographsExtensionA;
    property SupportsCJKUnifiedIdeographsExtensionB: Boolean read GetSupportsCJKUnifiedIdeographsExtensionB;
    property SupportsKanbun: Boolean read GetSupportsKanbun;
    property SupportsPrivateUseAreaPlane0: Boolean read GetSupportsPrivateUseAreaPlane0;
    property SupportsCJKStrokes: Boolean read GetSupportsCJKStrokes;
    property SupportsCJKCompatibilityIdeographs: Boolean read GetSupportsCJKCompatibilityIdeographs;
    property SupportsCJKCompatibilityIdeographsSupplement: Boolean read GetSupportsCJKCompatibilityIdeographsSupplement;
    property SupportsAlphabeticPresentationForms: Boolean read GetSupportsAlphabeticPresentationForms;
    property SupportsArabicPresentationFormsA: Boolean read GetSupportsArabicPresentationFormsA;
    property SupportsCombiningHalfMarks: Boolean read GetSupportsCombiningHalfMarks;
    property SupportsVerticalForms: Boolean read GetSupportsVerticalForms;
    property SupportsCJKCompatibilityForms: Boolean read GetSupportsCJKCompatibilityForms;
    property SupportsSmallFormVariants: Boolean read GetSupportsSmallFormVariants;
    property SupportsArabicPresentationFormsB: Boolean read GetSupportsArabicPresentationFormsB;
    property SupportsHalfwidthAndFullwidthForms: Boolean read GetSupportsHalfwidthAndFullwidthForms;
    property SupportsSpecials: Boolean read GetSupportsSpecials;
    property SupportsTibetan: Boolean read GetSupportsTibetan;
    property SupportsSyriac: Boolean read GetSupportsSyriac;
    property SupportsThaana: Boolean read GetSupportsThaana;
    property SupportsSinhala: Boolean read GetSupportsSinhala;
    property SupportsMyanmar: Boolean read GetSupportsMyanmar;
    property SupportsEthiopic: Boolean read GetSupportsEthiopic;
    property SupportsEthiopicSupplement: Boolean read GetSupportsEthiopicSupplement;
    property SupportsEthiopicExtended: Boolean read GetSupportsEthiopicExtended;
    property SupportsCherokee: Boolean read GetSupportsCherokee;
    property SupportsUnifiedCanadianAboriginalSyllabics: Boolean read GetSupportsUnifiedCanadianAboriginalSyllabics;
    property SupportsOgham: Boolean read GetSupportsOgham;
    property SupportsRunic: Boolean read GetSupportsRunic;
    property SupportsKhmer: Boolean read GetSupportsKhmer;
    property SupportsKhmerSymbols: Boolean read GetSupportsKhmerSymbols;
    property SupportsMongolian: Boolean read GetSupportsMongolian;
    property SupportsBraillePatterns: Boolean read GetSupportsBraillePatterns;
    property SupportsYiSyllables: Boolean read GetSupportsYiSyllables;
    property SupportsYiRadicals: Boolean read GetSupportsYiRadicals;
    property SupportsTagalog: Boolean read GetSupportsTagalog;
    property SupportsHanunoo: Boolean read GetSupportsHanunoo;
    property SupportsBuhid: Boolean read GetSupportsBuhid;
    property SupportsTagbanwa: Boolean read GetSupportsTagbanwa;
    property SupportsOldItalic: Boolean read GetSupportsOldItalic;
    property SupportsGothic: Boolean read GetSupportsGothic;
    property SupportsDeseret: Boolean read GetSupportsDeseret;
    property SupportsByzantineMusicalSymbols: Boolean read GetSupportsByzantineMusicalSymbols;
    property SupportsMusicalSymbols: Boolean read GetSupportsMusicalSymbols;
    property SupportsAncientGreekMusicalNotation: Boolean read GetSupportsAncientGreekMusicalNotation;
    property SupportsMathematicalAlphanumericSymbols: Boolean read GetSupportsMathematicalAlphanumericSymbols;
    property SupportsPrivateUsePlane15: Boolean read GetSupportsPrivateUsePlane15;
    property SupportsPrivateUsePlane16: Boolean read GetSupportsPrivateUsePlane16;
    property SupportsVariationSelectors: Boolean read GetSupportsVariationSelectors;
    property SupportsVariationSelectorsSupplement: Boolean read GetSupportsVariationSelectorsSupplement;
    property SupportsTags: Boolean read GetSupportsTags;
    property SupportsLimbu: Boolean read GetSupportsLimbu;
    property SupportsTaiLe: Boolean read GetSupportsTaiLe;
    property SupportsNewTaiLue: Boolean read GetSupportsNewTaiLue;
    property SupportsBuginese: Boolean read GetSupportsBuginese;
    property SupportsGlagolitic: Boolean read GetSupportsGlagolitic;
    property SupportsTifinagh: Boolean read GetSupportsTifinagh;
    property SupportsYijingHexagramSymbols: Boolean read GetSupportsYijingHexagramSymbols;
    property SupportsSylotiNagri: Boolean read GetSupportsSylotiNagri;
    property SupportsLinearBSyllabary: Boolean read GetSupportsLinearBSyllabary;
    property SupportsLinearBIdeograms: Boolean read GetSupportsLinearBIdeograms;
    property SupportsAegeanNumbers: Boolean read GetSupportsAegeanNumbers;
    property SupportsAncientGreekNumbers: Boolean read GetSupportsAncientGreekNumbers;
    property SupportsUgaritic: Boolean read GetSupportsUgaritic;
    property SupportsOldPersian: Boolean read GetSupportsOldPersian;
    property SupportsShavian: Boolean read GetSupportsShavian;
    property SupportsOsmanya: Boolean read GetSupportsOsmanya;
    property SupportsCypriotSyllabary: Boolean read GetSupportsCypriotSyllabary;
    property SupportsKharoshthi: Boolean read GetSupportsKharoshthi;
    property SupportsTaiXuanJingSymbols: Boolean read GetSupportsTaiXuanJingSymbols;
    property SupportsCuneiform: Boolean read GetSupportsCuneiform;
    property SupportsCuneiformNumbersAndPunctuation: Boolean read GetSupportsCuneiformNumbersAndPunctuation;
    property SupportsCountingRodNumerals: Boolean read GetSupportsCountingRodNumerals;
    property SupportsSundanese: Boolean read GetSupportsSundanese;
    property SupportsLepcha: Boolean read GetSupportsLepcha;
    property SupportsOlChiki: Boolean read GetSupportsOlChiki;
    property SupportsSaurashtra: Boolean read GetSupportsSaurashtra;
    property SupportsKayahLi: Boolean read GetSupportsKayahLi;
    property SupportsRejang: Boolean read GetSupportsRejang;
    property SupportsCham: Boolean read GetSupportsCham;
    property SupportsAncientSymbols: Boolean read GetSupportsAncientSymbols;
    property SupportsPhaistosDisc: Boolean read GetSupportsPhaistosDisc;
    property SupportsCarian: Boolean read GetSupportsCarian;
    property SupportsLycian: Boolean read GetSupportsLycian;
    property SupportsLydian: Boolean read GetSupportsLydian;
    property SupportsDominoTiles: Boolean read GetSupportsDominoTiles;
    property SupportsMahjongTiles: Boolean read GetSupportsMahjongTiles;
  end;


//------------------------------------------------------------------------------
//              TPascalTypeUnicodeRangeTable
//------------------------------------------------------------------------------
type
  TPascalTypeOS2CodePageRangeTable = class(TCustomPascalTypeTable)
  private
    FCodePageRange: TOS2CodePageRange;
    function GetSupportsAlternativeArabic: Boolean;
    function GetSupportsAlternativeHebrew: Boolean;
    function GetSupportsArabic: Boolean;
    function GetSupportsASMO708: Boolean;
    function GetSupportsChineseSimplified: Boolean;
    function GetSupportsChineseTraditional: Boolean;
    function GetSupportsCyrillic: Boolean;
    function GetSupportsGreek: Boolean;
    function GetSupportsGreekFormer437G: Boolean;
    function GetSupportsHebrew: Boolean;
    function GetSupportsIBMCyrillic: Boolean;
    function GetSupportsIBMGreek: Boolean;
    function GetSupportsIBMTurkish: Boolean;
    function GetSupportsJISJapan: Boolean;
    function GetSupportsKoreanJohab: Boolean;
    function GetSupportsKoreanWansung: Boolean;
    function GetSupportsLatin1: Boolean;
    function GetSupportsLatin2: Boolean;
    function GetSupportsLatin2EasternEurope: Boolean;
    function GetSupportsMacintoshCharacterSet: Boolean;
    function GetSupportsMSDOSBaltic: Boolean;
    function GetSupportsMSDOSCanadianFrench: Boolean;
    function GetSupportsMSDOSIcelandic: Boolean;
    function GetSupportsMSDOSNordic: Boolean;
    function GetSupportsMSDOSPortuguese: Boolean;
    function GetSupportsMSDOSRussian: Boolean;
    function GetSupportsOEMCharacter: Boolean;
    function GetSupportsThai: Boolean;
    function GetSupportsTurkish: Boolean;
    function GetSupportsUS: Boolean;
    function GetSupportsVietnamese: Boolean;
    function GetSupportsWELatin1: Boolean;
    function GetSupportsWindowsBaltic: Boolean;
    function GetSupportsSymbolCharacterSet: Boolean;
    function GetAsCardinal(Index: Byte): Cardinal;
    function GetAsString: string;
    procedure SetAsCardinal(Index: Byte; const Value: Cardinal);
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property AsCardinal[Index: Byte]: Cardinal read GetAsCardinal
      write SetAsCardinal;
    property AsString: string read GetAsString;

    property SupportsLatin1: Boolean read GetSupportsLatin1;
    property SupportsLatin2EasternEurope: Boolean read GetSupportsLatin2EasternEurope;
    property SupportsCyrillic: Boolean read GetSupportsCyrillic;
    property SupportsGreek: Boolean read GetSupportsGreek;
    property SupportsTurkish: Boolean read GetSupportsTurkish;
    property SupportsHebrew: Boolean read GetSupportsHebrew;
    property SupportsArabic: Boolean read GetSupportsArabic;
    property SupportsWindowsBaltic: Boolean read GetSupportsWindowsBaltic;
    property SupportsVietnamese: Boolean read GetSupportsVietnamese;
    property SupportsThai: Boolean read GetSupportsThai;
    property SupportsJISJapan: Boolean read GetSupportsJISJapan;
    property SupportsChineseSimplified: Boolean read GetSupportsChineseSimplified;
    property SupportsKoreanWansung: Boolean read GetSupportsKoreanWansung;
    property SupportsChineseTraditional: Boolean read GetSupportsChineseTraditional;
    property SupportsKoreanJohab: Boolean read GetSupportsKoreanJohab;
    property SupportsMacintoshCharacterSet: Boolean read GetSupportsMacintoshCharacterSet;
    property SupportsOEMCharacter: Boolean read GetSupportsOEMCharacter;
    property SupportsSymbolCharacterSet: Boolean read GetSupportsSymbolCharacterSet;
    property SupportsIBMGreek: Boolean read GetSupportsIBMGreek;
    property SupportsMSDOSRussian: Boolean read GetSupportsMSDOSRussian;
    property SupportsMSDOSNordic: Boolean read GetSupportsMSDOSNordic;
    property SupportsAlternativeArabic: Boolean read GetSupportsAlternativeArabic;
    property SupportsMSDOSCanadianFrench: Boolean read GetSupportsMSDOSCanadianFrench;
    property SupportsAlternativeHebrew: Boolean read GetSupportsAlternativeHebrew;
    property SupportsMSDOSIcelandic: Boolean read GetSupportsMSDOSIcelandic;
    property SupportsMSDOSPortuguese: Boolean read GetSupportsMSDOSPortuguese;
    property SupportsIBMTurkish: Boolean read GetSupportsIBMTurkish;
    property SupportsIBMCyrillic: Boolean read GetSupportsIBMCyrillic;
    property SupportsLatin2: Boolean read GetSupportsLatin2;
    property SupportsMSDOSBaltic: Boolean read GetSupportsMSDOSBaltic;
    property SupportsGreekFormer437G: Boolean read GetSupportsGreekFormer437G;
    property SupportsArabicASMO708: Boolean read GetSupportsASMO708;
    property SupportsWELatin1: Boolean read GetSupportsWELatin1;
    property SupportsUS: Boolean read GetSupportsUS;
  end;


//------------------------------------------------------------------------------
//              TPascalTypeOS2AddendumTable
//------------------------------------------------------------------------------
// Version 2-4
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/os2#version-4
//------------------------------------------------------------------------------
type
  TPascalTypeOS2AddendumTable = class(TCustomPascalTypeTable)
  private
    FXHeight    : SmallInt;
    FCapHeight  : SmallInt;
    FDefaultChar: Word;
    FBreakChar  : Word;
    FMaxContext : Word;
    procedure SetBreakChar(const Value: Word);
    procedure SetCapHeight(const Value: SmallInt);
    procedure SetDefaultChar(const Value: Word);
    procedure SetMaxContext(const Value: Word);
    procedure SetXHeight(const Value: SmallInt);
  protected
    procedure BreakCharChanged; virtual;
    procedure CapHeightChanged; virtual;
    procedure DefaultCharChanged; virtual;
    procedure MaxContextChanged; virtual;
    procedure XHeightChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property XHeight: SmallInt read FXHeight write SetXHeight;
    property CapHeight: SmallInt read FCapHeight write SetCapHeight;
    property DefaultChar: Word read FDefaultChar write SetDefaultChar;
    property BreakChar: Word read FBreakChar write SetBreakChar;
    property MaxContext: Word read FMaxContext write SetMaxContext;
  end;


//------------------------------------------------------------------------------
//
//              TPascalTypeOS2Table
//
//------------------------------------------------------------------------------
type
  TPascalTypeOS2Table = class(TCustomPascalTypeNamedTable)
  private
    FVersion               : Word;       // table version number (set to 0)
    FAverageCharacterWidth : SmallInt;   // average weighted advance width of lower case letters and space
    FWeight                : Word;       // visual weight (degree of blackness or thickness) of stroke in glyphs
    FWidthType             : Word;       // relative change from the normal aspect ratio (width to height ratio) as specified by a font designer for the glyphs in the font
    FFontEmbeddingFlags    : Word;       // characteristics and properties of this font (set undefined bits to zero)
    FSubscriptSizeX        : SmallInt;   // recommended horizontal size in pixels for subscripts
    FSubscriptSizeY        : SmallInt;   // recommended vertical size in pixels for subscripts
    FSubScriptOffsetX      : SmallInt;   // recommended horizontal offset for subscripts
    FSubscriptYOffsetY     : SmallInt;   // recommended vertical offset form the baseline for subscripts
    FSuperscriptSizeX      : SmallInt;   // recommended horizontal size in pixels for superscripts
    FSuperscriptSizeY      : SmallInt;   // recommended vertical size in pixels for superscripts
    FSuperscriptOffsetX    : SmallInt;   // recommended horizontal offset for superscripts
    FSuperscriptOffsetY    : SmallInt;   // recommended vertical offset from the baseline for superscripts
    FStrikeoutSize         : SmallInt;   // width of the strikeout stroke
    FStrikeoutPosition     : SmallInt;   // position of the strikeout stroke relative to the baseline
    FFontFamilyType        : Word;       // classification of font-family design.
    FFontVendorID          : TTableType; // four character identifier for the font vendor
    FFontSelection         : Word;       // 2-byte bit field containing information concerning the nature of the font patterns
    FUnicodeFirstCharIndex : Word;       // The minimum Unicode index in this font.
    FUnicodeLastCharIndex  : Word;       // The maximum Unicode index in this font.
    FTypographicAscent     : SmallInt;
    FTypographicDescent    : SmallInt;
    FTypographicLineGap    : SmallInt;
    FWindowsAscent         : Word;
    FWindowsDescent        : Word;

    FPanose                : TCustomPascalTypePanoseTable;
    FUnicodeRangeTable     : TPascalTypeUnicodeRangeTable;
    FCodePageRange         : TPascalTypeOS2CodePageRangeTable;
    FAddendumTable         : TPascalTypeOS2AddendumTable;
    function GetFontEmbeddingRights: TOS2FontEmbeddingRights;
    function GetFontFamilyClassID: Byte;
    function GetFontFamilySubClassID: Byte;
    function GetFontSelectionFlags: TOS2FontSelectionFlags;
    function GetWeightClass: TOS2WeightClass;
    function GetWidthClass: TOS2WidthClass;
    procedure SetFontEmbeddingFlags(const Value: Word);
    procedure SetFontEmbeddingRights(const Value: TOS2FontEmbeddingRights);
    procedure SetFontFamilyClassID(const Value: Byte);
    procedure SetFontFamilySubClassID(const Value: Byte);
    procedure SetFontFamilyType(const Value: Word);
    procedure SetFontSelection(const Value: Word);
    procedure SetFontSelectionFlags(const Value: TOS2FontSelectionFlags);
    procedure SetFontVendorID(const Value: TTableType);
    procedure SetPanose(const Value: TCustomPascalTypePanoseTable);
    procedure SetTypographicAscent(const Value: SmallInt);
    procedure SetTypographicDescent(const Value: SmallInt);
    procedure SetTypographicLineGap(const Value: SmallInt);
    procedure SetUnicodeFirstCharIndex(const Value: Word);
    procedure SetUnicodeLastCharIndex(const Value: Word);
    procedure SetWindowsAscent(const Value: Word);
    procedure SetWindowsDescent(const Value: Word);
    procedure SetVersion(const Value: Word);
    procedure SetWeight(const Value: Word);
    procedure SetWeightClass(const Value: TOS2WeightClass);
    procedure SetWidthClass(const Value: TOS2WidthClass);
    procedure SetWidthType(const Value: Word);
    procedure SetAverageCharacterWidth(const Value: SmallInt);
    procedure SetStrikeoutPosition(const Value: SmallInt);
    procedure SetStrikeoutSize(const Value: SmallInt);
    procedure SetSubScriptOffsetX(const Value: SmallInt);
    procedure SetSubscriptSizeX(const Value: SmallInt);
    procedure SetSubscriptOffsetY(const Value: SmallInt);
    procedure SetSubscriptSizeY(const Value: SmallInt);
    procedure SetSuperscriptOffsetX(const Value: SmallInt);
    procedure SetSuperscriptXSizeX(const Value: SmallInt);
    procedure SetSuperscriptOffsetY(const Value: SmallInt);
    procedure SetSuperscriptYSizeY(const Value: SmallInt);
    procedure SetCodePageRange(const Value: TPascalTypeOS2CodePageRangeTable);
    procedure SetAddendumTable(const Value: TPascalTypeOS2AddendumTable);
  protected
    procedure FontVendorIDChanged; virtual;
    procedure FontSelectionChanged; virtual;
    procedure FontEmbeddingRightsChanged; virtual;
    procedure FontFamilyChanged; virtual;
    procedure TypographicAscentChanged; virtual;
    procedure TypographicDescentChanged; virtual;
    procedure TypographicLineGapChanged; virtual;
    procedure UnicodeFirstCharIndexChanged; virtual;
    procedure UnicodeLastCharIndexChanged; virtual;
    procedure WindowsAscentChanged; virtual;
    procedure WindowsDescentChanged; virtual;
    procedure VersionChanged; virtual;
    procedure WeightChanged; virtual;
    procedure WidthTypeChanged; virtual;
    procedure AverageCharacterWidthChanged; virtual;
    procedure StrikeoutPositionChanged; virtual;
    procedure StrikeoutSizeChanged; virtual;
    procedure SubScriptOffsetXChanged; virtual;
    procedure SubscriptSizeXChanged; virtual;
    procedure SubscriptOffsetYChanged; virtual;
    procedure SubscriptSizeYChanged; virtual;
    procedure SuperscriptOffsetXChanged; virtual;
    procedure SuperscriptSizeXChanged; virtual;
    procedure SuperscriptOffsetYChanged; virtual;
    procedure SuperscriptSizeYChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property AddendumTable: TPascalTypeOS2AddendumTable read FAddendumTable write SetAddendumTable;
    property AverageCharacterWidth: SmallInt read FAverageCharacterWidth write SetAverageCharacterWidth;
    property CodePageRange: TPascalTypeOS2CodePageRangeTable read FCodePageRange write SetCodePageRange;
    property FontEmbeddingFlags: Word read FFontEmbeddingFlags write SetFontEmbeddingFlags;
    property FontEmbeddingRights: TOS2FontEmbeddingRights read GetFontEmbeddingRights write SetFontEmbeddingRights;
    property FontFamilyClassID: Byte read GetFontFamilyClassID write SetFontFamilyClassID;
    property FontFamilySubClassID: Byte read GetFontFamilySubClassID write SetFontFamilySubClassID;
    property FontFamilyType: Word read FFontFamilyType write SetFontFamilyType;
    property FontSelection: Word read FFontSelection write SetFontSelection;
    property FontSelectionFlags: TOS2FontSelectionFlags read GetFontSelectionFlags write SetFontSelectionFlags;
    property FontVendorID: TTableType read FFontVendorID write SetFontVendorID;
    property Panose: TCustomPascalTypePanoseTable read FPanose write SetPanose;
    property StrikeoutPosition: SmallInt read FStrikeoutPosition write SetStrikeoutPosition;
    property StrikeoutSize: SmallInt read FStrikeoutSize write SetStrikeoutSize;
    property SubScriptOffsetX: SmallInt read FSubScriptOffsetX write SetSubScriptOffsetX;
    property SubscriptOffsetY: SmallInt read FSubscriptYOffsetY write SetSubscriptOffsetY;
    property SubscriptSizeX: SmallInt read FSubscriptSizeX write SetSubscriptSizeX;
    property SubscriptSizeY: SmallInt read FSubscriptSizeY write SetSubscriptSizeY;
    property SuperscriptOffsetX: SmallInt read FSuperscriptOffsetX write SetSuperscriptOffsetX;
    property SuperscriptOffsetY: SmallInt read FSuperscriptOffsetY write SetSuperscriptOffsetY;
    property SuperscriptSizeX: SmallInt read FSuperscriptSizeX write SetSuperscriptXSizeX;
    property SuperscriptSizeY: SmallInt read FSuperscriptSizeY write SetSuperscriptYSizeY;
    property TypographicAscent: SmallInt read FTypographicAscent write SetTypographicAscent;
    property TypographicDescent: SmallInt read FTypographicDescent write SetTypographicDescent;
    property TypographicLineGap: SmallInt read FTypographicLineGap write SetTypographicLineGap;
    property UnicodeFirstCharacterIndex: Word read FUnicodeFirstCharIndex write SetUnicodeFirstCharIndex;
    property UnicodeLastCharacterIndex: Word read FUnicodeLastCharIndex write SetUnicodeLastCharIndex;
    property UnicodeRange: TPascalTypeUnicodeRangeTable read FUnicodeRangeTable write FUnicodeRangeTable;
    property Version: Word read FVersion write SetVersion;
    property Weight: Word read FWeight write SetWeight;
    property WeightClass: TOS2WeightClass read GetWeightClass write SetWeightClass;
    property WidthClass: TOS2WidthClass read GetWidthClass write SetWidthClass;
    property WidthType: Word read FWidthType write SetWidthType;
    property WindowsAscent: Word read FWindowsAscent write SetWindowsAscent;
    property WindowsDescent: Word read FWindowsDescent write SetWindowsDescent;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings,
  PascalType.Tables.TrueType.hhea;


resourcestring
  RCStrErrorAscender = 'Error: Typographic ascender should be equal to the ascender defined in the horizontal header table';
  RCStrErrorDescender = 'Error: Typographic descender should be equal to the descender defined in the horizontal header table';
  RCStrErrorLineGap = 'Error: Typographic line gap should be equal to the line gap defined in the horizontal header table';

//------------------------------------------------------------------------------
//              TPascalTypeUnicodeRangeTable
//------------------------------------------------------------------------------
procedure TPascalTypeUnicodeRangeTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeUnicodeRangeTable then
    FUnicodeRange := TPascalTypeUnicodeRangeTable(Source).FUnicodeRange;
end;

procedure TPascalTypeUnicodeRangeTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  with Stream do
  begin
    // check (minimum) table size
    if Position + 16 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read range from stream
    FUnicodeRange[0] := BigEndianValueReader.ReadCardinal(Stream);
    FUnicodeRange[1] := BigEndianValueReader.ReadCardinal(Stream);
    FUnicodeRange[2] := BigEndianValueReader.ReadCardinal(Stream);
    FUnicodeRange[3] := BigEndianValueReader.ReadCardinal(Stream);
  end;
end;

procedure TPascalTypeUnicodeRangeTable.SaveToStream(Stream: TStream);
begin
  // write range to stream
  WriteSwappedCardinal(Stream, FUnicodeRange[0]);
  WriteSwappedCardinal(Stream, FUnicodeRange[1]);
  WriteSwappedCardinal(Stream, FUnicodeRange[2]);
  WriteSwappedCardinal(Stream, FUnicodeRange[3]);
end;

procedure TPascalTypeUnicodeRangeTable.SetAsCardinal(Index: Byte; const Value: Cardinal);
begin
  if not(Index in [0..3]) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  FUnicodeRange[Index] := Value;
end;

function TPascalTypeUnicodeRangeTable.GetAsCardinal(Index: Byte): Cardinal;
begin
  if not(Index in [0..3]) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FUnicodeRange[Index];
end;

function TPascalTypeUnicodeRangeTable.GetAsString: string;
begin
  Result := UnicodeRangeToString(FUnicodeRange);
end;

function TPascalTypeUnicodeRangeTable.GetSupportsAegeanNumbers: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 5)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsAlphabeticPresentationForms: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 30)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsAncientGreekMusicalNotation: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 24)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsAncientGreekNumbers: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 6)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsAncientSymbols: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 23)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsArabic: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 13)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsArabicPresentationFormsA: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 31)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsArabicPresentationFormsB: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 3)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsArabicSupplement: Boolean;
begin
  Result := SupportsArabic;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsArmenian: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 10)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsArrows: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 5)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBalinese: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBasicLatin: Boolean;
begin
  Result := (FUnicodeRange[0] and 1) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBengali: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 16)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBlockElements: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 12)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBopomofo: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 19)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBopomofoExtended: Boolean;
begin
  Result := GetSupportsBopomofo;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBoxDrawing: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 11)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBraillePatterns: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 18)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBuginese: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 0)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsBuhid: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 20)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsByzantineMusicalSymbols: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 24)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCarian: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 25)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCham: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 22)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCherokee: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 12)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKCompatibility: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 23)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKCompatibilityForms: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 1)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKCompatibilityIdeographs: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 29)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKCompatibilityIdeographsSupplement: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 29)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKRadicalsSupplement: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKStrokes: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 29)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKSymbolsAndPunctuation: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 16)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKUnifiedIdeographs: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKUnifiedIdeographsExtensionA: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCJKUnifiedIdeographsExtensionB: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCombiningDiacriticalMarks: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 6)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCombiningDiacriticalMarksForSymbols: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 2)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCombiningDiacriticalMarksSupplement: Boolean;
begin
  Result := GetSupportsCombiningDiacriticalMarks;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCombiningHalfMarks: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 0)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsControlPictures: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 8)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCoptic: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 8)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCountingRodNumerals: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 15)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCuneiform: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 14)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCuneiformNumbersAndPunctuation: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 14)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCurrencySymbols: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 1)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCypriotSyllabary: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 11)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCyrillic: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 9)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCyrillicExtendedA: Boolean;
begin
  Result := GetSupportsCyrillic
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCyrillicExtendedB: Boolean;
begin
  Result := GetSupportsCyrillic
end;

function TPascalTypeUnicodeRangeTable.GetSupportsCyrillicSupplement: Boolean;
begin
  Result := GetSupportsCyrillic
end;

function TPascalTypeUnicodeRangeTable.GetSupportsDeseret: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 23)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsDevanagari: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 15)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsDingbats: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 15)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsDominoTiles: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 26)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsEnclosedAlphanumerics: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 10)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsEnclosedCJKLettersAndMonths: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 22)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsEthiopic: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 11)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsEthiopicExtended: Boolean;
begin
  Result := GetSupportsEthiopic;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsEthiopicSupplement: Boolean;
begin
  Result := GetSupportsEthiopic;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGeneralPunctuation: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 31)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGeometricShapes: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 13)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGeorgian: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 26)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGeorgianSupplement: Boolean;
begin
  Result := GetSupportsGeorgian;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGlagolitic: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 1)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGothic: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 22)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGreekandCoptic: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 7)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGreekExtended: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 30)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGujarati: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 18)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsGurmukhi: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 17)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsHalfwidthAndFullwidthForms: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 4)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsHangulCompatibilityJamo: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 20)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsHangulJamo: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 28)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsHangulSyllables: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 24)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsHanunoo: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 20)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsHebrew: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 11)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsHiragana: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 17)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsIdeographicDescriptionCharacters: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsIPAExtensions: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 4)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKanbun: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKangxiRadicals: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKannada: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 22)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKatakana: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 18)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKatakanaPhoneticExtensions: Boolean;
begin
  Result := GetSupportsKatakana;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKayahLi: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 20)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKharoshthi: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 12)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKhmer: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 16)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsKhmerSymbols: Boolean;
begin
  Result := GetSupportsKhmer;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLao: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 25)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLatin1Supplement: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 1)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLatinExtendedA: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 2)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLatinExtendedAdditional: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 29)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLatinExtendedB: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 3)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLatinExtendedC: Boolean;
begin
  Result := GetSupportsLatinExtendedAdditional;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLatinExtendedD: Boolean;
begin
  Result := GetSupportsLatinExtendedAdditional;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLepcha: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 17)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLetterlikeSymbols: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 3)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLimbu: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 29)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLinearBIdeograms: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 5)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLinearBSyllabary: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 5)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLycian: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 25)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsLydian: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 25)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMahjongTiles: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 26)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMalayalam: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 23)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMathematicalAlphanumericSymbols: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 25)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMathematicalOperators: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 6)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMiscellaneousMathematicalSymbolsA: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 6)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMiscellaneousMathematicalSymbolsB: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 6)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMiscellaneousSymbols: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 14)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMiscellaneousSymbolsAndArrows: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 5)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMiscellaneousTechnical: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 7)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsModifierToneLetters: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 5)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMongolian: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 17)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMusicalSymbols: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 24)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsMyanmar: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 10)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsNewTaiLue: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 31)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsNKo: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 14)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsNonPlane0: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 25)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsNumberForms: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 4)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsOgham: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 14)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsOlChiki: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 18)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsOldItalic: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 21)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsOldPersian: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 8)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsOpticalCharacterRecognition: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 9)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsOriya: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 19)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsOsmanya: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 10)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsPhagsPa: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 21)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsPhaistosDisc: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 24)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsPhoenician: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 26)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsPhoneticExtensions: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 4)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsPhoneticExtensionsSupplement: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 4)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsPrivateUseAreaPlane0: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 28)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsPrivateUsePlane15: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 26)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsPrivateUsePlane16: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 26)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsRejang: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 21)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsRunic: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 15)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSaurashtra: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 19)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsShavian: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 9)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSinhala: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 9)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSmallFormVariants: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 2)) <> 0
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSpacingModifierLetters: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 4)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSpecials: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 5)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSundanese: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 16)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSuperscriptsAndSubscripts: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 0)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSupplementalArrowsA: Boolean;
begin
  Result := GetSupportsArrows;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSupplementalArrowsB: Boolean;
begin
  Result := GetSupportsArrows;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSupplementalMathematicalOperators: Boolean;
begin
  Result := (FUnicodeRange[1] and (1 shl 6)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSupplementalPunctuation: Boolean;
begin
  Result := GetSupportsGeneralPunctuation;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSylotiNagri: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 4)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsSyriac: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 7)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTagalog: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 20)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTagbanwa: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 20)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTags: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 28)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTaiLe: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 30)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTaiXuanJingSymbols: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 13)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTamil: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 20)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTelugu: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 21)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsThaana: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 8)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsThai: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 24)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTibetan: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 6)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsTifinagh: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 2)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsUgaritic: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 7)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsUnifiedCanadianAboriginalSyllabics: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 13)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsVai: Boolean;
begin
  Result := (FUnicodeRange[0] and (1 shl 12)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsVariationSelectors: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsVariationSelectorsSupplement: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 27)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsVerticalForms: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 1)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsYijingHexagramSymbols: Boolean;
begin
  Result := (FUnicodeRange[3] and (1 shl 3)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsYiRadicals: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 19)) <> 0;
end;

function TPascalTypeUnicodeRangeTable.GetSupportsYiSyllables: Boolean;
begin
  Result := (FUnicodeRange[2] and (1 shl 19)) <> 0;
end;


//------------------------------------------------------------------------------
//              TPascalTypeOS2CodePageRangeTable
//------------------------------------------------------------------------------
procedure TPascalTypeOS2CodePageRangeTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeOS2CodePageRangeTable then
  begin
    FCodePageRange[0] := TPascalTypeOS2CodePageRangeTable(Self).FCodePageRange[0];
    FCodePageRange[1] := TPascalTypeOS2CodePageRangeTable(Self).FCodePageRange[1];
  end;
end;

function TPascalTypeOS2CodePageRangeTable.GetAsCardinal(Index: Byte): Cardinal;
begin
  if not(Index in [0..1]) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FCodePageRange[Index];
end;

function TPascalTypeOS2CodePageRangeTable.GetAsString: string;
begin
  Result := CodePageRangeToString(FCodePageRange);
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsAlternativeArabic: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 19)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsAlternativeHebrew: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 21)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsArabic: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 6)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsASMO708: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 29)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsChineseSimplified: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 18)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsChineseTraditional: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 20)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsCyrillic: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 2)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsGreek: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 3)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsGreekFormer437G: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 28)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsHebrew: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 5)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsIBMCyrillic: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 25)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsIBMGreek: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 16)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsIBMTurkish: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 24)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsJISJapan: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 17)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsKoreanJohab: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 21)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsKoreanWansung: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 19)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsLatin1: Boolean;
begin
  Result := (FCodePageRange[0] and 1) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsLatin2: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 26)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsLatin2EasternEurope: Boolean;
begin
  Result := (FCodePageRange[0] and 2) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsMacintoshCharacterSet: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 29)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsMSDOSBaltic: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 27)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsMSDOSCanadianFrench: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 20)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsMSDOSIcelandic: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 22)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsMSDOSNordic: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 18)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsMSDOSPortuguese: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 23)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsMSDOSRussian: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 17)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsOEMCharacter: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 30)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsSymbolCharacterSet: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 31)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsThai: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 16)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsTurkish: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 4)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsUS: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 31)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsVietnamese: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 8)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsWELatin1: Boolean;
begin
  Result := (FCodePageRange[1] and (1 shl 30)) <> 0;
end;

function TPascalTypeOS2CodePageRangeTable.GetSupportsWindowsBaltic: Boolean;
begin
  Result := (FCodePageRange[0] and (1 shl 7)) <> 0;
end;

procedure TPascalTypeOS2CodePageRangeTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  // check (minimum) table size
  if Stream.Position + 2*SizeOf(Cardinal) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read first cardinal
  FCodePageRange[0] := BigEndianValueReader.ReadCardinal(Stream);

  // read second cardinal
  FCodePageRange[1] := BigEndianValueReader.ReadCardinal(Stream);
end;

procedure TPascalTypeOS2CodePageRangeTable.SaveToStream(Stream: TStream);
begin
  // write first cardinal
  WriteSwappedCardinal(Stream, FCodePageRange[0]);

  // write second cardinal
  WriteSwappedCardinal(Stream, FCodePageRange[1]);
end;

procedure TPascalTypeOS2CodePageRangeTable.SetAsCardinal(Index: Byte; const Value: Cardinal);
begin
  if not(Index in [0..1]) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  FCodePageRange[Index] := Value;
end;


//------------------------------------------------------------------------------
//              TPascalTypeOS2AddendumTable
//------------------------------------------------------------------------------
procedure TPascalTypeOS2AddendumTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeOS2AddendumTable then
  begin
    FXHeight := TPascalTypeOS2AddendumTable(Source).FXHeight;
    FCapHeight := TPascalTypeOS2AddendumTable(Source).FCapHeight;
    FDefaultChar := TPascalTypeOS2AddendumTable(Source).FDefaultChar;
    FBreakChar := TPascalTypeOS2AddendumTable(Source).FBreakChar;
    FMaxContext := TPascalTypeOS2AddendumTable(Source).FMaxContext;
  end;
end;

procedure TPascalTypeOS2AddendumTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  // check (minimum) table size
  if Stream.Position + 5*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read x-Height
  FXHeight := BigEndianValueReader.ReadSmallInt(Stream);

  // read capital height
  FCapHeight := BigEndianValueReader.ReadSmallInt(Stream);

  // read default character
  FDefaultChar := BigEndianValueReader.ReadWord(Stream);

  // read break character
  FBreakChar := BigEndianValueReader.ReadWord(Stream);

  // read max. context
  FMaxContext := BigEndianValueReader.ReadWord(Stream);
end;

procedure TPascalTypeOS2AddendumTable.SaveToStream(Stream: TStream);
begin
  // write x-Height
  WriteSwappedSmallInt(Stream, FXHeight);

  // write capital height
  WriteSwappedSmallInt(Stream, FCapHeight);

  // write default character
  WriteSwappedWord(Stream, FDefaultChar);

  // write break character
  WriteSwappedWord(Stream, FBreakChar);

  // write max. context
  WriteSwappedWord(Stream, FMaxContext);
end;

procedure TPascalTypeOS2AddendumTable.SetBreakChar(const Value: Word);
begin
  if FBreakChar <> Value then
  begin
    FBreakChar := Value;
    BreakCharChanged;
  end;
end;

procedure TPascalTypeOS2AddendumTable.SetCapHeight(const Value: SmallInt);
begin
  if FCapHeight <> Value then
  begin
    FCapHeight := Value;
    CapHeightChanged;
  end;
end;

procedure TPascalTypeOS2AddendumTable.SetDefaultChar(const Value: Word);
begin
  if FDefaultChar <> Value then
  begin
    FDefaultChar := Value;
    DefaultCharChanged;
  end;
end;

procedure TPascalTypeOS2AddendumTable.SetMaxContext(const Value: Word);
begin
  if FMaxContext <> Value then
  begin
    FMaxContext := Value;
    MaxContextChanged;
  end;
end;

procedure TPascalTypeOS2AddendumTable.SetXHeight(const Value: SmallInt);
begin
  if FXHeight <> Value then
  begin
    FXHeight := Value;
    XHeightChanged;
  end;
end;

procedure TPascalTypeOS2AddendumTable.BreakCharChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2AddendumTable.CapHeightChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2AddendumTable.DefaultCharChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2AddendumTable.MaxContextChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2AddendumTable.XHeightChanged;
begin
  Changed;
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeOS2Table
//
//------------------------------------------------------------------------------
constructor TPascalTypeOS2Table.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FWeight := 400;
  FWidthType := 5;
  FPanose := TPascalTypeDefaultPanoseTable.Create;
  FUnicodeRangeTable := TPascalTypeUnicodeRangeTable.Create;
end;

destructor TPascalTypeOS2Table.Destroy;
begin
  FreeAndNil(FPanose);
  FreeAndNil(FUnicodeRangeTable);
  FreeAndNil(FCodePageRange);
  FreeAndNil(FAddendumTable);
  inherited;
end;

procedure TPascalTypeOS2Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeOS2Table then
  begin
    FVersion := TPascalTypeOS2Table(Source).FVersion;
    FAverageCharacterWidth := TPascalTypeOS2Table(Source).FAverageCharacterWidth;
    FWeight := TPascalTypeOS2Table(Source).FWeight;
    FWidthType := TPascalTypeOS2Table(Source).FWidthType;
    FFontEmbeddingFlags := TPascalTypeOS2Table(Source).FFontEmbeddingFlags;
    FSubscriptSizeX := TPascalTypeOS2Table(Source).FSubscriptSizeX;
    FSubscriptSizeY := TPascalTypeOS2Table(Source).FSubscriptSizeY;
    FSubScriptOffsetX := TPascalTypeOS2Table(Source).FSubScriptOffsetX;
    FSubscriptYOffsetY := TPascalTypeOS2Table(Source).FSubscriptYOffsetY;
    FSuperscriptSizeX := TPascalTypeOS2Table(Source).FSuperscriptSizeX;
    FSuperscriptSizeY := TPascalTypeOS2Table(Source).FSuperscriptSizeY;
    FSuperscriptOffsetX := TPascalTypeOS2Table(Source).FSuperscriptOffsetX;
    FSuperscriptOffsetY := TPascalTypeOS2Table(Source).FSuperscriptOffsetY;
    FStrikeoutSize := TPascalTypeOS2Table(Source).FStrikeoutSize;
    FStrikeoutPosition := TPascalTypeOS2Table(Source).FStrikeoutPosition;
    FFontFamilyType := TPascalTypeOS2Table(Source).FFontFamilyType;
    FFontVendorID := TPascalTypeOS2Table(Source).FFontVendorID;
    FFontSelection := TPascalTypeOS2Table(Source).FFontSelection;
    FUnicodeFirstCharIndex := TPascalTypeOS2Table(Source).FUnicodeFirstCharIndex;
    FUnicodeLastCharIndex := TPascalTypeOS2Table(Source).FUnicodeLastCharIndex;
    FTypographicAscent := TPascalTypeOS2Table(Source).FTypographicAscent;
    FTypographicDescent := TPascalTypeOS2Table(Source).FTypographicDescent;
    FTypographicLineGap := TPascalTypeOS2Table(Source).FTypographicLineGap;
    FWindowsAscent := TPascalTypeOS2Table(Source).FWindowsAscent;
    FWindowsDescent := TPascalTypeOS2Table(Source).FWindowsDescent;
    FPanose.Assign(TPascalTypeOS2Table(Source).FPanose);
    FUnicodeRangeTable.Assign(TPascalTypeOS2Table(Source).FUnicodeRangeTable);
    FCodePageRange.Assign(TPascalTypeOS2Table(Source).FCodePageRange);
    FAddendumTable.Assign(TPascalTypeOS2Table(Source).FAddendumTable);
  end;
end;

function TPascalTypeOS2Table.GetFontEmbeddingRights: TOS2FontEmbeddingRights;
begin
  Result := FontEmbeddingFlagsToRights(FFontEmbeddingFlags);
end;

function TPascalTypeOS2Table.GetFontFamilyClassID: Byte;
begin
  Result := FFontFamilyType shr 8;
end;

function TPascalTypeOS2Table.GetFontFamilySubClassID: Byte;
begin
  Result := FFontFamilyType and $FF;
end;

function TPascalTypeOS2Table.GetFontSelectionFlags: TOS2FontSelectionFlags;
begin
  Result := WordToFontSelectionFlags(FFontSelection);
end;

class function TPascalTypeOS2Table.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'OS/2';
end;


{$IFOPT R+}
{$DEFINE R_PLUS}
{$RANGECHECKS OFF}
{$ENDIF}
procedure TPascalTypeOS2Table.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  PanoseFamilyKind : Byte;
  PanoseFamilyClass: TPascalTypePanoseClass;
{$IFDEF AmbigiousExceptions}
  HorizontalHeader: TPascalTypeHorizontalHeaderTable;
{$ENDIF}
begin
  // check (minimum) table size
  if Stream.Position + 68 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read version
  FVersion := BigEndianValueReader.ReadWord(Stream);

  // check version
(*

Version check disabled. Even though we don't support newer versions, we
can still read the parts we support. The format is forward compatible.

  if not(FVersion in [0..3]) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);
*)

  // read average horizontal character width
  FAverageCharacterWidth := BigEndianValueReader.ReadWord(Stream);

  // read weight
  FWeight := BigEndianValueReader.ReadWord(Stream);

  // read width type
  FWidthType := BigEndianValueReader.ReadWord(Stream);

  // read font embedding right flags
  FFontEmbeddingFlags := BigEndianValueReader.ReadWord(Stream);

  // read SubscriptSizeX
  FSubscriptSizeX := BigEndianValueReader.ReadWord(Stream);

  // read SubscriptSizeY
  FSubscriptSizeY := BigEndianValueReader.ReadWord(Stream);

  // read SubScriptOffsetX
  FSubScriptOffsetX := BigEndianValueReader.ReadWord(Stream);

  // read SubscriptOffsetX
  FSubscriptYOffsetY := BigEndianValueReader.ReadWord(Stream);

  // read SuperscriptSizeX
  FSuperscriptSizeX := BigEndianValueReader.ReadWord(Stream);

  // read SuperscriptSizeY
  FSuperscriptSizeY := BigEndianValueReader.ReadWord(Stream);

  // read SuperscriptOffsetX
  FSuperscriptOffsetX := BigEndianValueReader.ReadWord(Stream);

  // read SuperscriptOffsetY
  FSuperscriptOffsetY := BigEndianValueReader.ReadWord(Stream);

  // read StrikeoutSize
  FStrikeoutSize := BigEndianValueReader.ReadWord(Stream);

  // read StrikeoutPosition
  FStrikeoutPosition := BigEndianValueReader.ReadWord(Stream);

  // read font family type
  FFontFamilyType := BigEndianValueReader.ReadWord(Stream);

  // read panose
  Stream.Read(PanoseFamilyKind, 1);

  // find panose family class by type
  PanoseFamilyClass := FindPascalTypePanoseByType(PanoseFamilyKind);

  if (PanoseFamilyClass = nil) then
    PanoseFamilyClass := TPascalTypeDefaultPanoseTable;

  if (FPanose = nil) or (FPanose.ClassType <> PanoseFamilyClass) then
  begin
    // free old panose object
    FreeAndNil(FPanose);

    // create new panose object
    FPanose := PanoseFamilyClass.Create;
  end;

  // rewind current position to read the family type as well
  Stream.Seek(-1, soFromCurrent);
  // load panose object from stream
  FPanose.LoadFromStream(Stream);

  // read unicode range
  FUnicodeRangeTable.LoadFromStream(Stream);

  // read font vendor identification
  Stream.Read(FFontVendorID, SizeOf(FFontVendorID));

  // read font selection flags
  (*
    Versions 0 to 3:
    Only bit 0 (italic) to bit 6 (regular) are assigned.
    Bits 7 to 15 are reserved and must be set to 0.
    Applications should ignore bits 7 to 15 in a font that has a version 0 to version 3 OS/2 table.

    Version 4 to 5:
    Bits 7 to 9 were defined in version 4 (OpenType 1.5).
    Bits 10 to 15 are reserved and must be set to 0.
    Applications should ignore bits 10 to 15 in a font that has a version 4 or version 5 OS/2 table.
  *)
  FFontSelection := BigEndianValueReader.ReadWord(Stream);
  case FVersion of
    0..3:
      FFontSelection := FFontSelection and $007F;

    4..5:
      FFontSelection := FFontSelection and $03FF;
  end;
{$IFDEF AmbigiousExceptions}
  if (FFontSelection and $8000 <> 0) then
    raise EPascalTypeError.CreateFmt(RCStrReservedValueError, [FFontSelection])
{$ENDIF};

  // read UnicodeFirstCharacterIndex
  FUnicodeFirstCharIndex := BigEndianValueReader.ReadWord(Stream);

  // read UnicodeLastCharacterIndex
  FUnicodeLastCharIndex := BigEndianValueReader.ReadWord(Stream);

  // read TypographicAscent
  FTypographicAscent := BigEndianValueReader.ReadWord(Stream);

  // read TypographicDescent
  FTypographicDescent := BigEndianValueReader.ReadWord(Stream);

  // read TypographicLineGap
  FTypographicLineGap := BigEndianValueReader.ReadWord(Stream);

  // read WindowsAscent
  FWindowsAscent := BigEndianValueReader.ReadWord(Stream);

  // read WindowsDescent
  FWindowsDescent := BigEndianValueReader.ReadWord(Stream);

{$IFDEF AmbigiousExceptions}
  HorizontalHeader := TPascalTypeHorizontalHeaderTable(FontFace.GetTableByTableName('hhea'));
  // hhea might not have been loaded yet due to the table load order
  // so don't do this test unless it has been loaded
  // Assert(HorizontalHeader <> nil);
  if (HorizontalHeader <> nil) then
  begin

    if fsfUseTypoMetrics in FontSelectionFlags then
    begin
      if Abs(HorizontalHeader.Ascent) <> Abs(FTypographicAscent) then
        raise EPascalTypeError.Create(RCStrErrorAscender);

      if Abs(HorizontalHeader.Descent) <> Abs(FTypographicDescent) then
        raise EPascalTypeError.Create(RCStrErrorDescender);

      if Abs(HorizontalHeader.LineGap) <> Abs(FTypographicLineGap) then
        raise EPascalTypeError.Create(RCStrErrorLineGap);
    end
    else
    begin
      // TODO : Handle WindowsAscender/Descender errors as warnings
      // These errors are very commons so the checks has been disabled for now
      if Abs(HorizontalHeader.Ascent) <> Abs(FWindowsAscent) then
        ; //raise EPascalTypeError.Create(RCStrErrorWindowsAscender);

      if Abs(HorizontalHeader.Descent) <> Abs(FWindowsDescent) then
        ; // raise EPascalTypeError.Create(RCStrErrorWindowsDescender);
    end;
  end;
{$ENDIF}

  // eventually load further tables
  if Version > 0 then
  begin
    // check if codepage range exists
    if (FCodePageRange = nil) then
      FCodePageRange := TPascalTypeOS2CodePageRangeTable.Create;

    // load codepage range from stream
    FCodePageRange.LoadFromStream(Stream);

    // eventually load addendum table
    if Version >= 2 then
    begin
      // check if addendum table exists
      if (FAddendumTable = nil) then
        FAddendumTable := TPascalTypeOS2AddendumTable.Create;

      // load addendum table from stream
      FAddendumTable.LoadFromStream(Stream);
    end;
  end;
end;
{$IFDEF R_PLUS}
{$RANGECHECKS ON}
{$UNDEF R_PLUS}
{$ENDIF}

procedure TPascalTypeOS2Table.SaveToStream(Stream: TStream);
begin
  // write version
  WriteSwappedWord(Stream, FVersion);

  // write average horizontal character width
  WriteSwappedWord(Stream, FAverageCharacterWidth);

  // write weight
  WriteSwappedWord(Stream, FWeight);

  // write width class
  WriteSwappedWord(Stream, FWidthType);

  // write font embedding rights
  WriteSwappedWord(Stream, FFontEmbeddingFlags);

  // write SubscriptSizeX
  WriteSwappedWord(Stream, FSubscriptSizeX);

  // write SubscriptSizeY
  WriteSwappedWord(Stream, FSubscriptSizeY);

  // write SubScriptOffsetX
  WriteSwappedWord(Stream, FSubScriptOffsetX);

  // write SubscriptOffsetX
  WriteSwappedWord(Stream, FSubscriptYOffsetY);

  // write SuperscriptSizeX
  WriteSwappedWord(Stream, FSuperscriptSizeX);

  // write SuperscriptSizeY
  WriteSwappedWord(Stream, FSuperscriptSizeY);

  // write SuperscriptOffsetX
  WriteSwappedWord(Stream, FSuperscriptOffsetX);

  // write SuperscriptOffsetY
  WriteSwappedWord(Stream, FSuperscriptOffsetY);

  // write StrikeoutSize
  WriteSwappedWord(Stream, FStrikeoutSize);

  // write StrikeoutPosition
  WriteSwappedWord(Stream, FStrikeoutPosition);

  // write font family type
  WriteSwappedWord(Stream, FFontFamilyType);

  // write panose
  FPanose.SaveToStream(Stream);

  // write unicode range
  FUnicodeRangeTable.SaveToStream(Stream);

  // read font vendor identification
  Stream.Write(FFontVendorID, 4);

  // write font selection
  WriteSwappedWord(Stream, FFontSelection);

  // write UnicodeFirstCharacterIndex
  WriteSwappedWord(Stream, FUnicodeFirstCharIndex);

  // write UnicodeLastCharacterIndex
  WriteSwappedWord(Stream, FUnicodeLastCharIndex);

  // write TypographicAscent
  WriteSwappedWord(Stream, FTypographicAscent);

  // write TypographicDescent
  WriteSwappedWord(Stream, FTypographicDescent);

  // write TypographicLineGap
  WriteSwappedWord(Stream, FTypographicLineGap);

  // write WindowsAscent
  WriteSwappedWord(Stream, FWindowsAscent);

  // write WindowsDescent
  WriteSwappedWord(Stream, FWindowsDescent);

  // eventually write code page range and addendum table
  if (FVersion > 0) then
  begin
    // check if code page range has been set and eventually save to stream
    if (FCodePageRange = nil) then
      raise EPascalTypeError.Create(RCStrCodePageRangeTableUndefined);
    FCodePageRange.SaveToStream(Stream);

    // check if addendum table has been set and eventually save to stream
    if Version >= 2 then
    begin
      if (FAddendumTable = nil) then
        raise EPascalTypeError.Create(RCStrAddendumTableUndefined);
      FAddendumTable.SaveToStream(Stream);
    end;
  end;
end;

function TPascalTypeOS2Table.GetWeightClass: TOS2WeightClass;
begin
  case FWeight div 100 of
    1:
      Result := wcThin;

    2:
      Result := wcExtraLight;

    3:
      Result := wcLight;

    4:
      Result := wcNormal;

    5:
      Result := wcMedium;

    6:
      Result := wcSemiBold;

    7:
      Result := wcBold;

    8:
      Result := wcExtraBold;

    9:
      Result := wcBlack;
  else
    Result := wcUnknownWeight;
  end;
end;

function TPascalTypeOS2Table.GetWidthClass: TOS2WidthClass;
begin
  case FWidthType of
    1:
      Result := wcUltraCondensed;
    2:
      Result := wcExtraCondensed;
    3:
      Result := wcCondensed;
    4:
      Result := wcSemiCondensed;
    5:
      Result := wcMediumNormal;
    6:
      Result := wcSemiExpanded;
    7:
      Result := wcExpanded;
    8:
      Result := wcExtraExpanded;
    9:
      Result := wcUltraExpanded;
  else
    Result := wcUnknownWidth;
  end;
end;

procedure TPascalTypeOS2Table.SetFontVendorID(const Value: TTableType);
begin
  if FFontVendorID.AsCardinal <> Value.AsCardinal then
  begin
    FFontVendorID := Value;
    FontVendorIDChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetFontSelection(const Value: Word);
begin
  if FFontSelection <> Value then
  begin
    FFontSelection := Value;
    FontSelectionChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetFontSelectionFlags(const Value: TOS2FontSelectionFlags);
begin
  if FontSelectionFlags <> Value then
  begin
    FFontSelection := FontSelectionFlagsToWord(Value);
    FontSelectionChanged
  end;
end;

procedure TPascalTypeOS2Table.SetPanose(const Value: TCustomPascalTypePanoseTable);
begin
  FPanose.Assign(Value);
end;

procedure TPascalTypeOS2Table.SetAddendumTable(const Value: TPascalTypeOS2AddendumTable);
begin
  if (FAddendumTable <> nil) then
  begin
    if (Value <> nil) then
      FAddendumTable.Assign(Value)
    else
      FreeAndNil(FAddendumTable)
  end else
  if (Value <> nil) then
  begin
    FAddendumTable := TPascalTypeOS2AddendumTable.Create;
    FAddendumTable.Assign(Value);
  end;
end;

procedure TPascalTypeOS2Table.SetCodePageRange(const Value: TPascalTypeOS2CodePageRangeTable);
begin
  if (FCodePageRange <> nil) then
  begin
    if (Value <> nil) then
      FCodePageRange.Assign(Value)
    else
      FreeAndNil(FCodePageRange)
  end else
  if (Value <> nil) then
  begin
    FCodePageRange := TPascalTypeOS2CodePageRangeTable.Create;
    FCodePageRange.Assign(Value);
  end;
end;

procedure TPascalTypeOS2Table.SetFontEmbeddingFlags(const Value: Word);
begin
  if FFontEmbeddingFlags <> Value then
  begin
    FFontEmbeddingFlags := Value;
    FontEmbeddingRightsChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetFontEmbeddingRights(const Value: TOS2FontEmbeddingRights);
begin
  if FontEmbeddingRights <> Value then
  begin
    FFontEmbeddingFlags := FontEmbeddingRightsToFlags(Value);
    FontEmbeddingRightsChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetFontFamilyClassID(const Value: Byte);
begin
  if FontFamilyClassID <> Value then
  begin
    FFontFamilyType := (FFontFamilyType and $FF) or (Value shl 8);
    FontFamilyChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetFontFamilySubClassID(const Value: Byte);
begin
  if FontFamilySubClassID <> Value then
  begin
    FFontFamilyType := (FFontFamilyType and $FF00) or Value;
    FontFamilyChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetFontFamilyType(const Value: Word);
begin
  if FFontFamilyType <> Value then
  begin
    FFontFamilyType := Value;
    FontFamilyChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetTypographicAscent(const Value: SmallInt);
begin
  if FTypographicAscent <> Value then
  begin
    FTypographicAscent := Value;
    TypographicAscentChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetTypographicDescent(const Value: SmallInt);
begin
  if FTypographicDescent <> Value then
  begin
    FTypographicDescent := Value;
    TypographicDescentChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetTypographicLineGap(const Value: SmallInt);
begin
  if FTypographicLineGap <> Value then
  begin
    FTypographicLineGap := Value;
    TypographicLineGapChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetUnicodeFirstCharIndex(const Value: Word);
begin
  if FUnicodeFirstCharIndex <> Value then
  begin
    FUnicodeFirstCharIndex := Value;
    UnicodeFirstCharIndexChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetUnicodeLastCharIndex(const Value: Word);
begin
  if FUnicodeLastCharIndex <> Value then
  begin
    FUnicodeLastCharIndex := Value;
    UnicodeLastCharIndexChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetWidthClass(const Value: TOS2WidthClass);
begin
  if Value = wcUnknownWidth then
    Exit;

  if WidthClass <> Value then
  begin
    FWidthType := Word(Value);
    WidthTypeChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetWidthType(const Value: Word);
begin
  if FWidthType <> Value then
  begin
    FWidthType := Value;
    WidthTypeChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetWindowsAscent(const Value: Word);
begin
  if FWindowsAscent <> Value then
  begin
    FWindowsAscent := Value;
    WindowsAscentChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetWindowsDescent(const Value: Word);
begin
  if FWindowsDescent <> Value then
  begin
    FWindowsDescent := Value;
    WindowsDescentChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetAverageCharacterWidth(const Value: SmallInt);
begin
  if FAverageCharacterWidth <> Value then
  begin
    FAverageCharacterWidth := Value;
    AverageCharacterWidthChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetStrikeoutPosition(const Value: SmallInt);
begin
  if FStrikeoutPosition <> Value then
  begin
    FStrikeoutPosition := Value;
    StrikeoutPositionChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetStrikeoutSize(const Value: SmallInt);
begin
  if FStrikeoutSize <> Value then
  begin
    FStrikeoutSize := Value;
    StrikeoutSizeChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetSubScriptOffsetX(const Value: SmallInt);
begin
  if FSubScriptOffsetX <> Value then
  begin
    FSubScriptOffsetX := Value;
    SubScriptOffsetXChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetSubscriptSizeX(const Value: SmallInt);
begin
  if FSubscriptSizeX <> Value then
  begin
    FSubscriptSizeX := Value;
    SubscriptSizeXChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetSubscriptOffsetY(const Value: SmallInt);
begin
  if FSubscriptYOffsetY <> Value then
  begin
    FSubscriptYOffsetY := Value;
    SubscriptOffsetYChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetSubscriptSizeY(const Value: SmallInt);
begin
  if FSubscriptSizeY <> Value then
  begin
    FSubscriptSizeY := Value;
    SubscriptSizeYChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetSuperscriptOffsetX(const Value: SmallInt);
begin
  if FSuperscriptOffsetX <> Value then
  begin
    FSuperscriptOffsetX := Value;
    SuperscriptOffsetXChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetSuperscriptXSizeX(const Value: SmallInt);
begin
  if FSuperscriptSizeX <> Value then
  begin
    FSuperscriptSizeX := Value;
    SuperscriptSizeXChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetSuperscriptOffsetY(const Value: SmallInt);
begin
  if FSuperscriptOffsetY <> Value then
  begin
    FSuperscriptOffsetY := Value;
    SuperscriptOffsetYChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetSuperscriptYSizeY(const Value: SmallInt);
begin
  if FSuperscriptSizeY <> Value then
  begin
    FSuperscriptSizeY := Value;
    SuperscriptSizeYChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetWeight(const Value: Word);
begin
  if FWeight <> Value then
  begin
    FWeight := Value;
    WeightChanged;
  end;
end;

procedure TPascalTypeOS2Table.SetWeightClass(const Value: TOS2WeightClass);
begin
  if Value = wcUnknownWeight then
    Exit;

  if WeightClass <> Value then
  begin
    FWeight := Word(Value);
    WeightChanged;
  end;
end;

procedure TPascalTypeOS2Table.FontVendorIDChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.FontSelectionChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.FontEmbeddingRightsChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.FontFamilyChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.TypographicAscentChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.TypographicDescentChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.TypographicLineGapChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.UnicodeFirstCharIndexChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.UnicodeLastCharIndexChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.WeightChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.WidthTypeChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.WindowsAscentChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.WindowsDescentChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.VersionChanged;
begin
  // make sure a code page range objects exists if necessary
  if FVersion > 0 then
  begin
    // create code page range table if it doesn't exists
    if (FCodePageRange = nil) then
      FCodePageRange := TPascalTypeOS2CodePageRangeTable.Create;

    if FVersion >= 2 then
    begin
      // create addendum table if it doesn't exists
      if (FAddendumTable = nil) then
        FAddendumTable := TPascalTypeOS2AddendumTable.Create;
    end else
      FreeAndNil(FAddendumTable);
  end else
  begin
    // free code page range if not needed
    FreeAndNil(FCodePageRange);

    // free addendum table if not needed
    FreeAndNil(FAddendumTable);
  end;

  Changed;
end;

procedure TPascalTypeOS2Table.AverageCharacterWidthChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.StrikeoutPositionChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.StrikeoutSizeChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.SubScriptOffsetXChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.SubscriptSizeXChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.SubscriptOffsetYChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.SubscriptSizeYChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.SuperscriptOffsetXChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.SuperscriptSizeXChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.SuperscriptOffsetYChanged;
begin
  Changed;
end;

procedure TPascalTypeOS2Table.SuperscriptSizeYChanged;
begin
  Changed;
end;


initialization

  RegisterPascalTypeTable(TPascalTypeOS2Table);

end.
