unit PascalType.Unicode.Builder.Decomposition;

interface

uses
  Generics.Collections,
  PascalType.Unicode,
  PascalType.Unicode.Builder.ResourceWriter,
  PascalType.Unicode.Builder.CharacterSet;

//----------------------------------------------------------------------------------------------------------------------
//
//      TDecompositionItem
//
//----------------------------------------------------------------------------------------------------------------------
type
  TDecompositionItem = record
  private
    FDecomposition: TPascalTypeCodePoints;
    FCode: TPascalTypeCodePoint;
    FTag: TCompatibilityFormattingTag;
  private
    procedure SetDecompositions(const Value: TPascalTypeCodePoints);
  public
    property Code: TPascalTypeCodePoint read FCode write FCode;
    property Tag: TCompatibilityFormattingTag read FTag write FTag;

    property Decomposition: TPascalTypeCodePoints read FDecomposition write SetDecompositions;
  end;

  PDecompositionItem = ^TDecompositionItem;


//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeDecompositions
//
//----------------------------------------------------------------------------------------------------------------------
type
  TUnicodeDecompositions = class
  private
    FDecompositions: TList<TDecompositionItem>;

  private
    procedure Expand;
    function GetCount: integer;
    function GetItem(Index: integer): PDecompositionItem;
    function Decompose(const CodePoints: TPascalTypeCodePoints): TPascalTypeCodePoints;
    function Find(Code: TPascalTypeCodePoint): Integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Code: TPascalTypeCodePoint; Tag: TCompatibilityFormattingTag; const Decomposition: TPascalTypeCodePoints);

    procedure WriteAsResource(AResourceWriter: TResourceWriter);

    property Count: integer read GetCount;
    property Item[Index: integer]: PDecompositionItem read GetItem; default;
  end;


//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeCompositions
//
//----------------------------------------------------------------------------------------------------------------------
type
  TUnicodeCompositions = class
  private
    FCompositions: TList<PDecompositionItem>;
    // Composition exceptions (decompositions that cannot be recomposed)
    FExceptions: TCharacterSet;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddExclusions(Start, Stop: TPascalTypeCodePoint);

    procedure ConstructFromDecompositions(Decompositions: TUnicodeDecompositions);

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
//      TDecompositionItem
//
//----------------------------------------------------------------------------------------------------------------------
procedure TDecompositionItem.SetDecompositions(const Value: TPascalTypeCodePoints);
begin
  FDecomposition := Copy(Value);
end;


//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeDecompositions
//
//----------------------------------------------------------------------------------------------------------------------
constructor TUnicodeDecompositions.Create;
begin
  inherited Create;

  FDecompositions := TList<TDecompositionItem>.Create;
end;

destructor TUnicodeDecompositions.Destroy;
begin
  FDecompositions.Free;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeDecompositions.Add(Code: TPascalTypeCodePoint; Tag: TCompatibilityFormattingTag; const Decomposition: TPascalTypeCodePoints);
var
  I: Integer;
  Item: TDecompositionItem;
begin
  Item.Code := Code;
  Item.Tag := Tag;
  Item.Decomposition := Decomposition;

  FDecompositions.BinarySearch(Item, i, TComparer<TDecompositionItem>.Construct(
    function(const A, B: TDecompositionItem): integer
    begin
      if (A.Code < B.Code) then
        Result := -1
      else
      if (A.Code > B.Code) then
        Result := 1
      else
      if (A.Tag = cftCanonical) and (B.Tag <> cftCanonical) then
        Result := -1
      else
      if (A.Tag <> cftCanonical) and (B.Tag = cftCanonical) then
        Result := 1
      else
        Result := 0;
    end));

  FDecompositions.Insert(i, Item);
end;

//----------------------------------------------------------------------------------------------------------------------

function TUnicodeDecompositions.Find(Code: TPascalTypeCodePoint): Integer;
var
  Item: TDecompositionItem;
begin
  Item.Code := Code;

  if (FDecompositions.BinarySearch(Item, Result, TComparer<TDecompositionItem>.Construct(
    function(const A, B: TDecompositionItem): integer
    begin
      if (A.Code < B.Code) then
        Result := 1
      else
      if (A.Code > B.Code) then
        Result := -1
      else
        Result := 0;
    end))) then
  begin
    // Try to find the best
    while (FDecompositions[Result].Tag <> cftCanonical) and (Result > 0) and (FDecompositions[Result-1].Code = Code) do
      Dec(Result);
  end else
    Result := -1;
end;

//----------------------------------------------------------------------------------------------------------------------

