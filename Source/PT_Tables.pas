unit PT_Tables;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Version: MPL 1.1 or LGPL 2.1 with linking exception                        //
//                                                                            //
// The contents of this file are subject to the Mozilla Public License        //
// Version 1.1 (the "License"); you may not use this file except in           //
// compliance with the License. You may obtain a copy of the License at       //
// http://www.mozilla.org/MPL/                                                //
//                                                                            //
// Software distributed under the License is distributed on an "AS IS"        //
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the    //
// License for the specific language governing rights and limitations under   //
// the License.                                                               //
//                                                                            //
// Alternatively, the contents of this file may be used under the terms of    //
// the Free Pascal modified version of the GNU Lesser General Public          //
// License Version 2.1 (the "FPC modified LGPL License"), in which case the   //
// provisions of this license are applicable instead of those above.          //
// Please see the file LICENSE.txt for additional information concerning      //
// this license.                                                              //
//                                                                            //
// The code is part of the PascalType Project                                 //
//                                                                            //
// The initial developer of this code is Christian-W. Budde                   //
//                                                                            //
// Portions created by Christian-W. Budde are Copyright (C) 2010-2021         //
// by Christian-W. Budde. All Rights Reserved.                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

{$I PT_Compiler.inc}

uses
  Classes, SysUtils,
  PT_Types,
  PT_Classes;

