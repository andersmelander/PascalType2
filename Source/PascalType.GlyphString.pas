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
  PascalType.Classes,
  PascalType.Types,
  PascalType.Unicode,
  PascalType.Tables.OpenType.Common.Anchor,
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
    FGlyphString: TPascalTypeGlyphString;
    FCodePoints: TPascalTypeCodePoints;
    FGlyphID: TGlyphID;
    FAlternateIndex: integer;
    FIsSubstituted: boolean;
    FIsLigated: boolean;
    FIsBase: boolean;
    FIsMark: boolean;
    FIsLigature: boolean;
    FCluster: integer;
    FXAdvance: integer;
    FYAdvance: integer;
    FXOffset: integer;
    FYOffset: integer;
    FMarkAttachment: integer;
    FMarkAttachmentType: integer;
    FLigatureComponent: integer;
    FCursiveAttachment: integer;
    FLigatureID: integer;
    FFeatures: TPascalTypeFeatures;
    FIsMultiplied: boolean;
  protected
    procedure SetOwner(AOwner: TPascalTypeGlyphString);
    procedure SetGlyphID(const Value: TGlyphID);
    function AllIsMark: boolean;
  public
    constructor Create(AGlyphString: TPascalTypeGlyphString = nil); virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPascalTypeGlyph); virtual;

    procedure ApplyPositioning(const AValueRecord: TOpenTypeValueRecord);
    procedure ApplyAnchor(MarkAnchor, BaseAnchor: TOpenTypeAnchor; BaseIndex: integer);

    property GlyphString: TPascalTypeGlyphString read FGlyphString;

    property CodePoints: TPascalTypeCodePoints read FCodePoints write FCodePoints;
    property GlyphID: TGlyphID read FGlyphID write SetGlyphID;
    property Cluster: integer read FCluster write FCluster;
    property XAdvance: integer read FXAdvance write FXAdvance;
    property YAdvance: integer read FYAdvance write FYAdvance;
    property XOffset: integer read FXOffset write FXOffset;
    property YOffset: integer read FYOffset write FYOffset;

    // Features to be applied by the shaper
    property Features: TPascalTypeFeatures read FFeatures write FFeatures;

    property AlternateIndex: integer read FAlternateIndex write FAlternateIndex;

    // Shaper state
    property LigatureID: integer read FLigatureID write FLigatureID;
    property LigatureComponent: integer read FLigatureComponent write FLigatureComponent;
    property MarkAttachment: integer read FMarkAttachment write FMarkAttachment;
    property CursiveAttachment: integer read FCursiveAttachment write FCursiveAttachment;
    property IsLigated: boolean read FIsLigated write FIsLigated;
    property IsSubstituted: boolean read FIsSubstituted write FIsSubstituted;
    property IsMultiplied: boolean read FIsMultiplied write FIsMultiplied;

    property IsBase: boolean read FIsBase;
    property IsMark: boolean read FIsMark;
    property IsLigature: boolean read FIsLigature;
    property MarkAttachmentType: integer read FMarkAttachmentType;
  end;

  TPascalTypeGlyphClass = class of TPascalTypeGlyph;


//------------------------------------------------------------------------------
//
//              TPascalTypeGlyphGlyphIterator
// TODO : Rename GlyphGlyph -> Glyph
//------------------------------------------------------------------------------
// Skipping glyphstring iterator
//------------------------------------------------------------------------------
  TPascalTypeGlyphGlyphIterator = record
  private
    FGlyphString: TPascalTypeGlyphString;
    FIndex: integer;
    FLookupFlags: Word;
    FMarkAttachmentFilter: integer;
    function GetGlyph: TPascalTypeGlyph;
    function GetEOF: boolean;
    function ShouldIgnore(AGlyph: TPascalTypeGlyph): boolean;
    procedure SetIndex(const Value: integer);
  public
    constructor Create(const AGlyphString: TPascalTypeGlyphString; ALookupFlags: Word = 0; AMarkAttachmentFilter: integer = -1);

    function Clone: TPascalTypeGlyphGlyphIterator;

    procedure Reset(ALookupFlags: Word = 0; AMarkAttachmentFilter: integer = -1);

    // Move forward. Skip glyphs that should be ignored. Return new index.
    function Next(AIncrement: integer = 1): integer;
    // Move Backward. Skip glyphs that should be ignored. Return new index.
    function Previous(AIncrement: integer = -1): integer;

    // Move forward/backward. Do not skip. Return new index.
    function Step(AIncrement: integer = 1): integer;

    // Simulate moving forward/backward. Skip glyphs that should be ignored. Return new index.
    function Peek(AIncrement: integer = 1): integer;
    function PeekGlyph(AIncrement: integer = 1): TPascalTypeGlyph;

    function GetEnumerator: TEnumerator<integer>;

    property Index: integer read FIndex write SetIndex;
    property EOF: boolean read GetEOF;
    // Current glyph. nil if there is no current.
    property Glyph: TPascalTypeGlyph read GetGlyph;

    property GlyphString: TPascalTypeGlyphString read FGlyphString;
    property LookupFlags: Word read FLookupFlags write FLookupFlags;
    property MarkAttachmentFilter: integer read FMarkAttachmentFilter;
  end;

