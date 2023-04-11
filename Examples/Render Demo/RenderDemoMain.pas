unit RenderDemoMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, PT_Types, PT_Classes, PT_Tables, PT_Storage,
  PT_StorageSFNT,
  PT_FontEngineGDI,
  PT_FontEngineGR32,
  PT_Windows,
  RenderDemoFontNameScanner;

{$I ..\..\Source\PT_Compiler.inc}  

type
  TFontNameFile = packed record
    FullFontName : string;
    FileName     : TFileName;
  end;

  TFmRenderDemo = class(TForm)
    ComboBoxFont: TComboBox;
    ComboBoxFontSize: TComboBox;
    EditText: TEdit;
    LabelFont: TLabel;
    LabelFontSize: TLabel;
    LabelFontEngine: TLabel;
    LabelText: TLabel;
    PaintBox: TPaintBox;
    PanelText: TPanel;
    RadioButtonPascalType: TRadioButton;
    RadioButtonWindows: TRadioButton;
    RadioButtonGraphics32: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBoxFontChange(Sender: TObject);
    procedure ComboBoxFontSizeChange(Sender: TObject);
    procedure EditTextChange(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PanelTextResize(Sender: TObject);
    procedure RadioButtonPascalTypeClick(Sender: TObject);
    procedure RadioButtonWindowsClick(Sender: TObject);
    procedure RadioButtonGraphics32Click(Sender: TObject);
  private
    FFontEngine  : TPascalTypeFontEngineGDI;
    FFontEngine32: TPascalTypeFontEngineGR32;
    FFontScanner : TFontNameStorageScan;
    FFontArray   : array of TFontNameFile;
    FBitmap      : TBitmap;
    FText        : string;
    FFontSize    : Integer;
    FFontName    : string;
    procedure FontScannedHandler(Sender: TObject; FontFileName: TFilename;
      Font: TCustomPascalTypeStorage);
    procedure SetText(const Value: string);
    procedure SetFontSize(const Value: Integer);
    procedure SetFontName(const Value: string);
  protected
    procedure FontNameChanged; virtual;
    procedure FontSizeChanged; virtual;
    procedure RenderText; virtual;
    procedure TextChanged; virtual;
  public
    property Text: string read FText write SetText;
    property FontSize: Integer read FFontSize write SetFontSize;
    property FontName: string read FFontName write SetFontName;
  end;

var
  FmRenderDemo: TFmRenderDemo;

implementation

{$R *.dfm}

uses
  Math,
  Types,
  GR32,
  GR32_Polygons,
  GR32_Brushes,
  GR32_Paths;

procedure TFmRenderDemo.FormCreate(Sender: TObject);
begin
 SetCurrentDir(GetFontDirectory);

 // create bitmap buffer
 FBitmap := TBitmap.Create;

 // create FontEngine
 FFontEngine := TPascalTypeFontEngineGDI.Create;
 FFontEngine32 := TPascalTypeFontEngineGR32.Create;

 // set initial properties
 FBitmap.Canvas.Font.Size := StrToInt(ComboBoxFontSize.Text);
 FFontEngine.FontSize := StrToInt(ComboBoxFontSize.Text);
 FFontEngine32.FontSize := StrToInt(ComboBoxFontSize.Text);

 FFontScanner := TFontNameStorageScan.Create(True);
 with FFontScanner do
  begin
   OnFontScanned := FontScannedHandler;
   Resume;
  end;
end;

procedure TFmRenderDemo.FormDestroy(Sender: TObject);
begin
 // free FontEngine
 FreeAndNil(FFontEngine);
 FreeAndNil(FFontEngine32);

 with FFontScanner do
  begin
   Terminate;
   WaitFor;
  end;
 FreeAndNil(FFontScanner);
end;

procedure TFmRenderDemo.FormShow(Sender: TObject);
begin
 Text := EditText.Text;
end;

procedure TFmRenderDemo.PaintBoxPaint(Sender: TObject);
begin
 if Assigned(FBitmap)
  then PaintBox.Canvas.Draw(0, 0, FBitmap);
end;

procedure TFmRenderDemo.PanelTextResize(Sender: TObject);
begin
 if Assigned(FBitmap) then
  with FBitmap do
   begin
    Width := PaintBox.Width;
    Height := PaintBox.Height;
   end;
 RenderText;
end;

procedure TFmRenderDemo.TextChanged;
begin
 RenderText;
end;

procedure TFmRenderDemo.FontNameChanged;
var
  FontIndex : Integer;
begin
 FBitmap.Canvas.Font.Name := FFontName;
 for FontIndex := 0 to High(FFontArray) do
  if FFontArray[FontIndex].FullFontName = FFontName then
   begin
    FFontEngine.LoadFromFile(FFontArray[FontIndex].FileName);
    FFontEngine32.LoadFromFile(FFontArray[FontIndex].FileName);
    Break;
   end;

 RenderText;
end;

procedure TFmRenderDemo.FontSizeChanged;
begin
 FBitmap.Canvas.Font.Size := FFontSize;
 FFontEngine.FontSize := FFontSize;
 FFontEngine32.FontSize := FFontSize;
 RenderText;
end;

procedure TFmRenderDemo.RadioButtonGraphics32Click(Sender: TObject);
begin
 RenderText;
end;

procedure TFmRenderDemo.RadioButtonPascalTypeClick(Sender: TObject);
begin
 RenderText;
end;

procedure TFmRenderDemo.RadioButtonWindowsClick(Sender: TObject);
begin
 RenderText;
end;

procedure TFmRenderDemo.RenderText;
begin
 with FBitmap, Canvas do
  begin
   // clear bitmap
   Brush.Color := clWhite;
   FillRect(ClipRect);

   if RadioButtonWindows.Checked then
    begin
     with Font do
      begin
       Color := clBlack;
       Name := ComboBoxFont.Text;
       Font.Size := FFontSize;
      end;

     TextOut(0, 0, FText);
    end;

   if RadioButtonPascalType.Checked then
     FFontEngine.RenderText(FText, Canvas, 0, 0)
   else
   if RadioButtonGraphics32.Checked then
   begin
//     CBezierTolerance := 0.01;
     var Bitmap32 := TBitmap32.Create;
     try
       Bitmap32.SetSize(FBitmap.Width, FBitmap.Height);
       Bitmap32.Clear(clWhite32);
       var Canvas32 := TCanvas32.Create(Bitmap32);
       try
         var Brush32 := Canvas32.Brushes.Add(TSolidBrush) as TSolidBrush;
         Brush32.FillColor := clBlack32;
         Brush32.FillMode := pfNonZero;

         FFontEngine32.RenderText(FText, Canvas32);
       finally
         Canvas32.Free;
       end;
       FBitmap.Assign(Bitmap32);

     finally
       Bitmap32.Free;
     end;

   end;
  end;
 PaintBox.Invalidate;
end;

procedure TFmRenderDemo.SetFontName(const Value: string);
begin
 if FFontName <> Value then
  begin
   FFontName := Value;
   FontNameChanged;
  end;
end;

procedure TFmRenderDemo.SetFontSize(const Value: Integer);
begin
 if FFontSize <> Value then
  begin
   FFontSize := Value;
   FontSizeChanged;
  end;
end;

procedure TFmRenderDemo.SetText(const Value: string);
begin
 if FText <> Value then
  begin
   FText := Value;
   TextChanged;
  end;
end;

procedure TFmRenderDemo.ComboBoxFontChange(Sender: TObject);
begin
 if (ComboBoxFont.ItemIndex >= 0) and (ComboBoxFont.ItemIndex < Length(FFontArray)) then
   FontName := FFontArray[ComboBoxFont.ItemIndex].FullFontName;
end;

procedure TFmRenderDemo.ComboBoxFontSizeChange(Sender: TObject);
begin
 FontSize := StrToInt(ComboBoxFontSize.Text);
end;

procedure TFmRenderDemo.EditTextChange(Sender: TObject);
begin
 Text := EditText.Text;
end;

procedure TFmRenderDemo.FontScannedHandler(Sender: TObject; FontFileName: TFilename;
  Font: TCustomPascalTypeStorage);
var
  CurrentFontName : string;
begin
 // add font name to font combo box
 CurrentFontName := TCustomPascalTypeStorageSFNT(Font).FontName;
 ComboBoxFont.Items.Add(CurrentFontName);

 SetLength(FFontArray, Length(FFontArray) + 1);
 with FFontArray[High(FFontArray)] do
  begin
   FullFontName := CurrentFontName;
   FileName := FontFileName;
  end;

 // check if current font is the one requested
 if CurrentFontName = 'Arial' then
  begin
   ComboBoxFont.ItemIndex := ComboBoxFont.Items.Count - 1;
   FontName := CurrentFontName;
  end;
end;

end.
