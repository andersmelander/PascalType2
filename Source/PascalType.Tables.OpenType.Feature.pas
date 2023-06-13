unit PascalType.Tables.OpenType.Feature;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'JSTF' table type                                     //
//                                                                            //
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
  PT_Tables,
  PascalType.Tables.OpenType;

//------------------------------------------------------------------------------
//
//              TCustomOpenTypeFeatureTable
//
//------------------------------------------------------------------------------
type
  TCustomOpenTypeFeatureTable = class abstract(TCustomOpenTypeNamedTable)
  private
    FFeatureParams   : Word;          // = NULL (reserved for offset to FeatureParams)
    FLookupListIndex : TArray<Word>; // Array of LookupList indices for this feature -zero-based (first lookup is LookupListIndex = 0)
    function GetLookupList(Index: Integer): Word;
    function GetLookupListCount: Integer;
    procedure SetFeatureParams(const Value: Word);
  protected
    procedure FeatureParamsChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function GetEnumerator: TEnumerator<Word>;

    property FeatureParams: Word read FFeatureParams write SetFeatureParams;
    // https://learn.microsoft.com/en-us/typography/opentype/spec/images/gsub_fig3g.png
    property LookupListCount: Integer read GetLookupListCount;
    property LookupList[Index: Integer]: Word read GetLookupList; default;
  end;

  TOpenTypeFeatureTableClass = class of TCustomOpenTypeFeatureTable;


//------------------------------------------------------------------------------
//
//              TOpenTypeFeatureTableGeneric
//
//------------------------------------------------------------------------------
// Generic placeholder for those features that have no concrete implementation.
//------------------------------------------------------------------------------
type
  TOpenTypeFeatureTableGeneric = class(TCustomOpenTypeFeatureTable)
  private
    FTableType: TTableType;
  protected
    function GetInternalTableType: TTableType; override;
    class function GetDisplayName: string; override;
  public
    class function GetTableType: TTableType; override;

    property TableType: TTableType read GetInternalTableType write FTableType;
  end;

//------------------------------------------------------------------------------
//
//              TOpenTypeFeatureListTable
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2#feature-list-table
//------------------------------------------------------------------------------
type
  TOpenTypeFeatureListTable = class(TCustomPascalTypeTable)
  private
    FFeatureList: TPascalTypeTableInterfaceList<TCustomOpenTypeFeatureTable>;
    function GetFeature(Index: Integer): TCustomOpenTypeFeatureTable;
    function GetFeatureCount: Integer;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    function FindFeature(const ATableType: TTableType): TCustomOpenTypeFeatureTable;

    property FeatureCount: Integer read GetFeatureCount;
    property Feature[Index: Integer]: TCustomOpenTypeFeatureTable read GetFeature;
  end;


//------------------------------------------------------------------------------
//
//      Features
//
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/featuretags
//------------------------------------------------------------------------------
procedure RegisterFeature(FeatureClass: TOpenTypeFeatureTableClass);
procedure RegisterFeatures(FeaturesClasses: array of TOpenTypeFeatureTableClass);
function FindFeatureByType(TableType: TTableType): TOpenTypeFeatureTableClass;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;

//------------------------------------------------------------------------------
//
//      Features
//
//------------------------------------------------------------------------------
var
  GFeatureClasses        : array of TOpenTypeFeatureTableClass;

function IsFeatureClassRegistered(FeatureClass: TOpenTypeFeatureTableClass): Boolean;
var
  TableClassIndex: Integer;
begin
  Result := False;
  for TableClassIndex := 0 to High(GFeatureClasses) do
    if GFeatureClasses[TableClassIndex] = FeatureClass then
    begin
      Result := True;
      Exit;
    end;
end;

function CheckFeatureClassesValid: Boolean;
var
  TableClassBaseIndex: Integer;
  TableClassIndex    : Integer;
begin
  Result := True;
  for TableClassBaseIndex := 0 to High(GFeatureClasses) do
    for TableClassIndex := TableClassBaseIndex + 1 to High(GFeatureClasses) do
      if GFeatureClasses[TableClassBaseIndex] = GFeatureClasses[TableClassIndex] then
      begin
        Result := False;
        Exit;
      end;
end;

procedure RegisterFeature(FeatureClass: TOpenTypeFeatureTableClass);
begin
  Assert(IsFeatureClassRegistered(FeatureClass) = False);
  SetLength(GFeatureClasses, Length(GFeatureClasses) + 1);
  GFeatureClasses[High(GFeatureClasses)] := FeatureClass;
