unit PascalType.Unicode.Builder.ResourceWriter;

interface

uses
  System.Classes;

const
  sDefaultResourceFilename = 'unicode.rc';

//----------------------------------------------------------------------------------------------------------------------
//
//      TResourceWriter
//
//----------------------------------------------------------------------------------------------------------------------
type
  TResourceWriterErrorHandler = reference to procedure(const S: string);

type
  TResourceWriter = class
  private
    FFilename: string;
    FCompressed: boolean;
    FTextStream: TStream;
    FResourceStream: TStream;
    FResourceDataStream: TStream;
    FLineBuffer: string;
    FByteCount: integer;

  private
    procedure FlushBuffer(Force: boolean);
    procedure FlushResource;

  public
    constructor Create(const AFilename: string = sDefaultResourceFilename; ACompressed: boolean = False);
    destructor Destroy; override;

    procedure WriteHeader;

    procedure WriteTextLine(const S: AnsiString = '');

    procedure BeginResource(const AName: string);
    procedure EndResource;

    procedure WriteResourceByte(Value: Cardinal);
    procedure WriteResourceCardinal(Value: Cardinal);
    procedure WriteResourceChar(Value: Cardinal);
    procedure WriteResourceCharArray(const Values: array of Cardinal);
  end;

implementation

uses
  System.ZLib,
  System.IOUtils,
  System.SysUtils,
  PascalType.Unicode,
  PascalType.Unicode.Builder.Common,
  PascalType.Unicode.Builder.Logger;

//----------------------------------------------------------------------------------------------------------------------
//
//      TResourceWriter
//
//----------------------------------------------------------------------------------------------------------------------
constructor TResourceWriter.Create(const AFilename: string; ACompressed: boolean);
begin
  inherited Create;

  FFilename := TPath.GetFileName(AFilename);

  FTextStream := TFileStream.Create(AFilename, fmCreate);
  FCompressed := ACompressed;

  FResourceDataStream := TMemoryStream.Create;
end;

destructor TResourceWriter.Destroy;
begin
  if (FResourceStream <> FResourceDataStream) then
    FResourceStream.Free;

  FResourceDataStream.Free;

  inherited;
end;

procedure TResourceWriter.BeginResource(const AName: string);
begin
  WriteTextLine;
  WriteTextLine;
  WriteTextLine(AnsiString(AName+' '+sUnicodeResourceType));
  WriteTextLine('BEGIN');
  FLineBuffer := '  ';

  FResourceDataStream.Size := 0;

  if FCompressed then
    FResourceStream := TZCompressionStream.Create(FResourceDataStream)
  else
    FResourceStream := FResourceDataStream;
end;

procedure TResourceWriter.EndResource;
begin
  if FCompressed then
    FreeAndNil(FResourceStream);

  FlushResource;

  WriteTextLine('END');
end;

procedure TResourceWriter.FlushBuffer(Force: boolean);
begin
  if (FByteCount = 0) then
    exit;

  if (Force) or (FByteCount >= 32) then
  begin
    WriteTextLine(AnsiString(FLineBuffer));
    FLineBuffer := '  ';
    FByteCount := 0;
  end;
end;

procedure TResourceWriter.FlushResource;
var
  WordBuffer: Word;
  ByteBuffer: Byte;
begin
  FResourceDataStream.Position := 0;

  while (FResourceDataStream.Position + SizeOf(WordBuffer) <= FResourceDataStream.Size) and
    (FResourceDataStream.Read(WordBuffer, SizeOf(WordBuffer)) = SizeOf(WordBuffer)) do
  begin
    FLineBuffer := FLineBuffer + '0x'+IntToHex(WordBuffer, 4);

    if (FResourceDataStream.Position < FResourceDataStream.Size) then
      FLineBuffer := FLineBuffer + ', ';

    Inc(FByteCount, SizeOf(WordBuffer));

    FlushBuffer(False);
  end;

  while (FResourceDataStream.Read(ByteBuffer, SizeOf(ByteBuffer)) = SizeOf(ByteBuffer)) do
  begin
    FLineBuffer := FLineBuffer + '"\x'+IntToHex(ByteBuffer, 2)+'"';
    Inc(FByteCount);

    FlushBuffer(False);
  end;

  FlushBuffer(True);
end;

procedure TResourceWriter.WriteHeader;
begin
  WriteTextLine(AnsiString('/' + StringOfChar('*', 79)));
  WriteTextLine;
  WriteTextLine;
  WriteTextLine(AnsiString('  ' + FFilename));
  WriteTextLine;
  WriteTextLine;
  WriteTextLine(AnsiString(Format('  Generated from the Unicode Character Database on %s by UDExtract.', [DateTimeToStr(Now)])));
  WriteTextLine('  UDExtract was written by:');
  WriteTextLine('  - Dipl. Ing. Mike Lischke, public@lischke-online.de');
  WriteTextLine('  - Anders Melander, anders@melander.dk');
  WriteTextLine;
  WriteTextLine(AnsiString(StringOfChar('*', 79) + '/'));
  WriteTextLine;
  WriteTextLine('#define LANG_NEUTRAL 0');
  WriteTextLine('#define SUBLANG_NEUTRAL 0');
  WriteTextLine;
  WriteTextLine('LANGUAGE LANG_NEUTRAL,SUBLANG_NEUTRAL // Language neutral');
  WriteTextLine;
  WriteTextLine('/' + AnsiString(StringOfChar('*', 78) + '/'));
end;

procedure TResourceWriter.WriteResourceByte(Value: Cardinal);
begin
  if (Value > High(Byte)) then
    Logger.FatalError('byte out of bound');

  FResourceStream.WriteData(Byte(Value));
end;

procedure TResourceWriter.WriteResourceCardinal(Value: Cardinal);
begin
  FResourceStream.WriteBuffer(Value, SizeOf(Value));
end;

procedure TResourceWriter.WriteResourceChar(Value: Cardinal);
begin
  if (Value > PascalTypeUnicode.MaximumUTF16) then
    Logger.FatalError('Unicode character out of bound');

  // Note: We only write 3 bytes. The high byte is unsed.
  FResourceStream.WriteBuffer(Value, 3);
end;

procedure TResourceWriter.WriteResourceCharArray(const Values: array of Cardinal);
begin
  // loops through Values and writes them into the target file

  for var i := Low(Values) to High(Values) do
    WriteResourceChar(Values[i]);
end;

procedure TResourceWriter.WriteTextLine(const S: AnsiString);
begin
  // Writes the given string as line into the resource script

  if (S <> '') then
    FTextStream.WriteBuffer(PAnsiChar(S)^, Length(S));

  FTextStream.WriteData(AnsiChar(#13));
  FTextStream.WriteData(AnsiChar(#10));
end;

end.
