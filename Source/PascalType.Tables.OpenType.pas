unit PascalType.Tables.OpenType;

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
  Generics.Collections,
  Generics.Defaults,
  Classes,
  PT_Types,
  PT_Classes,
  PT_Tables;

type
  TTagOffsetRecord = packed record
    Tag: TTableType;
    Offset: Word;
  end;

type
  TCustomOpenTypeNamedTable = class(TCustomPascalTypeNamedTable)
  protected
    class function GetDisplayName: string; virtual; abstract;
  public
    property DisplayName: string read GetDisplayName; // TODO : Should be a class property
  end;

  TCustomOpenTypeVersionedNamedTable = class(TCustomPascalTypeNamedTable)
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

  TCustomOpenTypeClassDefinitionTable = class(TCustomPascalTypeTable)
  protected
    class function GetClassFormat: Word; virtual; abstract;
  public
    property ClassFormat: Word read GetClassFormat;
  end;

  TOpenTypeClassDefinitionTableClass = class of TCustomOpenTypeClassDefinitionTable;

  TOpenTypeClassDefinitionFormat1Table = class(TCustomOpenTypeClassDefinitionTable)
  private
    FStartGlyph      : Word;          // First GlyphID of the ClassValueArray
    FClassValueArray : array of Word; // Array of Class Values-one per GlyphID
    procedure SetStartGlyph(const Value: Word);
    function GetClassValueCount: Integer;
    function GetClassValue(Index: Integer): Word;
  protected
    class function GetClassFormat: Word; override;

    procedure StartGlyphChanged; virtual;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property StartGlyph: Word read FStartGlyph write SetStartGlyph;
    property ClassValueCount: Integer read GetClassValueCount;
    property ClassValue[Index: Integer]: Word read GetClassValue;
  end;

  TClassRangeRecord = packed record
    StartGlyph : Word; // First GlyphID in the range
    EndGlyph   : Word; // Last GlyphID in the range
    GlyphClass : Word; // Applied to all glyphs in the range
  end;

  TOpenTypeClassDefinitionFormat2Table = class(TCustomOpenTypeClassDefinitionTable)
  private
    FClassRangeRecords: array of TClassRangeRecord; // Array of ClassRangeRecords-ordered by Start GlyphID
    function GetClassRangeRecord(Index: Integer): TClassRangeRecord;
    function GetClassRangeRecordCount: Integer;

  protected
    class function GetClassFormat: Word; override;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property ClassRangeRecordCount: Integer read GetClassRangeRecordCount;
    property ClassRangeRecord[Index: Integer]: TClassRangeRecord read GetClassRangeRecord;
  end;

  // https://learn.microsoft.com/en-us/typography/opentype/spec/gdef#mark-glyph-sets-table
  TOpenTypeMarkGlyphSetTable = class(TCustomPascalTypeTable)
  private
    FTableFormat: Word; // Format identifier == 1
    FCoverage   : array of Cardinal; // Array of offsets to mark set coverage tables.
    function GetCoverage(Index: Integer): Cardinal;
    function GetCoverageCount: Integer;
    procedure SetTableFormat(const Value: Word);
  protected
    procedure TableFormatChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property TableFormat: Word read FTableFormat write SetTableFormat;
    property CoverageCount: Integer read GetCoverageCount;
    property Coverage[Index: Integer]: Cardinal read GetCoverage;
  end;


implementation

uses
  Math, SysUtils,
  PT_Math,
  PT_ResourceStrings;


{ TCustomOpenTypeVersionedNamedTable }

constructor TCustomOpenTypeVersionedNamedTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion := 0;
end;

procedure TCustomOpenTypeVersionedNamedTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeVersionedNamedTable then
    FVersion := TCustomOpenTypeVersionedNamedTable(Source).FVersion;
end;

procedure TCustomOpenTypeVersionedNamedTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read version
  FVersion.Fixed := BigEndianValueReader.ReadCardinal(Stream);
end;

procedure TCustomOpenTypeVersionedNamedTable.SaveToStream(Stream: TStream);
begin
  inherited;

  // write version
  WriteSwappedCardinal(Stream, Cardinal(Version));
end;