type
  // Unknown Table

  TPascalTypeUnknownTable = class(TCustomPascalTypeNamedTable)
  private
    FTableType: TTableType;
    FStream: TMemoryStream;
  protected
    function GetInternalTableType: TTableType; override;
  public
    constructor Create(AParent: TCustomPascalTypeTable; TableType: TTableType); reintroduce; virtual;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Stream: TMemoryStream read FStream;
  end;

  // glyph data prototype table

  TCustomPascalTypeGlyphDataTable = class(TCustomPascalTypeTable);


  // Header Table

  TPascalTypeHeaderTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion            : TFixedPoint; // = $00010000
    FFontRevision       : TFixedPoint; // set by font manufacturer
    FCheckSumAdjustment : Cardinal; // To compute: set it to 0, calculate the checksum for the 'head' table and put it in the table directory, sum the entire font as uint32, then store B1B0AFBA - sum. The checksum for the 'head' table will not be wrong. That is OK.
    FMagicNumber        : Cardinal; // set to $5F0F3CF5
    FFlags              : TFontHeaderTableFlags;
    FUnitsPerEm         : Word; // range from 64 to 16384
    FCreatedDate        : Int64; // created international date
    FModifiedDate       : Int64; // modified international date
    FxMin               : SmallInt; // for all glyph bounding boxes
    FyMin               : SmallInt; // for all glyph bounding boxes
    FxMax               : SmallInt; // for all glyph bounding boxes
    FyMax               : SmallInt; // for all glyph bounding boxes
    FMacStyle           : TMacStyles; // see TMacStyles
    FLowestRecPPEM      : Word; // smallest readable size in pixels
    FFontDirectionHint  : TFontDirectionHint;
    FIndexToLocFormat   : TIndexToLocationFormat;
    FGlyphDataFormat    : Word; // 0 for current format
    procedure SetCheckSumAdjustment(const Value: Cardinal);
    procedure SetCreatedDate(const Value: Int64);
    procedure SetFlags(const Value: TFontHeaderTableFlags);
    procedure SetFontDirectionHint(const Value: TFontDirectionHint);
    procedure SetFontRevision(const Value: TFixedPoint);
    procedure SetGlyphDataFormat(const Value: Word);
    procedure SetIndexToLocFormat(const Value: TIndexToLocationFormat);
    procedure SetLowestRecPPEM(const Value: Word);
    procedure SetMacStyle(const Value: TMacStyles);
    procedure SetModifiedDate(const Value: Int64);
    procedure SetUnitsPerEm(const Value: Word);
    procedure SetVersion(const Value: TFixedPoint);
    procedure SetXMax(const Value: SmallInt);
    procedure SetXMin(const Value: SmallInt);
    procedure SetYMax(const Value: SmallInt);
    procedure SetYMin(const Value: SmallInt);
  protected
    procedure CheckSumAdjustmentChanged; virtual;
    procedure CreatedDateChanged; virtual;
    procedure FlagsChanged; virtual;
    procedure FontDirectionHintChanged; virtual;
    procedure FontRevisionChanged; virtual;
    procedure GlyphDataFormatChanged; virtual;
    procedure IndexToLocFormatChanged; virtual;
    procedure LowestRecPPEMChanged; virtual;
    procedure MacStyleChanged; virtual;
    procedure ModifiedDateChanged; virtual;
    procedure UnitsPerEmChanged; virtual;
    procedure VersionChanged; virtual;
    procedure XMaxChanged; virtual;
    procedure XMinChanged; virtual;
    procedure YMaxChanged; virtual;
    procedure YMinChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    // table data
    property Version: TFixedPoint read FVersion write SetVersion; // = $00010000
    property FontRevision: TFixedPoint read FFontRevision write SetFontRevision; // set by font manufacturer
    property CheckSumAdjustment: Cardinal read FCheckSumAdjustment write SetCheckSumAdjustment; // To compute: set it to 0, calculate the checksum for the 'head' table and put it in the table directory, sum the entire font as uint32, then store B1B0AFBA - sum. The checksum for the 'head' table will not be wrong. That is OK.
    property Flags: TFontHeaderTableFlags read FFlags write SetFlags;
    property UnitsPerEm: Word read FUnitsPerEm write SetUnitsPerEm; // range from 64 to 16384
    property CreatedDate: Int64 read FCreatedDate write SetCreatedDate; // created international date
    property ModifiedDate: Int64 read FModifiedDate write SetModifiedDate; // modified international date
    property XMin: SmallInt read FxMin write SetXMin; // for all glyph bounding boxes
    property YMin: SmallInt read FyMin write SetYMin; // for all glyph bounding boxes
    property XMax: SmallInt read FxMax write SetXMax; // for all glyph bounding boxes
    property YMax: SmallInt read FyMax write SetYMax; // for all glyph bounding boxes
    property MacStyle: TMacStyles read FMacStyle write SetMacStyle;
    property LowestRecPPEM: Word read FLowestRecPPEM write SetLowestRecPPEM; // smallest readable size in pixels
    property FontDirectionHint: TFontDirectionHint read FFontDirectionHint write SetFontDirectionHint; // 0 Mixed directional glyphs
    property IndexToLocationFormat: TIndexToLocationFormat read FIndexToLocFormat write SetIndexToLocFormat; // 0 for short offsets, 1 for long
    property GlyphDataFormat: Word read FGlyphDataFormat write SetGlyphDataFormat; // 0 for current format
  end;


  // Table 'maxp' of Maximum Profile

  TPascalTypeMaximumProfileTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion              : TFixedPoint;
    FNumGlyphs            : Word;
    FMaxPoints            : Word;
    FMaxContours          : Word;
    FMaxCompositePoints   : Word;
    FMaxCompositeContours : Word;
    FMaxZones             : Word;
    FMaxTwilightPoints    : Word;
    FMaxStorage           : Word;
    FMaxFunctionDefs      : Word;
    FMaxInstructionDefs   : Word;
    FMaxStackElements     : Word;
    FMaxSizeOfInstructions: Word;
    FMaxComponentElements : Word;
    FMaxComponentDepth    : Word;
    procedure SetVersion(const Value: TFixedPoint);
    procedure SetMaxComponentDepth(const Value: Word);
    procedure SetMaxComponentElements(const Value: Word);
    procedure SetMaxCompositeContours(const Value: Word);
    procedure SetMaxCompositePoints(const Value: Word);
    procedure SetMaxContours(const Value: Word);
    procedure SetMaxFunctionDefs(const Value: Word);
    procedure SetMaxInstructionDefs(const Value: Word);
    procedure SetMaxPoints(const Value: Word);
    procedure SetMaxSizeOfInstructions(const Value: Word);
    procedure SetMaxStackElements(const Value: Word);
    procedure SetMaxStorage(const Value: Word);
    procedure SetMaxTwilightPoints(const Value: Word);
    procedure SetMaxZones(const Value: Word);
    procedure SetNumGlyphs(const Value: Word);
  protected
    procedure MaxComponentDepthChanged; virtual;
    procedure MaxComponentElementsChanged; virtual;
    procedure MaxCompositeContoursChanged; virtual;
    procedure MaxCompositePointsChanged; virtual;
    procedure MaxContoursChanged; virtual;
    procedure MaxFunctionDefsChanged; virtual;
    procedure MaxInstructionDefsChanged; virtual;
    procedure MaxPointsChanged; virtual;
    procedure MaxSizeOfInstructionsChanged; virtual;
    procedure MaxStackElementsChanged; virtual;
    procedure MaxStorageChanged; virtual;
    procedure MaxTwilightPointsChanged; virtual;
    procedure MaxZonesChanged; virtual;
    procedure NumGlyphsChanged; virtual;
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
  published
    property NumGlyphs         : Word read FNumGlyphs write SetNumGlyphs;
    property MaxPoints         : Word read FMaxPoints write SetMaxPoints;
    property MaxContours       : Word read FMaxContours write SetMaxContours;
    property MaxCompositePoints: Word read FMaxCompositePoints write SetMaxCompositePoints;
    property MaxCompositeContours: Word read FMaxCompositeContours write SetMaxCompositeContours;
    property MaxZones         : Word read FMaxZones write SetMaxZones;
    property MaxTwilightPoints: Word read FMaxTwilightPoints write SetMaxTwilightPoints;
    property MaxStorage     : Word read FMaxStorage write SetMaxStorage;
    property MaxFunctionDefs: Word read FMaxFunctionDefs write SetMaxFunctionDefs;
    property MaxInstructionDefs: Word read FMaxInstructionDefs write SetMaxInstructionDefs;
    property MaxStackElements: Word read FMaxStackElements write SetMaxStackElements;
    property MaxSizeOfInstruction: Word read FMaxSizeOfInstructions write SetMaxSizeOfInstructions;
    property MaxComponentElements: Word read FMaxComponentElements write SetMaxComponentElements;
    property MaxComponentDepth: Word read FMaxComponentDepth write SetMaxComponentDepth;
  end;


  // table 'name'

  TCustomTrueTypeFontNamePlatform = class(TCustomPascalTypeTable)
  private
    FEncodingID: Word; // Platform-specific encoding identifier.
    FLanguageID: Word; // Language identifier.
    FNameID    : TNameID; // Name identifiers.
    FNameString: WideString;
    function GetEncodingIDAsWord: Word;
    procedure SetEncodingIDAsWord(const Value: Word);
  protected

    function GetPlatformID: TPlatformID; virtual; abstract;
    procedure EncodingIDChanged; virtual;

    property PlatformSpecificID: Word read GetEncodingIDAsWord write SetEncodingIDAsWord;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word);virtual; abstract;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Name: WideString read FNameString;
    property NameID: TNameID read FNameID;
    property PlatformID: TPlatformID read GetPlatformID;
    property LanguageID: Word read FLanguageID;
  end;

  TTrueTypeFontNamePlatformClass = class of TCustomTrueTypeFontNamePlatform;

  TTrueTypeFontNamePlatformUnicode = class(TCustomTrueTypeFontNamePlatform)
  private
    procedure SetEncodingID(const Value: TUnicodeEncodingID);
    function GetEncodingID: TUnicodeEncodingID;
  protected
    function GetPlatformID: TPlatformID; override;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word); override;

    property PlatformSpecificID: TUnicodeEncodingID read GetEncodingID
      write SetEncodingID;
  end;

  TTrueTypeFontNamePlatformApple = class(TCustomTrueTypeFontNamePlatform)
  private
    function GetEncodingID: TAppleEncodingID;
    procedure SetEncodingID(const Value: TAppleEncodingID);
  protected
    function GetPlatformID: TPlatformID; override;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word); override;

    property PlatformSpecificID: TAppleEncodingID read GetEncodingID
      write SetEncodingID;
  end;

  TTrueTypeFontNamePlatformMicrosoft = class(TCustomTrueTypeFontNamePlatform)
  private
    function GetEncodingID: TMicrosoftEncodingID;
    procedure SetEncodingID(const Value: TMicrosoftEncodingID);
  protected
    function GetPlatformID: TPlatformID; override;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word); override;

    property PlatformSpecificID: TMicrosoftEncodingID read GetEncodingID
      write SetEncodingID;
  end;

  TTrueTypeFontNamePlatformISO = class(TCustomTrueTypeFontNamePlatform)
  protected
    function GetPlatformID: TPlatformID; override;
  public
    procedure ReadStringFromStream(Stream: TStream; Length: Word); override;
  end;

  TPascalTypeNameTable = class(TCustomPascalTypeNamedTable)
  private
    FFormat       : Word; // Format selector. Set to 0.
    FNameSubTables: array of TCustomTrueTypeFontNamePlatform;
    procedure SetFormat(const Value: Word);
    function GetNameSubTable(Index: Word): TCustomTrueTypeFontNamePlatform;
    function GetNameSubTableCount: Word;
    procedure FreeNameSubTables;
  protected
    procedure FormatChanged; virtual;
  public
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Format: Word read FFormat write SetFormat;
    property NameSubTableCount: Word read GetNameSubTableCount;
    property NameSubTable[Index: Word]: TCustomTrueTypeFontNamePlatform
      read GetNameSubTable;
  end;




  // table 'post'

  TPascalTypePostscriptVersion2Table = class(TCustomPascalTypeTable)
  private
    FGlyphNameIndex: array of Word; // This is not an offset, but is the ordinal number of the glyph in 'post' string tables.
    FNames: array of ShortString;
    function GetGlyphIndexCount: Integer; // Glyph names with length bytes [variable] (a Pascal string).
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function GlyphIndexToString(GlyphIndex: Integer): string;

    property GlyphIndexCount: Integer read GetGlyphIndexCount;
  end;

  TPascalTypePostscriptTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion            : TFixedPoint; // Format of this table
    FItalicAngle        : TFixedPoint; // Italic angle in degrees
    FUnderlinePosition  : SmallInt;    // Underline position
    FUnderlineThickness : SmallInt;    // Underline thickness
    FIsFixedPitch       : Longint;     // Font is monospaced; set to 1 if the font is monospaced and 0 otherwise (N.B., to maintain compatibility with older versions of the TrueType spec, accept any non-zero value as meaning that the font is monospaced)
    FMinMemType42       : Longint;     // Minimum memory usage when a TrueType font is downloaded as a Type 42 font
    FMaxMemType42       : Longint;     // Maximum memory usage when a TrueType font is downloaded as a Type 42 font
    FMinMemType1        : Longint;     // Minimum memory usage when a TrueType font is downloaded as a Type 1 font
    FMaxMemType1        : Longint;     // Maximum memory usage when a TrueType font is downloaded as a Type 1 font
    FPostscriptV2Table  : TPascalTypePostscriptVersion2Table;
    procedure SetVersion(const Value: TFixedPoint);
    procedure SetIsFixedPitch(const Value: Longint);
    procedure SetItalicAngle(const Value: TFixedPoint);
    procedure SetMaxMemType1(const Value: Longint);
    procedure SetMaxMemType42(const Value: Longint);
    procedure SetMinMemType1(const Value: Longint);
    procedure SetMinMemType42(const Value: Longint);
    procedure SetUnderlinePosition(const Value: SmallInt);
    procedure SetUnderlineThickness(const Value: SmallInt);
  protected
    procedure VersionChanged; virtual;
    procedure IsFixedPitchChanged; virtual;
    procedure ItalicAngleChanged; virtual;
    procedure MaxMemType1Changed; virtual;
    procedure MaxMemType42Changed; virtual;
    procedure MinMemType1Changed; virtual;
    procedure MinMemType42Changed; virtual;
    procedure UnderlinePositionChanged; virtual;
    procedure UnderlineThicknessChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
    property ItalicAngle: TFixedPoint read FItalicAngle write SetItalicAngle;
    property UnderlinePosition: SmallInt read FUnderlinePosition
      write SetUnderlinePosition;
    property UnderlineThickness: SmallInt read FUnderlineThickness
      write SetUnderlineThickness;
    property IsFixedPitch: Longint read FIsFixedPitch write SetIsFixedPitch;
    property MinMemType42: Longint read FMinMemType42 write SetMinMemType42;
    property MaxMemType42: Longint read FMaxMemType42 write SetMaxMemType42;
    property MinMemType1: Longint read FMinMemType1 write SetMinMemType1;
    property MaxMemType1: Longint read FMaxMemType1 write SetMaxMemType1;
    property PostscriptV2Table: TPascalTypePostscriptVersion2Table
      read FPostscriptV2Table;
  end;

