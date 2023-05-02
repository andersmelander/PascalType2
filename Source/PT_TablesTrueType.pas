unit PT_TablesTrueType;

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
  Classes, SysUtils,
  PT_Types,
  PT_Classes,
  PT_Tables;

type
  // table 'cvt '

  TTrueTypeFontControlValueTable = class(TCustomPascalTypeNamedTable)
  private
    FControlValues: array of SmallInt;
    function GetControlValue(Index: Integer): SmallInt;
    function GetControlValueCount: Integer;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property ControlValue[Index: Integer]: SmallInt read GetControlValue;
    property ControlValueCount: Integer read GetControlValueCount;
  end;


  // TCustomTrueTypeFontInstructionTable

  TCustomTrueTypeFontInstructionTable = class(TCustomPascalTypeNamedTable)
  private
    FInstructions: array of Byte;
    function GetInstruction(Index: Integer): Byte;
    function GetInstructionCount: Integer;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Instruction[Index: Integer]: Byte read GetInstruction;
    property InstructionCount: Integer read GetInstructionCount;
  end;


  // table 'fpgm'

  TTrueTypeFontFontProgramTable = class(TCustomTrueTypeFontInstructionTable)
  public
    class function GetTableType: TTableType; override;
  end;


  // table 'loca'

  TTrueTypeFontLocationTable = class(TCustomPascalTypeNamedTable)
  private
    FLocations: array of Cardinal;
    function GetLocation(Index: Integer): Cardinal;
    function GetLocationCount: Cardinal;
  public
    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property Location[Index: Integer]: Cardinal read GetLocation; default;
    property LocationCount: Cardinal read GetLocationCount;
  end;


  // table 'prep'

  TTrueTypeFontControlValueProgramTable = class(TCustomTrueTypeFontInstructionTable)
  public
    class function GetTableType: TTableType; override;
  end;

implementation

uses
  PT_Math, PT_ResourceStrings;


{ TTrueTypeFontControlValueTable }

constructor TTrueTypeFontControlValueTable.Create(AParent: TCustomPascalTypeTable);
begin
  // nothing in here yet
  inherited;
end;

destructor TTrueTypeFontControlValueTable.Destroy;
begin
  // nothing in here yet
  inherited;
end;

procedure TTrueTypeFontControlValueTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TTrueTypeFontControlValueTable then
    FControlValues := TTrueTypeFontControlValueTable(Source).FControlValues;
end;

class function TTrueTypeFontControlValueTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'cvt ';
end;