end;

procedure RegisterFeatures(FeaturesClasses: array of TOpenTypeFeatureTableClass);
var
  FeaturesIndex: Integer;
begin
  SetLength(GFeatureClasses, Length(GFeatureClasses) + Length(FeaturesClasses));
  for FeaturesIndex := 0 to High(FeaturesClasses) do
    GFeatureClasses[Length(GFeatureClasses) - Length(FeaturesClasses) + FeaturesIndex] := FeaturesClasses[FeaturesIndex];
  Assert(CheckFeatureClassesValid);
end;

function FindFeatureByType(TableType: TTableType): TOpenTypeFeatureTableClass;
var
  FeaturesIndex: Integer;
begin
  Result := nil;
  for FeaturesIndex := 0 to High(GFeatureClasses) do
    if GFeatureClasses[FeaturesIndex].GetTableType = TableType then
    begin
      Result := GFeatureClasses[FeaturesIndex];
      Exit;
    end;
  // raise EPascalTypeError.Create('Unknown Table Class: ' + TableType);
end;



//------------------------------------------------------------------------------
//
//              TCustomOpenTypeFeatureTable
//
//------------------------------------------------------------------------------
constructor TCustomOpenTypeFeatureTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
end;

destructor TCustomOpenTypeFeatureTable.Destroy;
begin
  inherited;
end;

procedure TCustomOpenTypeFeatureTable.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TCustomOpenTypeFeatureTable then
  begin
    FFeatureParams := TCustomOpenTypeFeatureTable(Source).FFeatureParams;
    FLookupListIndex := TCustomOpenTypeFeatureTable(Source).FLookupListIndex;
  end;
end;

function TCustomOpenTypeFeatureTable.GetEnumerator: TEnumerator<Word>;
begin
  Result := TArrayEnumerator<Word>.Create(FLookupListIndex);
end;