procedure RegisterPascalTypeTable(TableClass: TCustomPascalTypeNamedTableClass);
procedure RegisterPascalTypeTables(TableClasses: array of TCustomPascalTypeNamedTableClass);
function FindPascalTypeTableByType(TableType: TTableType): TCustomPascalTypeNamedTableClass;

implementation

uses
  Math,
  PT_Math,
  PT_ResourceStrings,
  PascalType.Tables.TrueType.hhea;

resourcestring
  RCStrErrorWindowsAscender = 'Error: Windows ascender should be equal to ' +
    'the ascender defined in the horizontal header table';
  RCStrErrorWindowsDescender = 'Error: Windows descender should be equal to ' +
    'the descender defined in the horizontal header table';

var
  GTableClasses       : array of TCustomPascalTypeNamedTableClass;


{ TPascalTypeUnknownTable }

constructor TPascalTypeUnknownTable.Create(AParent: TCustomPascalTypeTable; TableType: TTableType);
begin
  inherited Create(AParent);
  FTableType := TableType;
  FStream := TMemoryStream.Create;
end;

destructor TPascalTypeUnknownTable.Destroy;
begin
  FreeAndNil(FStream);
  inherited;
end;

procedure TPascalTypeUnknownTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeUnknownTable then
  begin
    FTableType := TPascalTypeUnknownTable(Source).FTableType;

    // assign streams
    FStream.Seek(0, soFromBeginning);
    TPascalTypeUnknownTable(Source).FStream.Seek(0, soFromBeginning);
    FStream.CopyFrom(TPascalTypeUnknownTable(Source).FStream, 0);
  end;
end;

function TPascalTypeUnknownTable.GetInternalTableType: TTableType;
begin
  Result := FTableType;
end;

class function TPascalTypeUnknownTable.GetTableType: TTableType;
begin
  Result.AsInteger := 0;
end;

procedure TPascalTypeUnknownTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  FStream.Size := 0;
  if (Size > 0) then
    FStream.CopyFrom(Stream, Size);
end;

procedure TPascalTypeUnknownTable.SaveToStream(Stream: TStream);
begin
  FStream.Seek(0, soFromBeginning);
  Stream.CopyFrom(Stream, FStream.Size);
end;


{ TPascalTypeHeaderTable }

constructor TPascalTypeHeaderTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;

  FVersion.Value := 1;
  FVersion.Fract := 0;
  FFontRevision.Value := 1;
  FFontRevision.Fract := 0;
  FCheckSumAdjustment := 0;
  FMagicNumber := $F53C0F5F;
  FUnitsPerEm := 2048;
end;

procedure TPascalTypeHeaderTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeHeaderTable then
  begin
    FVersion := TPascalTypeHeaderTable(Source).FVersion;
    FFontRevision := TPascalTypeHeaderTable(Source).FFontRevision;
    FCheckSumAdjustment := TPascalTypeHeaderTable(Source).FCheckSumAdjustment;
    FMagicNumber := TPascalTypeHeaderTable(Source).FMagicNumber;
    FFlags := TPascalTypeHeaderTable(Source).FFlags;
    FUnitsPerEm := TPascalTypeHeaderTable(Source).FUnitsPerEm;
    FCreatedDate := TPascalTypeHeaderTable(Source).FCreatedDate;
    FModifiedDate := TPascalTypeHeaderTable(Source).FModifiedDate;
    FxMin := TPascalTypeHeaderTable(Source).FxMin;
    FyMin := TPascalTypeHeaderTable(Source).FyMin;
    FxMax := TPascalTypeHeaderTable(Source).FxMax;
    FyMax := TPascalTypeHeaderTable(Source).FyMax;
    FMacStyle := TPascalTypeHeaderTable(Source).FMacStyle;
    FLowestRecPPEM := TPascalTypeHeaderTable(Source).FLowestRecPPEM;
    FFontDirectionHint := TPascalTypeHeaderTable(Source).FFontDirectionHint;
    FIndexToLocFormat := TPascalTypeHeaderTable(Source).FIndexToLocFormat;
    FGlyphDataFormat := TPascalTypeHeaderTable(Source).FGlyphDataFormat;
  end;
end;

class function TPascalTypeHeaderTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'head';
end;

procedure TPascalTypeHeaderTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value64: Int64;
  Value32: Cardinal;
  Value16: Word;
begin
  // check (minimum) table size
  if Stream.Position + 54 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read version
  Stream.Read(Value32, SizeOf(TFixedPoint));
  FVersion.Fixed := Swap32(Value32);

  // check version
  if not(Version.Value = 1) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read font revision
  Stream.Read(Value32, SizeOf(TFixedPoint));
  FFontRevision.Fixed := Swap32(Value32);

  // read check sum adjust
  Stream.Read(Value32, SizeOf(Cardinal));
  FCheckSumAdjustment := Swap32(Value32);

  // read magic number
  Stream.Read(Value32, SizeOf(TFixedPoint));
  FMagicNumber := Swap32(Value32);

  // check for magic
  if (FMagicNumber <> $5F0F3CF5) then
    raise EPascalTypeError.Create(RCStrNoMagic);

  // read flags
  Value16 := BigEndianValueReader.ReadWord(Stream);
  FFlags := WordToFontHeaderTableFlags(Value16);

