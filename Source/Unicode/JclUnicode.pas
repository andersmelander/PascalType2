{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is JclUnicode.pas.                                                             }
{                                                                                                  }
{ The Initial Developer of the Original Code is Mike Lischke (public att lischke-online dott de).  }
{ Portions created by Mike Lischke are Copyright (C) 1999-2000 Mike Lischke. All Rights Reserved.  }
{                                                                                                  }
{ Contributor(s):                                                                                  }
{   Marcel van Brakel                                                                              }
{   Andreas Hausladen (ahuser)                                                                     }
{   Mike Lischke                                                                                   }
{   Flier Lu (flier)                                                                               }
{   Robert Marquardt (marquardt)                                                                   }
{   Robert Rossmair (rrossmair)                                                                    }
{   Olivier Sannier (obones)                                                                       }
{   Matthias Thoma (mthoma)                                                                        }
{   Petr Vones (pvones)                                                                            }
{   Peter Schraut (http://www.console-dev.de)                                                      }
{   Florent Ouchet (outchy)                                                                        }
{   glchapman                                                                                      }
{   Markus Humm (mhumm)                                                                            }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Various Unicode related routines                                                                 }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date::                                                                         $ }
{ Revision:      $Rev::                                                                          $ }
{ Author:        $Author::                                                                       $ }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Modified for the PascalType project.                                                             }
{ All dependencies on other JEDI units has been eliminated.                                        }
{                                                                                                  }
{**************************************************************************************************}

unit JclUnicode;


// Copyright (c) 1999-2000 Mike Lischke (public att lischke-online dott de)

interface

{-$define UNICODE_RAW_DATA}
{$define UNICODE_ZLIB_DATA}

{$IFDEF UNICODE_RAW_DATA}
  {$UNDEF UNICODE_ZLIB_DATA}
{$ENDIF UNICODE_RAW_DATA}

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.Character,
  System.SysUtils,
  System.Classes;

type
  // UTF conversion schemes (UCS) data types
  UCS4 = Cardinal;
  PUCS4 = ^UCS4;
  UCS2 = Char;
  PUCS2 = PChar;

  TUCS4Array = TArray<UCS4>;

const
  UCS4ReplacementCharacter: UCS4 = $0000FFFD;
  MaximumUCS2: UCS4 = $0000FFFF;
  MaximumUTF16: UCS4 = $0010FFFF;
  MaximumUCS4: UCS4 = $7FFFFFFF;

  SurrogateHighStart = UCS4($D800);
  SurrogateHighEnd = UCS4($DBFF);
  SurrogateLowStart = UCS4($DC00);
  SurrogateLowEnd = UCS4($DFFF);

