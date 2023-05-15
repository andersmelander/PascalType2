unit PT_TablesOptional;

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
  Classes, PT_Types, PT_Classes, PT_Tables;

type
  // table 'DSIG'
  TPascalTypeDigitalSignatureBlock = class(TCustomPascalTypeTable)
  private
    FFormat   : Cardinal;
    FReserved : array [0..1] of Word; // Reserved for later use; 0 for now
    FSignature: array of Byte; // PKCS#7 packet
    function GetSignatureByte(Index: Integer): Byte;
    function GetSignatureLength: Cardinal;
    procedure SetReserved(const Index: Integer; const Value: Word);
    procedure SetFormat(const Value: Cardinal);
  protected
    procedure FormatChanged; virtual;
    procedure ReservedChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property SignatureLength: Cardinal read GetSignatureLength;
    property SignatureByte[Index: Integer]: Byte read GetSignatureByte;
    property Reserved1: Word index 0 read FReserved[0] write SetReserved;
    property Reserved2: Word index 1 read FReserved[1] write SetReserved;
    property Format: Cardinal read FFormat write SetFormat;
  end;

  TDigitalSignatureDirectory = packed record
    Format: Cardinal; // Format of the signature
    Length: Cardinal; // Length of signature in bytes
    Offset: Cardinal; // Offset to the signature block from the beginning of the table
  end;

  TPascalTypeDigitalSignatureTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: Cardinal; // Version number of the DSIG table (0x00000001)
    FFlags  : TDigitalSignatureFlags; // Permission flags: Bit 0: cannot be resigned, Bits 1-7: Reserved (Set to 0)
    FSignatures: TPascalTypeTableList<TPascalTypeDigitalSignatureBlock>;
    procedure SetVersion(const Value: Cardinal);
    procedure SetFlags(const Value: TDigitalSignatureFlags);
    function GetSignatureCount: Integer;
    function GetSignatureBlock(Index: Integer): TPascalTypeDigitalSignatureBlock;
  protected
    procedure FlagsChanged; virtual;
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Cardinal read FVersion write SetVersion;
    property Flags: TDigitalSignatureFlags read FFlags write SetFlags;
    property SignatureCount: Integer read GetSignatureCount;
    property SignatureBlock[Index: Integer]: TPascalTypeDigitalSignatureBlock read GetSignatureBlock;
  end;


  // table 'gasp'

const
  Gasp_GridFit = 1;
  Gasp_DoGray = 2;