{$IFDEF AmbigiousExceptions}
  if (Value16 shr 14) <> 0 then
    raise EPascalTypeError.Create(RCStrHeaderFlagError);
{$ENDIF}
  // read UnitsPerEm
  FUnitsPerEm := BigEndianValueReader.ReadWord(Stream);

  // read CreatedDate
  Stream.Read(Value64, SizeOf(Int64));
  FCreatedDate := Swap64(Value64);

  // read ModifiedDate
  FModifiedDate := BigEndianValueReader.ReadInt64(Stream);

  // read xMin
  FxMin := BigEndianValueReader.ReadSmallInt(Stream);

  // read yMin
  FyMin := BigEndianValueReader.ReadSmallInt(Stream);

  // read xMax
  FxMax := BigEndianValueReader.ReadSmallInt(Stream);

  // read xMax
  FyMax := BigEndianValueReader.ReadSmallInt(Stream);

  // read MacStyle
  FMacStyle := WordToMacStyles(BigEndianValueReader.ReadWord(Stream));

  // read LowestRecPPEM
  FLowestRecPPEM := BigEndianValueReader.ReadWord(Stream);

  // read FontDirectionHint
  FFontDirectionHint := TFontDirectionHint(BigEndianValueReader.ReadSmallInt(Stream));

  // read IndexToLocFormat
  Value16 := BigEndianValueReader.ReadSmallInt(Stream);
  case Value16 of
    0:
      FIndexToLocFormat := ilShort;
    1:
      FIndexToLocFormat := ilLong;
  else
    raise EPascalTypeError.CreateFmt(RCStrWrongIndexToLocFormat, [Value16]);
  end;

  // read GlyphDataFormat
  FGlyphDataFormat := BigEndianValueReader.ReadSmallInt(Stream);
end;

procedure TPascalTypeHeaderTable.SaveToStream(Stream: TStream);
begin
  // write version
  WriteSwappedCardinal(Stream, Cardinal(FVersion));

  // write font revision
  WriteSwappedCardinal(Stream, Cardinal(FFontRevision));

  // write check sum adjust
  WriteSwappedCardinal(Stream, FCheckSumAdjustment);

  // write magic number
  WriteSwappedCardinal(Stream, FMagicNumber);

  // write flags
  WriteSwappedWord(Stream, FontHeaderTableFlagsToWord(FFlags));

  // write UnitsPerEm
  WriteSwappedWord(Stream, FUnitsPerEm);

  // write CreatedDate
  WriteSwappedInt64(Stream, FCreatedDate);

  // write ModifiedDate
  WriteSwappedInt64(Stream, FModifiedDate);

  // write xMin
  WriteSwappedSmallInt(Stream, FxMin);

  // write yMin
  WriteSwappedSmallInt(Stream, FyMin);

  // write xMax
  WriteSwappedSmallInt(Stream, FxMax);

  // write xMax
  WriteSwappedSmallInt(Stream, FyMax);

  // write MacStyle
  WriteSwappedWord(Stream, MacStylesToWord(FMacStyle));

  // write LowestRecPPEM
  WriteSwappedWord(Stream, FLowestRecPPEM);

  // write FontDirectionHint
  WriteSwappedWord(Stream, Word(FFontDirectionHint));

  // write IndexToLocFormat
  case FIndexToLocFormat of
    ilShort:
      WriteSwappedWord(Stream, 0);
    ilLong:
      WriteSwappedWord(Stream, 1);
  else
    raise EPascalTypeError.CreateFmt(RCStrWrongIndexToLocFormat,
      [Word(FIndexToLocFormat)]);
  end;

  // write GlyphDataFormat
  WriteSwappedWord(Stream, FGlyphDataFormat);
end;

procedure TPascalTypeHeaderTable.SetCheckSumAdjustment(const Value: Cardinal);
begin
  if FCheckSumAdjustment <> Value then
  begin
    FCheckSumAdjustment := Value;
    CheckSumAdjustmentChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetCreatedDate(const Value: Int64);
begin
  if FCreatedDate <> CreatedDate then
  begin
    FCreatedDate := Value;
    CreatedDateChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetFlags(const Value: TFontHeaderTableFlags);
begin
  if FFlags <> Value then
  begin
    FFlags := Value;
    FlagsChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetFontDirectionHint
  (const Value: TFontDirectionHint);
begin
  if FFontDirectionHint <> Value then
  begin
    FFontDirectionHint := Value;
    FontDirectionHintChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetFontRevision(const Value: TFixedPoint);
begin
  if (FFontRevision.Fract <> Value.Fract) or (FFontRevision.Value <> Value.Value)
  then
  begin
    FFontRevision := Value;
    FontRevisionChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetGlyphDataFormat(const Value: Word);
begin
  if FGlyphDataFormat <> Value then
  begin
    FGlyphDataFormat := Value;
    GlyphDataFormatChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetIndexToLocFormat
  (const Value: TIndexToLocationFormat);
begin
  if FIndexToLocFormat <> Value then
  begin
    FIndexToLocFormat := Value;
    IndexToLocFormatChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetLowestRecPPEM(const Value: Word);
begin
  if FLowestRecPPEM <> Value then
  begin
    FLowestRecPPEM := Value;
    LowestRecPPEMChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetMacStyle(const Value: TMacStyles);
begin
  if FMacStyle <> Value then
  begin
    FMacStyle := Value;
    MacStyleChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetModifiedDate(const Value: Int64);
begin
  if FModifiedDate <> Value then
  begin
    FModifiedDate := Value;
    ModifiedDateChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetUnitsPerEm(const Value: Word);
begin
  if FUnitsPerEm <> Value then
  begin
    FUnitsPerEm := Value;
    UnitsPerEmChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion <> Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetXMax(const Value: SmallInt);
begin
  if FxMax <> Value then
  begin
    FxMax := Value;
    XMaxChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetXMin(const Value: SmallInt);
begin
  if FxMin <> Value then
  begin
    FxMin := Value;
    XMinChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetYMax(const Value: SmallInt);
begin
  if FyMax <> Value then
  begin
    FyMax := Value;
    YMaxChanged;
  end;
end;

procedure TPascalTypeHeaderTable.SetYMin(const Value: SmallInt);
begin
  if FyMin <> Value then
  begin
    FyMin := Value;
    YMinChanged;
  end;
end;

procedure TPascalTypeHeaderTable.CheckSumAdjustmentChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.CreatedDateChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.FlagsChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.FontDirectionHintChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.FontRevisionChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.GlyphDataFormatChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.IndexToLocFormatChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.LowestRecPPEMChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.MacStyleChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.ModifiedDateChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.UnitsPerEmChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.VersionChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.XMaxChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.XMinChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.YMaxChanged;
begin
  Changed;
end;

procedure TPascalTypeHeaderTable.YMinChanged;
begin
  Changed;
end;


{ TCustomTrueTypeFontNamePlatform }

procedure TCustomTrueTypeFontNamePlatform.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomTrueTypeFontNamePlatform then
  begin
    FEncodingID := TCustomTrueTypeFontNamePlatform(Source).FEncodingID;
    FLanguageID := TCustomTrueTypeFontNamePlatform(Source).FLanguageID;
    FNameID := TCustomTrueTypeFontNamePlatform(Source).FNameID;
    FNameString := TCustomTrueTypeFontNamePlatform(Source).FNameString;
  end;