type
  // various predefined or otherwise useful character property categories
  TCharacterCategory = (
    // normative categories
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
    // bidirectional categories
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
    // self defined categories, they do not appear in the Unicode data file
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

const
  CharacterCategoryToUnicodeCategory: array [TCharacterUnicodeCategory] of TUnicodeCategory =
    ( TUnicodeCategory.ucUppercaseLetter,    // ccLetterUppercase
      TUnicodeCategory.ucLowercaseLetter,    // ccLetterLowercase
      TUnicodeCategory.ucTitlecaseLetter,    // ccLetterTitlecase
      TUnicodeCategory.ucNonSpacingMark,     // ccMarkNonSpacing
      TUnicodeCategory.ucCombiningMark,      // ccMarkSpacingCombining
      TUnicodeCategory.ucEnclosingMark,      // ccMarkEnclosing
      TUnicodeCategory.ucDecimalNumber,      // ccNumberDecimalDigit
      TUnicodeCategory.ucLetterNumber,       // ccNumberLetter
      TUnicodeCategory.ucOtherNumber,        // ccNumberOther
      TUnicodeCategory.ucSpaceSeparator,     // ccSeparatorSpace
      TUnicodeCategory.ucLineSeparator,      // ccSeparatorLine
      TUnicodeCategory.ucParagraphSeparator, // ccSeparatorParagraph
      TUnicodeCategory.ucControl,            // ccOtherControl
      TUnicodeCategory.ucFormat,             // ccOtherFormat
      TUnicodeCategory.ucSurrogate,          // ccOtherSurrogate
      TUnicodeCategory.ucPrivateUse,         // ccOtherPrivate
      TUnicodeCategory.ucUnassigned,         // ccOtherUnassigned
      TUnicodeCategory.ucModifierLetter,     // ccLetterModifier
      TUnicodeCategory.ucOtherLetter,        // ccLetterOther
      TUnicodeCategory.ucConnectPunctuation, // ccPunctuationConnector
      TUnicodeCategory.ucDashPunctuation,    // ccPunctuationDash
      TUnicodeCategory.ucOpenPunctuation,    // ccPunctuationOpen
      TUnicodeCategory.ucClosePunctuation,   // ccPunctuationClose
      TUnicodeCategory.ucInitialPunctuation, // ccPunctuationInitialQuote
      TUnicodeCategory.ucFinalPunctuation,   // ccPunctuationFinalQuote
      TUnicodeCategory.ucOtherPunctuation,   // ccPunctuationOther
      TUnicodeCategory.ucMathSymbol,         // ccSymbolMath
      TUnicodeCategory.ucCurrencySymbol,     // ccSymbolCurrency
      TUnicodeCategory.ucModifierSymbol,     // ccSymbolModifier
      TUnicodeCategory.ucOtherSymbol );      // ccSymbolOther

  UnicodeCategoryToCharacterCategory: array [TUnicodeCategory] of TCharacterCategory =
    ( ccOtherControl,            // ucControl
      ccOtherFormat,             // ucFormat
      ccOtherUnassigned,         // ucUnassigned
      ccOtherPrivate,            // ucPrivateUse
      ccOtherSurrogate,          // ucSurrogate
      ccLetterLowercase,         // ucLowercaseLetter
      ccLetterModifier,          // ucModifierLetter
      ccLetterOther,             // ucOtherLetter
      ccLetterTitlecase,         // ucTitlecaseLetter
      ccLetterUppercase,         // ucUppercaseLetter
      ccMarkSpacingCombining,    // ucCombiningMark
      ccMarkEnclosing,           // ucEnclosingMark
      ccMarkNonSpacing,          // ucNonSpacingMark
      ccNumberDecimalDigit,      // ucDecimalNumber
      ccNumberLetter,            // ucLetterNumber
      ccNumberOther,             // ucOtherNumber
      ccPunctuationConnector,    // ucConnectPunctuation
      ccPunctuationDash,         // ucDashPunctuation
      ccPunctuationClose,        // ucClosePunctuation
      ccPunctuationFinalQuote,   // ucFinalPunctuation
      ccPunctuationInitialQuote, // ucInitialPunctuation
      ccPunctuationOther,        // ucOtherPunctuation
      ccPunctuationOpen,         // ucOpenPunctuation
      ccSymbolCurrency,          // ucCurrencySymbol
      ccSymbolModifier,          // ucModifierSymbol
      ccSymbolMath,              // ucMathSymbol
      ccSymbolOther,             // ucOtherSymbol
      ccSeparatorLine,           // ucLineSeparator
      ccSeparatorParagraph,      // ucParagraphSeparator
      ccSeparatorSpace );        // ucSpaceSeparator

function CharacterCategoriesToUnicodeCategory(const Categories: TCharacterCategories): TUnicodeCategory;
function UnicodeCategoryToCharacterCategories(Category: TUnicodeCategory): TCharacterCategories;

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
  TCompatibilityFormattingTags = set of TCompatibilityFormattingTag;

  // used to hold information about the start and end
  // position of a unicodeblock.
  TUnicodeBlockRange = record
    RangeStart,
    RangeEnd: Cardinal;
  end;

  // An Unicode block usually corresponds to a particular language script but
  // can also represent special characters, musical symbols and the like.
  // https://www.unicode.org/charts/
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

  TUnicodeBlockData = record
    Range: TUnicodeBlockRange;
    Name: string;
  end;
  PUnicodeBlockData = ^TUnicodeBlockData;

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

function CanonicalCombiningClass(Code: Cardinal): Cardinal;

type
  // result type for number retrieval functions
  TUcNumber = record
    Numerator,
    Denominator: Integer;
  end;

type
  TCodePointFilter = reference to function(CodePoint: UCS4): boolean;

function UnicodeCompose(const Codes: TUCS4Array; Compatible: Boolean = False; Filter: TCodePointFilter = nil): TUCS4Array; 
function UnicodeDecompose(const Codes: TUCS4Array; Compatible: Boolean = False; Filter: TCodePointFilter = nil): TUCS4Array;
function GetUnicodeCategory(Code: UCS4): TCharacterCategories;

// Low level character routines
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeNumberLookup(Code: UCS4; var Number: TUcNumber): Boolean;
function UnicodeCaseFold(Code: UCS4): TUCS4Array;
function UnicodeToTitle(Code: UCS4): TUCS4Array;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeToUpper(Code: UCS4): TUCS4Array;
function UnicodeToLower(Code: UCS4): TUCS4Array;

// Character test routines
function UnicodeIsAlpha(C: UCS4): Boolean;
function UnicodeIsDigit(C: UCS4): Boolean;
function UnicodeIsAlphaNum(C: UCS4): Boolean;
function UnicodeIsNumberOther(C: UCS4): Boolean;
function UnicodeIsCased(C: UCS4): Boolean;
function UnicodeIsControl(C: UCS4): Boolean;
function UnicodeIsSpace(C: UCS4): Boolean;
function UnicodeIsWhiteSpace(C: UCS4): Boolean;
function UnicodeIsBlank(C: UCS4): Boolean;
function UnicodeIsPunctuation(C: UCS4): Boolean;
function UnicodeIsGraph(C: UCS4): Boolean;
function UnicodeIsPrintable(C: UCS4): Boolean;
function UnicodeIsUpper(C: UCS4): Boolean;
function UnicodeIsLower(C: UCS4): Boolean;
function UnicodeIsTitle(C: UCS4): Boolean;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsHexDigit(C: UCS4): Boolean;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeIsIsoControl(C: UCS4): Boolean;
function UnicodeIsFormatControl(C: UCS4): Boolean;
function UnicodeIsSymbol(C: UCS4): Boolean;
function UnicodeIsNumber(C: UCS4): Boolean;
function UnicodeIsNonSpacing(C: UCS4): Boolean;
function UnicodeIsOpenPunctuation(C: UCS4): Boolean;
function UnicodeIsClosePunctuation(C: UCS4): Boolean;
function UnicodeIsInitialPunctuation(C: UCS4): Boolean;
function UnicodeIsFinalPunctuation(C: UCS4): Boolean;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsComposed(C: UCS4): Boolean;
function UnicodeIsQuotationMark(C: UCS4): Boolean;
function UnicodeIsSymmetric(C: UCS4): Boolean;
function UnicodeIsMirroring(C: UCS4): Boolean;
function UnicodeIsNonBreaking(C: UCS4): Boolean;

// Directionality functions
function UnicodeIsRightToLeft(C: UCS4): Boolean;
function UnicodeIsLeftToRight(C: UCS4): Boolean;
function UnicodeIsStrong(C: UCS4): Boolean;
function UnicodeIsWeak(C: UCS4): Boolean;
function UnicodeIsNeutral(C: UCS4): Boolean;
function UnicodeIsSeparator(C: UCS4): Boolean;

// Other character test functions
function UnicodeIsMark(C: UCS4): Boolean;
function UnicodeIsModifier(C: UCS4): Boolean;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeIsLetterNumber(C: UCS4): Boolean;
function UnicodeIsConnectionPunctuation(C: UCS4): Boolean;
function UnicodeIsDash(C: UCS4): Boolean;
function UnicodeIsMath(C: UCS4): Boolean;
function UnicodeIsCurrency(C: UCS4): Boolean;
function UnicodeIsModifierSymbol(C: UCS4): Boolean;
function UnicodeIsSpacingMark(C: UCS4): Boolean;
function UnicodeIsEnclosing(C: UCS4): Boolean;
function UnicodeIsPrivate(C: UCS4): Boolean;
function UnicodeIsSurrogate(C: UCS4): Boolean;
function UnicodeIsLineSeparator(C: UCS4): Boolean;
function UnicodeIsParagraphSeparator(C: UCS4): Boolean;
function UnicodeIsIdentifierStart(C: UCS4): Boolean;
function UnicodeIsIdentifierPart(C: UCS4): Boolean;
function UnicodeIsDefined(C: UCS4): Boolean;
function UnicodeIsUndefined(C: UCS4): Boolean;
function UnicodeIsHan(C: UCS4): Boolean;
function UnicodeIsHangul(C: UCS4): Boolean;

function UnicodeIsUnassigned(C: UCS4): Boolean;
function UnicodeIsLetterOther(C: UCS4): Boolean;
function UnicodeIsConnector(C: UCS4): Boolean;
function UnicodeIsPunctuationOther(C: UCS4): Boolean;
function UnicodeIsSymbolOther(C: UCS4): Boolean;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsLeftToRightEmbedding(C: UCS4): Boolean;
function UnicodeIsLeftToRightOverride(C: UCS4): Boolean;
function UnicodeIsRightToLeftArabic(C: UCS4): Boolean;
function UnicodeIsRightToLeftEmbedding(C: UCS4): Boolean;
function UnicodeIsRightToLeftOverride(C: UCS4): Boolean;
function UnicodeIsPopDirectionalFormat(C: UCS4): Boolean;
function UnicodeIsEuropeanNumber(C: UCS4): Boolean;
function UnicodeIsEuropeanNumberSeparator(C: UCS4): Boolean;
function UnicodeIsEuropeanNumberTerminator(C: UCS4): Boolean;
function UnicodeIsArabicNumber(C: UCS4): Boolean;
function UnicodeIsCommonNumberSeparator(C: UCS4): Boolean;
function UnicodeIsBoundaryNeutral(C: UCS4): Boolean;
function UnicodeIsSegmentSeparator(C: UCS4): Boolean;
function UnicodeIsOtherNeutrals(C: UCS4): Boolean;
function UnicodeIsASCIIHexDigit(C: UCS4): Boolean;
function UnicodeIsBidiControl(C: UCS4): Boolean;
function UnicodeIsDeprecated(C: UCS4): Boolean;
function UnicodeIsDiacritic(C: UCS4): Boolean;
function UnicodeIsExtender(C: UCS4): Boolean;
function UnicodeIsHyphen(C: UCS4): Boolean;
function UnicodeIsIdeographic(C: UCS4): Boolean;
function UnicodeIsIDSBinaryOperator(C: UCS4): Boolean;
function UnicodeIsIDSTrinaryOperator(C: UCS4): Boolean;
function UnicodeIsJoinControl(C: UCS4): Boolean;
function UnicodeIsLogicalOrderException(C: UCS4): Boolean;
function UnicodeIsNonCharacterCodePoint(C: UCS4): Boolean;
function UnicodeIsOtherAlphabetic(C: UCS4): Boolean;
function UnicodeIsOtherDefaultIgnorableCodePoint(C: UCS4): Boolean;
function UnicodeIsOtherGraphemeExtend(C: UCS4): Boolean;
function UnicodeIsOtherIDContinue(C: UCS4): Boolean;
function UnicodeIsOtherIDStart(C: UCS4): Boolean;
function UnicodeIsOtherLowercase(C: UCS4): Boolean;
function UnicodeIsOtherMath(C: UCS4): Boolean;
function UnicodeIsOtherUppercase(C: UCS4): Boolean;
function UnicodeIsPatternSyntax(C: UCS4): Boolean;
function UnicodeIsPatternWhiteSpace(C: UCS4): Boolean;
function UnicodeIsRadical(C: UCS4): Boolean;
function UnicodeIsSoftDotted(C: UCS4): Boolean;
function UnicodeIsSTerm(C: UCS4): Boolean;
function UnicodeIsTerminalPunctuation(C: UCS4): Boolean;
function UnicodeIsUnifiedIdeograph(C: UCS4): Boolean;
function UnicodeIsVariationSelector(C: UCS4): Boolean;
{$ENDIF ~UNICODE_RTL_DATABASE}

// Utility functions
function CharSetFromLocale(Language: LCID): Byte;
function GetCharSetFromLocale(Language: LCID; out FontCharSet: Byte): Boolean;
function CodePageFromLocale(Language: LCID): Word;
function CodeBlockName(const CB: TUnicodeBlock): string;
function CodeBlockRange(const CB: TUnicodeBlock): TUnicodeBlockRange;
function CodeBlockFromChar(const C: UCS4): TUnicodeBlock;
function KeyboardCodePage: Word;
function KeyUnicode(C: Char): Char;
function StringToWideStringEx(const S: AnsiString; CodePage: Word): string;
function TranslateString(const S: AnsiString; CP1, CP2: Word): AnsiString;
function WideStringToStringEx(const WS: string; CodePage: Word): AnsiString;

type
  EUnicodeError = class(Exception);

// functions to load Unicode data from resource
procedure LoadCharacterCategories;
procedure LoadCaseMappingData;
procedure LoadDecompositionData;
procedure LoadCombiningClassData;
procedure LoadNumberData;
procedure LoadCompositionData;

// functions around TUCS4Array
function UCS4Array(Ch: UCS4): TUCS4Array;
function UCS4ArrayConcat(Left, Right: UCS4): TUCS4Array; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
procedure UCS4ArrayConcat(var Left: TUCS4Array; Right: UCS4); overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
procedure UCS4ArrayConcat(var Left: TUCS4Array; const Right: TUCS4Array); overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; const Right: TUCS4Array): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; Right: UCS4): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; const Right: AnsiString): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; Right: AnsiChar): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}

