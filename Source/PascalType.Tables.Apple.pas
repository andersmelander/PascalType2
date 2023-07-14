unit PascalType.Tables.Apple;

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
  PascalType.Tables,
  PascalType.Tables.Shared,
  PascalType.Tables.TrueType.head;

type
  TCustomPascalTypeNamedVersionTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: TFixedPoint;
    procedure SetVersion(const Value: TFixedPoint);
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
  end;

  TCustomPascalTypeBinarySearchingTable = class(TCustomPascalTypeTable)
  private
    FUnitSize: Word; // Size of a lookup unit for this search in bytes.
    FnUnits  : Word; // Number of units of the preceding size to be searched.
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'acnt'

  TCustomPascalTypeAccentAttachmentDescriptionTable = class(TCustomPascalTypeTable)
  private
    FPrimaryGlyphIndex: Word; // Primary glyph index number.
  protected
    class function GetIsFormat1: Boolean; virtual; abstract;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property IsFormat1: Boolean read GetIsFormat1;
  end;

  TPascalTypeAccentAttachmentDescriptionFormat0Table = class(TCustomPascalTypeAccentAttachmentDescriptionTable)
  private
    FPrimaryAttachmentPoint: Byte; // Primary attachment control point number.
    FSecondaryInfoIndex: Byte; // Secondary attachment control point number.
  protected
    class function GetIsFormat1: Boolean; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TPascalTypeAccentAttachmentDescriptionFormat1Table = class(TCustomPascalTypeAccentAttachmentDescriptionTable)
  private
    FExtensionOffset: Word;
    // Byte offset to the beginning of the extensions subtable.
  protected
    class function GetIsFormat1: Boolean; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  (*
    TAccentAttachmentExtention = packed record
    Components             : uint1; // Value = 0 indicates that there are more components. Value = 1 indicates that this is the last component.
    SecondaryInfoIndex     : uint7; // numberComponents]	Secondary information index for the first component.
    PrimaryAttachmentPoint : uint8; // numberComponents]	Primary attachment control point for the first component.
    end;

    TAccentAttachmentSecondaryData = packed record
    SecondaryGlyphIndex            : Word; // Secondary glyph index. A maximum of 255 entries are allowed.
    SecondaryGlyphAttachmentNumber : Byte; // Secondary glyph attachment index number.
    end;
  *)

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6acnt.html
  TPascalTypeAccentAttachmentTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FFirstAccentGlyphIndex: Word; // The first accented glyph index.
    FLastAccentGlyphIndex : Word; // The last accented glyph index.
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'avar'

  TAxisVariationCorrespondence = packed record
    fromCoord: TShortFrac; // Value in normalized user space.
    toCoord: TShortFrac; // Value in normalized axis space.
  end;

  TPascalTypeAxisVariationSegmentTable = class(TCustomPascalTypeTable)
  private
    FCorrespondenceArray: array of TAxisVariationCorrespondence;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6avar.html
  TPascalTypeAxisVariationTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FSegments: TPascalTypeTableList<TPascalTypeAxisVariationSegmentTable>;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'bsln'

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6bsln.html

  TCustomPascalTypeBaselinePartTable = class(TCustomPascalTypeTable)
  end;

  TPascalTypeBaselinePartFormat0Table = class(TCustomPascalTypeBaselinePartTable)
  private
    FDeltas: array [0..31] of Word;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TPascalTypeBaselinePartFormat1Table = class(TPascalTypeBaselinePartFormat0Table)
  private
    // FLookupTable : TLookupTable;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TPascalTypeBaselineTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FFormat: Word; // Format of the baseline table. Only one baseline format may be selected for the font.
    FDefaultBaseline: Word; // Default baseline value for all glyphs. This value can be from 0 through 31.
    FBaselinePart: TCustomPascalTypeBaselinePartTable;
  public
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'bdat'

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6bdat.html
  TPascalTypeBitmapDataTable = class(TCustomPascalTypeNamedVersionTable)
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'bhed'

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6bhed.html
  TPascalTypeBitmapHeaderTable = class(TPascalTypeHeaderTable)
  public
    class function GetTableType: TTableType; override;
  end;


  // table 'bloc'

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6bloc.html
  TPascalTypeBitmapLocationTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FBitmapSizeList: TPascalTypeTableList<TPascalTypeBitmapSizeTable>;
    function GetBitmapSizeTable(Index: Integer): TPascalTypeBitmapSizeTable;
    function GetBitmapSizeTableCount: Integer;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property BitmapSizeTableCount: Integer read GetBitmapSizeTableCount;
    property BitmapSizeTable[Index: Integer]: TPascalTypeBitmapSizeTable read GetBitmapSizeTable;
  end;


  // table 'fdsc'

  TCustomPascalTypeTaggedValueTable = class(TCustomPascalTypeTable)
  protected
    FValue: TFixedPoint;
    procedure ValueChanged; virtual;

    class function GetTableType: TTableType; virtual; abstract;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TPascalTypeTaggedValueTableClass = class of TCustomPascalTypeTaggedValueTable;

  TPascalTypeWeightValueTable = class(TCustomPascalTypeTaggedValueTable)
  private
    procedure SetValue(const Value: TFixedPoint);
  protected
    class function GetTableType: TTableType; override;
  public
    property Weight: TFixedPoint read FValue write SetValue;
  end;

  TPascalTypeWidthValueTable = class(TCustomPascalTypeTaggedValueTable)
  private
    procedure SetValue(const Value: TFixedPoint);
  protected
    class function GetTableType: TTableType; override;
  public
    property Width: TFixedPoint read FValue write SetValue;
  end;

  TPascalTypeSlantValueTable = class(TCustomPascalTypeTaggedValueTable)
  private
    procedure SetValue(const Value: TFixedPoint);
  protected
    class function GetTableType: TTableType; override;
  public
    property Slant: TFixedPoint read FValue write SetValue;
  end;

  TPascalTypeOpticalSizeValueTable = class(TCustomPascalTypeTaggedValueTable)
  private
    procedure SetValue(const Value: TFixedPoint);
  protected
    class function GetTableType: TTableType; override;
  public
    property OpticalSize: TFixedPoint read FValue write SetValue;
  end;

  TPascalTypeNonAlphabeticValueTable = class(TCustomPascalTypeTaggedValueTable)
  private
    function GetCode: TNonAlphabeticCode;
    procedure SetCode(const Value: TNonAlphabeticCode);
  protected
    class function GetTableType: TTableType; override;
  public
    property Code: TNonAlphabeticCode read GetCode write SetCode;
  end;

  TPascalTypeFontDescriptionTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FDescritors: TPascalTypeTableList<TCustomPascalTypeTaggedValueTable>;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'feat'

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6feat.html
  TPascalTypeAppleFeatureTable = class(TCustomPascalTypeTable)
  private
    FFeature      : Word;     // Feature type.
    FNumSettings  : Word;     // The number of records in the setting name array.
    FSettingTable : Cardinal; // Offset in bytes from the beginning of this table to this feature's setting name array. The actual type of record this offset refers to will depend on the exclusivity value, as described below.
    FFeatureFlags : Word;     // Single-bit flags associated with the feature type.
    FNameIndex    : SmallInt; // The name table index for the feature's name. This index has values greater than 255 and less than 32768.
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TPascalTypeFeatureTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FFeatures: TPascalTypeTableList<TPascalTypeAppleFeatureTable>;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  // table 'fvar'
  TVariationAxisRecord = packed record
    AxisTag      : TTableType;  // Axis name.
    MinValue     : TFixedPoint; // The minimum style coordinate for the axis.
    DefaultValue : TFixedPoint; // The default style coordinate for the axis.
    MaxValue     : TFixedPoint; // The maximum style coordinate for the axis.
    Flags        : Word;        // Set to zero.
    NameID       : Word;        // The designation in the 'name' table.
  end;

  TVariationInstancesRecord = packed record
    NameID      : Word; // The name of the defined instance coordinate. Similar to the nameID in the variation axis record, this identifies a name in the font's 'name' table.
    Flags       : Word; // Set to zero.
    Coordinates : array of TFixedPoint; // This is the coordinate of the defined instance.
    psNameID    : Word; // (Optional) The PostScript name of the defined instance coordinate. Similar to the nameID above, this identifies a name in the font's 'name' table. The corresponding 'name' table entry should be a valid PostScript name.
  end;

  // not entirely implemented, for more details see
  // https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6fvar.html
  TPascalTypeFontVariationTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FVariationAxes: array of TVariationAxisRecord;
    FInstances    : array of TVariationInstancesRecord;
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'hsty'

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6hsty.html
  TPascalTypeHorizontalStyleTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FExtraPlain     : SmallInt; // Extra space required when the font is not styled. Should be 0.
    FExtraBold      : SmallInt; // Extra space required when the font is boldfaced.
    FExtraItalic    : SmallInt; // Extra space required when the font is italicized.
    FExtraUnderline : SmallInt; // Extra space required when the font is underlined.
    FExtraOutline   : SmallInt; // Extra space required when the font is outlined.
    FExtraShadow    : SmallInt; // Extra space required when the font is shadowed.
    FExtraCondensed : SmallInt; // Extra space required when the font is condensed.
    FExtraExtended  : SmallInt; // Extra space required when the font is extended.
    procedure SetExtraBold(const Value: SmallInt);
    procedure SetExtraCondensed(const Value: SmallInt);
    procedure SetExtraExtended(const Value: SmallInt);
    procedure SetExtraItalic(const Value: SmallInt);
    procedure SetExtraOutline(const Value: SmallInt);
    procedure SetExtraPlain(const Value: SmallInt);
    procedure SetExtraShadow(const Value: SmallInt);
    procedure SetExtraUnderline(const Value: SmallInt);
  protected
    procedure ExtraBoldChanged; virtual;
    procedure ExtraCondensedChanged; virtual;
    procedure ExtraExtendedChanged; virtual;
    procedure ExtraItalicChanged; virtual;
    procedure ExtraOutlineChanged; virtual;
    procedure ExtraPlainChanged; virtual;
    procedure ExtraShadowChanged; virtual;
    procedure ExtraUnderlineChanged; virtual;
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property ExtraPlain: SmallInt read FExtraPlain write SetExtraPlain;
    property ExtraBold: SmallInt read FExtraBold write SetExtraBold;
    property ExtraItalic: SmallInt read FExtraItalic write SetExtraItalic;
    property ExtraUnderline: SmallInt read FExtraUnderline
      write SetExtraUnderline;
    property ExtraOutline: SmallInt read FExtraOutline write SetExtraOutline;
    property ExtraShadow: SmallInt read FExtraShadow write SetExtraShadow;
    property ExtraCondensed: SmallInt read FExtraCondensed
      write SetExtraCondensed;
    property ExtraExtended: SmallInt read FExtraExtended write SetExtraExtended;
  end;


  // table 'mort'

  TFeatureSubtableRecord = packed record
    FeatureType    : Word;     // The feature type.
    FeatureSetting : Word;     // The feature selector.
    EnableFlags    : Cardinal; // The OR’ed enable flags.
    DisableFlags   : Cardinal; // The AND’ed disable flags.
  end;

  TPascalTypeGlyphMetamorphosisChainTable = class(TCustomPascalTypeTable)
  private
    FDefaultFlags: Cardinal; // The default sub-feature flags for this chain.
    FFeatureArray: array of TFeatureSubtableRecord;
    procedure SetDefaultFlags(const Value: Cardinal);
    function GetFeatureCount: Cardinal;
    function GetFeature(Index: Cardinal): TFeatureSubtableRecord;
  protected
    procedure DefaultFlagsChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property DefaultFlags: Cardinal read FDefaultFlags write SetDefaultFlags;
    property FeatureCount: Cardinal read GetFeatureCount;
    property Feature[Index: Cardinal]: TFeatureSubtableRecord read GetFeature;
  end;

  TCustomPascalTypeGlyphMetamorphosisTable = class(TCustomPascalTypeNamedVersionTable)
  private
    function GetChainCount: Cardinal;
  protected
    FChains: TPascalTypeTableList<TPascalTypeGlyphMetamorphosisChainTable>;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    property ChainCount: Cardinal read GetChainCount;
  end;

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6mort.html
  TPascalTypeGlyphMetamorphosisTable = class(TCustomPascalTypeGlyphMetamorphosisTable)
  public
    class function GetTableType: TTableType; override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'morx'

  TPascalTypeExtendedGlyphMetamorphosisChainTable = class(TCustomPascalTypeTable)
  private
    FDefaultFlags: Cardinal; // The default sub-feature flags for this chain.
    FFeatureArray: array of TFeatureSubtableRecord;
    procedure SetDefaultFlags(const Value: Cardinal);
    function GetFeatureCount: Cardinal;
    function GetFeature(Index: Cardinal): TFeatureSubtableRecord;
  protected
    procedure DefaultFlagsChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property DefaultFlags: Cardinal read FDefaultFlags write SetDefaultFlags;
    property FeatureCount: Cardinal read GetFeatureCount;
    property Feature[Index: Cardinal]: TFeatureSubtableRecord read GetFeature;
  end;

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6morx.html
  TPascalTypeExtendedGlyphMetamorphosisTable = class(TCustomPascalTypeGlyphMetamorphosisTable)
  public
    class function GetTableType: TTableType; override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'opbd'

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6opbd.html
  TPascalTypeOpticalBoundsTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FFormat: Word;
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;


  // table 'prop'

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6prop.html
  TPascalTypeGlyphPropertiesTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FFormat : Word; // Format of the tracking table (set to 0).
    FDefault: Word; // Default properties applied to a glyph if that glyph is not present in the lookup table.
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  // table 'trak'
  TTrackTableEntryRecord = packed record
    Track: TFixedPoint; // Track value for this record.
    NameIndex: Word; // The 'name' table index for this track (a short Word or phrase like "loose" or "very tight"). NameIndex has a value greater than 255 and less than 32768.
    Offset: Word; // Offset from start of tracking table to per-size tracking values for this track.
  end;

  TPascalTypeTrackingDataTable = class(TCustomPascalTypeTable)
  private
    FTrackTable: array of TTrackTableEntryRecord; // Array[nTracks] of TrackTableEntry records.
    FSizeTable: array of TFixedPoint; // Array[nSizes] of size values.
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6trak.html
  TPascalTypeTrackingTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FFormat    : Word; // Format of the tracking table (set to 0).
    FHorizontal: TPascalTypeTrackingDataTable;
    FVertical  : TPascalTypeTrackingDataTable;
    procedure SetHorizontal(const Value: TPascalTypeTrackingDataTable);
    procedure SetVertical(const Value: TPascalTypeTrackingDataTable);
    procedure SetFormat(const Value: Word);
  protected
    procedure FormatChanged; virtual;
    procedure HorizontalChanged; virtual;
    procedure VerticalChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Format: Word read FFormat write SetFormat;
    property Horizontal: TPascalTypeTrackingDataTable read FHorizontal
      write SetHorizontal;
    property Vertical: TPascalTypeTrackingDataTable read FVertical
      write SetVertical;
  end;

  // table 'Zapf'
  TCustomPascalTypeZapfKindName = class(TCustomPascalTypeTable);

  TPascalTypeZapfKindNameString = class(TCustomPascalTypeZapfKindName)
  private
    FName: AnsiString;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Name: AnsiString read FName write FName;
  end;

  TPascalTypeZapfKindNameBinary = class(TCustomPascalTypeZapfKindName)
  private
    FValue: Word;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Value: Word read FValue write FValue;
  end;

  TZapfKindName = (zknUniversal = 0, zknApple = 1, zknAdobe = 2, zknAFII = 3,
    zknUnicode = 4, zknCidJapanese = 64, zknCidTraditionamChinese = 65,
    zknCidSimplifiedChinese = 66, zknCidKorean = 67, zknVersionHistory = 68,
    zknDesignerShortName = 69, zknDesignerLongName = 70,
    zknDesignerUsageNotes = 71, zknDesignerHistoricalNotes = 72);

  TPascalTypeZapfKindName = class(TCustomPascalTypeTable)
  private
    FKindType: TZapfKindName;
    FKindName: TCustomPascalTypeZapfKindName;
    procedure SetKindName(const Value: TCustomPascalTypeZapfKindName);
  protected
    procedure KindNameChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property KindName: TCustomPascalTypeZapfKindName read FKindName
      write SetKindName;
  end;

  TPascalTypeZapfGlyphInfoTable = class(TCustomPascalTypeTable)
  private
    FUnicodeCodePoints: array of Word; // Unicode code points for this glyph
    FKindNames        : array of TPascalTypeZapfKindName;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  // not entirely implemented, for more details see
  // http://developer.apple.com/fonts/TTRefMan/RM06/Chap6Zapf.html
  TPascalTypeZapfTable = class(TCustomPascalTypeNamedVersionTable)
  private
    FGlyphInfos: array of TPascalTypeZapfGlyphInfoTable;
    procedure ClearGlyphInfos;
  public
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

