unit PascalType.Tables.OpenType.Coverage;

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
  TCoverageFormat = (
    cfList = 1,
    cfRange = 2
  );

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeCoverageTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#coverage-table
//------------------------------------------------------------------------------
type
  TCustomOpenTypeCoverageTable = class;
  TOpenTypeCoverageTableClass = class of TCustomOpenTypeCoverageTable;

  TCustomOpenTypeCoverageTable = class abstract(TCustomPascalTypeTable)
  protected
    FCoverageFormat: TCoverageFormat;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function IndexOfGlyph(AGlyphID: Word): integer; virtual; abstract;

    function Clone(AParent: TCustomPascalTypeTable = nil): TCustomOpenTypeCoverageTable;

    class function ClassByFormat(ACoverageFormat: TCoverageFormat): TOpenTypeCoverageTableClass;
    class function CreateFromStream(Stream: TStream; AParent: TCustomPascalTypeTable = nil): TCustomOpenTypeCoverageTable;

    property CoverageFormat: TCoverageFormat read FCoverageFormat;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeCoverageListTable
//
//------------------------------------------------------------------------------
// Coverage table: List of Glyph IDs
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#coverage-format-1
//------------------------------------------------------------------------------
type
  TOpenTypeCoverageListTable = class(TCustomOpenTypeCoverageTable)
  private
    FGlyphArray: TGlyphString; // Array of GlyphIDs-in numerical order
    function GetGlyph(Index: Integer): Word;
    function GetGlyphCount: Integer;
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function IndexOfGlyph(AGlyphID: Word): integer; override;

    property GlyphCount: Integer read GetGlyphCount;
    property Glyph[Index: Integer]: Word read GetGlyph;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeCoverageRangeTable
//
//------------------------------------------------------------------------------
// Coverage table: List of Glyph ID ranges
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#coverage-format-2
//------------------------------------------------------------------------------
type
  TCoverageRangeRecord = record
    StartGlyph         : Word; // First GlyphID in the range
    EndGlyph           : Word; // Last GlyphID in the range
    StartCoverageIndex : Word; // Coverage Index of first GlyphID in range
  end;

  TOpenTypeCoverageRangeTable = class(TCustomOpenTypeCoverageTable)
  private
    FRangeArray: array of TCoverageRangeRecord;
    function GetRange(Index: Integer): TCoverageRangeRecord;
    function GetRangeCount: Integer;
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function IndexOfGlyph(AGlyphID: Word): integer; override;

    property RangeCount: Integer read GetRangeCount;
    property Range[Index: Integer]: TCoverageRangeRecord read GetRange;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeCoverageTable
//
//------------------------------------------------------------------------------
procedure TCustomOpenTypeCoverageTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeCoverageTable then
    Assert(CoverageFormat = TCustomOpenTypeCoverageTable(Source).CoverageFormat);
end;

procedure TCustomOpenTypeCoverageTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  if (TCoverageFormat(BigEndianValueReader.ReadWord(Stream)) <> FCoverageFormat) then
    raise EPascalTypeError.Create('Coverage format mismatch');
end;

procedure TCustomOpenTypeCoverageTable.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedWord(Stream, Ord(FCoverageFormat));
end;

class function TCustomOpenTypeCoverageTable.ClassByFormat(ACoverageFormat: TCoverageFormat): TOpenTypeCoverageTableClass;
begin
  case ACoverageFormat of
    cfList:
      Result := TOpenTypeCoverageListTable;

    cfRange:
      Result := TOpenTypeCoverageRangeTable;
  else
    raise EPascalTypeError.CreateFmt('Invalid coverage format: %d', [Ord(ACoverageFormat)]);
  end;
end;

function TCustomOpenTypeCoverageTable.Clone(AParent: TCustomPascalTypeTable): TCustomOpenTypeCoverageTable;
begin
  Result := ClassByFormat(CoverageFormat).Create(AParent);
  try
    Result.Assign(Self);
  except
    Result.Free;
    raise;
  end;
end;

class function TCustomOpenTypeCoverageTable.CreateFromStream(Stream: TStream; AParent: TCustomPascalTypeTable): TCustomOpenTypeCoverageTable;
var
  SavePos: Int64;
  CoverageFormat: TCoverageFormat;
