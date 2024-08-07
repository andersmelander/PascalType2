unit PascalType.Tables.OpenType.GDEF;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      'GDEF' table type                                     //
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
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables,
  PascalType.Tables.OpenType,
  PascalType.Tables.OpenType.Common;

//------------------------------------------------------------------------------
//
//              TOpenTypeGlyphDefinitionTable
//
//------------------------------------------------------------------------------
type
  TOpenTypeGlyphDefinitionTable = class(TCustomOpenTypeVersionedNamedTable)
  private
    FGlyphClassDef      : TCustomOpenTypeClassDefinitionTable; // Class definition table for glyph type
    FAttachmentListOffset : Word;                                // Offset to list of glyphs with attachment points-from beginning of GDEF header (may be NULL)
    FLigatureCaretListOffset : Word;                                // Offset to list of positioning points for ligature carets-from beginning of GDEF header (may be NULL)
    FMarkAttachClassDef : TCustomOpenTypeClassDefinitionTable; // Class definition table for mark attachment type (may be nil)
    FMarkGlyphSetsDef   : TOpenTypeMarkGlyphSetTable;          // Table of mark set definitions (may be nil)
  public
    constructor Create(AParent: TCustomPascalTypeTable); override;
    destructor Destroy; override;

    class function GetTableType: TTableType; override;

    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream; Size: Cardinal = 0); override;
    procedure SaveToStream(Stream: TStream); override;

    property GlyphClassDefinition: TCustomOpenTypeClassDefinitionTable read FGlyphClassDef;
    property MarkAttachmentClassDefinition: TCustomOpenTypeClassDefinitionTable read FMarkAttachClassDef;
    property MarkGlyphSet: TOpenTypeMarkGlyphSetTable read FMarkGlyphSetsDef;
  end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  SysUtils,
  PascalType.ResourceStrings;

//------------------------------------------------------------------------------
//
//              TOpenTypeGlyphDefinitionTable
//
//------------------------------------------------------------------------------
constructor TOpenTypeGlyphDefinitionTable.Create(AParent: TCustomPascalTypeTable);
const
  CGlyphDefinitionDefaultVersion: TFixedPoint = (Fixed: $00010002);
begin
  inherited;
  Version := CGlyphDefinitionDefaultVersion;
end;

destructor TOpenTypeGlyphDefinitionTable.Destroy;
begin
  FreeAndNil(FGlyphClassDef);
  FreeAndNil(FMarkAttachClassDef);
  FreeAndNil(FMarkGlyphSetsDef);
  inherited;
end;

procedure TOpenTypeGlyphDefinitionTable.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TOpenTypeGlyphDefinitionTable then
  begin
    FAttachmentListOffset := TOpenTypeGlyphDefinitionTable(Source).FAttachmentListOffset;
    FLigatureCaretListOffset := TOpenTypeGlyphDefinitionTable(Source).FLigatureCaretListOffset;

    if (TOpenTypeGlyphDefinitionTable(Source).FMarkGlyphSetsDef <> nil) then
    begin
      FMarkGlyphSetsDef := TOpenTypeMarkGlyphSetTable.Create(Self);
      FMarkGlyphSetsDef.Assign(TOpenTypeGlyphDefinitionTable(Source).FMarkGlyphSetsDef);
    end else
      FMarkGlyphSetsDef.Free;

    if (TOpenTypeGlyphDefinitionTable(Source).FGlyphClassDef <> nil) then
    begin
      if (FGlyphClassDef <> nil) and (FGlyphClassDef.ClassType <>  TOpenTypeGlyphDefinitionTable(Source).FGlyphClassDef.ClassType) then
        FreeAndNil(FGlyphClassDef);
      FGlyphClassDef := TOpenTypeClassDefinitionTableClass(TOpenTypeGlyphDefinitionTable(Source).FGlyphClassDef.ClassType).Create;
      FGlyphClassDef.Assign(TOpenTypeGlyphDefinitionTable(Source).FGlyphClassDef);
    end else
      FreeAndNil(FGlyphClassDef);

    if (TOpenTypeGlyphDefinitionTable(Source).FMarkAttachClassDef <> nil) then
    begin
      if (FMarkAttachClassDef <> nil) and (FMarkAttachClassDef.ClassType <>  TOpenTypeGlyphDefinitionTable(Source).FMarkAttachClassDef.ClassType) then
        FreeAndNil(FMarkAttachClassDef);

      FMarkAttachClassDef := TOpenTypeClassDefinitionTableClass(TOpenTypeGlyphDefinitionTable(Source).FMarkAttachClassDef.ClassType).Create;
      FMarkAttachClassDef.Assign(TOpenTypeGlyphDefinitionTable(Source).FMarkAttachClassDef);
    end else
      FreeAndNil(FMarkAttachClassDef);
  end;
end;

class function TOpenTypeGlyphDefinitionTable.GetTableType: TTableType;
begin
  Result := 'GDEF';
end;

procedure TOpenTypeGlyphDefinitionTable.LoadFromStream(Stream: TStream; Size: Cardinal);
var
  StartPos           : Int64;
  Value16            : Word;
  GlyphClassDefinitionOffset: Word;
  MarkAttachmentClassDefOffset: Word;
  MarkGlyphSetsDefinitionsOffset: Word;
