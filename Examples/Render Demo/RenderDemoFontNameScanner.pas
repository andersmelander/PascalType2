unit RenderDemoFontNameScanner;

interface

uses
  Windows, Classes, SysUtils,
  PT_Types,
  PT_Classes,
  PT_Tables,
  PascalType.FontFace,
  PascalType.FontFace.SFNT;

type
  TFontScannedEvent = procedure(Sender: TObject; const FileName: string;
    Font: TCustomPascalTypeFontFacePersistent) of object;

  TFontNameScanner = class(TThread)
  private
    FOnFontName  : TFontScannedEvent;
    FCurrentFile : string;
    FFontFaceScan : TPascalTypeFontFaceScan;
    procedure FontScanned;
  protected
    procedure Execute; override;
  public
    property OnFontScanned: TFontScannedEvent read FOnFontName write FOnFontName;
  end;

implementation

{ TFontNameScanner }

procedure TFontNameScanner.Execute;
var
  SR: TSearchRec;
begin
  if (not Assigned(FOnFontName)) then
    exit;

  if FindFirst('*.ttf', faAnyFile, SR) = 0 then
  try
    repeat
      FFontFaceScan := TPascalTypeFontFaceScan.Create;
      try
        with FFontFaceScan do
          try
            // store current file
            FCurrentFile := SR.Name;

//            if FCurrentFile = 'tahoma.ttf' then
//              Continue;

            // load font from file
            LoadFromFile(FCurrentFile);

            Synchronize(FontScanned);
          except
            on
              E: EPascalTypeError do Continue;
            else
              Continue;
          end;

      finally
        FreeAndNil(FFontFaceScan);
      end;
    until (FindNext(SR) <> 0) or Terminated;
  finally
    FindClose(SR);
  end;
end;

procedure TFontNameScanner.FontScanned;
begin
  if Assigned(FOnFontName) then
  begin
    UniqueString(FCurrentFile);
    FOnFontName(Self, FCurrentFile, FFontFaceScan);
  end;
end;

end.
