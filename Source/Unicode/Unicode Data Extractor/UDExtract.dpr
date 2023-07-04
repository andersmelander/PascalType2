program UDExtract;

{$APPTYPE CONSOLE}

// Application to convert a Unicode database file into a resource script compilable
// to a resource file. For usage see procedure PrintUsage.

uses
  Generics.Collections,
  Generics.Defaults,
  IOUtils,
  Classes,
  SysUtils,
  JclCompression,
  BZip2,
  ZLibh,
  JclBase,
  JclLogic,
  JclStrings,
  PascalType.Unicode in '..\..\PascalType.Unicode.pas';

const
  RESOURCETYPE = 'UNICODEDATA';

type
  TDecompositions = array of Cardinal;

  PDecomposition = ^TDecomposition;

  TDecomposition = record
  private
    procedure SetDecompositions(const Value: TDecompositions);
    function GetPointer: PDecomposition;
  public
    Code: Cardinal;
    Tag: TCompatibilityFormattingTag;
    _Decompositions: TDecompositions;
    property Decompositions: TDecompositions read _Decompositions write SetDecompositions;
    property PItem: PDecomposition read GetPointer;
  end;

  // collect of case mappings for each code point which is cased
  TCase = record
    Code: Cardinal;
    Fold,               // normalized case for case independent string comparison (e.g. for "ß" this is "ss")
    Lower,              // lower case (e.g. for "ß" this is "ß")
    Title,              // tile case (used mainly for compatiblity, ligatures etc., e.g. for "ß" this is "Ss")
    Upper: TUCS4Array;  // upper cae (e.g. for "ß" this is "SS")
  end;

  // structures for handling numbers
  TCodeIndex = record
    Code,
    Index: Cardinal;
  end;

  TNumber = record
    Numerator,
    Denominator: Int64;
  end;

  // start and stop of a range of code points
  TCharacterSet = array [0..$1000000 div BitsPerByte] of Byte;

  // start and stop of a range of code points
  TRange = record
    Start,
    Stop: Cardinal;
  end;

  TRangeArray = array of TRange;

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

var
  SourceFolder: string;
  SourceFileName: string = 'UnicodeData.txt';
  SpecialCasingFileName: string = 'SpecialCasing.txt';
  ArabicShapingFileName: string = 'ArabicShaping.txt';
  ScriptsFileName: string = 'Scripts.txt';
  AliasFileName: string = 'PropertyValueAliases.txt';
  CaseFoldingFileName: string = 'PropertyValueAliases.txt';
  DerivedNormalizationPropsFileName: string = 'DerivedNormalizationProps.txt';
  PropListFileName: string = 'PropList.txt';
  TargetFileName: string = 'unicode.rc';
  Verbose: Boolean;
  ZLibCompress: Boolean;
  BZipCompress: Boolean;

  // character category ranges
  Categories: array[TCharacterCategory] of TCharacterSet;
  // canonical combining classes
  CCCs: array[Byte] of TCharacterSet;
  // list of decomposition
  Decompositions: TList<TDecomposition>;
  // array to hold the number equivalents for specific codes (sorted by code)
  NumberCodes: array of TCodeIndex;
  // array of numbers used in NumberCodes
  Numbers: array of TNumber;
  // array for all case mappings (including 1 to many casing if a special casing source file was given)
  CaseMapping: array of TCase;
  // array of compositions (somehow the same as Decompositions except sorted by decompositions and removed elements)
  Compositions: TList<PDecomposition>;
  // array of composition exception ranges
  CompositionExceptions: TCharacterSet;

  // Arabic shaping classes
  ArabicShapingClasses: array[Byte] of TCharacterSet;

  // Scripts
  Scripts: array[TUnicodeScript] of TCharacterSet;

  // PropertyValueAliases
type
  TPropertyValueAliases = TDictionary<string, string>;
var
  PropertyValueAliases: TObjectDictionary<string, TPropertyValueAliases>;

//----------------------------------------------------------------------------------------------------------------------

procedure FatalError(const S: string);
begin
  if Verbose then
  begin
    Writeln;
    Writeln('[Fatal error] ' + S);
  end;
  ExitCode := 4;
  Abort;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure Warning(const S: string);
begin
  if Verbose then
  begin
    Writeln;
    Writeln('[Warning] ' + S);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function IsHexDigit(C: Char): Boolean;
begin
  Result := CharIsHexDigit(C);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SetCharacter(var CharacterSet: TCharacterSet; Code: Cardinal);
begin
  SetBitBuffer(CharacterSet[0], Code);
end;

//----------------------------------------------------------------------------------------------------------------------

function TestCharacter(const CharacterSet: TCharacterSet; Code: Cardinal): Boolean;
begin
  Result := TestBitBuffer(CharacterSet[0], Code);
end;

//----------------------------------------------------------------------------------------------------------------------

function FindNextCharacterRange(const CharacterSet: TCharacterSet; var Start, Stop: Cardinal): Boolean;
var
  ByteIndex: Cardinal;
begin
  ByteIndex := Start div BitsPerByte;
  if (ByteIndex < ($1000000 div BitsPerByte)) and (CharacterSet[ByteIndex] = 0) then
  begin
    while (ByteIndex < ($1000000 div BitsPerByte)) and (CharacterSet[ByteIndex] = 0) do
      Inc(ByteIndex);
    Start := ByteIndex * BitsPerByte;
  end;

  while (Start < $1000000) and not TestBitBuffer(CharacterSet[0], Start) do
    Inc(Start);

  if Start < $1000000 then
  begin
    Result := True;
    Stop := Start;

    ByteIndex := Stop div BitsPerByte;
    if (ByteIndex < ($1000000 div BitsPerByte)) and (CharacterSet[ByteIndex] = $FF) then
    begin
      while (ByteIndex < ($1000000 div BitsPerByte)) and (CharacterSet[ByteIndex] = $FF) do
        Inc(ByteIndex);
      Stop := ByteIndex * BitsPerByte;
    end;

    while (Stop < $1000000) and TestBitBuffer(CharacterSet[0], Stop) do
      Inc(Stop);
    if Stop <= $1000000 then
      Dec(Stop);
  end
  else
    Result := False;
end;

//----------------------------------------------------------------------------------------------------------------------

function FindCharacterRanges(const CharacterSet: TCharacterSet): TRangeArray;
var
  Capacity, Index: Integer;
  Start, Stop: Cardinal;
begin
  Capacity := 0;
  Index := 0;
  Start := 0;
  Stop := 0;
  while FindNextCharacterRange(CharacterSet, Start, Stop) do
  begin
    if Index >= Capacity then
    begin
      Inc(Capacity, 64);
      SetLength(Result, Capacity);
    end;
    Result[Index].Start := Start;
    Result[Index].Stop := Stop;
    Start := Stop + 1;
    Inc(Index);
  end;
  SetLength(Result, Index);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddRangeToCategories(Start, Stop: Cardinal; Category: TCharacterCategory); overload;
var
  Code: Integer;
begin
  for Code := Start to Stop do
    SetCharacter(Categories[Category], Code);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddRangeToCategories(Start, Stop: Cardinal; CategoryID: string); overload;
// Adds a range of code points to the categories structure.
var
  Index: Integer;
begin
  // find category
  for Index := Low(CategoriesStrings) to High(CategoriesStrings) do
    if CategoriesStrings[Index].Name = CategoryID then
    begin
      AddRangeToCategories(Start, Stop, CategoriesStrings[Index].Category);
      Exit;
    end;
  FatalError('No unicode category for ID "' + CategoryID + '"');
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddToCategories(Code: Cardinal; Category: TCharacterCategory); overload;
begin
  SetCharacter(Categories[Category], Code);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddToCategories(Code: Cardinal; CategoryID: string); overload;