//------------------------------------------------------------------------------
//
//              TPascalTypeGlyphString
//
//------------------------------------------------------------------------------
  TPascalTypeGlyphString = class
  private type
    TGlyphMapperDelegate = reference to function(GlyphID: TGlyphID): integer;
  private
    FLigatureID: integer;
  private
    FGlyphs: TList<TPascalTypeGlyph>;
    FLanguage: TTableType;
    FDirection: TPascalTypeDirection;
    FScript: TTableType;
    FAlternateIndex: integer;
    FFeatures: TPascalTypeFeatures;
    function GetGlyph(Index: integer): TPascalTypeGlyph;
    function GetCount: integer;
    function GetDirection: TPascalTypeDirection;
    function GetFeatures: PPascalTypeFeatures;
  protected
    function GetGlyphClassID(AGlyph: TPascalTypeGlyph): integer; virtual;
    function GetMarkAttachmentType(AGlyph: TPascalTypeGlyph): integer; virtual;
  protected
    class function GetGlyphClass: TPascalTypeGlyphClass; virtual;
    function CreateGlyph(AOwner: TPascalTypeGlyphString): TPascalTypeGlyph; overload; virtual;
  public
    constructor Create(const ACodePoints: TPascalTypeCodePoints);
    destructor Destroy; override;

    function CreateGlyph: TPascalTypeGlyph; overload;

    function Add: TPascalTypeGlyph;
    procedure Delete(Index: integer; Len: integer = 1);
    function Extract(Index: integer): TPascalTypeGlyph; overload;
    function Extract(Glyph: TPascalTypeGlyph): TPascalTypeGlyph; overload;
    procedure Insert(Index: integer; Glyph: TPascalTypeGlyph);
    procedure Move(OldIndex, NewIndex: integer);
    procedure Reverse;

    function AsString: TGlyphString; overload;
    function AsString(Mapper: TGlyphMapperDelegate): TGlyphString; overload;

    function Match(var AIterator: TPascalTypeGlyphGlyphIterator; AOffset: integer; const ASequence: TGlyphString; SkipFirst: boolean = False; MoveOnMatch: boolean = False): boolean; overload;
    function Match(var AIterator: TPascalTypeGlyphGlyphIterator; AOffset: integer; const ASequence: TGlyphString; Mapper: TGlyphMapperDelegate; SkipFirst: boolean = False; MoveOnMatch: boolean = False): boolean; overload;
    function Match(AFromIndex: integer; const ASequence: TGlyphString; SkipFirst: boolean = False): boolean; overload; deprecated;
    function Match(AFromIndex: integer; const ASequence: TGlyphString; Mapper: TGlyphMapperDelegate; SkipFirst: boolean = False): boolean; overload; deprecated;
    function MatchBacktrack(AFromIndex: integer; const ASequence: TGlyphString): boolean; overload; deprecated;
    function MatchBacktrack(AFromIndex: integer; const ASequence: TGlyphString; Mapper: TGlyphMapperDelegate): boolean; overload; deprecated;

    procedure ApplyAnchor(MarkAnchor, BaseAnchor: TOpenTypeAnchor; MarkIndex, BaseIndex: integer);

    procedure SetLength(ALen: integer);

    function GetNextLigatureID: integer;

    procedure HideDefaultIgnorables; virtual;

    function GetEnumerator: TEnumerator<TPascalTypeGlyph>;
    function CreateIterator(ALookupFlags: Word = 0; AMarkAttachmentFilter: integer = -1): TPascalTypeGlyphGlyphIterator; virtual;

    property Count: integer read GetCount;
    property Glyphs[Index: integer]: TPascalTypeGlyph read GetGlyph; default;

    // Context
    property Script: TTableType read FScript write FScript;
    property Language: TTableType read FLanguage write FLanguage;
    property Direction: TPascalTypeDirection read GetDirection write FDirection;
    property AlternateIndex: integer read FAlternateIndex write FAlternateIndex;

    // Features enabled for the string during shaping. Only used during shaping.
    // Note that the property is a pointer. This is so we can access the feature list by reference instead of by value.
    property Features: PPascalTypeFeatures read GetFeatures;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  System.Math,
  PascalType.Tables.OpenType.Lookup;

