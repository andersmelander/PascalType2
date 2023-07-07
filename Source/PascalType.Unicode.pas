unit PascalType.Unicode;

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
//  Portions created by Anders Melander are Copyright (C) 2023                //
//  by Anders Melander. All Rights Reserved.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//  Unicode tables and most categorization functions are adapted from code in //
//  the JEDI JCL library and are based on original work by Mike Lischke       //
//  (public att lischke-online dott de).                                      //
//  Portions created by Mike Lischke are Copyright (C) 1999-2000 Mike Lischke.//
//  All Rights Reserved.                                                      //
////////////////////////////////////////////////////////////////////////////////

interface

{$define UNICODE_RAW_DATA}
{-$define UNICODE_ZLIB_DATA}

{$I PT_Compiler.inc}

{$IFDEF UNICODE_RAW_DATA}
  {$UNDEF UNICODE_ZLIB_DATA}
{$ENDIF UNICODE_RAW_DATA}


//------------------------------------------------------------------------------
//
//              TPascalTypeCodePoint
//
//------------------------------------------------------------------------------
// UCS4 = UTF-32
// A Unicode 2.0 codepoint - 32 bits wide
//------------------------------------------------------------------------------
// The Unicode® Standard, Version 15.0 – Core Specification, Appendix C
// Relationship to ISO/IEC 10646
// Section C.2 Encoding Forms in ISO/IEC 10646
// UCS-4 stands for “Universal Character Set coded in 4 octets.” It is now
// treated simply as a synonym for UTF-32, and is considered the canonical form
// for representation of characters in [ISO/IEC] 10646.
//------------------------------------------------------------------------------
type
  TPascalTypeCodePoint = Cardinal;

  TPascalTypeCodePoints = TArray<TPascalTypeCodePoint>;


//------------------------------------------------------------------------------

type
  // 16 compatibility formatting tags are defined:
  TCompatibilityFormattingTag = (
    cftCanonical, // default when no CFT is explicited
    cftFont,      // Font variant (for example, a blackletter form)
    cftNoBreak,   // No-break version of a space or hyphen
    cftInitial,   // Initial presentation form (Arabic)
    cftMedial,    // Medial presentation form (Arabic)
    cftFinal,     // Final presentation form (Arabic)
    cftIsolated,  // Isolated presentation form (Arabic)
    cftCircle,    // Encircled form
    cftSuper,     // Superscript form
    cftSub,       // Subscript form
    cftVertical,  // Vertical layout presentation form
    cftWide,      // Wide (or zenkaku) compatibility character
    cftNarrow,    // Narrow (or hankaku) compatibility character
    cftSmall,     // Small variant form (CNS compatibility)
    cftSquare,    // CJK squared font variant
    cftFraction,  // Vulgar fraction form
    cftCompat     // Otherwise unspecified compatibility character
  );


//------------------------------------------------------------------------------

type
  // Various predefined or otherwise useful character property categories
  TCharacterCategory = (
    // Normative categories
    ccLetterUppercase,
    ccLetterLowercase,
    ccLetterTitlecase,
    ccMarkNonSpacing,
    ccMarkSpacingCombining,
    ccMarkEnclosing,
    ccNumberDecimalDigit,
    ccNumberLetter,
    ccNumberOther,
    ccSeparatorSpace,
    ccSeparatorLine,
    ccSeparatorParagraph,
    ccOtherControl,
    ccOtherFormat,
    ccOtherSurrogate,
    ccOtherPrivate,
    ccOtherUnassigned,
    // informative categories
    ccLetterModifier,
    ccLetterOther,
    ccPunctuationConnector,
    ccPunctuationDash,
    ccPunctuationOpen,
    ccPunctuationClose,
    ccPunctuationInitialQuote,
    ccPunctuationFinalQuote,
    ccPunctuationOther,
    ccSymbolMath,
    ccSymbolCurrency,
    ccSymbolModifier,
    ccSymbolOther,
    // Bidirectional categories
    ccLeftToRight,
    ccLeftToRightEmbedding,
    ccLeftToRightOverride,
    ccRightToLeft,
    ccRightToLeftArabic,
    ccRightToLeftEmbedding,
    ccRightToLeftOverride,
    ccPopDirectionalFormat,
    ccEuropeanNumber,
    ccEuropeanNumberSeparator,
    ccEuropeanNumberTerminator,
    ccArabicNumber,
    ccCommonNumberSeparator,
    ccBoundaryNeutral,
    ccSegmentSeparator,      // this includes tab and vertical tab
    ccWhiteSpace,            // Separator characters and control characters which should be treated by programming languages as "white space" for the purpose of parsing elements.
    ccOtherNeutrals,
    ccLeftToRightIsolate,
    ccRightToLeftIsolate,
    ccFirstStrongIsolate,
    ccPopDirectionalIsolate,
    // Self defined categories, they do not appear in the Unicode data file
    ccComposed,              // can be decomposed
    ccNonBreaking,
    ccSymmetric,             // has left and right forms
    ccHexDigit,              // Characters commonly used for the representation of hexadecimal numbers, plus their compatibility equivalents.
    ccQuotationMark,         // Punctuation characters that function as quotation marks.
    ccMirroring,
    ccAssigned,              // means there is a definition in the Unicode standard
    ccASCIIHexDigit,         // ASCII characters commonly used for the representation of hexadecimal numbers
    ccBidiControl,           // Format control characters which have specific functions in the Unicode Bidirectional Algorithm [UAX9].
    ccDash,                  // Punctuation characters explicitly called out as dashes in the Unicode Standard, plus their compatibility equivalents. Most of these have the General_Category value Pd, but some have the General_Category value Sm because of their use in mathematics.
    ccDeprecated,            // For a machine-readable list of deprecated characters. No characters will ever be removed from the standard, but the usage of deprecated characters is strongly discouraged.
    ccDiacritic,             // Characters that linguistically modify the meaning of another character to which they apply. Some diacritics are not combining characters, and some combining characters are not diacritics.
    ccExtender,              // Characters whose principal function is to extend the value or shape of a preceding alphabetic character. Typical of these are length and iteration marks.
    ccHyphen,                // Dashes which are used to mark connections between pieces of words, plus the Katakana middle dot. The Katakana middle dot functions like a hyphen, but is shaped like a dot rather than a dash.
    ccIdeographic,           // Characters considered to be CJKV (Chinese, Japanese, Korean, and Vietnamese) ideographs.
    ccIDSBinaryOperator,     // Used in Ideographic Description Sequences.
    ccIDSTrinaryOperator,    // Used in Ideographic Description Sequences.
    ccJoinControl,           // Format control characters which have specific functions for control of cursive joining and ligation.
    ccLogicalOrderException, // There are a small number of characters that do not use logical order. These characters require special handling in most processing.
    ccNonCharacterCodePoint, // Code points permanently reserved for internal use.
    ccOtherAlphabetic,       // Used in deriving the Alphabetic property.
    ccOtherDefaultIgnorableCodePoint, // Used in deriving the Default_Ignorable_Code_Point property.
    ccOtherGraphemeExtend,   // Used in deriving  the Grapheme_Extend property.
    ccOtherIDContinue,       // Used for backward compatibility of ID_Continue.
    ccOtherIDStart,          // Used for backward compatibility of ID_Start.
    ccOtherLowercase,        // Used in deriving the Lowercase property.
    ccOtherMath,             // Used in deriving the Math property.
    ccOtherUppercase,        // Used in deriving the Uppercase property.
    ccPatternSyntax,         // Used for pattern syntax as described in UAX #31: Unicode Identifier and Pattern Syntax [UAX31].
    ccPatternWhiteSpace,
    ccRadical,               // Used in Ideographic Description Sequences.
    ccSoftDotted,            // Characters with a "soft dot", like i or j. An accent placed on these characters causes the dot to disappear. An explicit dot above can be added where required, such as in Lithuanian.
    ccSTerm,                 // Sentence Terminal. Used in UAX #29: Unicode Text Segmentation [UAX29].
    ccTerminalPunctuation,   // Punctuation characters that generally mark the end of textual units.
    ccUnifiedIdeograph,      // Used in Ideographic Description Sequences.
    ccVariationSelector,     // Indicates characters that are Variation Selectors. For details on the behavior of these characters, see StandardizedVariants.html, Section 16.4, "Variation Selectors" in [Unicode], and the Unicode Ideographic Variation Database [UTS37].
    ccSentenceTerminal,      // Characters used at the end of a sentence
    ccPrependedQuotationMark,
    ccRegionalIndicator
  );

  TCharacterCategories = set of TCharacterCategory;

type
  TCharacterUnicodeCategory = ccLetterUppercase..ccSymbolOther;


//------------------------------------------------------------------------------
//
//              Block
//
//------------------------------------------------------------------------------
// An Unicode Block usually corresponds to a particular language script but
// can also represent special characters, musical symbols and the like.
// https://www.unicode.org/charts/
type
  TUnicodeBlock = (
    ubUndefined,
    ubBasicLatin,
    ubLatin1Supplement,
    ubLatinExtendedA,
    ubLatinExtendedB,
    ubIPAExtensions,
    ubSpacingModifierLetters,
    ubCombiningDiacriticalMarks,
    ubGreekandCoptic,
    ubCyrillic,
    ubCyrillicSupplement,
    ubArmenian,
    ubHebrew,
    ubArabic,
    ubSyriac,
    ubArabicSupplement,
    ubThaana,
    ubNKo,
    ubSamaritan,
    ubMandaic,
    ubSyriacSupplement,
    ubArabicExtendedA,
    ubDevanagari,
    ubBengali,
    ubGurmukhi,
    ubGujarati,
    ubOriya,
    ubTamil,
    ubTelugu,
    ubKannada,
    ubMalayalam,
    ubSinhala,
    ubThai,
    ubLao,
    ubTibetan,
    ubMyanmar,
    ubGeorgian,
    ubHangulJamo,
    ubEthiopic,
    ubEthiopicSupplement,
    ubCherokee,
    ubUnifiedCanadianAboriginalSyllabics,
    ubOgham,
    ubRunic,
    ubTagalog,
    ubHanunoo,
    ubBuhid,
    ubTagbanwa,
    ubKhmer,
    ubMongolian,
    ubUnifiedCanadianAboriginalSyllabicsExtended,
    ubLimbu,
    ubTaiLe,
    ubNewTaiLue,
    ubKhmerSymbols,
    ubBuginese,
    ubTaiTham,
    ubCombiningDiactiticalMarksExtended,
    ubBalinese,
    ubSundanese,
    ubBatak,
    ubLepcha,
    ubOlChiki,
    ubCyrillicExtendedC,
    ubGeorgianExtended,
    ubSundaneseSupplement,
    ubVedicExtensions,
    ubPhoneticExtensions,
    ubPhoneticExtensionsSupplement,
    ubCombiningDiacriticalMarksSupplement,
    ubLatinExtendedAdditional,
    ubGreekExtended,
    ubGeneralPunctuation,
    ubSuperscriptsandSubscripts,
    ubCurrencySymbols,
    ubCombiningDiacriticalMarksforSymbols,
    ubLetterlikeSymbols,
    ubNumberForms,
    ubArrows,
    ubMathematicalOperators,
    ubMiscellaneousTechnical,
    ubControlPictures,
    ubOpticalCharacterRecognition,
    ubEnclosedAlphanumerics,
    ubBoxDrawing,
    ubBlockElements,
    ubGeometricShapes,
    ubMiscellaneousSymbols,
    ubDingbats,
    ubMiscellaneousMathematicalSymbolsA,
    ubSupplementalArrowsA,
    ubBraillePatterns,
    ubSupplementalArrowsB,
    ubMiscellaneousMathematicalSymbolsB,
    ubSupplementalMathematicalOperators,
    ubMiscellaneousSymbolsandArrows,
    ubGlagolitic,
    ubLatinExtendedC,
    ubCoptic,
    ubGeorgianSupplement,
    ubTifinagh,
    ubEthiopicExtended,
    ubCyrillicExtendedA,
    ubSupplementalPunctuation,
    ubCJKRadicalsSupplement,
    ubKangxiRadicals,
    ubIdeographicDescriptionCharacters,
    ubCJKSymbolsandPunctuation,
    ubHiragana,
    ubKatakana,
    ubBopomofo,
    ubHangulCompatibilityJamo,
    ubKanbun,
    ubBopomofoExtended,
    ubCJKStrokes,
    ubKatakanaPhoneticExtensions,
    ubEnclosedCJKLettersandMonths,
    ubCJKCompatibility,
    ubCJKUnifiedIdeographsExtensionA,
    ubYijingHexagramSymbols,
    ubCJKUnifiedIdeographs,
    ubYiSyllables,
    ubYiRadicals,
    ubLisu,
    ubVai,
    ubCyrillicExtendedB,
    ubBamum,
    ubModifierToneLetters,
    ubLatinExtendedD,
    ubSylotiNagri,
    ubCommonIndicNumberForms,
    ubPhagsPa,
    ubSaurashtra,
    ubDevanagariExtended,
    ubKayahLi,
    ubRejang,
    ubHangulJamoExtendedA,
    ubJavanese,
    ubMyanmarExtendedB,
    ubCham,
    ubMyanmarExtendedA,
    ubTaiViet,
    ubMeeteiMayekExtensions,
    ubEthiopicExtendedA,
    ubLatinExtendedE,
    ubCherokeeSupplement,
    ubMeeteiMayek,
    ubHangulSyllables,
    ubHangulJamoExtendedB,
    ubHighSurrogates,
    ubHighPrivateUseSurrogates,
    ubLowSurrogates,
    ubPrivateUseArea,
    ubCJKCompatibilityIdeographs,
    ubAlphabeticPresentationForms,
    ubArabicPresentationFormsA,
    ubVariationSelectors,
    ubVerticalForms,
    ubCombiningHalfMarks,
    ubCJKCompatibilityForms,
    ubSmallFormVariants,
    ubArabicPresentationFormsB,
    ubHalfwidthandFullwidthForms,
    ubSpecials,
    ubLinearBSyllabary,
    ubLinearBIdeograms,
    ubAegeanNumbers,
    ubAncientGreekNumbers,
    ubAncientSymbols,
    ubPhaistosDisc,
    ubLycian,
    ubCarian,
    ubCopticEpactNumbers,
    ubOldItalic,
    ubGothic,
    ubOldPermic,
    ubUgaritic,
    ubOldPersian,
    ubDeseret,
    ubShavian,
    ubOsmanya,
    ubOsage,
    ubElbasan,
    ubCaucasianAlbanian,
    ubLinearA,
    ubCypriotSyllabary,
    ubImperialAramaic,
    ubPalmyrene,
    ubNabataean,
    ubHatran,
    ubPhoenician,
    ubLydian,
    ubMeroiticHieroglyphs,
    ubMeroiticCursive,
    ubKharoshthi,
    ubOldSouthArabian,
    ubOldNorthArabian,
    ubManichaean,
    ubAvestan,
    ubInscriptionalParthian,
    ubInscriptionalPahlavi,
    ubPsalterPahlavi,
    ubOldTurkic,
    ubOldHungarian,
    ubHanifiRohingya,
    ubRumiNumeralSymbols,
    ubYezidi,
    ubOldSogdian,
    ubSogdian,
    ubChorasmian,
    ubElymaic,
    ubBrahmi,
    ubKaithi,
    ubSoraSompeng,
    ubChakma,
    ubMahajani,
    ubSharada,
    ubSinhalaArchaicNumbers,
    ubKhojki,
    ubMultani,
    ubKhudawadi,
    ubGrantha,
    ubNewa,
    ubTirhuta,
    ubSiddam,
    ubModi,
    ubMongolianSupplement,
    ubTakri,
    ubAhom,
    ubDogra,
    ubWarangCiti,
    ubDivesAkuru,
    ubNandinagari,
    ubZanabazarSquare,
    ubSoyombo,
    ubPauCinHau,
    ubBhaiksuki,
    ubMarchen,
    ubMasaramGondi,
    ubGunjalaGondi,
    ubTamilSupplement,
    ubMakasar,
    ubLisuSupplement,
    ubCuneiform,
    ubCuneiformNumbersAndPunctuation,
    ubEarlyDynasticCuneiform,
    ubEgyptianHieroglyphs,
    ubEgyptianHieroglyphFormatControls,
    ubAnatolianHieroglyphs,
    ubBamumSupplement,
    ubMro,
    ubBassaVah,
    ubPahawhHmong,
    ubMedefaidrin,
    ubMiao,
    upIdeographicSymbolsAndPunctuation,
    ubTangut,
    ubTangutComponents,
    ubKhitanSmallScript,
    ubTangutSupplement,
    ubKanaSupplement,
    ubKanaExtendedA,
    ubSmallKanaExtension,
    ubNushu,
    ubDuployan,
    ubShorthandFormatControls,
    ubByzantineMusicalSymbols,
    ubMusicalSymbols,
    ubAncientGreekMusicalNotation,
    ubMayanNumerals,
    ubTaiXuanJingSymbols,
    ubCountingRodNumerals,
    ubSuttonSignWriting,
    ubMathematicalAlphanumericSymbols,
    ubGlagolithicSupplement,
    ubWancho,
    ubNyiakengPuachueHmong,
    ubMendeKikakui,
    ubIndicSiyaqNumbers,
    ubOttomanSiyaqNumbers,
    ubAdlam,
    ubArabicMathematicalAlphabeticSymbols,
    ubMahjongTiles,
    ubDominoTiles,
    ubPlayingCards,
    ubEnclosedAlphanumericSupplement,
    ubEnclosedIdeographicSupplement,
    ubMiscellaneousSymbolsAndPictographs,
    ubEmoticons,
    ubOrnamentalDingbats,
    ubTransportAndMapSymbols,
    ubAlchemicalSymbols,
    ubGeometricShapesExtended,
    ubSupplementalArrowsC,
    ubSupplementalSymbolsAndPictographs,
    ubChessSymbols,
    ubSymbolsAndPictographsExtendedA,
    ubSymbolsForLegacyComputing,
    ubCJKUnifiedIdeographsExtensionB,
    ubCJKUnifiedIdeographsExtensionC,
    ubCJKUnifiedIdeographsExtensionD,
    ubCJKUnifiedIdeographsExtensionE,
    ubCJKUnifiedIdeographsExtensionF,
    ubCJKCompatibilityIdeographsSupplement,
    ubCJKUnifiedIdeographsExtensionG,
    ubTags,
    ubVariationSelectorsSupplement,
    ubSupplementaryPrivateUseAreaA,
    ubSupplementaryPrivateUseAreaB
  );