end;

function TCustomTrueTypeFontNamePlatform.GetEncodingIDAsWord: Word;
begin
  Result := FEncodingID;
end;

procedure TCustomTrueTypeFontNamePlatform.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  with Stream do
  begin
    // check (minimum) table size
    if Position + 6 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read encoding ID
    FEncodingID := BigEndianValueReader.ReadWord(Stream);

    // read language ID
    FLanguageID := BigEndianValueReader.ReadWord(Stream);

    // read name ID
    FNameID := TNameID(BigEndianValueReader.ReadWord(Stream));
  end;
end;

procedure TCustomTrueTypeFontNamePlatform.SaveToStream(Stream: TStream);
begin
  // write encoding ID
  WriteSwappedWord(Stream, FEncodingID);

  // write language ID
  WriteSwappedWord(Stream, FLanguageID);

  // write name ID
  WriteSwappedWord(Stream, Word(FNameID));
end;

procedure TCustomTrueTypeFontNamePlatform.SetEncodingIDAsWord(const Value: Word);
begin
  if Value <> FEncodingID then
  begin
    FEncodingID := Value;
    EncodingIDChanged;
  end;
end;

procedure TCustomTrueTypeFontNamePlatform.EncodingIDChanged;
begin
  Changed;
end;


{ TTrueTypeFontNamePlatformUnicode }

function TTrueTypeFontNamePlatformUnicode.GetPlatformID: TPlatformID;
begin
  Result := piUnicode;
end;

procedure TTrueTypeFontNamePlatformUnicode.ReadStringFromStream(Stream: TStream;
  Length: Word);
var
  StrOffset: Integer;
begin
  with Stream do
  begin
    // reset name string
    FNameString := '';

    // actually read the string
    for StrOffset := 0 to Length div 2 - 1 do
      FNameString := FNameString + WideChar(BigEndianValueReader.ReadWord(Stream));
  end;
end;

function TTrueTypeFontNamePlatformUnicode.GetEncodingID: TUnicodeEncodingID;
begin
  Result := TUnicodeEncodingID(FEncodingID);
end;

