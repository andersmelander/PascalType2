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
// A Unicode 2.0 codepoint - 32 bits wide
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

  TCompatibilityFormattingTags = set of TCompatibilityFormattingTag;


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
    //            3.11, section D117
    //            It is assumed that the input has already been normalized.
    //            The result is not normalized. TODO : Is this correct?
    //
    //------------------------------------------------------------------------------
    class procedure Normalize(var ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil); static;
    class function Decompose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter = nil): TPascalTypeCodePoints; static;
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
    class function IsRightToLeft(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsLeftToRight(ACodePoint: TPascalTypeCodePoint): boolean; static;
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

    class function IsDefaultIgnorable(ACodePoint: TPascalTypeCodePoint): boolean; static;

  private
  end;

//------------------------------------------------------------------------------

function UnicodeDecompose(const Codes: TPascalTypeCodePoints; Compatible: Boolean = False; Filter: TCodePointFilter =nil): TPascalTypeCodePoints;
function UnicodeCompose(const Codes: TPascalTypeCodePoints; Compatible: Boolean = False; Filter: TCodePointComposeFilter = nil): TPascalTypeCodePoints;

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
{$if defined(UNICODE_RAW_DATA)}
{$elseif defined(UNICODE_ZLIB_DATA)}
  ZLib,
{$ifend}
  System.Classes;

//------------------------------------------------------------------------------
//
//              Hangul
//
//------------------------------------------------------------------------------
type
  Hangul = record
    const
      // constants for hangul composition and hangul-to-jamo decomposition
      JamoLBase = $1100;             // Leading syllable
      JamoVBase = $1161;             // Vovel
      JamoTBase = $11A7;             // Trailing syllable

      JamoLCount = 19;
      JamoVCount = 21;
      JamoTCount = 28;

      JamoNCount = JamoVCount * JamoTCount;   // 588
      JamoSCount = JamoLCount * JamoNCount;   // 11172
      JamoVTCount = JamoVCount * JamoTCount;

      JamoLLimit = JamoLBase + JamoLCount;
      JamoVLimit = JamoVBase + JamoVCount;
      JamoTLimit = JamoTBase + JamoTCount;

      HangulSBase = $AC00;             // hangul syllables start code point
      HangulCount = JamoLCount * JamoVCount * JamoTCount;
      HangulLimit = HangulSBase + HangulCount; // $D7FF

    class function IsHangul(ACodePoint: TPascalTypeCodePoint): boolean; static;
    class function IsJamoL(ACodePoint: TPascalTypeCodePoint): Boolean; static;
    class function IsJamoV(ACodePoint: TPascalTypeCodePoint): Boolean; static;
    class function IsJamoT(ACodePoint: TPascalTypeCodePoint): Boolean; static;
    class function IsHangulLV(ACodePoint: TPascalTypeCodePoint): boolean; static;
  end;


type
  // Start and stop of a range of code points
  TRange = record
    Start: TPascalTypeCodePoint;
    Stop: TPascalTypeCodePoint;
  end;

  TRangeArray = TArray<TRange>;

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

    property Values[ACodePoint: TPascalTypeCodePoint]: T read GetValue write SetValue; default;
    property Loaded: boolean read FLoaded write FLoaded;
  end;

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
var
  Plane, Page, Chr: Byte;
begin
  Plane := (ACodePoint shr 16) and $FF;
  Page := (ACodePoint shr 8) and $FF;
  Chr := ACodePoint and $FF;

  if (Trie[Plane] <> nil) and (Trie[Plane, Page] <> nil) then
    Result := Trie[Plane, Page, Chr]
  else
    Result := Default(T);
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

procedure LoadCharacterCategories;
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

  ResourceStream := TResourceStream.Create(HInstance, 'CATEGORIES', 'UNICODEDATA');

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

        // 3) go through every range and add the current category to each code point
        for CodePoint := RangeStart to RangeStop do
        begin
          Categories := UnicodeCategories.GetPointer(CodePoint, True);

          // The array is allocated on the exact size, but the compiler generates
          // a 32 bit "BTS" instruction that accesses memory beyond the allocated block.
          if (CodePoint and $FF < $FF) then
            Include(Categories^, Category)
          else
            Categories^ := Categories^ + [Category];
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
    LoadCharacterCategories;

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
  Result := (ACodePoint >= Hangul.HangulSBase) and (ACodePoint < Hangul.HangulLimit);
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

class function PascalTypeUnicode.IsDefaultIgnorable(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  // From DerivedCoreProperties.txt in the Unicode database,
  // minus U+115F, U+1160, U+3164 and U+FFA0, which is what
  // Harfbuzz and Uniscribe do.

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

  ResourceStream := TResourceStream.Create(HInstance, 'COMBINING', 'UNICODEDATA');

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
  TDecomposition = record
    Canonical: boolean;
    Leaves: TPascalTypeCodePoints;
  end;
  PDecomposition = ^TDecomposition;

var
  // List of decompositions, organized as three stage matrix (a trie)
  // Note: There are two tables, one for canonical decompositions and the other one
  //       for compatibility decompositions.
  Decompositions: TUnicodeTrieEx<TDecomposition>;

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
  if (Decompositions.Loaded) then
    exit;
  Decompositions.Loaded := True;

  ResourceStream := TResourceStream.Create(HInstance, 'DECOMPOSITION', 'UNICODEDATA');

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
        Decomposition := Decompositions.GetPointer(CodePoint, True);
        Decomposition.Canonical := (TCompatibilityFormattingTag(Reader.ReadByte) = cftCanonical);
        SetLength(Decomposition.Leaves, Size);
        for j := 0 to Size - 1 do
        begin
          Stream.ReadBuffer(CodePoint, 3);
          Decomposition.Leaves[j] := CodePoint;
        end;
      end;
    end;
    Assert(Stream.Position = Stream.Size);
  finally
    Stream.Free;
  end;
end;

function UnicodeDecompose(const Codes: TPascalTypeCodePoints; Compatible: Boolean; Filter: TCodePointFilter): TPascalTypeCodePoints;
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
    TIndex: Integer;
  begin
    Dec(CodePoint, Hangul.HangulSBase);
    AddCodePoint(Hangul.JamoLBase + (CodePoint div Hangul.JamoNCount));
    AddCodePoint(Hangul.JamoVBase + ((CodePoint mod Hangul.JamoNCount) div Hangul.JamoTCount));
    TIndex := CodePoint mod Hangul.JamoTCount;
    if TIndex <> 0 then
      AddCodePoint(Hangul.JamoTBase + TIndex);
  end;

  procedure Decompose(ACodePoint: TPascalTypeCodePoint);
  var
    Decomposition: PDecomposition;
    CodePoint: TPascalTypeCodePoint;
  begin
    Decomposition := Decompositions.GetPointer(ACodePoint);
    if (Decomposition <> nil) and (Decomposition.Leaves <> nil) and (Compatible or Decomposition.Canonical) then
    begin
      for CodePoint in Decomposition.Leaves do
        Decompose(CodePoint);
      exit;
    end;

    AddCodePoint(ACodePoint);
  end;

var
  CodePoint: TPascalTypeCodePoint;
begin
  SetLength(Result, Length(Codes));

  OutputSize := 0;

  // Load decomposition data if not already done
  if not Decompositions.Loaded then
    LoadDecompositions;

  for CodePoint in Codes do
  begin
    Assert(CodePoint < $1000000);

    if (Assigned(Filter)) and (not Filter(CodePoint)) then
    begin
      AddCodePoint(CodePoint);
      continue;
    end;

    // If the CodePoint is hangul then decomposition is performed algorithmically
    if Hangul.IsHangul(CodePoint) then
    begin
      // Hangul syllable: Decompose algorithmically
      DecomposeHangul(CodePoint);
      continue;
    end else
      Decompose(CodePoint);
  end;

  SetLength(Result, OutputSize);
end;

class function PascalTypeUnicode.Decompose(const ACodePoints: TPascalTypeCodePoints; Filter: TCodePointFilter): TPascalTypeCodePoints;
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

  ResourceStream := TResourceStream.Create(HInstance, 'COMPOSITION', 'UNICODEDATA');

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

//------------------------------------------------------------------------------
//
//              Hangul
//
//------------------------------------------------------------------------------
class function Hangul.IsHangul(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := PascalTypeUnicode.IsHangul(ACodePoint);
end;

class function Hangul.IsHangulLV(ACodePoint: TPascalTypeCodePoint): boolean;
begin
  Result := IsHangul(ACodePoint) and ((ACodePoint-HangulSBase) mod JamoTCount = 0);
end;

class function Hangul.IsJamoL(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := (ACodePoint >= JamoLBase) and (ACodePoint < JamoLLimit);
end;

class function Hangul.IsJamoT(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := (ACodePoint >= JamoTBase) and (ACodePoint < JamoTLimit);
end;

class function Hangul.IsJamoV(ACodePoint: TPascalTypeCodePoint): Boolean;
begin
  Result := (ACodePoint >= JamoVBase) and (ACodePoint < JamoVLimit);
end;

initialization
finalization
  CanonicalCompositionLookup.Free;
  CompatibleCompositionLookup.Free;
end.
