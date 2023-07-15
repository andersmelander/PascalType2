unit PascalType.Tables.TrueType.Directory;

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
  SysUtils,
  PascalType.Types,
  PascalType.Classes;

type
  // TableRecord: TrueType Table Directory Entry type
  TDirectoryTableEntry = packed record
    TableType: TTableType; // Table type
    CheckSum: Cardinal;    // Table checksum
    Offset: Cardinal;      // Table file offset
    Length: Cardinal;      // Table length
  end;

  TPascalTypeDirectoryTableList = TArray<TDirectoryTableEntry>;

//------------------------------------------------------------------------------
//
//              TPascalTypeDirectoryTable
//
//------------------------------------------------------------------------------
// TrueType Table Directory type
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/otff#table-directory
//------------------------------------------------------------------------------
type
  TPascalTypeDirectoryTable = class(TCustomPascalTypeTable)
  private
    FVersion: Cardinal;  // A tag to indicate the OFA scaler (should be $10000)
    FTableList: TPascalTypeDirectoryTableList;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    function Contains(const TableName: TTableType): boolean;
    function FindTableEntry(const TableName: TTableType; var TableEntry: TDirectoryTableEntry): boolean;
    function IndexOfTableEntry(const TableName: TTableType): integer;

    property Version: Cardinal read FVersion;
    property TableList: TPascalTypeDirectoryTableList read FTableList;
  end;

const
  sfntVersionTrueType   = $00010000;
  sfntVersionCFF        = $4F54544F; // 'OTTO'
  sfntVersionAppleTT    = $74727565; // 'eurt' ('true') - Not valid for OpenType
  sfntVersionAppleType1 = $74797031; // '1pyt' ('typ1') - Not valid for OpenType

const
  ttName = $656D616E; // 'name'
  ttHead = $64616568; // 'head'
  ttGlyf = $66796C67; // 'glyf'
  ttLoca = $61636F6C; // 'loca'
  ttMaxp = $7078616D; // 'maxp'
  ttCmap = $70616D63; // 'cmap'
  ttHhea = $61656868; // 'hhea'
  ttHmtx = $78746D68; // 'hmtx'
  ttKern = $6E72656B; // 'kern'
  ttPost = $74736F70; // 'post'
  ttOS2  = $322F534F; // 'OS2 '

implementation

uses
  Math,
  Generics.Collections,
  Generics.Defaults,
  PascalType.ResourceStrings;

//------------------------------------------------------------------------------
//
//              TPascalTypeDirectoryTable
//
//------------------------------------------------------------------------------
function TPascalTypeDirectoryTable.FindTableEntry(const TableName: TTableType; var TableEntry: TDirectoryTableEntry): boolean;
var
  Index: integer;
begin
  Index := IndexOfTableEntry(TableName);
  if (Index <> -1) then
  begin
    Result := True;
    TableEntry := FTableList[Index];
  end else
    Result := False;
end;

function TPascalTypeDirectoryTable.Contains(const TableName: TTableType): boolean;
begin
  Result := (IndexOfTableEntry(TableName) <> -1);
end;

function TPascalTypeDirectoryTable.IndexOfTableEntry(const TableName: TTableType): integer;
var
  TableEntry: TDirectoryTableEntry;
begin
  TableEntry.TableType := TableName;
  if (not TArray.BinarySearch<TDirectoryTableEntry>(FTableList, TableEntry, Result, TComparer<TDirectoryTableEntry>.Construct(
    function(const Item1, Item2: TDirectoryTableEntry): Integer
    begin
      Result := BinaryCompare(@Item1, @Item2, SizeOf(TTableType));
    end))) then
    Result := -1;
end;

procedure TPascalTypeDirectoryTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeDirectoryTable then
  begin
    FVersion := TPascalTypeDirectoryTable(Source).FVersion;
    FTableList := Copy(TPascalTypeDirectoryTable(Source).FTableList);
  end;
end;

procedure TPascalTypeDirectoryTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  i: Integer;
begin
  inherited;

  // make sure at least the offset subtable is contained in the file
  if Size < 10 then
    raise EPascalTypeError.Create(RCStrWrongFilesize);

  // read version
  FVersion := BigEndianValue.ReadCardinal(Stream);

  // check for known scaler types (OSX and Windows)
  case Version of
    sfntVersionTrueType,
    sfntVersionCFF,
    sfntVersionAppleTT:
      ;
  else
    raise EPascalTypeError.CreateFmt(RCStrUnknownVersion, [Version]);
  end;

  SetLength(FTableList, BigEndianValue.ReadWord(Stream));

  // Skip binary search stuff
  Stream.Seek(3*SizeOf(Word), soFromCurrent);

  for i := 0 to High(FTableList) do
  begin
    Stream.Read(FTableList[i].TableType, SizeOf(TTableType));
    FTableList[i].CheckSum := BigEndianValue.ReadCardinal(Stream);
    FTableList[i].Offset := BigEndianValue.ReadCardinal(Stream);
    FTableList[i].Length := BigEndianValue.ReadCardinal(Stream);
  end;
end;

procedure TPascalTypeDirectoryTable.SaveToStream(Stream: TStream);
begin
  inherited;
end;

end.
