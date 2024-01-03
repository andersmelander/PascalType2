unit PascalType.Unicode.Builder.Common;

interface

uses
  System.Classes,
  System.SysUtils,
  PascalType.Unicode;

function IsHexDigit(C: Char): Boolean;
procedure SplitCodes(const Line: string; var Elements: TPascalTypeCodePoints);
procedure SplitLine(const Line: string; Elements: TStringList);

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

implementation

//----------------------------------------------------------------------------------------------------------------------

function IsHexDigit(C: Char): Boolean;
begin
  case C of
    '0'..'9',
    'A'..'F', 'a'..'f':
      Result := True;
  else
    Result := False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SplitCodes(const Line: string; var Elements: TPascalTypeCodePoints);
// splits S, which may contain space delimited hex strings, into single parts
// and fills Elements
var
  Head: PChar;
  Tail: PChar;
  s: string;
  i: Integer;
begin
  Elements := nil;
  Head := PChar(Line);

  while (Head^ <> #0) do
  begin
    Tail := Head;
    while IsHexDigit(Tail^) do
      Inc(Tail);

    SetString(s, Head, Tail - Head);

    if (Length(s) > 0) then
    begin
      i := Length(Elements);
      SetLength(Elements, i + 1);
      Elements[i] := StrToInt('$' + s);
    end;

    // Skip spaces
    while (Tail^ = ' ') do
      Inc(Tail);

    Head := Tail;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SplitLine(const Line: string; Elements: TStringList);
// splits the given string into parts which are separated by semicolon and fills Elements
// with the partial strings
var
  s: string;
begin
  Elements.Clear;

  var Head := PChar(Line);
  while (Head^ <> #0) do
  begin
    var Tail := Head;

    // Look for next semicolon or string end (or comment identifier)
    while (Tail^ <> ';') and (Tail^ <> '#') and (Tail^ <> #0) do
      Inc(Tail);

    SetString(s, Head, Tail - Head);

    Elements.Add(s.Trim);

    // ignore all characters in a comment
    if (Tail^ = '#') or (Tail^ = #0) then
      Break;

    Head := Tail + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

end.