begin
  SavePos := Stream.Position;

  // Get the coverage type so we can create the correct object to read the coverage table
  CoverageFormat := TCoverageFormat(BigEndianValueReader.ReadWord(Stream));
  Result := TCustomOpenTypeCoverageTable.ClassByFormat(CoverageFormat).Create(AParent);
  try
    Stream.Position := SavePos;
    Result.LoadFromStream(Stream);
  except
    Result.Free;
    raise;
  end;
end;

//------------------------------------------------------------------------------
//
//              TOpenTypeCoverageListTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeCoverageListTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FCoverageFormat := cfList;
end;

procedure TOpenTypeCoverageListTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeCoverageListTable then
    FGlyphArray := TOpenTypeCoverageListTable(Source).FGlyphArray;
end;

function TOpenTypeCoverageListTable.GetGlyph(Index: Integer): Word;
begin
  if (Index < 0) or (Index > High(FGlyphArray)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FGlyphArray[Index];
end;

function TOpenTypeCoverageListTable.GetGlyphCount: Integer;
begin
  Result := Length(FGlyphArray);
end;

function TOpenTypeCoverageListTable.IndexOfGlyph(AGlyphID: Word): integer;
begin
  if (not TArray.BinarySearch<Word>(FGlyphArray, AGlyphID, Result)) then
    Result := -1;
end;

procedure TOpenTypeCoverageListTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  GlyphIndex: Integer;
begin
  inherited;

  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  SetLength(FGlyphArray, BigEndianValueReader.ReadWord(Stream));

  for GlyphIndex := 0 to High(FGlyphArray) do
    FGlyphArray[GlyphIndex] := BigEndianValueReader.ReadWord(Stream);
end;

procedure TOpenTypeCoverageListTable.SaveToStream(Stream: TStream);
var
  GlyphIndex: Integer;
begin
  inherited;

  WriteSwappedWord(Stream, Length(FGlyphArray));

  for GlyphIndex := 0 to High(FGlyphArray) do
    WriteSwappedWord(Stream, FGlyphArray[GlyphIndex]);
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeCoverageRangeTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeCoverageRangeTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FCoverageFormat := cfRange;
end;

procedure TOpenTypeCoverageRangeTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeCoverageRangeTable then
    FRangeArray := TOpenTypeCoverageRangeTable(Source).FRangeArray;
end;

function TOpenTypeCoverageRangeTable.GetRange(Index: Integer): TCoverageRangeRecord;
begin
  if (Index < 0) or (Index > High(FRangeArray)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FRangeArray[Index];
end;

function TOpenTypeCoverageRangeTable.GetRangeCount: Integer;
begin
  Result := Length(FRangeArray);
end;

function TOpenTypeCoverageRangeTable.IndexOfGlyph(AGlyphID: Word): integer;
var
  Lo, Hi, Mid: Integer;
begin
  // Binary search
  Lo := Low(FRangeArray);
  Hi := High(FRangeArray);
  while (Lo <= Hi) do
  begin
    Mid := (Lo + Hi) div 2;
    if (AGlyphID > FRangeArray[Mid].EndGlyph) then
      Lo := Succ(Mid)
    else
    if (AGlyphID < FRangeArray[Mid].StartGlyph) then
      Hi := Pred(Mid)
    else
      Exit(FRangeArray[Mid].StartCoverageIndex + AGlyphID - FRangeArray[Mid].StartGlyph);
  end;
  Result := -1;
end;

procedure TOpenTypeCoverageRangeTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  GlyphIndex: Integer;
begin
  inherited;

  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  SetLength(FRangeArray, BigEndianValueReader.ReadWord(Stream));

  for GlyphIndex := 0 to High(FRangeArray) do
  begin
    FRangeArray[GlyphIndex].StartGlyph := BigEndianValueReader.ReadWord(Stream);
    FRangeArray[GlyphIndex].EndGlyph := BigEndianValueReader.ReadWord(Stream);
    FRangeArray[GlyphIndex].StartCoverageIndex := BigEndianValueReader.ReadWord(Stream);
  end;
end;

procedure TOpenTypeCoverageRangeTable.SaveToStream(Stream: TStream);
var
  GlyphIndex: Integer;
begin
  inherited;

  WriteSwappedWord(Stream, Length(FRangeArray));

  for GlyphIndex := 0 to High(FRangeArray) do
  begin
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].StartGlyph);
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].EndGlyph);
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].StartCoverageIndex);
  end;
end;

//------------------------------------------------------------------------------

end.