procedure TTrueTypeFontNamePlatformUnicode.SetEncodingID
  (const Value: TUnicodeEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


{ TTrueTypeFontNamePlatformApple }

function TTrueTypeFontNamePlatformApple.GetPlatformID: TPlatformID;
begin
  Result := piApple;
end;

procedure TTrueTypeFontNamePlatformApple.ReadStringFromStream(Stream: TStream;
  Length: Word);
var
  str: AnsiString;
begin
  with Stream do
  begin
    // reset name string
    FNameString := '';

    // actually read the string
    SetLength(str, Length);
    if (Length <> 0) then
      Read(str[1], Length);
    FNameString := WideString(str);
  end;
end;

function TTrueTypeFontNamePlatformApple.GetEncodingID: TAppleEncodingID;
begin
  Result := TAppleEncodingID(FEncodingID);
end;

procedure TTrueTypeFontNamePlatformApple.SetEncodingID
  (const Value: TAppleEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


{ TTrueTypeFontNamePlatformMicrosoft }

function TTrueTypeFontNamePlatformMicrosoft.GetPlatformID: TPlatformID;
begin
  Result := piMicrosoft;
end;

procedure TTrueTypeFontNamePlatformMicrosoft.ReadStringFromStream
  (Stream: TStream; Length: Word);
var
  StrOffset: Integer;
begin
  with Stream do
  begin
    // reset name string
    FNameString := '';

    // actually read the string
    for StrOffset := 0 to Length div 2 - 1 do
      FNameString := FNameString + WideChar(BigEndianValueReader.ReadWord(Stream));
  end;
end;

function TTrueTypeFontNamePlatformMicrosoft.GetEncodingID: TMicrosoftEncodingID;
begin
  Result := TMicrosoftEncodingID(FEncodingID);
end;

procedure TTrueTypeFontNamePlatformMicrosoft.SetEncodingID
  (const Value: TMicrosoftEncodingID);
begin
  SetEncodingIDAsWord(Word(Value));
end;


{ TTrueTypeFontNamePlatformISO }

function TTrueTypeFontNamePlatformISO.GetPlatformID: TPlatformID;
begin
  Result := piISO;
end;

procedure TTrueTypeFontNamePlatformISO.ReadStringFromStream(Stream: TStream;
  Length: Word);
var
  str      : string;
  StrOffset: Integer;
begin
  with Stream do
    case FEncodingID of
      0:
        begin
          // reset name string
          FNameString := '';

          // actually read the string
          SetLength(str, Length);
          Read(str[1], Length);
          FNameString := str;
        end;
      1:
        begin
          // reset name string
          FNameString := '';

          // actually read the string
          for StrOffset := 0 to Length div 2 - 1 do
            FNameString := FNameString + WideChar(BigEndianValueReader.ReadWord(Stream));
        end;
    else
      raise EPascalTypeError.Create('Unsupported encoding');
    end;
end;


{ TPascalTypeNameTable }

destructor TPascalTypeNameTable.Destroy;
begin
  FreeNameSubTables;
  inherited;
end;

function TPascalTypeNameTable.GetNameSubTable(Index: Word)
  : TCustomTrueTypeFontNamePlatform;
begin
  if (Index < Length(FNameSubTables)) then
    Result := TCustomTrueTypeFontNamePlatform(FNameSubTables[Index])
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TPascalTypeNameTable.GetNameSubTableCount: Word;
begin
  Result := Length(FNameSubTables);
end;

class function TPascalTypeNameTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'name'
end;

procedure TPascalTypeNameTable.Assign(Source: TPersistent);
var
  NameTableClass: TTrueTypeFontNamePlatformClass;
  NameTableIndex: Integer;
begin
  inherited;
  if Source is TPascalTypeNameTable then
  begin
    FFormat := TPascalTypeNameTable(Source).FFormat;

    // free all name tables
    FreeNameSubTables;

    // set length of name table array
    SetLength(FNameSubTables, Length(TPascalTypeNameTable(Source).FNameSubTables));

    // assign name tables
    for NameTableIndex := 0 to High(FNameSubTables) do
    begin
      NameTableClass := TTrueTypeFontNamePlatformClass(TPascalTypeNameTable(Source).FNameSubTables[NameTableIndex].ClassType);

      // create name table
      FNameSubTables[NameTableIndex] := NameTableClass.Create;

      // assign name table
      FNameSubTables[NameTableIndex].Assign(TPascalTypeNameTable(Source).FNameSubTables[NameTableIndex]);
    end;
  end;
end;

procedure TPascalTypeNameTable.FreeNameSubTables;
var
  NameIndex: Integer;
begin
  for NameIndex := 0 to High(FNameSubTables) do
    FreeAndNil(FNameSubTables[NameIndex]);
end;

procedure TPascalTypeNameTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StoragePos : Int64;
  OldPosition: Int64;
  NameIndex  : Integer;
  StrLength  : Word;
  StrOffset  : Word;
  Value16    : Word;
begin
  with Stream do
  begin
    // check (minimum) table size
    if Position + 6 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // store start position as preliminary storage position in stream
    StoragePos := Position;

    // read format
    FFormat := BigEndianValueReader.ReadWord(Stream);

    if not(FFormat in [0..1]) then
      raise EPascalTypeError.Create(RCStrUnknownFormat);

    // free current name items
    FreeNameSubTables;

    // internally store number of records
    SetLength(FNameSubTables, BigEndianValueReader.ReadWord(Stream));

    // read storage offset and add to preliminary storage position
    StoragePos := StoragePos + BigEndianValueReader.ReadWord(Stream);

    // check (minimum) table size
    if Position + Length(FNameSubTables) * 12 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    for NameIndex := 0 to High(FNameSubTables) do
    begin
      // read platform ID
      Value16 := BigEndianValueReader.ReadWord(Stream);
      case TPlatformID(Value16) of
        piUnicode:
          FNameSubTables[NameIndex] := TTrueTypeFontNamePlatformUnicode.Create;
        piApple:
          FNameSubTables[NameIndex] := TTrueTypeFontNamePlatformApple.Create;
        piISO:
          FNameSubTables[NameIndex] := TTrueTypeFontNamePlatformISO.Create;
        piMicrosoft:
          FNameSubTables[NameIndex] := TTrueTypeFontNamePlatformMicrosoft.Create;
      else
        raise EPascalTypeError.CreateFmt(RCStrUnsupportedPlatform, [Value16]);
      end;

      // load name record from stream
      FNameSubTables[NameIndex].LoadFromStream(Stream);

      // read length
      StrLength := BigEndianValueReader.ReadWord(Stream);

      // read offset
      StrOffset := BigEndianValueReader.ReadWord(Stream);

      // store current position and jump to string definition
      OldPosition := Position;
      Position := StoragePos + StrOffset;

      // read string from steam
      FNameSubTables[NameIndex].ReadStringFromStream(Stream, StrLength);

      // restore position
      Position := OldPosition;
    end;

    // ignore format 1 addition
    if FFormat = 1 then
      Position := Position + BigEndianValueReader.ReadWord(Stream);
  end;
end;

procedure TPascalTypeNameTable.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

procedure TPascalTypeNameTable.SetFormat(const Value: Word);
begin
  if FFormat <> Value then
  begin
    FFormat := Value;
    FormatChanged;
  end;
end;

procedure TPascalTypeNameTable.FormatChanged;
begin
  Changed;
end;


{ TPascalTypeMaximumProfileTable }

constructor TPascalTypeMaximumProfileTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 1;
end;

procedure TPascalTypeMaximumProfileTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeMaximumProfileTable then
  begin
    FVersion := TPascalTypeMaximumProfileTable(Source).FVersion;
    FNumGlyphs := TPascalTypeMaximumProfileTable(Source).FNumGlyphs;
    FMaxPoints := TPascalTypeMaximumProfileTable(Source).FMaxPoints;
    FMaxContours := TPascalTypeMaximumProfileTable(Source).FMaxContours;
    FMaxCompositePoints := TPascalTypeMaximumProfileTable(Source).FMaxCompositePoints;
    FMaxCompositeContours := TPascalTypeMaximumProfileTable(Source).FMaxCompositeContours;
    FMaxZones := TPascalTypeMaximumProfileTable(Source).FMaxZones;
    FMaxTwilightPoints := TPascalTypeMaximumProfileTable(Source).FMaxTwilightPoints;
    FMaxStorage := TPascalTypeMaximumProfileTable(Source).FMaxStorage;
    FMaxFunctionDefs := TPascalTypeMaximumProfileTable(Source).FMaxFunctionDefs;
    FMaxInstructionDefs := TPascalTypeMaximumProfileTable(Source).FMaxInstructionDefs;
    FMaxStackElements := TPascalTypeMaximumProfileTable(Source).FMaxStackElements;
    FMaxSizeOfInstructions := TPascalTypeMaximumProfileTable(Source).FMaxSizeOfInstructions;
    FMaxComponentElements := TPascalTypeMaximumProfileTable(Source).FMaxComponentElements;
    FMaxComponentDepth := TPascalTypeMaximumProfileTable(Source).FMaxComponentDepth;
  end;
end;

class function TPascalTypeMaximumProfileTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'maxp';
end;

procedure TPascalTypeMaximumProfileTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  // check (minimum) table size
  if Stream.Position + $6 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read version
  FVersion.Fixed := BigEndianValueReader.ReadCardinal(Stream);

{$IFDEF AmbigiousExceptions}
//  if Version.Value > 1 then
//    raise EPascalTypeError.Create(RCStrUnsupportedVersion);
{$ENDIF}
  if (Version.Fixed <> $00010000) and (Version.Fixed <> $00005000) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // read glyphs count
  FNumGlyphs := BigEndianValueReader.ReadWord(Stream);

  // set postscript values to maximum
  if (Version.Fixed = $00005000) then
  begin
    FMaxPoints := High(Word);
    FMaxContours := High(Word);
    FMaxCompositePoints := High(Word);
    FMaxCompositeContours := High(Word);
    FMaxZones := High(Word);
    FMaxTwilightPoints := High(Word);
    FMaxStorage := High(Word);
    FMaxFunctionDefs := High(Word);
    FMaxInstructionDefs := High(Word);
    FMaxStackElements := High(Word);
    FMaxSizeOfInstructions := High(Word);
    FMaxComponentElements := High(Word);
    FMaxComponentDepth := High(Word);
    Exit;
  end;

  // check (minimum) table size
  if Stream.Position + $1A > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read max points
  FMaxPoints := BigEndianValueReader.ReadWord(Stream);

  // read max contours
  FMaxContours := BigEndianValueReader.ReadWord(Stream);

  // read max composite points
  FMaxCompositePoints := BigEndianValueReader.ReadWord(Stream);

  // read max composite contours
  FMaxCompositeContours := BigEndianValueReader.ReadWord(Stream);

  // read max zones
  FMaxZones := BigEndianValueReader.ReadWord(Stream);

  // read max twilight points
  FMaxTwilightPoints := BigEndianValueReader.ReadWord(Stream);

  // read max storage
  FMaxStorage := BigEndianValueReader.ReadWord(Stream);

  // read max function defs
  FMaxFunctionDefs := BigEndianValueReader.ReadWord(Stream);

  // read max instruction defs
  FMaxInstructionDefs := BigEndianValueReader.ReadWord(Stream);

  // read max stack elements
  FMaxStackElements := BigEndianValueReader.ReadWord(Stream);

  // read max size of instructions
  FMaxSizeOfInstructions := BigEndianValueReader.ReadWord(Stream);

  // read max component elements
  FMaxComponentElements := BigEndianValueReader.ReadWord(Stream);

  // read max component depth
  FMaxComponentDepth := BigEndianValueReader.ReadWord(Stream);
end;

procedure TPascalTypeMaximumProfileTable.SaveToStream(Stream: TStream);
begin
  // write version
  WriteSwappedCardinal(Stream, Cardinal(FVersion));

  // write glyphs count
  WriteSwappedWord(Stream, FNumGlyphs);

  // write max points
  WriteSwappedWord(Stream, FMaxPoints);

  // write max contours
  WriteSwappedWord(Stream, FMaxContours);

  // write max composite points
  WriteSwappedWord(Stream, FMaxCompositePoints);

  // write max composite contours
  WriteSwappedWord(Stream, FMaxCompositeContours);

  // write max zones
  WriteSwappedWord(Stream, FMaxZones);

  // write max twilight points
  WriteSwappedWord(Stream, FMaxTwilightPoints);

  // write max storage
  WriteSwappedWord(Stream, FMaxStorage);

  // write max function defs
  WriteSwappedWord(Stream, FMaxFunctionDefs);

  // write max instruction defs
  WriteSwappedWord(Stream, FMaxInstructionDefs);

  // write max stack elements
  WriteSwappedWord(Stream, FMaxStackElements);

  // write max size of instructions
  WriteSwappedWord(Stream, FMaxSizeOfInstructions);

  // write max component elements
  WriteSwappedWord(Stream, FMaxComponentElements);

  // write max component depth
  WriteSwappedWord(Stream, FMaxComponentDepth);
end;

procedure TPascalTypeMaximumProfileTable.SetMaxComponentDepth
  (const Value: Word);
begin
  if FMaxComponentDepth <> Value then
  begin
    FMaxComponentDepth := Value;
    MaxComponentDepthChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxComponentElements(const Value: Word);
begin
  if FMaxComponentElements <> Value then
  begin
    FMaxComponentElements := Value;
    MaxComponentElementsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxCompositeContours(const Value: Word);
begin
  if FMaxCompositeContours <> Value then
  begin
    FMaxCompositeContours := Value;
    MaxCompositeContoursChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxCompositePoints(const Value: Word);
begin
  if FMaxCompositePoints <> Value then
  begin
    FMaxCompositePoints := Value;
    MaxCompositePointsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxContours(const Value: Word);
begin
  if FMaxContours <> Value then
  begin
    FMaxContours := Value;
    MaxContoursChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxFunctionDefs(const Value: Word);
begin
  if FMaxFunctionDefs <> Value then
  begin
    FMaxFunctionDefs := Value;
    MaxFunctionDefsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxInstructionDefs(const Value: Word);
begin
  if FMaxInstructionDefs <> Value then
  begin
    FMaxInstructionDefs := Value;
    MaxInstructionDefsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxPoints(const Value: Word);
begin
  if FMaxPoints <> Value then
  begin
    FMaxPoints := Value;
    MaxPointsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxSizeOfInstructions(const Value: Word);
begin
  if FMaxSizeOfInstructions <> Value then
  begin
    FMaxSizeOfInstructions := Value;
    MaxSizeOfInstructionsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxStackElements(const Value: Word);
begin
  if FMaxStackElements <> Value then
  begin
    FMaxStackElements := Value;
    MaxStackElementsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxStorage(const Value: Word);
begin
  if FMaxStorage <> Value then
  begin
    FMaxStorage := Value;
    MaxStorageChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxTwilightPoints(const Value: Word);
begin
  if FMaxTwilightPoints <> Value then
  begin
    FMaxTwilightPoints := Value;
    MaxTwilightPointsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetMaxZones(const Value: Word);
begin
  if FMaxZones <> Value then
  begin
    FMaxZones := Value;
    MaxZonesChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetNumGlyphs(const Value: Word);
begin
  if FNumGlyphs <> Value then
  begin
    FNumGlyphs := Value;
    NumGlyphsChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeMaximumProfileTable.MaxComponentDepthChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxComponentElementsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxCompositeContoursChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxCompositePointsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxContoursChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxFunctionDefsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxInstructionDefsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxPointsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxSizeOfInstructionsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxStackElementsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxStorageChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxTwilightPointsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.MaxZonesChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.NumGlyphsChanged;
begin
  Changed;
end;

procedure TPascalTypeMaximumProfileTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypePostscriptTable }

constructor TPascalTypePostscriptTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 2;
end;

destructor TPascalTypePostscriptTable.Destroy;
begin
  FreeAndNil(FPostscriptV2Table);
  inherited;
end;

class function TPascalTypePostscriptTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'post';
end;

procedure TPascalTypePostscriptTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypePostscriptTable then
  begin
    FVersion := TPascalTypePostscriptTable(Source).FVersion;
    FItalicAngle := TPascalTypePostscriptTable(Source).FItalicAngle;
    FUnderlinePosition := TPascalTypePostscriptTable(Source).FUnderlinePosition;
    FUnderlineThickness := TPascalTypePostscriptTable(Source).FUnderlineThickness;
    FIsFixedPitch := TPascalTypePostscriptTable(Source).FIsFixedPitch;
    FMinMemType42 := TPascalTypePostscriptTable(Source).FMinMemType42;
    FMaxMemType42 := TPascalTypePostscriptTable(Source).FMaxMemType42;
    FMinMemType1 := TPascalTypePostscriptTable(Source).FMinMemType1;
    FMaxMemType1 := TPascalTypePostscriptTable(Source).FMaxMemType1;
    if (TPascalTypePostscriptTable(Source).FPostscriptV2Table <> nil) then
    begin
      if (FPostscriptV2Table = nil) then
        FPostscriptV2Table := TPascalTypePostscriptVersion2Table.Create(Self);
      FPostscriptV2Table.Assign(TPascalTypePostscriptTable(Source).FPostscriptV2Table);
    end else
      FreeAndNil(FPostscriptV2Table);
  end;
end;

{$IFOPT R+}
{$DEFINE R_PLUS}
{$RANGECHECKS OFF}
{$ENDIF}
procedure TPascalTypePostscriptTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value32: Cardinal;
begin
  with Stream do
  begin
    // check (minimum) table size
    if Position + 32 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read format type
    Read(Value32, SizeOf(Cardinal));
    FVersion.Fixed := Swap32(Value32);

    // read italic angle
    Read(Value32, SizeOf(Cardinal));
    FItalicAngle.Fixed := Swap32(Value32);

    // read underline position
    FUnderlinePosition := BigEndianValueReader.ReadWord(Stream);

    // read underline thickness
    FUnderlineThickness := BigEndianValueReader.ReadWord(Stream);

    // read is fixed pitch
    Read(Value32, SizeOf(Cardinal));
    FIsFixedPitch := Swap32(Value32);

    // read minimum memory usage (type 42)
    Read(Value32, SizeOf(Cardinal));
    FMinMemType42 := Swap32(Value32);

    // read maximum memory usage (type 42)
    Read(Value32, SizeOf(Cardinal));
    FMaxMemType42 := Swap32(Value32);

    // read minimum memory usage (type 1)
    Read(Value32, SizeOf(Cardinal));
    FMinMemType1 := Swap32(Value32);

    // read maximum memory usage (type 1)
    Read(Value32, SizeOf(Cardinal));
    FMaxMemType1 := Swap32(Value32);

    if FVersion.Value = 2 then
    begin
      if (FPostscriptV2Table = nil) then
        FPostscriptV2Table := TPascalTypePostscriptVersion2Table.Create(Self);
      FPostscriptV2Table.LoadFromStream(Stream);
    end;
  end;
end;
{$IFDEF R_PLUS}
{$RANGECHECKS ON}
{$UNDEF R_PLUS}
{$ENDIF}

procedure TPascalTypePostscriptTable.SaveToStream(Stream: TStream);
begin
  // write format type
  WriteSwappedCardinal(Stream, Cardinal(FVersion));

  // write italic angle
  WriteSwappedCardinal(Stream, Cardinal(FItalicAngle));

  // write underline position
  WriteSwappedWord(Stream, FUnderlinePosition);

  // write underline thickness
  WriteSwappedWord(Stream, FUnderlineThickness);

  // write is fixed pitch
  WriteSwappedCardinal(Stream, FIsFixedPitch);

  // write minimum memory usage (type 42)
  WriteSwappedCardinal(Stream, FMinMemType42);

  // write maximum memory usage (type 42)
  WriteSwappedCardinal(Stream, FMaxMemType42);

  // write minimum memory usage (type 1)
  WriteSwappedCardinal(Stream, FMinMemType1);

  // write maximum memory usage (type 1)
  WriteSwappedCardinal(Stream, FMaxMemType1);
end;

procedure TPascalTypePostscriptTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Value <> Value.Value) or (FVersion.Fract <> Value.Fract) then
  begin
    Version := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypePostscriptTable.SetIsFixedPitch(const Value: Longint);