var
  // list of composition mappings
  CompositionsLoaded: Boolean;
  MaxCompositionSize: Integer;

implementation

// Unicode data for case mapping, decomposition, numbers etc. This data is
// loaded on demand which means only those parts will be put in memory which are
// needed by one of the lookup functions.
// Note: There is a little tool called UDExtract which creates a resouce script from
//       the Unicode database file which can be compiled to the needed res file.
//       This tool, including its source code, can be downloaded from www.lischke-online.de/Unicode.html.

{$IFNDEF UNICODE_RTL_DATABASE}
  {$if defined(UNICODE_RAW_DATA)}
{$R Unicode.res}
  {$elseif defined(UNICODE_ZLIB_DATA)}
{$R UnicodeZLib.res}
  {$ifend}
{$ENDIF ~UNICODE_RTL_DATABASE}

uses
  SyncObjs,
{$IFNDEF UNICODE_RTL_DATABASE}
  {$if defined(UNICODE_RAW_DATA)}
  {$elseif defined(UNICODE_ZLIB_DATA)}
  ZLib,
  {$ifend}
{$ENDIF ~UNICODE_RTL_DATABASE}
{$IFNDEF FPC}
  System.RtlConsts;
{$ELSE FPC}
  System; // Just need something here
{$ENDIF FPC}

const
{$IFDEF FPC} // declarations from unit [Rtl]Consts
  SDuplicateString = 'String list does not allow duplicates';
  SListIndexError = 'List index out of bounds (%d)';
  SSortedListError = 'Operation not allowed on sorted string list';
{$ENDIF FPC}
  // some predefined sets to shorten parameter lists below and ease repeative usage
  ClassLetter = [ccLetterUppercase, ccLetterLowercase, ccLetterTitlecase, ccLetterModifier, ccLetterOther];
  ClassSpace = [ccSeparatorSpace];
  ClassPunctuation = [ccPunctuationConnector, ccPunctuationDash, ccPunctuationOpen, ccPunctuationClose,
    ccPunctuationOther, ccPunctuationInitialQuote, ccPunctuationFinalQuote];
  ClassMark = [ccMarkNonSpacing, ccMarkSpacingCombining, ccMarkEnclosing];
  ClassNumber = [ccNumberDecimalDigit, ccNumberLetter, ccNumberOther];
  ClassSymbol = [ccSymbolMath, ccSymbolCurrency, ccSymbolModifier, ccSymbolOther];
  ClassEuropeanNumber = [ccEuropeanNumber, ccEuropeanNumberSeparator, ccEuropeanNumberTerminator];

  // used to negate a set of categories
  ClassAll = [Low(TCharacterCategory)..High(TCharacterCategory)];

function CharacterCategoriesToUnicodeCategory(const Categories: TCharacterCategories): TUnicodeCategory;
var
  Category: TCharacterUnicodeCategory;
begin
  for Category := Low(TCharacterUnicodeCategory) to High(TCharacterUnicodeCategory) do
    if Category in Categories then
  begin
    Result := CharacterCategoryToUnicodeCategory[Category];
    Exit;
  end;
  Result := TUnicodeCategory.ucUnassigned;
end;

function UnicodeCategoryToCharacterCategories(Category: TUnicodeCategory): TCharacterCategories;
begin
  Result := [];
  Include(Result, UnicodeCategoryToCharacterCategory[Category]);
end;

{$IFDEF UNICODE_RTL_DATABASE}
procedure LoadCharacterCategories;
begin
  // do nothing, the RTL database is already loaded
end;

procedure LoadCaseMappingData;
begin
  // do nothing, the RTL database is already loaded
end;

procedure LoadDecompositionData;
begin
  // do nothing, the RTL database is already loaded
end;

procedure LoadCombiningClassData;
begin
  // do nothing, the RTL database is already loaded
end;

procedure LoadNumberData;
begin
  // do nothing, the RTL database is already loaded
end;

procedure LoadCompositionData;
begin
  // do nothing, the RTL database is already loaded
end;
{$ELSE ~UNICODE_RTL_DATABASE}
var
  // As the global data can be accessed by several threads it should be guarded
  // while the data is loaded.
  LoadInProgress: TCriticalSection;

function OpenResourceStream(const ResName: string): TBinaryReader;
var
  ResourceStream: TStream;
  Stream: TStream;
begin
  ResourceStream := TResourceStream.Create(HInstance, ResName, 'UNICODEDATA');

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

  Result := TBinaryReader.Create(Stream, nil, True);
end;

function StreamReadChar(Stream: TStream): Cardinal;
begin
  Result := 0;
  Stream.ReadBuffer(Result, 3);
end;

//----------------- support for character categories -----------------------------------------------

// Character category data is quite a large block since every defined character in Unicode is assigned at least
// one category. Because of this we cannot use a sparse matrix to provide quick access as implemented for
// e.g. composition data.
// The approach used here is based on the fact that an application seldomly uses all characters defined in Unicode
// simultanously. In fact the opposite is true. Most application will use either Western Europe or Arabic or
// Far East character data, but very rarely all together. Based on this fact is the implementation of virtual
// memory using the systems paging file (aka file mapping) to load only into virtual memory what is used currently.
// The implementation is not yet finished and needs a lot of improvements yet.

type
  // start and stop of a range of code points
  TRange = record
    Start,
    Stop: Cardinal;
  end;

  TRangeArray = array of TRange;
  TCategoriesArray = array of array of TCharacterCategories;

var
  // character categories, stored in the system's swap file and mapped on demand
  CategoriesLoaded: Boolean;
  Categories: array [Byte] of TCategoriesArray;

procedure LoadCharacterCategories;
// Loads the character categories data (as saved by the Unicode database extractor, see also
// the comments about JclUnicode.res above).
var
  Size: Integer;
  Stream: TBinaryReader;
  Category: TCharacterCategory;
  Buffer: TRangeArray;
  First, Second, Third: Byte;
  J, K: Integer;
begin
  // make sure no other code is currently modifying the global data area
  LoadInProgress.Enter;
  try
    // Data already loaded?
    if not CategoriesLoaded then
    begin
      Stream := OpenResourceStream('CATEGORIES');
      try
        while Stream.BaseStream.Position < Stream.BaseStream.Size do
        begin
          // a) read which category is current in the stream
          Stream.BaseStream.Read(Category, SizeOf(Category));
          // b) read the size of the ranges and the ranges themself
          Stream.BaseStream.Read(Size, SizeOf(Size));
          if Size > 0 then
          begin
            SetLength(Buffer, Size);
            for J := 0 to Size - 1 do
            begin
              Buffer[J].Start := StreamReadChar(Stream.BaseStream);
              Buffer[J].Stop := StreamReadChar(Stream.BaseStream);
            end;

            // c) go through every range and add the current category to each code point
            for J := 0 to Size - 1 do
              for K := Buffer[J].Start to Buffer[J].Stop do
              begin
                Assert(K < $1000000);

                First := (K shr 16) and $FF;
                Second := (K shr 8) and $FF;
                Third := K and $FF;
                // add second step array if not yet done
                if Categories[First] = nil then
                  SetLength(Categories[First], 256);
                if Categories[First, Second] = nil then
                  SetLength(Categories[First, Second], 256);
                // The array is allocated on the exact size, but the compiler generates
                // a 32 bit "BTS" instruction that accesses memory beyond the allocated block.
                if Third < 255 then
                  Include(Categories[First, Second, Third], Category)
                else
                  Categories[First, Second, Third] := Categories[First, Second, Third] + [Category];
              end;
          end;
        end;
        // Assert(Stream.Position = Stream.Size);
      finally
        Stream.Free;
        CategoriesLoaded := True;
      end;
    end;
  finally
    LoadInProgress.Leave;
  end;
end;

function CategoryLookup(Code: Cardinal; Cats: TCharacterCategories): Boolean; overload;
// determines whether the Code is in the given category
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000);

  // load property data if not already done
  if not CategoriesLoaded then
    LoadCharacterCategories;

  First := (Code shr 16) and $FF;
  Second := (Code shr 8) and $FF;
  Third := Code and $FF;
  if (Categories[First] <> nil) and (Categories[First, Second] <> nil) then
    Result := Categories[First, Second, Third] * Cats <> []
  else
    Result := False;
end;

//----------------- support for case mapping -------------------------------------------------------

type
// case conversion function
  TCaseType = (ctFold, ctLower, ctTitle, ctUpper);
  TCase = array [TCaseType] of TUCS4Array; // mapping for case fold, lower, title and upper in this order
  TCaseArray = array of array of TCase;

var
  // An array for all case mappings (including 1 to many casing if saved by the extraction program).
  // The organization is a sparse, two stage matrix.
  // SingletonMapping is to quickly return a single default mapping.
  CaseDataLoaded: Boolean;
  CaseMapping: array [Byte] of TCaseArray;

