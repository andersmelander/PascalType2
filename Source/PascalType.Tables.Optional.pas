unit PascalType.Tables.Optional;

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
  Classes, PascalType.Types, PascalType.Classes, PascalType.Tables;

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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property SignatureLength: Cardinal read GetSignatureLength;
    property SignatureByte[Index: Integer]: Byte read GetSignatureByte;
    property Reserved1: Word index 0 read FReserved[0] write SetReserved;
    property Reserved2: Word index 1 read FReserved[1] write SetReserved;
    property Format: Cardinal read FFormat write SetFormat;
  end;


  TPascalTypeDigitalSignatureTable = class(TCustomPascalTypeNamedTable)
  strict private type
    TDigitalSignatureDirectory = packed record
      Format: Cardinal; // Format of the signature
      Length: Cardinal; // Length of signature in bytes
      Offset: Cardinal; // Offset to the signature block from the beginning of the table
    end;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Cardinal read FVersion write SetVersion;
    property Flags: TDigitalSignatureFlags read FFlags write SetFlags;
    property SignatureCount: Integer read GetSignatureCount;
    property SignatureBlock[Index: Integer]: TPascalTypeDigitalSignatureBlock read GetSignatureBlock;
  end;


  // table 'gasp'

type
  TPascalTypeGridFittingAndScanConversionProcedureTable = class(TCustomPascalTypeNamedTable)
  public const
    Gasp_GridFit = 1;
    Gasp_DoGray = 2;

  public type
    TGaspRange = record
      MaxPPEM: Byte;
      GaspFlag: Byte;
    end;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
    property DeviceRecordCount: Word read GetDeviceRecordCount;
    property DeviceRecord[Index: Word]: TPascalTypeHorizontalDeviceMetricsSubTable read GetDeviceRecord write SetDeviceRecord;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
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
    property Padding: Byte read FPadding write SetPadding; // Reserved (set to 0 read FPadding write SetPadding)
  end;


  // table 'VDMX'

  TPascalTypeVDMXGroupTable = class(TCustomPascalTypeTable)
  public type
    TVDMXHeightRecord = packed record
      yPelHeight: Word; // yPelHeight to which values apply.
      yMax: SmallInt; // Maximum value (in pels) for this yPelHeight.
      yMin: SmallInt; // Minimum value (in pels) for this yPelHeight.
    end;

    TVDMXHeightRecords = TArray<TVDMXHeightRecord>;
  private
    FStartsz: Byte; // Starting yPelHeight
    FEndsz: Byte; // Ending yPelHeight
    FEntry: TVDMXHeightRecords; // The VDMX records
  protected
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    // TODO : Proper array getter
    property Entry: TVDMXHeightRecords read FEntry;
  end;

  TPascalTypeVerticalDeviceMetricsTable = class(TCustomPascalTypeNamedTable)
  public type
    TVDMXRatioRecord = packed record
      bCharSet: Byte; // Character set (see below).
      xRatio: Byte; // Value to use for x-Ratio
      yStartRatio: Byte; // Starting y-Ratio value.
      yEndRatio: Byte; // Ending y-Ratio value.
    end;
    TVDMXRatioRecords = TArray<TVDMXRatioRecord>;

  private
    FVersion: Word; // Version number (0 or 1).
    FRatios : TVDMXRatioRecords;
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

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;

    property RatioCount: Word read GetRatioCount;
    // TODO : Proper array getter
    property Ratios: TVDMXRatioRecords read FRatios;

    property GroupCount: Word read GetGroupCount;
    // TODO : Proper array getter
    property Groups: TPascalTypeTableList<TPascalTypeVDMXGroupTable> read FGroups;
  end;

implementation

uses
  Math,
  SysUtils,
  PascalType.ResourceStrings,
  PascalType.Tables.TrueType.maxp;


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

procedure TPascalTypeDigitalSignatureBlock.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 8 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FReserved[0] := BigEndianValue.ReadWord(Stream);
  FReserved[1] := BigEndianValue.ReadWord(Stream);
  SetLength(FSignature, BigEndianValue.ReadCardinal(Stream));

  // check if table contains the entire signature
  if Stream.Position + Length(FSignature) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  Stream.Read(FSignature[0], Length(FSignature));
end;