//------------------------------------------------------------------------------
//
//              Script
//
//------------------------------------------------------------------------------
// Generated from https://www.unicode.org/iso15924/iso15924.txt (4-jul-2023)
//------------------------------------------------------------------------------
type
  // ISO-15924 script enumeration
  //
  // Generated with the following RegEx:
  //   Input: ^(....)\t(\d*)\t(.*)\t(.*)$
  //   Output: us$1, // $2: $4
  // usZzzz adjusted manually to be the first entry
  TUnicodeScript = (
    usZzzz, // 999: Code for uncoded script
    usPcun, // 015: Proto-Cuneiform
    usPelm, // 016: Proto-Elamite
    usXsux, // 020: Cuneiform, Sumero-Akkadian
    usXpeo, // 030: Old Persian
    usUgar, // 040: Ugaritic
    usEgyp, // 050: Egyptian hieroglyphs
    usEgyh, // 060: Egyptian hieratic
    usEgyd, // 070: Egyptian demotic
    usHluw, // 080: Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)
    usNkdb, // 085: Naxi Dongba (na²¹ɕi³³ to³³ba²¹, Nakhi Tomba)
    usMaya, // 090: Mayan hieroglyphs
    usSgnw, // 095: SignWriting
    usMero, // 100: Meroitic Hieroglyphs
    usMerc, // 101: Meroitic Cursive
    usPsin, // 103: Proto-Sinaitic
    usSarb, // 105: Old South Arabian
    usNarb, // 106: Old North Arabian (Ancient North Arabian)
    usChrs, // 109: Chorasmian
    usPhnx, // 115: Phoenician
    usLydi, // 116: Lydian
    usTfng, // 120: Tifinagh (Berber)
    usSamr, // 123: Samaritan
    usArmi, // 124: Imperial Aramaic
    usHebr, // 125: Hebrew
    usPalm, // 126: Palmyrene
    usHatr, // 127: Hatran
    usElym, // 128: Elymaic
    usPrti, // 130: Inscriptional Parthian
    usPhli, // 131: Inscriptional Pahlavi
    usPhlp, // 132: Psalter Pahlavi
    usPhlv, // 133: Book Pahlavi
    usAvst, // 134: Avestan
    usSyrc, // 135: Syriac
    usSyrn, // 136: Syriac (Eastern variant)
    usSyrj, // 137: Syriac (Western variant)
    usSyre, // 138: Syriac (Estrangelo variant)
    usMani, // 139: Manichaean
    usMand, // 140: Mandaic, Mandaean
    usSogd, // 141: Sogdian
    usSogo, // 142: Old Sogdian
    usOugr, // 143: Old Uyghur
    usMong, // 145: Mongolian
    usNbat, // 159: Nabataean
    usArab, // 160: Arabic
    usAran, // 161: Arabic (Nastaliq variant)
    usNkoo, // 165: N’Ko
    usAdlm, // 166: Adlam
    usRohg, // 167: Hanifi Rohingya
    usThaa, // 170: Thaana
    usOrkh, // 175: Old Turkic, Orkhon Runic
    usHung, // 176: Old Hungarian (Hungarian Runic)
    usYezi, // 192: Yezidi
    usGrek, // 200: Greek
    usCari, // 201: Carian
    usLyci, // 202: Lycian
    usCopt, // 204: Coptic
    usGoth, // 206: Gothic
    usItal, // 210: Old Italic (Etruscan, Oscan, etc.)
    usRunr, // 211: Runic
    usOgam, // 212: Ogham
    usLatn, // 215: Latin
    usLatg, // 216: Latin (Gaelic variant)
    usLatf, // 217: Latin (Fraktur variant)
    usMoon, // 218: Moon (Moon code, Moon script, Moon type)
    usOsge, // 219: Osage
    usCyrl, // 220: Cyrillic
    usCyrs, // 221: Cyrillic (Old Church Slavonic variant)
    usGlag, // 225: Glagolitic
    usElba, // 226: Elbasan
    usPerm, // 227: Old Permic
    usVith, // 228: Vithkuqi
    usArmn, // 230: Armenian
    usAghb, // 239: Caucasian Albanian
    usGeor, // 240: Georgian (Mkhedruli and Mtavruli)
    usGeok, // 241: Khutsuri (Asomtavruli and Nuskhuri)
    usDsrt, // 250: Deseret (Mormon)
    usBass, // 259: Bassa Vah
    usOsma, // 260: Osmanya
    usOlck, // 261: Ol Chiki (Ol Cemet’, Ol, Santali)
    usWara, // 262: Warang Citi (Varang Kshiti)
    usPauc, // 263: Pau Cin Hau
    usMroo, // 264: Mro, Mru
    usMedf, // 265: Medefaidrin (Oberi Okaime, Oberi Ɔkaimɛ)
    usSunu, // 274: Sunuwar
    usTnsa, // 275: Tangsa
    usVisp, // 280: Visible Speech
    usShaw, // 281: Shavian (Shaw)
    usPlrd, // 282: Miao (Pollard)
    usWcho, // 283: Wancho
    usJamo, // 284: Jamo (alias for Jamo subset of Hangul)
    usBopo, // 285: Bopomofo
    usHang, // 286: Hangul (Hangŭl, Hangeul)
    usKore, // 287: Korean (alias for Hangul + Han)
    usKits, // 288: Khitan small script
    usTeng, // 290: Tengwar
    usCirt, // 291: Cirth
    usSara, // 292: Sarati
    usPiqd, // 293: Klingon (KLI pIqaD)
    usToto, // 294: Toto
    usNagm, // 295: Nag Mundari
    usBrah, // 300: Brahmi
    usSidd, // 302: Siddham, Siddhaṃ, Siddhamātṛkā
    usRanj, // 303: Ranjana
    usKhar, // 305: Kharoshthi
    usGuru, // 310: Gurmukhi
    usNand, // 311: Nandinagari
    usGong, // 312: Gunjala Gondi
    usGonm, // 313: Masaram Gondi
    usMahj, // 314: Mahajani
    usDeva, // 315: Devanagari (Nagari)
    usSylo, // 316: Syloti Nagri
    usKthi, // 317: Kaithi
    usSind, // 318: Khudawadi, Sindhi
    usShrd, // 319: Sharada, Śāradā
    usGujr, // 320: Gujarati
    usTakr, // 321: Takri, Ṭākrī, Ṭāṅkrī
    usKhoj, // 322: Khojki
    usMult, // 323: Multani
    usModi, // 324: Modi, Moḍī
    usBeng, // 325: Bengali (Bangla)
    usTirh, // 326: Tirhuta
    usOrya, // 327: Oriya (Odia)
    usDogr, // 328: Dogra
    usSoyo, // 329: Soyombo
    usTibt, // 330: Tibetan
    usPhag, // 331: Phags-pa
    usMarc, // 332: Marchen
    usNewa, // 333: Newa, Newar, Newari, Nepāla lipi
    usBhks, // 334: Bhaiksuki
    usLepc, // 335: Lepcha (Róng)
    usLimb, // 336: Limbu
    usMtei, // 337: Meitei Mayek (Meithei, Meetei)
    usAhom, // 338: Ahom, Tai Ahom
    usZanb, // 339: Zanabazar Square (Zanabazarin Dörböljin Useg, Xewtee Dörböljin Bicig, Horizontal Square Script)
    usTelu, // 340: Telugu
    usDiak, // 342: Dives Akuru
    usGran, // 343: Grantha
    usSaur, // 344: Saurashtra
    usKnda, // 345: Kannada
    usTaml, // 346: Tamil
    usMlym, // 347: Malayalam
    usSinh, // 348: Sinhala
    usCakm, // 349: Chakma
    usMymr, // 350: Myanmar (Burmese)
    usLana, // 351: Tai Tham (Lanna)
    usThai, // 352: Thai
    usTale, // 353: Tai Le
    usTalu, // 354: New Tai Lue
    usKhmr, // 355: Khmer
    usLaoo, // 356: Lao
    usKali, // 357: Kayah Li
    usCham, // 358: Cham
    usTavt, // 359: Tai Viet
    usBali, // 360: Balinese
    usJava, // 361: Javanese
    usSund, // 362: Sundanese
    usRjng, // 363: Rejang (Redjang, Kaganga)
    usLeke, // 364: Leke
    usBatk, // 365: Batak
    usMaka, // 366: Makasar
    usBugi, // 367: Buginese
    usKawi, // 368: Kawi
    usTglg, // 370: Tagalog (Baybayin, Alibata)
    usHano, // 371: Hanunoo (Hanunóo)
    usBuhd, // 372: Buhid
    usTagb, // 373: Tagbanwa
    usSora, // 398: Sora Sompeng
    usLisu, // 399: Lisu (Fraser)
    usLina, // 400: Linear A
    usLinb, // 401: Linear B
    usCpmn, // 402: Cypro-Minoan
    usCprt, // 403: Cypriot syllabary
    usHira, // 410: Hiragana
    usKana, // 411: Katakana
    usHrkt, // 412: Japanese syllabaries (alias for Hiragana + Katakana)
    usJpan, // 413: Japanese (alias for Han + Hiragana + Katakana)
    usNkgb, // 420: Naxi Geba (na²¹ɕi³³ gʌ²¹ba²¹, 'Na-'Khi ²Ggŏ-¹baw, Nakhi Geba)
    usEthi, // 430: Ethiopic (Geʻez)
    usBamu, // 435: Bamum
    usKpel, // 436: Kpelle
    usLoma, // 437: Loma
    usMend, // 438: Mende Kikakui
    usAfak, // 439: Afaka
    usCans, // 440: Unified Canadian Aboriginal Syllabics
    usCher, // 445: Cherokee
    usHmng, // 450: Pahawh Hmong
    usHmnp, // 451: Nyiakeng Puachue Hmong
    usYiii, // 460: Yi
    usVaii, // 470: Vai
    usWole, // 480: Woleai
    usNshu, // 499: Nüshu
    usHani, // 500: Han (Hanzi, Kanji, Hanja)
    usHans, // 501: Han (Simplified variant)
    usHant, // 502: Han (Traditional variant)
    usHanb, // 503: Han with Bopomofo (alias for Han + Bopomofo)
    usKitl, // 505: Khitan large script
    usJurc, // 510: Jurchen
    usTang, // 520: Tangut
    usShui, // 530: Shuishu
    usBlis, // 550: Blissymbols
    usBrai, // 570: Braille
    usInds, // 610: Indus (Harappan)
    usRoro, // 620: Rongorongo
    usDupl, // 755: Duployan shorthand, Duployan stenography
    usQaaa, // 900: Reserved for private use (start)
    usQabx, // 949: Reserved for private use (end)
    usZsye, // 993: Symbols (Emoji variant)
    usZinh, // 994: Code for inherited script
    usZmth, // 995: Mathematical notation
    usZsym, // 996: Symbols
    usZxxx, // 997: Code for unwritten documents
    usZyyy);// 998: Code for undetermined script


type
  TISO15924 = record
    Number: Word;
    Code: string;
    Alias: string;
  end;


//------------------------------------------------------------------------------
//
//              Normalization filter
//
//------------------------------------------------------------------------------
// Used both by decomposition and composition.
//
// - Decomposition:
//   Returns True if the codepoint should be decomposed, False if it should kept
//   as-is.
//
// - Composition:
//   Returns True if the composed codepoint can be used, False if the decomposed
//   characters should be kept as-is.
//------------------------------------------------------------------------------
type
  TCodePointFilter = reference to function(CodePoint: TPascalTypeCodePoint): boolean;
  TCodePointComposeFilter = reference to function(FirstCodePoint, SecondCodePoint: TPascalTypeCodePoint; var Composite: TPascalTypeCodePoint): boolean;
  TCodePointDecomposeFilter = reference to function(Composite: TPascalTypeCodePoint; CodePoint: TPascalTypeCodePoint): boolean;