procedure RegisterDescriptionTag(TableClass: TPascalTypeTaggedValueTableClass);
procedure RegisterDescriptionTags(TableClasses: array of TPascalTypeTaggedValueTableClass);
function FindDescriptionTagByType(TableType: TTableType): TPascalTypeTaggedValueTableClass;

implementation

uses
  SysUtils,
  PT_Math,
  PT_ResourceStrings,
  PascalType.Tables.TrueType.maxp;

resourcestring
  RCStrGlyphIndexOrderError = 'Last glyph index is smaller than first!';
  RCStrUnknownBaselinePart = 'Unknown baseline part!';
  RCStrTooManySizePairs = 'More than two size pairs are not supported';
  RCStrTooFewSizePairs = 'At least 2 size pairs are are mandatory!';
  RCStrUnknownAxisSize = 'Unknown axis size';
  RCStrUnknownInstanceSize = 'Unknown instance size';

var
  GDescriptionTagClasses: array of TPascalTypeTaggedValueTableClass;


{ TCustomPascalTypeNamedVersionTable }

constructor TCustomPascalTypeNamedVersionTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 1;
end;

procedure TCustomPascalTypeNamedVersionTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomPascalTypeNamedVersionTable then
    FVersion := TCustomPascalTypeNamedVersionTable(Source).FVersion;
end;

procedure TCustomPascalTypeNamedVersionTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value32: Cardinal;
begin
  inherited;

  with Stream do
  begin
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    Read(Value32, SizeOf(TFixedPoint));
    FVersion.Fixed := Swap32(Value32);

    if Version.Value < 1 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);
  end;
end;

procedure TCustomPascalTypeNamedVersionTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write version
  WriteSwappedCardinal(Stream, Cardinal(FVersion));
end;

procedure TCustomPascalTypeNamedVersionTable.SetVersion
  (const Value: TFixedPoint);
begin
  if (FVersion.Value <> Value.Value) or (FVersion.Fract <> Value.Fract) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TCustomPascalTypeNamedVersionTable.VersionChanged;
begin
  Changed;
end;


{ TCustomPascalTypeBinarySearchingTable }

procedure TCustomPascalTypeBinarySearchingTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomPascalTypeBinarySearchingTable then
  begin
    FUnitSize := TCustomPascalTypeBinarySearchingTable(Source).FUnitSize;
    FnUnits := TCustomPascalTypeBinarySearchingTable(Source).FnUnits;
  end;
end;

procedure TCustomPascalTypeBinarySearchingTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 10 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read unit size
  FUnitSize := BigEndianValueReader.ReadWord(Stream);

  // read unit count
  FnUnits := BigEndianValueReader.ReadWord(Stream);

  Stream.Seek(3* SizeOf(Word), soFromCurrent);
end;

procedure TCustomPascalTypeBinarySearchingTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TCustomPascalTypeAccentAttachmentDescriptionTable }

procedure TCustomPascalTypeAccentAttachmentDescriptionTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomPascalTypeAccentAttachmentDescriptionTable then
    FPrimaryGlyphIndex := TCustomPascalTypeAccentAttachmentDescriptionTable(Source).FPrimaryGlyphIndex;
end;

