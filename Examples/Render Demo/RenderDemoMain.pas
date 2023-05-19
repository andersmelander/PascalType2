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

{-$define IMAGE32} // Define to include Image32 text output
{-$define RASTERIZER_GDI} // Define to include GDI rasterizer

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
    LabelText: TLabel;
    GridPanel1: TGridPanel;
    PaintBoxWindows: TPaintBox;
    PaintBoxGDI: TPaintBox;
    PaintBoxGraphics32: TPaintBox;
    PaintBoxImage32: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBoxFontChange(Sender: TObject);
    procedure ComboBoxFontSizeChange(Sender: TObject);
    procedure EditTextChange(Sender: TObject);
    procedure PaintBoxWindowsPaint(Sender: TObject);
    procedure PaintBoxGDIPaint(Sender: TObject);
    procedure PaintBoxGraphics32Paint(Sender: TObject);
    procedure PaintBoxImage32Paint(Sender: TObject);
  private
    FFontFace: TPascalTypeFontFace;
    FRasterizerGDI  : TPascalTypeFontRasterizerGDI;
    FRasterizerGraphics32: TPascalTypeRasterizerGraphics32;
    FFontScanner : TFontNameScanner;
    FFontArray   : array of TFontNameFile;
    FText        : string;
    FFontSize    : Integer;
    FFontName    : string;
    FFontFilename: string;
    procedure FontScannedHandler(Sender: TObject; FontFileName: TFilename; Font: TCustomPascalTypeFontFacePersistent);
    procedure SetText(const Value: string);
    procedure SetFontSize(const Value: Integer);
    procedure SetFontName(const Value: string);
  protected
    procedure FontNameChanged; virtual;
    procedure FontSizeChanged; virtual;
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
{$ifdef IMAGE32}
  Img32,
  Img32.Text,
{$endif IMAGE32}
  GR32,
  GR32_Polygons,
  GR32_Brushes,
  GR32_Paths;

procedure TFmRenderDemo.FormCreate(Sender: TObject);
begin
{$ifndef IMAGE32}
  PaintBoxImage32.Free;
  GridPanel1.RowCollection.Items[3].Free;
  GridPanel1.RowCollection.EquallySplitPercentuals;
{$endif IMAGE32}
{$ifndef RASTERIZER_GDI}
  PaintBoxGDI.Free;
  GridPanel1.RowCollection.Items[1].Free;
  GridPanel1.RowCollection.EquallySplitPercentuals;
{$endif RASTERIZER_GDI}

  SetCurrentDir(GetFontDirectory);

  FFontFace := TPascalTypeFontFace.Create;

  // create rasterizers
  FRasterizerGDI := TPascalTypeFontRasterizerGDI.Create;
  FRasterizerGraphics32 := TPascalTypeRasterizerGraphics32.Create;

  FRasterizerGDI.FontFace := FFontFace;
  FRasterizerGraphics32.FontFace := FFontFace;

  // set initial properties
  FFontSize := StrToIntDef(ComboBoxFontSize.Text, 20);

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

procedure TFmRenderDemo.PaintBoxGDIPaint(Sender: TObject);
var
  Canvas: TCanvas;
begin
  Canvas := TPaintBox(Sender).Canvas;

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Canvas.ClipRect);

  FRasterizerGDI.FontSize := FFontSize;
  FRasterizerGDI.RenderText(FText, Canvas, 0, 0)
end;

procedure TFmRenderDemo.PaintBoxGraphics32Paint(Sender: TObject);
var
  Canvas: TCanvas;
  Canvas32: TCanvas32;
  Bitmap32: TBitmap32;
  BrushFill: TSolidBrush;
  BrushStroke: TStrokeBrush;
begin
  Canvas := TPaintBox(Sender).Canvas;

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Canvas.ClipRect);

  // CBezierTolerance := 0.01;
  Bitmap32 := TBitmap32.Create;
  try
    Bitmap32.SetSize(TPaintBox(Sender).Width, TPaintBox(Sender).Height);
    Bitmap32.Clear(clWhite32);
    Canvas32 := TCanvas32.Create(Bitmap32);
    try
      // (*
      BrushFill := Canvas32.Brushes.Add(TSolidBrush) as TSolidBrush;
      BrushFill.FillColor := clBlack32;
      BrushFill.FillMode := pfNonZero;
      // *)
      (*
        BrushStroke := Canvas32.Brushes.Add(TStrokeBrush) as TStrokeBrush;
        BrushStroke.FillColor := clTrRed32;
        BrushStroke.StrokeWidth := 1;
        BrushStroke.JoinStyle := jsMiter;
        BrushStroke.EndStyle := esButt;
      *)
      FRasterizerGraphics32.FontSize := 0; // TODO : We need to force a recalc of the scale. Changing the font doesn't notify the rasterizer.
      FRasterizerGraphics32.FontSize := FFontSize;
      FRasterizerGraphics32.RenderShapedText(FText, Canvas32);
    finally
      Canvas32.Free;
    end;
    Bitmap32.DrawTo(Canvas.Handle, 0, 0);

  finally
    Bitmap32.Free;
  end;
end;

procedure TFmRenderDemo.PaintBoxImage32Paint(Sender: TObject);
{$ifdef IMAGE32}
var
  Canvas: TCanvas;
  Image: TImage32;
  FontReader: TFontReader;
  Font: TFontCache;
{$endif IMAGE32}
begin
{$ifdef IMAGE32}
  Canvas := TPaintBox(Sender).Canvas;

  Image := TImage32.Create(nil);
  try
    FontReader := FontManager.LoadFromFile(FFontFilename);
    try
      Font := TFontCache.Create(FontReader);
      try
        Font.FontHeight :=  FFontSize * 96 {DPI} div 72;

        Font.InvertY := True;

        Image.SetSize(TPaintBox(Sender).Width, TPaintBox(Sender).Height, clWhite32);

        Img32.Text.DrawText(Image, 0, Ceil(Font.LineHeight), FText, Font, clBlack32, True);

        Image.CopyToDc(Canvas.Handle, 0, 0, False);

      finally
        Font.Free;
      end;
    finally
      FontReader.Free;
    end;
  finally
    Image.Free;
  end;
{$endif IMAGE32}
end;

procedure TFmRenderDemo.PaintBoxWindowsPaint(Sender: TObject);
var
  Canvas: TCanvas;
begin
  Canvas := TPaintBox(Sender).Canvas;

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Canvas.ClipRect);

  Canvas.Font.Color := clBlack;
  Canvas.Font.Name := FFontName;
  Canvas.Font.Size := FFontSize;

  Canvas.TextOut(0, 0, FText);
end;

procedure TFmRenderDemo.TextChanged;
begin
  Invalidate;
end;

procedure TFmRenderDemo.FontNameChanged;
var
  FontIndex : Integer;
begin
  for FontIndex := 0 to High(FFontArray) do
    if FFontArray[FontIndex].FullFontName = FFontName then
    begin
      FFontFilename := FFontArray[FontIndex].FileName;
      FFontFace.LoadFromFile(FFontFilename);
      Break;
    end;

  Invalidate;
end;

procedure TFmRenderDemo.FontSizeChanged;
begin
  Invalidate;
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