begin
  StartPos := Stream.Position;

  inherited;

  // Check version already read
  if Version.Value <> 1 then
    raise EPascalTypeError.Create(RCStrUnsupportedVersion);

  // Check if table is complete
  if Stream.Position + 4*SizeOf(Word) > Stream.Size then
    raise EPascalTypeError.Create(RCStrTableIncomplete);

  // Glyph class definition offset
  GlyphClassDefinitionOffset := BigEndianValue.ReadWord(Stream);

  // Attachment list offset
  FAttachmentListOffset := BigEndianValue.ReadWord(Stream);

  // Ligature caret list offset
  FLigatureCaretListOffset := BigEndianValue.ReadWord(Stream);

  // Mark attachment class definition offset
  MarkAttachmentClassDefOffset := BigEndianValue.ReadWord(Stream);

  if (Version.Fract >= 2) then
  begin
    // Mark glyph set definitions offset
    MarkGlyphSetsDefinitionsOffset := BigEndianValue.ReadWord(Stream);

  end else
    MarkGlyphSetsDefinitionsOffset := 0;


  FreeAndNil(FGlyphClassDef);
  if GlyphClassDefinitionOffset <> 0 then
  begin
    Stream.Position := StartPos + GlyphClassDefinitionOffset;

    Value16 := BigEndianValue.ReadWord(Stream);
    case Value16 of
      1:
        FGlyphClassDef := TOpenTypeClassDefinitionFormat1Table.Create;
      2:
        FGlyphClassDef := TOpenTypeClassDefinitionFormat2Table.Create;
    else
      raise EPascalTypeError.Create(RCStrUnknownClassDefinition);
    end;

    if (FGlyphClassDef <> nil) then
      FGlyphClassDef.LoadFromStream(Stream);
  end;


  FreeAndNil(FMarkAttachClassDef);
  if MarkAttachmentClassDefOffset <> 0 then
  begin
    Stream.Position := StartPos + MarkAttachmentClassDefOffset;

    Value16 := BigEndianValue.ReadWord(Stream);
    case Value16 of
      1:
        FMarkAttachClassDef := TOpenTypeClassDefinitionFormat1Table.Create;
      2:
        FMarkAttachClassDef := TOpenTypeClassDefinitionFormat2Table.Create;
    else
      raise EPascalTypeError.Create(RCStrUnknownClassDefinition);
    end;

    if (FMarkAttachClassDef <> nil) then
      FMarkAttachClassDef.LoadFromStream(Stream);
  end;


  if MarkGlyphSetsDefinitionsOffset <> 0 then
  begin
    Stream.Position := StartPos + MarkGlyphSetsDefinitionsOffset;

    if (FMarkGlyphSetsDef = nil) then
      FMarkGlyphSetsDef := TOpenTypeMarkGlyphSetTable.Create(Self);

    FMarkGlyphSetsDef.LoadFromStream(Stream);
  end else
    FreeAndNil(FMarkGlyphSetsDef);
end;

procedure TOpenTypeGlyphDefinitionTable.SaveToStream(Stream: TStream);
var
  StartPos: Int64;
  Offsets : array [0..4] of Word;
begin
  inherited;

  with Stream do
  begin
    // remember start position as position minus version aready written
    StartPos := Position - 4;

    // reset offset array to zero
    FillChar(Offsets[0], 5 * SizeOf(Word), 0);

    // skip directory for now
    Seek(SizeOf(Offsets), soCurrent);

    // write glyph class definition
    if (FGlyphClassDef <> nil) then
    begin
      Offsets[0] := Word(Position - StartPos);
      FGlyphClassDef.SaveToStream(Stream);
    end;

    (*
      // write attachment list
      if (FAttachmentListOffset <> nil) then
      begin
      Offsets[1] := Word(Position - StartPos);
      FAttachmentListOffset.SaveToStream(Stream);
      end;

      // write ligature caret list
      if (FLigatureCaretListOffset <> nil) then
      begin
      Offsets[2] := Word(Position - StartPos);
      FLigatureCaretListOffset.SaveToStream(Stream);
      end;
    *)

    // write mark attachment class definition
    if (FMarkAttachClassDef <> nil) then
    begin
      Offsets[3] := Word(Position - StartPos);
      FMarkAttachClassDef.SaveToStream(Stream);
    end;

    // write mark glyph set definition
    if (FMarkGlyphSetsDef <> nil) then
    begin
      Offsets[4] := Word(Position - StartPos);
      FMarkGlyphSetsDef.SaveToStream(Stream);
    end;

    // skip directory for now
    Position := StartPos + SizeOf(TFixedPoint);

    // write directory

    // write glyph class definition
    BigEndianValue.WriteWord(Stream, Offsets[0]);

    // write attach list
    BigEndianValue.WriteWord(Stream, Offsets[1]);

    // write ligature caret list
    BigEndianValue.WriteWord(Stream, Offsets[2]);

    // write mark attach class definition
    BigEndianValue.WriteWord(Stream, Offsets[3]);

    // write mark glyph set
    BigEndianValue.WriteWord(Stream, Offsets[4]);
  end;
end;

//------------------------------------------------------------------------------

initialization

  PascalTypeTableClasses.RegisterTable(TOpenTypeGlyphDefinitionTable);

end.