procedure TCustomOpenTypeVersionedNamedTable.SetVersion
  (const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TCustomOpenTypeVersionedNamedTable.VersionChanged;
begin
  Changed;
end;


{ TCustomOpenTypeClassDefinitionTable }


{ TOpenTypeClassDefinitionFormat1Table }

procedure TOpenTypeClassDefinitionFormat1Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeClassDefinitionFormat1Table then
  begin
    FStartGlyph := TOpenTypeClassDefinitionFormat1Table(Source).FStartGlyph;
    FClassValueArray := TOpenTypeClassDefinitionFormat1Table(Source).FClassValueArray;
  end;
end;

class function TOpenTypeClassDefinitionFormat1Table.GetClassFormat: Word;
begin
  Result := 1;
end;

function TOpenTypeClassDefinitionFormat1Table.GetClassValue(Index: Integer): Word;
begin
  if (Index < 0) or (Index > High(FClassValueArray)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FClassValueArray[Index];
end;

function TOpenTypeClassDefinitionFormat1Table.GetClassValueCount: Integer;
begin
  Result := Length(FClassValueArray);
end;

procedure TOpenTypeClassDefinitionFormat1Table.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  ArrayIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 4 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read start glyph
    FStartGlyph := BigEndianValueReader.ReadWord(Stream);

    // read ClassValueArray length
    SetLength(FClassValueArray, BigEndianValueReader.ReadWord(Stream));

    // read ClassValueArray
    for ArrayIndex := 0 to High(FClassValueArray) do
      FClassValueArray[ArrayIndex] := BigEndianValueReader.ReadWord(Stream);
  end;
end;

procedure TOpenTypeClassDefinitionFormat1Table.SaveToStream(Stream: TStream);
var
  ArrayIndex: Integer;
begin
  inherited;

  // write start glyph
  WriteSwappedWord(Stream, FStartGlyph);

  // write ClassValueArray length
  WriteSwappedWord(Stream, Length(FClassValueArray));

  // write ClassValueArray
  for ArrayIndex := 0 to High(FClassValueArray) do
    WriteSwappedWord(Stream, FClassValueArray[ArrayIndex]);
end;

procedure TOpenTypeClassDefinitionFormat1Table.SetStartGlyph(const Value: Word);
begin
  if FStartGlyph <> Value then
  begin
    FStartGlyph := Value;
    StartGlyphChanged;
  end;
end;

procedure TOpenTypeClassDefinitionFormat1Table.StartGlyphChanged;
begin
  Changed;
end;


{ TOpenTypeClassDefinitionFormat2Table }

procedure TOpenTypeClassDefinitionFormat2Table.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeClassDefinitionFormat2Table then
    FClassRangeRecords := TOpenTypeClassDefinitionFormat2Table(Source).FClassRangeRecords;
end;

class function TOpenTypeClassDefinitionFormat2Table.GetClassFormat: Word;
begin
  Result := 2;
end;

function TOpenTypeClassDefinitionFormat2Table.GetClassRangeRecord(Index: Integer): TClassRangeRecord;
begin
  if (Index < 0) or (Index > High(FClassRangeRecords)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FClassRangeRecords[Index];
end;

function TOpenTypeClassDefinitionFormat2Table.GetClassRangeRecordCount: Integer;
begin
  Result := Length(FClassRangeRecords);
end;

procedure TOpenTypeClassDefinitionFormat2Table.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  ArrayIndex: Integer;
begin
  inherited;

  with Stream do
  begin
    // check (minimum) table size
    if Position + 2 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read ClassRangeRecords length
    SetLength(FClassRangeRecords, BigEndianValueReader.ReadWord(Stream));

    // read ClassRangeRecords
    for ArrayIndex := 0 to High(FClassRangeRecords) do
      with FClassRangeRecords[ArrayIndex] do
      begin
        // read start glyph
        StartGlyph := BigEndianValueReader.ReadWord(Stream);

        // read end glyph
        EndGlyph := BigEndianValueReader.ReadWord(Stream);

        // read glyph class
        GlyphClass := BigEndianValueReader.ReadWord(Stream);
      end;
  end;
end;

procedure TOpenTypeClassDefinitionFormat2Table.SaveToStream(Stream: TStream);
begin
  inherited;

  // write ClassRangeRecords length
  WriteSwappedWord(Stream, Length(FClassRangeRecords));
end;


{ TOpenTypeMarkGlyphSetTable }

constructor TOpenTypeMarkGlyphSetTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FTableFormat := 1;
end;

procedure TOpenTypeMarkGlyphSetTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeMarkGlyphSetTable then
  begin
    FTableFormat := TOpenTypeMarkGlyphSetTable(Source).FTableFormat;
    FCoverage := TOpenTypeMarkGlyphSetTable(Source).FCoverage;
  end;
end;

function TOpenTypeMarkGlyphSetTable.GetCoverage(Index: Integer): Cardinal;
begin
  if (Index < 0) or (Index > High(FCoverage)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FCoverage[Index];
end;

function TOpenTypeMarkGlyphSetTable.GetCoverageCount: Integer;
begin
  Result := Length(FCoverage);
end;

procedure TOpenTypeMarkGlyphSetTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  CoverageIndex: Integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 2*SizeOf(Word) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read format
  FTableFormat := BigEndianValueReader.ReadWord(Stream);

  if FTableFormat > 1 then
    raise EPascalTypeError.Create(RCStrUnknownFormat);

  // read coverage length
  SetLength(FCoverage, BigEndianValueReader.ReadWord(Stream));

  // check (minimum) table size
  if Stream.Position + Length(FCoverage) * SizeOf(Cardinal) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read coverage data
  for CoverageIndex := 0 to High(FCoverage) do
    FCoverage[CoverageIndex] := BigEndianValueReader.ReadCardinal(Stream);
end;

procedure TOpenTypeMarkGlyphSetTable.SaveToStream(Stream: TStream);
var
  CoverageIndex: Integer;
begin
  inherited;

  // write table format
  WriteSwappedWord(Stream, FTableFormat);

  // write coverage length
  WriteSwappedWord(Stream, Length(FCoverage));

  // write coverage data
  for CoverageIndex := 0 to High(FCoverage) do
    WriteSwappedCardinal(Stream, FCoverage[CoverageIndex]);
end;

procedure TOpenTypeMarkGlyphSetTable.SetTableFormat(const Value: Word);
begin
  if FTableFormat <> Value then
  begin
    FTableFormat := Value;
    TableFormatChanged;
  end;
end;

procedure TOpenTypeMarkGlyphSetTable.TableFormatChanged;
begin
  Changed;
end;


end.