function TTrueTypeFontControlValueTable.GetControlValue(Index: Integer): SmallInt;
begin
  if (Index > High(FControlValues)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := Swap16(FControlValues[Index]);
end;

function TTrueTypeFontControlValueTable.GetControlValueCount: Integer;
begin
  Result := Length(FControlValues);
end;

procedure TTrueTypeFontControlValueTable.LoadFromStream(Stream: TStream);
begin
  with Stream do
  begin
    SetLength(FControlValues, Size div 2);

    // check for minimal table size
    if Position + Length(FControlValues) * SizeOf(Word) > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read control values
    Read(FControlValues[0], Length(FControlValues) * SizeOf(Word));
  end;
end;

procedure TTrueTypeFontControlValueTable.SaveToStream(Stream: TStream);
begin
  // write control values
  Stream.Write(FControlValues[0], Length(FControlValues) * SizeOf(Word));
end;


{ TCustomTrueTypeFontInstructionTable }

constructor TCustomTrueTypeFontInstructionTable.Create(AParent: TCustomPascalTypeTable);
begin
  // nothing in here yet
  inherited;
end;

destructor TCustomTrueTypeFontInstructionTable.Destroy;
begin
  // nothing in here yet
  inherited;
end;

procedure TCustomTrueTypeFontInstructionTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomTrueTypeFontInstructionTable then
    FInstructions := TCustomTrueTypeFontInstructionTable(Source).FInstructions;
end;

function TCustomTrueTypeFontInstructionTable.GetInstruction(Index: Integer): Byte;
begin
  if (Index > High(FInstructions)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FInstructions[Index];
end;

function TCustomTrueTypeFontInstructionTable.GetInstructionCount: Integer;
begin
  Result := Length(FInstructions);
end;

procedure TCustomTrueTypeFontInstructionTable.LoadFromStream(Stream: TStream);
begin
  SetLength(FInstructions, Stream.Size);

  // check for minimal table size
  if Stream.Position + Length(FInstructions) > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read control values
  Stream.Read(FInstructions[0], Length(FInstructions) * SizeOf(Word));
end;

procedure TCustomTrueTypeFontInstructionTable.SaveToStream(Stream: TStream);
begin
  // write instructions
  if (Length(FInstructions) > 0) then
    Stream.Write(FInstructions[0], Length(FInstructions));
end;


{ TTrueTypeFontFontProgramTable }

class function TTrueTypeFontFontProgramTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'fpgm';
end;


{ TTrueTypeFontLocationTable }

procedure TTrueTypeFontLocationTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TTrueTypeFontLocationTable then
    FLocations := TTrueTypeFontLocationTable(Source).FLocations;
end;

function TTrueTypeFontLocationTable.GetLocation(Index: Integer): Cardinal;
begin
  if (Index < 0) or (Index > High(FLocations)) then
    raise EPascalTypeError.CreateFmt(RCStrIndexOutOfBounds, [Index]);
  Result := FLocations[Index];
end;

function TTrueTypeFontLocationTable.GetLocationCount: Cardinal;
begin
  Result := Length(FLocations);
end;

class function TTrueTypeFontLocationTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'loca';
end;

procedure TTrueTypeFontLocationTable.LoadFromStream(Stream: TStream);
var
  LocationIndex: Integer;
  HeaderTable  : TPascalTypeHeaderTable;
  MaxProfTable : TPascalTypeMaximumProfileTable;
begin
  // get header table
  HeaderTable := TPascalTypeHeaderTable(Storage.GetTableByTableName('head'));
  Assert(HeaderTable <> nil);

  // get maximum profile table
  MaxProfTable := TPascalTypeMaximumProfileTable(Storage.GetTableByTableName('maxp'));
  Assert(MaxProfTable <> nil);

  case HeaderTable.IndexToLocationFormat of
    ilShort:
      begin
        // check (minimum) table size
        if (MaxProfTable.NumGlyphs + 1) * SizeOf(Word) > Stream.Size then
          raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

        // set location array length
        SetLength(FLocations, MaxProfTable.NumGlyphs + 1);

        // read location array data
        for LocationIndex := 0 to High(FLocations) do
          FLocations[LocationIndex] := 2 * ReadSwappedWord(Stream);
      end;

    ilLong:
      begin
        // check (minimum) table size
        if (MaxProfTable.NumGlyphs + 1) * SizeOf(Cardinal) > Stream.Size then
          raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

        // set location array length
        SetLength(FLocations, MaxProfTable.NumGlyphs + 1);

        // read location array data
        for LocationIndex := 0 to High(FLocations) do
          FLocations[LocationIndex] := ReadSwappedCardinal(Stream);
      end;
  end;

{$IFDEF AmbigiousExceptions}
  // verify that the locations are stored in ascending order
  for LocationIndex := 1 to High(FLocations) do
    if FLocations[LocationIndex - 1] > FLocations[LocationIndex] then
      raise EPascalTypeError.Create(RCStrLocationOffsetError);
{$ENDIF}
end;

procedure TTrueTypeFontLocationTable.SaveToStream(Stream: TStream);
var
  LocationIndex: Integer;
  HeaderTable  : TPascalTypeHeaderTable;
  MaxProfTable : TPascalTypeMaximumProfileTable;
begin
  // get header table
  HeaderTable := TPascalTypeHeaderTable(Storage.GetTableByTableName('head'));
  Assert(HeaderTable <> nil);

  // get maximum profile table
  MaxProfTable := TPascalTypeMaximumProfileTable(Storage.GetTableByTableName('maxp'));
  Assert(MaxProfTable <> nil);

  // check whether the number of glyps matches the location array length
  if (MaxProfTable.NumGlyphs + 1) <> Length(FLocations) then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  case HeaderTable.IndexToLocationFormat of
    ilShort:
      begin
        // write location array data
        for LocationIndex := 0 to High(FLocations) do
          WriteSwappedWord(Stream, FLocations[LocationIndex] div 2);
      end;

    ilLong:
      begin
        // write location array data
        for LocationIndex := 0 to High(FLocations) do
          WriteSwappedCardinal(Stream, FLocations[LocationIndex]);
      end;
  end;
end;


{ TTrueTypeFontControlValueProgramTable }

class function TTrueTypeFontControlValueProgramTable.GetTableType: TTableType;
begin
  Result.AsAnsiChar := 'prep';
end;

initialization

  RegisterPascalTypeTables([TTrueTypeFontControlValueTable,
    TTrueTypeFontFontProgramTable,
    TTrueTypeFontLocationTable, TTrueTypeFontControlValueProgramTable]);

end.