function TCustomOpenTypeFeatureTable.GetLookupList(Index: Integer): Word;
begin
  if (Index < 0) or (Index > High(FLookupListIndex)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FLookupListIndex[Index];
end;

function TCustomOpenTypeFeatureTable.GetLookupListCount: Integer;
begin
  Result := Length(FLookupListIndex);
end;

procedure TCustomOpenTypeFeatureTable.LoadFromStream(Stream: TStream);
var
  LookupIndex: integer;
begin
  inherited;

  // check (minimum) table size
  if Stream.Position + 4 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read feature parameter offset
  FFeatureParams := BigEndianValueReader.ReadWord(Stream);

  // read lookup count
  SetLength(FLookupListIndex, BigEndianValueReader.ReadWord(Stream));

  // read lookup list index offsets
  for LookupIndex := 0 to High(FLookupListIndex) do
    FLookupListIndex[LookupIndex] := BigEndianValueReader.ReadWord(Stream);
end;

procedure TCustomOpenTypeFeatureTable.SaveToStream(Stream: TStream);
var
  LookupIndex: Word;
begin
  inherited;

  // read feature parameter offset
  FFeatureParams := BigEndianValueReader.ReadWord(Stream);

  // read lookup count
  SetLength(FLookupListIndex, BigEndianValueReader.ReadWord(Stream));

  // read lookup list index offsets
  for LookupIndex := 0 to High(FLookupListIndex) do
    FLookupListIndex[LookupIndex] := BigEndianValueReader.ReadWord(Stream);
end;

procedure TCustomOpenTypeFeatureTable.SetFeatureParams(const Value: Word);
begin
  if FFeatureParams <> Value then
  begin
    FFeatureParams := Value;
    FeatureParamsChanged;
  end;
end;

procedure TCustomOpenTypeFeatureTable.FeatureParamsChanged;
begin
  Changed;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeFeatureListTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeFeatureListTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FFeatureList := TPascalTypeTableInterfaceList<TCustomOpenTypeFeatureTable>.Create(Self);
end;

destructor TOpenTypeFeatureListTable.Destroy;
begin
  FreeAndNil(FFeatureList);
  inherited;
end;

function TOpenTypeFeatureListTable.FindFeature(const ATableType: TTableType): TCustomOpenTypeFeatureTable;
begin
  for Result in FFeatureList do
    if (Result.TableType = ATableType) then
      exit;
  Result := nil;
end;

procedure TOpenTypeFeatureListTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeFeatureListTable then
    FFeatureList.Assign(TOpenTypeFeatureListTable(Source).FFeatureList);
end;

function TOpenTypeFeatureListTable.GetFeature(Index: Integer): TCustomOpenTypeFeatureTable;
begin
  if (Index < 0) or (Index >= FFeatureList.Count) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FFeatureList[Index];
end;

function TOpenTypeFeatureListTable.GetFeatureCount: Integer;
begin
  Result := FFeatureList.Count;
end;

procedure TOpenTypeFeatureListTable.LoadFromStream(Stream: TStream);
var
  StartPos    : Int64;
  FeatureIndex: Integer;
  FeatureList : array of TTagOffsetRecord;
  FeatureTable: TCustomOpenTypeFeatureTable;
  FeatureClass: TOpenTypeFeatureTableClass;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 2 > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // read feature list count
  SetLength(FeatureList, BigEndianValueReader.ReadWord(Stream));

  for FeatureIndex := 0 to High(FeatureList) do
  begin
    // read table type
    Stream.Read(FeatureList[FeatureIndex].Tag, SizeOf(TTableType));

    // read offset
    FeatureList[FeatureIndex].Offset := BigEndianValueReader.ReadWord(Stream);
  end;

  // clear language system list
  FFeatureList.Clear;

  for FeatureIndex := 0 to High(FeatureList) do
  begin
    // find feature class
    FeatureClass := FindFeatureByType(FeatureList[FeatureIndex].Tag);

    if (FeatureClass = nil) then
      // We *must* load the table even if we have no implementation for it.
      // Otherwise the index numbers in the feature index list (see
      // TCustomOpenTypeLanguageSystemTable) will not match.
      FeatureClass := TOpenTypeFeatureTableGeneric;

    // create language system entry
    // add to language system list
    FeatureTable := FFeatureList.Add(FeatureClass);

    // Set the table type in case we used the generic implementation
    if (FeatureTable is TOpenTypeFeatureTableGeneric) then
      TOpenTypeFeatureTableGeneric(FeatureTable).TableType := FeatureList[FeatureIndex].Tag;

    // set position to actual script list entry
    Stream.Position := StartPos + FeatureList[FeatureIndex].Offset;

    // load from stream
    FeatureTable.LoadFromStream(Stream);
  end;
end;

procedure TOpenTypeFeatureListTable.SaveToStream(Stream: TStream);
var
  StartPos    : Int64;
  IndexPos    : Int64;
  SavePos    : Int64;
  FeatureIndex: Integer;
  FeatureList : array of TTagOffsetRecord;
begin
  StartPos := Stream.Position;

  inherited;

  // write feature list count
  WriteSwappedWord(Stream, FFeatureList.Count);

  // leave space for feature directory
  IndexPos := Stream.Position;
  Stream.Seek(FFeatureList.Count * SizeOf(TTagOffsetRecord), soCurrent);

  // build directory (to be written later) and write data
  SetLength(FeatureList, FFeatureList.Count);
  for FeatureIndex := 0 to FFeatureList.Count - 1 do
  begin
    // get table type
    FeatureList[FeatureIndex].Tag := FFeatureList[FeatureIndex].TableType;
    FeatureList[FeatureIndex].Offset := Stream.Position - StartPos;

    // write feature to stream
    FFeatureList[FeatureIndex].SaveToStream(Stream);
  end;

  // write directory
  SavePos := Stream.Position;
  Stream.Position := IndexPos;

  for FeatureIndex := 0 to High(FeatureList) do
  begin
    // write tag
    Stream.Write(FeatureList[FeatureIndex].Tag, SizeOf(TTableType));

    // write offset
    WriteSwappedWord(Stream, FeatureList[FeatureIndex].Offset);
  end;

  Stream.Position := SavePos;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeFeatureTableGeneric
//
//------------------------------------------------------------------------------
class function TOpenTypeFeatureTableGeneric.GetDisplayName: string;
begin
  Result := '(unknown)';
end;

function TOpenTypeFeatureTableGeneric.GetInternalTableType: TTableType;
begin
  Result := FTableType;
end;

class function TOpenTypeFeatureTableGeneric.GetTableType: TTableType;
begin
  Result := 0;
end;

//------------------------------------------------------------------------------

end.
