unit PascalType.GlyphString;

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
  PT_Classes,
  PT_Types,
  PascalType.Unicode,
  PascalType.Tables.OpenType.Common.ValueRecord;

//------------------------------------------------------------------------------
//
//              TPascalTypeGlyph
//
//------------------------------------------------------------------------------
type
  TPascalTypeGlyphString = class;

  TPascalTypeGlyph = class
  private
    FOwner: TPascalTypeGlyphString;
    FCodePoints: TPascalTypeCodePoints;
    FGlyphID: TGlyphID;
    FCluster: integer;
    FXAdvance: integer;
    FYAdvance: integer;
    FXOffset: integer;
    FYOffset: integer;
    FMarkAttachment: integer;
    FLigatureComponent: integer;
    function GetIsLigature: boolean;
    function GetIsMark: boolean;
  protected
    procedure SetOwner(AOwner: TPascalTypeGlyphString);
  public
    constructor Create(AOwner: TPascalTypeGlyphString = nil); virtual;

    procedure Assign(Source: TPascalTypeGlyph); virtual;

    procedure ApplyPositioning(const AValueRecord: TOpenTypeValueRecord);

    property Owner: TPascalTypeGlyphString read FOwner;
    property CodePoints: TPascalTypeCodePoints read FCodePoints write FCodePoints;
    property GlyphID: TGlyphID read FGlyphID write FGlyphID;
    property Cluster: integer read FCluster write FCluster;
    property XAdvance: integer read FXAdvance write FXAdvance;
    property YAdvance: integer read FYAdvance write FYAdvance;
    property XOffset: integer read FXOffset write FXOffset;
    property YOffset: integer read FYOffset write FYOffset;

    // Shaper state
    property LigatureComponent: integer read FLigatureComponent write FLigatureComponent;
    property MarkAttachment: integer read FMarkAttachment write FMarkAttachment;

    property IsMark: boolean read GetIsMark;
    property IsLigature: boolean read GetIsLigature;
  end;

  TPascalTypeGlyphClass = class of TPascalTypeGlyph;


//------------------------------------------------------------------------------
//
//              TPascalTypeGlyphString
//
//------------------------------------------------------------------------------
  TPascalTypeGlyphString = class
  private type
    TGlyphMapperDelegate = reference to function(GlyphID: TGlyphID): integer;
  private
    FGlyphs: TList<TPascalTypeGlyph>;
    function GetGlyph(Index: integer): TPascalTypeGlyph;
    function GetCount: integer;
  protected
    class function GetGlyphClass: TPascalTypeGlyphClass; virtual;
    function CreateGlyph(AOwner: TPascalTypeGlyphString): TPascalTypeGlyph; overload; virtual;
  public
    constructor Create(const ACodePoints: TPascalTypeCodePoints); virtual;
    destructor Destroy; override;

    function CreateGlyph: TPascalTypeGlyph; overload;

    function Add: TPascalTypeGlyph;
    procedure Delete(Index: integer; Len: integer = 1);
    function Extract(Index: integer): TPascalTypeGlyph; overload;
    function Extract(Glyph: TPascalTypeGlyph): TPascalTypeGlyph; overload;
    procedure Insert(Index: integer; Glyph: TPascalTypeGlyph);

    function AsString: TGlyphString; overload;
    function AsString(Mapper: TGlyphMapperDelegate): TGlyphString; overload;

    function Match(AFromIndex: integer; const ASequence: TGlyphString; SkipFirst: boolean = False): boolean; overload;
    function Match(AFromIndex: integer; const ASequence: TGlyphString; Mapper: TGlyphMapperDelegate; SkipFirst: boolean = False): boolean; overload;
    function MatchBacktrack(AFromIndex: integer; const ASequence: TGlyphString): boolean; overload;
    function MatchBacktrack(AFromIndex: integer; const ASequence: TGlyphString; Mapper: TGlyphMapperDelegate): boolean; overload;

    procedure SetLength(ALen: integer);

    function GetEnumerator: TEnumerator<TPascalTypeGlyph>;

    property Count: integer read GetCount;
    property Glyphs[Index: integer]: TPascalTypeGlyph read GetGlyph; default;
  end;

  TPascalTypeGlyphStringClass = class of TPascalTypeGlyphString;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation


//------------------------------------------------------------------------------
//
//              TPascalTypeGlyph
//
//------------------------------------------------------------------------------
constructor TPascalTypeGlyph.Create(AOwner: TPascalTypeGlyphString);
begin
  inherited Create;
  FOwner := AOwner;
  FLigatureComponent := -1;
  FMarkAttachment := -1;
end;

function TPascalTypeGlyph.GetIsLigature: boolean;
begin
  Result := (Length(FCodePoints) > 1);
end;

function TPascalTypeGlyph.GetIsMark: boolean;
var
  CodePoint: TPascalTypeCodePoint;
begin
  if (Length(FCodePoints) = 0) then
    Exit(False);
  for CodePoint in FCodePoints do
    if (not PascalTypeUnicode.IsMark(CodePoint)) then
      Exit(False);
  Result := True;
end;

procedure TPascalTypeGlyph.SetOwner(AOwner: TPascalTypeGlyphString);
begin
  FOwner := AOwner;
end;

procedure TPascalTypeGlyph.ApplyPositioning(const AValueRecord: TOpenTypeValueRecord);
begin
  Inc(FXOffset, AValueRecord.xPlacement);
  Inc(FYOffset, AValueRecord.yPlacement);
  Inc(FXAdvance, AValueRecord.xAdvance);
  Inc(FYAdvance, AValueRecord.yAdvance);
end;

procedure TPascalTypeGlyph.Assign(Source: TPascalTypeGlyph);
begin
  FCodePoints := Source.FCodePoints;
  FGlyphID := Source.FGlyphID;
  FCluster := Source.Cluster;
end;


//------------------------------------------------------------------------------
//
//              TPascalTypeGlyphString
//
//------------------------------------------------------------------------------
constructor TPascalTypeGlyphString.Create(const ACodePoints: TPascalTypeCodePoints);
var
  CodePoint: TPascalTypeCodePoint;
  Glyph: TPascalTypeGlyph;
  Cluster: integer;
begin
  inherited Create;
  FGlyphs := TObjectList<TPascalTypeGlyph>.Create;

  FGlyphs.Capacity := Length(ACodePoints);

  Cluster := 0;
  for CodePoint in ACodePoints do
  begin
    Glyph := Add;
    Glyph.CodePoints := [CodePoint];
    Glyph.Cluster := Cluster;
    Inc(Cluster);
  end;
end;

destructor TPascalTypeGlyphString.Destroy;
begin
  FGlyphs.Free;
  inherited;
end;

function TPascalTypeGlyphString.CreateGlyph(AOwner: TPascalTypeGlyphString): TPascalTypeGlyph;
begin
  Result := GetGlyphClass.Create(AOwner);
end;

function TPascalTypeGlyphString.CreateGlyph: TPascalTypeGlyph;
begin
  Result := CreateGlyph(nil);
end;

class function TPascalTypeGlyphString.GetGlyphClass: TPascalTypeGlyphClass;
begin
  Result := TPascalTypeGlyph;
end;

function TPascalTypeGlyphString.Add: TPascalTypeGlyph;
begin
  Result := CreateGlyph(Self);
  FGlyphs.Add(Result);
end;

procedure TPascalTypeGlyphString.Delete(Index, Len: integer);
begin
  while (Len > 0) and (Index < FGlyphs.Count) do
  begin
    FGlyphs.Delete(Index);
    Dec(Len);
  end;
end;

procedure TPascalTypeGlyphString.Insert(Index: integer; Glyph: TPascalTypeGlyph);
begin
  if (Glyph.Owner <> Self) and (Glyph.Owner <> nil) then
    Glyph.Owner.Extract(Glyph);

  FGlyphs.Insert(Index, Glyph);

  Glyph.SetOwner(Self);
end;