type
  TGaspRange = record
    MaxPPEM: Byte;
    GaspFlag: Byte;
  end;

  TPascalTypeGridFittingAndScanConversionProcedureTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion   : Word;
    FGaspRanges: array of TGaspRange;
    procedure SetVersion(const Value: Word);
    function GetRangeCount: Integer;
    function GetRange(Index: Integer): TGaspRange;
  protected
    procedure VersionChanged; virtual;
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property RangeCount: Integer read GetRangeCount;
    property Range[Index: Integer]: TGaspRange read GetRange;
  end;


  // table 'hdmx'

  TPascalTypeHorizontalDeviceMetricsSubTable = class(TCustomPascalTypeTable)
  private
    Fppem    : Byte;
    FMaxWidth: Byte;
    FWidths  : array of Byte;
    function GetWidth(Index: Integer): Byte;
    function GetWidthCount: Integer;
    procedure SetMaxWidth(const Value: Byte);
    procedure Setppem(const Value: Byte);
  protected
    procedure MaxWidthChanged; virtual;
    procedure ppemChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property ppem: Byte read Fppem write Setppem;
    property MaxWidth: Byte read FMaxWidth write SetMaxWidth;
    property Width[Index: Integer]: Byte read GetWidth;
    property WidthCount: Integer read GetWidthCount;
  end;

  TPascalTypeHorizontalDeviceMetricsTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion  : Word; // Table version number (0)
    FSubtables: TPascalTypeTableInterfaceList<TPascalTypeHorizontalDeviceMetricsSubTable>;
    procedure SetVersion(const Value: Word);
    function GetDeviceRecordCount: Word;
    function GetDeviceRecord(Index: Word): TPascalTypeHorizontalDeviceMetricsSubTable;
    procedure SetDeviceRecord(Index: Word; const Value: TPascalTypeHorizontalDeviceMetricsSubTable);
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    class function GetTableType: TTableType; override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property DeviceRecordCount: Word read GetDeviceRecordCount;
    property DeviceRecord[Index: Word]: TPascalTypeHorizontalDeviceMetricsSubTable read GetDeviceRecord write SetDeviceRecord;
  end;

  // table 'kern'
  // https://learn.microsoft.com/en-us/typography/opentype/spec/kern
  TCustomPascalTypeKerningFormatSubTable = class(TCustomPascalTypeTable)
  public
    function GetKerningValue(LeftGlyphIndex, RightGlyphIndex: Word): Word;
      virtual; abstract;
  end;

  TCustomPascalTypeKerningFormatSubTableClass = class of
    TCustomPascalTypeKerningFormatSubTable;

  TKerningFormat0SubTable = packed record
    Left  : Word; // The glyph index for the left-hand glyph in the kerning pair.
    Right : Word; // The glyph index for the right-hand glyph in the kerning pair.
    Value : SmallInt; // The kerning value for the above pair, in FUnits. If this value is greater than zero, the characters will be moved apart. If this value is less than zero, the character will be moved closer together.
  end;

  // https://learn.microsoft.com/en-us/typography/opentype/spec/kern#format-0
  TPascalTypeKerningFormat0SubTable = class(TCustomPascalTypeKerningFormatSubTable)
  private
    FPairs: array of TKerningFormat0SubTable;
    function GetPairCount: Integer;
    function GetPair(Index: Integer): TKerningFormat0SubTable;
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function GetKerningValue(LeftGlyphIndex: Word; RightGlyphIndex: Word): Word; override;

    property PairCount: Integer read GetPairCount;
    property Pair[Index: Integer]: TKerningFormat0SubTable read GetPair;
  end;

  TPascalTypeKerningFormat2SubTable = class(TCustomPascalTypeKerningFormatSubTable)
  public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TPascalTypeKerningSubTable = class(TCustomPascalTypeTable)
  private
    FVersion    : Word;
    FLength     : Word;
    FCoverage   : Word;
    FFormatTable: TCustomPascalTypeKerningFormatSubTable;
    function GetFormat: Byte;
    function GetIsCrossStream: Boolean;
    function GetIsHorizontal: Boolean;
    function GetIsMinimum: Boolean;
    function GetIsReplace: Boolean;
    procedure SetFormat(const Value: Byte);
    procedure SetIsCrossStream(const Value: Boolean);
    procedure SetIsHorizontal(const Value: Boolean);
    procedure SetIsMinimum(const Value: Boolean);
    procedure SetIsReplace(const Value: Boolean);
    procedure SetVersion(const Value: Word);
  protected
    procedure AssignFormat; virtual;
    procedure CoverageChanged; virtual;
    procedure FormatChanged; virtual;
    procedure IsCrossStreamChanged; virtual;
    procedure IsHorizontalChanged; virtual;
    procedure IsMinimumChanged; virtual;
    procedure IsReplaceChanged; virtual;
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property Length: Word read FLength;
    property Coverage: Word read FCoverage;

    property IsHorizontal: Boolean read GetIsHorizontal write SetIsHorizontal;
    property IsMinimum: Boolean read GetIsMinimum write SetIsMinimum;
    property IsCrossStream: Boolean read GetIsCrossStream write SetIsCrossStream;
    property IsReplace: Boolean read GetIsReplace write SetIsReplace;
    property Format: Byte read GetFormat write SetFormat;

    property FormatTable: TCustomPascalTypeKerningFormatSubTable read FFormatTable;
  end;

  TPascalTypeKerningTable = class(TCustomPascalTypeNamedTable)
  private
    FKerningSubtableList: TPascalTypeTableList<TPascalTypeKerningSubTable>;
    FVersion            : Word;
    procedure SetVersion(const Value: Word);
    function GetKerningSubtableCount: Integer;
    function GetKerningSubtable(Index: Integer): TPascalTypeKerningSubTable;
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;

    property KerningSubtable[Index: Integer]: TPascalTypeKerningSubTable read GetKerningSubtable;
    property KerningSubtableCount: Integer read GetKerningSubtableCount;
  end;


  // table 'LTSH'

  TPascalTypeLinearThresholdTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion     : Word;
    FVerticalPels: array of Byte; // The vertical pel height at which the glyph can be assumed to scale linearly. On a per glyph basis.
    function GetVerticalPelCount: Integer;
    function GetVerticalPel(Index: Integer): Byte;
    procedure SetVersion(const Value: Word);
  protected
    procedure VersionChanged; virtual;
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property VerticalPelCount: Integer read GetVerticalPelCount;
    property VerticalPel[Index: Integer]: Byte read GetVerticalPel;
  end;


  // table 'PCLT'
  // https://learn.microsoft.com/en-us/typography/opentype/spec/pclt
  // TODO : Why do we even support this table type?
  TPascalTypePCL5Table = class(TCustomPascalTypeNamedTable)
  private
    FVersion            : TFixedPoint;
    FFontNumber         : TPcl5FontNumber;
    FPitch              : Word;
    FXHeight            : Word;
    FStyle              : Word;
    FTypeFamily         : Word;
    FCapHeight          : Word;
    FSymbolSet          : Word;
    FTypeface           : array [0..15] of AnsiChar;
    FCharacterComplement: array [0..7] of AnsiChar;
    FFileName           : array [0..5] of AnsiChar;
    FStrokeWeight       : AnsiChar;
    FWidthType          : AnsiChar;
    FSerifStyle         : Byte;
    FPadding            : Byte; // Reserved (set to 0)
    function GetCharacterComplement: string;
    function GetFileName: string;
    function GetTypeface: string;
    procedure SetVersion(const Value: TFixedPoint);
    procedure SetCapHeight(const Value: Word);
    procedure SetFontNumber(const Value: TPcl5FontNumber);
    procedure SetPadding(const Value: Byte);
    procedure SetPitch(const Value: Word);
    procedure SetSerifStyle(const Value: Byte);
    procedure SetStrokeWeight(const Value: AnsiChar);
    procedure SetStyle(const Value: Word);
    procedure SetSymbolSet(const Value: Word);
    procedure SetTypeFamily(const Value: Word);
    procedure SetWidthType(const Value: AnsiChar);
    procedure SetXHeight(const Value: Word);
    procedure SetCharacterComplement(const Value: string);
    procedure SetFileName(const Value: string);
    procedure SetTypeface(const Value: string);
  protected
    procedure VersionChanged; virtual;
    procedure CapHeightChanged; virtual;
    procedure FontNumberChanged; virtual;
    procedure PaddingChanged; virtual;
    procedure PitchChanged; virtual;
    procedure SerifStyleChanged; virtual;
    procedure StrokeWeightChanged; virtual;
    procedure StyleChanged; virtual;
    procedure SymbolSetChanged; virtual;
    procedure TypeFamilyChanged; virtual;
    procedure WidthTypeChanged; virtual;
    procedure XHeightChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
    property FontNumber: TPcl5FontNumber read FFontNumber write SetFontNumber;
    property Pitch: Word read FPitch write SetPitch;
    property XHeight: Word read FXHeight write SetXHeight;
    property Style: Word read FStyle write SetStyle;
    property TypeFamily: Word read FTypeFamily write SetTypeFamily;
    property CapHeight: Word read FCapHeight write SetCapHeight;
    property SymbolSet: Word read FSymbolSet write SetSymbolSet;
    property Typeface: string read GetTypeface write SetTypeface;
    property CharacterComplement: string read GetCharacterComplement
      write SetCharacterComplement;
    property FileName: string read GetFileName write SetFileName;
    property StrokeWeight: AnsiChar read FStrokeWeight write SetStrokeWeight;
    property WidthType: AnsiChar read FWidthType write SetWidthType;
    property SerifStyle: Byte read FSerifStyle write SetSerifStyle;
    property Padding: Byte read FPadding write SetPadding;
    // Reserved (set to 0 read FPadding write SetPadding)
  end;


  // table 'VDMX'

  TVDMXHeightRecord = packed record
    yPelHeight: Word; // yPelHeight to which values apply.
    yMax: SmallInt; // Maximum value (in pels) for this yPelHeight.
    yMin: SmallInt; // Minimum value (in pels) for this yPelHeight.
  end;

  TPascalTypeVDMXGroupTable = class(TCustomPascalTypeTable)
  private
    FStartsz: Byte; // Starting yPelHeight
    FEndsz  : Byte; // Ending yPelHeight
    FEntry  : array of TVDMXHeightRecord; // The VDMX records
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TVDMXRatioRecord = packed record
    bCharSet: Byte; // Character set (see below).
    xRatio: Byte; // Value to use for x-Ratio
    yStartRatio: Byte; // Starting y-Ratio value.
    yEndRatio: Byte; // Ending y-Ratio value.
  end;

  TPascalTypeVerticalDeviceMetricsTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: Word; // Version number (0 or 1).
    FRatios : array of TVDMXRatioRecord;
    FGroups : TPascalTypeTableList<TPascalTypeVDMXGroupTable>;
    procedure SetVersion(const Value: Word);
    function GetRatioCount: Word;
    function GetGroupCount: Word;
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property RatioCount: Word read GetRatioCount;
    property GroupCount: Word read GetGroupCount;
  end;

implementation

uses
  Math, SysUtils, PT_Math, PT_ResourceStrings;