procedure LoadCaseMappingData;
var
  Stream: TBinaryReader;
  I, J, Code, Size: Integer;
  First, Second, Third: Byte;
begin
  // make sure no other code is currently modifying the global data area
  LoadInProgress.Enter;
  try
    if not CaseDataLoaded then
    begin
      Stream := OpenResourceStream('CASE');
      try
        // the first entry in the stream is the number of entries in the case mapping table
        Stream.BaseStream.Read(Size, SizeOf(Size));
        for I := 0 to Size - 1 do
        begin
          // a) read actual code point
          Code := StreamReadChar(Stream.BaseStream);
          Assert(Code < $1000000);

          // if there is no high byte entry in the first stage table then create one
          First := (Code shr 16) and $FF;
          Second := (Code shr 8) and $FF;
          Third := Code and $FF;
          if CaseMapping[First] = nil then
            SetLength(CaseMapping[First], 256);
          if CaseMapping[First, Second] = nil then
            SetLength(CaseMapping[First, Second], 256);

          // b) read fold case array
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            SetLength(CaseMapping[First, Second, Third, ctFold], Size);
            for J := 0 to Size - 1 do
              CaseMapping[First, Second, Third, ctFold, J] := StreamReadChar(Stream.BaseStream);
          end;
          // c) read lower case array
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            SetLength(CaseMapping[First, Second, Third, ctLower], Size);
            for J := 0 to Size - 1 do
              CaseMapping[First, Second, Third, ctLower, J] := StreamReadChar(Stream.BaseStream);
          end;
          // d) read title case array
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            SetLength(CaseMapping[First, Second, Third, ctTitle], Size);
            for J := 0 to Size - 1 do
              CaseMapping[First, Second, Third, ctTitle, J] := StreamReadChar(Stream.BaseStream);
          end;
          // e) read upper case array
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            SetLength(CaseMapping[First, Second, Third, ctUpper], Size);
            for J := 0 to Size - 1 do
              CaseMapping[First, Second, Third, ctUpper, J] := StreamReadChar(Stream.BaseStream);
          end;
        end;
        Assert(Stream.BaseStream.Position = Stream.BaseStream.Size);
      finally
        Stream.Free;
        CaseDataLoaded := True;
      end;
    end;
  finally
    LoadInProgress.Leave;
  end;
end;

function CaseLookup(Code: Cardinal; CaseType: TCaseType; var Mapping: TUCS4Array): Boolean;
// Performs a lookup of the given code; returns True if Found, with Mapping referring to the mapping.
// ctFold is handled specially: if no mapping is found then result of looking up ctLower
//   is returned
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000);

  // load case mapping data if not already done
  if not CaseDataLoaded then
    LoadCaseMappingData;

  First := (Code shr 16) and $FF;
  Second := (Code shr 8) and $FF;
  Third := Code and $FF;
  // Check first stage table whether there is a mapping for a particular block and
  // (if so) then whether there is a mapping or not.
  if (CaseMapping[First] <> nil) and (CaseMapping[First, Second] <> nil) and
     (CaseMapping[First, Second, Third, CaseType] <> nil) then
    Mapping := CaseMapping[First, Second, Third, CaseType]
  else
    Mapping := nil;
  Result := Assigned(Mapping);
  // defer to lower case if no fold case exists
  if not Result and (CaseType = ctFold) and (CaseMapping[First] <> nil) and
    (CaseMapping[First, Second] <> nil) and (CaseMapping[First, Second, Third, ctLower] <> nil) then
  begin
    Mapping := CaseMapping[First, Second, Third, ctLower];
    Result := Assigned(Mapping);
  end;
end;

function UnicodeCaseFold(Code: UCS4): TUCS4Array;
// This function returnes an array of special case fold mappings if there is one defined for the given
// code, otherwise the lower case will be returned. This all applies only to cased code points.
// Uncased code points are returned unchanged.
begin
  SetLength(Result, 0);
  if not CaseLookup(Code, ctFold, Result) then
  begin
    SetLength(Result, 1);
    Result[0] := Code;
  end;
end;

{$ENDIF ~UNICODE_RTL_DATABASE}

function UnicodeToUpper(Code: UCS4): TUCS4Array;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  SetLength(Result, 1);
  Result[0] := Ord(TCharacter.ToUpper(Chr(Code)));
{$ELSE ~UNICODE_RTL_DATABASE}
  SetLength(Result, 0);
  if not CaseLookup(Code, ctUpper, Result) then
  begin
    SetLength(Result, 1);
    Result[0] := Code;
  end;
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeToLower(Code: UCS4): TUCS4Array;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  SetLength(Result, 1);
  Result[0] := Ord(TCharacter.ToLower(Chr(Code)));
{$ELSE ~UNICODE_RTL_DATABASE}
  SetLength(Result, 0);
  if not CaseLookup(Code, ctLower, Result) then
  begin
    SetLength(Result, 1);
    Result[0] := Code;
  end;
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

{$IFNDEF UNICODE_RTL_DATABASE}

function UnicodeToTitle(Code: UCS4): TUCS4Array;
begin
  SetLength(Result, 0);
  if not CaseLookup(Code, ctTitle, Result) then
  begin
    SetLength(Result, 1);
    Result[0] := Code;
  end;
end;

{$ENDIF ~UNICODE_RTL_DATABASE}
//----------------- support for decomposition ------------------------------------------------------

const
  // constants for hangul composition and hangul-to-jamo decomposition
  SBase = $AC00;             // hangul syllables start code point
  LBase = $1100;             // leading syllable
  VBase = $1161;
  TBase = $11A7;             // trailing syllable
  LCount = 19;
  VCount = 21;
  TCount = 28;
  NCount = VCount * TCount;   // 588
  SCount = LCount * NCount;   // 11172

type
  TDecomposition = record
    Tag: TCompatibilityFormattingTag;
    Leaves: TUCS4Array;
  end;
  PDecomposition = ^TDecomposition;
  TDecompositionArray = array of TDecomposition;
  TDecompositions = array of TDecompositionArray;
  TDecompositionsArray = array [Byte] of TDecompositions;

var
  // list of decompositions, organized (again) as three stage matrix
  // Note: there are two tables, one for canonical decompositions and the other one
  //       for compatibility decompositions.
  DecompositionsLoaded: Boolean;
  Decompositions: TDecompositionsArray;

procedure LoadDecompositionData;
var
  Stream: TBinaryReader;
  I, J, Code, Size: Integer;
  First, Second, Third: Byte;
begin
  // make sure no other code is currently modifying the global data area
  LoadInProgress.Enter;
  try
    if not DecompositionsLoaded then
    begin
      Stream := OpenResourceStream('DECOMPOSITION');
      try
        // determine how many decomposition entries we have
        Stream.BaseStream.Read(Size, SizeOf(Size));
        for I := 0 to Size - 1 do
        begin
          Code := StreamReadChar(Stream.BaseStream);

          Assert(Code < $1000000);

          First := (Code shr 16) and $FF;
          Second := (Code shr 8) and $FF;
          Third := Code and $FF;

          // if there is no high byte entry in the first stage table then create one
          if Decompositions[First] = nil then
            SetLength(Decompositions[First], 256);
          if Decompositions[First, Second] = nil then
            SetLength(Decompositions[First, Second], 256);

          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            Decompositions[First, Second, Third].Tag := TCompatibilityFormattingTag(Stream.ReadByte);
            SetLength(Decompositions[First, Second, Third].Leaves, Size);
            for J := 0 to Size - 1 do
              Decompositions[First, Second, Third].Leaves[J] := StreamReadChar(Stream.BaseStream);
          end;
        end;
        Assert(Stream.BaseStream.Position = Stream.BaseStream.Size);
      finally
        Stream.Free;
        DecompositionsLoaded := True;
      end;
    end;
  finally
    LoadInProgress.Leave;
  end;
end;

function UnicodeDecompose(const Codes: TUCS4Array; Compatible: Boolean; Filter: TCodePointFilter): TUCS4Array;
var
  OutputSize: integer;

  procedure AddCodePoint(const ACodePoint: UCS4);
  begin
    if Length(Result) < (OutputSize+1) then
      SetLength(Result, (OutputSize+1) * 2);
    Result[OutputSize] := ACodePoint;
    Inc(OutputSize);
  end;

  procedure AddCodePoints(const ACodePoints: TUCS4Array);
  var
    CodePoint: UCS4;
  begin
    if Length(Result) < (OutputSize+Length(ACodePoints)) then
      SetLength(Result, (OutputSize+Length(ACodePoints)) * 2);
    for CodePoint in ACodePoints do
    begin
      Result[OutputSize] := CodePoint;
      Inc(OutputSize);
    end;
  end;

  procedure DecomposeHangul(CodePoint: UCS4);
  var
    Rest: Integer;
  begin
    Dec(CodePoint, SBase);
    AddCodePoint(LBase + (CodePoint div NCount));
    AddCodePoint(VBase + ((CodePoint mod NCount) div TCount));
    Rest := CodePoint mod TCount;
    if Rest <> 0 then
      AddCodePoint(TBase + Rest);
  end;