function TPascalTypeGlyphString.Match(AFromIndex: integer; const ASequence: TGlyphString; SkipFirst: boolean): boolean;
var
  i: integer;
begin
  // If the end of the sequence is past the end of our string then there can be no match
  if (AFromIndex + Length(ASequence) > FGlyphs.Count) then
    Exit(False);

  // Match forward
  for i := 0 to High(ASequence) do
  begin
    if (SkipFirst) then
    begin
      SkipFirst := False;
      continue;
    end;

    if (FGlyphs[AFromIndex + i].GlyphID <> ASequence[i]) then
      Exit(False);
  end;

  Result := True;
end;

function TPascalTypeGlyphString.Match(AFromIndex: integer; const ASequence: TGlyphString; Mapper: TGlyphMapperDelegate; SkipFirst: boolean): boolean;
var
  i: integer;
begin
  // If the end of the sequence is past the end of our string then there can be no match
  if (AFromIndex + Length(ASequence) > FGlyphs.Count) then
    Exit(False);

  // Match forward
  for i := 0 to High(ASequence) do
  begin
    if (SkipFirst) then
    begin
      SkipFirst := False;
      continue;
    end;

    if (Mapper(FGlyphs[AFromIndex + i].GlyphID) <> ASequence[i]) then
      Exit(False);
  end;

  Result := True;
end;

function TPascalTypeGlyphString.MatchBacktrack(AFromIndex: integer; const ASequence: TGlyphString; Mapper: TGlyphMapperDelegate): boolean;
var
  i: integer;
begin
  // If the start of the sequence is past the start of our string then there can be no match
  if (AFromIndex - Length(ASequence) < 0) then
    Exit(False);

  // Match backward
  for i := 0 to High(ASequence) do
    if (Mapper(FGlyphs[AFromIndex - i].GlyphID) <> ASequence[i]) then
      Exit(False);

  Result := True;
end;

function TPascalTypeGlyphString.MatchBacktrack(AFromIndex: integer; const ASequence: TGlyphString): boolean;
var
  i: integer;
begin
  // If the start of the sequence is past the start of our string then there can be no match
  if (AFromIndex - Length(ASequence) < 0) then
    Exit(False);

  // Match backward
  for i := 0 to High(ASequence) do
    if (FGlyphs[AFromIndex - i].GlyphID <> ASequence[i]) then
      Exit(False);

  Result := True;
end;

function TPascalTypeGlyphString.Extract(Glyph: TPascalTypeGlyph): TPascalTypeGlyph;
begin
  Result := FGlyphs.Extract(Glyph);
  if (Result <> nil) then
    Result.SetOwner(nil);
end;

function TPascalTypeGlyphString.Extract(Index: integer): TPascalTypeGlyph;
begin
  Result := FGlyphs[Index];
  Extract(Result);
end;

function TPascalTypeGlyphString.GetEnumerator: TEnumerator<TPascalTypeGlyph>;
begin
  Result := FGlyphs.GetEnumerator;
end;

function TPascalTypeGlyphString.GetGlyph(Index: integer): TPascalTypeGlyph;
begin
  Result := FGlyphs[Index];
end;

function TPascalTypeGlyphString.GetCount: integer;
begin
  Result := FGlyphs.Count;
end;

procedure TPascalTypeGlyphString.SetLength(ALen: integer);
begin
  while (FGlyphs.Count > ALen) do
    FGlyphs.Delete(FGlyphs.Count-1);

  while (FGlyphs.Count < ALen) do
    Add;
end;

function TPascalTypeGlyphString.AsString: TGlyphString;
var
  i: integer;
begin
  System.SetLength(Result, FGlyphs.Count);
  for i := 0 to FGlyphs.Count-1 do
    Result[i] := FGlyphs[i].GlyphID;
end;

function TPascalTypeGlyphString.AsString(Mapper: TGlyphMapperDelegate): TGlyphString;
var
  i: integer;
begin
  System.SetLength(Result, FGlyphs.Count);
  for i := 0 to FGlyphs.Count-1 do
    Result[i] := Mapper(FGlyphs[i].GlyphID);
end;

end.
