unit PascalType.Unicode.Builder.CharacterSet;

interface

uses
  PascalType.Unicode,
  PascalType.Unicode.Builder.ResourceWriter;

type
  // Start and stop of a range of code points
  TRange = record
    Start: Cardinal;
    Stop: Cardinal;
  end;

  TRangeArray = array of TRange;

//----------------------------------------------------------------------------------------------------------------------
//
//      TCharacterSet
//
//----------------------------------------------------------------------------------------------------------------------
type
  TCharacterSet = record
  const
    BitsPerByte = 8;
    MaxBitIndex = PascalTypeUnicode.MaximumUTF16;//$01000000;
    MaxByteIndex = MaxBitIndex div BitsPerByte;

  private
    // Array of bytes
    Bits: array[0..MaxByteIndex] of Byte;

  private
    function FindNextCharacterRange(var Start, Stop: Cardinal): Boolean;
    function GetCharacter(Code: TPascalTypeCodePoint): Boolean;

  public
    // Array of all bits within the byte array
    property Characters[Code: TPascalTypeCodePoint]: boolean read GetCharacter; default;

    procedure SetCharacter(Code: TPascalTypeCodePoint);

    function FindCharacterRanges: TRangeArray;
  end;


//----------------------------------------------------------------------------------------------------------------------
//
//      TCharacterSetList
//
//----------------------------------------------------------------------------------------------------------------------
type
  TCharacterSetList = record
  public
    Data: array[Byte] of TCharacterSet;

  public
    procedure WriteAsResource(AResourceWriter: TResourceWriter);
  end;


//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

implementation


//----------------------------------------------------------------------------------------------------------------------
//
//      TCharacterSet
//
//----------------------------------------------------------------------------------------------------------------------
function TCharacterSet.FindCharacterRanges: TRangeArray;
var
  Capacity, Index: Integer;
  Start, Stop: Cardinal;
begin
  Capacity := 0;
  Index := 0;
  Start := 0;
  Stop := 0;
  while FindNextCharacterRange(Start, Stop) do
  begin
    if Index >= Capacity then
    begin
      Inc(Capacity, 64);
      SetLength(Result, Capacity);
    end;

    Assert(Start <= MaxBitIndex);
    Assert(Stop <= MaxBitIndex);
    Assert(Start <= Stop);

    Result[Index].Start := Start;
    Result[Index].Stop := Stop;

    Start := Stop + 1;

    Inc(Index);
  end;

  SetLength(Result, Index);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCharacterSet.FindNextCharacterRange(var Start, Stop: Cardinal): Boolean;
var
  ByteIndex: Cardinal;
begin
  // Find next set bit.
  ByteIndex := Start div BitsPerByte;
  if (ByteIndex > MaxByteIndex) then
    Exit(False);

  // Disregard bits at positions before the current start.
  var Mask: Byte := 1 shl (Start and $07);
  if (Bits[ByteIndex] < Mask) then
  begin
    // No (relevant) bits in current byte. Scan forward until we find a byte with any bits set.
    Inc(ByteIndex);

    while (ByteIndex <= MaxByteIndex) and (Bits[ByteIndex] = 0) do
      Inc(ByteIndex);

    Start := ByteIndex * BitsPerByte;
  end;

  // Find the exact position bit within the byte we found above
  while (Start <= MaxBitIndex) and (not Characters[Start]) do
    Inc(Start);

  if (Start > MaxBitIndex) then
    Exit(False);

  Result := True;

  // Find next unset bit.
  Stop := Start;
  ByteIndex := Stop div BitsPerByte;

  // We now know that the bit at the current position is set. Disregard
  // that bit, and all bits before it.
  Mask := Byte(not(Cardinal(1 shl (Start and $07 + 1))-1));
  if (Bits[ByteIndex] and Mask = Mask) then
  begin
    // No (relevant) bits in current byte. Scan forward until we find a byte with any bits unset.
    Inc(ByteIndex);

    while (ByteIndex <= MaxByteIndex) and (Bits[ByteIndex] = $FF) do
      Inc(ByteIndex);

    Stop := ByteIndex * BitsPerByte;
  end;

  while (Stop <= MaxBitIndex) and (Characters[Stop]) do
    Inc(Stop);

  if (Stop > MaxBitIndex) then
    Stop := MaxBitIndex
  else
    Dec(Stop);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCharacterSet.SetCharacter(Code: TPascalTypeCodePoint);
begin
  Assert(Code <= MaxBitIndex);

  var p: PByte := @Bits[Code div BitsPerByte];

  var Mask: Byte := 1 shl (Code and $07);

  p^ := p^ or Mask;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCharacterSet.GetCharacter(Code: TPascalTypeCodePoint): Boolean;
begin
  Assert(Code <= MaxBitIndex);

  var p: PByte := @Bits[Code div BitsPerByte];

  var Mask: Byte := 1 shl (Code and $07);

  Result := ((p^ and Mask) <> 0);
end;


//----------------------------------------------------------------------------------------------------------------------
//
//      TCharacterSetList
//
//----------------------------------------------------------------------------------------------------------------------
procedure TCharacterSetList.WriteAsResource(AResourceWriter: TResourceWriter);
begin
  for var i := Low(Data) to High(Data) do
  begin
    var Ranges := Data[i].FindCharacterRanges;

    if (Length(Ranges) = 0) then
      continue;

    AResourceWriter.WriteResourceByte(Ord(i));

    AResourceWriter.WriteResourceCardinal(Length(Ranges));

    for var j := Low(Ranges) to High(Ranges) do
    begin
      AResourceWriter.WriteResourceChar(Ranges[j].Start);
      AResourceWriter.WriteResourceChar(Ranges[j].Stop);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

end.