var
  Index: integer;
  First, Second, Third: Byte;
  CodePoint: UCS4;
  Level1: TDecompositions;
  Level2: TDecompositionArray;
  Level3: PDecomposition;
begin
  SetLength(Result, Length(Codes));

  OutputSize := 0;
  Index := 0;

  // Load decomposition data if not already done
  if not DecompositionsLoaded then
    LoadDecompositionData;

  while (Index <= High(Codes)) do
  begin
    CodePoint := Codes[Index];
    Inc(Index);

    Assert(CodePoint < $1000000);

    // If the CodePoint is hangul then decomposition is performed algorithmically
    if UnicodeIsHangul(CodePoint) then
    begin
      DecomposeHangul(CodePoint);
      continue;
    end else
    begin
      First := (CodePoint shr 16) and $FF;
      Second := (CodePoint shr 8) and $FF;
      Third := CodePoint and $FF;

      Level1 := Decompositions[First];
      if (Level1 <> nil) then
      begin
        Level2 := Level1[Second];
        if (Level2 <> nil) then
        begin
          Level3 := @Level2[Third];
          if (Level3.Leaves <> nil) and (Compatible or (Level3.Tag = cftCanonical)) then
          begin
            AddCodePoints(Level3.Leaves);
            continue;
          end;
        end;
      end;
    end;
    AddCodePoint(CodePoint);
  end;

  SetLength(Result, OutputSize);
end;

//----------------- support for combining classes --------------------------------------------------

type
  TClassArray = array of array of Byte;

var
  // canonical combining classes, again as two stage matrix
  CCCsLoaded: Boolean;
  CCCs: array [Byte] of TClassArray;

procedure LoadCombiningClassData;
var
  Stream: TBinaryReader;
  I, J, K, Size: Integer;
  Buffer: TRangeArray;
  First, Second, Third: Byte;
begin
  // make sure no other code is currently modifying the global data area
  LoadInProgress.Enter;
  try
    if not CCCsLoaded then
    begin
      Stream := OpenResourceStream('COMBINING');
      try
        while Stream.BaseStream.Position < Stream.BaseStream.Size do
        begin
          // a) determine which class is stored here
          I := Stream.ReadByte;
          // b) determine how many ranges are assigned to this class
          Size := Stream.ReadByte;
          // c) read start and stop code of each range
          if Size > 0 then
          begin
            SetLength(Buffer, Size);
            for J := 0 to Size - 1 do
            begin
              Buffer[J].Start := StreamReadChar(Stream.BaseStream);
              Buffer[J].Stop := StreamReadChar(Stream.BaseStream);
            end;

            // d) put this class in every of the code points just loaded
            for J := 0 to Size - 1 do
              for K := Buffer[J].Start to Buffer[J].Stop do
              begin
                // (outchy) TODO: handle in a cleaner way
                Assert(K < $1000000);
                First := (K shr 16) and $FF;
                Second := (K shr 8) and $FF;
                Third := K and $FF;
                // add second step array if not yet done
                if CCCs[First] = nil then
                  SetLength(CCCs[First], 256);
                if CCCs[First, Second] = nil then
                  SetLength(CCCs[First, Second], 256);
                CCCs[First, Second, Third] := I;
              end;
          end;
        end;
        // Assert(Stream.Position = Stream.Size);
      finally
        Stream.Free;
        CCCsLoaded := True;
      end;
    end;
  finally
    LoadInProgress.Leave;
  end;
end;

function CanonicalCombiningClass(Code: Cardinal): Cardinal;
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000);

  // load combining class data if not already done
  if not CCCsLoaded then
    LoadCombiningClassData;

  First := (Code shr 16) and $FF;
  Second := (Code shr 8) and $FF;
  Third := Code and $FF;
  if (CCCs[First] <> nil) and (CCCs[First, Second] <> nil) then
    Result := CCCs[First, Second, Third]
  else
    Result := 0;
end;

//----------------- support for numeric values -----------------------------------------------------

type
  // structures for handling numbers
  TCodeIndex = record
    Code,
    Index: Cardinal;
  end;

var
  // array to hold the number equivalents for specific codes
  NumberCodesLoaded: Boolean;
  NumberCodes: array of TCodeIndex;
  // array of numbers used in NumberCodes
  Numbers: array of TUcNumber;

procedure LoadNumberData;
var
  Stream: TBinaryReader;
  Size, I: Integer;
begin
  // make sure no other code is currently modifying the global data area
  LoadInProgress.Enter;
  try
    if not NumberCodesLoaded then
    begin
      Stream := OpenResourceStream('NUMBERS');
      try
        // Numbers are special (compared to other Unicode data) as they utilize two
        // arrays, one containing all used numbers (in nominator-denominator format) and
        // another one which maps a code point to one of the numbers in the first array.

        // a) determine size of numbers array
        Size := Stream.ReadByte;
        SetLength(Numbers, Size);
        // b) read numbers data
        for I := 0 to Size - 1 do
        begin
          Numbers[I].Numerator := Stream.ReadInteger;
          Numbers[I].Denominator := Stream.ReadInteger;
        end;
        // c) determine size of index array
        Size := Stream.ReadInteger;
        SetLength(NumberCodes, Size);
        // d) read index data
        for I := 0 to Size - 1 do
        begin
          NumberCodes[I].Code := StreamReadChar(Stream.BaseStream);
          NumberCodes[I].Index := Stream.ReadByte;
        end;
        Assert(Stream.BaseStream.Position = Stream.BaseStream.Size);
      finally
        Stream.Free;
        NumberCodesLoaded := True;
      end;
    end;
  finally
    LoadInProgress.Leave;
  end;
end;

function UnicodeNumberLookup(Code: UCS4; var Number: TUcNumber): Boolean;
// Searches for the given code and returns its number equivalent (if there is one).
// Typical cases are: '1/6' (U+2159), '3/8' (U+215C), 'XII' (U+216B) etc.
// Result is set to True if the code could be found.
var
  L, R, M: Integer;
begin
  // load number data if not already done
  if not NumberCodesLoaded then
    LoadNumberData;

  Result := False;
  L := 0;
  R := High(NumberCodes);
  while L <= R do
  begin
    M := (L + R) shr 1;
    if Code > NumberCodes[M].Code then
      L := M + 1
    else
    begin
      if Code < NumberCodes[M].Code then
        R := M - 1
      else
      begin
        Number := Numbers[NumberCodes[M].Index];
        Result := True;
        Break;
      end;
    end;
  end;
end;

//----------------- support for composition --------------------------------------------------------

type
  // maps between a pair of code points to a composite code point
  // Note: the source pair is packed into one 4 byte value to speed up search.
  TComposition = record
    Code: Cardinal;
    Tag: TCompatibilityFormattingTag;
    First: Cardinal;
    Next: array of Cardinal;
  end;

var
  // list of composition mappings
  Compositions: array of TComposition;

procedure LoadCompositionData;
var
  Stream: TBinaryReader;
  I, J, Size: Integer;
begin
  // make sure no other code is currently modifying the global data area
  LoadInProgress.Enter;
  try
    if not CompositionsLoaded then
    begin
      Stream := OpenResourceStream('COMPOSITION');
      try
        // a) determine size of compositions array
        Size := Stream.ReadInteger;
        SetLength(Compositions, Size);
        // b) read data
        for I := 0 to Size - 1 do
        begin
          Compositions[I].Code := StreamReadChar(Stream.BaseStream);
          Size := Stream.ReadByte;
          if Size > MaxCompositionSize then
            MaxCompositionSize := Size;
          SetLength(Compositions[I].Next, Size - 1);
          Compositions[I].Tag := TCompatibilityFormattingTag(Stream.ReadByte);
          Compositions[I].First := StreamReadChar(Stream.BaseStream);
          for J := 0 to Size - 2 do
            Compositions[I].Next[J] := StreamReadChar(Stream.BaseStream);
        end;
        Assert(Stream.BaseStream.Position = Stream.BaseStream.Size);
      finally
        Stream.Free;
        CompositionsLoaded := True;
      end;
    end;
  finally
    LoadInProgress.Leave;
  end;
end;

