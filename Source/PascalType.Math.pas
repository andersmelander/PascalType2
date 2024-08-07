unit PascalType.Math;

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
//  Portions created by Christian-W. Budde are Copyright (C) 2010-2021        //
//  by Christian-W. Budde. All Rights Reserved.                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

{$I PT_Compiler.inc}

uses
  PascalType.Types;

// various swap functions for converting big-endian data
function Swap16(Value: Word): Word; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function Swap32(Value: Cardinal): Cardinal;
function Swap64(Value: Int64): Int64;

// integer math
function FloorLog2(Value: Cardinal): Cardinal;
function Mul32To64(Value, Scale: Integer): Int64;
function MulDiv(Value, Scale, Divisor: Integer): Integer;

implementation

function Swap16(Value: Word): Word; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
{$IFDEF SUPPORTS_INLINE}
begin
  Result := Swap(Value);
{$ELSE}
{$IFDEF PUREPASCAL}
begin
  Result := Swap(Value);
{$ELSE}
asm
  {$IFDEF CPUx86_64}
  MOV     EAX, ECX
  {$ENDIF}
  XCHG    AL, AH
  {$ENDIF}
  {$ENDIF}
end;

function Swap32(Value: Cardinal): Cardinal;
{$IFDEF PUREPASCAL}
type
  TTwoWords = array [0..1] of Word;
begin
  TTwoWords(Result)[1] := Swap(TTwoWords(Value)[0]);
  TTwoWords(Result)[0] := Swap(TTwoWords(Value)[1]);
{$ELSE}
asm
  {$IFDEF CPUx86_64}
  MOV     EAX, ECX
  {$ENDIF}
  BSWAP   EAX
  {$ENDIF}
end;

function Swap64(Value: Int64): Int64;
type
  TFourWords = array [0..3] of Word;
begin
  TFourWords(Result)[3] := Swap(TFourWords(Value)[0]);
  TFourWords(Result)[2] := Swap(TFourWords(Value)[1]);
  TFourWords(Result)[1] := Swap(TFourWords(Value)[2]);
  TFourWords(Result)[0] := Swap(TFourWords(Value)[3]);
end;

function FloorLog2(Value: Cardinal): Cardinal;
begin
  // check if Value is zero as log2(0) is undefined
  if (Value = 0) then
    raise EPascalTypeError.Create('FloorLog2 Error');

  // set basic value
  Result := 0;

  if (Value >= 1 shl 16) then
  begin
    Value := Value shr 16;
    Result := Result + 16;
  end;
  if (Value >= 1 shl 8) then
  begin
    Value := Value shr 8;
    Result := Result + 8;
  end;
  if (Value >= 1 shl 4) then
  begin
    Value := Value shr 4;
    Result := Result + 4;
  end;
  if (Value >= 1 shl 2) then
  begin
    Value := Value shr 2;
    Result := Result + 2;
  end;
  if (Value >= 1 shl 1) then
    Result := Result + 1;
end;

function Mul32To64(Value, Scale: Integer): Int64;
begin
  Result := Value * Scale;
end;

function MulDiv(Value, Scale, Divisor: Integer): Integer;
var
  Sign: Integer;
  Temp: Int64;
begin
  Sign := Value;
  Value := Abs(Value);

  Sign := Sign xor Scale;
  Scale := Abs(Scale);

  Sign := Sign xor Divisor;
  Divisor := Abs(Divisor);

  Temp := Value * Scale;
  Divisor := Temp div Divisor;

  if Sign < 0 then
    Result := -Divisor
  else
    Result := Divisor;
end;

end.
