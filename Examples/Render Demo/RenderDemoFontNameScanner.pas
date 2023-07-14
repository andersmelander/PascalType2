unit RenderDemoFontNameScanner;

interface

uses
  Windows, Classes, SysUtils,
  PT_Types,
  PT_Classes,
  PascalType.Tables,
  PascalType.FontFace,
  PascalType.FontFace.SFNT;

type
  TFontScannedEvent = procedure(Sender: TObject; const FileName: string;
    Font: TCustomPascalTypeFontFacePersistent) of object;

  TFontNameScanner = class(TThread)
  private
    FPath: string;
    FOnFontName  : TFontScannedEvent;
    FCurrentFile : string;
    FFontFaceScan : TPascalTypeFontFaceScan;
    procedure FontScanned;
  protected
    procedure Execute; override;
  public
    constructor Create(const APath: string = '*.ttf');
    property OnFontScanned: TFontScannedEvent read FOnFontName write FOnFontName;
  end;

implementation

uses
  IOUtils,
  PascalType.Platform.Windows;

{ TFontNameScanner }

constructor TFontNameScanner.Create(const APath: string);
var
  FolderFont: string;
begin
  inherited Create(True);

  FolderFont := GetFontDirectory;
  FPath := TPath.Combine(FolderFont, APath);
end;

procedure TFontNameScanner.Execute;
var
  Folder: string;
  Mask: string;
  Filename: string;
begin
  if (not Assigned(FOnFontName)) then
    exit;

  Folder := TPath.GetDirectoryName(FPath);
  if (not TDirectory.Exists(Folder)) then
    exit;

  Mask := TPath.GetFileName(FPath);

  for Filename in TDirectory.GetFiles(Folder, Mask) do
  begin
    if (Terminated) then
      break;

    FFontFaceScan := TPascalTypeFontFaceScan.Create;
    try

      try

        // load font from file
        FFontFaceScan.LoadFromFile(Filename);

        FCurrentFile := Filename;

        Synchronize(FontScanned);

      except
        on E: EPascalTypeError do
          continue;
      else
        continue;
      end;

    finally
      FreeAndNil(FFontFaceScan);
    end;
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