// Adds a range of code points to the categories structure.
var
  Index: Integer;
begin
  // find category
  for Index := Low(CategoriesStrings) to High(CategoriesStrings) do
    if CategoriesStrings[Index].Name = CategoryID then
    begin
      AddToCategories(Code, CategoriesStrings[Index].Category);
      Exit;
    end;
  FatalError('No unicode category for ID "' + CategoryID + '"');
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddCanonicalCombiningClass(Code, CCClass: Cardinal);
begin
  // most of the code points have a combining class of 0 (so to speak the default class)
  // hence we don't need to store them
  if CCClass > 0 then
    SetCharacter(CCCs[CCClass], Code);
end;

procedure AddArabicShapingClass(Code, AClass: Cardinal);
begin
  if AClass > 0 then
    SetCharacter(ArabicShapingClasses[AClass], Code);
end;

function ResolveAlias(const Category, Value: string): string;
var
  AliasCategory: TPropertyValueAliases;
begin
  if (not PropertyValueAliases.TryGetValue(Category, AliasCategory)) or
    (not AliasCategory.TryGetValue(Value, Result)) then
    Result := Value;
end;

procedure AddScript(FirstCode, LastCode: Cardinal; AScript: TUnicodeScript);
begin
  if AScript <> usZzzz then
    while (FirstCode <= LastCode) do
    begin
      SetCharacter(Scripts[AScript], FirstCode);
      Inc(FirstCode);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function MakeNumber(Num, Denom: Int64): Integer;
// adds a number if it does not already exist and returns its index value
var
  I: Integer;
begin
  Result := -1;
  // determine if the number already exists
  for I := 0 to  High(Numbers) do
    if (Numbers[I].Numerator = Num) and (Numbers[I].Denominator = Denom) then
    begin
      Result := I;
      Break;
    end;

  if Result = -1 then
  begin
    Result := Length(Numbers);
    SetLength(Numbers, Result + 1);

    Numbers[Result].Numerator := Num;
    Numbers[Result].Denominator := Denom;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddNumber(Code: Cardinal; Num, Denom: Int64);
var
  I, J: Integer;
begin
  // Insert the Code in order.
  I := 0;
  J := Length(NumberCodes);
  while (I < J) and (Code > NumberCodes[I].Code) do
    Inc(I);

  // Handle the case of the codes matching and simply replace the number that was there before.
  if (I < J) and (Code = NumberCodes[I].Code) then
    NumberCodes[I].Index := MakeNumber(Num, Denom)
  else
  begin
    // Resize the array if necessary.
    SetLength(NumberCodes, J + 1);

    // Shift things around to insert the Code if necessary.
    if I < J then
    begin
      Move(NumberCodes[I], NumberCodes[I + 1], (J - I) * SizeOf(TCodeIndex));
      FillChar(NumberCodes[I], SizeOf(TCodeIndex), 0);
    end;
    NumberCodes[I].Code := Code;
    NumberCodes[I].Index := MakeNumber(Num, Denom);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddDecomposition(Code: Cardinal; Tag: TCompatibilityFormattingTag; Decomposition: TDecompositions);
var
  I: Integer;
  Item: TDecomposition;
begin
  AddToCategories(Code, ccComposed);

(*
  // locate the insertion point for the code
  I := 0;
  J := Length(Decompositions);
  while (I < J) and (Code > Decompositions[I].Code) do
    Inc(I);
*)

  Item.Code := Code;
  Item.Tag := Tag;
  Item.Decompositions := Copy(Decomposition);

  Decompositions.BinarySearch(Item, i, TComparer<TDecomposition>.Construct(
    function(const A, B: TDecomposition): integer
    begin
      if (A.Code < B.Code) then
        Result := -1
      else
      if (A.Code > B.Code) then
        Result := 1
      else
      if (A.Tag = cftCanonical) and (B.Tag <> cftCanonical) then
        Result := -1
      else
      if (A.Tag <> cftCanonical) and (B.Tag = cftCanonical) then
        Result := 1
      else
        Result := 0;
    end));

  Decompositions.Insert(i, Item);

(*
  if (I = J) or (Decompositions[I].Code <> Code) then
  begin
    // allocate space for a new decomposition
    SetLength(Decompositions, J + 1);

    if I < J then
    begin
      // shift the Decompositions up by one if the codes don't match
      Move(Decompositions[I], Decompositions[I + 1], (J - I) * SizeOf(TDecomposition));
      FillChar(Decompositions[I], SizeOf(TDecomposition), 0);
    end;
  end;

  // insert or replace a decomposition
  if Length(Decompositions[I].Decompositions) <> Length(Decomposition) then
    SetLength(Decompositions[I].Decompositions, Length(Decomposition));

  Decompositions[I].Code := Code;
  Decompositions[I].Tag := Tag;
  Move(Decomposition[0], Decompositions[I].Decompositions[0], Length(Decomposition) * SizeOf(Cardinal));
*)
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddRangeToCompositionExclusions(Start, Stop: Cardinal);
var
  Code: Integer;
begin
  for Code := Start to Stop do
    SetCharacter(CompositionExceptions, Code);
end;

//----------------------------------------------------------------------------------------------------------------------

function FindOrAddCaseEntry(Code: Cardinal): Integer;
// Used to look up the given code in the case mapping array. If no entry with the given code
// exists then it is added implicitely.
var
  J: Integer;
begin
  Result := 0;
  J := Length(CaseMapping);
  while (Result < J) and (CaseMapping[Result].Code < Code) do
    Inc(Result);

  // this code is not yet in the case mapping table
  if (Result = J) or (CaseMapping[Result].Code <> Code) then
  begin
    SetLength(CaseMapping, J + 1);

    // locate the insertion point
    Result := 0;
    while (Result < J) and (Code > CaseMapping[Result].Code) do
      Inc(Result);
    if Result < J then
    begin
      // shift the array up by one
      Move(CaseMapping[Result], CaseMapping[Result + 1], (J - Result) * SizeOf(TCase));
      FillChar(CaseMapping[Result], SizeOf(TCase), 0);
    end;
    Casemapping[Result].Code := Code;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddFoldCase(Code: Cardinal; FoldMapping: TUCS4Array);
var
  I: Integer;
begin
  I := FindOrAddCaseEntry(Code);
  if Length(CaseMapping[I].Fold) = 0 then
    CaseMapping[I].Fold := Copy(FoldMapping, 0, Length(FoldMapping))
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddLowerCase(Code: Cardinal; Lower: TUCS4Array);
var
  I: Integer;
begin
  I := FindOrAddCaseEntry(Code);
  if Length(CaseMapping[I].Lower) = 0 then
    CaseMapping[I].Lower := Copy(Lower, 0, Length(Lower))
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddUpperCase(Code: Cardinal; Upper: TUCS4Array);
var
  I: Integer;
begin
  I := FindOrAddCaseEntry(Code);
  if Length(CaseMapping[I].Upper) = 0 then
    CaseMapping[I].Upper := Copy(Upper, 0, Length(Upper))
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AddTitleCase(Code: Cardinal; Title: TUCS4Array);
var
  I: Integer;
begin
  I := FindOrAddCaseEntry(Code);
  if Length(CaseMapping[I].Title) = 0 then
    CaseMapping[I].Title := Copy(Title, 0, Length(Title))
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SplitLine(const Line: string; Elements: TStringList);
// splits the given string into parts which are separated by semicolon and fills Elements
// with the partial strings
var
  Head,
  Tail: PChar;
  S: string;
  
