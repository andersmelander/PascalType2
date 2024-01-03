unit PascalType.Unicode.Builder.Categories;

interface

uses
  Generics.Collections,
  PascalType.Unicode,
  PascalType.Unicode.Builder.CharacterSet,
  PascalType.Unicode.Builder.ResourceWriter;

type
  CategoryString = record
    Name: string;
    Category: TCharacterCategory;
  end;

const
  // List of categories expected to be found in the Unicode Character Database
  // including some implementation specific properties.
  // Note: there are multiple definitions which describe the same property (because they are used in the general
  //       categories as well as bidirectional categories (while we store both types as one).
  //       These are:
  //       - Mn, NSM for non-spacing mark
  //       - Zp, B for paragraph separator
  CategoriesStrings: array[0..94] of CategoryString = (
    // normative categories
    (Name: 'Lu';  Category: ccLetterUppercase),           // letter, upper case
    (Name: 'Ll';  Category: ccLetterLowercase),           // letter, lower case
    (Name: 'Lt';  Category: ccLetterTitlecase),           // letter, title case
    (Name: 'Mn';  Category: ccMarkNonSpacing),            // mark, non spacing
    (Name: 'NSM'; Category: ccMarkNonSpacing),
    (Name: 'Mc';  Category: ccMarkSpacingCombining),      // mark, spacing combining
    (Name: 'Me';  Category: ccMarkEnclosing),             // mark, enclosing
    (Name: 'Nd';  Category: ccNumberDecimalDigit),        // number, decimal digit
    (Name: 'Nl';  Category: ccNumberLetter),              // number, letter
    (Name: 'No';  Category: ccNumberOther),               // number, other
    (Name: 'Zs';  Category: ccSeparatorSpace),            // separator, space
    (Name: 'Zl';  Category: ccSeparatorLine),             // separator, line
    (Name: 'Zp';  Category: ccSeparatorParagraph),        // separator, paragraph
    (Name: 'B';   Category: ccSeparatorParagraph),
    (Name: 'Cc';  Category: ccOtherControl),              // other, control
    (Name: 'Cf';  Category: ccOtherFormat),               // other, format
    (Name: 'Cs';  Category: ccOtherSurrogate),            // other, surrogate
    (Name: 'Co';  Category: ccOtherPrivate),              // other, private use
    (Name: 'Cn';  Category: ccOtherUnassigned),           // other, not assigned
    // informative categories
    (Name: 'Lm';  Category: ccLetterModifier),            // letter, modifier
    (Name: 'Lo';  Category: ccLetterOther),               // letter, other
    (Name: 'Pc';  Category: ccPunctuationConnector),      // punctuation, connector
    (Name: 'Pd';  Category: ccPunctuationDash),           // punctuation, dash
    (Name: 'Dash'; Category: ccPunctuationDash),
    (Name: 'Ps';  Category: ccPunctuationOpen),           // punctuation, open
    (Name: 'Pe';  Category: ccPunctuationClose),          // punctuation, close
    (Name: 'Pi';  Category: ccPunctuationInitialQuote),   // punctuation, initial quote
    (Name: 'Pf';  Category: ccPunctuationFinalQuote),     // punctuation, final quote
    (Name: 'Po';  Category: ccPunctuationOther),          // punctuation, other
    (Name: 'Sm';  Category: ccSymbolMath),                // symbol, math
    (Name: 'Sc';  Category: ccSymbolCurrency),            // symbol, currency
    (Name: 'Sk';  Category: ccSymbolModifier),            // symbol, modifier
    (Name: 'So';  Category: ccSymbolOther),               // symbol, other
    // bidirectional categories
    (Name: 'L';   Category: ccLeftToRight),               // left-to-right
    (Name: 'LRE'; Category: ccLeftToRightEmbedding),      // left-to-right embedding
    (Name: 'LRO'; Category: ccLeftToRightOverride),       // left-to-right override
    (Name: 'R';   Category: ccRightToLeft),               // right-to-left
    (Name: 'AL';  Category: ccRightToLeftArabic),         // right-to-left arabic
    (Name: 'RLE'; Category: ccRightToLeftEmbedding),      // right-to-left embedding
    (Name: 'RLO'; Category: ccRightToLeftOverride),       // right-to-left override
    (Name: 'PDF'; Category: ccPopDirectionalFormat),      // pop directional format
    (Name: 'EN';  Category: ccEuropeanNumber),            // european number
    (Name: 'ES';  Category: ccEuropeanNumberSeparator),   // european number separator
    (Name: 'ET';  Category: ccEuropeanNumberTerminator),  // european number terminator
    (Name: 'AN';  Category: ccArabicNumber),              // arabic number
    (Name: 'CS';  Category: ccCommonNumberSeparator),     // common number separator
    (Name: 'BN';  Category: ccBoundaryNeutral),           // boundary neutral
    (Name: 'S';   Category: ccSegmentSeparator),          // segment separator
    (Name: 'WS';  Category: ccWhiteSpace),                // white space
    (Name: 'White_Space'; Category: ccWhiteSpace),
    (Name: 'ON';  Category: ccOtherNeutrals),             // other neutrals
    (Name: 'LRI'; Category: ccLeftToRightIsolate),
    (Name: 'RLI'; Category: ccRightToLeftIsolate),
    (Name: 'FSI'; Category: ccFirstStrongIsolate),
    (Name: 'PDI'; Category: ccPopDirectionalIsolate),
    // self defined categories, they do not appear in the Unicode data file
    (Name: 'Cm';  Category: ccComposed),                  // composed (can be decomposed)
    (Name: 'Nb';  Category: ccNonBreaking),               // non-breaking
    (Name: 'Sy';  Category: ccSymmetric),                 // symmetric (has left and right forms)
    (Name: 'Hd';  Category: ccHexDigit),                  // hex digit
    (Name: 'Hex_Digit'; Category: ccHexDigit),
    (Name: 'Qm';  Category: ccQuotationMark),             // quote marks
    (Name: 'Quotation_Mark'; Category: ccQuotationMark),
    (Name: 'Mr';  Category: ccMirroring),                 // mirroring
    (Name: 'Cp';  Category: ccAssigned),                  // assigned character (there is a definition in the Unicode standard)
    //'Luu' // letter unique upper case
    (Name: 'Bidi_Control'; Category: ccBidiControl),
    (Name: 'Join_Control'; Category: ccJoinControl),
    (Name: 'Hyphen'; Category: ccHyphen),
    (Name: 'Terminal_Punctuation'; Category: ccTerminalPunctuation),
    (Name: 'Other_Math'; Category: ccOtherMath),
    (Name: 'ASCII_Hex_Digit'; Category: ccASCIIHexDigit),
    (Name: 'Other_Alphabetic'; Category: ccOtherAlphabetic),
    (Name: 'Ideographic'; Category: ccIdeographic),
    (Name: 'Diacritic'; Category: ccDiacritic),
    (Name: 'Extender'; Category: ccExtender),
    (Name: 'Other_Lowercase'; Category: ccOtherLowercase),
    (Name: 'Other_Uppercase'; Category: ccOtherUppercase),
    (Name: 'Noncharacter_Code_Point'; Category: ccNonCharacterCodePoint),
    (Name: 'Other_Grapheme_Extend'; Category: ccOtherGraphemeExtend),
    (Name: 'IDS_Binary_Operator'; Category: ccIDSBinaryOperator),
    (Name: 'IDS_Trinary_Operator'; Category: ccIDSTrinaryOperator),
    (Name: 'Radical'; Category: ccRadical),
    (Name: 'Unified_Ideograph'; Category: ccUnifiedIdeograph),
    (Name: 'Other_Default_Ignorable_Code_Point'; Category: ccOtherDefaultIgnorableCodePoint),
    (Name: 'Deprecated'; Category: ccDeprecated),
    (Name: 'Soft_Dotted'; Category: ccSoftDotted),
    (Name: 'Logical_Order_Exception'; Category: ccLogicalOrderException),
    (Name: 'Other_ID_Start'; Category: ccOtherIDStart),
    (Name: 'Other_ID_Continue'; Category: ccOtherIDContinue),
    (Name: 'STerm'; Category: ccSTerm),
    (Name: 'Variation_Selector'; Category: ccVariationSelector),
    (Name: 'Pattern_White_Space'; Category: ccPatternWhiteSpace),
    (Name: 'Pattern_Syntax'; Category: ccPatternSyntax),
    (Name: 'Sentence_Terminal'; Category: ccSentenceTerminal),
    (Name: 'Prepended_Concatenation_Mark'; Category: ccPrependedQuotationMark),
    (Name: 'Regional_Indicator'; Category: ccRegionalIndicator)
    );

