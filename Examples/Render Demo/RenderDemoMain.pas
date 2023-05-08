unit RenderDemoMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  PT_Types,
  PT_Classes,
  PT_Tables,
  PascalType.FontFace,
  PascalType.FontFace.SFNT,
  PascalType.Rasterizer.GDI,
  PascalType.Rasterizer.Graphics32,
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
    FFontFace: TPascalTypeFontFace;
    FRasterizerGDI  : TPascalTypeFontRasterizerGDI;
    FRasterizerGraphics32: TPascalTypeRasterizerGraphics32;
    FFontScanner : TFontNameScanner;
    FFontArray   : array of TFontNameFile;
    FBitmap      : TBitmap;
    FText        : string;
    FFontSize    : Integer;
    FFontName    : string;
    procedure FontScannedHandler(Sender: TObject; FontFileName: TFilename; Font: TCustomPascalTypeFontFacePersistent);
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

  FFontFace := TPascalTypeFontFace.Create;

  // create rasterizers
  FRasterizerGDI := TPascalTypeFontRasterizerGDI.Create;
  FRasterizerGraphics32 := TPascalTypeRasterizerGraphics32.Create;

  FRasterizerGDI.FontFace := FFontFace;
  FRasterizerGraphics32.FontFace := FFontFace;

  // set initial properties
  FBitmap.Canvas.Font.Size := StrToInt(ComboBoxFontSize.Text);
  FRasterizerGDI.FontSize := StrToInt(ComboBoxFontSize.Text);
  FRasterizerGraphics32.FontSize := StrToInt(ComboBoxFontSize.Text);

  FFontScanner := TFontNameScanner.Create(True);
  with FFontScanner do
  begin
    OnFontScanned := FontScannedHandler;
    Start;
  end;
end;

procedure TFmRenderDemo.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FRasterizerGDI);
  FreeAndNil(FRasterizerGraphics32);
  FreeAndNil(FFontFace);

  FBitmap.Free;

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
      FFontFace.LoadFromFile(FFontArray[FontIndex].FileName);
      Break;
    end;

  RenderText;
end;

procedure TFmRenderDemo.FontSizeChanged;
begin
 FBitmap.Canvas.Font.Size := FFontSize;
 FRasterizerGDI.FontSize := FFontSize;
 FRasterizerGraphics32.FontSize := FFontSize;
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
var
  Bitmap32: TBitmap32;
  Canvas32: TCanvas32;
  BrushFill: TSolidBrush;
  BrushStroke: TStrokeBrush;
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
     FRasterizerGDI.RenderText(FText, Canvas, 0, 0)
   else
   if RadioButtonGraphics32.Checked then
   begin
//     CBezierTolerance := 0.01;
     Bitmap32 := TBitmap32.Create;
     try
       Bitmap32.SetSize(FBitmap.Width, FBitmap.Height);
       Bitmap32.Clear(clWhite32);
       Canvas32 := TCanvas32.Create(Bitmap32);
       try
//(*
         BrushFill := Canvas32.Brushes.Add(TSolidBrush) as TSolidBrush;
         BrushFill.FillColor := clBlack32;
         BrushFill.FillMode := pfNonZero;
//*)
//(*
         BrushStroke := Canvas32.Brushes.Add(TStrokeBrush) as TStrokeBrush;
         BrushStroke.FillColor := clTrRed32;
         BrushStroke.StrokeWidth := 1;
         BrushStroke.JoinStyle := jsMiter;
         BrushStroke.EndStyle := esButt;
//*)
         FRasterizerGraphics32.RenderShapedText(FText, Canvas32);
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
  Font: TCustomPascalTypeFontFacePersistent);
var
  CurrentFontName : string;
begin
 // add font name to font combo box
 CurrentFontName := TCustomPascalTypeFontFace(Font).FontName;
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
