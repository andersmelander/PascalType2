unit PascalType.Tables.OpenType.Common.Mark;

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
  System.Classes,
  Generics.Collections,
  PascalType.Tables.OpenType.Common.Anchor;

//------------------------------------------------------------------------------
//
//              TOpenTypeMark
//
//------------------------------------------------------------------------------
// Shared Tables: Mark Array Table
//------------------------------------------------------------------------------
// https://learn.microsoft.com/en-us/typography/opentype/spec/gpos#mark-array-table
//------------------------------------------------------------------------------
(*
  The MarkArray table defines the class and the anchor point for a mark glyph.
  Three GPOS subtable types — MarkToBase attachment, MarkToLigature attachment,
  and MarkToMark attachment — use the MarkArray table to specify data for
  attaching marks.

  The MarkArray table contains a count of the number of MarkRecords (markCount)
  and an array of those records (markRecords). Each mark record defines the
  class of the mark and an offset to the Anchor table that contains data for the
  mark.

  A class value can be zero (0), but the MarkRecord must explicitly assign that
  class value. (This differs from the Class Definition table, in which all
  glyphs not assigned class values automatically belong to Class 0.) The GPOS
  subtables that refer to MarkArray tables use the class assignments for
  indexing zero-based arrays that contain data for each mark class.
*)
type
  TOpenTypeMark = class
  private
    FMarkClass: Word;
    FAnchor: TOpenTypeAnchor;
  public
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream; StartPos: Int64);

    procedure Assign(Source: TOpenTypeMark);
    function Clone: TOpenTypeMark;

    property MarkClass: Word read FMarkClass write FMarkClass;
    property Anchor: TOpenTypeAnchor read FAnchor;
  end;


//------------------------------------------------------------------------------
//
//              TOpenTypeMarkList
//
//------------------------------------------------------------------------------
type
  TOpenTypeMarkList = class
  private
    FMarks: TObjectList<TOpenTypeMark>;
    function GetCount: integer;
    function GetMark(Index: integer): TOpenTypeMark;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    procedure Assign(Source: TOpenTypeMarkList);

    property Count: integer read GetCount;
    property Marks[Index: integer]: TOpenTypeMark read GetMark; default;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PT_Classes;

//------------------------------------------------------------------------------
//
//              TOpenTypeMark
//
//------------------------------------------------------------------------------
procedure TOpenTypeMark.Assign(Source: TOpenTypeMark);
begin
  FMarkClass := Source.MarkClass;
  FreeAndNil(FAnchor);
  FAnchor := Source.Anchor.Clone;
end;

function TOpenTypeMark.Clone: TOpenTypeMark;
begin
  Result := TOpenTypeMark.Create;
  try

    Result.Assign(Self);

  except
    Result.Free;
    raise;
  end;
end;

destructor TOpenTypeMark.Destroy;
begin
  FAnchor.Free;
  inherited;
end;

procedure TOpenTypeMark.LoadFromStream(Stream: TStream; StartPos: Int64);
var
  SavePos: Int64;
  AnchorOffset: Word;
begin
  FMarkClass := BigEndianValueReader.ReadWord(Stream);
  AnchorOffset := BigEndianValueReader.ReadWord(Stream);

  SavePos := Stream.Position;

  Stream.Position := StartPos + AnchorOffset;
  FAnchor := TOpenTypeAnchor.CreateFromStream(Stream);

  Stream.Position := SavePos;
end;


//------------------------------------------------------------------------------
//
//              TOpenTypeMarkList
//
//------------------------------------------------------------------------------
procedure TOpenTypeMarkList.Assign(Source: TOpenTypeMarkList);
var
  Mark: TOpenTypeMark;
  NewMark: TOpenTypeMark;
begin
  FMarks.Clear;
  FMarks.Capacity := Source.Count;
  for Mark in Source.FMarks do
  begin
    NewMark := TOpenTypeMark.Create;
    FMarks.Add(NewMark);
    NewMark.Assign(Mark);
  end;
end;

constructor TOpenTypeMarkList.Create;
begin
  inherited Create;
  FMarks := TObjectList<TOpenTypeMark>.Create;
end;

destructor TOpenTypeMarkList.Destroy;
begin
  FMarks.Free;
  inherited;
end;

function TOpenTypeMarkList.GetCount: integer;
begin
  Result := FMarks.Count;
end;

function TOpenTypeMarkList.GetMark(Index: integer): TOpenTypeMark;
begin
  Result := FMarks[Index];
end;

procedure TOpenTypeMarkList.LoadFromStream(Stream: TStream);
var
  StartPos: Int64;
  MarkCount: Word;
  Mark: TOpenTypeMark;
begin
  FMarks.Clear;

  StartPos := Stream.Position;

  MarkCount := BigEndianValueReader.ReadWord(Stream);

  FMarks.Capacity := MarkCount;
  while (MarkCount > 0) do
  begin
    Mark := TOpenTypeMark.Create;
    FMarks.Add(Mark);
    Mark.LoadFromStream(Stream, StartPos);
    Dec(MarkCount);
  end;
end;

procedure TOpenTypeMarkList.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
  SavePos: Int64;
  ListPos: Int64;
  Mark: TOpenTypeMark;
  AnchorOffsets: array of Word;
  i: integer;
begin
  StartPos := Stream.Position;

  WriteSwappedWord(Stream, FMarks.Count);

  ListPos := Stream.Position;
  for i := 0 to FMarks.Count-1 do
  begin
    WriteSwappedWord(Stream, FMarks[i].MarkClass);
    Stream.Position := Stream.Position + SizeOf(Word);
  end;

  SetLength(AnchorOffsets, FMarks.Count);
  for i := 0 to FMarks.Count-1 do
  begin
    AnchorOffsets[i] := Stream.Position - StartPos;
    FMarks[i].Anchor.SaveToStream(Stream);
  end;

  SavePos := Stream.Position;

  Stream.Position := ListPos;
  for i := 0 to FMarks.Count-1 do
  begin
    Stream.Position := Stream.Position + SizeOf(Word);
    WriteSwappedWord(Stream, AnchorOffsets[i]);
  end;

  Stream.Position := SavePos;
end;

//------------------------------------------------------------------------------

end.