procedure TCustomPascalTypeAccentAttachmentDescriptionTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value16: Word;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    Value16 := BigEndianValueReader.ReadWord(Stream);
    FPrimaryGlyphIndex := (Value16 and $7FFF);

{$IFDEF Ambigious Exceptions}
    if not((Value16 and $8000) <> 0) = IsFormat1) then
      raise EPascalTypeError.Create('Format mismatch!');
{$ENDIF}
  end;
end;

procedure TCustomPascalTypeAccentAttachmentDescriptionTable.SaveToStream(
  Stream: TStream);
var
  Value16: Word;
begin
  inherited;

  // build value containing both format and glyph index and write to stream
  Value16 := Word(GetIsFormat1) + (FPrimaryGlyphIndex shr 1);
  WriteSwappedWord(Stream, Value16);
end;


{ TPascalTypeAccentAttachmentDescriptionFormat0Table }

procedure TPascalTypeAccentAttachmentDescriptionFormat0Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeAccentAttachmentDescriptionFormat0Table then
  begin
    FPrimaryAttachmentPoint := TPascalTypeAccentAttachmentDescriptionFormat0Table(Source).FPrimaryAttachmentPoint;
    FSecondaryInfoIndex := TPascalTypeAccentAttachmentDescriptionFormat0Table(Source).FSecondaryInfoIndex;
  end;
end;

class function TPascalTypeAccentAttachmentDescriptionFormat0Table.GetIsFormat1: Boolean;
begin
  Result := False;
end;

procedure TPascalTypeAccentAttachmentDescriptionFormat0Table.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read primary attachment point
    Read(FPrimaryAttachmentPoint, 1);

    // read secondary info index
    Read(FSecondaryInfoIndex, 1);
  end;
end;

procedure TPascalTypeAccentAttachmentDescriptionFormat0Table.SaveToStream
  (Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // write primary attachment point
    Write(FPrimaryAttachmentPoint, 1);

    // write secondary info index
    Write(FSecondaryInfoIndex, 1);
  end;
end;


{ TPascalTypeAccentAttachmentDescriptionFormat1Table }

procedure TPascalTypeAccentAttachmentDescriptionFormat1Table.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeAccentAttachmentDescriptionFormat1Table then
    FExtensionOffset := TPascalTypeAccentAttachmentDescriptionFormat1Table(Source).FExtensionOffset;
end;

class function TPascalTypeAccentAttachmentDescriptionFormat1Table.GetIsFormat1: Boolean;
begin
  Result := True;
end;

procedure TPascalTypeAccentAttachmentDescriptionFormat1Table.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read extension offset
    FExtensionOffset := BigEndianValueReader.ReadWord(Stream);
  end;
end;

procedure TPascalTypeAccentAttachmentDescriptionFormat1Table.SaveToStream(Stream: TStream);
begin
  inherited;

  // write extension offset
  WriteSwappedWord(Stream, FExtensionOffset);
end;


{ TPascalTypeAccentAttachmentTable }

procedure TPascalTypeAccentAttachmentTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeAccentAttachmentTable then
  begin
    FFirstAccentGlyphIndex := TPascalTypeAccentAttachmentTable(Source).FFirstAccentGlyphIndex;
    FLastAccentGlyphIndex  := TPascalTypeAccentAttachmentTable(Source).FLastAccentGlyphIndex;
  end;
end;

class function TPascalTypeAccentAttachmentTable.GetTableType: TTableType;
begin
  Result := 'acnt';
end;

procedure TPascalTypeAccentAttachmentTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  GlyphIndex: Cardinal;
  DescOffset: Cardinal;
  ExtOffset: Cardinal;
  SecOffset: Cardinal;
  Description: TCustomPascalTypeAccentAttachmentDescriptionTable;
  Value16: Word;
  Format:  Byte;
begin
  inherited;

  with Stream do
  begin
    // remember start position
    StartPos := Position;

    // read first glyph
    Read(Value16, SizeOf(Word));
    FFirstAccentGlyphIndex := Swap16(Value16);

    // read last glyph
    Read(Value16, SizeOf(Word));
    FLastAccentGlyphIndex := Swap16(Value16);

{$IFDEF AmbigiousExceptions}
    if FLastAccentGlyphIndex < FFirstAccentGlyphIndex then
      raise EPascalTypeError.Create(RCStrGlyphIndexOrderError);
{$ENDIF}
    // read description offset
    DescOffset := BigEndianValueReader.ReadCardinal(Stream);

    // read extension offset
    ExtOffset := BigEndianValueReader.ReadCardinal(Stream);

    // read secondary offset
    SecOffset := BigEndianValueReader.ReadCardinal(Stream);

    // locate description subtable position
    Position := StartPos + DescOffset;
    for GlyphIndex := 0 to (FLastAccentGlyphIndex - FFirstAccentGlyphIndex) - 1 do
    begin
      Read(Format, 1);
      Seek(0, soFromBeginning);

      // identify format
      if (Format and $80) <> 0 then
        Description := TPascalTypeAccentAttachmentDescriptionFormat0Table.Create
      else
        Description := TPascalTypeAccentAttachmentDescriptionFormat1Table.Create;

      // read description from stream
      Description.LoadFromStream(Stream);
    end;

    // locate extention subtable position
    Position := StartPos + ExtOffset;

    // TODO: read extention

    // locate secondary data subtable position
    Position := StartPos + SecOffset;

    // TODO: read secondary data
  end;
end;

procedure TPascalTypeAccentAttachmentTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write first glyph
  WriteSwappedWord(Stream, FFirstAccentGlyphIndex);

  // write last glyph
  WriteSwappedWord(Stream, FLastAccentGlyphIndex);
end;


{ TPascalTypeAxisVariationSegmentTable }

procedure TPascalTypeAxisVariationSegmentTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeAxisVariationSegmentTable then
    FCorrespondenceArray := TPascalTypeAxisVariationSegmentTable(Source).FCorrespondenceArray;
end;

procedure TPascalTypeAxisVariationSegmentTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  PairIndex: Integer;
begin
  inherited;

  // read pair count
  SetLength(FCorrespondenceArray, BigEndianValueReader.ReadWord(Stream));

  for PairIndex := 0 to High(FCorrespondenceArray) do
  begin
    FCorrespondenceArray[PairIndex].fromCoord := BigEndianValueReader.ReadSmallInt(Stream);
    FCorrespondenceArray[PairIndex].toCoord := BigEndianValueReader.ReadSmallInt(Stream);
  end;
end;

procedure TPascalTypeAxisVariationSegmentTable.SaveToStream(Stream: TStream);
var
  PairIndex: Integer;
begin
  inherited;

  // write pair count
  WriteSwappedWord(Stream, Length(FCorrespondenceArray));

  for PairIndex := 0 to High(FCorrespondenceArray) do
  begin
    // write 'from' coordinate
    WriteSwappedSmallInt(Stream, FCorrespondenceArray[PairIndex].fromCoord);

    // write 'to' coordinate
    WriteSwappedSmallInt(Stream, FCorrespondenceArray[PairIndex].toCoord);
  end;
end;


{ TPascalTypeAxisVariationTable }

constructor TPascalTypeAxisVariationTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FSegments := TPascalTypeTableList<TPascalTypeAxisVariationSegmentTable>.Create;
end;

destructor TPascalTypeAxisVariationTable.Destroy;
begin
  FreeAndNil(FSegments);
  inherited;
end;

procedure TPascalTypeAxisVariationTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeAxisVariationTable then
    FSegments.Assign(TPascalTypeAxisVariationTable(Source).FSegments);
end;

class function TPascalTypeAxisVariationTable.GetTableType: TTableType;
begin
  Result := 'avar';
end;

procedure TPascalTypeAxisVariationTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value32: Cardinal;
  AxisCount: Cardinal;
  AxisIndex: Cardinal;
  Segment: TPascalTypeAxisVariationSegmentTable;
begin
  inherited;

  with Stream do
  begin
    // read axis count
    Read(Value32, SizeOf(Cardinal));
    AxisCount := Swap32(Value32);

    for AxisIndex := 0 to AxisCount - 1 do
    begin
      // create segment object
      // add segment to segment list
      Segment := FSegments.Add;

      // load segment from stream
      Segment.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeAxisVariationTable.SaveToStream(Stream: TStream);
var
  AxisIndex: Cardinal;
begin
  inherited;

  // write axis count
  WriteSwappedCardinal(Stream, FSegments.Count);

  for AxisIndex := 0 to FSegments.Count - 1 do
    with TPascalTypeAxisVariationSegmentTable(FSegments[AxisIndex]) do
    begin
      // save segment to stream
      SaveToStream(Stream);
    end;
end;


{ TPascalTypeBaselinePartFormat0Table }

procedure TPascalTypeBaselinePartFormat0Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeBaselinePartFormat0Table then
    FDeltas := TPascalTypeBaselinePartFormat0Table(Source).FDeltas;
end;

procedure TPascalTypeBaselinePartFormat0Table.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  DeltaIndex: Word;
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 64 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read 32 delta values (a value of 0 means no delta ;-)
    for DeltaIndex := 0 to High(FDeltas) do
      FDeltas[DeltaIndex] :=
        BigEndianValueReader.ReadWord(Stream);
  end;
end;

procedure TPascalTypeBaselinePartFormat0Table.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeBaselinePartFormat1Table }

procedure TPascalTypeBaselinePartFormat1Table.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeBaselinePartFormat1Table then
    // TPascalTypeBaselinePartFormat1Table(Source)
    ;
end;

procedure TPascalTypeBaselinePartFormat1Table.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

end;

procedure TPascalTypeBaselinePartFormat1Table.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeBaselineTable }

procedure TPascalTypeBaselineTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeBaselineTable then
  begin
    FFormat := TPascalTypeBaselineTable(Source).FFormat;
    FDefaultBaseline := TPascalTypeBaselineTable(Source).FDefaultBaseline;
    FreeAndNil(FBaselinePart);
    case FFormat of
      0: FBaselinePart := TPascalTypeBaselinePartFormat0Table.Create;
      1: FBaselinePart := TPascalTypeBaselinePartFormat1Table.Create;
    end;
    if (FBaselinePart <> nil) then
      FBaselinePart.Assign(TPascalTypeBaselineTable(Source).FBaselinePart);
  end;
