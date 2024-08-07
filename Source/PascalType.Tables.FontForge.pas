unit PascalType.Tables.FontForge;

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
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables,
  PascalType.Tables.Shared;

type
  // 'BDF '

  // see http://fontforge.sourceforge.net/non-standard.html for more information
  TPascalTypeFontForgeX11BDFTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: Word;
    procedure SetVersion(const Value: Word); // currently 0x0001
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Word read FVersion write SetVersion;
  end;


  // 'FFTM'

  // see http://fontforge.sourceforge.net/non-standard.html for more information
  TPascalTypeFontForgeTimeStampTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion   : Cardinal; // currently 0x00000001
    FTimeStamp : Int64; // the date of the sources for fontforge
    FCreation  : Int64; // Not the creation date of the tt/ot file, but the date the sfd file was created. (not always accurate).
    FLastMod   : Int64; // Not the modification date of the file, but the time a glyph, etc. was last changed in the font database. (not always accurate)
    procedure SetCreation(const Value: Int64);
    procedure SetLast(const Value: Int64);
    procedure SetTimeStamp(const Value: Int64);
    procedure SetVersion(const Value: Cardinal);
  protected
    procedure CreationChanged; virtual;
    procedure LastChanged; virtual;
    procedure TimeStampChanged; virtual;
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: Cardinal read FVersion write SetVersion;
    property TimeStamp: Int64 read FTimeStamp write SetTimeStamp;
    property CreationDate: Int64 read FCreation write SetCreation;
    property ModifiedDate: Int64 read FLastMod write SetLast;
  end;


  // 'PfEd'

  // see http://fontforge.sourceforge.net/non-standard.html for more information
  TPascalTypeFontForgeExtensionTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: TFixedPoint; // currently 0x00010000
    procedure SetVersion(const Value: TFixedPoint);
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
  end;


  // 'TEX '

  // see http://fontforge.sourceforge.net/non-standard.html for more information
  TPascalTypeFontForgeTexTable = class(TCustomPascalTypeNamedTable)
  private
    FVersion: TFixedPoint; // currently 0x00010000
    procedure SetVersion(const Value: TFixedPoint);
  protected
    procedure VersionChanged; virtual;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property Version: TFixedPoint read FVersion write SetVersion;
  end;

implementation

uses
  PascalType.ResourceStrings;

{ TPascalTypeFontForgeX11BDFTable }

constructor TPascalTypeFontForgeX11BDFTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion := 1;
end;

procedure TPascalTypeFontForgeX11BDFTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFontForgeX11BDFTable then
    FVersion := TPascalTypeFontForgeTimeStampTable(Source).FVersion;
end;

class function TPascalTypeFontForgeX11BDFTable.GetTableType: TTableType;
begin
  Result := 'BDF ';
end;

procedure TPascalTypeFontForgeX11BDFTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion := BigEndianValue.ReadWord(Stream);
  end;
end;

procedure TPascalTypeFontForgeX11BDFTable.SaveToStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // write version
    BigEndianValue.WriteWord(Stream, FVersion);

    // write strike-count
    BigEndianValue.WriteWord(Stream, 0);

    // write offset
    BigEndianValue.WriteCardinal(Stream, 0);
  end;
end;

procedure TPascalTypeFontForgeX11BDFTable.SetVersion(const Value: Word);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeFontForgeX11BDFTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeFontForgeTimeStampTable }

constructor TPascalTypeFontForgeTimeStampTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion := 1;
end;

procedure TPascalTypeFontForgeTimeStampTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFontForgeTimeStampTable then
  begin
    FVersion := TPascalTypeFontForgeTimeStampTable(Source).FVersion;
    FTimeStamp := TPascalTypeFontForgeTimeStampTable(Source).FTimeStamp;
    FCreation := TPascalTypeFontForgeTimeStampTable(Source).FCreation;
    FLastMod := TPascalTypeFontForgeTimeStampTable(Source).FLastMod;
  end;
end;

class function TPascalTypeFontForgeTimeStampTable.GetTableType: TTableType;
begin
  Result := 'FFTM';
end;

procedure TPascalTypeFontForgeTimeStampTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 28 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion := BigEndianValue.ReadCardinal(Stream);

    // read time stamp
    FTimeStamp := BigEndianValue.ReadInt64(Stream);

    // read creation date
    FCreation := BigEndianValue.ReadInt64(Stream);

    // read last modified date
    FLastMod := BigEndianValue.ReadInt64(Stream);
  end;