{ TPascalTypeDigitalSignatureBlock }

procedure TPascalTypeDigitalSignatureBlock.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeDigitalSignatureBlock then
  begin
    FFormat := TPascalTypeDigitalSignatureBlock(Source).FFormat;
    FReserved := TPascalTypeDigitalSignatureBlock(Source).FReserved;
    FSignature := TPascalTypeDigitalSignatureBlock(Source).FSignature;
  end;
end;

function TPascalTypeDigitalSignatureBlock.GetSignatureByte(Index: Integer): Byte;
begin
  if (Index < 0) or (Index > High(FSignature)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FSignature[Index];
end;

function TPascalTypeDigitalSignatureBlock.GetSignatureLength: Cardinal;
begin
  Result := Length(FSignature);
end;

procedure TPascalTypeDigitalSignatureBlock.LoadFromStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read reserved 1
    FReserved[0] := BigEndianValueReader.ReadWord(Stream);

    // read reserved 2
    FReserved[1] := BigEndianValueReader.ReadWord(Stream);

    // read signature length
    SetLength(FSignature, BigEndianValueReader.ReadCardinal(Stream));

    // check if table contains the entire signature
    if Position + Length(FSignature) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read signature length
    Read(FSignature[0], Length(FSignature));
  end;
end;

procedure TPascalTypeDigitalSignatureBlock.SaveToStream(Stream: TStream);
begin
  // write reserved 1
  WriteSwappedWord(Stream, FReserved[0]);

  // write reserved 2
  WriteSwappedWord(Stream, FReserved[1]);

  // write signature length
  WriteSwappedCardinal(Stream, Length(FSignature));

  // write signature length
  Write(FSignature[0], Length(FSignature));
end;

procedure TPascalTypeDigitalSignatureBlock.SetFormat(const Value: Cardinal);
begin
  if FFormat <> Value then
  begin
    FFormat := Value;
    FormatChanged;
  end;
end;

procedure TPascalTypeDigitalSignatureBlock.SetReserved(const Index: Integer;
  const Value: Word);
begin
  if FReserved[Index] <> Value then
  begin
    FReserved[Index] := Value;
    ReservedChanged;
  end;
end;

procedure TPascalTypeDigitalSignatureBlock.ReservedChanged;
begin
  Changed;
end;

procedure TPascalTypeDigitalSignatureBlock.FormatChanged;
begin
  Changed;
end;


{ TPascalTypeDigitalSignatureTable }

constructor TPascalTypeDigitalSignatureTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion := 1;
  FSignatures := TPascalTypeTableList<TPascalTypeDigitalSignatureBlock>.Create;
end;

destructor TPascalTypeDigitalSignatureTable.Destroy;
begin
  FreeAndNil(FSignatures);
  inherited;
end;

procedure TPascalTypeDigitalSignatureTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeDigitalSignatureTable then
  begin
    FVersion := TPascalTypeDigitalSignatureTable(Source).FVersion;
    FFlags := TPascalTypeDigitalSignatureTable(Source).FFlags;
    FSignatures.Assign(TPascalTypeDigitalSignatureTable(Source).FSignatures);
  end;
end;

class function TPascalTypeDigitalSignatureTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'DSIG';
end;

function TPascalTypeDigitalSignatureTable.GetSignatureBlock(Index: Integer): TPascalTypeDigitalSignatureBlock;
begin
  if (Index < 0) or (Index >= FSignatures.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FSignatures[Index];
end;

function TPascalTypeDigitalSignatureTable.GetSignatureCount: Integer;
begin
  Result := FSignatures.Count;
end;

procedure TPascalTypeDigitalSignatureTable.LoadFromStream(Stream: TStream);
var
  StartPos : Int64;
  DirIndex : Integer;
  Directory: array of TDigitalSignatureDirectory;
  SigBlock : TPascalTypeDigitalSignatureBlock;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // store stream start position
    StartPos := Position;

    // read version
    FVersion := BigEndianValueReader.ReadCardinal(Stream);

    if Version <> 1 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read directory entry count
    SetLength(Directory, BigEndianValueReader.ReadWord(Stream));

    // read flags
    FFlags := WordToDigitalSignatureFlags(BigEndianValueReader.ReadWord(Stream));

    if Position + Length(Directory) * SizeOf(TDigitalSignatureDirectory) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read directory entry
    for DirIndex := 0 to High(Directory) do
      with Directory[DirIndex] do
      begin
        // read format
        Format := BigEndianValueReader.ReadCardinal(Stream);

        // read length
        Length := BigEndianValueReader.ReadCardinal(Stream);

        // read offset
        Offset := BigEndianValueReader.ReadCardinal(Stream);
      end;

    // clear existing signatures
    FSignatures.Clear;

    // read digital signatures
    for DirIndex := 0 to High(Directory) do
    begin
      SigBlock := FSignatures.Add;

      Position := StartPos + Directory[DirIndex].Offset;

      // check if table contains the entire signature
      if Position + Directory[DirIndex].Length > Size then
        raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

      // load digital signature from stream
      SigBlock.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeDigitalSignatureTable.SaveToStream(Stream: TStream);
var
  StartPos : Int64;
  DirIndex : Integer;
  Directory: array of TDigitalSignatureDirectory;
begin
  with Stream do
  begin
    // store stream start position
    StartPos := Position;

    // write format type
    WriteSwappedWord(Stream, FVersion);

    // write directory entry count
    WriteSwappedWord(Stream, FSignatures.Count);

    // write flags
    WriteSwappedWord(Stream, DigitalSignatureFlagsToWord(FFlags));

    // set length of temporary directory
    SetLength(Directory, FSignatures.Count);

    // offset directory
    Seek(soFromCurrent, FSignatures.Count * 3 * SizeOf(Cardinal));

    // build directory and store signature
    for DirIndex := 0 to FSignatures.Count - 1 do
    begin
      Directory[DirIndex].Format := FSignatures[DirIndex].Format;
      Directory[DirIndex].Offset := Position - StartPos;
      FSignatures[DirIndex].SaveToStream(Stream);
      Directory[DirIndex].Length := (Position - StartPos) - Directory[DirIndex].Offset;
    end;

    // locate directory
    Position := StartPos + 3 * SizeOf(Word);

    // write directory entries
    for DirIndex := 0 to High(Directory) do
    begin
      // write format
      WriteSwappedCardinal(Stream, Directory[DirIndex].Format);

      // write length
      WriteSwappedCardinal(Stream, Directory[DirIndex].Length);

      // write offset
      WriteSwappedCardinal(Stream, Directory[DirIndex].Offset);
    end;
  end;
end;

procedure TPascalTypeDigitalSignatureTable.SetFlags(const Value: TDigitalSignatureFlags);
begin
  if FFlags <> Value then
  begin
    FFlags := Value;
    FlagsChanged;
  end;
end;

procedure TPascalTypeDigitalSignatureTable.SetVersion(const Value: Cardinal);
begin
  if (Version <> Value) then
  begin
    Version := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeDigitalSignatureTable.FlagsChanged;
begin
  Changed;
end;

procedure TPascalTypeDigitalSignatureTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeGridFittingAndScanConversionProcedureTable }

procedure TPascalTypeGridFittingAndScanConversionProcedureTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeGridFittingAndScanConversionProcedureTable then
  begin
    FVersion := TPascalTypeGridFittingAndScanConversionProcedureTable(Source).FVersion;
    FGaspRanges := TPascalTypeGridFittingAndScanConversionProcedureTable(Source).FGaspRanges;
  end;
end;

class function TPascalTypeGridFittingAndScanConversionProcedureTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'gasp';
end;

function TPascalTypeGridFittingAndScanConversionProcedureTable.GetRange(Index: Integer): TGaspRange;
begin
  if (Index < 0) or (Index > High(FGaspRanges)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FGaspRanges[Index];
end;

function TPascalTypeGridFittingAndScanConversionProcedureTable.GetRangeCount: Integer;
begin
  Result := Length(FGaspRanges);
end;

procedure TPascalTypeGridFittingAndScanConversionProcedureTable.LoadFromStream
  (Stream: TStream);
var
  RangeIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion := BigEndianValueReader.ReadWord(Stream);

    // check version
    if not(Version in [0..1]) then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read version
    SetLength(FGaspRanges, BigEndianValueReader.ReadWord(Stream));

    // check (minimum) table size
    if Position + 4 * Length(FGaspRanges) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    for RangeIndex := 0 to High(FGaspRanges) do
    begin
      // read MaxPPEM
      FGaspRanges[RangeIndex].MaxPPEM := Byte(BigEndianValueReader.ReadWord(Stream));

      // read GaspFlag
      FGaspRanges[RangeIndex].GaspFlag := Byte(BigEndianValueReader.ReadWord(Stream));
    end;
  end;
end;

procedure TPascalTypeGridFittingAndScanConversionProcedureTable.SaveToStream(Stream: TStream);
var
  RangeIndex: Integer;
begin
  with Stream do
  begin
    // write version
    WriteSwappedWord(Stream, FVersion);

    // write numRanges
    WriteSwappedWord(Stream, Length(FGaspRanges));

    for RangeIndex := 0 to High(FGaspRanges) do
    begin
      // write MaxPPEM
      WriteSwappedWord(Stream, FGaspRanges[RangeIndex].MaxPPEM);

      // write GaspFlag
      WriteSwappedWord(Stream, FGaspRanges[RangeIndex].GaspFlag);
    end;
  end;
end;

procedure TPascalTypeGridFittingAndScanConversionProcedureTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeGridFittingAndScanConversionProcedureTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeHorizontalDeviceMetricsSubTable }

procedure TPascalTypeHorizontalDeviceMetricsSubTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeHorizontalDeviceMetricsSubTable then
  begin
    Fppem := TPascalTypeHorizontalDeviceMetricsSubTable(Source).Fppem;
    FMaxWidth := TPascalTypeHorizontalDeviceMetricsSubTable(Source).FMaxWidth;
    FWidths := TPascalTypeHorizontalDeviceMetricsSubTable(Source).FWidths;
  end;
end;

function TPascalTypeHorizontalDeviceMetricsSubTable.GetWidth(Index: Integer): Byte;
begin
  if (Index < 0) or (Index > High(FWidths)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FWidths[Index];
end;

function TPascalTypeHorizontalDeviceMetricsSubTable.GetWidthCount: Integer;
begin
  Result := Length(FWidths);
end;

procedure TPascalTypeHorizontalDeviceMetricsSubTable.LoadFromStream(Stream: TStream);
var
  MaxProfile: TPascalTypeMaximumProfileTable;
begin
  inherited;

  MaxProfile := TPascalTypeMaximumProfileTable(FontFace.GetTableByTableName('maxp'));

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read ppem
    Read(Fppem, 1);

    // read max width
    Read(FMaxWidth, 1);

    // set length of widths to number of glyphs
    SetLength(FWidths, MaxProfile.NumGlyphs);

    // check (minimum) table size
    if Position + Length(FWidths) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read widths
    Read(FWidths[0], Length(FWidths));
  end;
end;

procedure TPascalTypeHorizontalDeviceMetricsSubTable.SaveToStream
  (Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // write ppem
    WriteSwappedWord(Stream, Fppem);

    // write max width
    WriteSwappedWord(Stream, FMaxWidth);

    // write widths
    Write(FWidths[0], Length(FWidths));
  end;
end;

procedure TPascalTypeHorizontalDeviceMetricsSubTable.SetMaxWidth
  (const Value: Byte);
begin
  if FMaxWidth <> Value then
  begin
    FMaxWidth := Value;
    MaxWidthChanged;
  end;
end;

procedure TPascalTypeHorizontalDeviceMetricsSubTable.Setppem(const Value: Byte);
begin
  if Fppem <> Value then
  begin
    Fppem := Value;
    ppemChanged;
  end;
end;

procedure TPascalTypeHorizontalDeviceMetricsSubTable.MaxWidthChanged;
begin
  Changed;
end;

procedure TPascalTypeHorizontalDeviceMetricsSubTable.ppemChanged;
begin
  Changed;
end;


{ TPascalTypeHorizontalDeviceMetricsTable }

constructor TPascalTypeHorizontalDeviceMetricsTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FSubtables := TPascalTypeTableInterfaceList<TPascalTypeHorizontalDeviceMetricsSubTable>.Create(Self);
end;

destructor TPascalTypeHorizontalDeviceMetricsTable.Destroy;
begin
  FreeAndNil(FSubtables);
  inherited;
end;

procedure TPascalTypeHorizontalDeviceMetricsTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeHorizontalDeviceMetricsTable then
  begin
    FVersion := TPascalTypeHorizontalDeviceMetricsTable(Source).FVersion;
    FSubtables.Assign(TPascalTypeHorizontalDeviceMetricsTable(Source).FSubtables);
  end;
end;

function TPascalTypeHorizontalDeviceMetricsTable.GetDeviceRecord(Index: Word): TPascalTypeHorizontalDeviceMetricsSubTable;
begin
  if (Index > FSubtables.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FSubtables[Index];
end;

function TPascalTypeHorizontalDeviceMetricsTable.GetDeviceRecordCount: Word;
begin
  Result := FSubtables.Count;
end;

class function TPascalTypeHorizontalDeviceMetricsTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'hdmx';
end;

procedure TPascalTypeHorizontalDeviceMetricsTable.LoadFromStream(Stream: TStream);
var
  OffsetPosition  : Int64;
  SizeDeviceRecord: Cardinal;
  NumRecords      : SmallInt;
  RecordIndex     : Cardinal;
  SubTableRecord  : TPascalTypeHorizontalDeviceMetricsSubTable;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read format type
    FVersion := BigEndianValueReader.ReadWord(Stream);

    if Version <> 0 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read num records
    NumRecords := BigEndianValueReader.ReadSmallInt(Stream);

    // read device record size
    SizeDeviceRecord := BigEndianValueReader.ReadCardinal(Stream);

    // store offset position
    OffsetPosition := Position;

    for RecordIndex := 0 to NumRecords - 1 do
    begin
      // locate current record
      Position := OffsetPosition + RecordIndex * SizeDeviceRecord;

      // create subtable entry
      // add subtable entry to subtables
      SubTableRecord := FSubtables.Add;

      // load subtable entry from stream
      SubTableRecord.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeHorizontalDeviceMetricsTable.SaveToStream(Stream: TStream);
begin
  with Stream do
  begin
    // write format type
    WriteSwappedWord(Stream, FVersion);

    // write num records
    WriteSwappedWord(Stream, FSubtables.Count);

    (*
      TODO: Write further TPascalTypeHorizontalDeviceMetricsTable properties

      // write device record size
      WriteSwappedWord(Stream, FSizeDeviceRecord);
    *)
  end;
end;

procedure TPascalTypeHorizontalDeviceMetricsTable.SetDeviceRecord(Index: Word;
  const Value: TPascalTypeHorizontalDeviceMetricsSubTable);
begin

end;

procedure TPascalTypeHorizontalDeviceMetricsTable.SetVersion(const Value: Word);
begin
  if (FVersion <> Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeHorizontalDeviceMetricsTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeKerningFormat0SubTable }

function TPascalTypeKerningFormat0SubTable.GetKerningValue(LeftGlyphIndex, RightGlyphIndex: Word): Word;
var
  PairIndex: Integer;
begin
  Result := 0;
  for PairIndex := 0 to High(FPairs) do
    if FPairs[PairIndex].Left = LeftGlyphIndex then
      if FPairs[PairIndex].Right = RightGlyphIndex then
      begin
        Result := FPairs[PairIndex].Value;
        Exit;
      end;
end;

function TPascalTypeKerningFormat0SubTable.GetPair(Index: Integer): TKerningFormat0SubTable;
begin
  if (Index < 0) or (Index > High(FPairs)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FPairs[Index];
end;

function TPascalTypeKerningFormat0SubTable.GetPairCount: Integer;
begin
  Result := Length(FPairs);
end;

procedure TPascalTypeKerningFormat0SubTable.LoadFromStream(Stream: TStream);
var
  PairIndex    : Integer;
{$ifdef KERN_BSEARCH}
  SearchRange  : Word;
  EntrySelector: Word;
  RangeShift   : Word;
{$endif KERN_BSEARCH}
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read number of pairs
  SetLength(FPairs, BigEndianValueReader.ReadWord(Stream));

{$ifdef KERN_BSEARCH}
  // Note: Cambria Light Bold has zero in SearchRange

  // read search range
  SearchRange := BigEndianValueReader.ReadWord(Stream);

  // confirm search range has a valid value
  if (SearchRange <> 0) and (SearchRange > Round(6 * (1 shl FloorLog2(Length(FPairs))))) then
    raise EPascalTypeError.Create(RCStrErrorInKerningSubTable + ': ' +
      RCStrWrongSearchRange);

  // read entry selector
  EntrySelector := BigEndianValueReader.ReadWord(Stream);

  // confirm entry selector has a valid value
  if (SearchRange <> 0) and (EntrySelector < Round(Log2(SearchRange / 6))) then
    raise EPascalTypeError.Create(RCStrErrorInKerningSubTable + ': ' +
      RCStrWrongEntrySelector);

  // read range shift
  RangeShift := BigEndianValueReader.ReadWord(Stream);

{$IFDEF AmbigiousExceptions}
  // confirm range shift has a valid value
  // "Calibri" fails this one. Since I can't really imagine that we will use the value
  // the test has been disabled.
(*
  if (SearchRange <> 0) and (RangeShift <> (6 * Length(FPairs) - SearchRange)) then
    raise EPascalTypeError.Create(RCStrErrorInKerningSubTable + ': ' + RCStrWrongRangeShift);
*)
{$ENDIF}
{$else KERN_BSEARCH}
  Stream.Seek(3*SizeOf(Word), soFromCurrent);
{$endif KERN_BSEARCH}

  for PairIndex := 0 to High(FPairs) do
  begin
    // read left
    FPairs[PairIndex].Left := BigEndianValueReader.ReadWord(Stream);

    // read right
    FPairs[PairIndex].Right := BigEndianValueReader.ReadWord(Stream);

    // read value
    FPairs[PairIndex].Value := BigEndianValueReader.ReadSmallInt(Stream);
  end;
end;

procedure TPascalTypeKerningFormat0SubTable.SaveToStream(Stream: TStream);
var
  PairIndex    : Integer;
  SearchRange  : Word;
  EntrySelector: Word;
  RangeShift   : Word;
begin
  inherited;

  // write number of pairs
  WriteSwappedWord(Stream, Length(FPairs));

  // write search range
  SearchRange := Round(6 * (Power(2, Floor(Log2(Length(FPairs))))));
  WriteSwappedWord(Stream, SearchRange);

  // write entry selector
  EntrySelector := Round(Log2(SearchRange / 6));
  WriteSwappedWord(Stream, EntrySelector);

  // write range shift
  RangeShift := 6 * Length(FPairs) - SearchRange;
  WriteSwappedWord(Stream, RangeShift);

  for PairIndex := 0 to High(FPairs) do
    with FPairs[PairIndex] do
    begin
      // write left
      WriteSwappedWord(Stream, Left);

      // write right
      WriteSwappedWord(Stream, Right);

      // write value
      WriteSwappedWord(Stream, Value);
    end;
end;


{ TPascalTypeKerningFormat2SubTable }

procedure TPascalTypeKerningFormat2SubTable.LoadFromStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;

procedure TPascalTypeKerningFormat2SubTable.SaveToStream(Stream: TStream);
begin
  inherited;
  raise EPascalTypeNotImplemented.Create(RCStrNotImplemented);
end;


{ TPascalTypeKerningSubTable }

constructor TPascalTypeKerningSubTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FFormatTable := TPascalTypeKerningFormat0SubTable.Create;
  AssignFormat;
end;

destructor TPascalTypeKerningSubTable.Destroy;
begin
  FreeAndNil(FFormatTable);
  inherited;
end;

procedure TPascalTypeKerningSubTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeKerningSubTable then
  begin
    FVersion := TPascalTypeKerningSubTable(Source).FVersion;
    FLength := TPascalTypeKerningSubTable(Source).FLength;
    FCoverage := TPascalTypeKerningSubTable(Source).FCoverage;

    FFormatTable.Assign(TPascalTypeKerningSubTable(Source).FFormatTable);
  end;
end;

procedure TPascalTypeKerningSubTable.LoadFromStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion := BigEndianValueReader.ReadWord(Stream);

    if FVersion <> 0 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read length
    FLength := BigEndianValueReader.ReadWord(Stream);

    // read coverage
    FCoverage := BigEndianValueReader.ReadWord(Stream);
    AssignFormat;

    case Format of
      0, 2:
        FFormatTable.LoadFromStream(Stream);
    else
      begin
        // check minimum size
        if Position + FLength - 6 > Size then
          raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

        Seek(soFromCurrent, FLength - 6);
      end;
    end;
  end;
end;

procedure TPascalTypeKerningSubTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write version
  WriteSwappedWord(Stream, FVersion);

  // write length
  WriteSwappedWord(Stream, FLength);

  // write coverage
  WriteSwappedWord(Stream, FCoverage);
end;

function TPascalTypeKerningSubTable.GetFormat: Byte;
begin
  Result := (FCoverage shr 8) and $FF;
end;

function TPascalTypeKerningSubTable.GetIsCrossStream: Boolean;
begin
  Result := (FCoverage and (1 shl 2)) > 0;
end;

function TPascalTypeKerningSubTable.GetIsHorizontal: Boolean;
begin
  Result := (FCoverage and 1) > 0;
end;

function TPascalTypeKerningSubTable.GetIsMinimum: Boolean;
begin
  Result := (FCoverage and (1 shl 1)) > 0;
end;

function TPascalTypeKerningSubTable.GetIsReplace: Boolean;
begin
  Result := (FCoverage and (1 shl 3)) > 0;
end;

procedure TPascalTypeKerningSubTable.SetFormat(const Value: Byte);
begin
  if Value <> Format then
  begin
    FCoverage := (FCoverage and $FF) or ((Value and $FF) shl 8);
    FormatChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsCrossStream(const Value: Boolean);
begin
  if IsCrossStream <> Value then
  begin
    FCoverage := (FCoverage and (not(1 shl 2))) or (Integer(Value = True) shl 2);
    IsCrossStreamChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsHorizontal(const Value: Boolean);
begin
  if IsHorizontal <> Value then
  begin
    FCoverage := (FCoverage and (not 1)) or (Integer(Value = True));
    IsHorizontalChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsMinimum(const Value: Boolean);
begin
  if IsMinimum <> Value then
  begin
    FCoverage := (FCoverage and (not(1 shl 1))) or (Integer(Value = True) shl 1);
    IsMinimumChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetIsReplace(const Value: Boolean);
begin
  if IsReplace <> Value then
  begin
    FCoverage := (FCoverage and (not(1 shl 3))) or (Integer(Value = True) shl 3);
    IsReplaceChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeKerningSubTable.AssignFormat;
var
  OldFormatTable: TCustomPascalTypeKerningFormatSubTable;
const
  CFormatClasses: array[0..1] of TCustomPascalTypeKerningFormatSubTableClass =
    (TPascalTypeKerningFormat0SubTable, TPascalTypeKerningFormat2SubTable);
begin
  case Format of
    0, 2:
      if not(FFormatTable is CFormatClasses[Format shr 1]) then
      begin
        OldFormatTable := FFormatTable;
        FFormatTable := CFormatClasses[Format shr 1].Create;
        if (OldFormatTable <> nil) then
        begin
          FFormatTable.Assign(OldFormatTable);
          OldFormatTable.Free;
        end;
      end;
  else
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);
  end;
end;

procedure TPascalTypeKerningSubTable.FormatChanged;
begin
  AssignFormat;
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.IsCrossStreamChanged;
begin
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.IsHorizontalChanged;
begin
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.IsMinimumChanged;
begin
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.IsReplaceChanged;
begin
  CoverageChanged;
end;

procedure TPascalTypeKerningSubTable.CoverageChanged;
begin
  Changed;
end;

procedure TPascalTypeKerningSubTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeKerningTable }

constructor TPascalTypeKerningTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FKerningSubtableList := TPascalTypeTableList<TPascalTypeKerningSubTable>.Create;
end;

destructor TPascalTypeKerningTable.Destroy;
begin
  FreeAndNil(FKerningSubtableList);
  inherited;
end;

procedure TPascalTypeKerningTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeKerningTable then
  begin
    FVersion := TPascalTypeKerningTable(Source).FVersion;
    FKerningSubtableList.Assign(TPascalTypeKerningTable(Source).FKerningSubtableList);
  end;
end;

function TPascalTypeKerningTable.GetKerningSubtable(Index: Integer): TPascalTypeKerningSubTable;
begin
  if (Index >= 0) and (Index < FKerningSubtableList.Count) then
    Result := FKerningSubtableList[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TPascalTypeKerningTable.GetKerningSubtableCount: Integer;
begin
  Result := FKerningSubtableList.Count;
end;

class function TPascalTypeKerningTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'kern';
end;

procedure TPascalTypeKerningTable.LoadFromStream(Stream: TStream);
var
  SubTableIndex: Integer;
  SubTable     : TPascalTypeKerningSubTable;
  SubTableCount: Word;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // clear eventually existing tables
    FKerningSubtableList.Clear;

    // read version
    FVersion := BigEndianValueReader.ReadWord(Stream);

    // For now we only support version 0 (same as Windows).
    // At time of writing, Apple has defined 3 additional versions.
    // https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6kern.html
    // TODO : Support for more kerning table versions
    if FVersion <> 0 then
      exit;
      // raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read number of glyphs
    SubTableCount := BigEndianValueReader.ReadWord(Stream);

    for SubTableIndex := 0 to SubTableCount - 1 do
    begin
      SubTable := FKerningSubtableList.Add;
      // load from stream
      SubTable.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeKerningTable.SaveToStream(Stream: TStream);
var
  SubTableIndex: Integer;
begin
  // write version
  WriteSwappedWord(Stream, FVersion);

  // write number of glyphs
  WriteSwappedWord(Stream, FKerningSubtableList.Count);

  // save to stream
  for SubTableIndex := 0 to FKerningSubtableList.Count - 1 do
    FKerningSubtableList[SubTableIndex].SaveToStream(Stream);
end;

procedure TPascalTypeKerningTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeKerningTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeLinearThresholdTable }

procedure TPascalTypeLinearThresholdTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeLinearThresholdTable then
  begin
    FVersion := TPascalTypeLinearThresholdTable(Source).FVersion;
    FVerticalPels := TPascalTypeLinearThresholdTable(Source).FVerticalPels;
  end;
end;

class function TPascalTypeLinearThresholdTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'LTSH';
end;

function TPascalTypeLinearThresholdTable.GetVerticalPel(Index: Integer): Byte;
begin
  if (Index >= 0) and (Index < Length(FVerticalPels)) then
    Result := FVerticalPels[Index]
  else
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
end;

function TPascalTypeLinearThresholdTable.GetVerticalPelCount: Integer;
begin
  Result := Length(FVerticalPels);
end;

procedure TPascalTypeLinearThresholdTable.LoadFromStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    Version := BigEndianValueReader.ReadWord(Stream);

    if Version <> 0 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read number of glyphs
    SetLength(FVerticalPels, BigEndianValueReader.ReadWord(Stream));

    if Position + Length(FVerticalPels) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read vertical pel height
    Read(FVerticalPels[0], Length(FVerticalPels));
  end;
end;

procedure TPascalTypeLinearThresholdTable.SaveToStream(Stream: TStream);
begin
  // write version
  WriteSwappedWord(Stream, Version);

  // write number of glyphs
  WriteSwappedWord(Stream, Length(FVerticalPels));

  // write vertical pel height
  Stream.Write(FVerticalPels[0], Length(FVerticalPels));
end;

procedure TPascalTypeLinearThresholdTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeLinearThresholdTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypePCL5Table }

constructor TPascalTypePCL5Table.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 1;
end;

procedure TPascalTypePCL5Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypePCL5Table then
  begin
    FVersion := TPascalTypePCL5Table(Source).FVersion;
    FFontNumber := TPascalTypePCL5Table(Source).FFontNumber;
    FPitch := TPascalTypePCL5Table(Source).FPitch;
    FXHeight := TPascalTypePCL5Table(Source).FXHeight;
    FStyle := TPascalTypePCL5Table(Source).FStyle;
    FTypeFamily := TPascalTypePCL5Table(Source).FTypeFamily;
    FCapHeight := TPascalTypePCL5Table(Source).FCapHeight;
    FSymbolSet := TPascalTypePCL5Table(Source).FSymbolSet;
    FTypeface := TPascalTypePCL5Table(Source).FTypeface;
    FCharacterComplement := TPascalTypePCL5Table(Source).FCharacterComplement;
    FFileName := TPascalTypePCL5Table(Source).FFileName;
    FStrokeWeight := TPascalTypePCL5Table(Source).FStrokeWeight;
    FWidthType := TPascalTypePCL5Table(Source).FWidthType;
    FSerifStyle := TPascalTypePCL5Table(Source).FSerifStyle;
    FPadding := TPascalTypePCL5Table(Source).FPadding;
  end;
end;

class function TPascalTypePCL5Table.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'PCLT';
end;

function TPascalTypePCL5Table.GetCharacterComplement: string;
begin
  Result := string(FTypeface);
end;

function TPascalTypePCL5Table.GetFileName: string;
begin
  Result := string(FFileName);
end;

function TPascalTypePCL5Table.GetTypeface: string;
begin
  Result := string(FTypeface);
end;

procedure TPascalTypePCL5Table.LoadFromStream(Stream: TStream);
var
  Value32: Cardinal;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 54 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion.Fixed := BigEndianValueReader.ReadCardinal(Stream);

    // A value of zero observed in the "Architecture" and "Technical" fonts
    if Version.Value <> 1 then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read font number
    Read(Value32, SizeOf(Cardinal));
    FFontNumber := TPcl5FontNumber(Value32);

    // read pitch
    FPitch := BigEndianValueReader.ReadWord(Stream);

    // read x-height
    FXHeight := BigEndianValueReader.ReadWord(Stream);

    // read style
    FStyle := BigEndianValueReader.ReadWord(Stream);

    // read type family
    FTypeFamily := BigEndianValueReader.ReadWord(Stream);

    // read capital height
    FCapHeight := BigEndianValueReader.ReadWord(Stream);

    // read symbol set
    FSymbolSet := BigEndianValueReader.ReadWord(Stream);

    // read typeface
    Read(FTypeface, 16);

    // read character complement
    Read(FCharacterComplement, 8);

    // read filename
    Read(FFileName, 6);

    // read stroke weight
    Read(FStrokeWeight, SizeOf(AnsiChar));

    // read width type
    Read(FWidthType, SizeOf(AnsiChar));

    // read serif style
    Read(FSerifStyle, SizeOf(Byte));

    // read Padding
    Read(FPadding, SizeOf(Byte));
  end;
end;

procedure TPascalTypePCL5Table.SaveToStream(Stream: TStream);
begin
  with Stream do
  begin
    // write version
    WriteSwappedCardinal(Stream, Cardinal(FVersion));

    // write font number
    WriteSwappedCardinal(Stream, Cardinal(FFontNumber));

    // write pitch
    WriteSwappedWord(Stream, FPitch);

    // write XHeight
    WriteSwappedWord(Stream, FXHeight);

    // write style
    WriteSwappedWord(Stream, FStyle);

    // write type family
    WriteSwappedWord(Stream, FTypeFamily);

    // write capital height
    WriteSwappedWord(Stream, FCapHeight);

    // write symbol set
    WriteSwappedWord(Stream, FSymbolSet);

    // write typeface
    Write(FTypeface, 16);

    // write character complement
    Write(FCharacterComplement, 8);

    // write filename
    Write(FFileName, 6);

    // write stroke weight
    Write(FStrokeWeight, SizeOf(AnsiChar));

    // write width type
    Write(FWidthType, SizeOf(AnsiChar));

    // write serif style
    Write(FSerifStyle, SizeOf(Byte));

    // write Padding
    Write(FPadding, SizeOf(Byte));
  end;
end;

procedure TPascalTypePCL5Table.SetCapHeight(const Value: Word);
begin
  if FCapHeight <> Value then
  begin
    FCapHeight := Value;
    CapHeightChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetCharacterComplement(const Value: string);
begin
  FillChar(FCharacterComplement[0], 8, 0);
  Move(Value[1], FCharacterComplement[0], Min(8, Length(Value)));
end;

procedure TPascalTypePCL5Table.SetFileName(const Value: string);
begin
  FillChar(FCharacterComplement[0], 6, 0);
  Move(Value[1], FCharacterComplement[0], Min(6, Length(Value)));
end;

procedure TPascalTypePCL5Table.SetFontNumber(const Value: TPcl5FontNumber);
begin
  if Cardinal(FFontNumber) <> Cardinal(Value) then
  begin
    FFontNumber := Value;
    FontNumberChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetPadding(const Value: Byte);
begin
  if FPadding <> Value then
  begin
    FPadding := Value;
    PaddingChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetPitch(const Value: Word);
begin
  if FPitch <> Value then
  begin
    FPitch := Value;
    PitchChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetSerifStyle(const Value: Byte);
begin
  if FSerifStyle <> Value then
  begin
    FSerifStyle := Value;
    SerifStyleChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetStrokeWeight(const Value: AnsiChar);
begin
  if FStrokeWeight <> Value then
  begin
    FStrokeWeight := Value;
    StrokeWeightChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetStyle(const Value: Word);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    StyleChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetSymbolSet(const Value: Word);
begin
  if FSymbolSet <> Value then
  begin
    FSymbolSet := Value;
    SymbolSetChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetTypeface(const Value: string);
begin
  FillChar(FCharacterComplement[0], 16, 0);
  Move(Value[1], FCharacterComplement[0], Min(16, Length(Value)));
end;

procedure TPascalTypePCL5Table.SetTypeFamily(const Value: Word);
begin
  if FTypeFamily <> Value then
  begin
    FTypeFamily := Value;
    TypeFamilyChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetWidthType(const Value: AnsiChar);
begin
  if FWidthType <> Value then
  begin
    FWidthType := Value;
    WidthTypeChanged;
  end;
end;

procedure TPascalTypePCL5Table.SetXHeight(const Value: Word);
begin
  if FXHeight <> Value then
  begin
    FXHeight := Value;
    XHeightChanged;
  end;
end;

procedure TPascalTypePCL5Table.CapHeightChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.FontNumberChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.PaddingChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.PitchChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.SerifStyleChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.StrokeWeightChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.StyleChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.SymbolSetChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.TypeFamilyChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.VersionChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.WidthTypeChanged;
begin
  Changed;
end;

procedure TPascalTypePCL5Table.XHeightChanged;
begin
  Changed;
end;


{ TPascalTypeVDMXGroupTable }

procedure TPascalTypeVDMXGroupTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeVDMXGroupTable then
  begin
    FStartsz := TPascalTypeVDMXGroupTable(Source).FStartsz;
    FEndsz := TPascalTypeVDMXGroupTable(Source).FEndsz;
    FEntry := TPascalTypeVDMXGroupTable(Source).FEntry;
  end;
end;

procedure TPascalTypeVDMXGroupTable.LoadFromStream(Stream: TStream);
var
  EntryIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read number of height records
    SetLength(FEntry, BigEndianValueReader.ReadWord(Stream));

    // read starting yPelHeight
    Read(FStartsz, 1);

    // read ending yPelHeight
    Read(FEndsz, 1);

    for EntryIndex := 0 to High(FEntry) do
      with FEntry[EntryIndex] do
      begin
        // read yPelHeight to which values apply.
        yPelHeight := BigEndianValueReader.ReadWord(Stream);

        // read Maximum value (in pels) for this yPelHeight.
        yMax := BigEndianValueReader.ReadSmallInt(Stream);

        // read Minimum value (in pels) for this yPelHeight.
        yMin := BigEndianValueReader.ReadSmallInt(Stream);
      end;
  end;
end;

procedure TPascalTypeVDMXGroupTable.SaveToStream(Stream: TStream);
var
  EntryIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // write number of height records
    WriteSwappedWord(Stream, Length(FEntry));

    // write starting yPelHeight
    Write(FStartsz, 1);

    // write ending yPelHeight
    Write(FEndsz, 1);

    for EntryIndex := 0 to High(FEntry) do
      with FEntry[EntryIndex] do
      begin
        // write yPelHeight to which values apply.
        WriteSwappedWord(Stream, yPelHeight);

        // write Maximum value (in pels) for this yPelHeight.
        WriteSwappedSmallInt(Stream, yMax);

        // write Minimum value (in pels) for this yPelHeight.
        WriteSwappedSmallInt(Stream, yMin);
      end;
  end;
end;


{ TPascalTypeVerticalDeviceMetricsTable }

constructor TPascalTypeVerticalDeviceMetricsTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FGroups := TPascalTypeTableList<TPascalTypeVDMXGroupTable>.Create;
end;

destructor TPascalTypeVerticalDeviceMetricsTable.Destroy;
begin
  FreeAndNil(FGroups);
  inherited;
end;

procedure TPascalTypeVerticalDeviceMetricsTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeVerticalDeviceMetricsTable then
  begin
    FVersion := TPascalTypeVerticalDeviceMetricsTable(Source).FVersion;
    FRatios := TPascalTypeVerticalDeviceMetricsTable(Source).FRatios;
    FGroups.Assign(TPascalTypeVerticalDeviceMetricsTable(Source).FGroups);
  end;
end;

function TPascalTypeVerticalDeviceMetricsTable.GetGroupCount: Word;
begin
  Result := FGroups.Count;
end;

function TPascalTypeVerticalDeviceMetricsTable.GetRatioCount: Word;
begin
  Result := Length(FRatios);
end;

class function TPascalTypeVerticalDeviceMetricsTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'VDMX';
end;

procedure TPascalTypeVerticalDeviceMetricsTable.LoadFromStream(Stream: TStream);
var
  RatioIndex: Integer;
  Offsets   : array of Word;
  NumRecs   : Word;
  Group     : TPascalTypeVDMXGroupTable;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 6 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion := BigEndianValueReader.ReadWord(Stream);

    // check version in 0..1
    if not(FVersion in [0..1]) then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);

    // read number of VDMX groups present
    NumRecs := BigEndianValueReader.ReadWord(Stream);

    // read number of aspect ratio groupings
    SetLength(FRatios, BigEndianValueReader.ReadWord(Stream));
    SetLength(Offsets, Length(FRatios));

    // check (minimum) table size
    if Position + 6 * Length(FRatios) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read ratios
    for RatioIndex := 0 to High(FRatios) do
      with FRatios[RatioIndex] do
      begin
        Read(bCharSet, 1);
        Read(xRatio, 1);
        Read(yStartRatio, 1);
        Read(yEndRatio, 1);
      end;

    // read offsets
    for RatioIndex := 0 to High(FRatios) do
      Offsets[RatioIndex] := BigEndianValueReader.ReadWord(Stream);

    // read groups
    for RatioIndex := 0 to NumRecs - 1 do
    begin
      // create new group
      // add group to list
      Group := FGroups.Add;

      // load gropu from stream
      Group.LoadFromStream(Stream);
    end;
  end;
end;

procedure TPascalTypeVerticalDeviceMetricsTable.SaveToStream(Stream: TStream);
begin
  // write version
  WriteSwappedWord(Stream, FVersion);

  // write number of VDMX groups present
  WriteSwappedWord(Stream, FGroups.Count);

  // write number of aspect ratio groupings
  WriteSwappedWord(Stream, Length(FRatios));
end;

procedure TPascalTypeVerticalDeviceMetricsTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeVerticalDeviceMetricsTable.VersionChanged;
begin
  Changed;
end;


initialization

  RegisterPascalTypeTables([TPascalTypeDigitalSignatureTable,
    TPascalTypeGridFittingAndScanConversionProcedureTable,
    TPascalTypeHorizontalDeviceMetricsTable, TPascalTypeKerningTable,
    TPascalTypeLinearThresholdTable, TPascalTypePCL5Table,
    TPascalTypeVerticalDeviceMetricsTable]);

end.
