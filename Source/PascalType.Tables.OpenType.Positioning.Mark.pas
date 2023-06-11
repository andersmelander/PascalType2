unit PascalType.Tables.OpenType.Positioning.Mark;

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
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Lookup,
  PascalType.Tables.OpenType.Positioning,
  PascalType.Tables.OpenType.Coverage,
  PascalType.Tables.OpenType.Common.Mark,
  PascalType.Tables.OpenType.Common.Anchor;


//------------------------------------------------------------------------------
//
//              TCustomOpenTypePositioningSubTableMarkAttachment
//
//------------------------------------------------------------------------------
// Base class for mark attachment formats
//------------------------------------------------------------------------------
type
  TCustomOpenTypePositioningSubTableMarkAttachment = class abstract(TCustomOpenTypePositioningSubTable)
  private
    FBaseCoverage: TCustomOpenTypeCoverageTable;
    FMarks: TOpenTypeMarkList;
    FMarkClassCount: Word;
  protected
    procedure ClearBaseRecords; virtual; abstract;
    procedure LoadBaseArrayFromStream(Stream: TStream); virtual; abstract;
    procedure SaveBaseArrayToStream(Stream: TStream); virtual; abstract;
    function GetMarkCoverage: TCustomOpenTypeCoverageTable;
    property Marks: TOpenTypeMarkList read FMarks;
    property MarkClassCount: Word read FMarkClassCount;
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;

    property MarkCoverage: TCustomOpenTypeCoverageTable read GetMarkCoverage; // Alias for CoverageTable property
    property BaseCoverage: TCustomOpenTypeCoverageTable read FBaseCoverage;
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
//              TCustomOpenTypePositioningSubTableMarkAttachment
//
//------------------------------------------------------------------------------
procedure TCustomOpenTypePositioningSubTableMarkAttachment.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TCustomOpenTypePositioningSubTableMarkAttachment then
  begin
    ClearBaseRecords;
    FreeAndNil(FBaseCoverage);
    FBaseCoverage := TCustomOpenTypePositioningSubTableMarkAttachment(Source).FBaseCoverage.Clone(Self);

    FMarks.Assign(TCustomOpenTypePositioningSubTableMarkAttachment(Source).FMarks);
  end;
end;

constructor TCustomOpenTypePositioningSubTableMarkAttachment.Create(AParent: TCustomPascalTypeTable);
begin
  inherited;
  FMarks := TOpenTypeMarkList.Create;
end;

destructor TCustomOpenTypePositioningSubTableMarkAttachment.Destroy;
begin
  FBaseCoverage.Free;
  FMarks.Free;
  ClearBaseRecords;
  inherited;
end;

function TCustomOpenTypePositioningSubTableMarkAttachment.GetMarkCoverage: TCustomOpenTypeCoverageTable;
begin
  Result := inherited CoverageTable;
end;

procedure TCustomOpenTypePositioningSubTableMarkAttachment.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  CoverageOffset: Word;
  MarkArrayOffset: Word;
  BaseArrayOffset: Word;
begin
  StartPos := Stream.Position;

  inherited;

  // check (minimum) table size
  if Stream.Position + 4 * SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Offsets and count
  CoverageOffset := BigEndianValueReader.ReadWord(Stream);
  FMarkClassCount := BigEndianValueReader.ReadWord(Stream);
  MarkArrayOffset := BigEndianValueReader.ReadWord(Stream);
  BaseArrayOffset := BigEndianValueReader.ReadWord(Stream);

  // Coverage table
  Stream.Position := StartPos + CoverageOffset;
  FBaseCoverage := TCustomOpenTypeCoverageTable.CreateFromStream(Stream, Self);

  // Mark array
  Stream.Position := StartPos + MarkArrayOffset;
  FMarks.LoadFromStream(Stream);

  // Delegate load of base array (or whatever) to derived class
  Stream.Position := StartPos + BaseArrayOffset;
  LoadBaseArrayFromStream(Stream);
end;

procedure TCustomOpenTypePositioningSubTableMarkAttachment.SaveToStream(Stream: TStream);
var
  StartPos, SavePos: Int64;
  CoverageOffsetOffset: Int64;
  MarkArrayOffsetOffset: Int64;
  BaseArrayOffsetOffset: Int64;
  CoverageOffset: Word;
  MarkArrayOffset: Word;
  BaseArrayOffset: Word;
begin
  StartPos := Stream.Position;

  inherited;

  CoverageOffsetOffset := Stream.Position;
  Stream.Position := Stream.Position + SizeOf(Word);

  WriteSwappedWord(Stream, MarkClassCount);

  MarkArrayOffsetOffset := Stream.Position;
  Stream.Position := Stream.Position + SizeOf(Word);

  BaseArrayOffsetOffset := Stream.Position;
  Stream.Position := Stream.Position + SizeOf(Word);

  CoverageOffset := Stream.Position - StartPos;
  FBaseCoverage.SaveToStream(Stream);

  MarkArrayOffset := Stream.Position - StartPos;
  FMarks.SaveToStream(Stream);

  BaseArrayOffset := Stream.Position - StartPos;

  // Delegate save of base array (or whatever) to derived class
  SaveBaseArrayToStream(Stream);

  SavePos := Stream.Position;

  Stream.Position := CoverageOffsetOffset;
  WriteSwappedWord(Stream, CoverageOffset);

  Stream.Position := MarkArrayOffsetOffset;
  WriteSwappedWord(Stream, MarkArrayOffset);

  Stream.Position := BaseArrayOffsetOffset;
  WriteSwappedWord(Stream, BaseArrayOffset);

  Stream.Position := SavePos;
end;


//------------------------------------------------------------------------------

end.