function TUnicodeDecompositions.GetCount: integer;
begin
  Result := FDecompositions.Count;
end;

function TUnicodeDecompositions.GetItem(Index: integer): PDecompositionItem;
begin
  Result := @(FDecompositions.List[Index]);
end;

procedure TUnicodeDecompositions.WriteAsResource(AResourceWriter: TResourceWriter);
begin
  // Fully expand all decompositions before generating the output
  Expand;

  AResourceWriter.WriteResourceCardinal(FDecompositions.Count);

  for var i := 0 to FDecompositions.Count-1 do
  begin
    AResourceWriter.WriteResourceChar(FDecompositions[i].Code);
    AResourceWriter.WriteResourceByte(Length(FDecompositions[i].Decomposition));
    AResourceWriter.WriteResourceByte(Byte(FDecompositions[i].Tag));
    AResourceWriter.WriteResourceCharArray(FDecompositions[i].Decomposition);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TUnicodeDecompositions.Decompose(const CodePoints: TPascalTypeCodePoints): TPascalTypeCodePoints;

  procedure AddResult(Code: TPascalTypeCodePoint);
  begin
    SetLength(Result, Length(Result)+1);
    Result[High(Result)] := Code;
  end;

begin
  for var i := 0 to High(CodePoints) do
  begin
    var Index := Find(CodePoints[i]);

    if (Index >= 0) then
    begin
      var Sub := Decompose(FDecompositions[Index].Decomposition);
      for var j := 0 to High(Sub) do
        AddResult(Sub[j]);
    end else
      AddResult(CodePoints[i]);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeDecompositions.Expand;
// Expand all decompositions by recursively decomposing each character in the decomposition.
begin
  for var i := 0 to FDecompositions.Count-1 do
    FDecompositions[i].Decomposition := Decompose(FDecompositions[i].Decomposition);
end;


//----------------------------------------------------------------------------------------------------------------------
//
//      TUnicodeCompositions
//
//----------------------------------------------------------------------------------------------------------------------
constructor TUnicodeCompositions.Create;
begin
  inherited Create;

  FCompositions := TList<PDecompositionItem>.Create;
end;

destructor TUnicodeCompositions.Destroy;
begin
  FCompositions.Free;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCompositions.AddExclusions(Start, Stop: TPascalTypeCodePoint);
begin
  for var Code := Start to Stop do
    FExceptions.SetCharacter(Code);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCompositions.ConstructFromDecompositions(Decompositions: TUnicodeDecompositions);
begin
  // Copy decompositions, eliminating exceptions
  FCompositions.Capacity := Decompositions.Count;
  for var i := 0 to Decompositions.Count-1 do
  begin
    var Item := Decompositions[i];
    if (not FExceptions[Item.Code]) then
      FCompositions.Add(Item);
  end;

  FCompositions.Sort(TComparer<PDecompositionItem>.Construct(
    function(const Decomposition1, Decomposition2: PDecompositionItem): Integer
    var
      i, Len1, Len2, MinLen: Integer;
    begin
      Len1 := Length(Decomposition1.Decomposition);
      Len2 := Length(Decomposition2.Decomposition);
      MinLen := Len1;
      if MinLen > Len2 then
        MinLen := Len2;

      for i := 0 to MinLen - 1 do
      begin
        if Decomposition1.Decomposition[i] > Decomposition2.Decomposition[i] then
          Exit(1)
        else
        if Decomposition1.Decomposition[i] < Decomposition2.Decomposition[i] then
          Exit(-1);
      end;

      // If start of two arrays are identical, sorting from longer to shorter (gives more
      // chances to longer combinations at runtime
      if Len1 < Len2 then
        Result := 1
      else
      if Len1 > Len2 then
        Result := -1
      else
      // Canonical before compatible
      if (Decomposition1.Tag = cftCanonical) and (Decomposition2.Tag <> cftCanonical) then
        Result := -1
      else
      if (Decomposition1.Tag <> cftCanonical) and (Decomposition2.Tag = cftCanonical) then
        Result := 1
      else
        Result := 0;

    end));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TUnicodeCompositions.WriteAsResource(AResourceWriter: TResourceWriter);
begin
  AResourceWriter.WriteResourceCardinal(FCompositions.Count);

  for var i := 0 to FCompositions.Count-1 do
  begin
    AResourceWriter.WriteResourceChar(FCompositions[i].Code);
    AResourceWriter.WriteResourceByte(Length(FCompositions[i].Decomposition));
    AResourceWriter.WriteResourceByte(Byte(FCompositions[i].Tag));
    AResourceWriter.WriteResourceCharArray(FCompositions[i].Decomposition);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

end.