//------------------------------------------------------------------------------
//
//              TPascalTypeGlyph
//
//------------------------------------------------------------------------------
constructor TPascalTypeGlyph.Create(AGlyphString: TPascalTypeGlyphString);
begin
  inherited Create;
  FGlyphString := AGlyphString;
  FLigatureID := -1;
  FLigatureComponent := -1;
  FMarkAttachment := -1;
  FCursiveAttachment := -1;
  FAlternateIndex := -1;
end;

destructor TPascalTypeGlyph.Destroy;
begin
  if (FGlyphString <> nil) then
    FGlyphString.Extract(Self);
  inherited;
end;

procedure TPascalTypeGlyph.SetGlyphID(const Value: TGlyphID);
var
  ClassID: integer;
begin
  if (GlyphID = Value) then
    exit;

  FGlyphID := Value;
  FIsSubstituted := True;

  ClassID := GlyphString.GetGlyphClassID(Self);

  FIsBase := (ClassID = 1);
  FIsLigature := (ClassID = 2);
  FIsMark := (ClassID = 3);

  FMarkAttachmentType := GlyphString.GetMarkAttachmentType(Self);
end;

procedure TPascalTypeGlyph.SetOwner(AOwner: TPascalTypeGlyphString);
begin
  if (FGlyphString = AOwner) then
    exit;
  if (FGlyphString <> nil) then
    FGlyphString.Extract(Self);
  FGlyphString := AOwner;
end;

function TPascalTypeGlyph.AllIsMark: boolean;
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

procedure TPascalTypeGlyph.ApplyAnchor(MarkAnchor, BaseAnchor: TOpenTypeAnchor; BaseIndex: integer);
var
  MarkPos, BasePos: TAnchorPoint;
begin
  MarkPos := MarkAnchor.Position;
  BasePos := BaseAnchor.Position;

  XOffset := BasePos.X - MarkPos.X;
  YOffset := BasePos.Y - MarkPos.Y;

  MarkAttachment := BaseIndex;
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

  FAlternateIndex := -1;
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
  Result := CreateGlyph(Self);
end;

function TPascalTypeGlyphString.CreateIterator(ALookupFlags: Word;
  AMarkAttachmentFilter: integer): TPascalTypeGlyphGlyphIterator;
begin
  Result := TPascalTypeGlyphGlyphIterator.Create(Self, ALookupFlags, AMarkAttachmentFilter);
end;

class function TPascalTypeGlyphString.GetGlyphClass: TPascalTypeGlyphClass;
begin
  Result := TPascalTypeGlyph;
end;

function TPascalTypeGlyphString.GetGlyphClassID(AGlyph: TPascalTypeGlyph): integer;
begin
  if (AGlyph.AllIsMark) then
    Result := 3 // Mark
  else
  if (Length(AGlyph.CodePoints) > 1) then
    Result := 2 // Ligature
  else
    Result := 1; // Base
end;

function TPascalTypeGlyphString.GetMarkAttachmentType(AGlyph: TPascalTypeGlyph): integer;
begin
  Result := 0;
end;

function TPascalTypeGlyphString.GetNextLigatureID: integer;
begin
  Inc(FLigatureID); // Increment before assign -> First ID is 1
  Result := FLigatureID;
end;

procedure TPascalTypeGlyphString.HideDefaultIgnorables;
begin
  // Overridden in TShaperGlyphString
end;

function TPascalTypeGlyphString.Add: TPascalTypeGlyph;
begin
  Result := CreateGlyph;
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
  if (Glyph.GlyphString <> Self) and (Glyph.GlyphString <> nil) then
    Glyph.GlyphString.Extract(Glyph);

  FGlyphs.Insert(Index, Glyph);

  Glyph.SetOwner(Self);
end;