procedure TPascalTypeDigitalSignatureBlock.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteWord(Stream, FReserved[0]);
  BigEndianValue.WriteWord(Stream, FReserved[1]);
  BigEndianValue.WriteCardinal(Stream, Length(FSignature));
  Stream.Write(FSignature[0], Length(FSignature));
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

procedure TPascalTypeDigitalSignatureTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos : Int64;
  i : Integer;
  Directory: TArray<TDigitalSignatureDirectory>;
  SigBlock : TPascalTypeDigitalSignatureBlock;
begin
  // store stream start position
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 8 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FVersion := BigEndianValue.ReadCardinal(Stream);

  if Version <> 1 then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  SetLength(Directory, BigEndianValue.ReadWord(Stream));

  FFlags := WordToDigitalSignatureFlags(BigEndianValue.ReadWord(Stream));

  if Stream.Position + Length(Directory) * SizeOf(TDigitalSignatureDirectory) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read directory entry
  for i := 0 to High(Directory) do
  begin
    Directory[i].Format := BigEndianValue.ReadCardinal(Stream);
    Directory[i].Length := BigEndianValue.ReadCardinal(Stream);
    Directory[i].Offset := BigEndianValue.ReadCardinal(Stream);
  end;

  // clear existing signatures
  FSignatures.Clear;

  // read digital signatures
  for i := 0 to High(Directory) do
  begin
    Stream.Position := StartPos + Directory[i].Offset;

    // check if table contains the entire signature
    if Stream.Position + Directory[i].Length > Stream.Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // load digital signature from stream
    SigBlock := FSignatures.Add;
    SigBlock.LoadFromStream(Stream);
  end;
end;

procedure TPascalTypeDigitalSignatureTable.SaveToStream(Stream: TStream);
var
  StartPos : Int64;
  DirPos : Int64;
  i : Integer;
  Directory: TArray<TDigitalSignatureDirectory>;
begin
  // store stream start position
  StartPos := Stream.Position;

  inherited;

  BigEndianValue.WriteWord(Stream, FVersion);
  BigEndianValue.WriteWord(Stream, FSignatures.Count);
  BigEndianValue.WriteWord(Stream, DigitalSignatureFlagsToWord(FFlags));
  SetLength(Directory, FSignatures.Count);

  // offset directory
  DirPos := Stream.Position;
  Stream.Seek(soFromCurrent, FSignatures.Count * 3 * SizeOf(Cardinal));

  // build directory and store signature
  for i := 0 to FSignatures.Count - 1 do
  begin
    Directory[i].Format := FSignatures[i].Format;
    Directory[i].Offset := Stream.Position - StartPos;
    FSignatures[i].SaveToStream(Stream);
    Directory[i].Length := (Stream.Position - StartPos) - Directory[i].Offset;
  end;

  // locate directory
  Stream.Position := DirPos;

  // write directory entries
  for i := 0 to High(Directory) do
  begin
    BigEndianValue.WriteCardinal(Stream, Directory[i].Format);
    BigEndianValue.WriteCardinal(Stream, Directory[i].Length);
    BigEndianValue.WriteCardinal(Stream, Directory[i].Offset);
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

procedure TPascalTypeGridFittingAndScanConversionProcedureTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  i: Integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FVersion := BigEndianValue.ReadWord(Stream);

  // check version
  if not(Version in [0..1]) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  SetLength(FGaspRanges, BigEndianValue.ReadWord(Stream));

  // check (minimum) table size
  if Stream.Position + 4 * Length(FGaspRanges) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  for i := 0 to High(FGaspRanges) do
  begin
    FGaspRanges[i].MaxPPEM := Byte(BigEndianValue.ReadWord(Stream));
    FGaspRanges[i].GaspFlag := Byte(BigEndianValue.ReadWord(Stream));
  end;
end;

procedure TPascalTypeGridFittingAndScanConversionProcedureTable.SaveToStream(Stream: TStream);
var
  i: Integer;
begin
  BigEndianValue.WriteWord(Stream, FVersion);
  BigEndianValue.WriteWord(Stream, Length(FGaspRanges));

  for i := 0 to High(FGaspRanges) do
  begin
    BigEndianValue.WriteWord(Stream, FGaspRanges[i].MaxPPEM);
    BigEndianValue.WriteWord(Stream, FGaspRanges[i].GaspFlag);
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

