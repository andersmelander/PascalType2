unit PascalType.Unicode.Builder.Numbers;

interface

uses
  Generics.Collections,
  PascalType.Unicode,
  PascalType.Unicode.Builder.ResourceWriter;

//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeNumbers
//
//----------------------------------------------------------------------------------------------------------------------
type
  TUnicodeNumbers = class
  private type
    TCodeIndex = record
      Code: TPascalTypeCodePoint;
      Index: Cardinal;
    end;

    TNumber = record
      Numerator: Int64;
      Denominator: Int64;
    end;

  private
    // Array to hold the number equivalents for specific codes (sorted by code)
    FNumberCodes: TArray<TCodeIndex>;
    // Array of numbers used in NumberCodes
    FNumbers: TArray<TNumber>;

  private
    function MakeNumber(Num, Denom: Int64): Integer;

  public
    procedure Add(Code: TPascalTypeCodePoint; Num, Denom: Int64);

    procedure WriteAsResource(AResourceWriter: TResourceWriter);
  end;

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  Generics.Defaults;

//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeNumbers
//
//----------------------------------------------------------------------------------------------------------------------
function TUnicodeNumbers.MakeNumber(Num, Denom: Int64): Integer;
begin
  for var i := 0 to High(FNumbers) do
    if (FNumbers[i].Numerator = Num) and (FNumbers[i].Denominator = Denom) then
      Exit(i);

  Result := Length(FNumbers);
  SetLength(FNumbers, Result + 1);

  FNumbers[Result].Numerator := Num;
  FNumbers[Result].Denominator := Denom;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeNumbers.Add(Code: TPascalTypeCodePoint; Num, Denom: Int64);
var
  i, j: Integer;
begin
  // Insert the Code in order.
  i := 0;
  j := Length(FNumberCodes);
  while (i < j) and (Code > FNumberCodes[i].Code) do
    Inc(i);

  var Item: TCodeIndex;
  Item.Code := Code;
  Item.Index := MakeNumber(Num, Denom);

  var Index: integer;
  if (TArray.BinarySearch<TCodeIndex>(FNumberCodes, Item, Index, TComparer<TCodeIndex>.Construct(
    function(const A, B: TCodeIndex): integer
    begin
      Result := integer(A.Code)-integer(B.Code);
    end))) then
    // If the code matches we simply replace the number that was there before.
    FNumberCodes[Index].Index := Item.Index
  else
    Insert(Item, FNumberCodes, Index);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeNumbers.WriteAsResource(AResourceWriter: TResourceWriter);
begin
  // first, write the number definitions (size, values)
  AResourceWriter.WriteResourceByte(Length(FNumbers));
  for var i := 0 to High(FNumbers) do
  begin
    AResourceWriter.WriteResourceCardinal(Cardinal(FNumbers[i].Numerator));
    AResourceWriter.WriteResourceCardinal(Cardinal(FNumbers[i].Denominator));
  end;

  // second, write the number mappings (size, values)
  AResourceWriter.WriteResourceCardinal(Length(FNumberCodes));
  for var i := 0 to High(FNumberCodes) do
  begin
    AResourceWriter.WriteResourceChar(FNumberCodes[i].Code);
    AResourceWriter.WriteResourceByte(FNumberCodes[i].Index);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

end.
