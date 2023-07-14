unit PascalType.Tables.OpenType.ClassDefinition;

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
  PascalType.Tables;


type
  TClassDefinitionFormat = (
    cdfList = 1,
    cdfRange = 2
  );

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeClassDefinitionTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#class-definition-table
//------------------------------------------------------------------------------
type
  TCustomOpenTypeClassDefinitionTable = class;
  TOpenTypeClassDefinitionTableClass = class of TCustomOpenTypeClassDefinitionTable;

  TCustomOpenTypeClassDefinitionTable = class abstract(TCustomPascalTypeTable)
  protected
    FClassFormat: TClassDefinitionFormat;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function ClassByGlyphID(AGlyphID: Word): integer; virtual; abstract;

    class function ClassByFormat(AClassFormat: TClassDefinitionFormat): TOpenTypeClassDefinitionTableClass;

    property ClassFormat: TClassDefinitionFormat read FClassFormat;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeClassDefinitionListTable
//
//------------------------------------------------------------------------------
// Class definition table, format 1: List of Class IDs
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#class-definition-table-format-1
//------------------------------------------------------------------------------
type
  TOpenTypeClassDefinitionListTable = class(TCustomOpenTypeClassDefinitionTable)
  private
    FStartGlyphID: Word; // First GlyphID in the list
    FClassIDArray: TArray<Word>; // Array of class IDs
    function GetClassID(Index: Integer): Word;
    function GetClassCount: Integer;
  protected
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function ClassByGlyphID(AGlyphID: Word): integer; override;

    property StartGlyphID: Word read FStartGlyphID write FStartGlyphID;
    property ClassCount: Integer read GetClassCount;
    property ClassID[Index: Integer]: Word read GetClassID;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeClassDefinitionRangeTable
//
//------------------------------------------------------------------------------
// Class definition table, format 2: List of ClassID ID ranges
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#class-definition-table-format-2
//------------------------------------------------------------------------------
type
  TOpenTypeClassDefinitionRangeTable = class(TCustomOpenTypeClassDefinitionTable)
  public type
    TClassDefinitionRangeRecord = record
      StartGlyphID: Word;       // First GlyphID in the range
      EndGlyphID: Word;         // Last GlyphID in the range
      ClassID: Word;            // Class ID of first GlyphID in range
    end;
  private
    FRangeArray: array of TClassDefinitionRangeRecord;
  protected
    function GetRange(Index: Integer): TClassDefinitionRangeRecord;
    function GetRangeCount: Integer;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function ClassByGlyphID(AGlyphID: Word): integer; override;

    property RangeCount: Integer read GetRangeCount;
    property Range[Index: Integer]: TClassDefinitionRangeRecord read GetRange;
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
//              TCustomOpenTypeClassDefinitionTable
//
//------------------------------------------------------------------------------
procedure TCustomOpenTypeClassDefinitionTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypeClassDefinitionTable then
    Assert(ClassFormat = TCustomOpenTypeClassDefinitionTable(Source).ClassFormat);
end;

procedure TCustomOpenTypeClassDefinitionTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  if (TClassDefinitionFormat(BigEndianValueReader.ReadWord(Stream)) <> FClassFormat) then
    raise EPascalTypeError.Create('Class definition format mismatch');
end;

procedure TCustomOpenTypeClassDefinitionTable.SaveToStream(Stream: TStream);
begin
  inherited;

  WriteSwappedWord(Stream, Ord(FClassFormat));
end;

class function TCustomOpenTypeClassDefinitionTable.ClassByFormat(AClassFormat: TClassDefinitionFormat): TOpenTypeClassDefinitionTableClass;
begin
  case AClassFormat of
    cdfList:
      Result := TOpenTypeClassDefinitionListTable;

    cdfRange:
      Result := TOpenTypeClassDefinitionRangeTable;
  else
    Result := nil;
  end;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeClassDefinitionListTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeClassDefinitionListTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FClassFormat := cdfList;
end;

procedure TOpenTypeClassDefinitionListTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeClassDefinitionListTable then
    FClassIDArray := TOpenTypeClassDefinitionListTable(Source).FClassIDArray;