const
  DecompositionTags: array [TCompatibilityFormattingTag] of string =
    ('',            // cftCanonical
     '<font>',      // cftFont
     '<noBreak>',   // cftNoBreak
     '<initial>',   // cftInitial
     '<medial>',    // cftMedial
     '<final>',     // cftFinal
     '<isolated>',  // cftIsolated
     '<circle>',    // cftCircle
     '<super>',     // cftSuper
     '<sub>',       // cftSub
     '<vertical>',  // cftVertical
     '<wide>',      // cftWide
     '<narrow>',    // cftNarrow
     '<small>',     // cftSmall
     '<square>',    // cftSquare
     '<fraction>',  // cftFraction
     '<compat>');   // cftCompat


//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeCategories
//
//----------------------------------------------------------------------------------------------------------------------
type
  TUnicodeCategories = record
    FCategories: TCharacterSetList; // Actually array[TCharacterCategory] of TCharacterSet;
  public
    procedure Add(Code: TPascalTypeCodePoint; const CategoryID: string); overload;
    procedure Add(Code: TPascalTypeCodePoint; Category: TCharacterCategory); overload;
    procedure AddRange(Start, Stop: TPascalTypeCodePoint; Category: TCharacterCategory); overload;
    procedure AddRange(Start, Stop: TPascalTypeCodePoint; const CategoryID: string); overload;

    procedure WriteAsResource(AResourceWriter: TResourceWriter);
  end;


