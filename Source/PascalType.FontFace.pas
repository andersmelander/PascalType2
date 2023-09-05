unit PascalType.FontFace;

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
  Types,
  Generics.Collections,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables.TrueType.Directory,
  PascalType.Tables;

type
  TCustomPascalTypeFontFacePersistent = class;

  TFontFaceNotification = (fnDestroy, fnChanged);

  IPascalTypeFontFaceNotification = interface
    ['{6494D33F-B6D0-4598-B2F5-3C4A37053235}']
    procedure FontFaceNotification(Sender: TCustomPascalTypeFontFacePersistent; Notification: TFontFaceNotification);
  end;

  // TODO : This class can most likely be rolled into the derived class
  // TCustomPascalTypeFontFace since we will probably only ever have that one derived class.
  TCustomPascalTypeFontFacePersistent = class abstract(TInterfacedPersistent, IStreamPersist)
  private
    FUpdateCount: integer;
    FModified: boolean;
    FOnChanged: TNotifyEvent;
    FSubscribers: TList<IPascalTypeFontFaceNotification>;
  protected
    procedure Changed; virtual;
    property Modified: boolean read FModified;

    procedure Notify(Notification: TFontFaceNotification);
  public
    // IStreamPersist
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;

  public
    destructor Destroy; override;

    procedure Subscribe(const Subscriber: IPascalTypeFontFaceNotification);
    procedure Unsubscribe(const Subscriber: IPascalTypeFontFaceNotification);

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure LoadFromFile(FileName: TFileName);
    procedure SaveToFile(FileName: TFileName);

    // CreateLayoutEngine creates a layout engine specific to the font technology
    // handled by this font class.
    // It really should return a TCustomPascalTypeLayoutEngine but due to unit
    // and class dependencies that isn't feasible.
    // Instead it returns the layout engine as a TObject and the caller must then
    // case that to TCustomPascalTypeLayoutEngine.
    function CreateLayoutEngine: TObject; virtual; abstract;

    property OnChanged: TNotifyEvent read FOnChanged;
  end;

implementation

{ TCustomPascalTypeFontFace }

procedure TCustomPascalTypeFontFacePersistent.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TCustomPascalTypeFontFacePersistent.EndUpdate;
begin
  if (FUpdateCount = 1) and (FModified) then
  begin
    Notify(fnChanged);

    if Assigned(FOnChanged) then
      FOnChanged(Self);

    FModified := False;
  end;
  Dec(FUpdateCount);
end;

procedure TCustomPascalTypeFontFacePersistent.Changed;
begin
  BeginUpdate;
  FModified := True;
  EndUpdate;
end;

destructor TCustomPascalTypeFontFacePersistent.Destroy;
begin
  Notify(fnDestroy);
  FreeAndNil(FSubscribers);

  inherited;
end;

procedure TCustomPascalTypeFontFacePersistent.LoadFromFile(FileName: TFileName);
var
  Stream: TStream;
begin
  // TODO : TBufferedFileStream doesn't exist in older versions of Delphi
  BeginUpdate;
  try
    Stream := TBufferedFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      LoadFromStream(Stream);
    finally
      Stream.Free;
    end;

    Changed;
  finally
    EndUpdate;
  end;
end;

procedure TCustomPascalTypeFontFacePersistent.Notify(Notification: TFontFaceNotification);
var
  i: integer;
begin
  if (FSubscribers = nil) then
    exit;

  for i := FSubscribers.Count-1 downto 0 do
    FSubscribers[i].FontFaceNotification(Self, Notification);
end;

procedure TCustomPascalTypeFontFacePersistent.SaveToFile(FileName: TFileName);
var
  Stream: TStream;
begin
  if FileExists(FileName) then
    Stream := TFileStream.Create(FileName, fmCreate)
  else
    Stream := TFileStream.Create(FileName, fmOpenWrite);
  try

    SaveToStream(Stream);

  finally
    Stream.Free;
  end;
end;

procedure TCustomPascalTypeFontFacePersistent.Subscribe(const Subscriber: IPascalTypeFontFaceNotification);
begin
  if (FSubscribers = nil) then
    FSubscribers := TList<IPascalTypeFontFaceNotification>.Create;

  FSubscribers.Add(Subscriber);
end;

procedure TCustomPascalTypeFontFacePersistent.Unsubscribe(const Subscriber: IPascalTypeFontFaceNotification);
begin
  if (FSubscribers <> nil) then
    FSubscribers.Remove(Subscriber);
end;

end.