begin
  if FIsFixedPitch <> Value then
  begin
    FIsFixedPitch := Value;
    IsFixedPitchChanged;
  end;
end;

procedure TPascalTypePostscriptTable.SetItalicAngle(const Value: TFixedPoint);
begin
  if (FItalicAngle.Value <> Value.Value) or (FItalicAngle.Fract <> Value.Fract)
  then
  begin
    FItalicAngle := Value;
    ItalicAngleChanged;
  end;
end;

procedure TPascalTypePostscriptTable.SetMaxMemType1(const Value: Longint);
begin
  if FMaxMemType1 <> Value then
  begin
    FMaxMemType1 := Value;
    MaxMemType1Changed;
  end;
end;

procedure TPascalTypePostscriptTable.SetMaxMemType42(const Value: Longint);
begin
  if FMaxMemType42 <> Value then
  begin
    FMaxMemType42 := Value;
    MaxMemType42Changed;
  end;
end;

procedure TPascalTypePostscriptTable.SetMinMemType1(const Value: Longint);
begin
  if FMinMemType1 <> Value then
  begin
    FMinMemType1 := Value;
    MinMemType1Changed;
  end;
end;

procedure TPascalTypePostscriptTable.SetMinMemType42(const Value: Longint);
begin
  if FMinMemType42 <> Value then
  begin
    FMinMemType42 := Value;
    MinMemType42Changed;
  end;