end;

destructor TPascalTypeBaselineTable.Destroy;
begin
  FreeAndNil(FBaselinePart);
  inherited;
end;

class function TPascalTypeBaselineTable.GetTableType: TTableType;
begin
  Result := 'bsln';
end;

procedure TPascalTypeBaselineTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value16: Word;
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read format
    Read(Value16, SizeOf(Word));
    FFormat := Swap16(Value16);

    // read default baseline
    Read(Value16, SizeOf(Word));
    FDefaultBaseline := Swap16(Value16);

    case FFormat of
      0: FBaselinePart := TPascalTypeBaselinePartFormat0Table.Create;
      1: FBaselinePart := TPascalTypeBaselinePartFormat1Table.Create;
      2: raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
      3: raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
      else
        raise EPascalTypeError.Create(RCStrUnknownBaselinePart);
    end;
  end;
end;

procedure TPascalTypeBaselineTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write format
  WriteSwappedWord(Stream, FFormat);

  // write default baseline
  WriteSwappedWord(Stream, FDefaultBaseline);

  // write baseline part to stream
  if (FBaselinePart <> nil) then
    FBaselinePart.SaveToStream(Stream);
end;


{ TPascalTypeBitmapHeaderTable }

class function TPascalTypeBitmapHeaderTable.GetTableType: TTableType;
begin
  Result := 'bhed';
end;


{ TPascalTypeBitmapLocationTable }

constructor TPascalTypeBitmapLocationTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FBitmapSizeList := TPascalTypeTableList<TPascalTypeBitmapSizeTable>.Create;
end;

destructor TPascalTypeBitmapLocationTable.Destroy;
begin
  FreeAndNil(FBitmapSizeList);
  inherited;
end;

procedure TPascalTypeBitmapLocationTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeBitmapLocationTable then
    FBitmapSizeList.Assign(TPascalTypeBitmapLocationTable(Source).FBitmapSizeList);
end;

function TPascalTypeBitmapLocationTable.GetBitmapSizeTable(Index: Integer)
: TPascalTypeBitmapSizeTable;
begin
  if (Index >= 0) and (Index < FBitmapSizeList.Count) then
    Result := FBitmapSizeList[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TPascalTypeBitmapLocationTable.GetBitmapSizeTableCount: Integer;
begin
  Result := FBitmapSizeList.Count;
end;

class function TPascalTypeBitmapLocationTable.GetTableType: TTableType;
begin
  Result := 'bloc';
end;

procedure TPascalTypeBitmapLocationTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value32: Cardinal;
  BitmapSizeCount: Cardinal;
  BitmapSizeIndex: Integer;
  BitmapSizeTable: TPascalTypeBitmapSizeTable;
begin
  inherited;

  with Stream do
  begin
    // read number of BitmapSize tables
    Read(Value32, SizeOf(Cardinal));
    BitmapSizeCount := Swap32(Value32);

    // read bitmap size tables
    for BitmapSizeIndex := 0 to BitmapSizeCount - 1 do
    begin
      // create bitmap size table
      // add bitmap size table
      BitmapSizeTable := FBitmapSizeList.Add;

      // load bitmap size table
      BitmapSizeTable.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeBitmapLocationTable.SaveToStream(Stream: TStream);
var
  BitmapSizeIndex: Integer;
begin
  inherited;

  // write number of BitmapSize tables
  WriteSwappedCardinal(Stream, FBitmapSizeList.Count);

  // write bitmap size tables
  for BitmapSizeIndex := 0 to FBitmapSizeList.Count - 1 do
    // save bitmap size table to stream
    FBitmapSizeList[BitmapSizeIndex].SaveToStream(Stream);
end;


{ TPascalTypeBitmapDataTable }

procedure TPascalTypeBitmapDataTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is Self.ClassType then
    // TPascalTypeBitmapDataTable(Source)
    ;
end;

class function TPascalTypeBitmapDataTable.GetTableType: TTableType;
begin
  Result := 'bdat';
end;

procedure TPascalTypeBitmapDataTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;
end;

procedure TPascalTypeBitmapDataTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TCustomPascalTypeTaggedValueTable }

procedure TCustomPascalTypeTaggedValueTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TCustomPascalTypeTaggedValueTable then
    FValue := TCustomPascalTypeTaggedValueTable(Source).FValue;
end;

procedure TCustomPascalTypeTaggedValueTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value32: Cardinal;
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read value
    Read(Value32, SizeOf(Cardinal));
    FValue.Fixed := Swap32(Value32);
  end;
end;

procedure TCustomPascalTypeTaggedValueTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write value
  WriteSwappedCardinal(Stream, Cardinal(FValue));
end;

procedure TCustomPascalTypeTaggedValueTable.ValueChanged;
begin
  Changed;
end;


{ TPascalTypeWeightValueTable }

class function TPascalTypeWeightValueTable.GetTableType: TTableType;
begin
  Result := 'wght';
end;

procedure TPascalTypeWeightValueTable.SetValue(const Value: TFixedPoint);
begin
  if (FValue.Fract <> Value.Fract) or (FValue.Value <> Value.Value) then
  begin
    FValue := Value;
    ValueChanged;
  end;
end;


{ TPascalTypeWidthValueTable }

class function TPascalTypeWidthValueTable.GetTableType: TTableType;
begin
  Result := 'wdth';
end;

procedure TPascalTypeWidthValueTable.SetValue(const Value: TFixedPoint);
begin
  if (FValue.Fract <> Value.Fract) or (FValue.Value <> Value.Value) then
  begin
    FValue := Value;
    ValueChanged;
  end;
end;


{ TPascalTypeSlantValueTable }

class function TPascalTypeSlantValueTable.GetTableType: TTableType;
begin
  Result := 'slnt';
end;

procedure TPascalTypeSlantValueTable.SetValue(const Value: TFixedPoint);
begin
  if (FValue.Fract <> Value.Fract) or (FValue.Value <> Value.Value) then
  begin
    FValue := Value;
    ValueChanged;
  end;
end;


{ TPascalTypeOpticalSizeValueTable }

class function TPascalTypeOpticalSizeValueTable.GetTableType: TTableType;
begin
  Result := 'opsz';
end;

procedure TPascalTypeOpticalSizeValueTable.SetValue(
  const Value: TFixedPoint);
begin
  if (FValue.Fract <> Value.Fract) or (FValue.Value <> Value.Value) then
  begin
    FValue := Value;
    ValueChanged;
  end;
end;


{ TPascalTypeNonAlphabeticValueTable }

class function TPascalTypeNonAlphabeticValueTable.GetTableType: TTableType;
begin
  Result := 'nalt';
end;

function TPascalTypeNonAlphabeticValueTable.GetCode: TNonAlphabeticCode;
begin
  Result := FixedPointToNonAlphabeticCode(FValue);
end;

procedure TPascalTypeNonAlphabeticValueTable.SetCode(
  const Value: TNonAlphabeticCode);
begin
  if (FixedPointToNonAlphabeticCode(FValue) <> Value) then
  begin
    FValue := NonAlphabeticCodeToFixedPoint(Value);
    ValueChanged;
  end;
end;


{ TPascalTypeFontDescriptionTable }

constructor TPascalTypeFontDescriptionTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FDescritors := TPascalTypeTableList<TCustomPascalTypeTaggedValueTable>.Create;
end;

destructor TPascalTypeFontDescriptionTable.Destroy;
begin
  FreeAndNil(FDescritors);
  inherited;
end;

procedure TPascalTypeFontDescriptionTable.Assign(Source: TPersistent);
var
  i: integer;
  TagClass: TPascalTypeTaggedValueTableClass;
  Descritor: TCustomPascalTypeTaggedValueTable;
begin
  inherited;

  if Source is TPascalTypeFontDescriptionTable then
  begin
    FDescritors.Clear;

    for i := 0 to TPascalTypeFontDescriptionTable(Source).FDescritors.Count-1 do
    begin
      TagClass := TPascalTypeTaggedValueTableClass(TCustomPascalTypeTaggedValueTable(TPascalTypeFontDescriptionTable(Source).FDescritors[i]).ClassType);
      Descritor := FDescritors.Add(TagClass);

      Descritor.Assign(TCustomPascalTypeTaggedValueTable(TPascalTypeFontDescriptionTable(Source).FDescritors[i]));
    end;
  end;
end;

class function TPascalTypeFontDescriptionTable.GetTableType: TTableType;
begin
  Result := 'fdsc';
end;

procedure TPascalTypeFontDescriptionTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value32:  Cardinal;
  DescCount: Cardinal;
  DescIndex: Cardinal;
  TagClass: TPascalTypeTaggedValueTableClass;
  Descritor: TCustomPascalTypeTaggedValueTable;
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read description count
    Read(Value32, SizeOf(Cardinal));
    DescCount := Swap32(Value32);

    for DescIndex := 0 to DescCount - 1 do
    begin
      // read tag
      Read(Value32, SizeOf(Cardinal));

      // find description class by tag
      TagClass := FindDescriptionTagByType(TTableType(Value32));

      // read tag
      if (TagClass <> nil) then
      begin
        // create descriptor
        Descritor := TagClass.Create;

        // read descriptor from stream
        Descritor.LoadFromStream(Stream);

        // add descriptor to descriptor list
        FDescritors.Add(Descritor);
      end else
        Seek(4, soFromCurrent);
    end;
  end;
end;

procedure TPascalTypeFontDescriptionTable.SaveToStream(Stream: TStream);
var
  Value32: Cardinal;
  DescIndex: Cardinal;
begin
  inherited;

  with Stream do
  begin
    // write description count
    WriteSwappedCardinal(Stream, FDescritors.Count);

    for DescIndex := 0 to FDescritors.Count - 1 do
      with FDescritors[DescIndex] do
      begin
        // write tag
        Value32 := Cardinal(TableType);
        Write(Value32, SizeOf(Cardinal));

        // write descriptor to stream
        SaveToStream(Stream);
      end;
  end;
end;