//------------------------------------------------------------------------------
//
//              PascalTypeUnicode namespace
//
//------------------------------------------------------------------------------
type
  PascalTypeUnicode = record
    const
      UCS4Replacement: Char     = #$FFFD;
      UCS4ReplacementCodePoint  = $0000FFFD;
      MaximumUCS2               = $0000FFFF;
      MaximumUTF16              = $0010FFFF;
      MaximumUCS4               = $7FFFFFFF;

      MaxHighSurrogate          = $DBFF;
      MaxLowSurrogate           = $DFFF;
      MaxSurrogate              = $DFFF;
      MinHighSurrogate          = $D800;
      MinLowSurrogate           = $DC00;
      MinSurrogate              = $D800;

    const
      cpDottedCircle            = $000025CC;


    //------------------------------------------------------------------------------
    //
    //              Canonical Combining Classes
    //
    //------------------------------------------------------------------------------
    class function CanonicalCombiningClass(ACodePoint: TPascalTypeCodePoint): Cardinal; static;


    //------------------------------------------------------------------------------
    //
    //              Normalization
    //
    //------------------------------------------------------------------------------
    //
    // Normalize: Normalizes the input in-place.
    //            Implements the "Canonical Ordering Algorithm" as described in
    //            The Unicode® Standard, Version 15.0 – Core Specification, Chapter
    //            3.11, section D109.
    //
    // Decompose: Decomposes to NFD form.
    //            Implements "Canonical Decomposition" as described in
    //            The Unicode® Standard, Version 15.0 – Core Specification, Chapter
    //            3.7, section D68.
    //            It is assumed that the input has already been normalized.
    //            The result is not normalized.
    //
    // Compose:   Composes to NFC form.
    //            Implements the "Canonical Composition Algorithm" as described in
    //            The Unicode® Standard, Version 15.0 – Core Specification, Chapter
    //            3.11, section D117.
    //            It is assumed that the input has already been normalized.
    //            The result is not normalized.
    //
    //------------------------------------------------------------------------------
    class procedure Normalize(var ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil); static;
    class function Decompose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointDecomposeFilter = nil): TPascalTypeCodePoints; static;
    class function Compose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointComposeFilter = nil): TPascalTypeCodePoints; static;


    //------------------------------------------------------------------------------
    //
    //              String conversion
    //
    //------------------------------------------------------------------------------
    // Convert between 16-bit Unicode (native char/string) and 32-bit Unicode
    //------------------------------------------------------------------------------
    class function UTF16ToUTF32(const AText: string): TPascalTypeCodePoints; static;
    class function UTF32ToUTF16(const ACodePoints: TPascalTypeCodePoints): string; static;


    //------------------------------------------------------------------------------
    //
    //              Block
    //
    //------------------------------------------------------------------------------
    class function GetBlock(ACodePoint: TPascalTypeCodePoint): TUnicodeBlock; static;
    class function GetBlockName(AScript: TUnicodeBlock): string; static;


    //------------------------------------------------------------------------------
    //
    //              Script
    //
    //------------------------------------------------------------------------------
    // ISO 15924 script values
    // See: https://www.unicode.org/iso15924/codelists.html
    //------------------------------------------------------------------------------
    class function GetScript(ACodePoint: TPascalTypeCodePoint): TUnicodeScript; static;
    class function ScriptToISO15924(AScript: TUnicodeScript): TISO15924; static;
    class function ISO15924ToScript(const ACode: string): TUnicodeScript; static;
    class function IsRightToLeft(AScript: TUnicodeScript): boolean; overload; static;
    class function IsLeftToRight(AScript: TUnicodeScript): boolean; overload; static;


    //------------------------------------------------------------------------------
    //
    //              Categorization
    //
    //------------------------------------------------------------------------------
    class function GetCategory(ACodePoint: TPascalTypeCodePoint): TCharacterCategories; static;

    class function IsAlpha(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsDigit(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsAlphaNum(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsNumberOther(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsCased(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsControl(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSpace(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsWhiteSpace(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsBlank(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsPunctuation(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsGraph(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsPrintable(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsUpper(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsLower(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsTitle(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsHexDigit(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsIsoControl(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsFormatControl(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSymbol(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsNumber(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsNonSpacing(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOpenPunctuation(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsClosePunctuation(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsInitialPunctuation(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsFinalPunctuation(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsComposed(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsQuotationMark(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSymmetric(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsMirroring(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsNonBreaking(ACodePoint: TPascalTypeCodePoint): boolean; static;

    // Directionality class functions
    class function IsRightToLeft(ACodePoint: TPascalTypeCodePoint): boolean; overload; static;
    class function IsLeftToRight(ACodePoint: TPascalTypeCodePoint): boolean; overload; static;
    class function IsStrong(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsWeak(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsNeutral(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSeparator(ACodePoint: TPascalTypeCodePoint): boolean; static;

    // Other character test class functions
    class function IsMark(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsModifier(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsLetterNumber(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsConnectionPunctuation(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsDash(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsMath(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsCurrency(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsModifierSymbol(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSpacingMark(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsEnclosing(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsPrivate(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSurrogate(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsLineSeparator(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsParagraphSeparator(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsIdentifierStart(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsIdentifierPart(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsDefined(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsUndefined(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsHan(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsHangul(ACodePoint: TPascalTypeCodePoint): boolean; static;

    class function IsUnassigned(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsLetterOther(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsConnector(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsPunctuationOther(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSymbolOther(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsLeftToRightEmbedding(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsLeftToRightOverride(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsRightToLeftArabic(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsRightToLeftEmbedding(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsRightToLeftOverride(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsPopDirectionalFormat(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsEuropeanNumber(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsEuropeanNumberSeparator(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsEuropeanNumberTerminator(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsArabicNumber(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsCommonNumberSeparator(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsBoundaryNeutral(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSegmentSeparator(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherNeutrals(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsASCIIHexDigit(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsBidiControl(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsDeprecated(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsDiacritic(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsExtender(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsHyphen(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsIdeographic(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsIDSBinaryOperator(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsIDSTrinaryOperator(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsJoinControl(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsLogicalOrderException(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsNonCharacterCodePoint(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherAlphabetic(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherDefaultIgnorableCodePoint(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherGraphemeExtend(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherIDContinue(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherIDStart(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherLowercase(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherMath(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsOtherUppercase(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsPatternSyntax(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsPatternWhiteSpace(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsRadical(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSoftDotted(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsSTerm(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsTerminalPunctuation(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsUnifiedIdeograph(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsVariationSelector(ACodePoint: TPascalTypeCodePoint): boolean; static;

    //------------------------------------------------------------------------------
    //
    //              Shaping
    //
    //------------------------------------------------------------------------------
    class function IsDefaultIgnorable(ACodePoint: TPascalTypeCodePoint): boolean; static;

    // Space estimates based on:
    // https://unicode.org/charts/PDF/U2000.pdf
    // https://docs.microsoft.com/en-us/typography/develop/character-design-standards/whitespace
    type
      TUnicodeSpaceType = (
        ustNOT_SPACE       = 0,
        ustSPACE_EM        = 1,
        ustSPACE_EM_2      = 2,
        ustSPACE_EM_3      = 3,
        ustSPACE_EM_4      = 4,
        ustSPACE_EM_5      = 5,
        ustSPACE_EM_6      = 6,
        ustSPACE_EM_16     = 16,
        ustSPACE_4_EM_18   , // 4/18th of an EM!
        ustSPACE           ,
        ustSPACE_FIGURE    ,
        ustSPACE_PUNCTUATION,
        ustSPACE_NARROW);

    class function GetSpaceType(ACodePoint: TPascalTypeCodePoint): TUnicodeSpaceType; static;
  end;

//------------------------------------------------------------------------------

function UnicodeDecompose(const Codes: TPascalTypeCodePoints; Compatible: Boolean = False; Filter: TCodePointDecomposeFilter = nil): TPascalTypeCodePoints;
function UnicodeCompose(const Codes: TPascalTypeCodePoints; Compatible: Boolean = False; Filter: TCodePointComposeFilter = nil): TPascalTypeCodePoints;


//------------------------------------------------------------------------------
//
//              Hangul
//
//------------------------------------------------------------------------------
// Constants for support of Conjoining Jamo Behavior as described in
// The Unicode® Standard, Version 15.0 – Core Specification, Chapter 3.12
//------------------------------------------------------------------------------
type
  Hangul = record
    const
      // Constants for hangul composition and hangul-to-jamo decomposition
      JamoLBase = $1100;             // Leading consonant
      JamoVBase = $1161;             // Vovel
      JamoTBase = $11A7;             // Trailing consonant

      JamoLCount = 19;
      JamoVCount = 21;
      JamoTCount = 28;

      JamoNCount = JamoVCount * JamoTCount;     // 588
      JamoSCount = JamoLCount * JamoNCount;     // 11,172
      JamoVTCount = JamoVCount * JamoTCount;    // 6,569,136

      JamoLLimit = JamoLBase + JamoLCount;      // $1113
      JamoVLimit = JamoVBase + JamoVCount;      // $1176
      JamoTLimit = JamoTBase + JamoTCount;      // $11C3

      HangulSBase = $AC00;             // Hangul syllables start code point
      HangulCount = JamoLCount * JamoVCount * JamoTCount;
      HangulLimit = HangulSBase + HangulCount;  // $D7A4

      // Composed LVT syllable
    class function IsHangul(ACodePoint: TPascalTypeCodePoint): boolean; static;
      // Composed LV syllable
    class function IsHangulLV(ACodePoint: TPascalTypeCodePoint): boolean; static;

    // Combining leading consonant
    class function IsJamoL(ACodePoint: TPascalTypeCodePoint): Boolean; static;
    // Combining medial vowel
    class function IsJamoV(ACodePoint: TPascalTypeCodePoint): Boolean; static;
    // Combining trailing consonant
    class function IsJamoT(ACodePoint: TPascalTypeCodePoint): Boolean; static;

    // Leading consonant
    class function IsL(ACodePoint: TPascalTypeCodePoint): Boolean; static;
    // Medial vowel
    class function IsV(ACodePoint: TPascalTypeCodePoint): Boolean; static;
    // Trailing consonant
    class function IsT(ACodePoint: TPascalTypeCodePoint): Boolean; static;
    // Tone mark
    class function IsTone(ACodePoint: TPascalTypeCodePoint): Boolean; static;
  end;

//------------------------------------------------------------------------------
//
//              Trie data structure
//
//------------------------------------------------------------------------------
type
  TUnicodeTrie<T> = array[byte] of TArray<TArray<T>>;

  TUnicodeTrieEx<T> = record
  private
    FLoaded: boolean;
    function GetValue(ACodePoint: TPascalTypeCodePoint): T;
    procedure SetValue(ACodePoint: TPascalTypeCodePoint; const Value: T);
  public
    Trie: TUnicodeTrie<T>;

    function GetPointer(ACodePoint: TPascalTypeCodePoint; AExpand: boolean = False): pointer;
    function TryGetValue(ACodePoint: TPascalTypeCodePoint; var Value: T): boolean;

    property Values[ACodePoint: TPascalTypeCodePoint]: T read GetValue write SetValue; default;
    property Loaded: boolean read FLoaded write FLoaded;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

{$if defined(UNICODE_RAW_DATA)}
  {$R 'PascalType.Unicode.res' 'PascalType.Unicode.rc'}
{$elseif defined(UNICODE_ZLIB_DATA)}
  {$R 'PascalType.UnicodeZLib.res' 'PascalType.UnicodeZLib.rc'}
{$ifend}

uses
  Generics.Collections,
  SysUtils,
{$if defined(UNICODE_ZLIB_DATA)}
  ZLib,
{$ifend}
  System.Classes;

const
  ResourceType = 'UNICODEDATA';

//------------------------------------------------------------------------------
//
//              Hangul
//
//------------------------------------------------------------------------------
class function Hangul.IsHangul(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := (ACodePoint >= HangulSBase) and (ACodePoint < HangulLimit);
end;

class function Hangul.IsHangulLV(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsHangul(ACodePoint) and ((ACodePoint-HangulSBase) mod JamoTCount = 0);
end;

class function Hangul.IsJamoL(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := (ACodePoint >= JamoLBase) and (ACodePoint < JamoLLimit);
end;

class function Hangul.IsL(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := ((ACodePoint >= JamoLBase) and (ACodePoint <= $115f)) or ((ACodePoint >= $a960) and (ACodePoint <= $a97c));
end;

class function Hangul.IsJamoT(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := (ACodePoint >= JamoTBase) and (ACodePoint < JamoTLimit);
  // Note: FontKit says (ACodePoint > JamoTBase) and (ACodePoint < JamoTLimit);
end;

class function Hangul.IsT(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := ((ACodePoint > JamoTBase) and (ACodePoint <= $11ff)) or ((ACodePoint >= $d7cb) and (ACodePoint <= $d7fb));
end;

class function Hangul.IsJamoV(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := (ACodePoint >= JamoVBase) and (ACodePoint < JamoVLimit);
end;

class function Hangul.IsV(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := ((ACodePoint >= JamoVBase-1) and (ACodePoint <= $11a7)) or ((ACodePoint >= $d7b0) and (ACodePoint <= $d7c6));
end;

class function Hangul.IsTone(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := (ACodePoint >= $302E) and (ACodePoint <= $302F);
end;

//------------------------------------------------------------------------------
//
//              Trie data structure
//
//------------------------------------------------------------------------------
function TUnicodeTrieEx<T>.GetPointer(ACodePoint: TPascalTypeCodePoint; AExpand: boolean): pointer;
var
  Plane, Page, Chr: Byte;
begin
  Plane := (ACodePoint shr 16) and $FF;
  Page := (ACodePoint shr 8) and $FF;
  Chr := ACodePoint and $FF;

  if (Trie[Plane] = nil) then
  begin
    if (not AExpand) then
      Exit(nil);
    SetLength(Trie[Plane], 256);
  end;

  if (Trie[Plane, Page] = nil) then
  begin
    if (not AExpand) then
      Exit(nil);
    SetLength(Trie[Plane, Page], 256);
  end;

  Result := @Trie[Plane, Page, Chr];
end;

function TUnicodeTrieEx<T>.GetValue(ACodePoint: TPascalTypeCodePoint): T;
begin
  TryGetValue(ACodePoint, Result);
end;

procedure TUnicodeTrieEx<T>.SetValue(ACodePoint: TPascalTypeCodePoint; const Value: T);
var
  Plane, Page, Chr: Byte;
begin
  Plane := (ACodePoint shr 16) and $FF;
  Page := (ACodePoint shr 8) and $FF;
  Chr := ACodePoint and $FF;

  if (Trie[Plane] = nil) then
    SetLength(Trie[Plane], 256);

  if (Trie[Plane, Page] = nil) then
    SetLength(Trie[Plane, Page], 256);

  Trie[Plane, Page, Chr] := Value;
end;


function TUnicodeTrieEx<T>.TryGetValue(ACodePoint: TPascalTypeCodePoint; var Value: T): boolean;
var
  Plane, Page, Chr: Byte;
begin
  Plane := (ACodePoint shr 16) and $FF;
  Page := (ACodePoint shr 8) and $FF;
  Chr := ACodePoint and $FF;

  Result := (Trie[Plane] <> nil) and (Trie[Plane, Page] <> nil);
  if (Result) then
    Value := Trie[Plane, Page, Chr]
  else
    Value := Default(T);
end;

//------------------------------------------------------------------------------
//
//              Categorization
//
//------------------------------------------------------------------------------
type
  PCharacterCategories = ^TCharacterCategories;

var
  UnicodeCategories: TUnicodeTrieEx<TCharacterCategories>;

const
  // Some predefined sets to shorten parameter lists below and ease repeative usage
  ClassLetter = [ccLetterUppercase, ccLetterLowercase, ccLetterTitlecase, ccLetterModifier, ccLetterOther];
  ClassSpace = [ccSeparatorSpace];
  ClassPunctuation = [ccPunctuationConnector, ccPunctuationDash, ccPunctuationOpen, ccPunctuationClose,
    ccPunctuationOther, ccPunctuationInitialQuote, ccPunctuationFinalQuote];
  ClassMark = [ccMarkNonSpacing, ccMarkSpacingCombining, ccMarkEnclosing];
  ClassNumber = [ccNumberDecimalDigit, ccNumberLetter, ccNumberOther];
  ClassSymbol = [ccSymbolMath, ccSymbolCurrency, ccSymbolModifier, ccSymbolOther];
  ClassEuropeanNumber = [ccEuropeanNumber, ccEuropeanNumberSeparator, ccEuropeanNumberTerminator];

procedure LoadUnicodeCategories;
var
  ResourceStream: TStream;
  Stream: TStream;
  Reader: TBinaryReader;
  RangeStart: TPascalTypeCodePoint;
  RangeStop: TPascalTypeCodePoint;
  Size: integer;
  Category: TCharacterCategory;
  i: Integer;
  CodePoint: TPascalTypeCodePoint;
  Categories: PCharacterCategories;
begin
  if UnicodeCategories.Loaded then
    exit;
  UnicodeCategories.Loaded := True;

  ResourceStream := TResourceStream.Create(HInstance, 'CATEGORIES', ResourceType);

{$if defined(UNICODE_RAW_DATA)}
  Stream := ResourceStream;
{$elseif defined(UNICODE_ZLIB_DATA)}
  try

    Stream := TDecompressionStream.Create(ResourceStream, 15, True);

  except
    ResourceStream.Free;
    raise;
  end;
{$ifend}

  Reader := TBinaryReader.Create(Stream, nil, True);
  try
    RangeStart := Default(TPascalTypeCodePoint);
    RangeStop := Default(TPascalTypeCodePoint);

    while (Stream.Position < Stream.Size) do
    begin
      // 1) Read category
      Stream.Read(Category, SizeOf(Category));

      // 2) Read size of ranges, and ranges
      Stream.Read(Size, SizeOf(Size));
      if (Size = 0) then
        continue;

      for i := 0 to Size - 1 do
      begin
        Stream.ReadBuffer(RangeStart, 3);
        Stream.ReadBuffer(RangeStop, 3);
        Assert(RangeStart < $1000000);
        Assert(RangeStop < $1000000);

        // 3) Go through every range and add the current category to each code point
        for CodePoint := RangeStart to RangeStop do
        begin
          Categories := UnicodeCategories.GetPointer(CodePoint, True);
          Include(Categories^, Category)
        end;
      end;
    end;
    Assert(Stream.Position = Stream.Size);
  finally
    Reader.Free;
  end;
end;

class function PascalTypeUnicode.GetCategory(ACodePoint: TPascalTypeCodePoint): TCharacterCategories;
begin
  Assert(ACodePoint < $1000000);

  if not UnicodeCategories.Loaded then
    LoadUnicodeCategories;

  Result := UnicodeCategories[ACodePoint];
end;

function IsInCategories(ACodePoint: TPascalTypeCodePoint; ACategories: TCharacterCategories): Boolean;
// determines whether the ACodePoint is in the given category
begin
  Result := (PascalTypeUnicode.GetCategory(ACodePoint) * ACategories <> [])
end;

class function PascalTypeUnicode.IsAlpha(ACodePoint: TPascalTypeCodePoint): boolean; // Is the character alphabetic?
begin
  Result := IsInCategories(ACodePoint, ClassLetter);
end;

class function PascalTypeUnicode.IsDigit(ACodePoint: TPascalTypeCodePoint): boolean; // Is the character a digit?
begin
  Result := IsInCategories(ACodePoint, [ccNumberDecimalDigit]);
end;

class function PascalTypeUnicode.IsAlphaNum(ACodePoint: TPascalTypeCodePoint): boolean; // Is the character alphabetic or a number?
begin
  Result := IsInCategories(ACodePoint, ClassLetter + [ccNumberDecimalDigit]);
end;

class function PascalTypeUnicode.IsNumberOther(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccNumberOther]);
end;

class function PascalTypeUnicode.IsCased(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a "cased" character, i.e. either lower case, title case or upper case
begin
  Result := IsInCategories(ACodePoint, [ccLetterLowercase, ccLetterTitleCase, ccLetterUppercase]);
end;

class function PascalTypeUnicode.IsControl(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a control character?
begin
  Result := IsInCategories(ACodePoint, [ccOtherControl, ccOtherFormat]);
end;

class function PascalTypeUnicode.IsSpace(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a spacing character?
begin
  Result := IsInCategories(ACodePoint, ClassSpace);
end;

class function PascalTypeUnicode.IsWhiteSpace(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a white space character (same as UnicodeIsSpace plus
// tabulator, new line etc.)?
begin
  Result := IsInCategories(ACodePoint, ClassSpace + [ccWhiteSpace, ccSegmentSeparator]);
end;

class function PascalTypeUnicode.IsBlank(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a space separator?
begin
  Result := IsInCategories(ACodePoint, [ccSeparatorSpace]);
end;

class function PascalTypeUnicode.IsPunctuation(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a punctuation mark?
begin
  Result := IsInCategories(ACodePoint, ClassPunctuation);
end;

class function PascalTypeUnicode.IsGraph(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character graphical?
begin
  Result := IsInCategories(ACodePoint, ClassMark + ClassNumber + ClassLetter + ClassPunctuation + ClassSymbol);
end;

class function PascalTypeUnicode.IsPrintable(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character printable?
begin
  Result := IsInCategories(ACodePoint, ClassMark + ClassNumber + ClassLetter + ClassPunctuation + ClassSymbol +
    [ccSeparatorSpace]);
end;

class function PascalTypeUnicode.IsUpper(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character already upper case?
begin
  Result := IsInCategories(ACodePoint, [ccLetterUppercase]);
end;

class function PascalTypeUnicode.IsLower(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character already lower case?
begin
  Result := IsInCategories(ACodePoint, [ccLetterLowercase]);
end;

class function PascalTypeUnicode.IsTitle(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character already title case?
begin
  Result := IsInCategories(ACodePoint, [ccLetterTitlecase]);
end;

class function PascalTypeUnicode.IsHexDigit(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a hex digit?
begin
  Result := IsInCategories(ACodePoint, [ccHexDigit]);
end;

class function PascalTypeUnicode.IsIsoControl(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a C0 control character (< 32)?
begin
  Result := IsInCategories(ACodePoint, [ccOtherControl]);
end;

class function PascalTypeUnicode.IsFormatControl(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a format control character?
begin
  Result := IsInCategories(ACodePoint, [ccOtherFormat]);
end;

class function PascalTypeUnicode.IsSymbol(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a symbol?
begin
  Result := IsInCategories(ACodePoint, ClassSymbol);
end;

class function PascalTypeUnicode.IsNumber(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a number or digit?
begin
  Result := IsInCategories(ACodePoint, ClassNumber);
end;

class function PascalTypeUnicode.IsNonSpacing(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character non-spacing?
begin
  Result := IsInCategories(ACodePoint, [ccMarkNonSpacing]);
end;

class function PascalTypeUnicode.IsOpenPunctuation(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character an open/left punctuation (e.g. '[')?
begin
  Result := IsInCategories(ACodePoint, [ccPunctuationOpen]);
end;

class function PascalTypeUnicode.IsClosePunctuation(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character an close/right punctuation (e.g. ']')?
begin
  Result := IsInCategories(ACodePoint, [ccPunctuationClose]);
end;

class function PascalTypeUnicode.IsInitialPunctuation(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character an initial punctuation (e.g. U+2018 LEFT SINGLE QUOTATION MARK)?
begin
  Result := IsInCategories(ACodePoint, [ccPunctuationInitialQuote]);
end;

class function PascalTypeUnicode.IsFinalPunctuation(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a final punctuation (e.g. U+2019 RIGHT SINGLE QUOTATION MARK)?
begin
  Result := IsInCategories(ACodePoint, [ccPunctuationFinalQuote]);
end;

class function PascalTypeUnicode.IsComposed(ACodePoint: TPascalTypeCodePoint): boolean;
// Can the character be decomposed into a set of other characters?
begin
  Result := IsInCategories(ACodePoint, [ccComposed]);
end;

class function PascalTypeUnicode.IsQuotationMark(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character one of the many quotation marks?
begin
  Result := IsInCategories(ACodePoint, [ccQuotationMark]);
end;

class function PascalTypeUnicode.IsSymmetric(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character one that has an opposite form (i.e. <>)?
begin
  Result := IsInCategories(ACodePoint, [ccSymmetric]);
end;

class function PascalTypeUnicode.IsMirroring(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character mirroring (superset of symmetric)?
begin
  Result := IsInCategories(ACodePoint, [ccMirroring]);
end;

class function PascalTypeUnicode.IsNonBreaking(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character non-breaking (i.e. non-breaking space)?
begin
  Result := IsInCategories(ACodePoint, [ccNonBreaking]);
end;

class function PascalTypeUnicode.IsRightToLeft(ACodePoint: TPascalTypeCodePoint): boolean;
// Does the character have strong right-to-left directionality (i.e. Arabic letters)?
begin
  Result := IsInCategories(ACodePoint, [ccRightToLeft]);
end;

class function PascalTypeUnicode.IsLeftToRight(ACodePoint: TPascalTypeCodePoint): boolean;
// Does the character have strong left-to-right directionality (i.e. Latin letters)?
begin
  Result := IsInCategories(ACodePoint, [ccLeftToRight]);
end;

class function PascalTypeUnicode.IsStrong(ACodePoint: TPascalTypeCodePoint): boolean;
// Does the character have strong directionality?
begin
  Result := IsInCategories(ACodePoint, [ccLeftToRight, ccRightToLeft]);
end;

class function PascalTypeUnicode.IsWeak(ACodePoint: TPascalTypeCodePoint): boolean;
// Does the character have weak directionality (i.e. numbers)?
begin
  Result := IsInCategories(ACodePoint, ClassEuropeanNumber + [ccArabicNumber, ccCommonNumberSeparator]);
end;

class function PascalTypeUnicode.IsNeutral(ACodePoint: TPascalTypeCodePoint): boolean;
// Does the character have neutral directionality (i.e. whitespace)?
begin
  Result := IsInCategories(ACodePoint, [ccSeparatorParagraph, ccSegmentSeparator, ccWhiteSpace, ccOtherNeutrals]);
end;

class function PascalTypeUnicode.IsSeparator(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a block or segment separator?
begin
  Result := IsInCategories(ACodePoint, [ccSeparatorParagraph, ccSegmentSeparator]);
end;

class function PascalTypeUnicode.IsMark(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a mark of some kind?
begin
  Result := IsInCategories(ACodePoint, ClassMark);
end;

class function PascalTypeUnicode.IsModifier(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a letter modifier?
begin
  Result := IsInCategories(ACodePoint, [ccLetterModifier]);
end;

class function PascalTypeUnicode.IsLetterNumber(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a number represented by a letter?
begin
  Result := IsInCategories(ACodePoint, [ccNumberLetter]);
end;

class function PascalTypeUnicode.IsConnectionPunctuation(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character connecting punctuation?
begin
  Result := IsInCategories(ACodePoint, [ccPunctuationConnector]);
end;

class function PascalTypeUnicode.IsDash(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a dash punctuation?
begin
  Result := IsInCategories(ACodePoint, [ccPunctuationDash]);
end;

class function PascalTypeUnicode.IsMath(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a math character?
begin
  Result := IsInCategories(ACodePoint, [ccSymbolMath]);
end;

class function PascalTypeUnicode.IsCurrency(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a currency character?
begin
  Result := IsInCategories(ACodePoint, [ccSymbolCurrency]);
end;

class function PascalTypeUnicode.IsModifierSymbol(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a modifier symbol?
begin
  Result := IsInCategories(ACodePoint, [ccSymbolModifier]);
end;

class function PascalTypeUnicode.IsSpacingMark(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a spacing mark?
begin
  Result := IsInCategories(ACodePoint, [ccMarkSpacingCombining]);
end;

class function PascalTypeUnicode.IsEnclosing(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character enclosing (i.e. enclosing box)?
begin
  Result := IsInCategories(ACodePoint, [ccMarkEnclosing]);
end;

class function PascalTypeUnicode.IsPrivate(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character from the Private Use Area?
begin
  Result := IsInCategories(ACodePoint, [ccOtherPrivate]);
end;

class function PascalTypeUnicode.IsSurrogate(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character one of the surrogate codes?
begin
  Result := IsInCategories(ACodePoint, [ccOtherSurrogate]);
end;

class function PascalTypeUnicode.IsLineSeparator(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a line separator?
begin
  Result := IsInCategories(ACodePoint, [ccSeparatorLine]);
end;

class function PascalTypeUnicode.IsParagraphSeparator(ACodePoint: TPascalTypeCodePoint): boolean;
// Is th character a paragraph separator;
begin
  Result := IsInCategories(ACodePoint, [ccSeparatorParagraph]);
end;

class function PascalTypeUnicode.IsIdentifierStart(ACodePoint: TPascalTypeCodePoint): boolean;
// Can the character begin an identifier?
begin
  Result := IsInCategories(ACodePoint, ClassLetter + [ccNumberLetter]);
end;

class function PascalTypeUnicode.IsIdentifierPart(ACodePoint: TPascalTypeCodePoint): boolean;
// Can the character appear in an identifier?
begin
  Result := IsInCategories(ACodePoint, ClassLetter + [ccNumberLetter, ccMarkNonSpacing, ccMarkSpacingCombining,
    ccNumberDecimalDigit, ccPunctuationConnector, ccOtherFormat]);
end;

class function PascalTypeUnicode.IsDefined(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character defined (appears in one of the data files)?
begin
  Result := IsInCategories(ACodePoint, [ccAssigned]);
end;

class function PascalTypeUnicode.IsUndefined(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character undefined (not assigned in the Unicode database)?
begin
  Result := not IsInCategories(ACodePoint, [ccAssigned]);
end;

class function PascalTypeUnicode.IsHan(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a Han ideograph?
begin
  Result := ((ACodePoint >= $4E00) and (ACodePoint <= $9FFF))  or ((ACodePoint >= $F900) and (ACodePoint <= $FAFF));
end;

class function PascalTypeUnicode.IsHangul(ACodePoint: TPascalTypeCodePoint): boolean;
// Is the character a pre-composed Hangul syllable?
begin
  Result := Hangul.IsHangul(ACodePoint);
end;

class function PascalTypeUnicode.IsUnassigned(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherUnassigned]);
end;

class function PascalTypeUnicode.IsLetterOther(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccLetterOther]);
end;

class function PascalTypeUnicode.IsConnector(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccPunctuationConnector]);
end;

class function PascalTypeUnicode.IsPunctuationOther(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccPunctuationOther]);
end;

class function PascalTypeUnicode.IsSymbolOther(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccSymbolOther]);
end;

class function PascalTypeUnicode.IsLeftToRightEmbedding(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccLeftToRightEmbedding]);
end;

class function PascalTypeUnicode.IsLeftToRightOverride(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccLeftToRightOverride]);
end;

class function PascalTypeUnicode.IsRightToLeftArabic(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccRightToLeftArabic]);
end;

class function PascalTypeUnicode.IsRightToLeftEmbedding(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccRightToLeftEmbedding]);
end;

class function PascalTypeUnicode.IsRightToLeftOverride(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccRightToLeftOverride]);
end;

class function PascalTypeUnicode.IsPopDirectionalFormat(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccPopDirectionalFormat]);
end;

class function PascalTypeUnicode.IsEuropeanNumber(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccEuropeanNumber]);
end;

class function PascalTypeUnicode.IsEuropeanNumberSeparator(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccEuropeanNumberSeparator]);
end;

class function PascalTypeUnicode.IsEuropeanNumberTerminator(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccEuropeanNumberTerminator]);
end;

class function PascalTypeUnicode.IsArabicNumber(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccArabicNumber]);
end;

class function PascalTypeUnicode.IsCommonNumberSeparator(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccCommonNumberSeparator]);
end;

class function PascalTypeUnicode.IsBoundaryNeutral(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccBoundaryNeutral]);
end;

class function PascalTypeUnicode.IsSegmentSeparator(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccSegmentSeparator]);
end;

class function PascalTypeUnicode.IsOtherNeutrals(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherNeutrals]);
end;

class function PascalTypeUnicode.IsASCIIHexDigit(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccASCIIHexDigit]);
end;

class function PascalTypeUnicode.IsBidiControl(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccBidiControl]);
end;

class function PascalTypeUnicode.IsDeprecated(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccDeprecated]);
end;

class function PascalTypeUnicode.IsDiacritic(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccDiacritic]);
end;

class function PascalTypeUnicode.IsExtender(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccExtender]);
end;

class function PascalTypeUnicode.IsHyphen(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccHyphen]);
end;

class function PascalTypeUnicode.IsIdeographic(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccIdeographic]);
end;

class function PascalTypeUnicode.IsIDSBinaryOperator(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccIDSBinaryOperator]);
end;

class function PascalTypeUnicode.IsIDSTrinaryOperator(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccIDSTrinaryOperator]);
end;

class function PascalTypeUnicode.IsJoinControl(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccJoinControl]);
end;

class function PascalTypeUnicode.IsLogicalOrderException(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccLogicalOrderException]);
end;

class function PascalTypeUnicode.IsNonCharacterCodePoint(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccNonCharacterCodePoint]);
end;

class function PascalTypeUnicode.IsOtherAlphabetic(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherAlphabetic]);
end;

class function PascalTypeUnicode.IsOtherDefaultIgnorableCodePoint(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherDefaultIgnorableCodePoint]);
end;

class function PascalTypeUnicode.IsOtherGraphemeExtend(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherGraphemeExtend]);
end;

class function PascalTypeUnicode.IsOtherIDContinue(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherIDContinue]);
end;

class function PascalTypeUnicode.IsOtherIDStart(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherIDStart]);
end;

class function PascalTypeUnicode.IsOtherLowercase(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherLowercase]);
end;

class function PascalTypeUnicode.IsOtherMath(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherMath]);
end;

class function PascalTypeUnicode.IsOtherUppercase(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccOtherUppercase]);
end;

class function PascalTypeUnicode.IsPatternSyntax(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccPatternSyntax]);
end;

class function PascalTypeUnicode.IsPatternWhiteSpace(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccPatternWhiteSpace]);
end;

class function PascalTypeUnicode.IsRadical(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccRadical]);
end;

class function PascalTypeUnicode.IsSoftDotted(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccSoftDotted]);
end;

class function PascalTypeUnicode.IsSTerm(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccSTerm]);
end;

class function PascalTypeUnicode.IsTerminalPunctuation(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccTerminalPunctuation]);
end;

class function PascalTypeUnicode.IsUnifiedIdeograph(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccUnifiedIdeograph]);
end;

class function PascalTypeUnicode.IsVariationSelector(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsInCategories(ACodePoint, [ccVariationSelector]);
end;


//------------------------------------------------------------------------------
//
//              Block
//
//------------------------------------------------------------------------------
type
  TUnicodeBlockRange = record
    RangeStart,
    RangeEnd: Cardinal;
  end;

  TUnicodeBlockData = record
    Range: TUnicodeBlockRange;
    Name: string;
  end;

const
  UnicodeBlockData: array [TUnicodeBlock] of TUnicodeBlockData =
    ((Range:(RangeStart: $FFFFFFFF; RangeEnd: $0000); Name: 'No-block'),
    (Range:(RangeStart: $0000; RangeEnd: $007F); Name: 'Basic Latin'),
    (Range:(RangeStart: $0080; RangeEnd: $00FF); Name: 'Latin-1 Supplement'),
    (Range:(RangeStart: $0100; RangeEnd: $017F); Name: 'Latin Extended-A'),
    (Range:(RangeStart: $0180; RangeEnd: $024F); Name: 'Latin Extended-B'),
    (Range:(RangeStart: $0250; RangeEnd: $02AF); Name: 'IPA Extensions'),
    (Range:(RangeStart: $02B0; RangeEnd: $02FF); Name: 'Spacing Modifier Letters'),
    (Range:(RangeStart: $0300; RangeEnd: $036F); Name: 'Combining Diacritical Marks'),
    (Range:(RangeStart: $0370; RangeEnd: $03FF); Name: 'Greek and Coptic'),
    (Range:(RangeStart: $0400; RangeEnd: $04FF); Name: 'Cyrillic'),
    (Range:(RangeStart: $0500; RangeEnd: $052F); Name: 'Cyrillic Supplement'),
    (Range:(RangeStart: $0530; RangeEnd: $058F); Name: 'Armenian'),
    (Range:(RangeStart: $0590; RangeEnd: $05FF); Name: 'Hebrew'),
    (Range:(RangeStart: $0600; RangeEnd: $06FF); Name: 'Arabic'),
    (Range:(RangeStart: $0700; RangeEnd: $074F); Name: 'Syriac'),
    (Range:(RangeStart: $0750; RangeEnd: $077F); Name: 'Arabic Supplement'),
    (Range:(RangeStart: $0780; RangeEnd: $07BF); Name: 'Thaana'),
    (Range:(RangeStart: $07C0; RangeEnd: $07FF); Name: 'NKo'),
    (Range:(RangeStart: $0800; RangeEnd: $083F); Name: 'Samaritan'),
    (Range:(RangeStart: $0840; RangeEnd: $085F); Name: 'Mandaic'),
    (Range:(RangeStart: $0860; RangeEnd: $086F); Name: 'Syriac Supplement'),
    (Range:(RangeStart: $08A0; RangeEnd: $08FF); Name: 'Arabic Extended-A'),
    (Range:(RangeStart: $0900; RangeEnd: $097F); Name: 'Devanagari'),
    (Range:(RangeStart: $0980; RangeEnd: $09FF); Name: 'Bengali'),
    (Range:(RangeStart: $0A00; RangeEnd: $0A7F); Name: 'Gurmukhi'),
    (Range:(RangeStart: $0A80; RangeEnd: $0AFF); Name: 'Gujarati'),
    (Range:(RangeStart: $0B00; RangeEnd: $0B7F); Name: 'Oriya'),
    (Range:(RangeStart: $0B80; RangeEnd: $0BFF); Name: 'Tamil'),
    (Range:(RangeStart: $0C00; RangeEnd: $0C7F); Name: 'Telugu'),
    (Range:(RangeStart: $0C80; RangeEnd: $0CFF); Name: 'Kannada'),
    (Range:(RangeStart: $0D00; RangeEnd: $0D7F); Name: 'Malayalam'),
    (Range:(RangeStart: $0D80; RangeEnd: $0DFF); Name: 'Sinhala'),
    (Range:(RangeStart: $0E00; RangeEnd: $0E7F); Name: 'Thai'),
    (Range:(RangeStart: $0E80; RangeEnd: $0EFF); Name: 'Lao'),
    (Range:(RangeStart: $0F00; RangeEnd: $0FFF); Name: 'Tibetan'),
    (Range:(RangeStart: $1000; RangeEnd: $109F); Name: 'Myanmar'),
    (Range:(RangeStart: $10A0; RangeEnd: $10FF); Name: 'Georgian'),
    (Range:(RangeStart: $1100; RangeEnd: $11FF); Name: 'Hangul Jamo'),
    (Range:(RangeStart: $1200; RangeEnd: $137F); Name: 'Ethiopic'),
    (Range:(RangeStart: $1380; RangeEnd: $139F); Name: 'Ethiopic Supplement'),
    (Range:(RangeStart: $13A0; RangeEnd: $13FF); Name: 'Cherokee'),
    (Range:(RangeStart: $1400; RangeEnd: $167F); Name: 'Unified Canadian Aboriginal Syllabics'),
    (Range:(RangeStart: $1680; RangeEnd: $169F); Name: 'Ogham'),
    (Range:(RangeStart: $16A0; RangeEnd: $16FF); Name: 'Runic'),
    (Range:(RangeStart: $1700; RangeEnd: $171F); Name: 'Tagalog'),
    (Range:(RangeStart: $1720; RangeEnd: $173F); Name: 'Hanunoo'),
    (Range:(RangeStart: $1740; RangeEnd: $175F); Name: 'Buhid'),
    (Range:(RangeStart: $1760; RangeEnd: $177F); Name: 'Tagbanwa'),
    (Range:(RangeStart: $1780; RangeEnd: $17FF); Name: 'Khmer'),
    (Range:(RangeStart: $1800; RangeEnd: $18AF); Name: 'Mongolian'),
    (Range:(RangeStart: $18B0; RangeEnd: $18FF); Name: 'Unified Canadian Aboriginal Syllabics Extended'),
    (Range:(RangeStart: $1900; RangeEnd: $194F); Name: 'Limbu'),
    (Range:(RangeStart: $1950; RangeEnd: $197F); Name: 'Tai Le'),
    (Range:(RangeStart: $1980; RangeEnd: $19DF); Name: 'New Tai Lue'),
    (Range:(RangeStart: $19E0; RangeEnd: $19FF); Name: 'Khmer Symbols'),
    (Range:(RangeStart: $1A00; RangeEnd: $1A1F); Name: 'Buginese'),
    (Range:(RangeStart: $1A20; RangeEnd: $1AAF); Name: 'Tai Tham'),
    (Range:(RangeStart: $1AB0; RangeEnd: $1AFF); Name: 'Combining Diacritical Marks Extended'),
    (Range:(RangeStart: $1B00; RangeEnd: $1B7F); Name: 'Balinese'),
    (Range:(RangeStart: $1B80; RangeEnd: $1BBF); Name: 'Sundanese'),
    (Range:(RangeStart: $1BC0; RangeEnd: $1BFF); Name: 'Batak'),
    (Range:(RangeStart: $1C00; RangeEnd: $1C4F); Name: 'Lepcha'),
    (Range:(RangeStart: $1C50; RangeEnd: $1C7F); Name: 'Ol Chiki'),
    (Range:(RangeStart: $1C80; RangeEnd: $1C8F); Name: 'Cyrillic Extended-C'),
    (Range:(RangeStart: $1C90; RangeEnd: $1CBF); Name: 'Georgian Extended'),
    (Range:(RangeStart: $1CC0; RangeEnd: $1CCF); Name: 'Sundanese Supplement'),
    (Range:(RangeStart: $1CD0; RangeEnd: $1CFF); Name: 'Vedic Extensions'),
    (Range:(RangeStart: $1D00; RangeEnd: $1D7F); Name: 'Phonetic Extensions'),
    (Range:(RangeStart: $1D80; RangeEnd: $1DBF); Name: 'Phonetic Extensions Supplement'),
    (Range:(RangeStart: $1DC0; RangeEnd: $1DFF); Name: 'Combining Diacritical Marks Supplement'),
    (Range:(RangeStart: $1E00; RangeEnd: $1EFF); Name: 'Latin Extended Additional'),
    (Range:(RangeStart: $1F00; RangeEnd: $1FFF); Name: 'Greek Extended'),
    (Range:(RangeStart: $2000; RangeEnd: $206F); Name: 'General Punctuation'),
    (Range:(RangeStart: $2070; RangeEnd: $209F); Name: 'Superscripts and Subscripts'),
    (Range:(RangeStart: $20A0; RangeEnd: $20CF); Name: 'Currency Symbols'),
    (Range:(RangeStart: $20D0; RangeEnd: $20FF); Name: 'Combining Diacritical Marks for Symbols'),
    (Range:(RangeStart: $2100; RangeEnd: $214F); Name: 'Letterlike Symbols'),
    (Range:(RangeStart: $2150; RangeEnd: $218F); Name: 'Number Forms'),
    (Range:(RangeStart: $2190; RangeEnd: $21FF); Name: 'Arrows'),
    (Range:(RangeStart: $2200; RangeEnd: $22FF); Name: 'Mathematical Operators'),
    (Range:(RangeStart: $2300; RangeEnd: $23FF); Name: 'Miscellaneous Technical'),
    (Range:(RangeStart: $2400; RangeEnd: $243F); Name: 'Control Pictures'),
    (Range:(RangeStart: $2440; RangeEnd: $245F); Name: 'Optical Character Recognition'),
    (Range:(RangeStart: $2460; RangeEnd: $24FF); Name: 'Enclosed Alphanumerics'),
    (Range:(RangeStart: $2500; RangeEnd: $257F); Name: 'Box Drawing'),
    (Range:(RangeStart: $2580; RangeEnd: $259F); Name: 'Block Elements'),
    (Range:(RangeStart: $25A0; RangeEnd: $25FF); Name: 'Geometric Shapes'),
    (Range:(RangeStart: $2600; RangeEnd: $26FF); Name: 'Miscellaneous Symbols'),
    (Range:(RangeStart: $2700; RangeEnd: $27BF); Name: 'Dingbats'),
    (Range:(RangeStart: $27C0; RangeEnd: $27EF); Name: 'Miscellaneous Mathematical Symbols-A'),
    (Range:(RangeStart: $27F0; RangeEnd: $27FF); Name: 'Supplemental Arrows-A'),
    (Range:(RangeStart: $2800; RangeEnd: $28FF); Name: 'Braille Patterns'),
    (Range:(RangeStart: $2900; RangeEnd: $297F); Name: 'Supplemental Arrows-B'),
    (Range:(RangeStart: $2980; RangeEnd: $29FF); Name: 'Miscellaneous Mathematical Symbols-B'),
    (Range:(RangeStart: $2A00; RangeEnd: $2AFF); Name: 'Supplemental Mathematical Operators'),
    (Range:(RangeStart: $2B00; RangeEnd: $2BFF); Name: 'Miscellaneous Symbols and Arrows'),
    (Range:(RangeStart: $2C00; RangeEnd: $2C5F); Name: 'Glagolitic'),
    (Range:(RangeStart: $2C60; RangeEnd: $2C7F); Name: 'Latin Extended-C'),
    (Range:(RangeStart: $2C80; RangeEnd: $2CFF); Name: 'Coptic'),
    (Range:(RangeStart: $2D00; RangeEnd: $2D2F); Name: 'Georgian Supplement'),
    (Range:(RangeStart: $2D30; RangeEnd: $2D7F); Name: 'Tifinagh'),
    (Range:(RangeStart: $2D80; RangeEnd: $2DDF); Name: 'Ethiopic Extended'),
    (Range:(RangeStart: $2DE0; RangeEnd: $2DFF); Name: 'Cyrillic Extended-A'),
    (Range:(RangeStart: $2E00; RangeEnd: $2E7F); Name: 'Supplemental Punctuation'),
    (Range:(RangeStart: $2E80; RangeEnd: $2EFF); Name: 'CJK Radicals Supplement'),
    (Range:(RangeStart: $2F00; RangeEnd: $2FDF); Name: 'Kangxi Radicals'),
    (Range:(RangeStart: $2FF0; RangeEnd: $2FFF); Name: 'Ideographic Description Characters'),
    (Range:(RangeStart: $3000; RangeEnd: $303F); Name: 'CJK Symbols and Punctuation'),
    (Range:(RangeStart: $3040; RangeEnd: $309F); Name: 'Hiragana'),
    (Range:(RangeStart: $30A0; RangeEnd: $30FF); Name: 'Katakana'),
    (Range:(RangeStart: $3100; RangeEnd: $312F); Name: 'Bopomofo'),
    (Range:(RangeStart: $3130; RangeEnd: $318F); Name: 'Hangul Compatibility Jamo'),
    (Range:(RangeStart: $3190; RangeEnd: $319F); Name: 'Kanbun'),
    (Range:(RangeStart: $31A0; RangeEnd: $31BF); Name: 'Bopomofo Extended'),
    (Range:(RangeStart: $31C0; RangeEnd: $31EF); Name: 'CJK Strokes'),
    (Range:(RangeStart: $31F0; RangeEnd: $31FF); Name: 'Katakana Phonetic Extensions'),
    (Range:(RangeStart: $3200; RangeEnd: $32FF); Name: 'Enclosed CJK Letters and Months'),
    (Range:(RangeStart: $3300; RangeEnd: $33FF); Name: 'CJK Compatibility'),
    (Range:(RangeStart: $3400; RangeEnd: $4DBF); Name: 'CJK Unified Ideographs Extension A'),
    (Range:(RangeStart: $4DC0; RangeEnd: $4DFF); Name: 'Yijing Hexagram Symbols'),
    (Range:(RangeStart: $4E00; RangeEnd: $9FFC); Name: 'CJK Unified Ideographs'),
    (Range:(RangeStart: $A000; RangeEnd: $A48F); Name: 'Yi Syllables'),
    (Range:(RangeStart: $A490; RangeEnd: $A4CF); Name: 'Yi Radicals'),
    (Range:(RangeStart: $A4D0; RangeEnd: $A4FF); Name: 'Lisu'),
    (Range:(RangeStart: $A500; RangeEnd: $A63F); Name: 'Vai'),
    (Range:(RangeStart: $A640; RangeEnd: $A69F); Name: 'Cyrillic Extended-B'),
    (Range:(RangeStart: $A6A0; RangeEnd: $A6FF); Name: 'Bamum'),
    (Range:(RangeStart: $A700; RangeEnd: $A71F); Name: 'Modifier Tone Letters'),
    (Range:(RangeStart: $A720; RangeEnd: $A7FF); Name: 'Latin Extended-D'),
    (Range:(RangeStart: $A800; RangeEnd: $A82F); Name: 'Syloti Nagri'),
    (Range:(RangeStart: $A830; RangeEnd: $A83F); Name: 'Common Indic Number Forms'),
    (Range:(RangeStart: $A840; RangeEnd: $A87F); Name: 'Phags-pa'),
    (Range:(RangeStart: $A880; RangeEnd: $A8DF); Name: 'Saurashtra'),
    (Range:(RangeStart: $A8E0; RangeEnd: $A8FF); Name: 'Devanagari Extended'),
    (Range:(RangeStart: $A900; RangeEnd: $A92F); Name: 'Kayah Li'),
    (Range:(RangeStart: $A930; RangeEnd: $A95F); Name: 'Rejang'),
    (Range:(RangeStart: $A960; RangeEnd: $A97F); Name: 'Hangul Jamo Extended-A'),
    (Range:(RangeStart: $A980; RangeEnd: $A9DF); Name: 'Javanese'),
    (Range:(RangeStart: $A9E0; RangeEnd: $A9FF); Name: 'Myanmar Extended-B'),
    (Range:(RangeStart: $AA00; RangeEnd: $AA5F); Name: 'Cham'),
    (Range:(RangeStart: $AA60; RangeEnd: $AA7F); Name: 'Myanmar Extended-A'),
    (Range:(RangeStart: $AA80; RangeEnd: $AADF); Name: 'Tai Viet'),
    (Range:(RangeStart: $AAE0; RangeEnd: $AAFF); Name: 'Meetei Mayek Extensions'),
    (Range:(RangeStart: $AB00; RangeEnd: $AB2F); Name: 'Ethiopic Extended-A'),
    (Range:(RangeStart: $AB30; RangeEnd: $AB6F); Name: 'Latin Extended-E'),
    (Range:(RangeStart: $AB70; RangeEnd: $ABBF); Name: 'Cherokee Supplement'),
    (Range:(RangeStart: $ABC0; RangeEnd: $ABFF); Name: 'Meetei Mayek'),
    (Range:(RangeStart: $AC00; RangeEnd: $D7AF); Name: 'Hangul Syllables'),
    (Range:(RangeStart: $D7B0; RangeEnd: $D7FF); Name: 'Hangul Jamo Extended-B'),
    (Range:(RangeStart: $D800; RangeEnd: $DB7F); Name: 'High Surrogates'),
    (Range:(RangeStart: $DB80; RangeEnd: $DBFF); Name: 'High Private Use Surrogates'),
    (Range:(RangeStart: $DC00; RangeEnd: $DFFF); Name: 'Low Surrogates'),
    (Range:(RangeStart: $E000; RangeEnd: $F8FF); Name: 'Private Use Area'),
    (Range:(RangeStart: $F900; RangeEnd: $FAFF); Name: 'CJK Compatibility Ideographs'),
    (Range:(RangeStart: $FB00; RangeEnd: $FB4F); Name: 'Alphabetic Presentation Forms'),
    (Range:(RangeStart: $FB50; RangeEnd: $FDFF); Name: 'Arabic Presentation Forms-A'),
    (Range:(RangeStart: $FE00; RangeEnd: $FE0F); Name: 'Variation Selectors'),
    (Range:(RangeStart: $FE10; RangeEnd: $FE1F); Name: 'Vertical Forms'),
    (Range:(RangeStart: $FE20; RangeEnd: $FE2F); Name: 'Combining Half Marks'),
    (Range:(RangeStart: $FE30; RangeEnd: $FE4F); Name: 'CJK Compatibility Forms'),
    (Range:(RangeStart: $FE50; RangeEnd: $FE6F); Name: 'Small Form Variants'),
    (Range:(RangeStart: $FE70; RangeEnd: $FEFF); Name: 'Arabic Presentation Forms-B'),
    (Range:(RangeStart: $FF00; RangeEnd: $FFEF); Name: 'Halfwidth and Fullwidth Forms'),
    (Range:(RangeStart: $FFF0; RangeEnd: $FFFF); Name: 'Specials'),
    (Range:(RangeStart: $10000; RangeEnd: $1007F); Name: 'Linear B Syllabary'),
    (Range:(RangeStart: $10080; RangeEnd: $100FF); Name: 'Linear B Ideograms'),
    (Range:(RangeStart: $10100; RangeEnd: $1013F); Name: 'Aegean Numbers'),
    (Range:(RangeStart: $10140; RangeEnd: $1018F); Name: 'Ancient Greek Numbers'),
    (Range:(RangeStart: $10190; RangeEnd: $101CF); Name: 'Ancient Symbols'),
    (Range:(RangeStart: $101D0; RangeEnd: $101FF); Name: 'Phaistos Disc'),
    (Range:(RangeStart: $10280; RangeEnd: $1029F); Name: 'Lycian'),
    (Range:(RangeStart: $102A0; RangeEnd: $102DF); Name: 'Carian'),
    (Range:(RangeStart: $102E0; RangeEnd: $102FF); Name: 'Coptic Epact Numbers'),
    (Range:(RangeStart: $10300; RangeEnd: $1032F); Name: 'Old Italic'),
    (Range:(RangeStart: $10330; RangeEnd: $1034F); Name: 'Gothic'),
    (Range:(RangeStart: $10350; RangeEnd: $1037F); Name: 'Old Permic'),
    (Range:(RangeStart: $10380; RangeEnd: $1039F); Name: 'Ugaritic'),
    (Range:(RangeStart: $103A0; RangeEnd: $103DF); Name: 'Old Persian'),
    (Range:(RangeStart: $10400; RangeEnd: $1044F); Name: 'Deseret'),
    (Range:(RangeStart: $10450; RangeEnd: $1047F); Name: 'Shavian'),
    (Range:(RangeStart: $10480; RangeEnd: $104AF); Name: 'Osmanya'),
    (Range:(RangeStart: $104B0; RangeEnd: $104FF); Name: 'Osage'),
    (Range:(RangeStart: $10500; RangeEnd: $1052F); Name: 'Elbasan'),
    (Range:(RangeStart: $10530; RangeEnd: $1056F); Name: 'Caucasian Albanian'),
    (Range:(RangeStart: $10600; RangeEnd: $1077F); Name: 'Linear A'),
    (Range:(RangeStart: $10800; RangeEnd: $1083F); Name: 'Cypriot Syllabary'),
    (Range:(RangeStart: $10840; RangeEnd: $1085F); Name: 'Imperial Aramaic'),
    (Range:(RangeStart: $10860; RangeEnd: $1087F); Name: 'Palmyrene'),
    (Range:(RangeStart: $10880; RangeEnd: $108AF); Name: 'Nabataean'),
    (Range:(RangeStart: $108E0; RangeEnd: $108FF); Name: 'Hatran'),
    (Range:(RangeStart: $10900; RangeEnd: $1091F); Name: 'Phoenician'),
    (Range:(RangeStart: $10920; RangeEnd: $1093F); Name: 'Lydian'),
    (Range:(RangeStart: $10980; RangeEnd: $1099F); Name: 'Meroitic Hieroglyphs'),
    (Range:(RangeStart: $109A0; RangeEnd: $109FF); Name: 'Meroitic Cursive'),
    (Range:(RangeStart: $10A00; RangeEnd: $10A5F); Name: 'Kharoshthi'),
    (Range:(RangeStart: $10A60; RangeEnd: $10A7F); Name: 'Old South Arabian'),
    (Range:(RangeStart: $10A80; RangeEnd: $10A9F); Name: 'Old North Arabian'),
    (Range:(RangeStart: $10AC0; RangeEnd: $10AFF); Name: 'Manichaean'),
    (Range:(RangeStart: $10B00; RangeEnd: $10B3F); Name: 'Avestan'),
    (Range:(RangeStart: $10B40; RangeEnd: $10B5F); Name: 'Inscriptional Parthian'),
    (Range:(RangeStart: $10B60; RangeEnd: $10B7F); Name: 'Inscriptional Pahlavi'),
    (Range:(RangeStart: $10B80; RangeEnd: $10BAF); Name: 'Psalter Pahlavi'),
    (Range:(RangeStart: $10C00; RangeEnd: $10C4F); Name: 'Old Turkic'),
    (Range:(RangeStart: $10C80; RangeEnd: $10CFF); Name: 'Old Hungarian'),
    (Range:(RangeStart: $10D00; RangeEnd: $10D3F); Name: 'Hanifi Rohingya'),
    (Range:(RangeStart: $10E60; RangeEnd: $10E7F); Name: 'Rumi Numeral Symbols'),
    (Range:(RangeStart: $10E80; RangeEnd: $10EBF); Name: 'Yezidi'),
    (Range:(RangeStart: $10F00; RangeEnd: $10F2F); Name: 'Old Sogdian'),
    (Range:(RangeStart: $10F30; RangeEnd: $10FAF); Name: 'Sogdian'),
    (Range:(RangeStart: $10FB0; RangeEnd: $10FDF); Name: 'Chorasmian'),
    (Range:(RangeStart: $10FE0; RangeEnd: $10FFF); Name: 'Elymaic'),
    (Range:(RangeStart: $11000; RangeEnd: $1107F); Name: 'Brahmi'),
    (Range:(RangeStart: $11080; RangeEnd: $110CF); Name: 'Kaithi'),
    (Range:(RangeStart: $110D0; RangeEnd: $110FF); Name: 'Sora Sompeng'),
    (Range:(RangeStart: $11100; RangeEnd: $1114F); Name: 'Chakma'),
    (Range:(RangeStart: $11150; RangeEnd: $1117F); Name: 'Mahajani'),
    (Range:(RangeStart: $11180; RangeEnd: $111DF); Name: 'Sharada'),
    (Range:(RangeStart: $111E0; RangeEnd: $111FF); Name: 'Sinhala Archaic Numbers'),
    (Range:(RangeStart: $11200; RangeEnd: $1124F); Name: 'Khojki'),
    (Range:(RangeStart: $11280; RangeEnd: $112AF); Name: 'Multani'),
    (Range:(RangeStart: $112B0; RangeEnd: $112FF); Name: 'Khudawadi'),
    (Range:(RangeStart: $11300; RangeEnd: $1137F); Name: 'Grantha'),
    (Range:(RangeStart: $11400; RangeEnd: $1147F); Name: 'Newa'),
    (Range:(RangeStart: $11480; RangeEnd: $114DF); Name: 'Tirhuta'),
    (Range:(RangeStart: $11580; RangeEnd: $115FF); Name: 'Siddam'),
    (Range:(RangeStart: $11600; RangeEnd: $1165F); Name: 'Modi'),
    (Range:(RangeStart: $11660; RangeEnd: $1167F); Name: 'Mongolian Supplement'),
    (Range:(RangeStart: $11680; RangeEnd: $116CF); Name: 'Takri'),
    (Range:(RangeStart: $11700; RangeEnd: $1173F); Name: 'Ahom'),
    (Range:(RangeStart: $11800; RangeEnd: $1184F); Name: 'Dogra'),
    (Range:(RangeStart: $118A0; RangeEnd: $118FF); Name: 'Warang Citi'),
    (Range:(RangeStart: $11900; RangeEnd: $1195F); Name: 'Dives Akuru'),
    (Range:(RangeStart: $119A0; RangeEnd: $119FF); Name: 'Nandinagari'),
    (Range:(RangeStart: $11A00; RangeEnd: $11A4F); Name: 'Zanabazar Square'),
    (Range:(RangeStart: $11A50; RangeEnd: $11AAF); Name: 'Soyombo'),
    (Range:(RangeStart: $11AC0; RangeEnd: $11AFF); Name: 'Pau Cin Hau'),
    (Range:(RangeStart: $11C00; RangeEnd: $11C6F); Name: 'Bhaiksuki'),
    (Range:(RangeStart: $11C70; RangeEnd: $11CBF); Name: 'Marchen'),
    (Range:(RangeStart: $11D00; RangeEnd: $11D5F); Name: 'Masaram Gondi'),
    (Range:(RangeStart: $11D60; RangeEnd: $11DAF); Name: 'Gunjala Gondi'),
    (Range:(RangeStart: $11EE0; RangeEnd: $11EFF); Name: 'Makasar'),
    (Range:(RangeStart: $11FB0; RangeEnd: $11FBF); Name: 'Lisu Supplement'),
    (Range:(RangeStart: $11FC0; RangeEnd: $11FFF); Name: 'Tamil Supplement'),
    (Range:(RangeStart: $12000; RangeEnd: $123FF); Name: 'Cuneiform'),
    (Range:(RangeStart: $12400; RangeEnd: $1247F); Name: 'Cuneiform Numbers and Punctuation'),
    (Range:(RangeStart: $12480; RangeEnd: $1254F); Name: 'Early Dynastic Cuneiform'),
    (Range:(RangeStart: $13000; RangeEnd: $1342F); Name: 'Egyptian Hieroglyphs'),
    (Range:(RangeStart: $13430; RangeEnd: $1343F); Name: 'Egyptian Hieroglyph Format Controls'),
    (Range:(RangeStart: $14400; RangeEnd: $1467F); Name: 'Anatolian Hieroglyphs'),
    (Range:(RangeStart: $16800; RangeEnd: $16A3F); Name: 'Bamum Supplement'),
    (Range:(RangeStart: $16A40; RangeEnd: $16A6F); Name: 'Mro'),
    (Range:(RangeStart: $16AD0; RangeEnd: $16AFF); Name: 'Bassa Vah'),
    (Range:(RangeStart: $16B00; RangeEnd: $16B8F); Name: 'Pahawh Hmong'),
    (Range:(RangeStart: $16E40; RangeEnd: $16E9F); Name: 'Medefaidrin'),
    (Range:(RangeStart: $16F00; RangeEnd: $16F9F); Name: 'Miao'),
    (Range:(RangeStart: $16FE0; RangeEnd: $16FFF); Name: 'Ideographic Symbols and Punctuation'),
    (Range:(RangeStart: $17000; RangeEnd: $187F7); Name: 'Tangut'),
    (Range:(RangeStart: $18800; RangeEnd: $18AFF); Name: 'Tangut Components'),
    (Range:(RangeStart: $18B00; RangeEnd: $18CFF); Name: 'Khitan Small Script'),
    (Range:(RangeStart: $18D00; RangeEnd: $18D08); Name: 'Tangut Supplement'),
    (Range:(RangeStart: $1B000; RangeEnd: $1B0FF); Name: 'Kana Supplement'),
    (Range:(RangeStart: $1B100; RangeEnd: $1B12F); Name: 'Kana Extended-A'),
    (Range:(RangeStart: $1B130; RangeEnd: $1B16F); Name: 'Small Kana Extension'),
    (Range:(RangeStart: $1B170; RangeEnd: $1B2FF); Name: 'Nushu'),
    (Range:(RangeStart: $1BC00; RangeEnd: $1BC9F); Name: 'Duployan'),
    (Range:(RangeStart: $1BCA0; RangeEnd: $1BCAF); Name: 'Shorthand Format Controls'),
    (Range:(RangeStart: $1D000; RangeEnd: $1D0FF); Name: 'Byzantine Musical Symbols'),
    (Range:(RangeStart: $1D100; RangeEnd: $1D1FF); Name: 'Musical Symbols'),
    (Range:(RangeStart: $1D200; RangeEnd: $1D24F); Name: 'Ancient Greek Musical Notation'),
    (Range:(RangeStart: $1D2E0; RangeEnd: $1D2FF); Name: 'Mayan Numerals'),
    (Range:(RangeStart: $1D300; RangeEnd: $1D35F); Name: 'Tai Xuan Jing Symbols'),
    (Range:(RangeStart: $1D360; RangeEnd: $1D37F); Name: 'Counting Rod Numerals'),
    (Range:(RangeStart: $1D400; RangeEnd: $1D7FF); Name: 'Mathematical Alphanumeric Symbols'),
    (Range:(RangeStart: $1D800; RangeEnd: $1DAAF); Name: 'Sutton SignWriting'),
    (Range:(RangeStart: $1E000; RangeEnd: $1E02F); Name: 'Glagolitic Supplement'),
    (Range:(RangeStart: $1E100; RangeEnd: $1E14F); Name: 'Nyiakeng Puachue Hmong'),
    (Range:(RangeStart: $1E2C0; RangeEnd: $1E2FF); Name: 'Wancho'),
    (Range:(RangeStart: $1E800; RangeEnd: $1E8DF); Name: 'Mende Kikakui'),
    (Range:(RangeStart: $1EC70; RangeEnd: $1ECBF); Name: 'Indic Siyaq Numbers'),
    (Range:(RangeStart: $1ED00; RangeEnd: $1ED4F); Name: 'Ottoman Siyaq Numbers'),
    (Range:(RangeStart: $1E900; RangeEnd: $1E95F); Name: 'Adlam'),
    (Range:(RangeStart: $1EE00; RangeEnd: $1EEFF); Name: 'Arabic Mathematical Alphabetic Symbols'),
    (Range:(RangeStart: $1F000; RangeEnd: $1F02F); Name: 'Mahjong Tiles'),
    (Range:(RangeStart: $1F030; RangeEnd: $1F09F); Name: 'Domino Tiles'),
    (Range:(RangeStart: $1F0A0; RangeEnd: $1F0FF); Name: 'Playing Cards'),
    (Range:(RangeStart: $1F100; RangeEnd: $1F1FF); Name: 'Enclosed Alphanumeric Supplement'),
    (Range:(RangeStart: $1F200; RangeEnd: $1F2FF); Name: 'Enclosed Ideographic Supplement'),
    (Range:(RangeStart: $1F300; RangeEnd: $1F5FF); Name: 'Miscellaneous Symbols And Pictographs'),
    (Range:(RangeStart: $1F600; RangeEnd: $1F64F); Name: 'Emoticons'),
    (Range:(RangeStart: $1F650; RangeEnd: $1F67F); Name: 'Ornamental Dingbats'),
    (Range:(RangeStart: $1F680; RangeEnd: $1F6FF); Name: 'Transport And Map Symbols'),
    (Range:(RangeStart: $1F700; RangeEnd: $1F77F); Name: 'Alchemical Symbols'),
    (Range:(RangeStart: $1F780; RangeEnd: $1F7FF); Name: 'Geometric Shapes Extended'),
    (Range:(RangeStart: $1F800; RangeEnd: $1F8FF); Name: 'Supplemental Arrows-C'),
    (Range:(RangeStart: $1F900; RangeEnd: $1F9FF); Name: 'Supplemental Symbols And Pictographs'),
    (Range:(RangeStart: $1FA00; RangeEnd: $1FA6F); Name: 'Chess Symbols'),
    (Range:(RangeStart: $1FA70; RangeEnd: $1FAFF); Name: 'Symbols and Pictographs Extended-A'),
    (Range:(RangeStart: $1FB00; RangeEnd: $1FBFF); Name: 'Symbols for Legacy Computing'),
    (Range:(RangeStart: $20000; RangeEnd: $2A6DD); Name: 'CJK Unified Ideographs Extension B'),
    (Range:(RangeStart: $2A700; RangeEnd: $2B734); Name: 'CJK Unified Ideographs Extension C'),
    (Range:(RangeStart: $2B740; RangeEnd: $2B81D); Name: 'CJK Unified Ideographs Extension D'),
    (Range:(RangeStart: $2B820; RangeEnd: $2CEA1); Name: 'CJK Unified Ideographs Extension E'),
    (Range:(RangeStart: $2CEB0; RangeEnd: $2EBE0); Name: 'CJK Unified Ideographs Extension F'),
    (Range:(RangeStart: $2F800; RangeEnd: $2FA1F); Name: 'CJK Compatibility Ideographs Supplement'),
    (Range:(RangeStart: $30000; RangeEnd: $3134A); Name: 'CJK Unified Ideographs Extension G'),
    (Range:(RangeStart: $E0000; RangeEnd: $E007F); Name: 'Tags'),
    (Range:(RangeStart: $E0100; RangeEnd: $E01EF); Name: 'Variation Selectors Supplement'),
    (Range:(RangeStart: $F0000; RangeEnd: $FFFFF); Name: 'Supplementary Private Use Area-A'),
    (Range:(RangeStart: $100000; RangeEnd: $10FFFF); Name: 'Supplementary Private Use Area-B'));

class function PascalTypeUnicode.GetBlock(ACodePoint: TPascalTypeCodePoint): TUnicodeBlock;
var
  Lo, Hi: TUnicodeBlock;
begin
  // Binary search
  Lo := Succ(Low(TUnicodeBlock)); // First entry is the "no-block"
  Hi := High(TUnicodeBlock);
  while (Lo <= Hi) do
  begin
    Result := TUnicodeBlock((Ord(Lo)+Ord(Hi)) div 2);
    if (ACodePoint > UnicodeBlockData[Result].Range.RangeEnd) then
      Lo := Succ(Result)
    else
    if (ACodePoint < UnicodeBlockData[Result].Range.RangeStart) then
      Hi := Result
    else
      Exit;
  end;
  // Not found
  Result := Low(TUnicodeBlock);
end;

class function PascalTypeUnicode.GetBlockName(AScript: TUnicodeBlock): string;
begin
  Result := UnicodeBlockData[AScript].Name;
end;


//------------------------------------------------------------------------------
//
//              Script
//
//------------------------------------------------------------------------------
var
  Scripts: TUnicodeTrieEx<TUnicodeScript>;

procedure LoadScripts;
var
  ResourceStream: TStream;
  Stream: TStream;
  Reader: TBinaryReader;
  Size: Integer;
  Script: TUnicodeScript;
  RangeStart: TPascalTypeCodePoint;
  RangeStop: TPascalTypeCodePoint;
  i: Integer;
  CodePoint: TPascalTypeCodePoint;
begin
  if Scripts.Loaded then
    exit;
  Scripts.Loaded := True;

  ResourceStream := TResourceStream.Create(HInstance, 'SCRIPTS', ResourceType);

{$if defined(UNICODE_RAW_DATA)}
  Stream := ResourceStream;
{$elseif defined(UNICODE_ZLIB_DATA)}
  try

    Stream := TDecompressionStream.Create(ResourceStream, 15, True);

  except
    ResourceStream.Free;
    raise;
  end;
{$ifend}

  Reader := TBinaryReader.Create(Stream, nil, True);
  try
    RangeStart := Default(TPascalTypeCodePoint);
    RangeStop := Default(TPascalTypeCodePoint);

    Assert(SizeOf(TUnicodeScript) = 1);

    while Stream.Position < Stream.Size do
    begin
      // 1) Determine which script  is stored here
      Script := TUnicodeScript(Reader.ReadByte);

      // 2) Determine how many ranges are assigned to this script
      Size := Reader.ReadByte;
      if (Size = 0) then
        continue;

      for i := 0 to Size - 1 do
      begin
        // 3) Read start and stop code of each range
        Stream.ReadBuffer(RangeStart, 3);
        Stream.ReadBuffer(RangeStop, 3);
        Assert(RangeStart < $1000000);
        Assert(RangeStop < $1000000);

        // 4) Put this script in every of the code points just loaded
        for CodePoint := RangeStart to RangeStop do
          Scripts[CodePoint] := Script;
      end;
    end;
    // Assert(Stream.Position = Stream.Size);
  finally
    Reader.Free;
  end;
end;

class function PascalTypeUnicode.GetScript(ACodePoint: TPascalTypeCodePoint): TUnicodeScript;
begin
  Assert(ACodePoint < $1000000);

  if (not Scripts.Loaded) then
    LoadScripts;

  Result := Scripts[ACodePoint];
end;

const
  // Mapping from TUnicodeScript to Iso15924 script properties
  //
  // Generated with the following RegEx:
  //   Input: ^(....)\t(\d*)\t(.*)\t(.*)$
  //   Output: (Number: $2; Code: '$1'; Alias: '$3'), // $4
  // First entry (scZzzz) adjusted manually.
  ISO15924: array[TUnicodeScript] of TISO15924 = (
    (Number: 999; Code: 'Zzzz'; Alias: 'Unknown'), // Code for uncoded script
    (Number: 015; Code: 'Pcun'; Alias: ''), // Proto-Cuneiform
    (Number: 016; Code: 'Pelm'; Alias: ''), // Proto-Elamite
    (Number: 020; Code: 'Xsux'; Alias: 'Cuneiform'), // Cuneiform, Sumero-Akkadian
    (Number: 030; Code: 'Xpeo'; Alias: 'Old_Persian'), // Old Persian
    (Number: 040; Code: 'Ugar'; Alias: 'Ugaritic'), // Ugaritic
    (Number: 050; Code: 'Egyp'; Alias: 'Egyptian_Hieroglyphs'), // Egyptian hieroglyphs
    (Number: 060; Code: 'Egyh'; Alias: ''), // Egyptian hieratic
    (Number: 070; Code: 'Egyd'; Alias: ''), // Egyptian demotic
    (Number: 080; Code: 'Hluw'; Alias: 'Anatolian_Hieroglyphs'), // Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)
    (Number: 085; Code: 'Nkdb'; Alias: ''), // Naxi Dongba (na²¹ɕi³³ to³³ba²¹, Nakhi Tomba)
    (Number: 090; Code: 'Maya'; Alias: ''), // Mayan hieroglyphs
    (Number: 095; Code: 'Sgnw'; Alias: 'SignWriting'), // SignWriting
    (Number: 100; Code: 'Mero'; Alias: 'Meroitic_Hieroglyphs'), // Meroitic Hieroglyphs
    (Number: 101; Code: 'Merc'; Alias: 'Meroitic_Cursive'), // Meroitic Cursive
    (Number: 103; Code: 'Psin'; Alias: ''), // Proto-Sinaitic
    (Number: 105; Code: 'Sarb'; Alias: 'Old_South_Arabian'), // Old South Arabian
    (Number: 106; Code: 'Narb'; Alias: 'Old_North_Arabian'), // Old North Arabian (Ancient North Arabian)
    (Number: 109; Code: 'Chrs'; Alias: 'Chorasmian'), // Chorasmian
    (Number: 115; Code: 'Phnx'; Alias: 'Phoenician'), // Phoenician
    (Number: 116; Code: 'Lydi'; Alias: 'Lydian'), // Lydian
    (Number: 120; Code: 'Tfng'; Alias: 'Tifinagh'), // Tifinagh (Berber)
    (Number: 123; Code: 'Samr'; Alias: 'Samaritan'), // Samaritan
    (Number: 124; Code: 'Armi'; Alias: 'Imperial_Aramaic'), // Imperial Aramaic
    (Number: 125; Code: 'Hebr'; Alias: 'Hebrew'), // Hebrew
    (Number: 126; Code: 'Palm'; Alias: 'Palmyrene'), // Palmyrene
    (Number: 127; Code: 'Hatr'; Alias: 'Hatran'), // Hatran
    (Number: 128; Code: 'Elym'; Alias: 'Elymaic'), // Elymaic
    (Number: 130; Code: 'Prti'; Alias: 'Inscriptional_Parthian'), // Inscriptional Parthian
    (Number: 131; Code: 'Phli'; Alias: 'Inscriptional_Pahlavi'), // Inscriptional Pahlavi
    (Number: 132; Code: 'Phlp'; Alias: 'Psalter_Pahlavi'), // Psalter Pahlavi
    (Number: 133; Code: 'Phlv'; Alias: ''), // Book Pahlavi
    (Number: 134; Code: 'Avst'; Alias: 'Avestan'), // Avestan
    (Number: 135; Code: 'Syrc'; Alias: 'Syriac'), // Syriac
    (Number: 136; Code: 'Syrn'; Alias: ''), // Syriac (Eastern variant)
    (Number: 137; Code: 'Syrj'; Alias: ''), // Syriac (Western variant)
    (Number: 138; Code: 'Syre'; Alias: ''), // Syriac (Estrangelo variant)
    (Number: 139; Code: 'Mani'; Alias: 'Manichaean'), // Manichaean
    (Number: 140; Code: 'Mand'; Alias: 'Mandaic'), // Mandaic, Mandaean
    (Number: 141; Code: 'Sogd'; Alias: 'Sogdian'), // Sogdian
    (Number: 142; Code: 'Sogo'; Alias: 'Old_Sogdian'), // Old Sogdian
    (Number: 143; Code: 'Ougr'; Alias: 'Old_Uyghur'), // Old Uyghur
    (Number: 145; Code: 'Mong'; Alias: 'Mongolian'), // Mongolian
    (Number: 159; Code: 'Nbat'; Alias: 'Nabataean'), // Nabataean
    (Number: 160; Code: 'Arab'; Alias: 'Arabic'), // Arabic
    (Number: 161; Code: 'Aran'; Alias: ''), // Arabic (Nastaliq variant)
    (Number: 165; Code: 'Nkoo'; Alias: 'Nko'), // N’Ko
    (Number: 166; Code: 'Adlm'; Alias: 'Adlam'), // Adlam
    (Number: 167; Code: 'Rohg'; Alias: 'Hanifi_Rohingya'), // Hanifi Rohingya
    (Number: 170; Code: 'Thaa'; Alias: 'Thaana'), // Thaana
    (Number: 175; Code: 'Orkh'; Alias: 'Old_Turkic'), // Old Turkic, Orkhon Runic
    (Number: 176; Code: 'Hung'; Alias: 'Old_Hungarian'), // Old Hungarian (Hungarian Runic)
    (Number: 192; Code: 'Yezi'; Alias: 'Yezidi'), // Yezidi
    (Number: 200; Code: 'Grek'; Alias: 'Greek'), // Greek
    (Number: 201; Code: 'Cari'; Alias: 'Carian'), // Carian
    (Number: 202; Code: 'Lyci'; Alias: 'Lycian'), // Lycian
    (Number: 204; Code: 'Copt'; Alias: 'Coptic'), // Coptic
    (Number: 206; Code: 'Goth'; Alias: 'Gothic'), // Gothic
    (Number: 210; Code: 'Ital'; Alias: 'Old_Italic'), // Old Italic (Etruscan, Oscan, etc.)
    (Number: 211; Code: 'Runr'; Alias: 'Runic'), // Runic
    (Number: 212; Code: 'Ogam'; Alias: 'Ogham'), // Ogham
    (Number: 215; Code: 'Latn'; Alias: 'Latin'), // Latin
    (Number: 216; Code: 'Latg'; Alias: ''), // Latin (Gaelic variant)
    (Number: 217; Code: 'Latf'; Alias: ''), // Latin (Fraktur variant)
    (Number: 218; Code: 'Moon'; Alias: ''), // Moon (Moon code, Moon script, Moon type)
    (Number: 219; Code: 'Osge'; Alias: 'Osage'), // Osage
    (Number: 220; Code: 'Cyrl'; Alias: 'Cyrillic'), // Cyrillic
    (Number: 221; Code: 'Cyrs'; Alias: ''), // Cyrillic (Old Church Slavonic variant)
    (Number: 225; Code: 'Glag'; Alias: 'Glagolitic'), // Glagolitic
    (Number: 226; Code: 'Elba'; Alias: 'Elbasan'), // Elbasan
    (Number: 227; Code: 'Perm'; Alias: 'Old_Permic'), // Old Permic
    (Number: 228; Code: 'Vith'; Alias: 'Vithkuqi'), // Vithkuqi
    (Number: 230; Code: 'Armn'; Alias: 'Armenian'), // Armenian
    (Number: 239; Code: 'Aghb'; Alias: 'Caucasian_Albanian'), // Caucasian Albanian
    (Number: 240; Code: 'Geor'; Alias: 'Georgian'), // Georgian (Mkhedruli and Mtavruli)
    (Number: 241; Code: 'Geok'; Alias: 'Georgian'), // Khutsuri (Asomtavruli and Nuskhuri)
    (Number: 250; Code: 'Dsrt'; Alias: 'Deseret'), // Deseret (Mormon)
    (Number: 259; Code: 'Bass'; Alias: 'Bassa_Vah'), // Bassa Vah
    (Number: 260; Code: 'Osma'; Alias: 'Osmanya'), // Osmanya
    (Number: 261; Code: 'Olck'; Alias: 'Ol_Chiki'), // Ol Chiki (Ol Cemet’, Ol, Santali)
    (Number: 262; Code: 'Wara'; Alias: 'Warang_Citi'), // Warang Citi (Varang Kshiti)
    (Number: 263; Code: 'Pauc'; Alias: 'Pau_Cin_Hau'), // Pau Cin Hau
    (Number: 264; Code: 'Mroo'; Alias: 'Mro'), // Mro, Mru
    (Number: 265; Code: 'Medf'; Alias: 'Medefaidrin'), // Medefaidrin (Oberi Okaime, Oberi Ɔkaimɛ)
    (Number: 274; Code: 'Sunu'; Alias: ''), // Sunuwar
    (Number: 275; Code: 'Tnsa'; Alias: 'Tangsa'), // Tangsa
    (Number: 280; Code: 'Visp'; Alias: ''), // Visible Speech
    (Number: 281; Code: 'Shaw'; Alias: 'Shavian'), // Shavian (Shaw)
    (Number: 282; Code: 'Plrd'; Alias: 'Miao'), // Miao (Pollard)
    (Number: 283; Code: 'Wcho'; Alias: 'Wancho'), // Wancho
    (Number: 284; Code: 'Jamo'; Alias: ''), // Jamo (alias for Jamo subset of Hangul)
    (Number: 285; Code: 'Bopo'; Alias: 'Bopomofo'), // Bopomofo
    (Number: 286; Code: 'Hang'; Alias: 'Hangul'), // Hangul (Hangŭl, Hangeul)
    (Number: 287; Code: 'Kore'; Alias: ''), // Korean (alias for Hangul + Han)
    (Number: 288; Code: 'Kits'; Alias: 'Khitan_Small_Script'), // Khitan small script
    (Number: 290; Code: 'Teng'; Alias: ''), // Tengwar
    (Number: 291; Code: 'Cirt'; Alias: ''), // Cirth
    (Number: 292; Code: 'Sara'; Alias: ''), // Sarati
    (Number: 293; Code: 'Piqd'; Alias: ''), // Klingon (KLI pIqaD)
    (Number: 294; Code: 'Toto'; Alias: 'Toto'), // Toto
    (Number: 295; Code: 'Nagm'; Alias: ''), // Nag Mundari
    (Number: 300; Code: 'Brah'; Alias: 'Brahmi'), // Brahmi
    (Number: 302; Code: 'Sidd'; Alias: 'Siddham'), // Siddham, Siddhaṃ, Siddhamātṛkā
    (Number: 303; Code: 'Ranj'; Alias: ''), // Ranjana
    (Number: 305; Code: 'Khar'; Alias: 'Kharoshthi'), // Kharoshthi
    (Number: 310; Code: 'Guru'; Alias: 'Gurmukhi'), // Gurmukhi
    (Number: 311; Code: 'Nand'; Alias: 'Nandinagari'), // Nandinagari
    (Number: 312; Code: 'Gong'; Alias: 'Gunjala_Gondi'), // Gunjala Gondi
    (Number: 313; Code: 'Gonm'; Alias: 'Masaram_Gondi'), // Masaram Gondi
    (Number: 314; Code: 'Mahj'; Alias: 'Mahajani'), // Mahajani
    (Number: 315; Code: 'Deva'; Alias: 'Devanagari'), // Devanagari (Nagari)
    (Number: 316; Code: 'Sylo'; Alias: 'Syloti_Nagri'), // Syloti Nagri
    (Number: 317; Code: 'Kthi'; Alias: 'Kaithi'), // Kaithi
    (Number: 318; Code: 'Sind'; Alias: 'Khudawadi'), // Khudawadi, Sindhi
    (Number: 319; Code: 'Shrd'; Alias: 'Sharada'), // Sharada, Śāradā
    (Number: 320; Code: 'Gujr'; Alias: 'Gujarati'), // Gujarati
    (Number: 321; Code: 'Takr'; Alias: 'Takri'), // Takri, Ṭākrī, Ṭāṅkrī
    (Number: 322; Code: 'Khoj'; Alias: 'Khojki'), // Khojki
    (Number: 323; Code: 'Mult'; Alias: 'Multani'), // Multani
    (Number: 324; Code: 'Modi'; Alias: 'Modi'), // Modi, Moḍī
    (Number: 325; Code: 'Beng'; Alias: 'Bengali'), // Bengali (Bangla)
    (Number: 326; Code: 'Tirh'; Alias: 'Tirhuta'), // Tirhuta
    (Number: 327; Code: 'Orya'; Alias: 'Oriya'), // Oriya (Odia)
    (Number: 328; Code: 'Dogr'; Alias: 'Dogra'), // Dogra
    (Number: 329; Code: 'Soyo'; Alias: 'Soyombo'), // Soyombo
    (Number: 330; Code: 'Tibt'; Alias: 'Tibetan'), // Tibetan
    (Number: 331; Code: 'Phag'; Alias: 'Phags_Pa'), // Phags-pa
    (Number: 332; Code: 'Marc'; Alias: 'Marchen'), // Marchen
    (Number: 333; Code: 'Newa'; Alias: 'Newa'), // Newa, Newar, Newari, Nepāla lipi
    (Number: 334; Code: 'Bhks'; Alias: 'Bhaiksuki'), // Bhaiksuki
    (Number: 335; Code: 'Lepc'; Alias: 'Lepcha'), // Lepcha (Róng)
    (Number: 336; Code: 'Limb'; Alias: 'Limbu'), // Limbu
    (Number: 337; Code: 'Mtei'; Alias: 'Meetei_Mayek'), // Meitei Mayek (Meithei, Meetei)
    (Number: 338; Code: 'Ahom'; Alias: 'Ahom'), // Ahom, Tai Ahom
    (Number: 339; Code: 'Zanb'; Alias: 'Zanabazar_Square'), // Zanabazar Square (Zanabazarin Dörböljin Useg, Xewtee Dörböljin Bicig, Horizontal Square Script)
    (Number: 340; Code: 'Telu'; Alias: 'Telugu'), // Telugu
    (Number: 342; Code: 'Diak'; Alias: 'Dives_Akuru'), // Dives Akuru
    (Number: 343; Code: 'Gran'; Alias: 'Grantha'), // Grantha
    (Number: 344; Code: 'Saur'; Alias: 'Saurashtra'), // Saurashtra
    (Number: 345; Code: 'Knda'; Alias: 'Kannada'), // Kannada
    (Number: 346; Code: 'Taml'; Alias: 'Tamil'), // Tamil
    (Number: 347; Code: 'Mlym'; Alias: 'Malayalam'), // Malayalam
    (Number: 348; Code: 'Sinh'; Alias: 'Sinhala'), // Sinhala
    (Number: 349; Code: 'Cakm'; Alias: 'Chakma'), // Chakma
    (Number: 350; Code: 'Mymr'; Alias: 'Myanmar'), // Myanmar (Burmese)
    (Number: 351; Code: 'Lana'; Alias: 'Tai_Tham'), // Tai Tham (Lanna)
    (Number: 352; Code: 'Thai'; Alias: 'Thai'), // Thai
    (Number: 353; Code: 'Tale'; Alias: 'Tai_Le'), // Tai Le
    (Number: 354; Code: 'Talu'; Alias: 'New_Tai_Lue'), // New Tai Lue
    (Number: 355; Code: 'Khmr'; Alias: 'Khmer'), // Khmer
    (Number: 356; Code: 'Laoo'; Alias: 'Lao'), // Lao
    (Number: 357; Code: 'Kali'; Alias: 'Kayah_Li'), // Kayah Li
    (Number: 358; Code: 'Cham'; Alias: 'Cham'), // Cham
    (Number: 359; Code: 'Tavt'; Alias: 'Tai_Viet'), // Tai Viet
    (Number: 360; Code: 'Bali'; Alias: 'Balinese'), // Balinese
    (Number: 361; Code: 'Java'; Alias: 'Javanese'), // Javanese
    (Number: 362; Code: 'Sund'; Alias: 'Sundanese'), // Sundanese
    (Number: 363; Code: 'Rjng'; Alias: 'Rejang'), // Rejang (Redjang, Kaganga)
    (Number: 364; Code: 'Leke'; Alias: ''), // Leke
    (Number: 365; Code: 'Batk'; Alias: 'Batak'), // Batak
    (Number: 366; Code: 'Maka'; Alias: 'Makasar'), // Makasar
    (Number: 367; Code: 'Bugi'; Alias: 'Buginese'), // Buginese
    (Number: 368; Code: 'Kawi'; Alias: ''), // Kawi
    (Number: 370; Code: 'Tglg'; Alias: 'Tagalog'), // Tagalog (Baybayin, Alibata)
    (Number: 371; Code: 'Hano'; Alias: 'Hanunoo'), // Hanunoo (Hanunóo)
    (Number: 372; Code: 'Buhd'; Alias: 'Buhid'), // Buhid
    (Number: 373; Code: 'Tagb'; Alias: 'Tagbanwa'), // Tagbanwa
    (Number: 398; Code: 'Sora'; Alias: 'Sora_Sompeng'), // Sora Sompeng
    (Number: 399; Code: 'Lisu'; Alias: 'Lisu'), // Lisu (Fraser)
    (Number: 400; Code: 'Lina'; Alias: 'Linear_A'), // Linear A
    (Number: 401; Code: 'Linb'; Alias: 'Linear_B'), // Linear B
    (Number: 402; Code: 'Cpmn'; Alias: 'Cypro_Minoan'), // Cypro-Minoan
    (Number: 403; Code: 'Cprt'; Alias: 'Cypriot'), // Cypriot syllabary
    (Number: 410; Code: 'Hira'; Alias: 'Hiragana'), // Hiragana
    (Number: 411; Code: 'Kana'; Alias: 'Katakana'), // Katakana
    (Number: 412; Code: 'Hrkt'; Alias: 'Katakana_Or_Hiragana'), // Japanese syllabaries (alias for Hiragana + Katakana)
    (Number: 413; Code: 'Jpan'; Alias: ''), // Japanese (alias for Han + Hiragana + Katakana)
    (Number: 420; Code: 'Nkgb'; Alias: ''), // Naxi Geba (na²¹ɕi³³ gʌ²¹ba²¹, 'Na-'Khi ²Ggŏ-¹baw, Nakhi Geba)
    (Number: 430; Code: 'Ethi'; Alias: 'Ethiopic'), // Ethiopic (Geʻez)
    (Number: 435; Code: 'Bamu'; Alias: 'Bamum'), // Bamum
    (Number: 436; Code: 'Kpel'; Alias: ''), // Kpelle
    (Number: 437; Code: 'Loma'; Alias: ''), // Loma
    (Number: 438; Code: 'Mend'; Alias: 'Mende_Kikakui'), // Mende Kikakui
    (Number: 439; Code: 'Afak'; Alias: ''), // Afaka
    (Number: 440; Code: 'Cans'; Alias: 'Canadian_Aboriginal'), // Unified Canadian Aboriginal Syllabics
    (Number: 445; Code: 'Cher'; Alias: 'Cherokee'), // Cherokee
    (Number: 450; Code: 'Hmng'; Alias: 'Pahawh_Hmong'), // Pahawh Hmong
    (Number: 451; Code: 'Hmnp'; Alias: 'Nyiakeng_Puachue_Hmong'), // Nyiakeng Puachue Hmong
    (Number: 460; Code: 'Yiii'; Alias: 'Yi'), // Yi
    (Number: 470; Code: 'Vaii'; Alias: 'Vai'), // Vai
    (Number: 480; Code: 'Wole'; Alias: ''), // Woleai
    (Number: 499; Code: 'Nshu'; Alias: 'Nushu'), // Nüshu
    (Number: 500; Code: 'Hani'; Alias: 'Han'), // Han (Hanzi, Kanji, Hanja)
    (Number: 501; Code: 'Hans'; Alias: ''), // Han (Simplified variant)
    (Number: 502; Code: 'Hant'; Alias: ''), // Han (Traditional variant)
    (Number: 503; Code: 'Hanb'; Alias: ''), // Han with Bopomofo (alias for Han + Bopomofo)
    (Number: 505; Code: 'Kitl'; Alias: ''), // Khitan large script
    (Number: 510; Code: 'Jurc'; Alias: ''), // Jurchen
    (Number: 520; Code: 'Tang'; Alias: 'Tangut'), // Tangut
    (Number: 530; Code: 'Shui'; Alias: ''), // Shuishu
    (Number: 550; Code: 'Blis'; Alias: ''), // Blissymbols
    (Number: 570; Code: 'Brai'; Alias: 'Braille'), // Braille
    (Number: 610; Code: 'Inds'; Alias: ''), // Indus (Harappan)
    (Number: 620; Code: 'Roro'; Alias: ''), // Rongorongo
    (Number: 755; Code: 'Dupl'; Alias: 'Duployan'), // Duployan shorthand, Duployan stenography
    (Number: 900; Code: 'Qaaa'; Alias: ''), // Reserved for private use (start)
    (Number: 949; Code: 'Qabx'; Alias: ''), // Reserved for private use (end)
    (Number: 993; Code: 'Zsye'; Alias: ''), // Symbols (Emoji variant)
    (Number: 994; Code: 'Zinh'; Alias: 'Inherited'), // Code for inherited script
    (Number: 995; Code: 'Zmth'; Alias: ''), // Mathematical notation
    (Number: 996; Code: 'Zsym'; Alias: ''), // Symbols
    (Number: 997; Code: 'Zxxx'; Alias: ''), // Code for unwritten documents
    (Number: 998; Code: 'Zyyy'; Alias: 'Common')); // Code for undetermined script

class function PascalTypeUnicode.ScriptToISO15924(AScript: TUnicodeScript): TISO15924;
begin
  Result := ISO15924[AScript];
end;

var
  ISO15924Lookup: TDictionary<string, TUnicodeScript> = nil;

class function PascalTypeUnicode.ISO15924ToScript(const ACode: string): TUnicodeScript;
begin
  if (ISO15924Lookup = nil) then
  begin
    ISO15924Lookup := TDictionary<string, TUnicodeScript>.Create;

    for Result := Low(ISO15924) to High(ISO15924) do
      ISO15924Lookup.Add(ISO15924[Result].Code.ToLower, Result);
    ISO15924Lookup.Add('dflt', usZzzz);
  end;

  if (not ISO15924Lookup.TryGetValue(ACode.ToLower, Result)) then
    Result := usZzzz;
end;

class function PascalTypeUnicode.IsLeftToRight(AScript: TUnicodeScript): boolean;
begin
  // TODO : There are other directions besides LTR and RTL
  Result := not IsRightToLeft(AScript);
end;

class function PascalTypeUnicode.IsRightToLeft(AScript: TUnicodeScript): boolean;
begin
  // TODO : Get this data from the UCD
  case AScript of
    usArab,     // Arabic
    usHebr,     // Hebrew
    usSyrc,     // Syriac
    usThaa,     // Thaana
    usCprt,     // Cypriot Syllabary
    usKhar,     // Kharosthi
    usPhnx,     // Phoenician
    usNkoo,     // N'Ko
    usLydi,     // Lydian
    usAvst,     // Avestan
    usArmi,     // Imperial Aramaic
    usPhli,     // Inscriptional Pahlavi
    usPrti,     // Inscriptional Parthian
    usSarb,     // Old South Arabian
    usOrkh,     // Old Turkic, Orkhon Runic
    usSamr,     // Samaritan
    usMand,     // Mandaic, Mandaean
    usMerc,     // Meroitic Cursive
    usMero,     // Meroitic Hieroglyphs

    // Unicode 7.0 (not listed on http://www.microsoft.com/typography/otspec/scripttags.htm)
    usMani,     // Manichaean
    usMend,     // Mende Kikakui
    usNbat,     // Nabataean
    usNarb,     // Old North Arabian
    usPalm,     // Palmyrene
    usPhlp:     // Psalter Pahlavi
      Result := True;
  else
    Result := False;
  end;
end;



//------------------------------------------------------------------------------
//
//              Shaping
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.IsDefaultIgnorable(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  (* From HarfBuzz
   *
   * Default_Ignorable codepoints:
   *
   * Note: While U+115F, U+1160, U+3164 and U+FFA0 are Default_Ignorable,
   * we do NOT want to hide them, as the way Uniscribe has implemented them
   * is with regular spacing glyphs, and that's the way fonts are made to work.
   * As such, we make exceptions for those four.
   * Also ignoring U+1BCA0..1BCA3. https://github.com/harfbuzz/harfbuzz/issues/503
   *
   * Unicode 14.0:
   * $ grep '; Default_Ignorable_Code_Point ' DerivedCoreProperties.txt | sed 's/;.*#/#/'
   * 00AD          # Cf       SOFT HYPHEN
   * 034F          # Mn       COMBINING GRAPHEME JOINER
   * 061C          # Cf       ARABIC LETTER MARK
   * 115F..1160    # Lo   [2] HANGUL CHOSEONG FILLER..HANGUL JUNGSEONG FILLER
   * 17B4..17B5    # Mn   [2] KHMER VOWEL INHERENT AQ..KHMER VOWEL INHERENT AA
   * 180B..180D    # Mn   [3] MONGOLIAN FREE VARIATION SELECTOR ONE..MONGOLIAN FREE VARIATION SELECTOR THREE
   * 180E          # Cf       MONGOLIAN VOWEL SEPARATOR
   * 180F          # Mn       MONGOLIAN FREE VARIATION SELECTOR FOUR
   * 200B..200F    # Cf   [5] ZERO WIDTH SPACE..RIGHT-TO-LEFT MARK
   * 202A..202E    # Cf   [5] LEFT-TO-RIGHT EMBEDDING..RIGHT-TO-LEFT OVERRIDE
   * 2060..2064    # Cf   [5] WORD JOINER..INVISIBLE PLUS
   * 2065          # Cn       <reserved-2065>
   * 2066..206F    # Cf  [10] LEFT-TO-RIGHT ISOLATE..NOMINAL DIGIT SHAPES
   * 3164          # Lo       HANGUL FILLER
   * FE00..FE0F    # Mn  [16] VARIATION SELECTOR-1..VARIATION SELECTOR-16
   * FEFF          # Cf       ZERO WIDTH NO-BREAK SPACE
   * FFA0          # Lo       HALFWIDTH HANGUL FILLER
   * FFF0..FFF8    # Cn   [9] <reserved-FFF0>..<reserved-FFF8>
   * 1BCA0..1BCA3  # Cf   [4] SHORTHAND FORMAT LETTER OVERLAP..SHORTHAND FORMAT UP STEP
   * 1D173..1D17A  # Cf   [8] MUSICAL SYMBOL BEGIN BEAM..MUSICAL SYMBOL END PHRASE
   * E0000         # Cn       <reserved-E0000>
   * E0001         # Cf       LANGUAGE TAG
   * E0002..E001F  # Cn  [30] <reserved-E0002>..<reserved-E001F>
   * E0020..E007F  # Cf  [96] TAG SPACE..CANCEL TAG
   * E0080..E00FF  # Cn [128] <reserved-E0080>..<reserved-E00FF>
   * E0100..E01EF  # Mn [240] VARIATION SELECTOR-17..VARIATION SELECTOR-256
   * E01F0..E0FFF  # Cn [3600] <reserved-E01F0>..<reserved-E0FFF>
   *)

  case (ACodePoint shr 16) and $FF of // Plane

    $00: // BMP
      case (ACodePoint shr 8) and $FF of // Page

        $00: Result := (ACodePoint = $00AD);
        $03: Result := (ACodePoint = $034F);
        $06: Result := (ACodePoint = $061C);
        $17: Result := (ACodePoint >= $17B4) and (ACodePoint <= $17B5);
        $18: Result := (ACodePoint >= $180B) and (ACodePoint <= $180E);
        $20: Result := ((ACodePoint >= $200B) and (ACodePoint <= $200F)) or ((ACodePoint >= $202A) and (ACodePoint <= $202E)) or ((ACodePoint >= $2060) and (ACodePoint <= $206F));
        $FE: Result := (ACodePoint >= $FE00) and (ACodePoint <= $FE0F) or (ACodePoint = $FEFF);
        $FF: Result := (ACodePoint >= $FFF0) and (ACodePoint <= $FFF8);

      else
        Result := False;
      end;

    $01:
      Result := ((ACodePoint >= $1BCA0) and (ACodePoint <= $1BCA3)) or ((ACodePoint >= $1D173) and (ACodePoint <= $1D17A));

    $0E:
      Result := (ACodePoint >= $E0000) and (ACodePoint <= $E0FFF);

  else
    Result := False;
  end;
end;

class function PascalTypeUnicode.GetSpaceType(ACodePoint: TPascalTypeCodePoint): TUnicodeSpaceType;
begin
  // All GC=Zs chars that can use a fallback.
  case ACodePoint of
    $0020: Result := ustSPACE;          // U+0020 SPACE
    $00A0: Result := ustSPACE;	        // U+00A0 NO-BREAK SPACE
    $2000: Result := ustSPACE_EM_2;	// U+2000 EN QUAD
    $2001: Result := ustSPACE_EM;	// U+2001 EM QUAD
    $2002: Result := ustSPACE_EM_2;	// U+2002 EN SPACE
    $2003: Result := ustSPACE_EM;	// U+2003 EM SPACE
    $2004: Result := ustSPACE_EM_3;	// U+2004 THREE-PER-EM SPACE
    $2005: Result := ustSPACE_EM_4;	// U+2005 FOUR-PER-EM SPACE
    $2006: Result := ustSPACE_EM_6;	// U+2006 SIX-PER-EM SPACE
    $2007: Result := ustSPACE_FIGURE;	// U+2007 FIGURE SPACE
    $2008: Result := ustSPACE_PUNCTUATION;// U+2008 PUNCTUATION SPACE
    $2009: Result := ustSPACE_EM_5;	// U+2009 THIN SPACE
    $200A: Result := ustSPACE_EM_16;	// U+200A HAIR SPACE
    $202F: Result := ustSPACE_NARROW;	// U+202F NARROW NO-BREAK SPACE
    $205F: Result := ustSPACE_4_EM_18;	// U+205F MEDIUM MATHEMATICAL SPACE
    $3000: Result := ustSPACE_EM;	// U+3000 IDEOGRAPHIC SPACE
  else
    Result := ustNOT_SPACE;             // U+1680 OGHAM SPACE MARK
  end;
end;


//------------------------------------------------------------------------------
//
//              Canonical Combining Classes
//
//------------------------------------------------------------------------------
var
  CCCs: TUnicodeTrieEx<Byte>;

procedure LoadCCCs;
var
  ResourceStream: TStream;
  Stream: TStream;
  Reader: TBinaryReader;
  Size: Integer;
  CCC: Integer;
  RangeStart: TPascalTypeCodePoint;
  RangeStop: TPascalTypeCodePoint;
  i: Integer;
  CodePoint: TPascalTypeCodePoint;
begin
  if CCCs.Loaded then
    exit;
  CCCs.Loaded := True;

  ResourceStream := TResourceStream.Create(HInstance, 'COMBINING', ResourceType);

{$if defined(UNICODE_RAW_DATA)}
  Stream := ResourceStream;
{$elseif defined(UNICODE_ZLIB_DATA)}
  try

    Stream := TDecompressionStream.Create(ResourceStream, 15, True);

  except
    ResourceStream.Free;
    raise;
  end;
{$ifend}

  Reader := TBinaryReader.Create(Stream, nil, True);
  try
    RangeStart := Default(TPascalTypeCodePoint);
    RangeStop := Default(TPascalTypeCodePoint);

    while Stream.Position < Stream.Size do
    begin
      // 1) Determine which class is stored here
      CCC := Reader.ReadByte;

      // 2) Determine how many ranges are assigned to this class
      Size := Reader.ReadByte;
      if (Size = 0) then
        continue;

      for i := 0 to Size - 1 do
      begin
        // 3) Read start and stop code of each range
        Stream.ReadBuffer(RangeStart, 3);
        Stream.ReadBuffer(RangeStop, 3);
        Assert(RangeStart < $1000000);
        Assert(RangeStop < $1000000);

        // 4) Put this class in every of the code points just loaded
        for CodePoint := RangeStart to RangeStop do
          CCCs[CodePoint] := CCC;
      end;
    end;
    // Assert(Stream.Position = Stream.Size);
  finally
    Reader.Free;
  end;
end;

class function PascalTypeUnicode.CanonicalCombiningClass(ACodePoint: TPascalTypeCodePoint): Cardinal;
begin
  Assert(ACodePoint < $1000000);

  if (not CCCs.Loaded) then
    LoadCCCs;

  Result := CCCs[ACodePoint];
end;


//------------------------------------------------------------------------------
//
//              Normalization
//
//------------------------------------------------------------------------------
class procedure PascalTypeUnicode.Normalize(var ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter);
var
  StartIndex: integer;
  EndIndex: integer;
  Outer, Inner, NextOuter: integer;
  CodePoint: TPascalTypeCodePoint;
begin
  StartIndex := 0;

  // Quick test to determine first codepoint that should be handled (if any)
  // ASCII 0-127 is guaranteed to be unaffected by NFC.
  while (StartIndex < High(ACodePoints)) and (ACodePoints[StartIndex] <= 127) do
    Inc(StartIndex);


  while (StartIndex < High(ACodePoints)) do // No need to test the last char
  begin
    // Find the start of a group. A group follows a codepoint[class=0] and contains one or more codepoint[class<>0].
    if CanonicalCombiningClass(ACodePoints[StartIndex]) = 0 then
    begin
      Inc(StartIndex);
      continue;
    end;

    // Find the end of the group
    EndIndex := StartIndex + 1;
    // OpenType: Do not reorder marks
    while (EndIndex < Length(ACodePoints)) and (CanonicalCombiningClass(ACodePoints[EndIndex]) <> 0) and ((not Assigned(Filter)) or (Filter(ACodePoints[EndIndex]))) do
      Inc(EndIndex);
    // Note: EndIndex is now one past the last in the group to be ordered

    // There's nothing to reorder unless group has 2 or more codepoints in it
    if (EndIndex - StartIndex > 1) then
    begin
      // Bubble sort
      Outer := EndIndex;
      repeat
        NextOuter := 0;
        for Inner := StartIndex+1 to Outer-1 do
          if CanonicalCombiningClass(ACodePoints[Inner-1]) > CanonicalCombiningClass(ACodePoints[Inner]) then
          begin
            // Swap
            CodePoint := ACodePoints[Inner];
            ACodePoints[Inner] := ACodePoints[Inner-1];
            ACodePoints[Inner-1] := CodePoint;
            NextOuter := Inner;
          end;
        Outer := NextOuter;
      until (Outer <= StartIndex+1);
    end;

    StartIndex := EndIndex;
  end;
end;


//------------------------------------------------------------------------------
//
//              Decompose
//
//------------------------------------------------------------------------------
type
  TDecomposition = TPascalTypeCodePoints;
  PDecomposition = ^TDecomposition;

var
  CanonicalDecompositions: TUnicodeTrieEx<TDecomposition>;
  CompatibleDecompositions: TUnicodeTrieEx<TDecomposition>;

procedure LoadDecompositions;
var
  ResourceStream: TStream;
  Stream: TStream;
  Reader: TBinaryReader;
  Size: Integer;
  CodePoint: TPascalTypeCodePoint;
  i, j: Integer;
  Decomposition: PDecomposition;
begin
  if (CanonicalDecompositions.Loaded) then
    exit;
  CanonicalDecompositions.Loaded := True;

  ResourceStream := TResourceStream.Create(HInstance, 'DECOMPOSITION', ResourceType);

{$if defined(UNICODE_RAW_DATA)}
  Stream := ResourceStream;
{$elseif defined(UNICODE_ZLIB_DATA)}
  try

    Stream := TDecompressionStream.Create(ResourceStream, 15, True);

  except
    ResourceStream.Free;
    raise;
  end;
{$ifend}

  Reader := TBinaryReader.Create(Stream, nil, True);
  try
    CodePoint := 0;
    Size := Reader.ReadInteger;

    for i := 0 to Size - 1 do
    begin
      Stream.ReadBuffer(CodePoint, 3);
      Assert(CodePoint < $1000000);

      Size := Reader.ReadByte;
      if Size > 0 then
      begin
        if (TCompatibilityFormattingTag(Reader.ReadByte) = cftCanonical) then
          Decomposition := CanonicalDecompositions.GetPointer(CodePoint, True)
        else
          Decomposition := CompatibleDecompositions.GetPointer(CodePoint, True);

        // Decomposition should never have more than one canonical mapping and
        // one composite mapping.
        Assert(Length(Decomposition^) = 0);

        SetLength(Decomposition^, Size);

        // Note:
        // Max length of a canonical decomposition is 2.
        // Max length of a compatible decomposition is 18.

        for j := 0 to Size - 1 do
        begin
          Stream.ReadBuffer(CodePoint, 3);
          Decomposition^[j] := CodePoint;
        end;
      end;
    end;
    Assert(Stream.Position = Stream.Size);
  finally
    Stream.Free;
  end;
end;

function UnicodeDecompose(const Codes: TPascalTypeCodePoints; Compatible: Boolean; Filter: TCodePointDecomposeFilter): TPascalTypeCodePoints;
var
  OutputSize: integer;

  procedure AddCodePoint(const ACodePoint: TPascalTypeCodePoint);
  begin
    if Length(Result) < (OutputSize+1) then
      SetLength(Result, (OutputSize+1) * 2);
    Result[OutputSize] := ACodePoint;
    Inc(OutputSize);
  end;

  procedure AddCodePoints(const ACodePoints: TPascalTypeCodePoints);
  var
    CodePoint: TPascalTypeCodePoint;
  begin
    if Length(Result) < (OutputSize+Length(ACodePoints)) then
      SetLength(Result, (OutputSize+Length(ACodePoints)) * 2);
    for CodePoint in ACodePoints do
    begin
      Result[OutputSize] := CodePoint;
      Inc(OutputSize);
    end;
  end;

  procedure DecomposeHangul(CodePoint: TPascalTypeCodePoint);
  var
    SIndex, TIndex: Integer;
    LCodePoint, VCodePoint, TCodePoint: TPascalTypeCodePoint;
  begin
    SIndex := CodePoint - Hangul.HangulSBase;

    LCodePoint := Hangul.JamoLBase + (SIndex div Hangul.JamoNCount);
    VCodePoint := Hangul.JamoVBase + ((SIndex mod Hangul.JamoNCount) div Hangul.JamoTCount);
    TIndex := SIndex mod Hangul.JamoTCount;
    if TIndex <> 0 then
      TCodePoint := Hangul.JamoTBase + TIndex
    else
      TCodePoint := 0;

    if (Assigned(Filter)) then
    begin
      if (not Filter(CodePoint, LCodePoint)) or
        (not Filter(CodePoint, VCodePoint)) or
        ((TCodePoint <> 0) and (not Filter(CodePoint, TCodePoint))) then
      begin
        // Filter rejected one of components. Add original.
        AddCodePoint(CodePoint);
        exit;
      end;
    end;

    AddCodePoint(LCodePoint);
    AddCodePoint(VCodePoint);
    if TCodePoint <> 0 then
      AddCodePoint(TCodePoint);
  end;

  function Decompose(ACodePoint: TPascalTypeCodePoint): boolean;
  var
    Decomposition: PDecomposition;
    i: integer;
  begin
    (*
    Compatibility Decomposition
    D65 Compatibility decomposition: The decomposition of a character or character
        sequence that results from recursively applying *both* the compatibility mappings
        *and* the canonical mappings found in the Unicode Character Database, and those
        described in Section 3.12, Conjoining Jamo Behavior, until no characters can be further
        decomposed, and then reordering nonspacing marks according to Section 3.11,
        Normalization Forms.

    Canonical Decomposition
    D68 Canonical decomposition: The decomposition of a character or character sequence
        that results from recursively applying the canonical mappings found in the Unicode
        Character Database and those described in Section 3.12, Conjoining Jamo Behavior,
        until no characters can be further decomposed, and then reordering nonspacing
        marks according to Section 3.11, Normalization Forms.


    Unicode® Standard Annex #44
    5.7.3 Character Decomposition Mapping
    In some instances a canonical mapping or a compatibility mapping may consist of a single
    character. For a canonical mapping, this indicates that the character is a canonical
    equivalent of another single character. For a compatibility mapping, this indicates that
    the character is a compatibility equivalent of another single character.

    A canonical mapping may also consist of a pair of characters, but is never longer than
    two characters. When a canonical mapping consists of a pair of characters, the first
    character may itself be a character with a decomposition mapping, but the second
    character never has a decomposition mapping.

    Compatibility mappings can be much longer than canonical mappings. For historical
    reasons, the longest compatibility mapping is 18 characters long. Compatibility mappings
    are guaranteed to be no longer than 18 characters, although most consist of just a few
    characters.

    *)

    // Compatible decomposition
    Decomposition := nil;
    if (Compatible) then
    begin
      Decomposition := CompatibleDecompositions.GetPointer(ACodePoint);
      if (Decomposition <> nil) and (Length(Decomposition^) = 0) then
        Decomposition := nil;
    end;

    // Canonical decomposition
    if (Decomposition = nil) then
    begin
      Decomposition := CanonicalDecompositions.GetPointer(ACodePoint);
      if (Decomposition <> nil) and (Length(Decomposition^) = 0) then
        Decomposition := nil;
    end;

    // No decomposition; Just add character.
    // There's no need to call the filter since there's nothing we can do
    // about the filter rejecting it.
    if (Decomposition = nil) then
      Exit(False);

    // Since the first character will be recursively decomposed, its final value
    // might be different from the one we have now. Therefore we start by
    // filtering on the second character instead. If that one is rejected, then
    // the whole decomposition must be rejected.
    // Note that, even though compatible decompositions may be longer than two
    // characters, we only filter on the first two.
    if  ((Length(Decomposition^) > 1) and (Assigned(Filter)) and (not Filter(ACodePoint, Decomposition^[1]))) then
      Exit(False);

    // Recurse to decompose first character.
    // If that returns True then the first character has been added and
    // we just need to add the rest.
    // If it returns False then we filter on the first character and add
    // everything if the filter accepts it.
    if (not Decompose(Decomposition^[0])) then
    begin
      // First character could not be re-decomposed.

      // Filter it to determine if it can be added.
      if (Assigned(Filter)) and (not Filter(ACodePoint, Decomposition^[0])) then
        Exit(False);

      AddCodePoint(Decomposition^[0]);
    end;

    // Add remaining decomposed characters.
    for i := 1 to High(Decomposition^) do
      AddCodePoint(Decomposition^[i]);

    Result := True;
  end;

var
  CodePoint: TPascalTypeCodePoint;
begin
  SetLength(Result, Length(Codes));

  OutputSize := 0;

  // Load decomposition data if not already done
  if not CanonicalDecompositions.Loaded then
    LoadDecompositions;

  for CodePoint in Codes do
  begin
    Assert(CodePoint < $1000000);

    // Prefilter on composite only
    if (Assigned(Filter)) and (not Filter(CodePoint, 0)) then
    begin
      AddCodePoint(CodePoint);
      continue;
    end;

    // If the CodePoint is hangul then decomposition is performed algorithmically
    if Hangul.IsHangul(CodePoint) then
    begin
      DecomposeHangul(CodePoint);
      continue;
    end else
    begin
      if (not Decompose(CodePoint)) then
        AddCodePoint(CodePoint);
    end;
  end;

  SetLength(Result, OutputSize);
end;

class function PascalTypeUnicode.Decompose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointDecomposeFilter): TPascalTypeCodePoints;
begin
  Result := UnicodeDecompose(ACodePoints, False, Filter);
end;


//------------------------------------------------------------------------------
//
//              Compose
//
//------------------------------------------------------------------------------
type
  TUnicodeCompositionPair = record
    First: TPascalTypeCodePoint;
    Second: TPascalTypeCodePoint;
  end;

var
  CanonicalCompositionLookup: TDictionary<TUnicodeCompositionPair, TPascalTypeCodePoint>;
  CompatibleCompositionLookup: TDictionary<TUnicodeCompositionPair, TPascalTypeCodePoint>;

procedure LoadCompositions;
var
  ResourceStream: TStream;
  Stream: TStream;
  Reader: TBinaryReader;
  i, Size: Integer;
  Pair: TUnicodeCompositionPair;
  Composite: TPascalTypeCodePoint;
  Canonical: boolean;
begin
  if (CompatibleCompositionLookup <> nil) then
    exit;

  CanonicalCompositionLookup := TDictionary<TUnicodeCompositionPair, TPascalTypeCodePoint>.Create;
  CompatibleCompositionLookup := TDictionary<TUnicodeCompositionPair, TPascalTypeCodePoint>.Create;

  ResourceStream := TResourceStream.Create(HInstance, 'COMPOSITION', ResourceType);

{$if defined(UNICODE_RAW_DATA)}
  Stream := ResourceStream;
{$elseif defined(UNICODE_ZLIB_DATA)}
  try

    Stream := TDecompressionStream.Create(ResourceStream, 15, True);

  except
    ResourceStream.Free;
    raise;
  end;
{$ifend}

  Reader := TBinaryReader.Create(Stream, nil, True);
  try
    Size := Reader.ReadInteger;

    CanonicalCompositionLookup.Capacity := Size;
    CompatibleCompositionLookup.Capacity := Size;

    Composite := Default(TPascalTypeCodePoint);
    Pair := Default(TUnicodeCompositionPair);

    for i := 0 to Size - 1 do
    begin
      Stream.ReadBuffer(Composite, 3);
      Size := Reader.ReadByte;

      if (Size = 2) then
      begin
        Canonical := (TCompatibilityFormattingTag(Reader.ReadByte) = cftCanonical);
        Stream.ReadBuffer(Pair.First, 3);
        Stream.ReadBuffer(Pair.Second, 3);
        if (Canonical) then
          CanonicalCompositionLookup.Add(Pair, Composite)
        else
          CompatibleCompositionLookup.TryAdd(Pair, Composite); // Ignore duplicates
      end else
        Stream.Seek(Size*3+1, soFromCurrent);

    end;
    Assert(Stream.Position = Stream.Size);
  finally
    Reader.Free;
  end;
end;

function UnicodeCompose(const Codes: TPascalTypeCodePoints; Compatible: Boolean; Filter: TCodePointComposeFilter): TPascalTypeCodePoints;
var
  OutputSize: integer;

  procedure AddCodePoint(const ACodePoint: TPascalTypeCodePoint);
  begin
    if Length(Result) < (OutputSize+1) then
      SetLength(Result, (OutputSize+1) * 2);
    Result[OutputSize] := ACodePoint;
    Inc(OutputSize);
  end;

  function ComposeTwoHangul(FirstCodePoint, SecondCodePoint: TPascalTypeCodePoint; var Composite: TPascalTypeCodePoint): boolean;
  var
    LIndex, VIndex, TIndex: integer;
  begin
    // 1. Check to see if two current characters are L and Vovel
    if Hangul.IsJamoL(FirstCodePoint) and Hangul.IsJamoV(SecondCodePoint) then
    begin
      // Make syllable of form LV
      LIndex := FirstCodePoint - Hangul.JamoLBase;
      VIndex := SecondCodePoint - Hangul.JamoVBase;

      Composite := Hangul.HangulSBase + (LIndex * Hangul.JamoVCount + VIndex) * Hangul.JamoTCount;

      Result := True;
    end else
    // 2. Check to see if two current characters are LV and T
    if Hangul.IsHangulLV(FirstCodePoint) and Hangul.IsJamoT(SecondCodePoint) then
    begin
      // Make syllable of form LVT
      TIndex := SecondCodePoint - Hangul.JamoTBase;

      Composite := FirstCodePoint + TPascalTypeCodePoint(TIndex);
      Result := True;
    end else
      Result := False;

    if (Result ) and (Assigned(Filter)) then
      Result := Filter(FirstCodePoint, SecondCodePoint, Composite);
  end;

  function ComposeTwo(FirstCodePoint, SecondCodePoint: TPascalTypeCodePoint; var Composite: TPascalTypeCodePoint): boolean;
  var
    Pair: TUnicodeCompositionPair;
  begin
    Pair.First := FirstCodePoint;
    Pair.Second := SecondCodePoint;

    if ((not Compatible) and (CanonicalCompositionLookup.TryGetValue(Pair, Composite))) or
      ((Compatible) and (CompatibleCompositionLookup.TryGetValue(Pair, Composite))) then
      Exit(True);

    // Give Hangul a go at it
    Result := ComposeTwoHangul(FirstCodePoint, SecondCodePoint, Composite);
  end;

var
  Index: integer;
  StarterIndex: integer;
  CodePoint, Composite: TPascalTypeCodePoint;
  StarterCCC, CCC, TestCCC: Cardinal;
begin
  if (Length(Codes) <= 1) then
    Exit(Codes);

  Index := 0;
  // Quick scan forward for first potential starter; We might not need to do any work at all here...
  // ASCII 0-255 is guaranteed to be unaffected by NFC
  while (Index <= High(Codes)) and (Codes[Index] <= 255) do
    Inc(Index);
  if (Index > High(Codes)) then
    Exit(Codes);

  // Load composition data if not already done
  if (CompatibleCompositionLookup = nil) then
    LoadCompositions;

  SetLength(Result, Length(Codes));

  // If we skipped anything above, unskip the first one since it's probably a starter
  // which we will need for the composition.
  if (Index > 0) then
    Dec(Index);

  OutputSize := Index;

  // Copy the codepoint we skipped above
  if (OutputSize > 0) then
    Move(Codes[0], Result[0], OutputSize*SizeOf(Codes[0]));

  // And now on to the actual composition algorithm...

  StarterIndex := OutputSize;
  CodePoint := Codes[Index];
  AddCodePoint(CodePoint);
  StarterCCC := PascalTypeUnicode.CanonicalCombiningClass(CodePoint);
  Inc(Index);

  (*
  D117
  Canonical Composition Algorithm: Starting from the second character in the coded
  character sequence (of a Canonical Decomposition or Compatibility Decomposition)
  and proceeding sequentially to the final character, perform the following
  steps:

  R1 Seek back (left) in the coded character sequence from the character C to find the
     last Starter L preceding C in the character sequence.

  R2 If there is such an L, and C is not blocked from L, and there exists a Primary Composite
     P which is canonically equivalent to the sequence <L, C>, then replace L by
     P in the sequence and delete C from the sequence.
  *)

  while (Index <= High(Codes)) do
  begin
    CodePoint := Codes[Index];
    CCC := PascalTypeUnicode.CanonicalCombiningClass(CodePoint);

    (*
    D115
    Blocked: Let A and C be two characters in a coded character sequence <A, ... C>. C is
    blocked from A if and only if ccc(A) = 0 and there exists some character B between A
    and C in the coded character sequence, i.e., <A, ... B, ... C>, and either ccc(B) = 0 or
    ccc(B) >= ccc(C).

    In the code below,

      A = Result[StarterIndex]
      B = Result[OutputSize-1]
      C = Codes[Index] = CodePoint

      ccc(A) = StarterCCC
      ccc(B) = TestCCC
      ccc(C) = CCC
    *)
    TestCCC := PascalTypeUnicode.CanonicalCombiningClass(Result[OutputSize-1]);

    if ((StarterCCC = 0) and (StarterIndex < OutputSize-1) and ((TestCCC = 0) or (TestCCC >= CCC))) or
       (not ComposeTwo(Result[StarterIndex], CodePoint, Composite)) then
    begin
      // Blocked, doesn't compose or rejected by filter.
      if (CCC = 0) then
        StarterIndex := OutputSize;

      AddCodePoint(CodePoint);
      Inc(Index);

      continue;
    end;

    // Composes; Modify starter in Result and continue.
    Result[StarterIndex] := Composite;

    StarterCCC := PascalTypeUnicode.CanonicalCombiningClass(Composite);

    Inc(Index);
  end;

  SetLength(Result, OutputSize);
end;

class function PascalTypeUnicode.Compose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointComposeFilter): TPascalTypeCodePoints;
begin
  Result := UnicodeCompose(ACodePoints, False, Filter);
end;


//------------------------------------------------------------------------------
//
//              String conversion
//
//------------------------------------------------------------------------------
class function PascalTypeUnicode.UTF16ToUTF32(const AText: string): TPascalTypeCodePoints;
var
  i, j: integer;
  CodePoint: TPascalTypeCodePoint;
begin
  i := 1;
  j := 0;

  SetLength(Result, Length(AText));

  while i <= Length(AText) do
  begin
    CodePoint := Ord(AText[i]);
    Inc(i);

    if (i <= Length(AText)) and (CodePoint and $FC00 = MinHighSurrogate) and (Word(Ord(AText[i])) and $FC00 = MinLowSurrogate) then
    begin
      CodePoint := (Cardinal(Cardinal(CodePoint and $03FF) shl 10) or Cardinal(Ord(AText[i]) and $03FF)) + $10000;
      inc(i);
    end;

    Result[j] := CodePoint;
    inc(j);
  end;

  SetLength(Result, j);
end;

class function PascalTypeUnicode.UTF32ToUTF16(const ACodePoints: TPascalTypeCodePoints): string;
var
  i: integer;
  CodePoint: TPascalTypeCodePoint;
  Surrogate: Cardinal;
begin
  Result := '';

  i := Length(ACodePoints);
  for CodePoint in ACodePoints do
    if (CodePoint > MaximumUCS2) and (CodePoint <= MaximumUTF16) then
      Inc(i);

  SetLength(Result, i);

  i := 1;
  for CodePoint in ACodePoints do
  begin

    if CodePoint < MinHighSurrogate then
      Result[i] := Char(CodePoint)
    else
    if CodePoint <= MaxLowSurrogate then
      Result[i] := UCS4Replacement
    else
    if CodePoint <= $FFFD then
      Result[i] := Char(CodePoint)
    else
    if CodePoint <= $FFFF then
      Result[i] := UCS4Replacement
    else
    if CodePoint <= MaximumUTF16 then
    begin
      Surrogate := CodePoint - $10000;
      Result[i] := Char((Surrogate shr 10) or MinHighSurrogate);
      Inc(i);
      Result[i] := Char((Surrogate and $03FF) or MinLowSurrogate);
    end else
      Result[i] := UCS4Replacement;

    Inc(i);
  end;
end;


initialization
finalization
  CanonicalCompositionLookup.Free;
  CompatibleCompositionLookup.Free;
  ISO15924Lookup.Free;
end.