function UnicodeCompose(const Codes: TUCS4Array; Compatible: Boolean; Filter: TCodePointFilter): TUCS4Array;
var
  OutputSize: integer;

  procedure AddCodePoint(const ACodePoint: UCS4);
  begin
    if Length(Result) < (OutputSize+1) then
      SetLength(Result, (OutputSize+1) * 2);
    Result[OutputSize] := ACodePoint;
    Inc(OutputSize);
  end;

  function Compose(Index: integer): integer;
  var
    L, R, M: Integer;
    HighNext: Integer;
    StartCodePoint: UCS4;
    i: integer;
  begin
    StartCodePoint := Codes[Index];

    if (Index = High(Codes)) then
    begin
      AddCodePoint(StartCodePoint);
      Result := 1;
      exit;
    end;

    L := 0;
    R := High(Compositions);

    // Binary search...
    while L <= R do
    begin
      M := (L + R) shr 1;
      if Compositions[M].First > StartCodePoint then
      begin
        R := M - 1;
        continue;
      end;

      if Compositions[M].First < StartCodePoint then
      begin
        L := M + 1;
        continue;
      end;

      // Match

      // Scan backward to the first element where First match
      while (M > 0) and (Compositions[M-1].First = StartCodePoint) do
        Dec(M);

      // Iterate forward through elements where First match
      while (M <= High(Compositions)) and (Compositions[M].First = StartCodePoint) do
      begin
        HighNext := High(Compositions[M].Next);
        Result := 0;

        // Enough characters in buffer to be tested?
        if (Index+HighNext < High(Codes)) and
          (Compatible or (Compositions[M].Tag = cftCanonical)) then
        begin
          for i := 0 to HighNext do
          begin
            if Compositions[M].Next[i] = Codes[Index + i + 1] then
              Result := i + 2 { +1 for first, +1 because of 0-based array }
            else
              break;
          end;

          if Result = HighNext + 2 then // all codes matched
          begin
            if (not Assigned(Filter)) or (Filter(Compositions[M].Code)) then
            begin
              AddCodePoint(Compositions[M].Code);
              exit;
            end;
            break;
          end;
        end;

        Inc(M);
      end;
      Break;
    end;

    AddCodePoint(StartCodePoint);
    Result := 1;
  end;

var
  Index: integer;
  Consumed: integer;
begin
  if (Length(Codes) <= 1) then
    Exit(Codes);
    
  // Load composition data if not already done
  if not CompositionsLoaded then
    LoadCompositionData;

  SetLength(Result, Length(Codes));
  OutputSize := 0;
  Index := 0;

  while (Index <= High(Codes)) do
  begin
    Consumed := Compose(Index);
    Inc(Index, Consumed);
  end;

  SetLength(Result, OutputSize);
end;

{$IFNDEF UNICODE_RTL_DATABASE}

function WideComposeHangul(const Source: string): string;
var
  Len: NativeInt;
  Ch, Last: Char;
  I: NativeInt;
  LIndex, VIndex,
  SIndex, TIndex: NativeInt;
begin
  Result := '';
  Len := Length(Source);
  if Len > 0 then
  begin
    Last := Source[1];
    Result := Last;

    for I := 2 to Len do
    begin
      Ch := Source[I];

      // 1. check to see if two current characters are L and V
      LIndex := Word(Last) - LBase;
      if (0 <= LIndex) and (LIndex < LCount) then
      begin
        VIndex := Word(Ch) - VBase;
        if (0 <= VIndex) and (VIndex < VCount) then
        begin
          // make syllable of form LV
          Last := Char((SBase + (LIndex * VCount + VIndex) * TCount));
          Result[Length(Result)] := Last; // reset last
          Continue; // discard Ch
        end;
      end;

      // 2. check to see if two current characters are LV and T
      SIndex := Word(Last) - SBase;
      if (0 <= SIndex) and (SIndex < SCount) and ((SIndex mod TCount) = 0) then
      begin
        TIndex := Word(Ch) - TBase;
        if (0 <= TIndex) and (TIndex <= TCount) then
        begin
          // make syllable of form LVT
          Inc(Word(Last), TIndex);
          Result[Length(Result)] := Last; // reset last
          Continue; // discard Ch
        end;
      end;

      // if neither case was true, just add the character
      Last := Ch;
      Result := Result + Ch;
    end;
  end;
end;

{$ENDIF ~UNICODE_RTL_DATABASE}

//----------------- character test routines --------------------------------------------------------

function UnicodeIsAlpha(C: UCS4): Boolean; // Is the character alphabetic?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsLetter(Chr(C));
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassLetter);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsDigit(C: UCS4): Boolean; // Is the character a digit?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsDigit(Chr(C));
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccNumberDecimalDigit]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsAlphaNum(C: UCS4): Boolean; // Is the character alphabetic or a number?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsLetterOrDigit(Chr(C));
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassLetter + [ccNumberDecimalDigit]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsNumberOther(C: UCS4): Boolean;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherNumber;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccNumberOther]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsCased(C: UCS4): Boolean;
// Is the character a "cased" character, i.e. either lower case, title case or upper case
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucTitlecaseLetter, TUnicodeCategory.ucUppercaseLetter];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterLowercase, ccLetterTitleCase, ccLetterUppercase]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsControl(C: UCS4): Boolean;
// Is the character a control character?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucControl, TUnicodeCategory.ucFormat];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherControl, ccOtherFormat]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsSpace(C: UCS4): Boolean;
// Is the character a spacing character?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSpaceSeparator;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassSpace);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsWhiteSpace(C: UCS4): Boolean;
// Is the character a white space character (same as UnicodeIsSpace plus
// tabulator, new line etc.)?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsWhiteSpace(Chr(C));
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassSpace + [ccWhiteSpace, ccSegmentSeparator]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsBlank(C: UCS4): Boolean;
// Is the character a space separator?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSpaceSeparator;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSeparatorSpace]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsPunctuation(C: UCS4): Boolean;
// Is the character a punctuation mark?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassPunctuation);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsGraph(C: UCS4): Boolean;
// Is the character graphical?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucEnclosingMark,
     TUnicodeCategory.ucNonSpacingMark,
     TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber,
     TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation,
     TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassMark + ClassNumber + ClassLetter + ClassPunctuation + ClassSymbol);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsPrintable(C: UCS4): Boolean;
// Is the character printable?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucEnclosingMark,
     TUnicodeCategory.ucNonSpacingMark,
     TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber,
     TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation,
     TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol,
     TUnicodeCategory.ucSpaceSeparator];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassMark + ClassNumber + ClassLetter + ClassPunctuation + ClassSymbol +
    [ccSeparatorSpace]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsUpper(C: UCS4): Boolean;
// Is the character already upper case?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUppercaseLetter;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterUppercase]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsLower(C: UCS4): Boolean;
// Is the character already lower case?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLowercaseLetter;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterLowercase]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsTitle(C: UCS4): Boolean;
// Is the character already title case?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucTitlecaseLetter;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterTitlecase]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsHexDigit(C: UCS4): Boolean;
// Is the character a hex digit?
begin
  Result := CategoryLookup(C, [ccHexDigit]);
end;
{$ENDIF ~UNICODE_RTL_DATABASE}

function UnicodeIsIsoControl(C: UCS4): Boolean;
// Is the character a C0 control character (< 32)?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucControl;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherControl]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsFormatControl(C: UCS4): Boolean;
// Is the character a format control character?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucFormat;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherFormat]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsSymbol(C: UCS4): Boolean;
// Is the character a symbol?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassSymbol);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsNumber(C: UCS4): Boolean;
// Is the character a number or digit?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassNumber);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsNonSpacing(C: UCS4): Boolean;
// Is the character non-spacing?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucNonSpacingMark;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccMarkNonSpacing]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsOpenPunctuation(C: UCS4): Boolean;
// Is the character an open/left punctuation (e.g. '[')?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOpenPunctuation;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationOpen]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsClosePunctuation(C: UCS4): Boolean;
// Is the character an close/right punctuation (e.g. ']')?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucClosePunctuation;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationClose]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsInitialPunctuation(C: UCS4): Boolean;
// Is the character an initial punctuation (e.g. U+2018 LEFT SINGLE QUOTATION MARK)?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucInitialPunctuation;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationInitialQuote]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsFinalPunctuation(C: UCS4): Boolean;
// Is the character a final punctuation (e.g. U+2019 RIGHT SINGLE QUOTATION MARK)?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucFinalPunctuation;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationFinalQuote]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsComposed(C: UCS4): Boolean;
// Can the character be decomposed into a set of other characters?
begin
  Result := CategoryLookup(C, [ccComposed]);
end;

function UnicodeIsQuotationMark(C: UCS4): Boolean;
// Is the character one of the many quotation marks?
begin
  Result := CategoryLookup(C, [ccQuotationMark]);
end;

function UnicodeIsSymmetric(C: UCS4): Boolean;
// Is the character one that has an opposite form (i.e. <>)?
begin
  Result := CategoryLookup(C, [ccSymmetric]);
end;

function UnicodeIsMirroring(C: UCS4): Boolean;
// Is the character mirroring (superset of symmetric)?
begin
  Result := CategoryLookup(C, [ccMirroring]);
end;

function UnicodeIsNonBreaking(C: UCS4): Boolean;
// Is the character non-breaking (i.e. non-breaking space)?
begin
  Result := CategoryLookup(C, [ccNonBreaking]);
end;