{ TPascalTypeAppleFeatureTable }

procedure TPascalTypeAppleFeatureTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeAppleFeatureTable then
  begin
    FFeature := TPascalTypeAppleFeatureTable(Source).FFeature;
    FNumSettings := TPascalTypeAppleFeatureTable(Source).FNumSettings;
    FSettingTable := TPascalTypeAppleFeatureTable(Source).FSettingTable;
    FFeatureFlags := TPascalTypeAppleFeatureTable(Source).FFeatureFlags;
    FNameIndex := TPascalTypeAppleFeatureTable(Source).FNameIndex;
  end;
end;

procedure TPascalTypeAppleFeatureTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 12 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read feature
    FFeature := BigEndianValueReader.ReadWord(Stream);

    // read settings count
    FNumSettings := BigEndianValueReader.ReadWord(Stream);

    // read setting table offset
    FSettingTable := BigEndianValueReader.ReadCardinal(Stream);

    // read feature flags
    FFeatureFlags := BigEndianValueReader.ReadWord(Stream);

    // read name index
    FNameIndex := BigEndianValueReader.ReadSmallInt(Stream);
  end;
end;

procedure TPascalTypeAppleFeatureTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeFeatureTable }

constructor TPascalTypeFeatureTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FFeatures := TPascalTypeTableList<TPascalTypeAppleFeatureTable>.Create;
end;

destructor TPascalTypeFeatureTable.Destroy;
begin
  FreeAndNil(FFeatures);
  inherited;
end;

procedure TPascalTypeFeatureTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeFeatureTable then
    FFeatures.Assign(TPascalTypeFeatureTable(Source).FFeatures);
end;

class function TPascalTypeFeatureTable.GetTableType: TTableType;
begin
  Result := 'feat';
end;

procedure TPascalTypeFeatureTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  FeatureNameCount: Word;
  FeatureNameIndex: Word;
  AppleFeature: TPascalTypeAppleFeatureTable;
{$IFDEF AmbigiousExceptions}
    Value32: Cardinal; Value16: Word;
{$ENDIF}
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read feature name count
    FeatureNameCount := BigEndianValueReader.ReadWord(Stream);

{$IFDEF AmbigiousExceptions}
    Read(Value16, SizeOf(Word));
    if Value16 <> 0 then raise EPascalTypeError.CreateFmt(RCStrReservedValueError, [Swap16(Value16)]);

    Read(Value32, SizeOf(Cardinal));
    if Value32 <> 0 then raise EPascalTypeError.CreateFmt(RCStrReservedValueError, [Swap32(Value32)]);
{$ELSE}
    Seek(6, soFromCurrent);
{$ENDIF}
    for FeatureNameIndex := 0 to FeatureNameCount - 1 do
    begin
      // create apple feature
      // add feature to list
      AppleFeature := FFeatures.Add;

      // load apple feature from stream
      AppleFeature.LoadFromStream(Stream);
    end;

  end;
end;

procedure TPascalTypeFeatureTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeFontVariationTable }

procedure TPascalTypeFontVariationTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeFontVariationTable then
  begin
    FVariationAxes := TPascalTypeFontVariationTable(Source).FVariationAxes;
    FInstances := TPascalTypeFontVariationTable(Source).FInstances;
  end;
end;

class function TPascalTypeFontVariationTable.GetTableType: TTableType;
begin
  Result := 'fvar';
end;

procedure TPascalTypeFontVariationTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos:  Int64;
  OffsetToData: Word;
  // Offset in bytes from the beginning of the table to the beginning of the first axis data.
  CountSizePairs: Word; // Axis + instance = 2.
  AxisIndex: Word;
  AxisSize:  Word;
  // The number of bytes in each gxFontVariationAxis record. Set to 20 bytes.
  InstIndex: Word;
  InstSize:  Word;
  // The number of bytes in each gxFontInstance array. InstanceSize = axisCount * sizeof(gxShortFrac).
begin
  // remember start position
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 6*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read offset to data
  OffsetToData := BigEndianValueReader.ReadWord(Stream);

  // read size pair count
  CountSizePairs := BigEndianValueReader.ReadWord(Stream);

  // check size pair count
  if CountSizePairs < 2 then
    raise EPascalTypeError.Create(RCStrTooFewSizePairs);

{$IFDEF AmbigiousExceptions}
  // ambigious size pair count check
  if CountSizePairs > 2 then
    raise EPascalTypeError.Create(RCStrTooManySizePairs);
{$ENDIF}
  // read axis count
  SetLength(FVariationAxes, BigEndianValueReader.ReadWord(Stream));

  // read axis size
  AxisSize := BigEndianValueReader.ReadWord(Stream);

  // check axis size
  if AxisSize < 20 then
    raise EPascalTypeError.Create(RCStrUnknownAxisSize);

{$IFDEF AmbigiousExceptions}
  // ambigious axis size check
  if AxisSize > 20 then
    raise EPascalTypeError.Create(RCStrUnknownAxisSize);
{$ENDIF}
  // read instance count
  SetLength(FInstances, BigEndianValueReader.ReadWord(Stream));

  // read instance size
  InstSize := BigEndianValueReader.ReadWord(Stream);

  // check instance size
  if InstSize < (2*SizeOf(Word) + Length(FVariationAxes) * SizeOf(TFixedPoint)) then
    raise EPascalTypeError.Create(RCStrUnknownInstanceSize);

{$IFDEF AmbigiousExceptions}
  // The instanceSize will have one of two values: 2 × sizeof(uint16_t) + axisCount × sizeof(Fixed), or 3 × sizeof(uint16_t) + axisCount × sizeof(Fixed).
  if InstSize > (3*SizeOf(Word) + Length(FVariationAxes) * SizeOf(TFixedPoint)) then
    raise EPascalTypeError.Create(RCStrUnknownInstanceSize);
{$ENDIF}
  // locate data
  Stream.Position := StartPos + OffsetToData;

  // check (minimum) table size
  if Stream.Position + Length(FVariationAxes) * AxisSize + Length(FInstances) * InstSize > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read data
  for AxisIndex := 0 to High(FVariationAxes) do
  begin
    // read axis tag
    Stream.Read(FVariationAxes[AxisIndex].AxisTag, SizeOf(TTableType));

    // read minimum style coordinate for the axis
    FVariationAxes[AxisIndex].MinValue.Fixed := BigEndianValueReader.ReadCardinal(Stream);

    // read default style coordinate for the axis
    FVariationAxes[AxisIndex].DefaultValue.Fixed := BigEndianValueReader.ReadCardinal(Stream);

    // read maximum style coordinate for the axis
    FVariationAxes[AxisIndex].MaxValue.Fixed := BigEndianValueReader.ReadCardinal(Stream);

    // read flags (set to 0!)
    FVariationAxes[AxisIndex].Flags := BigEndianValueReader.ReadWord(Stream);

{$IFDEF AmbigiousExceptions}
    // ambigious axis size check
    if FVariationAxes[AxisIndex].Flags <> 0 then
      raise EPascalTypeError.Create(RCStrReservedValueError);
{$ENDIF}
    // read name ID
    FVariationAxes[AxisIndex].NameID := BigEndianValueReader.ReadWord(Stream);
  end;

  for InstIndex := 0 to High(FInstances) do
  begin
    // read name ID
    FInstances[InstIndex].NameID := BigEndianValueReader.ReadWord(Stream);

    // read flags (set to 0!)
    FInstances[InstIndex].Flags := BigEndianValueReader.ReadWord(Stream);

    // set coordinate count
    SetLength(FInstances[InstIndex].Coordinates, Length(FVariationAxes));

    // read coordinates
    for AxisIndex := 0 to High(FVariationAxes) do
      FInstances[InstIndex].Coordinates[AxisIndex].Fixed := BigEndianValueReader.ReadCardinal(Stream);

    if InstSize = (3*SizeOf(Word) + Length(FVariationAxes) * SizeOf(TFixedPoint)) then
      FInstances[InstIndex].psNameID := BigEndianValueReader.ReadWord(Stream)
    else
      FInstances[InstIndex].psNameID := 0;
  end;
end;

procedure TPascalTypeFontVariationTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeGlyphPropertiesTable }

procedure TPascalTypeGlyphPropertiesTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeGlyphPropertiesTable then
  begin
    FFormat  := TPascalTypeGlyphPropertiesTable(Source).FFormat;
    FDefault := TPascalTypeGlyphPropertiesTable(Source).FDefault;
  end;
end;

class function TPascalTypeGlyphPropertiesTable.GetTableType: TTableType;
begin
  Result := 'prop';
end;

procedure TPascalTypeGlyphPropertiesTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value16: Word;
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read format
    Read(Value16, SizeOf(Word));
    FFormat := Swap16(Value16);

    // read default
    Read(Value16, SizeOf(Word));
    FDefault := Swap16(Value16);
  end;
end;

procedure TPascalTypeGlyphPropertiesTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write format
  WriteSwappedWord(Stream, FFormat);

  // write default
  WriteSwappedWord(Stream, FDefault);
end;


{ TPascalTypeHorizontalStyleTable }

procedure TPascalTypeHorizontalStyleTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeHorizontalStyleTable then
  begin
    FExtraPlain := TPascalTypeHorizontalStyleTable(Source).FExtraPlain;
    FExtraBold  := TPascalTypeHorizontalStyleTable(Source).FExtraBold;
    FExtraItalic := TPascalTypeHorizontalStyleTable(Source).FExtraItalic;
    FExtraUnderline := TPascalTypeHorizontalStyleTable(Source).FExtraUnderline;
    FExtraOutline := TPascalTypeHorizontalStyleTable(Source).FExtraOutline;
    FExtraShadow := TPascalTypeHorizontalStyleTable(Source).FExtraShadow;
    FExtraCondensed := TPascalTypeHorizontalStyleTable(Source).FExtraCondensed;
    FExtraExtended := TPascalTypeHorizontalStyleTable(Source).FExtraExtended;
  end;
end;

class function TPascalTypeHorizontalStyleTable.GetTableType: TTableType;
begin
  Result := 'hsty';
end;

procedure TPascalTypeHorizontalStyleTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read extra plain
    FExtraPlain := BigEndianValueReader.ReadWord(Stream);

    // read extra bold
    FExtraBold := BigEndianValueReader.ReadWord(Stream);

    // read extra italic
    FExtraItalic := BigEndianValueReader.ReadWord(Stream);

    // read extra underline
    FExtraUnderline := BigEndianValueReader.ReadWord(Stream);

    // read extra outline
    FExtraOutline := BigEndianValueReader.ReadWord(Stream);

    // read extra shadow
    FExtraShadow := BigEndianValueReader.ReadWord(Stream);

    // read extra condensed
    FExtraCondensed := BigEndianValueReader.ReadWord(Stream);

    // read extra extended
    FExtraExtended := BigEndianValueReader.ReadWord(Stream);
  end;
end;

procedure TPascalTypeHorizontalStyleTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write extra plain
  WriteSwappedWord(Stream, FExtraPlain);

  // write extra bold
  WriteSwappedWord(Stream, FExtraBold);

  // write extra italic
  WriteSwappedWord(Stream, FExtraItalic);

  // write extra underline
  WriteSwappedWord(Stream, FExtraUnderline);

  // write extra outline
  WriteSwappedWord(Stream, FExtraOutline);

  // write extra shadow
  WriteSwappedWord(Stream, FExtraShadow);

  // write extra condensed
  WriteSwappedWord(Stream, FExtraCondensed);

  // write extra extended
  WriteSwappedWord(Stream, FExtraExtended);
end;

procedure TPascalTypeHorizontalStyleTable.ExtraBoldChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalStyleTable.ExtraCondensedChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalStyleTable.ExtraExtendedChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalStyleTable.ExtraItalicChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalStyleTable.ExtraOutlineChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalStyleTable.ExtraPlainChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalStyleTable.ExtraShadowChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalStyleTable.ExtraUnderlineChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalStyleTable.SetExtraBold(
  const Value: smallint);
begin
  if FExtraBold <> Value then
  begin
    FExtraBold := Value;
    ExtraBoldChanged;
  end;
end;

procedure TPascalTypeHorizontalStyleTable.SetExtraCondensed(
  const Value: smallint);
begin
  if FExtraCondensed <> Value then
  begin
    FExtraCondensed := Value;
    ExtraCondensedChanged;
  end;
end;

procedure TPascalTypeHorizontalStyleTable.SetExtraExtended(
  const Value: smallint);
begin
  if FExtraExtended <> Value then
  begin
    FExtraExtended :=
      Value;
    ExtraExtendedChanged;
  end;
end;

procedure TPascalTypeHorizontalStyleTable.SetExtraItalic(
  const Value: smallint);
begin
  if FExtraItalic <> Value then
  begin
    FExtraItalic :=
      Value;
    ExtraItalicChanged;
  end;
end;

procedure TPascalTypeHorizontalStyleTable.SetExtraOutline(
  const Value: smallint);
begin
  if FExtraOutline <> Value then
  begin
    FExtraOutline :=
      Value;
    ExtraOutlineChanged;
  end;
end;

procedure TPascalTypeHorizontalStyleTable.SetExtraPlain(
  const Value: smallint);
begin
  if FExtraPlain <> Value then
  begin
    FExtraPlain :=
      Value;
    ExtraPlainChanged;
  end;
end;

procedure TPascalTypeHorizontalStyleTable.SetExtraShadow(
  const Value: smallint);
begin
  if FExtraShadow <> Value then
  begin
    FExtraShadow :=
      Value;
    ExtraShadowChanged;
  end;
end;

procedure TPascalTypeHorizontalStyleTable.SetExtraUnderline(
  const Value: smallint);
begin
  if FExtraUnderline <> Value then
  begin
    FExtraUnderline := Value;
    ExtraUnderlineChanged;
  end;
end;


{ TCustomPascalTypeGlyphMetamorphosisTable }

constructor TCustomPascalTypeGlyphMetamorphosisTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FChains := TPascalTypeTableList<TPascalTypeGlyphMetamorphosisChainTable>.Create;
end;

destructor TCustomPascalTypeGlyphMetamorphosisTable.Destroy;
begin
  FreeAndNil(FChains);
  inherited;
end;

function TCustomPascalTypeGlyphMetamorphosisTable.GetChainCount: Cardinal;
begin
  Result := FChains.Count;
end;

procedure TCustomPascalTypeGlyphMetamorphosisTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TCustomPascalTypeGlyphMetamorphosisTable then
    FChains.Assign(TCustomPascalTypeGlyphMetamorphosisTable(Source).FChains);
end;

{ TPascalTypeGlyphMetamorphosisChainTable }

procedure TPascalTypeGlyphMetamorphosisChainTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeGlyphMetamorphosisChainTable then
  begin
    FDefaultFlags := TPascalTypeGlyphMetamorphosisChainTable(Source).FDefaultFlags;
    FFeatureArray := TPascalTypeGlyphMetamorphosisChainTable(Source).FFeatureArray;
  end;
end;

