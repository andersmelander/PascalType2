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
  Classes, SysUtils, Types,
  PT_Types,
  PT_Classes,
  PT_TableDirectory,
  PT_Tables;

type
  // TODO : This class can most likely be rolled into the derived class
  // TCustomPascalTypeFontFace since we will probably only ever have that one derived class.
  TCustomPascalTypeFontFacePersistent = class abstract(TInterfacedPersistent, IStreamPersist, IPascalTypeFontFaceChange)
  private
    FOnChanged: TNotifyEvent;
  protected
    // IPascalTypeFontFaceChange
    procedure Changed; virtual;

  public
    // IStreamPersist
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;

  public
    procedure LoadFromFile(FileName: TFileName);
    procedure SaveToFile(FileName: TFileName);

    // TODO : Needs multicast. FontFace can be shared among rasterizers
//    property OnChanged: TNotifyEvent read FOnChanged;
  end;

implementation

{ TCustomPascalTypeFontFace }

procedure TCustomPascalTypeFontFacePersistent.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TCustomPascalTypeFontFacePersistent.LoadFromFile(FileName: TFileName);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    LoadFromStream(FileStream);
  finally
    FileStream.Free;
  end;
end;

procedure TCustomPascalTypeFontFacePersistent.SaveToFile(FileName: TFileName);
var
  FileStream: TFileStream;
begin
  if FileExists(FileName) then
    FileStream := TFileStream.Create(FileName, fmCreate)
  else
    FileStream := TFileStream.Create(FileName, fmOpenWrite);
  try
    SaveToStream(FileStream);
  finally
    FileStream.Free;
  end;
end;

end.