end;

procedure TPascalTypePostscriptTable.SetUnderlinePosition
  (const Value: SmallInt);
begin
  if FUnderlinePosition <> Value then
  begin
    FUnderlinePosition := Value;
    UnderlinePositionChanged;
  end;
end;

procedure TPascalTypePostscriptTable.SetUnderlineThickness
  (const Value: SmallInt);
begin
  if FUnderlineThickness <> Value then
  begin
    FUnderlineThickness := Value;
    UnderlineThicknessChanged;
  end;
end;

procedure TPascalTypePostscriptTable.VersionChanged;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.IsFixedPitchChanged;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.ItalicAngleChanged;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.MaxMemType1Changed;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.MaxMemType42Changed;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.MinMemType1Changed;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.MinMemType42Changed;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.UnderlinePositionChanged;
begin
  Changed;
end;

procedure TPascalTypePostscriptTable.UnderlineThicknessChanged;
begin
  Changed;
end;


{ TPascalTypePostscriptVersion2Table }

constructor TPascalTypePostscriptVersion2Table.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
end;

destructor TPascalTypePostscriptVersion2Table.Destroy;
begin
  inherited;
end;

function TPascalTypePostscriptVersion2Table.GetGlyphIndexCount: Integer;
begin
  Result := Length(FGlyphNameIndex);
end;

function TPascalTypePostscriptVersion2Table.GlyphIndexToString(GlyphIndex: Integer): string;
begin
  if FGlyphNameIndex[GlyphIndex] < 258 then
    Result := DefaultGlyphName(FGlyphNameIndex[GlyphIndex])
  else
    Result := string(FNames[FGlyphNameIndex[GlyphIndex] - 258]);
end;

procedure TPascalTypePostscriptVersion2Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypePostscriptVersion2Table then
  begin
    FGlyphNameIndex := TPascalTypePostscriptVersion2Table(Source).FGlyphNameIndex;
    FNames := TPascalTypePostscriptVersion2Table(Source).FNames;
  end;
end;

procedure TPascalTypePostscriptVersion2Table.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  GlyphIndex: Integer;
  Value8    : Byte;
begin
  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // load number of glyphs
    SetLength(FGlyphNameIndex, BigEndianValueReader.ReadWord(Stream));

    // read glyph name index array
    for GlyphIndex := 0 to High(FGlyphNameIndex) do
      FGlyphNameIndex[GlyphIndex] := BigEndianValueReader.ReadWord(Stream);

    while Position < Size do
    begin
      Read(Value8, SizeOf(Byte));
      SetLength(FNames, Length(FNames) + 1);
      SetLength(FNames[High(FNames)], Value8);
      Read(FNames[High(FNames)][1], Value8);
    end;
  end;
end;

procedure TPascalTypePostscriptVersion2Table.SaveToStream(Stream: TStream);
begin
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

/// /////////////////////////////////////////////////////////////////////////////

function IsPascalTypeTableRegistered(TableClass: TCustomPascalTypeNamedTableClass): Boolean;
var
  TableClassIndex: Integer;
begin
  Result := False;
  for TableClassIndex := 0 to High(GTableClasses) do
    if GTableClasses[TableClassIndex] = TableClass then
    begin
      Result := True;
      Exit;
    end;
end;

function CheckGlobalTableClassesValid: Boolean;
var
  TableClassBaseIndex: Integer;
  TableClassIndex    : Integer;
begin
  Result := True;
  for TableClassBaseIndex := 0 to High(GTableClasses) do
    for TableClassIndex := TableClassBaseIndex + 1 to High(GTableClasses) do
      if GTableClasses[TableClassBaseIndex] = GTableClasses[TableClassIndex] then
      begin
        Result := False;
        Exit;
      end;
end;

procedure RegisterPascalTypeTable(TableClass: TCustomPascalTypeNamedTableClass);
begin
  Assert(IsPascalTypeTableRegistered(TableClass) = False);
  SetLength(GTableClasses, Length(GTableClasses) + 1);
  GTableClasses[High(GTableClasses)] := TableClass;
end;

procedure RegisterPascalTypeTables(TableClasses: array of TCustomPascalTypeNamedTableClass);
var
  TableClassIndex: Integer;
begin
  SetLength(GTableClasses, Length(GTableClasses) + Length(TableClasses));
  for TableClassIndex := 0 to High(TableClasses) do
    GTableClasses[Length(GTableClasses) - Length(TableClasses) + TableClassIndex] := TableClasses[TableClassIndex];
  Assert(CheckGlobalTableClassesValid);
end;

function FindPascalTypeTableByType(TableType: TTableType): TCustomPascalTypeNamedTableClass;
var
  TableClassIndex: Integer;
begin
  Result := nil;
  for TableClassIndex := 0 to High(GTableClasses) do
    if GTableClasses[TableClassIndex].GetTableType.AsCardinal = TableType.AsCardinal then
    begin
      Result := GTableClasses[TableClassIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown Table Class: ' + TableType);
end;

initialization

  RegisterPascalTypeTables([TPascalTypeHeaderTable,
    TPascalTypeNameTable, TPascalTypeMaximumProfileTable,
    TPascalTypePostscriptTable]);

end.