end;

function TOpenTypeClassDefinitionListTable.ClassByGlyphID(AGlyphID: Word): integer;
var
  Index: integer;
begin
  Index := AGlyphID - FStartGlyphID;
  if (Index >= 0) and (Index <= High(FClassIDArray)) then
    Result := FClassIDArray[Index]
  else
    Result := 0; // Glyphs not in table belong to class #0
end;

function TOpenTypeClassDefinitionListTable.GetClassID(Index: Integer): Word;
begin
  if (Index < 0) or (Index > High(FClassIDArray)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FClassIDArray[Index];
end;

function TOpenTypeClassDefinitionListTable.GetClassCount: Integer;
begin
  Result := Length(FClassIDArray);
end;

procedure TOpenTypeClassDefinitionListTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  i: Integer;
begin
  inherited;

  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  FStartGlyphID := BigEndianValueReader.ReadWord(Stream);

  SetLength(FClassIDArray, BigEndianValueReader.ReadWord(Stream));

  for i := 0 to High(FClassIDArray) do
    FClassIDArray[i] := BigEndianValueReader.ReadWord(Stream);
end;

procedure TOpenTypeClassDefinitionListTable.SaveToStream(Stream: TStream);
var
  i: Integer;
begin
  inherited;

  WriteSwappedWord(Stream, FStartGlyphID);
  WriteSwappedWord(Stream, Length(FClassIDArray));

  for i := 0 to High(FClassIDArray) do
    WriteSwappedWord(Stream, FClassIDArray[i]);
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeClassDefinitionRangeTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeClassDefinitionRangeTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FClassFormat := cdfRange;
end;

procedure TOpenTypeClassDefinitionRangeTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeClassDefinitionRangeTable then
    FRangeArray := TOpenTypeClassDefinitionRangeTable(Source).FRangeArray;
end;

function TOpenTypeClassDefinitionRangeTable.GetRange(Index: Integer): TClassDefinitionRangeRecord;
begin
  if (Index < 0) or (Index > High(FRangeArray)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FRangeArray[Index];
end;

function TOpenTypeClassDefinitionRangeTable.GetRangeCount: Integer;
begin
  Result := Length(FRangeArray);
end;

function TOpenTypeClassDefinitionRangeTable.ClassByGlyphID(AGlyphID: Word): integer;
var
  Lo, Hi, Mid: Integer;
begin
  // Binary search
  Lo := Low(FRangeArray);
  Hi := High(FRangeArray);
  while (Lo <= Hi) do
  begin
    Mid := (Lo + Hi) div 2;
    if (AGlyphID > FRangeArray[Mid].EndGlyphID) then
      Lo := Succ(Mid)
    else
    if (AGlyphID < FRangeArray[Mid].StartGlyphID) then
      Hi := Pred(Mid)
    else
      Exit(FRangeArray[Mid].ClassID);
  end;

  Result := 0; // Glyphs not in table belong to class #0
end;

procedure TOpenTypeClassDefinitionRangeTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  i: Integer;
begin
  inherited;

  if Stream.Position + SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  SetLength(FRangeArray, BigEndianValueReader.ReadWord(Stream));

  for i := 0 to High(FRangeArray) do
  begin
    FRangeArray[i].StartGlyphID := BigEndianValueReader.ReadWord(Stream);
    FRangeArray[i].EndGlyphID := BigEndianValueReader.ReadWord(Stream);
    FRangeArray[i].ClassID := BigEndianValueReader.ReadWord(Stream);
  end;
end;

procedure TOpenTypeClassDefinitionRangeTable.SaveToStream(Stream: TStream);
var
  GlyphIndex: Integer;
begin
  inherited;

  WriteSwappedWord(Stream, Length(FRangeArray));

  for GlyphIndex := 0 to High(FRangeArray) do
  begin
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].StartGlyphID);
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].EndGlyphID);
    WriteSwappedWord(Stream, FRangeArray[GlyphIndex].ClassID);
  end;
end;

//------------------------------------------------------------------------------

end.