function UnicodeIsRightToLeft(C: UCS4): Boolean;
// Does the character have strong right-to-left directionality (i.e. Arabic letters)?
begin
  Result := CategoryLookup(C, [ccRightToLeft]);
end;

function UnicodeIsLeftToRight(C: UCS4): Boolean;
// Does the character have strong left-to-right directionality (i.e. Latin letters)?
begin
  Result := CategoryLookup(C, [ccLeftToRight]);
end;

function UnicodeIsStrong(C: UCS4): Boolean;
// Does the character have strong directionality?
begin
  Result := CategoryLookup(C, [ccLeftToRight, ccRightToLeft]);
end;

function UnicodeIsWeak(C: UCS4): Boolean;
// Does the character have weak directionality (i.e. numbers)?
begin
  Result := CategoryLookup(C, ClassEuropeanNumber + [ccArabicNumber, ccCommonNumberSeparator]);
end;

function UnicodeIsNeutral(C: UCS4): Boolean;
// Does the character have neutral directionality (i.e. whitespace)?
begin
  Result := CategoryLookup(C, [ccSeparatorParagraph, ccSegmentSeparator, ccWhiteSpace, ccOtherNeutrals]);
end;

function UnicodeIsSeparator(C: UCS4): Boolean;
// Is the character a block or segment separator?
begin
  Result := CategoryLookup(C, [ccSeparatorParagraph, ccSegmentSeparator]);
end;

function UnicodeIsMark(C: UCS4): Boolean;
// Is the character a mark of some kind?
begin
  Result := CategoryLookup(C, ClassMark);
end;

function UnicodeIsModifier(C: UCS4): Boolean;
// Is the character a letter modifier?
begin
  Result := CategoryLookup(C, [ccLetterModifier]);
end;
{$ENDIF ~UNICODE_RTL_DATABASE}

function UnicodeIsLetterNumber(C: UCS4): Boolean;
// Is the character a number represented by a letter?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLetterNumber;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccNumberLetter]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsConnectionPunctuation(C: UCS4): Boolean;
// Is the character connecting punctuation?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucConnectPunctuation;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationConnector]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsDash(C: UCS4): Boolean;
// Is the character a dash punctuation?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucDashPunctuation;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationDash]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsMath(C: UCS4): Boolean;
// Is the character a math character?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucMathSymbol;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSymbolMath]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsCurrency(C: UCS4): Boolean;
// Is the character a currency character?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucCurrencySymbol;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSymbolCurrency]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsModifierSymbol(C: UCS4): Boolean;
// Is the character a modifier symbol?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucModifierSymbol;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSymbolModifier]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsSpacingMark(C: UCS4): Boolean;
// Is the character a spacing mark?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLineSeparator, TUnicodeCategory.ucParagraphSeparator,
     TUnicodeCategory.ucSpaceSeparator];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccMarkSpacingCombining]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsEnclosing(C: UCS4): Boolean;
// Is the character enclosing (i.e. enclosing box)?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucEnclosingMark;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccMarkEnclosing]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsPrivate(C: UCS4): Boolean;
// Is the character from the Private Use Area?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucPrivateUse;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherPrivate]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsSurrogate(C: UCS4): Boolean;
// Is the character one of the surrogate codes?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSurrogate;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherSurrogate]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsLineSeparator(C: UCS4): Boolean;
// Is the character a line separator?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLineSeparator;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSeparatorLine]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsParagraphSeparator(C: UCS4): Boolean;
// Is th character a paragraph separator;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucParagraphSeparator;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSeparatorParagraph]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsIdentifierStart(C: UCS4): Boolean;
// Can the character begin an identifier?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucLetterNumber];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassLetter + [ccNumberLetter]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsIdentifierPart(C: UCS4): Boolean;
// Can the character appear in an identifier?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucLetterNumber, TUnicodeCategory.ucDecimalNumber,
     TUnicodeCategory.ucNonSpacingMark, TUnicodeCategory.ucCombiningMark,
     TUnicodeCategory.ucConnectPunctuation,
     TUnicodeCategory.ucFormat];
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassLetter + [ccNumberLetter, ccMarkNonSpacing, ccMarkSpacingCombining,
    ccNumberDecimalDigit, ccPunctuationConnector, ccOtherFormat]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsDefined(C: UCS4): Boolean;
// Is the character defined (appears in one of the data files)?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) <> TUnicodeCategory.ucUnassigned;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccAssigned]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsUndefined(C: UCS4): Boolean;
// Is the character undefined (not assigned in the Unicode database)?
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUnassigned;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := not CategoryLookup(C, [ccAssigned]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsHan(C: UCS4): Boolean;
// Is the character a Han ideograph?
begin
  Result := ((C >= $4E00) and (C <= $9FFF))  or ((C >= $F900) and (C <= $FAFF));
end;

function UnicodeIsHangul(C: UCS4): Boolean;
// Is the character a pre-composed Hangul syllable?
begin
  Result := (C >= $AC00) and (C <= $D7FF);
end;

function UnicodeIsUnassigned(C: UCS4): Boolean;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUnassigned;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherUnassigned]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsLetterOther(C: UCS4): Boolean;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherLetter;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterOther]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsConnector(C: UCS4): Boolean;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucConnectPunctuation;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationConnector]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsPunctuationOther(C: UCS4): Boolean;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherPunctuation;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationOther]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

function UnicodeIsSymbolOther(C: UCS4): Boolean;
begin
{$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherSymbol;
{$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSymbolOther]);
{$ENDIF ~UNICODE_RTL_DATABASE}
end;

{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsLeftToRightEmbedding(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccLeftToRightEmbedding]);
end;

function UnicodeIsLeftToRightOverride(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccLeftToRightOverride]);
end;

function UnicodeIsRightToLeftArabic(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccRightToLeftArabic]);
end;

function UnicodeIsRightToLeftEmbedding(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccRightToLeftEmbedding]);
end;

function UnicodeIsRightToLeftOverride(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccRightToLeftOverride]);
end;

function UnicodeIsPopDirectionalFormat(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccPopDirectionalFormat]);
end;

function UnicodeIsEuropeanNumber(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccEuropeanNumber]);
end;

function UnicodeIsEuropeanNumberSeparator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccEuropeanNumberSeparator]);
end;

function UnicodeIsEuropeanNumberTerminator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccEuropeanNumberTerminator]);
end;

function UnicodeIsArabicNumber(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccArabicNumber]);
end;

function UnicodeIsCommonNumberSeparator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccCommonNumberSeparator]);
end;

function UnicodeIsBoundaryNeutral(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccBoundaryNeutral]);
end;

function UnicodeIsSegmentSeparator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccSegmentSeparator]);
end;

function UnicodeIsOtherNeutrals(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherNeutrals]);
end;

function UnicodeIsASCIIHexDigit(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccASCIIHexDigit]);
end;

function UnicodeIsBidiControl(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccBidiControl]);
end;

function UnicodeIsDeprecated(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccDeprecated]);
end;

function UnicodeIsDiacritic(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccDiacritic]);
end;

function UnicodeIsExtender(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccExtender]);
end;

function UnicodeIsHyphen(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccHyphen]);
end;

function UnicodeIsIdeographic(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccIdeographic]);
end;

function UnicodeIsIDSBinaryOperator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccIDSBinaryOperator]);
end;

function UnicodeIsIDSTrinaryOperator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccIDSTrinaryOperator]);
end;

function UnicodeIsJoinControl(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccJoinControl]);
end;

function UnicodeIsLogicalOrderException(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccLogicalOrderException]);
end;

function UnicodeIsNonCharacterCodePoint(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccNonCharacterCodePoint]);
end;

function UnicodeIsOtherAlphabetic(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherAlphabetic]);
end;

function UnicodeIsOtherDefaultIgnorableCodePoint(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherDefaultIgnorableCodePoint]);
end;

function UnicodeIsOtherGraphemeExtend(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherGraphemeExtend]);
end;

function UnicodeIsOtherIDContinue(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherIDContinue]);
end;

function UnicodeIsOtherIDStart(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherIDStart]);
end;

function UnicodeIsOtherLowercase(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherLowercase]);
end;

function UnicodeIsOtherMath(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherMath]);
end;

function UnicodeIsOtherUppercase(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherUppercase]);
end;

function UnicodeIsPatternSyntax(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccPatternSyntax]);
end;

function UnicodeIsPatternWhiteSpace(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccPatternWhiteSpace]);
end;

function UnicodeIsRadical(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccRadical]);
end;

function UnicodeIsSoftDotted(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccSoftDotted]);
end;

function UnicodeIsSTerm(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccSTerm]);
end;

function UnicodeIsTerminalPunctuation(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccTerminalPunctuation]);
end;

function UnicodeIsUnifiedIdeograph(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccUnifiedIdeograph]);
end;