procedure TPascalTypeHorizontalDeviceMetricsSubTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  MaxProfile: TPascalTypeMaximumProfileTable;
begin
  inherited;

  MaxProfile := TPascalTypeMaximumProfileTable(FontFace.GetTableByTableName('maxp'));

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read ppem
  Stream.Read(Fppem, 1);

  // read max width
  Stream.Read(FMaxWidth, 1);

  // set length of widths to number of glyphs
  SetLength(FWidths, MaxProfile.NumGlyphs);

  // check (minimum) table size
  if Stream.Position + Length(FWidths) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read widths
  Stream.Read(FWidths[0], Length(FWidths));
end;

procedure TPascalTypeHorizontalDeviceMetricsSubTable.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteWord(Stream, Fppem);
  BigEndianValue.WriteWord(Stream, FMaxWidth);
  Write(FWidths[0], Length(FWidths));
end;

procedure TPascalTypeHorizontalDeviceMetricsSubTable.SetMaxWidth(const Value: Byte);
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

procedure TPascalTypeHorizontalDeviceMetricsTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  OffsetPosition  : Int64;
  SizeDeviceRecord: Cardinal;
  NumRecords      : SmallInt;
  RecordIndex     : Cardinal;
  SubTableRecord  : TPascalTypeHorizontalDeviceMetricsSubTable;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 8 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FVersion := BigEndianValue.ReadWord(Stream);

  if Version <> 0 then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  NumRecords := BigEndianValue.ReadSmallInt(Stream);
  SizeDeviceRecord := BigEndianValue.ReadCardinal(Stream);

  // store offset position
  OffsetPosition := Stream.Position;

  for RecordIndex := 0 to NumRecords - 1 do
  begin
    // locate current record
    Stream.Position := OffsetPosition + RecordIndex * SizeDeviceRecord;

    // create subtable entry
    // add subtable entry to subtables
    SubTableRecord := FSubtables.Add;

    // load subtable entry from stream
    SubTableRecord.LoadFromStream(Stream);
  end;
end;

procedure TPascalTypeHorizontalDeviceMetricsTable.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteWord(Stream, FVersion);
  BigEndianValue.WriteWord(Stream, FSubtables.Count);

  (*
    TODO: Write further TPascalTypeHorizontalDeviceMetricsTable properties

    // write device record size
    BigEndianValue.WriteWord(Stream, FSizeDeviceRecord);
  *)
  Assert(False, 'Not implemented');
end;

procedure TPascalTypeHorizontalDeviceMetricsTable.SetDeviceRecord(Index: Word; const Value: TPascalTypeHorizontalDeviceMetricsSubTable);
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

procedure TPascalTypeLinearThresholdTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  Version := BigEndianValue.ReadWord(Stream);

  if Version <> 0 then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  SetLength(FVerticalPels, BigEndianValue.ReadWord(Stream));

  if Stream.Position + Length(FVerticalPels) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  Stream.Read(FVerticalPels[0], Length(FVerticalPels));
end;

procedure TPascalTypeLinearThresholdTable.SaveToStream(Stream: TStream);
begin
  BigEndianValue.WriteWord(Stream, Version);
  BigEndianValue.WriteWord(Stream, Length(FVerticalPels));
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

procedure TPascalTypePCL5Table.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 54 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FVersion.Fixed := BigEndianValue.ReadInteger(Stream);

  if Version.Value <> 1 then
  begin
    // A value of $00000100 observed in the "Architecture" and "Technical" fonts
    if (FVersion.Fixed <> $00000100) then
      raise EPascalTypeError.Create(RCStrUnsupportedVersion);
  end;

  FFontNumber := TPcl5FontNumber(BigEndianValue.ReadCardinal(Stream));
  FPitch := BigEndianValue.ReadWord(Stream);
  FXHeight := BigEndianValue.ReadWord(Stream);
  FStyle := BigEndianValue.ReadWord(Stream);
  FTypeFamily := BigEndianValue.ReadWord(Stream);
  FCapHeight := BigEndianValue.ReadWord(Stream);
  FSymbolSet := BigEndianValue.ReadWord(Stream);
  Stream.Read(FTypeface, 16);
  Stream.Read(FCharacterComplement, 8);
  Stream.Read(FFileName, 6);
  Stream.Read(FStrokeWeight, SizeOf(AnsiChar));
  Stream.Read(FWidthType, SizeOf(AnsiChar));
  Stream.Read(FSerifStyle, SizeOf(Byte));
  Stream.Read(FPadding, SizeOf(Byte));
