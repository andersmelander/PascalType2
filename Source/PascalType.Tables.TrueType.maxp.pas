unit PascalType.Tables.TrueType.maxp;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'maxp' table type                                     //
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
  Classes,
  PT_Types,
  PT_Classes,
  PascalType.Tables;

//------------------------------------------------------------------------------
//
//              TPascalTypeMaximumProfileTable
//
//------------------------------------------------------------------------------
// maxp — Maximum Profile
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/maxp
// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6maxp.html
//------------------------------------------------------------------------------
type
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


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_ResourceStrings;


//------------------------------------------------------------------------------
//
//              TPascalTypeMaximumProfileTable
//
//------------------------------------------------------------------------------
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
  inherited;

  if Stream.Position + $6 > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  // read version
  FVersion.Fixed := BigEndianValueReader.ReadCardinal(Stream);

  if (Version.Fixed <> $00010000) and (Version.Fixed <> $00005000) then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  FNumGlyphs := BigEndianValueReader.ReadWord(Stream);

  // Set postscript values to maximum
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

  if Stream.Position + $1A > Stream.Size then
    raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

  FMaxPoints := BigEndianValueReader.ReadWord(Stream);
  FMaxContours := BigEndianValueReader.ReadWord(Stream);
  FMaxCompositePoints := BigEndianValueReader.ReadWord(Stream);
  FMaxCompositeContours := BigEndianValueReader.ReadWord(Stream);
  FMaxZones := BigEndianValueReader.ReadWord(Stream);
  FMaxTwilightPoints := BigEndianValueReader.ReadWord(Stream);
  FMaxStorage := BigEndianValueReader.ReadWord(Stream);
  FMaxFunctionDefs := BigEndianValueReader.ReadWord(Stream);
  FMaxInstructionDefs := BigEndianValueReader.ReadWord(Stream);
  FMaxStackElements := BigEndianValueReader.ReadWord(Stream);
  FMaxSizeOfInstructions := BigEndianValueReader.ReadWord(Stream);
  FMaxComponentElements := BigEndianValueReader.ReadWord(Stream);
  FMaxComponentDepth := BigEndianValueReader.ReadWord(Stream);
end;

procedure TPascalTypeMaximumProfileTable.SaveToStream(Stream: TStream);
begin
  inherited;
  WriteSwappedCardinal(Stream, Cardinal(FVersion));
  WriteSwappedWord(Stream, FNumGlyphs);
  WriteSwappedWord(Stream, FMaxPoints);
  WriteSwappedWord(Stream, FMaxContours);
  WriteSwappedWord(Stream, FMaxCompositePoints);
  WriteSwappedWord(Stream, FMaxCompositeContours);
  WriteSwappedWord(Stream, FMaxZones);
  WriteSwappedWord(Stream, FMaxTwilightPoints);
  WriteSwappedWord(Stream, FMaxStorage);
  WriteSwappedWord(Stream, FMaxFunctionDefs);
  WriteSwappedWord(Stream, FMaxInstructionDefs);
  WriteSwappedWord(Stream, FMaxStackElements);
  WriteSwappedWord(Stream, FMaxSizeOfInstructions);
  WriteSwappedWord(Stream, FMaxComponentElements);
  WriteSwappedWord(Stream, FMaxComponentDepth);
end;

procedure TPascalTypeMaximumProfileTable.SetMaxComponentDepth(const Value: Word);
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


initialization

  PascalTypeTableClasses.RegisterTable(TPascalTypeMaximumProfileTable);

end.