function UnicodeIsVariationSelector(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccVariationSelector]);
end;
{$ENDIF ~UNICODE_RTL_DATABASE}

// I need to fix a problem (introduced by MS) here. The first parameter can be a pointer
// (and is so defined) or can be a normal DWORD, depending on the dwFlags parameter.
// As usual, lpSrc has been translated to a var parameter. But this does not work in
// our case, hence the redeclaration of the function with a pointer as first parameter.

function TranslateCharsetInfoEx(lpSrc: NativeInt; out lpCs: TCharsetInfo; dwFlags: DWORD): BOOL; stdcall;
  external 'gdi32.dll' name 'TranslateCharsetInfo';

function GetCharSetFromLocale(Language: LCID; out FontCharSet: Byte): Boolean;
const
  TCI_SRCLOCALE = $1000;
var
  CP: Word;
  CSI: TCharsetInfo;
begin
  if not CheckWin32Version(5, 0) then // Win2k required
  begin
    // these versions of Windows don't support TCI_SRCLOCALE
    CP := CodePageFromLocale(Language);
    if CP = 0 then
      RaiseLastOSError;
    Result := TranslateCharsetInfoEx(CP, CSI, TCI_SRCCODEPAGE);
  end
  else
    Result := TranslateCharsetInfoEx(Language, CSI, TCI_SRCLOCALE);

  if Result then
    FontCharset := CSI.ciCharset;
end;

function CharSetFromLocale(Language: LCID): Byte;
begin
  if not GetCharSetFromLocale(Language, Result) then
    RaiseLastOSError;
end;

function CodePageFromLocale(Language: LCID): Word;
// determines the code page for a given locale
var
  Buf: array [0..6] of Char;
begin
  GetLocaleInfo(Language, LOCALE_IDefaultAnsiCodePage, Buf, 6);
  Result := StrToIntDef(Buf, GetACP);
end;

function KeyboardCodePage: Word;
begin
  Result := CodePageFromLocale(GetKeyboardLayout(0) and $FFFF);
end;

function KeyUnicode(C: Char): Char;
// converts the given character (as it comes with a WM_CHAR message) into its
// corresponding Unicode character depending on the active keyboard layout
begin
  MultiByteToWideChar(KeyboardCodePage, MB_USEGLYPHCHARS, @C, 1, @Result, 1);
end;

function CodeBlockRange(const CB: TUnicodeBlock): TUnicodeBlockRange;
// http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
begin
  Result := UnicodeBlockData[CB].Range;
end;


// Names taken from http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
function CodeBlockName(const CB: TUnicodeBlock): string;
begin
  Result := UnicodeBlockData[CB].Name;
end;

// Returns an ID for the Unicode code block to which C belongs.
// If C does not belong to any of the defined blocks then ubUndefined is returned.
// Note: the code blocks listed here are based on Unicode Version 5.0.0
function CodeBlockFromChar(const C: UCS4): TUnicodeBlock;
// http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
var
  L, H, I: TUnicodeBlock;
begin
  Result := ubUndefined;
  L := ubBasicLatin;
  H := High(TUnicodeBlock);
  while L <= H do
  begin
    I := TUnicodeBlock((Cardinal(L) + Cardinal(H)) shr 1);
    if (C >= UnicodeBlockData[I].Range.RangeStart) and (C <= UnicodeBlockData[I].Range.RangeEnd) then
    begin
      Result := I;
      Break;
    end
    else
    if C < UnicodeBlockData[I].Range.RangeStart then
    begin
      Dec(I);
      H := I;
    end
    else
    begin
      Inc(I);
      L := I;
    end;
  end;
end;


function CompareTextWin95(const W1, W2: string; Locale: LCID): NativeInt;
// special comparation function for Win9x since there's no system defined
// comparation function, returns -1 if W1 < W2, 0 if W1 = W2 or 1 if W1 > W2
var
  S1, S2: AnsiString;
  CP: Word;
  L1, L2: NativeInt;
begin
  L1 := Length(W1);
  L2 := Length(W2);
  SetLength(S1, L1);
  SetLength(S2, L2);
  CP := CodePageFromLocale(Locale);
  WideCharToMultiByte(CP, 0, PWideChar(W1), L1, PAnsiChar(S1), L1, nil, nil);
  WideCharToMultiByte(CP, 0, PWideChar(W2), L2, PAnsiChar(S2), L2, nil, nil);
  Result := CompareStringA(Locale, NORM_IGNORECASE, PAnsiChar(S1), Length(S1),
    PAnsiChar(S2), Length(S2)) - 2;
end;

function CompareTextWinNT(const W1, W2: string; Locale: LCID): NativeInt;
// Wrapper function for WinNT since there's no system defined comparation function
// in Win9x and we need a central comparation function for TWideStringList.
// Returns -1 if W1 < W2, 0 if W1 = W2 or 1 if W1 > W2
begin
  Result := CompareStringW(Locale, NORM_IGNORECASE, PWideChar(W1), Length(W1),
    PWideChar(W2), Length(W2)) - 2;
end;

function StringToWideStringEx(const S: AnsiString; CodePage: Word): string;
var
  InputLength,
  OutputLength: NativeInt;
begin
  InputLength := Length(S);
  OutputLength := MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, nil, 0);
  SetLength(Result, OutputLength);
  MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, PWideChar(Result), OutputLength);
end;

function WideStringToStringEx(const WS: string; CodePage: Word): AnsiString;
var
  InputLength,
  OutputLength: NativeInt;
begin
  InputLength := Length(WS);
  OutputLength := WideCharToMultiByte(CodePage, 0, PWideChar(WS), InputLength, nil, 0, nil, nil);
  SetLength(Result, OutputLength);
  WideCharToMultiByte(CodePage, 0, PWideChar(WS), InputLength, PAnsiChar(Result), OutputLength, nil, nil);
end;

function TranslateString(const S: AnsiString; CP1, CP2: Word): AnsiString;
begin
  Result:= WideStringToStringEx(StringToWideStringEx(S, CP1), CP2);
end;

function UCS4Array(Ch: UCS4): TUCS4Array;
begin
  SetLength(Result, 1);
  Result[0] := Ch;
end;

function UCS4ArrayConcat(Left, Right: UCS4): TUCS4Array;
begin
  SetLength(Result, 2);
  Result[0] := Left;
  Result[1] := Right;
end;

procedure UCS4ArrayConcat(var Left: TUCS4Array; Right: UCS4);
var
  I: NativeInt;
begin
  I := Length(Left);
  SetLength(Left, I + 1);
  Left[I] := Right;
end;

procedure UCS4ArrayConcat(var Left: TUCS4Array; const Right: TUCS4Array);
var
  I, J: NativeInt;
begin
  I := Length(Left);
  J := Length(Right);
  SetLength(Left, I + J);
  Move(Right[0], Left[I], J * SizeOf(Right[0]));
end;

function UCS4ArrayEquals(const Left: TUCS4Array; const Right: TUCS4Array): Boolean;
var
  I: NativeInt;
begin
  I := Length(Left);
  Result := I = Length(Right);
  while Result do
  begin
    Dec(I);
    Result := (I >= 0) and (Left[I] = Right[I]);
  end;
  Result := I < 0;
end;

function UCS4ArrayEquals(const Left: TUCS4Array; Right: UCS4): Boolean;
begin
  Result := (Length(Left) = 1) and (Left[0] = Right);
end;

function UCS4ArrayEquals(const Left: TUCS4Array; const Right: AnsiString): Boolean;
var
  I: NativeInt;
begin
  I := Length(Left);
  Result := I = Length(Right);
  while Result do
  begin
    Dec(I);
    Result := (I >= 0) and (Left[I] = Ord(Right[I + 1]));
  end;
  Result := I < 0;
end;

function UCS4ArrayEquals(const Left: TUCS4Array; Right: AnsiChar): Boolean;
begin
  Result := (Length(Left) = 1) and (Left[0] = Ord(Right));
end;

function GetUnicodeCategory(Code: UCS4): TCharacterCategories;
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000);

  // load property data if not already done
  if not CategoriesLoaded then
    LoadCharacterCategories;

  First := (Code shr 16) and $FF;
  Second := (Code shr 8) and $FF;
  Third := Code and $FF;
  if (Categories[First] <> nil) and (Categories[First, Second] <> nil) then
    Result := Categories[First, Second, Third]
  else
    Result := [];
end;

procedure PrepareUnicodeData;
// Prepares structures which are globally needed.
begin
  {$IFNDEF UNICODE_RTL_DATABASE}
  LoadInProgress := TCriticalSection.Create;
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;

procedure FreeUnicodeData;
// Frees all data which has been allocated and which is not automatically freed by Delphi.
begin
  {$IFNDEF UNICODE_RTL_DATABASE}
  FreeAndNil(LoadInProgress);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;

initialization
  PrepareUnicodeData;

finalization
  FreeUnicodeData;

end.