end;

procedure TPascalTypePCL5Table.SaveToStream(Stream: TStream);
begin
  inherited;

  BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));
  BigEndianValue.WriteCardinal(Stream, Cardinal(FFontNumber));
  BigEndianValue.WriteWord(Stream, FPitch);
  BigEndianValue.WriteWord(Stream, FXHeight);
  BigEndianValue.WriteWord(Stream, FStyle);
  BigEndianValue.WriteWord(Stream, FTypeFamily);
  BigEndianValue.WriteWord(Stream, FCapHeight);
  BigEndianValue.WriteWord(Stream, FSymbolSet);
  Stream.Write(FTypeface, 16);
  Stream.Write(FCharacterComplement, 8);
  Stream.Write(FFileName, 6);
  Stream.Write(FStrokeWeight, SizeOf(AnsiChar));
  Stream.Write(FWidthType, SizeOf(AnsiChar));
  Stream.Write(FSerifStyle, SizeOf(Byte));
  Stream.Write(FPadding, SizeOf(Byte));
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

procedure TPascalTypeVDMXGroupTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  i: Integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  SetLength(FEntry, BigEndianValue.ReadWord(Stream));
  Stream.Read(FStartsz, 1);
  Stream.Read(FEndsz, 1);

  for i := 0 to High(FEntry) do
  begin
    FEntry[i].yPelHeight := BigEndianValue.ReadWord(Stream);
    FEntry[i].yMax := BigEndianValue.ReadSmallInt(Stream);
    FEntry[i].yMin := BigEndianValue.ReadSmallInt(Stream);
  end;
end;

procedure TPascalTypeVDMXGroupTable.SaveToStream(Stream: TStream);
var
  i: Integer;
begin
  inherited;

  BigEndianValue.WriteWord(Stream, Length(FEntry));
  Stream.Write(FStartsz, 1);
  Stream.Write(FEndsz, 1);

  for i := 0 to High(FEntry) do
  begin
    BigEndianValue.WriteWord(Stream, FEntry[i].yPelHeight);
    BigEndianValue.WriteSmallInt(Stream, FEntry[i].yMax);
    BigEndianValue.WriteSmallInt(Stream, FEntry[i].yMin);
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

procedure TPascalTypeVerticalDeviceMetricsTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  i: Integer;
  Offsets: array of Word;
  NumRecs: Word;
  Group: TPascalTypeVDMXGroupTable;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 6 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FVersion := BigEndianValue.ReadWord(Stream);

  if not(FVersion in [0..1]) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  NumRecs := BigEndianValue.ReadWord(Stream);
  SetLength(FRatios, BigEndianValue.ReadWord(Stream));
  SetLength(Offsets, Length(FRatios));

  if Stream.Position + 6 * Length(FRatios) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  for i := 0 to High(FRatios) do
  begin
    Stream.Read(FRatios[i].bCharSet, 1);
    Stream.Read(FRatios[i].xRatio, 1);
    Stream.Read(FRatios[i].yStartRatio, 1);
    Stream.Read(FRatios[i].yEndRatio, 1);
  end;

  for i := 0 to High(FRatios) do
    Offsets[i] := BigEndianValue.ReadWord(Stream);

  for i := 0 to NumRecs - 1 do
  begin
    Group := FGroups.Add;
    Group.LoadFromStream(Stream);
  end;
end;

procedure TPascalTypeVerticalDeviceMetricsTable.SaveToStream(Stream: TStream);
begin
  BigEndianValue.WriteWord(Stream, FVersion);
  BigEndianValue.WriteWord(Stream, FGroups.Count);
  BigEndianValue.WriteWord(Stream, Length(FRatios));
  Assert(False, 'Not implemented');
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

  PascalTypeTableClasses.RegisterTables([TPascalTypeDigitalSignatureTable,
    TPascalTypeGridFittingAndScanConversionProcedureTable,
    TPascalTypeHorizontalDeviceMetricsTable,
    TPascalTypeLinearThresholdTable, TPascalTypePCL5Table,
    TPascalTypeVerticalDeviceMetricsTable]);

end.