begin
  Elements.Clear;
  Head := PChar(Line);
  while Head^ <> #0 do
  begin
    Tail := Head;
    // look for next semicolon or string end (or comment identifier)
    while (Tail^ <> ';') and (Tail^ <> '#') and (Tail^ <> #0) do
      Inc(Tail);
    SetString(S, Head, Tail - Head);
    Elements.Add(Trim(S));
    // ignore all characters in a comment 
    if (Tail^ = '#') or (Tail^ = #0) then
      Break;
    Head := Tail + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SplitCodes(const Line: string; var Elements: TUCS4Array);
// splits S, which may contain space delimited hex strings, into single parts
// and fills Elements
var
  Head,
  Tail: PChar;
  S: string;
  I: Integer;

begin
  Elements := nil;
  Head := PChar(Line);
  while Head^ <> #0 do
  begin
    Tail := Head;
    while IsHexDigit(Tail^) do
      Inc(Tail);
    SetString(S, Head, Tail - Head);
    if Length(S) > 0 then
    begin
      I := Length(Elements);
      SetLength(Elements, I + 1);
      Elements[I] := StrToInt('$' + S);
    end;
    // skip spaces
    while Tail^ = ' ' do
      Inc(Tail);
    if Tail^ = #0 then
     Break;
    Head := Tail;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParseData;
// ParseData takes the source file and extracts all relevant data into internal structures to be
// used when creating the resource script.
var
  Lines,
  Line,
  SymCharacters,
  DecompositionsStr,
  NumberStr: TStringList;
  I, J, SymIndex: Integer;
  RangePending: Boolean;
  StartCode,
  EndCode: Cardinal;
  K, Tag: TCompatibilityFormattingTag;
  Name, SymName: string;
  Decompositions: TDecompositions;

  // number representation
  Nominator,
  Denominator: Int64;

  // case mapping
  AMapping: TUCS4Array;

begin
  SourceFileName := TPath.Combine(SourceFolder, SourceFileName);

  if (not TFile.Exists(SourceFileName)) then
  begin
    if Verbose then
      Writeln(Format('[Fatal error] ''%s'' not found', [SourceFileName]));
    Halt(1);
  end;

  if Verbose then
  begin
    Writeln;
    Writeln('Reading data from ' + SourceFileName + ':');
  end;

  Lines := nil;
  SymCharacters := nil;
  Line := nil;
  DecompositionsStr := nil;
  NumberStr := nil;
  try
    Lines := TStringList.Create;
    SymCharacters := TStringList.Create;
    Line := TStringList.Create;
    DecompositionsStr := TStringList.Create;
    NumberStr := TStringList.Create;

    // Unicode data files are about 600K in size, so don't hesitate and load them in one rush.
    Lines.LoadFromFile(SourceFileName);

    // Go for each line, organization is one line for a code point or two consecutive lines
    // for a range of code points.
    RangePending := False;
    StartCode := 0;
    for I := 0 to Lines.Count - 1 do
    begin
      SplitLine(Lines[I], Line);
      // continue only if the line is not empty
      if Line.Count > 1 then
      begin
        Name := UpperCase(Line[1]);
        // Line contains now up to 15 entries, starting with the code point value
        if RangePending then
        begin
          // last line was a range start, so this one must be the range end
          if Pos(', LAST>', Name) = 0 then
            FatalError(Format('Range end expected in line %d.', [I + 1]));
          EndCode := StrToInt('$' + Line[0]);

          // register general category
          AddRangeToCategories(StartCode, EndCode, Line[2]);

          // register bidirectional category
          AddRangeToCategories(StartCode, EndCode, Line[4]);

          // mark the range as containing assigned code points
          AddRangeToCategories(StartCode, EndCode, ccAssigned);
          RangePending := False;
        end
        else
        begin
          StartCode := StrToInt('$' + Line[0]);
          // check for the start of a range
          if Pos(', FIRST>', Name) > 0 then
            RangePending := True
          else
          begin
            // normal case, one code point must be parsed

            // 1) categorize code point as being assinged
            AddToCategories(StartCode, ccAssigned);

            // 2) find symmetric shapping characters
            // replace LEFT by RIGHT and vice-versa
            SymName := StringReplace(Name, 'LEFT', 'LLEEFFTT', [rfReplaceAll]);
            SymName := StringReplace(SymName, 'RIGHT', 'LEFT', [rfReplaceAll]);
            SymName := StringReplace(SymName, 'LLEEFFTT', 'RIGHT', [rfReplaceAll]);
            if Name <> SymName then
            begin
              SymIndex := SymCharacters.IndexOf(SymName);
              if SymIndex >= 0 then
              begin
                AddToCategories(StartCode, ccSymmetric);
                AddToCategories(Cardinal(SymCharacters.Objects[SymIndex]), ccSymmetric);
              end
              else
                SymCharacters.AddObject(Name, TObject(StartCode));
            end;

            if Line.Count < 3 then
              Continue;
            // 3) categorize the general character class
            AddToCategories(StartCode, Line[2]);

            if Line.Count < 4 then
              Continue;
            // 4) register canonical combining class
            AddCanonicalCombiningClass(StartCode, StrToInt(Line[3]));

            if Line.Count < 5 then
              Continue;
            // 5) categorize the bidirectional character class
            AddToCategories(StartCode, Line[4]);

            if Line.Count < 6 then
              Continue;
            // 6) if the character can be decomposed then keep its decomposed parts
            //    and add it to the can-be-decomposed category
            StrToStrings(Line[5], NativeSpace, DecompositionsStr, False);
            Tag := cftCanonical;
            if (DecompositionsStr.Count > 0) and (Pos('<', DecompositionsStr.Strings[0]) > 0) then
            begin
              for K := Low(DecompositionTags) to High(DecompositionTags) do
              begin
                if DecompositionTags[K] = DecompositionsStr.Strings[0] then
                begin
                  Tag := K;
                  Break;
                end;
              end;
              if Tag = cftCanonical then
                FatalError('Unknown decomposition tag ' + DecompositionsStr.Strings[0]);
              if Tag = cftNoBreak then
                AddToCategories(StartCode, ccNonBreaking);
              DecompositionsStr.Delete(0);
            end;
            if (DecompositionsStr.Count > 0) and (Pos('<', DecompositionsStr.Strings[0]) = 0) then
            begin
              // consider only canonical decomposition mappings
              SetLength(Decompositions, DecompositionsStr.Count);
              for J := 0 to DecompositionsStr.Count - 1 do
                Decompositions[J] := StrToInt('$' + DecompositionsStr.Strings[J]);

              // If there is more than one code in the temporary decomposition
              // array then add the character with its decomposition.
              // (outchy) latest unicode data have aliases to link items having the same decompositions
              //if DecompTempSize > 1 then
              AddDecomposition(StartCode, Tag, Decompositions);
            end;

            if Line.Count < 9 then
              Break;
            // 7) examine if there is a numeric representation of this code
            StrToStrings(Line[8], '/', NumberStr, False);
            if NumberStr.Count = 1 then
            begin
              Nominator := StrToInt64(NumberStr.Strings[0]);
              Denominator := 1;
              AddNumber(StartCode, Nominator, Denominator);
            end
            else
            if NumberStr.Count = 2 then
            begin
              Nominator := StrToInt64(NumberStr.Strings[0]);
              Denominator := StrToInt64(NumberStr.Strings[1]);
              AddNumber(StartCode, Nominator, Denominator);
            end
            else
            if NumberStr.Count <> 0 then
              FatalError('Unknown number ' + Line[8]);

            if Line.Count < 10 then
              Continue;
            // 8) read mirrored character
            SymName := Line[9];
            if SymName = 'Y' then
              AddToCategories(StartCode, ccMirroring)
            else
            if SymName <> 'N' then
              FatalError('Unknown mirroring character');

            if Line.Count < 13 then
              Continue;
            SetLength(AMapping, 1);
            // 9) read simple upper case mapping (only 1 to 1 mappings)
            if Length(Line[12]) > 0 then
            begin
              AMapping[0] := StrToInt('$' + Line[12]);
              AddUpperCase(StartCode, AMapping);
            end;

            if Line.Count < 14 then
              Continue;
            // 10) read simple lower case mapping
            if Length(Line[13]) > 0 then
            begin
              AMapping[0] := StrToInt('$' + Line[13]);
              AddLowerCase(StartCode, AMapping);
            end;

            if Line.Count < 15 then
              Continue;
            // 11) read title case mapping
            if Length(Line[14]) > 0 then
            begin
              AMapping[0] := StrToInt('$' + Line[14]);
              AddTitleCase(StartCode, AMapping);
            end;
          end;
        end;
      end;
      if Verbose then
        Write(Format(#13'  %d%% done', [Round(100 * I / Lines.Count)]));
    end;
  finally
    Lines.Free;
    Line.Free;
    SymCharacters.Free;
    DecompositionsStr.Free;
    NumberStr.Free;
  end;
  if Verbose then
    Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParseSpecialCasing;
// One-to-many case mappings are given by a separate file which is in a different format
// than the Unicode data file. This procedure parses this file and adds those extended mappings
// to the internal array.
var
  Lines,
  Line: TStringList;
  I: Integer;
  Code: Cardinal;
  AMapping: TUCS4Array;
begin
  SpecialCasingFileName := TPath.Combine(SourceFolder, SpecialCasingFileName);

  if not TFile.Exists(SpecialCasingFileName) then
  begin
    Writeln;
    Warning(SpecialCasingFileName + ' not found, ignoring special casing');
    exit;
  end;

  if Verbose then
  begin
    Writeln;
    Writeln('Reading special casing data from ' + SpecialCasingFileName + ':');
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(SpecialCasingFileName);
    Line := TStringList.Create;
    try
      for I := 0 to Lines.Count - 1 do
      begin
        SplitLine(Lines[I], Line);
        // continue only if the line is not empty
        if (Line.Count > 0) and (Length(Line[0]) > 0) then
        begin
          Code := StrToInt('$' + Line[0]);
          // extract lower case
          if Length(Line[1]) > 0 then
          begin
            SplitCodes(Line[1], AMapping);
            AddLowerCase(Code, AMapping);
          end;
          // extract title case
          if Length(Line[2]) > 0 then
          begin
            SplitCodes(Line[2], AMapping);
            AddTitleCase(Code, AMapping);
          end;
          // extract upper case
          if Length(Line[3]) > 0 then
          begin
            SplitCodes(Line[3], AMapping);
            AddUpperCase(Code, AMapping);
          end;
        end;
        if Verbose then
          Write(Format(#13'  %d%% done', [Round(100 * I / Lines.Count)]));
      end;
    finally
      Line.Free;
    end;
  finally
    Lines.Free;
  end;
  if Verbose then
    Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParseCaseFolding;
// Casefolding data is given by yet another optional file. Usually case insensitive string comparisons
// are done by converting the strings to lower case and compare them, but in some cases
// this is not enough. We only add those special cases to our internal casing array.
var
  Reader: TStreamReader;
  Line: string;
  Values: TArray<string>;
  Code: Cardinal;
  AMapping: TUCS4Array;
begin
  CaseFoldingFileName := TPath.Combine(SourceFolder, CaseFoldingFileName);

  if not TFile.Exists(CaseFoldingFileName) then
  begin
    Writeln;
    Warning(CaseFoldingFileName + ' not found, ignoring case folding');
    exit;
  end;

  if Verbose then
  begin
    Writeln;
    Writeln('Reading case folding data from ' + CaseFoldingFileName + ':');
  end;

  Reader := TStreamReader.Create(ArabicShapingFileName);
  try

    while (not Reader.EndOfStream) do
    begin

       // Layout of one line is:
       // <code>; <status>; <mapping>; # <name>
       // where status is either "L" describing a normal lowered letter
       // and "E" for exceptions (only the second is read)

      Line := Reader.ReadLine.Trim;
      if (Line = '') or (Line.StartsWith('#')) then
        continue;

      Values := Line.Split([';']);

      if (Length(Values) < 3) then
        continue;

      // the code currently being under consideration
      Code := StrToInt('$' + Values[0]);
      // type of mapping
      if ((Values[1] = 'C') or (Values[1] = 'F')) and (Values[2].Trim <> '') then
      begin
        SplitCodes(Values[2].Trim, AMapping);
        AddFoldCase(Code, AMapping);
      end;

      if Verbose then
        Write(Format(#13'  %d%% done', [Round(100 * Reader.BaseStream.Position / Reader.BaseStream.Size)]));

    end;

  finally
    Reader.Free;
  end;

  if Verbose then
    Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParseArabicShaping;
(*
# Each line contains four fields, separated by a semicolon.
#
# Field 0: the code point, in 4-digit hexadecimal
#   form, of a character.
#
# Field 1: gives a short schematic name for that character.
#   The schematic name is descriptive of the shape, based as
#   consistently as possible on a name for the skeleton and
#   then the diacritic marks applied to the skeleton, if any.
#   Note that this schematic name is considered a comment,
#   and does not constitute a formal property value.
#
# Field 2: defines the joining type (property name: Joining_Type)
#   R Right_Joining
#   L Left_Joining
#   D Dual_Joining
#   C Join_Causing
#   U Non_Joining
#   T Transparent
#
# See Section 9.2, Arabic for more information on these joining types.
# Note that for cursive joining scripts which are typically rendered
# top-to-bottom, rather than right-to-left, Joining_Type=L conventionally
# refers to bottom joining, and Joining_Type=R conventionally refers
# to top joining. See Section 14.4, Phags-pa for more information on the
# interpretation of joining types in vertical layout.
#
# Field 3: defines the joining group (property name: Joining_Group)
#
# The values of the joining group are based schematically on character
# names. Where a schematic character name consists of two or more parts
# separated by spaces, the formal Joining_Group property value, as specified in
# PropertyValueAliases.txt, consists of the same name parts joined by
# underscores. Hence, the entry:
#
#   0629; TEH MARBUTA; R; TEH MARBUTA
#
# corresponds to [Joining_Group = Teh_Marbuta].
*)
var
  Reader: TStreamReader;
  Line: string;
  Columns: TArray<string>;
  Code: Cardinal;
  ShapingClassValue: Byte;
  JoiningType: Char;
  JoiningGroup: string;
begin
  ArabicShapingFileName := TPath.Combine(SourceFolder, ArabicShapingFileName);

  if not FileExists(ArabicShapingFileName) then
  begin
    Writeln;
    Warning(ArabicShapingFileName + ' not found, ignoring arabic shaping');
    exit;
  end;

  if Verbose then
  begin
    Writeln;
    Writeln('Reading arabic shaping data from ' + ArabicShapingFileName + ':');
  end;

  Reader := TStreamReader.Create(ArabicShapingFileName);
  try

    while (not Reader.EndOfStream) do
    begin
      // # Unicode; Schematic Name; Joining Type; Joining Group

      Line := Reader.ReadLine.Trim;
      if (Line = '') or (Line.StartsWith('#')) then
        continue;

      Columns := Line.Split([';']);

      if (Length(Columns) < 4) then
        continue;

      Code := StrToInt('$'+Columns[0].Trim);

      JoiningType := Columns[2].Trim[1];

      ShapingClassValue := 0;

      if (JoiningType = 'R') then
      begin
        JoiningGroup := Columns[3].Trim;
        if (JoiningGroup = 'ALAPH') then
          ShapingClassValue := 5
        else
        if (JoiningGroup = 'DALATH RISH') then
          ShapingClassValue := 6;
      end;

      if (ShapingClassValue = 0) then
        case JoiningType of
          'U': ShapingClassValue := 1; // Non_Joining
          'L': ShapingClassValue := 2; // Left_Joining
          'R': ShapingClassValue := 3; // Right_Joining
          'D': ShapingClassValue := 4; // Dual_Joining
          'C': ShapingClassValue := 4; // Join_Causing
          'T': ShapingClassValue := 7; // Transparent
        end;

      if (ShapingClassValue <> 0) then
        AddArabicShapingClass(Code, ShapingClassValue);

      if Verbose then
        Write(Format(#13'  %d%% done', [Round(100 * Reader.BaseStream.Position / Reader.BaseStream.Size)]));

    end;

  finally
    Reader.Free;
  end;
  if Verbose then
    Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParseScripts;
(*
The format of this file is similar to that of Blocks.txt [Blocks]. The fields are separated by semicolons. The first
field contains either a single code point or the first and last code points in a range separated by “..”. The second
field provides the script property value for that range. The comment (after a #) indicates the General_Category and the
character name. For each range, it gives the character count in square brackets and uses the names for the first and
last characters in the range. For example:

    0B01;       Oriya # Mn       ORIYA SIGN CANDRABINDU
    0B02..0B03; Oriya # Mc   [2] ORIYA SIGN ANUSVARA..ORIYA SIGN VISARGA

The default value for the Script property is Unknown, given to all code points that are not explicitly mentioned in the
data file.
*)
var
  Reader: TStreamReader;
  Line: string;
  Columns: TArray<string>;
  Codes: TArray<string>;
  FirstCode, LastCode: Cardinal;
  Script: TUnicodeScript;
  i: integer;
begin
  ScriptsFileName := TPath.Combine(SourceFolder, ScriptsFileName);

  if not FileExists(ScriptsFileName) then
  begin
    Writeln;
    Warning(ScriptsFileName + ' not found, ignoring scripts');
    exit;
  end;

  if Verbose then
  begin
    Writeln;
    Writeln('Reading scripts data from ' + ScriptsFileName + ':');
  end;

  var ScriptMap := TDictionary<string, TUnicodeScript>.Create;
  try
    for Script := Low(TUnicodeScript) to High(TUnicodeScript) do
    begin
      var ISO15924 := PascalTypeUnicode.ScriptToISO15924(Script);
      if (ISO15924.Alias <> '') then
      begin
        if (not ScriptMap.TryAdd(ISO15924.Alias, Script)) then
          ScriptMap.Add(ISO15924.Alias+'_v2', Script); // E.g. 'Georgian'
      end;
    end;

    (*
    #  All code points not explicitly listed for Script
    #  have the value Unknown (scZzzz = 999).
    *)

    Reader := TStreamReader.Create(ScriptsFileName);
    try

      while (not Reader.EndOfStream) do
      begin
        // 0B01;       Oriya # Mn       ORIYA SIGN CANDRABINDU
        // 0B02..0B03; Oriya # Mc   [2] ORIYA SIGN ANUSVARA..ORIYA SIGN VISARGA

        Line := Reader.ReadLine;
        i := Pos('#', Line);
        if (i > 0) then
        begin
          while (i > 1) and (Line[i-1] = ' ') do
            Dec(i);
          Delete(Line, i, MaxInt);
        end;
        if (Line = '') then
          continue;

        Columns := Line.Split([';']);

        if (Length(Columns) < 2) then
          continue;

        Codes := Columns[0].Trim.Split(['..']);
        FirstCode := StrToInt('$'+Codes[0]);
        if (Length(Codes) > 1) then
          LastCode := StrToInt('$'+Codes[1])
        else
          LastCode := FirstCode;

        if (ScriptMap.TryGetValue(Columns[1].Trim, Script)) then
          AddScript(FirstCode, LastCode, Script);

        if Verbose then
          Write(Format(#13'  %d%% done', [Round(100 * Reader.BaseStream.Position / Reader.BaseStream.Size)]));

      end;

    finally
      Reader.Free;
    end;
  finally
    ScriptMap.Free;
  end;

  if Verbose then
    Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParsePropertyValueAliases;
(*
# Each line describes a property value name.
# This consists of three or more fields, separated by semicolons.
#
# First Field: The first field describes the property for which that
# property value name is used.
#
# Second Field: The second field is the short name for the property value.
# It is typically an abbreviation, but in a number of cases it is simply
# a duplicate of the "long name" in the third field.
#
# Third Field: The third field is the long name for the property value,
# typically the formal name used in documentation about the property value.
*)
var
  Reader: TStreamReader;
  Line: string;
  Values: TArray<string>;
  Category, ShortName, LongName: string;
  i: integer;
  AliasCategory: TPropertyValueAliases;
begin
  AliasFileName := TPath.Combine(SourceFolder, AliasFileName);

  if (not TFile.Exists(AliasFileName)) then
  begin
    Writeln;
    Warning(AliasFileName + ' not found, ignoring aliases');
    exit;
  end;

  if Verbose then
  begin
    Writeln;
    Writeln('Reading aliases data from ' + AliasFileName + ':');
  end;

  Reader := TStreamReader.Create(AliasFileName);
  try

    while (not Reader.EndOfStream) do
    begin
      // sc ; Adlm                             ; Adlam

      Line := Reader.ReadLine;
      i := Pos('#', Line);
      if (i > 0) then
      begin
        while (i > 1) and (Line[i-1] = ' ') do
          Dec(i);
        Delete(Line, i, MaxInt);
      end;
      if (Line = '') then
        continue;

      Values := Line.Split([';']);

      if (Length(Values) < 3) then
        continue;

      Category := Values[0].Trim;
      ShortName := Values[1].Trim;
      LongName := Values[2].Trim;

      if (not PropertyValueAliases.TryGetValue(Category, AliasCategory)) then
      begin
        AliasCategory := TPropertyValueAliases.Create;
        PropertyValueAliases.Add(Category, AliasCategory);
      end;
      AliasCategory.Add(ShortName, LongName);

      // Reverse
      if (not PropertyValueAliases.TryGetValue('_'+Category, AliasCategory)) then
      begin
        AliasCategory := TPropertyValueAliases.Create;
        PropertyValueAliases.Add('_'+Category, AliasCategory);
      end;
      AliasCategory.Add(LongName, ShortName);

      if Verbose then
        Write(Format(#13'  %d%% done', [Round(100 * Reader.BaseStream.Position / Reader.BaseStream.Size)]));

    end;

  finally
    Reader.Free;
  end;
  if Verbose then
    Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParseDerivedNormalizationProps;
// parse DerivedNormalizationProps looking for composition exclusions
var
 Lines,
 Line: TStringList;
 I, SeparatorPos: Integer;
 Start, Stop: Cardinal;
begin
  DerivedNormalizationPropsFileName := TPath.Combine(SourceFolder, DerivedNormalizationPropsFileName);

  if not TFile.Exists(DerivedNormalizationPropsFileName) then
  begin
    WriteLn;
    Warning(DerivedNormalizationPropsFileName + ' not found, ignoring derived normalization');
    exit;
  end;

  if Verbose then
  begin
    WriteLn;
    WriteLn('Reading derived normalization props from ' + DerivedNormalizationPropsFileName + ':');
  end;

  Lines := TStringList.Create;
 try
   Lines.LoadFromFile(DerivedNormalizationPropsFileName);
   Line := TStringList.Create;
   try
     for I := 0 to Lines.Count - 1 do
     begin
       // Layout of one line is:
       // <range>; <options> [;...] ; # <name>
       SplitLine(Lines[I], Line);
       // continue only if the line is not empty
       if (Line.Count > 0) and (Length(Line[0]) > 1) then
       begin
         // the range currently being under consideration
         SeparatorPos := Pos('..', Line[0]);
         if SeparatorPos > 0 then
         begin
           Start := StrToInt('$' + Copy(Line[0], 1, SeparatorPos - 1));
           Stop := StrToInt('$' + Copy(Line[0], SeparatorPos + 2, MaxInt));
         end
         else
         begin
           Start := StrToInt('$' + Line[0]);
           Stop := Start;
         end;
         // first option is considered
         if SameText(Line[1], 'Full_Composition_Exclusion') then
           AddRangeToCompositionExclusions(Start, Stop);
       end;
       if Verbose then
         Write(Format(#13'  %d%% done', [Round(100 * I / Lines.Count)]));
     end;
   finally
     Line.Free;
   end;
 finally
   Lines.Free;
 end;
 if Verbose then
   Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParsePropList;
var
 Lines,
 Line: TStringList;
 I, SeparatorPos: Integer;
 Start, Stop: Cardinal;
begin
  PropListFileName := TPath.Combine(SourceFolder, PropListFileName);

  if not TFile.Exists(PropListFileName) then
  begin
    WriteLn;
    Warning(PropListFileName + ' not found, ignoring property list');
    exit;
  end;

  if Verbose then
  begin
    WriteLn;
    WriteLn('Reading property list from ' + PropListFileName + ':');
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(PropListFileName);
    Line := TStringList.Create;
    try
      for I := 0 to Lines.Count - 1 do
      begin
        // Layout of one line is:
        // <range> or <char>; <property>
        SplitLine(Lines[I], Line);
        // continue only if the line is not empty
        if (Line.Count > 0) and (Length(Line[0]) > 1) then
        begin
          // the range currently being under consideration
          SeparatorPos := Pos('..', Line[0]);
          if SeparatorPos > 0 then
          begin
            Start := StrToInt('$' + Copy(Line[0], 1, SeparatorPos - 1));
            Stop := StrToInt('$' + Copy(Line[0], SeparatorPos + 2, MaxInt));
            AddRangeToCategories(Start, Stop, Line[1]);
          end
          else
          begin
            Start := StrToInt('$' + Line[0]);
            AddToCategories(Start, Line[1]);
          end;
        end;
        if Verbose then
          Write(Format(#13'  %d%% done', [Round(100 * I / Lines.Count)]));
      end;
    finally
      Line.Free;
    end;
  finally
    Lines.Free;
  end;
  if Verbose then
    Writeln;
end;

//----------------------------------------------------------------------------------------------------------------------

function FindDecomposition(Code: Cardinal): Integer;
var
  Item: TDecomposition;
begin
  Item.Code := Code;

  if (Decompositions.BinarySearch(Item, Result, TComparer<TDecomposition>.Construct(
    function(const A, B: TDecomposition): integer
    begin
      if (A.Code < B.Code) then
        Result := 1
      else
      if (A.Code > B.Code) then
        Result := -1
      else
        Result := 0;
    end))) then
  begin
    // Try to find the best
    while (Decompositions[Result].Tag <> cftCanonical) and (Result > 0) and (Decompositions[Result-1].Code = Code) do
      Dec(Result);
  end else
    Result := -1;
end;

//----------------------------------------------------------------------------------------------------------------------

function DecomposeIt(const S: TDecompositions): TDecompositions;

  procedure AddResult(Code: Cardinal);
  var
    L: Integer;
  begin
    L := Length(Result);
    SetLength(Result, L + 1);
    Result[L] := Code;
  end;

var
  I, J, K: Integer;
  Sub: TDecompositions;
begin
  for I := Low(S) to High(S) do
  begin
    J := FindDecomposition(S[I]);
    if J >= 0 then
    begin
      Sub := DecomposeIt(Decompositions[J].Decompositions);
      for K := Low(Sub) to High(Sub) do
        AddResult(Sub[K]);
    end
    else
      AddResult(S[I]);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ExpandDecompositions;
// Expand all decompositions by recursively decomposing each character in the decomposition.
var
  I: Integer;
  S: TDecompositions;
begin
  for I := 0 to Decompositions.Count-1 do
  begin
    // avoid side effects by creating a new array
    SetLength(S, 0);
    var p := Decompositions[I].PItem;
    S := DecomposeIt(p.Decompositions);
    p.Decompositions := S;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function IsCompositionExcluded(Code: Cardinal): Boolean;
// checks if composition is excluded to this code (decomposition cannot be recomposed)
begin
  Result := TestCharacter(CompositionExceptions, Code);
end;

//----------------------------------------------------------------------------------------------------------------------

function SortCompositions(const Decomposition1, Decomposition2: PDecomposition): Integer;
var
  I, Len1, Len2, MinLen: Integer;
begin
  Len1 := Length(Decomposition1.Decompositions);
  Len2 := Length(Decomposition2.Decompositions);
  MinLen := Len1;
  if MinLen > Len2 then
    MinLen := Len2;

  for I := 0 to MinLen - 1 do
  begin
    if Decomposition1.Decompositions[I] > Decomposition2.Decompositions[I] then
    begin
      Result := 1;
      Exit;
    end
    else
    if Decomposition1.Decompositions[I] < Decomposition2.Decompositions[I] then
    begin
      Result := -1;
      Exit;
    end;
  end;
  // if starts of two arrays are identical, sorting from longer to shorter (gives more
  // chances to longer combinations at runtime
  if Len1 < Len2 then
    Result := 1
  else
  if Len1 > Len2 then
    Result := -1
  else
  // Canonical before compatible
  if (Decomposition1.Tag = cftCanonical) and (Decomposition2.Tag <> cftCanonical) then
    Exit(-1)
  else
  if (Decomposition1.Tag <> cftCanonical) and (Decomposition2.Tag = cftCanonical) then
    Exit(1)
  else
    Result := 0;

end;

//----------------------------------------------------------------------------------------------------------------------

procedure CreateCompositions;
// create composition list from decomposition list
var
  J: Integer;
begin
  // reduce reallocations
  Compositions.Capacity := Decompositions.Count;

  // eliminate exceptions
  var List := Decompositions.List;
  for J := 0 to Decompositions.Count-1 do
    if (not IsCompositionExcluded(List[J].Code)) then
      Compositions.Add(List[J].PItem);

  Compositions.Sort(TComparer<PDecomposition>.Construct(SortCompositions));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure CreateResourceScript;
// creates the target file using the collected data
var
  TextStream, ResourceStream, CompressedResourceStream: TStream;
  CurrentLine: string;

  //--------------- local functions -------------------------------------------

  procedure WriteTextLine(S: AnsiString = '');
  // writes the given string as line into the resource script
  begin
    S := S + #13#10;
    TextStream.WriteBuffer(PAnsiChar(S)^, Length(S));
  end;

  //---------------------------------------------------------------------------

  procedure WriteTextByte(Value: Byte);
  // Buffers one byte of data (conversion to two-digit hex string is performed first)
  // and flushs out the current line if there are 32 values collected.
  begin
    CurrentLine := CurrentLine + Format('%.2x ', [Value]);
    if Length(CurrentLine) = 32 * 3 then
    begin
      WriteTextLine(AnsiString('  ''' + Trim(CurrentLine) + ''''));
      CurrentLine := '';
    end;
  end;

  //---------------------------------------------------------------------------

  procedure WriteResourceByte(Value: Cardinal);
  begin
    if Value <= $FF then
      ResourceStream.WriteBuffer(Value, 1)
    else
      FatalError('byte out of bound');
  end;

  //---------------------------------------------------------------------------

  procedure WriteResourceCardinal(Value: Cardinal);
  begin
    ResourceStream.WriteBuffer(Value, SizeOf(Value));
  end;

  //---------------------------------------------------------------------------

  procedure WriteResourceChar(Value: Cardinal);
  begin
    if Value < $1000000 then
      ResourceStream.WriteBuffer(Value, 3)
    else
      FatalError('character out of bound');
  end;

  //---------------------------------------------------------------------------

  procedure WriteResourceCharArray(Values: array of Cardinal);
  // loops through Values and writes them into the target file
  var
    I: Integer;
  begin
    for I := Low(Values) to High(Values) do
      WriteResourceChar(Values[I]);
  end;

  //---------------------------------------------------------------------------

  procedure CreateResource;
  begin
    if ZLibCompress or BZipCompress then
      CompressedResourceStream := TMemoryStream.Create;
    if ZLibCompress then
      ResourceStream := TJclZLibCompressStream.Create(CompressedResourceStream, 9)
    else
    if BZipCompress then
      ResourceStream := TJclBZIP2CompressionStream.Create(CompressedResourceStream, 9)
    else
      ResourceStream := TMemoryStream.Create;
  end;

  //---------------------------------------------------------------------------

  procedure FlushResource;
  var
    Buffer: Byte;
  begin
    if ZLibCompress or BZipCompress then
    begin
      ResourceStream.Free;

      ResourceStream := CompressedResourceStream;
    end;

    ResourceStream.Seek(0, soFromBeginning);

    while ResourceStream.Read(Buffer, SizeOf(Buffer)) = SizeOf(Buffer) do
      WriteTextByte(Buffer);

    ResourceStream.Free;

    if Length(CurrentLine) > 0 then
    begin
      WriteTextLine(AnsiString('  ''' + Trim(CurrentLine) + ''''));
      CurrentLine := '';
    end;
  end;

  //--------------- end local functions ---------------------------------------

var
  I, J: Integer;
  Ranges: TRangeArray;
  Category: TCharacterCategory;
begin
  CurrentLine := '';
  TextStream := TFileStream.Create(TargetFileName, fmCreate);
  try
    // 1) template header
    WriteTextLine(AnsiString('/' + StringOfChar('*', 100)));
    WriteTextLine;
    WriteTextLine;
    WriteTextLine(AnsiString('  ' + TargetFileName));
    WriteTextLine;
    WriteTextLine;
    WriteTextLine(Format('  Generated from the Unicode Character Database on %s by UDExtract.', [DateTimeToStr(Now)]));
    WriteTextLine('  UDExtract was written by:');
    WriteTextLine('  - Dipl. Ing. Mike Lischke, public@lischke-online.de');
    WriteTextLine('  - Anders Melander, anders@melander.dk');
    WriteTextLine;
    WriteTextLine;
    WriteTextLine(AnsiString(StringOfChar('*', 100) + '/'));
    WriteTextLine;
    WriteTextLine;

    // 2) category data
    WriteTextLine('LANGUAGE 0,0 CATEGORIES '+RESOURCETYPE+' LOADONCALL MOVEABLE DISCARDABLE');
    WriteTextLine('{');
    CreateResource;
    // write out only used categories
    for Category := Low(TCharacterCategory) to High(TCharacterCategory) do
    begin
      Ranges := FindCharacterRanges(Categories[Category]);
      if Length(Ranges) > 0 then
      begin
        // a) record what category it is actually (the cast assumes there will never
        //    be more than 256 categories)
        WriteResourceByte(Ord(Category));
        // b) tell how many ranges are assigned
        WriteResourceCardinal(Length(Ranges));
        // c) write start and stop code of each range
        for J := Low(Ranges) to High(Ranges) do
        begin
          WriteResourceChar(Ranges[J].Start);
          WriteResourceChar(Ranges[J].Stop);
        end;
      end;
    end;

    FlushResource;
    WriteTextLine('}');
    WriteTextLine;
    WriteTextLine;

    // 3) case mapping data
    WriteTextLine('LANGUAGE 0,0 CASE '+RESOURCETYPE+' LOADONCALL MOVEABLE DISCARDABLE');
    WriteTextLine('{');
    CreateResource;
    // record how many case mapping entries we have
    WriteResourceCardinal(Length(CaseMapping));
    for I := 0 to High(CaseMapping) do
    begin
      // store every available case mapping, consider one-to-many mappings
      // a) write actual code point
      WriteResourceChar(CaseMapping[I].Code);
      // b) write lower case
      WriteResourceByte(Length(CaseMapping[I].Fold));
      WriteResourceCharArray(CaseMapping[I].Fold);
      // c) write lower case
      WriteResourceByte(Length(CaseMapping[I].Lower));
      WriteResourceCharArray(CaseMapping[I].Lower);
      // d) write title case
      WriteResourceByte(Length(CaseMapping[I].Title));
      WriteResourceCharArray(CaseMapping[I].Title);
      // e) write upper case
      WriteResourceByte(Length(CaseMapping[I].Upper));
      WriteResourceCharArray(CaseMapping[I].Upper);
    end;
    FlushResource;
    WriteTextLine('}');
    WriteTextLine;
    WriteTextLine;

    // 4) decomposition data
    // fully expand all decompositions before generating the output
    ExpandDecompositions;
    WriteTextLine('LANGUAGE 0,0 DECOMPOSITION '+RESOURCETYPE+' LOADONCALL MOVEABLE DISCARDABLE');
    WriteTextLine('{');
    CreateResource;
    // record how many decomposition entries we have
    WriteResourceCardinal(Decompositions.Count);
    for I := 0 to Decompositions.Count-1 do
    begin
      WriteResourceChar(Decompositions[I].Code);
      WriteResourceByte(Length(Decompositions[I].Decompositions));
      WriteResourceByte(Byte(Decompositions[I].Tag));
      WriteResourceCharArray(Decompositions[I].Decompositions);
    end;
    FlushResource;
    WriteTextLine('}');
    WriteTextLine;
    WriteTextLine;

    // 5) canonical combining class data
    WriteTextLine('LANGUAGE 0,0 COMBINING '+RESOURCETYPE+' LOADONCALL MOVEABLE DISCARDABLE');
    WriteTextLine('{');
    CreateResource;
    for I := 0 to 255 do
    begin
      Ranges := FindCharacterRanges(CCCs[I]);
      if Length(Ranges) > 0 then
      begin
        // a) record which class is stored here
        WriteResourceByte(I);
        // b) tell how many ranges are assigned
        WriteResourceByte(Length(Ranges));
        // c) write start and stop code of each range
        for J := Low(Ranges) to High(Ranges) do
        begin
          WriteResourceChar(Ranges[J].Start);
          WriteResourceChar(Ranges[J].Stop);
        end;
      end;
    end;

    FlushResource;
    WriteTextLine('}');
    WriteTextLine;
    WriteTextLine;

    // 5a) ArabicShapingClasses[
    WriteTextLine('LANGUAGE 0,0 ARABSHAPING '+RESOURCETYPE+' LOADONCALL MOVEABLE DISCARDABLE');
    WriteTextLine('{');
    CreateResource;
    for I := 0 to 255 do
    begin
      Ranges := FindCharacterRanges(ArabicShapingClasses[I]);
      if Length(Ranges) > 0 then
      begin
        // a) record which class is stored here
        WriteResourceByte(I);
        // b) tell how many ranges are assigned
        WriteResourceByte(Length(Ranges));
        // c) write start and stop code of each range
        for J := Low(Ranges) to High(Ranges) do
        begin
          WriteResourceChar(Ranges[J].Start);
          WriteResourceChar(Ranges[J].Stop);
        end;
      end;
    end;

    FlushResource;
    WriteTextLine('}');
    WriteTextLine;
    WriteTextLine;

    // 5b) Scripts
    WriteTextLine('LANGUAGE 0,0 SCRIPTS '+RESOURCETYPE+' LOADONCALL MOVEABLE DISCARDABLE');
    WriteTextLine('{');
    CreateResource;
    Assert(Ord(High(TUnicodeScript)) <= 255);
    for var Script := Low(Scripts) to High(Scripts) do
    begin
      Ranges := FindCharacterRanges(Scripts[Script]);
      if Length(Ranges) > 0 then
      begin
        // a) record which script is stored here
        WriteResourceByte(Ord(Script));
        // b) tell how many ranges are assigned
        WriteResourceByte(Length(Ranges));
        // c) write start and stop code of each range
        for J := Low(Ranges) to High(Ranges) do
        begin
          WriteResourceChar(Ranges[J].Start);
          WriteResourceChar(Ranges[J].Stop);
        end;
      end;
    end;

    FlushResource;
    WriteTextLine('}');
    WriteTextLine;
    WriteTextLine;

    // 6) number data, this is actually two arrays, one which contains the numbers
    //    and the second containing the mapping between a code and a number
    WriteTextLine('LANGUAGE 0,0 NUMBERS '+RESOURCETYPE+' LOADONCALL MOVEABLE DISCARDABLE');
    WriteTextLine('{');
    CreateResource;
    // first, write the number definitions (size, values)
    WriteResourceByte(Length(Numbers));
    for I := 0 to High(Numbers) do
    begin
      WriteResourceCardinal(Cardinal(Numbers[I].Numerator));
      WriteResourceCardinal(Cardinal(Numbers[I].Denominator));
    end;
    // second, write the number mappings (size, values)
    WriteResourceCardinal(Length(NumberCodes));
    for I := 0 to High(NumberCodes) do
    begin
      WriteResourceChar(NumberCodes[I].Code);
      WriteResourceByte(NumberCodes[I].Index);
    end;
    FlushResource;
    WriteTextLine('}');
    WriteTextLine;
    WriteTextLine;

    // 7 ) composition data
    // create composition data from decomposition data and exclusion list before generating the output
    CreateCompositions;
    WriteTextLine('LANGUAGE 0,0 COMPOSITION '+RESOURCETYPE+' LOADONCALL MOVEABLE DISCARDABLE');
    WriteTextLine('{');
    CreateResource;
    // first, write the number of compositions
    WriteResourceCardinal(Compositions.Count);
    for I := 0 to Compositions.Count-1 do
    begin
      WriteResourceChar(Compositions[I].Code);
      WriteResourceByte(Length(Compositions[I].Decompositions));
      WriteResourceByte(Byte(Compositions[I].Tag));
      WriteResourceCharArray(Compositions[I].Decompositions);
    end;
    FlushResource;
    WriteTextLine('}');
  finally
    TextStream.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------
procedure PrintUsage;

begin
  Writeln('Usage: UDExtract [options]');
  Writeln;
  Writeln('  Reads data from the Unicode Character Database (UCD) text files');
  Writeln('  and generate a Windows resource script from the data in it.');
  Writeln;
  Writeln('  Options might have the following values (not case sensitive):');
  Writeln('    /?'#9#9#9'shows this screen');
  Writeln('    /source:<value>'#9'specify UCD source folder');
  Writeln('    /target:<value>'#9'specify destination resource file (default is unicode.rc)');
  Writeln('    /v or /verbose'#9'show warnings, errors etc., prompt at completion');
  WriteLn('    /z or /zip'#9#9'compress resource streams using zlib');
  WriteLn('    /bz or /bzip'#9'compress resource streams using bzip2');
  Writeln('    /all'#9#9'include all of the following resources');
  Writeln('    /alias'#9#9'read property value aliases text file');
  Writeln('    /arabic'#9#9'include arabic shaping resource');
  Writeln('    /case'#9#9'include lower/upper case resource');
  Writeln('    /casing'#9#9'include special case folding resource');
  WriteLn('    /derived'#9#9'include derived normalization resource');
  WriteLn('    /proplist'#9#9'include character properties resources');
  Writeln('    /scripts'#9#9'include scripts resource');
  Writeln;
  Writeln('Press <enter> to continue...');
  Readln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure CheckExtension(var FileName: TFileName; const Ext: String);

// Checks whether the given file name string contains an extension. If not then Ext is added to FileName.

begin
  if ExtractFileExt(FileName) = '' then
    FileName := FileName + Ext;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParseOptions;
var
  Value: string;
begin
  if FindCmdLineSwitch('h') or FindCmdLineSwitch('help') or FindCmdLineSwitch('?') then
  begin
    PrintUsage;
    Halt(0)
  end;

  Verbose := FindCmdLineSwitch('verbose') or FindCmdLineSwitch('v');
  ZLibCompress := FindCmdLineSwitch('zip') or FindCmdLineSwitch('z');
  BZipCompress := FindCmdLineSwitch('bzip') or FindCmdLineSwitch('bz');

  if FindCmdLineSwitch('source', Value, True, [clstValueAppended]) then
    SourceFolder := Value;

  if FindCmdLineSwitch('target', Value, True, [clstValueAppended]) then
    TargetFileName := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

{ TDecomposition }

function TDecomposition.GetPointer: PDecomposition;
begin
  Result := @Self;
end;

procedure TDecomposition.SetDecompositions(const Value: TDecompositions);
begin
  _Decompositions := Value;
end;

begin
  Writeln('Unicode database conversion tool');
  Writeln('(c) 2000, written by Dipl. Ing. Mike Lischke [public@lischke-online.de]');
  Writeln('(c) 2023, updated by Anders Melander [anders@melander.dk]');
  Writeln;

  ParseOptions;

  try
    Decompositions := TList<TDecomposition>.Create;
    Compositions := TList<PDecomposition>.Create;
    PropertyValueAliases := TObjectDictionary<string, TPropertyValueAliases>.Create([doOwnsValues]);


    if BZipCompress and not LoadBZip2 then
    begin
      WriteLn('failed to load bzip2 library');
      Halt(1);
    end;

    ParseData;

    var ParamAll := FindCmdLineSwitch('all');
    if ParamAll or FindCmdLineSwitch('alias') then
      ParsePropertyValueAliases;

    if ParamAll or FindCmdLineSwitch('arabic') then
      ParseArabicShaping;

    if ParamAll or FindCmdLineSwitch('scripts') then
      ParseScripts;

    if ParamAll or FindCmdLineSwitch('casing') then
      ParseSpecialCasing;

    if ParamAll or FindCmdLineSwitch('case') then
      ParseCaseFolding;

    if ParamAll or FindCmdLineSwitch('derived') then
      ParseDerivedNormalizationProps;

    if ParamAll or FindCmdLineSwitch('proplist') then
      ParsePropList;

    // finally write the collected data
    if Verbose then
    begin
      Writeln;
      Writeln;
      Writeln('Writing resource script ' + TargetFileName + '  ');
    end;
    CreateResourceScript;

    Decompositions.Free;
    Compositions.Free;
    PropertyValueAliases.Free;
  finally
    if Verbose then
    begin
      Writeln;
      Writeln('Program finished. Press <enter> to continue...');
      ReadLn;
    end;
  end;
end.