end;

procedure TPascalTypeFontForgeTimeStampTable.SaveToStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 28 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // write version
    BigEndianValue.WriteInt64(Stream, FVersion);

    // write time stamp
    BigEndianValue.WriteInt64(Stream, FTimeStamp);

    // write creation date
    BigEndianValue.WriteInt64(Stream, FCreation);

    // write last modified date
    BigEndianValue.WriteInt64(Stream, FLastMod);
  end;
end;

procedure TPascalTypeFontForgeTimeStampTable.SetCreation(const Value: Int64);
begin
  if FCreation <> Value then
  begin
    FCreation := Value;
    CreationChanged;
  end;
end;

procedure TPascalTypeFontForgeTimeStampTable.SetLast(const Value: Int64);
begin
  if FLastMod <> Value then
  begin
    FLastMod := Value;
    LastChanged;
  end;
end;

procedure TPascalTypeFontForgeTimeStampTable.SetTimeStamp(const Value: Int64);
begin
  if FTimeStamp <> Value then
  begin
    FTimeStamp := Value;
    TimeStampChanged;
  end;
end;

procedure TPascalTypeFontForgeTimeStampTable.SetVersion(const Value: Cardinal);
begin
  if FVersion <> Value then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeFontForgeTimeStampTable.CreationChanged;
begin
  Changed;
end;

procedure TPascalTypeFontForgeTimeStampTable.LastChanged;
begin
  Changed;
end;

procedure TPascalTypeFontForgeTimeStampTable.TimeStampChanged;
begin
  Changed;
end;

procedure TPascalTypeFontForgeTimeStampTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeFontForgeExtensionTable }

constructor TPascalTypeFontForgeExtensionTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 1;
end;

procedure TPascalTypeFontForgeExtensionTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFontForgeTexTable then
    FVersion := TPascalTypeFontForgeTexTable(Source).FVersion;
end;

class function TPascalTypeFontForgeExtensionTable.GetTableType: TTableType;
begin
  Result := 'PfEd';
end;

procedure TPascalTypeFontForgeExtensionTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion.Fixed := BigEndianValue.ReadInteger(Stream);
  end;
end;

procedure TPascalTypeFontForgeExtensionTable.SaveToStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // write version
    BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));

    // write count
    BigEndianValue.WriteCardinal(Stream, 0);
  end;
end;

procedure TPascalTypeFontForgeExtensionTable.SetVersion
  (const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeFontForgeExtensionTable.VersionChanged;
begin
  Changed;
end;


{ TPascalTypeFontForgeTexTable }

constructor TPascalTypeFontForgeTexTable.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FVersion.Value := 1;
end;

procedure TPascalTypeFontForgeTexTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TPascalTypeFontForgeTexTable then
    FVersion := TPascalTypeFontForgeTexTable(Source).FVersion;
end;

class function TPascalTypeFontForgeTexTable.GetTableType: TTableType;
begin
  Result := 'TEX ';
end;

procedure TPascalTypeFontForgeTexTable.LoadFromStream(Stream: TStream; Size: Cardinal);
begin
  inherited;

  with Stream do
  begin
    // check if table is complete
    if Position + 8 > Size then
      raise EPascalTypeTableIncomplete.Create(RCStrTableIncomplete);

    // read version
    FVersion.Fixed := BigEndianValue.ReadInteger(Stream);
  end;
end;

procedure TPascalTypeFontForgeTexTable.SaveToStream(Stream: TStream);
begin
  inherited;

  with Stream do
  begin
    // write version
    BigEndianValue.WriteCardinal(Stream, Cardinal(FVersion));

    // write count
    BigEndianValue.WriteCardinal(Stream, 0);
  end;
end;

procedure TPascalTypeFontForgeTexTable.SetVersion(const Value: TFixedPoint);
begin
  if (FVersion.Fract <> Value.Fract) or (FVersion.Value <> Value.Value) then
  begin
    FVersion := Value;
    VersionChanged;
  end;
end;

procedure TPascalTypeFontForgeTexTable.VersionChanged;
begin
  Changed;
end;

initialization

PascalTypeTableClasses.RegisterTables([TPascalTypeFontForgeTimeStampTable,
  TPascalTypeFontForgeExtensionTable, TPascalTypeFontForgeTexTable,
  TPascalTypeFontForgeX11BDFTable]);

end.