function TPascalTypeGlyphMetamorphosisChainTable.GetFeature(Index: Cardinal): TFeatureSubtableRecord;
begin
  if (Index < Cardinal(Length(FFeatureArray))) then
    Result := FFeatureArray[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TPascalTypeGlyphMetamorphosisChainTable.GetFeatureCount: Cardinal;
begin
  Result := Length(FFeatureArray);
end;

procedure TPascalTypeGlyphMetamorphosisChainTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPosition: Int64;
  ChainLength:  Cardinal;
  // The length of the chain in bytes, including this header.
  SubtableCount: Word; // The number of subtables in the chain.
  FeatureIndex: Word;
  SubtableIndex: Word;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 12 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // remember start position
    StartPosition := Position;

    // read default flags
    FDefaultFlags := BigEndianValueReader.ReadCardinal(Stream);

    // read chain length
    ChainLength := BigEndianValueReader.ReadCardinal(Stream);

{$IFDEF AmbigiousExceptions}
    // check if chain length is a multiple of 4
    if (ChainLength mod 4) <> 0 then raise EPascalTypeError.Create
      (RCStrWrongChainLength);
{$ENDIF}
    // read feature entry count
    SetLength(FFeatureArray, BigEndianValueReader.ReadWord(Stream));

    // read subtable count
    SubtableCount := BigEndianValueReader.ReadWord(Stream);

    for FeatureIndex := 0 to High(FFeatureArray) do
      with FFeatureArray[FeatureIndex] do
      begin
        // read feature type
        FeatureType := BigEndianValueReader.ReadWord(Stream);

        // read feature setting
        FeatureSetting := BigEndianValueReader.ReadWord(Stream);

        // read enable flags
        EnableFlags := BigEndianValueReader.ReadCardinal(Stream);

        // read disable flags
        DisableFlags := BigEndianValueReader.ReadCardinal(Stream);
      end;

    // jump to end of this table
    Position := StartPosition + ChainLength;

    // read subtables
    for SubtableIndex := 0 to SubtableCount - 1 do
    begin
      // TODO: Read further TPascalTypeGlyphMetamorphosisChainTable properties
    end;
  end;
end;

procedure TPascalTypeGlyphMetamorphosisChainTable.SaveToStream(
  Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // write default flags
    WriteSwappedCardinal(Stream, FDefaultFlags);
  end;
end;

procedure TPascalTypeGlyphMetamorphosisChainTable.SetDefaultFlags
  (const Value: Cardinal);
begin
  if FDefaultFlags <> Value then
  begin
    FDefaultFlags := Value;
    DefaultFlagsChanged;
  end;
end;

procedure TPascalTypeGlyphMetamorphosisChainTable.DefaultFlagsChanged;
begin
  Changed;
end;


{ TPascalTypeGlyphMetamorphosisTable }

class function TPascalTypeGlyphMetamorphosisTable.GetTableType: TTableType;
begin
  Result := 'mort';
end;

procedure TPascalTypeGlyphMetamorphosisTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value32:  Cardinal;
  ChainIndex: Cardinal;
  NumChain: Cardinal;
  ChainTable: TPascalTypeGlyphMetamorphosisChainTable;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read number of chains
    Read(Value32, SizeOf(Cardinal));
    NumChain := Swap32(Value32);

{$IFDEF AmbigiousExceptions}
    if NumChain <= 0 then raise EPascalTypeError.Create
      (RCStrTooFewMetamorphosisChains);
{$ENDIF}
    for ChainIndex := 0 to NumChain - 1 do
    begin
      // create chain table
      // add chain table to lists
      ChainTable := FChains.Add;

      // load chain table from stream
      ChainTable.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeGlyphMetamorphosisTable.SaveToStream(Stream: TStream);
var
  ChainIndex: Cardinal;
begin
  inherited;

  with Stream do
  begin
    // write number of chains
    WriteSwappedCardinal(Stream, FChains.Count);

    // save chain tables to stream
    for ChainIndex := 0 to FChains.Count - 1 do
      FChains[ChainIndex].SaveToStream(Stream);
  end;
end;


{ TPascalTypeExtendedGlyphMetamorphosisChainTable }

procedure TPascalTypeExtendedGlyphMetamorphosisChainTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeExtendedGlyphMetamorphosisChainTable then
  begin
    FDefaultFlags := TPascalTypeExtendedGlyphMetamorphosisChainTable(Source).FDefaultFlags;
    FFeatureArray := TPascalTypeExtendedGlyphMetamorphosisChainTable(Source).FFeatureArray;
  end;
end;

function TPascalTypeExtendedGlyphMetamorphosisChainTable.GetFeature(Index: Cardinal): TFeatureSubtableRecord;
begin
  if (Index < Cardinal(Length(FFeatureArray))) then
    Result :=
      FFeatureArray[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TPascalTypeExtendedGlyphMetamorphosisChainTable.GetFeatureCount
: Cardinal;
begin
  Result := Length(FFeatureArray);
end;

procedure TPascalTypeExtendedGlyphMetamorphosisChainTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPosition: Int64;
  ChainLength:  Cardinal;
  // The length of the chain in bytes, including this header.
  SubtableCount: Cardinal; // The number of subtables in the chain.
  FeatureIndex: Cardinal;
  SubtableIndex: Cardinal;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 12 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // remember start position
    StartPosition := Position;

    // read default flags
    FDefaultFlags := BigEndianValueReader.ReadCardinal(Stream);

    // read chain length
    ChainLength := BigEndianValueReader.ReadCardinal(Stream);

{$IFDEF AmbigiousExceptions}
    // check if chain length is a multiple of 4
    if (ChainLength mod 4) <> 0 then raise EPascalTypeError.Create
      (RCStrWrongChainLength);
{$ENDIF}
    // read feature entry count
    SetLength(FFeatureArray, BigEndianValueReader.ReadCardinal(Stream));

    // read subtable count
    SubtableCount := BigEndianValueReader.ReadCardinal(Stream);

    for FeatureIndex := 0 to High(FFeatureArray) do
      with FFeatureArray[FeatureIndex] do
      begin
        // read feature type
        FeatureType := BigEndianValueReader.ReadWord(Stream);

        // read feature setting
        FeatureSetting := BigEndianValueReader.ReadWord(Stream);

        // read enable flags
        EnableFlags := BigEndianValueReader.ReadCardinal(Stream);

        // read disable flags
        DisableFlags := BigEndianValueReader.ReadCardinal(Stream);
      end;

    // jump to end of this table
    Position := StartPosition + ChainLength;

    // read subtables
    for SubtableIndex := 0 to SubtableCount - 1 do
    begin
      // TODO: Read further TPascalTypeExtendedGlyphMetamorphosisChainTable properties
    end;
  end;
end;

procedure TPascalTypeExtendedGlyphMetamorphosisChainTable.SaveToStream
  (Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

procedure TPascalTypeExtendedGlyphMetamorphosisChainTable.SetDefaultFlags
  (const Value: Cardinal);
begin
  if FDefaultFlags <> Value then
  begin
    FDefaultFlags := Value;
    DefaultFlagsChanged;
  end;
end;

procedure TPascalTypeExtendedGlyphMetamorphosisChainTable.
DefaultFlagsChanged;
begin
  Changed;
end;


{ TPascalTypeExtendedGlyphMetamorphosisTable }

class function TPascalTypeExtendedGlyphMetamorphosisTable.GetTableType: TTableType;
begin
  Result := 'morx';
end;

procedure TPascalTypeExtendedGlyphMetamorphosisTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value32:  Cardinal;
  ChainIndex: Cardinal;
  NumChain: Cardinal;
  ChainTable: TPascalTypeExtendedGlyphMetamorphosisChainTable;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // check version (should be >= 2.0)
    if Version.Value < 2 then
      raise EPascalTypeError.CreateFmt(RCStrWrongMajorVersion, [Version.Value]);

    // read number of chains
    Read(Value32, SizeOf(Cardinal));
    NumChain := Swap32(Value32);

{$IFDEF AmbigiousExceptions}
    if NumChain <= 0 then raise EPascalTypeError.Create
      (RCStrTooFewMetamorphosisChains);
{$ENDIF}
    for ChainIndex := 0 to NumChain - 1 do
    begin
      // create chain table
      // add chain table to lists
      ChainTable := TPascalTypeExtendedGlyphMetamorphosisChainTable(FChains.Add(TPascalTypeExtendedGlyphMetamorphosisChainTable));

      // load chain table from stream
      ChainTable.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeExtendedGlyphMetamorphosisTable.SaveToStream(
  Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeOpticalBoundsTable }

procedure TPascalTypeOpticalBoundsTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeOpticalBoundsTable then
    FFormat := TPascalTypeOpticalBoundsTable(Source).FFormat;
end;

class function TPascalTypeOpticalBoundsTable.GetTableType: TTableType;
begin
  Result := 'opbd';
end;

procedure TPascalTypeOpticalBoundsTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  Value16: Word;
begin
  inherited;

  with Stream do
  begin
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read format
    Read(Value16, SizeOf(Word));
    FFormat := Swap16(Value16);

    if not (FFormat in [0..1]) then
      raise EPascalTypeError.Create(RCStrWrongFormat);
  end;
end;

procedure TPascalTypeOpticalBoundsTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeTrackingDataTable }

procedure TPascalTypeTrackingDataTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeTrackingDataTable then
  begin
    FTrackTable := TPascalTypeTrackingDataTable(Source).FTrackTable;
    FSizeTable  := TPascalTypeTrackingDataTable(Source).FSizeTable;
  end;
end;

procedure TPascalTypeTrackingDataTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  SizeTableOffset: Cardinal;
  // Offset from start of the tracking table to the start of the size subtable.
  RecordIndex: Integer;
begin
  inherited;
  with Stream do
  begin
    // check (minimum) table size
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // remember start position
    StartPos := Position;

    // read length of track table
    SetLength(FTrackTable, BigEndianValueReader.ReadWord(Stream));

    // read length of track table
    SetLength(FSizeTable, BigEndianValueReader.ReadWord(Stream));

    // read size table offset
    SizeTableOffset := BigEndianValueReader.ReadWord(Stream);

    // check (minimum) table size
    if Position + 8 * Length(FTrackTable) + 4 * Length(FSizeTable) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    for RecordIndex := 0 to High(FTrackTable) do
      with FTrackTable[RecordIndex] do
      begin
        // read track
        Track.Fixed := BigEndianValueReader.ReadCardinal(Stream);

        // read name index
        NameIndex := BigEndianValueReader.ReadWord(Stream);

{$IFDEF AmbigiousExceptions}
    if NameIndex <= 256 then raise EPascalTypeError.Create
      ('NameIndex should be >= 256!');
{$ENDIF}
        // read offset
        Offset := BigEndianValueReader.ReadWord(Stream);
      end;

    // locate size table position
    Position := StartPos + SizeTableOffset;

    for RecordIndex := 0 to High(FSizeTable) do
    begin
      // read value
      FSizeTable[RecordIndex].Fixed := BigEndianValueReader.ReadCardinal(Stream);
    end;
  end;
end;

procedure TPascalTypeTrackingDataTable.SaveToStream(Stream: TStream);
begin
  inherited;

  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeTrackingTable }

procedure TPascalTypeTrackingTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeTrackingTable then
    FFormat := TPascalTypeTrackingTable(Source).FFormat;
end;

constructor TPascalTypeTrackingTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FHorizontal := TPascalTypeTrackingDataTable.Create;
  FVertical := TPascalTypeTrackingDataTable.Create;
end;

destructor TPascalTypeTrackingTable.Destroy;
begin
  FreeAndNil(FHorizontal);
  FreeAndNil(FVertical);
  inherited;
end;

class function TPascalTypeTrackingTable.GetTableType: TTableType;
begin
  Result := 'trak';
end;

procedure TPascalTypeTrackingTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  HorizOffset: Word;
  // Offset from start of tracking table to TrackData for horizontal text (or 0 if none).
  VertOffset: Word;
  // Offset from start of tracking table to TrackData for vertical text (or 0 if none).
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // remember start position
    StartPos := Position;

    // read format
    FFormat := BigEndianValueReader.ReadWord(Stream);

    // read horizontal offset
    HorizOffset := BigEndianValueReader.ReadWord(Stream);

    // read vertical offset
    VertOffset := BigEndianValueReader.ReadWord(Stream);

{$IFDEF AmbigiousException}
    // read reserved
    if BigEndianValueReader.ReadWord(Stream) <> 0 then raise EPascalTypeError.Create
      (RCStrReservedValueError);
{$ELSE}
    // skip reserved
    Seek(2, soFromCurrent);
{$ENDIF}
    // locate horizontal track table data
    Position := StartPos + HorizOffset;

    // load horizontal tracking table data from stream
    FHorizontal.LoadFromStream(Stream);

    // locate vertical track table data
    Position := StartPos + VertOffset;

    // load vertical tracking table data from stream
    FVertical.LoadFromStream(Stream);
  end;
end;

procedure TPascalTypeTrackingTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

procedure TPascalTypeTrackingTable.SetFormat(const Value: Word);
begin
  if FFormat <> Value then
  begin
    FFormat := Value;
    FormatChanged;
  end;
end;

procedure TPascalTypeTrackingTable.SetHorizontal(
  const Value: TPascalTypeTrackingDataTable);
begin
  if FHorizontal <> Value then
  begin
    FHorizontal := Value;
    HorizontalChanged;
  end;
end;

procedure TPascalTypeTrackingTable.SetVertical(
  const Value: TPascalTypeTrackingDataTable);
begin
  if FVertical <> Value then
  begin
    FVertical := Value;
    VerticalChanged;
  end;
end;

procedure TPascalTypeTrackingTable.FormatChanged;
begin
  Changed;
end;

procedure TPascalTypeTrackingTable.HorizontalChanged;
begin
  Changed;
end;

procedure TPascalTypeTrackingTable.VerticalChanged;
begin
  Changed;
end;


{ TPascalTypeZapfGlyphInfoTable }

procedure TPascalTypeZapfGlyphInfoTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeZapfGlyphInfoTable then
    FUnicodeCodePoints := TPascalTypeZapfGlyphInfoTable(Source).FUnicodeCodePoints;
end;

procedure TPascalTypeZapfGlyphInfoTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  GroupOffset: Cardinal;
  // Byte offset from start of extraInfo to GroupInfo or GroupInfoGroup for this glyph, or 0xFFFFFFFF if none
  FeatOffset: Cardinal;
  // Byte offset from start of extraInfo to FeatureInfo for this glyph, or 0xFFFFFFFF if none
  UnicodeIndex: Word;
  KindNameCount: Word;
  KindNameIndex: Word;
begin
  StartPos := Stream.Position;

  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 10 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read group offset
    GroupOffset := BigEndianValueReader.ReadCardinal(Stream);

    // read feature offset
    FeatOffset := BigEndianValueReader.ReadCardinal(Stream);

    // read number of 16bit unicode values
    SetLength(FUnicodeCodePoints, BigEndianValueReader.ReadWord(Stream));

    // check (minimum) table size
    if Position + 2 * Length(FUnicodeCodePoints) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read unicode code points
    for UnicodeIndex := 0 to High(FUnicodeCodePoints) do
      FUnicodeCodePoints[UnicodeIndex] := BigEndianValueReader.ReadWord(Stream);

    // read kind name count
    KindNameCount := BigEndianValueReader.ReadWord(Stream);

    // set length kind names
    SetLength(FKindNames, KindNameCount);

    for KindNameIndex := 0 to KindNameCount - 1 do
    begin
      FKindNames[KindNameIndex] := TPascalTypeZapfKindName.Create;
      FKindNames[KindNameIndex].LoadFromStream(Stream);
    end;

    // Assert(Position = StartPos + GroupOffset);

    // TODO: Finish implementation of TPascalTypeZapfGlyphInfoTable (see http://developer.apple.com/fonts/TTRefMan/RM06/Chap6Zapf.html)
    // Dummy asserts to silence compiler hints
    Assert(FeatOffset <> 0);
    Assert(GroupOffset <> 0);
    Assert(StartPos <> 0);

  end;
end;

procedure TPascalTypeZapfGlyphInfoTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeZapfKindNameString }

procedure TPascalTypeZapfKindNameString.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeZapfKindNameString then
    FName := TPascalTypeZapfKindNameString(Source).FName;
end;

procedure TPascalTypeZapfKindNameString.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  CharCount: Byte;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 1 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read length of string
    Read(CharCount, 1);

    // set length of name
    SetLength(FName, CharCount);

    // read string
    Read(FName[1], CharCount);
  end;
end;

procedure TPascalTypeZapfKindNameString.SaveToStream(Stream: TStream);
begin
  inherited;

  // save string to stream
  Stream.Write(FName, Length(FName) + 1);
end;


{ TPascalTypeZapfKindNameBinary }

procedure TPascalTypeZapfKindNameBinary.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeZapfKindNameBinary then
    FValue := TPascalTypeZapfKindNameBinary(Source).FValue;
end;

procedure TPascalTypeZapfKindNameBinary.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    Read(FValue, 2);
  end;
end;

procedure TPascalTypeZapfKindNameBinary.SaveToStream(Stream: TStream);
begin
  inherited;

  Stream.Write(FValue, 2);
end;


{ TPascalTypeZapfKindName }

procedure TPascalTypeZapfKindName.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TPascalTypeZapfKindName then
  begin
    FKindType := TPascalTypeZapfKindName(Source).FKindType;
    FKindName := TPascalTypeZapfKindName(Source).FKindName;
  end;
end;

procedure TPascalTypeZapfKindName.KindNameChanged;
begin
  if (FKindType in [zknUniversal..zknUniversal]) and
    (not (FKindName is TPascalTypeZapfKindNameString)) then
  begin
    // eventually free current kind name object
    FreeAndNil(FKindName);

    // create new kind name object
    FKindName := TPascalTypeZapfKindNameString.Create;
  end;
  if (FKindType in [zknCidJapanese..zknDesignerHistoricalNotes]) and
    (not (FKindName is TPascalTypeZapfKindNameString)) then
  begin
    // eventually free current kind name object
    FreeAndNil(FKindName);

    // create new kind name object
    FKindName := TPascalTypeZapfKindNameBinary.Create;
  end;
end;

procedure TPascalTypeZapfKindName.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 1 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read kind type
    Read(FKindType, 1);

    // eventually free current kind name object
    FreeAndNil(FKindName);

    // eventually create kind name object
    if FKindType in [zknUniversal..zknUniversal] then
      FKindName :=
        TPascalTypeZapfKindNameString.Create
    else if FKindType in [zknCidJapanese..zknDesignerHistoricalNotes] then
      FKindName :=
        TPascalTypeZapfKindNameBinary.Create;

    // eventually load kind name from stream
    if (FKindName <> nil) then
      FKindName.LoadFromStream(Stream);
  end;
end;

procedure TPascalTypeZapfKindName.SaveToStream(Stream: TStream);
begin
  inherited;

  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

procedure TPascalTypeZapfKindName.SetKindName(
  const Value: TCustomPascalTypeZapfKindName);
begin
  if FKindName <> Value then
  begin
    FKindName := Value;
    KindNameChanged;
  end;
end;


{ TPascalTypeZapfTable }

destructor TPascalTypeZapfTable.Destroy;
begin
  ClearGlyphInfos;
  inherited;
end;

procedure TPascalTypeZapfTable.Assign(Source: TPersistent);
var
  GlyphIndex: Integer;
begin
  inherited;

  if Source is TPascalTypeZapfTable then
  begin
    SetLength(FGlyphInfos, Length(TPascalTypeZapfTable(Source).FGlyphInfos));
    for GlyphIndex := 0 to High(FGlyphInfos) do
      FGlyphInfos[GlyphIndex].Assign(TPascalTypeZapfTable(Source).FGlyphInfos[GlyphIndex]);
  end;
end;

class function TPascalTypeZapfTable.GetTableType: TTableType;
begin
  Result := 'Zapf';
end;

procedure TPascalTypeZapfTable.ClearGlyphInfos;
var
  GlyphIndex: Integer;
begin
  for GlyphIndex := 0 to High(FGlyphInfos) do
    FreeAndNil(FGlyphInfos[GlyphIndex]);
end;

procedure TPascalTypeZapfTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos: Int64;
  MaxProfile: TPascalTypeMaximumProfileTable;
  GlyphIndex: Integer;
  ExtraInfo: Cardinal; // Offset from start of table to start of extra info space (added to groupOffset and featOffset in GlyphInfo)
  Offsets: array of Cardinal; // Array of offsets, indexed by glyphcode, from start of table to GlyphInfo structure for a glyph
begin
  inherited;
  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // remember start position
    StartPos := Position;

    // read extra info offset
    ExtraInfo := BigEndianValueReader.ReadCardinal(Stream);

    // get maximum profile table
    MaxProfile := TPascalTypeMaximumProfileTable(FontFace.GetTableByTableType('maxp'));
    Assert(MaxProfile <> nil);

    // set length of offset array
    SetLength(Offsets, MaxProfile.NumGlyphs);

    // read glyph info offsets
    for GlyphIndex := 0 to High(Offsets) do
      Offsets[GlyphIndex] :=
        BigEndianValueReader.ReadCardinal(Stream);

    // set glyph info array length
    SetLength(FGlyphInfos, Length(Offsets));

    // load glyph info
    for GlyphIndex := 0 to High(Offsets) do
    begin
      // locate glyph info
      Position := StartPos + Offsets[GlyphIndex];

      // create glyph info table for current glyph index
      FGlyphInfos[GlyphIndex] := TPascalTypeZapfGlyphInfoTable.Create;

      // load glyph info from stream
      FGlyphInfos[GlyphIndex].LoadFromStream(Stream);
    end;

    // locate extra info
    Position := StartPos + ExtraInfo;
  end;
end;

procedure TPascalTypeZapfTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

/// /////////////////////////////////////////////////////////////////////////////

function IsTagRegistered(TableClass: TPascalTypeTaggedValueTableClass): Boolean;
var
  TableClassIndex: Integer;
begin
  Result := False;
  for TableClassIndex := 0 to High(GDescriptionTagClasses) do
    if GDescriptionTagClasses[TableClassIndex] = TableClass then
    begin
      Result := True;
      Exit;
    end;
end;

function CheckDescriptionTagsValid: Boolean;
var
  TableClassBaseIndex: Integer;
  TableClassIndex: Integer;
begin
  Result := True;
  for TableClassBaseIndex := 0 to High(GDescriptionTagClasses) do
    for TableClassIndex := TableClassBaseIndex + 1 to High(GDescriptionTagClasses) do
      if GDescriptionTagClasses[TableClassBaseIndex] = GDescriptionTagClasses[TableClassIndex] then
      begin
        Result := False;
        Exit;
      end;
end;

procedure RegisterDescriptionTag(TableClass: TPascalTypeTaggedValueTableClass);
begin
  Assert(IsTagRegistered(TableClass) = False);
  SetLength(GDescriptionTagClasses, Length(GDescriptionTagClasses) + 1);
  GDescriptionTagClasses[High(GDescriptionTagClasses)] := TableClass;
end;

procedure RegisterDescriptionTags(TableClasses:
  array of TPascalTypeTaggedValueTableClass);
var
  TableClassIndex: Integer;
begin
  SetLength(GDescriptionTagClasses, Length(GDescriptionTagClasses) +
    Length(TableClasses));
  for TableClassIndex := 0 to High(TableClasses) do
    GDescriptionTagClasses[Length(GDescriptionTagClasses) -
      Length(TableClasses) + TableClassIndex] := TableClasses[TableClassIndex];
  Assert(CheckDescriptionTagsValid);
end;

function FindDescriptionTagByType(TableType: TTableType)
: TPascalTypeTaggedValueTableClass;
var
  TableClassIndex: Integer;
begin
  Result := nil;
  for TableClassIndex := 0 to High(GDescriptionTagClasses) do
    if GDescriptionTagClasses[TableClassIndex].GetTableType = TableType then
    begin
      Result := GDescriptionTagClasses[TableClassIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown Table Class: ' + TableType);
end;

initialization

  RegisterDescriptionTags([TPascalTypeWeightValueTable, TPascalTypeWidthValueTable,
    TPascalTypeSlantValueTable, TPascalTypeOpticalSizeValueTable,
    TPascalTypeNonAlphabeticValueTable]);

  PascalTypeTableClasses.RegisterTables([TPascalTypeAccentAttachmentTable,
    TPascalTypeAxisVariationTable, TPascalTypeBaselineTable,
    TPascalTypeBitmapDataTable, TPascalTypeBitmapHeaderTable,
    TPascalTypeBitmapLocationTable, TPascalTypeFontDescriptionTable,
    TPascalTypeFeatureTable, TPascalTypeFontVariationTable,
    TPascalTypeHorizontalStyleTable, TPascalTypeGlyphMetamorphosisTable,
    TPascalTypeExtendedGlyphMetamorphosisTable, TPascalTypeOpticalBoundsTable,
    TPascalTypeGlyphPropertiesTable, TPascalTypeTrackingTable, TPascalTypeZapfTable]);

end.