function TPascalTypeGlyphString.Match(var AIterator: TPascalTypeGlyphGlyphIterator; AOffset: integer; const ASequence: TGlyphString;
  SkipFirst, MoveOnMatch: boolean): boolean;
var
  Iterator: TPascalTypeGlyphGlyphIterator;
  Index: integer;
begin
  if (not AIterator.EOF) and (Length(ASequence) = 0) then
    Exit(True);

  // If the end of the sequence is past the end of our string then there can be no match
  if (AIterator.EOF) or (AIterator.Index + AOffset < 0) or (AIterator.Index + AOffset + Length(ASequence) > FGlyphs.Count) then
    Exit(False);

  Iterator := AIterator.Clone;
  if (AOffset <> 0) then
    Iterator.Next(AOffset);

  for Index := 0 to High(ASequence) do
  begin
    if (SkipFirst) then
    begin
      SkipFirst := False;
      continue;
    end;

    if (Iterator.Glyph = nil) or (Iterator.Glyph.GlyphID <> ASequence[Index]) then
      Exit(False);

    Iterator.Next;
  end;

  if (MoveOnMatch) then
    AIterator.Index := Iterator.Index;

  Result := True;
end;

function TPascalTypeGlyphString.Match(var AIterator: TPascalTypeGlyphGlyphIterator; AOffset: integer; const ASequence: TGlyphString;
  Mapper: TGlyphMapperDelegate; SkipFirst, MoveOnMatch: boolean): boolean;
var
  Iterator: TPascalTypeGlyphGlyphIterator;
  Index: integer;
begin
  if (not AIterator.EOF) and (Length(ASequence) = 0) then
    Exit(True);

  // If the end of the sequence is past the end of our string then there can be no match
  if (AIterator.EOF) or (AIterator.Index + AOffset < 0) or (AIterator.Index + AOffset + Length(ASequence) > FGlyphs.Count) then
    Exit(False);

  Iterator := AIterator.Clone;
  if (AOffset <> 0) then
    Iterator.Next(AOffset);

  for Index := 0 to High(ASequence) do
  begin
    if (SkipFirst) then
    begin
      SkipFirst := False;
      continue;
    end;

    if (Iterator.Glyph = nil) or (Mapper(Iterator.Glyph.GlyphID) <> ASequence[Index]) then
      Exit(False);

    Iterator.Next;
  end;

  if (MoveOnMatch) then
    AIterator.Index := Iterator.Index;

  Result := True;
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

procedure TPascalTypeGlyphString.Move(OldIndex, NewIndex: integer);
begin
  FGlyphs.Move(OldIndex, NewIndex);
end;

procedure TPascalTypeGlyphString.Reverse;
var
  i: integer;
begin
  for i := 0 to FGlyphs.Count div 2 - 1 do
    FGlyphs.Exchange(i, FGlyphs.Count-i-1);
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

function TPascalTypeGlyphString.GetFeatures: PPascalTypeFeatures;
begin
  Result := @FFeatures;
end;

function TPascalTypeGlyphString.GetGlyph(Index: integer): TPascalTypeGlyph;
begin
  if (Index >= 0) then
    Result := FGlyphs[Index]
  else
    // Iterator returns -1 on EOF, so we return nil. That way the caller
    // can either test the iterator index against -1 or test the glyph
    // against nil.
    Result := nil;
end;

function TPascalTypeGlyphString.GetCount: integer;
begin
  Result := FGlyphs.Count;
end;

function TPascalTypeGlyphString.GetDirection: TPascalTypeDirection;
var
  UnicodeScript: TUnicodeScript;
begin
  Result := FDirection;

  if (Result = dirDefault) then
  begin
    UnicodeScript := PascalTypeUnicode.ISO15924ToScript(FScript.AsString);

    if PascalTypeUnicode.IsRightToLeft(UnicodeScript) then
      Result := dirRightToLeft
    else
      Result := dirLeftToRight;
  end;
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

procedure TPascalTypeGlyphString.ApplyAnchor(MarkAnchor, BaseAnchor: TOpenTypeAnchor; MarkIndex, BaseIndex: integer);
begin
  FGlyphs[MarkIndex].ApplyAnchor(MarkAnchor, BaseAnchor, BaseIndex);
end;

function TPascalTypeGlyphString.AsString(Mapper: TGlyphMapperDelegate): TGlyphString;
var
  i: integer;