//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  PascalType.Unicode.Builder.Logger;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCategories.WriteAsResource(AResourceWriter: TResourceWriter);
begin
  FCategories.WriteAsResource(AResourceWriter);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCategories.AddRange(Start, Stop: TPascalTypeCodePoint; Category: TCharacterCategory);
begin
  for var Code := Start to Stop do
    FCategories.Data[Ord(Category)].SetCharacter(Code);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCategories.AddRange(Start, Stop: TPascalTypeCodePoint; const CategoryID: string);
// Adds a range of code points to the FCategories structure.
begin
  // find category
  for var Index := Low(CategoriesStrings) to High(CategoriesStrings) do
    if CategoriesStrings[Index].Name = CategoryID then
    begin
      AddRange(Start, Stop, CategoriesStrings[Index].Category);
      Exit;
    end;

  Logger.FatalError('No unicode category for ID "' + CategoryID + '"');
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCategories.Add(Code: TPascalTypeCodePoint; Category: TCharacterCategory);
begin
  FCategories.Data[Ord(Category)].SetCharacter(Code);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCategories.Add(Code: TPascalTypeCodePoint; const CategoryID: string);
// Adds a range of code points to the FCategories structure.
var
  Index: Integer;
begin
  // find category
  for Index := Low(CategoriesStrings) to High(CategoriesStrings) do
    if CategoriesStrings[Index].Name = CategoryID then
    begin
      Add(Code, CategoriesStrings[Index].Category);
      Exit;
    end;

  Logger.FatalError('No unicode category for ID "' + CategoryID + '"');
end;

//----------------------------------------------------------------------------------------------------------------------

end.