begin
  System.SetLength(Result, FGlyphs.Count);
  for i := 0 to FGlyphs.Count-1 do
    Result[i] := Mapper(FGlyphs[i].GlyphID);
end;

//------------------------------------------------------------------------------
//
//              TPascalTypeGlyphGlyphIterator
//
//------------------------------------------------------------------------------
constructor TPascalTypeGlyphGlyphIterator.Create(const AGlyphString: TPascalTypeGlyphString; ALookupFlags: Word;
  AMarkAttachmentFilter: integer);
begin
  FGlyphString := AGlyphString;
  FLookupFlags := ALookupFlags;
  FMarkAttachmentFilter := AMarkAttachmentFilter;
end;

function TPascalTypeGlyphGlyphIterator.Clone: TPascalTypeGlyphGlyphIterator;
begin
  Result := TPascalTypeGlyphGlyphIterator.Create(FGlyphString, FLookupFlags, FMarkAttachmentFilter);
  Result.FIndex := FIndex;
end;

function TPascalTypeGlyphGlyphIterator.GetEnumerator: TEnumerator<integer>;
begin
  Result := nil; // TODO
end;

function TPascalTypeGlyphGlyphIterator.GetEOF: boolean;
begin
  Result := (FIndex = -1);
end;

function TPascalTypeGlyphGlyphIterator.GetGlyph: TPascalTypeGlyph;
begin
  if (FIndex <> -1) then
    Result := FGlyphString[FIndex]
  else
    Result := nil;
end;

function TPascalTypeGlyphGlyphIterator.Next(AIncrement: integer): integer;
begin
  Result := Peek(AIncrement);
  FIndex := Result;
end;

function TPascalTypeGlyphGlyphIterator.Peek(AIncrement: integer): integer;
var
  Direction: integer;
begin
  Result := FIndex;
  if (AIncrement = 0) then
    Exit;

  if (AIncrement > 0) then
    Direction := 1
  else
    Direction := -1;

  while (AIncrement <> 0) and (Result >= 0) and (Result < FGlyphString.Count) do
  begin
    Inc(Result, Direction);
    while (Result >= 0) and (Result < FGlyphString.Count) and ShouldIgnore(FGlyphString[Result]) do
      Inc(Result, Direction);

    Dec(AIncrement, Direction);
  end;

  if (Result < 0) or (Result >= FGlyphString.Count) then
    Result := -1;
end;

function TPascalTypeGlyphGlyphIterator.PeekGlyph(AIncrement: integer): TPascalTypeGlyph;
var
  Index: integer;
begin
  Index := Peek(AIncrement);
  if (Index <> -1) then
    Result := FGlyphString[Index]
  else
    Result := nil;
end;

function TPascalTypeGlyphGlyphIterator.Previous(AIncrement: integer): integer;
begin
  Result := Peek(-AIncrement);
  FIndex := Result;
end;

procedure TPascalTypeGlyphGlyphIterator.Reset(ALookupFlags: Word; AMarkAttachmentFilter: integer);
begin
  SetIndex(0);
  FLookupFlags := ALookupFlags;
  FMarkAttachmentFilter := AMarkAttachmentFilter;
end;

procedure TPascalTypeGlyphGlyphIterator.SetIndex(const Value: integer);
begin
  FIndex := Min(Max(0, Value), FGlyphString.Count-1);
end;

function TPascalTypeGlyphGlyphIterator.ShouldIgnore(AGlyph: TPascalTypeGlyph): boolean;
begin
  Result :=
    ((FLookupFlags and TCustomOpenTypeLookupTable.IGNORE_BASE_GLYPHS <> 0) and (AGlyph.IsBase)) or
    ((FLookupFlags and TCustomOpenTypeLookupTable.IGNORE_LIGATURES <> 0) and (AGlyph.IsLigature)) or
    ((FLookupFlags and TCustomOpenTypeLookupTable.IGNORE_MARKS <> 0) and (AGlyph.IsMark)) or
    ((FMarkAttachmentFilter <> -1) and (AGlyph.IsMark) and (FMarkAttachmentFilter <> AGlyph.MarkAttachmentType));
end;

function TPascalTypeGlyphGlyphIterator.Step(AIncrement: integer): integer;
begin
  if (FIndex <> -1) then
  begin
    Inc(FIndex, AIncrement);

    if (FIndex < 0) or (FIndex >= FGlyphString.Count) then
      FIndex := -1;
  end;
  Result := FIndex;
end;

end.
