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
  RenderDemoFontNameScanner, Vcl.Menus, System.Actions, Vcl.ActnList;

{$I ..\..\Source\PT_Compiler.inc}

{$define IMAGE32} // Define to include Image32 text output
{-$define RASTERIZER_GDI} // Define to include GDI rasterizer
{$define WIN_ANTIALIAS} // Define to have Windows TextOut anti-aliased

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
    PanelGDI: TPanel;
    PaintBox1: TPaintBox;
    PaintBoxWindows: TPaintBox;
    PanelPascalTypeGDI: TPanel;
    PaintBox2: TPaintBox;
    PaintBoxGDI: TPaintBox;
    PanelPascalTypeGraphics32: TPanel;
    PaintBox3: TPaintBox;
    PaintBoxGraphics32: TPaintBox;
    PanelImage32: TPanel;
    PaintBox4: TPaintBox;
    PaintBoxImage32: TPaintBox;
    ComboBoxTestCase: TComboBox;
    Label1: TLabel;
    ActionList: TActionList;
    ActionColor: TAction;
    PopupMenu: TPopupMenu;
    MenuItemColor: TMenuItem;
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
    procedure PaintBox1Paint(Sender: TObject);
    procedure ComboBoxTestCaseChange(Sender: TObject);
    procedure ActionColorExecute(Sender: TObject);
  private
    FFontFace: TPascalTypeFontFace;
    FRasterizerGDI  : TPascalTypeFontRasterizerGDI;
    FRasterizerGraphics32: TPascalTypeRasterizerGraphics32;
    FFontScanner : TFontNameScanner;
    FUserFontScanner : TFontNameScanner;
    FFontArray   : array of TFontNameFile;
    FText        : string;
    FFontSize    : Integer;
    FFontName    : string;
    FFontFilename: string;
    FLanguage: TTableType;
    FScript: TTableType;
    FDirection: TPascalTypeDirection;
    procedure FontScannedHandler(Sender: TObject; const FontFileName: string; Font: TCustomPascalTypeFontFacePersistent);
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
    property Script: TTableType read FScript;
    property Language: TTableType read FLanguage;
    property Direction: TPascalTypeDirection read FDirection;
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
  GR32_Paths,
  PascalType.Platform.Windows,
  PascalType.Shaper,
  PascalType.Shaper.Script.Default,
  PascalType.GlyphString;

type
  TTestCase = record
    Name: string;
    FontName: string;
    Script: TTableType;
    Language: TTableType;
    Direction: TPascalTypeDirection;
    Text: string;
  end;

const
  TestCases: array[0..16] of TTestCase = (
    (Name: 'Default'; FontName: 'Arial'; Text: 'PascalType Render Demo'),
    (Name: 'GSUB, Single, Single/frac'; FontName: 'Cascadia Mono Regular'; Text: '123/456! ½ 8'#$2044'9'),
    (Name: 'GSUB, Single, List'; FontName: 'Candara'; Text: #$0386#$038C#$038E#$038F),
    (Name: 'GSUB, Ligature'; FontName: 'Arabic Typesetting'; Text: 'ff fi ffi ft fft'),
    (Name: 'GSUB, Multiple'; FontName: 'Microsoft Sans Serif'; Script: (AsAnsiChar: 'thai'); Text: #$0E01#$0E33#$0E44#$0E23' '#$0E19#$0E33),
    (Name: 'GSUB, Chained, Simple'; FontName: 'Monoid Regular'; Text: ' _/¯\_/¯\_'),
    (Name: 'GSUB, Chained, Class'; FontName: 'Segoe UI Variable'; Text: 'i¨ j¨ i´'),
    (Name: 'GSUB, Chained, Coverage'; FontName: 'Segoe UI Variable'; Text: '1/2 3/4 123/456'),
    (Name: 'GPOS, Pair, Single'; FontName: 'Arial'; Text: 'LTAVAWA 11.Y.F'),
    (Name: 'GPOS, Pair, Class'; FontName: 'Roboto Regular'; Text: 'P, PA '#$0393'm'),
    (Name: 'GPOS, Cursive'; FontName: 'Arabic Typesetting'; Script: (AsAnsiChar: 'arab'); Direction: dirRightToLeft; Text: 'نَجلاء'),
//    (Name: 'GPOS, Cursive'; FontName: 'Arabic Typesetting'; Script: (AsAnsiChar: 'arab'); Direction: dirRightToLeft; Text: #$FE98#$067C#$067D), // Incorrect testcase; No cursive attachment
    (Name: 'GPOS, MarkToBase'; FontName: 'Segoe UI'; Text: #$1EAA' '#$1EEE' '#$0041#$0304#$0301#$0020#$0141#$006F#$0304#$0067#$0069#$0304#$0301#$0020#$007A#$006F#$0328#$0304#$0301#$007A#$0065),
    (Name: 'GPOS, MarkToMark'; FontName: 'Arabic Typesetting'; Text: 'A'#$0327#$0323' A'#$0323#$0327),//#$03BC#$03B1#$0390#$03C3#$03C4#$03C1#$03BF#$03C2), // Segoe UI appears to have a bug with this test case
    (Name: 'GPOS, MarkToLigature'; FontName: 'Arabic Typesetting'; Script: (AsAnsiChar: 'arab'); Direction: dirRightToLeft; Text: #$FEF8#$0612'  '#$0644#$0627#$0654#$0612), // #$FEF8 is a ligature for #$0644#$0627#$0654
    (Name: 'Table: kern'; FontName: 'Verdana'; Text: 'LTAVAWA 11.LYT.'),
    (Name: 'Unicode normalization'; FontName: 'Arial'; Text: 'æøåÆØÅ'),
    (Name: 'Composite glyphs'; FontName: 'Segoe UI'; Text: '½äâåéò')
  );

const
  GlyphPalette: TArray<TColor> = [$233BC2, $529cc7, $52DAEA, $3CC003, $BE9A57, $D76E97];

var
  OneOverDPIScale: Double;

procedure GetDPIScale;
begin
  OneOverDPIScale := Screen.PixelsPerInch / 96;
end;

function _DPIAware(AValue: Integer): Integer; overload;
begin
  Result := Round(AValue * OneOverDPIScale);
end;

function _DPIAware(AValue: Double): Double; overload;
begin
  Result := AValue * OneOverDPIScale;
end;

procedure TFmRenderDemo.FormCreate(Sender: TObject);
var
  TestCase: TTestCase;
begin
{$ifndef IMAGE32}
  PanelImage32.Free;
  GridPanel1.RowCollection.Items[3].Free;
  GridPanel1.RowCollection.EquallySplitPercentuals;
{$endif IMAGE32}
{$ifndef RASTERIZER_GDI}
  PanelPascalTypeGDI.Free;
  GridPanel1.RowCollection.Items[1].Free;
  GridPanel1.RowCollection.EquallySplitPercentuals;
{$endif RASTERIZER_GDI}

  FFontFace := TPascalTypeFontFace.Create;

  // create rasterizers
  FRasterizerGDI := TPascalTypeFontRasterizerGDI.Create;
  FRasterizerGraphics32 := TPascalTypeRasterizerGraphics32.Create;

  FRasterizerGDI.FontFace := FFontFace;
  FRasterizerGraphics32.FontFace := FFontFace;

  // set initial properties
  FFontSize := StrToIntDef(ComboBoxFontSize.Text, 36);

  FFontScanner := TFontNameScanner.Create;
  FFontScanner.OnFontScanned := FontScannedHandler;
  FFontScanner.Start;

  FUserFontScanner := TFontNameScanner.Create(GetUserFontDirectory+'\*.ttf');
  FUserFontScanner.OnFontScanned := FontScannedHandler;
  FUserFontScanner.Start;

  for TestCase in TestCases do
    ComboBoxTestCase.Items.Add(TestCase.Name);
end;

procedure TFmRenderDemo.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FRasterizerGDI);
  FreeAndNil(FRasterizerGraphics32);
  FreeAndNil(FFontFace);

  FFontScanner.Terminate;
  FFontScanner.WaitFor;
  FFontScanner.Free;

  FUserFontScanner.Terminate;
  FUserFontScanner.WaitFor;
  FUserFontScanner.Free;
end;

procedure TFmRenderDemo.FormShow(Sender: TObject);
begin
  Text := EditText.Text;
end;

procedure TFmRenderDemo.PaintBox1Paint(Sender: TObject);
var
  lf: LOGFONT; // Windows native font structure
begin
  TPaintBox(Sender).Canvas.Brush.Style := bsClear;
  lf := Default(LOGFONT);
  lf.lfHeight := 12;
  lf.lfEscapement := 10 * 90;
  lf.lfOrientation := 10 * 90;
  lf.lfCharSet := DEFAULT_CHARSET;
  StrCopy(lf.lfFaceName, 'Arial');

  TPaintBox(Sender).Canvas.Font.Handle := CreateFontIndirect(lf);
  TPaintBox(Sender).Canvas.TextOut(0, TPaintBox(Sender).Height, TPanel(TPaintBox(Sender).Parent).Caption);
end;

procedure TFmRenderDemo.PaintBoxGDIPaint(Sender: TObject);
var
  Canvas: TCanvas;
begin
  Canvas := TPaintBox(Sender).Canvas;

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Canvas.ClipRect);

  FRasterizerGDI.FontSize := _DPIAware(FFontSize);
  FRasterizerGDI.RenderText(FText, Canvas, 0, 0)
end;

procedure TFmRenderDemo.PaintBoxGraphics32Paint(Sender: TObject);
var
  Canvas: TCanvas;
  Canvas32: TCanvas32;
  Bitmap32: TBitmap32;
  ShaperClass: TPascalTypeShaperClass;
  Shaper: TPascalTypeShaper;
  ShapedText: TPascalTypeGlyphString;
  i: integer;
  CursorPos: TFloatPoint;
{$define FILL_PATH}
{-$define STROKE_PATH}
{$ifdef FILL_PATH}
  BrushFill: TSolidBrush;
{$endif FILL_PATH}
{$ifdef STROKE_PATH}
  BrushStroke: TStrokeBrush;
{$endif STROKE_PATH}
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
{$ifdef FILL_PATH}
      BrushFill := Canvas32.Brushes.Add(TSolidBrush) as TSolidBrush;
      BrushFill.FillColor := clBlack32;
      BrushFill.FillMode := pfNonZero;
{$endif FILL_PATH}
{$ifdef STROKE_PATH}
      BrushStroke := Canvas32.Brushes.Add(TStrokeBrush) as TStrokeBrush;
      BrushStroke.FillColor := clTrRed32;
      BrushStroke.StrokeWidth := 1;
      BrushStroke.JoinStyle := jsMiter;
      BrushStroke.EndStyle := esButt;
{$endif STROKE_PATH}
      FRasterizerGraphics32.FontSize := 0; // TODO : We need to force a recalc of the scale. Changing the font doesn't notify the rasterizer.
      FRasterizerGraphics32.FontSize := _DPIAware(FFontSize);

      // TODO : Detect script from text
      ShaperClass := TPascalTypeShaper.GetShaperForScript(FScript);
      Shaper := ShaperClass.Create(FFontFace);
      try
        // TODO : Test only. Enable 'liga' optional feature for test purpose
        Shaper.Features['liga'] := True;
        Shaper.Features.EnableAll := True; // TODO : This currently does nothing

        Shaper.Language := FLanguage;
        Shaper.Script := FScript;
        Shaper.Direction := FDirection;

        ShapedText := Shaper.Shape(FText);
        try

          if (ActionColor.Checked) then
          begin
            CursorPos.X := 0;
            CursorPos.Y := 0;

            for i := 0 to ShapedText.Count-1 do
            begin

              BrushFill.FillColor := Color32(GlyphPalette[i mod Length(GlyphPalette)]);
              FRasterizerGraphics32.RenderShapedGlyph(ShapedText[i], Canvas32, CursorPos.X, CursorPos.Y);

            end;
          end else
            FRasterizerGraphics32.RenderShapedText(ShapedText, Canvas32);

        finally
          ShapedText.Free;
        end;

      finally
        Shaper.Free;
      end;

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
  if (FFontFilename = '') then
    exit;

  Canvas := TPaintBox(Sender).Canvas;

  Image := TImage32.Create(nil);
  try
    FontReader := FontManager.LoadFromFile(FFontFilename);
    try
      Font := TFontCache.Create(FontReader);
      try
        Font.FontHeight :=  _DPIAware(FFontSize);

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
{$ifdef WIN_ANTIALIAS}
var
  lf : TLogFont;
  FontHandle: HFONT;
{$endif WIN_ANTIALIAS}
begin
  Canvas := TPaintBox(Sender).Canvas;

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Canvas.ClipRect);

  Canvas.Font.Color := clBlack;
{$ifdef WIN_ANTIALIAS}
  lf := Default(TLogFont);
  lf.lfHeight := -MulDiv(FFontSize, Canvas.Font.PixelsPerInch, 72);
  lf.lfWeight := FW_NORMAL;
  lf.lfCharSet := Font.Charset;
  StrPLCopy(lf.lfFaceName, FFontName, LF_FACESIZE);
  lf.lfQuality := ANTIALIASED_QUALITY;
//  lf.lfQuality := CLEARTYPE_QUALITY;
//  lf.lfQuality := CLEARTYPE_NATURAL_QUALITY;
  lf.lfOutPrecision := OUT_TT_ONLY_PRECIS;
  lf.lfClipPrecision := CLIP_DEFAULT_PRECIS;
  lf.lfPitchAndFamily := DEFAULT_PITCH;

  FontHandle := CreateFontIndirect(lf);
  if (FontHandle = 0) then
    RaiseLastOSError;

  Canvas.Font.Handle := FontHandle;
{$else WIN_ANTIALIAS}
  Canvas.Font.Name := FFontName;
  Canvas.Font.Size := FFontSize;
{$endif WIN_ANTIALIAS}

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
  Invalidate;

  for FontIndex := 0 to High(FFontArray) do
    if FFontArray[FontIndex].FullFontName = FFontName then
    begin
      FFontFilename := FFontArray[FontIndex].FileName;
      FFontFace.LoadFromFile(FFontFilename);
      Break;
    end;
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

procedure TFmRenderDemo.ActionColorExecute(Sender: TObject);
begin
  Invalidate;
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

procedure TFmRenderDemo.ComboBoxTestCaseChange(Sender: TObject);
var
  TestCase: TTestCase;
begin
  if (TComboBox(Sender).ItemIndex = -1) then
    exit;

  TestCase := TestCases[TComboBox(Sender).ItemIndex];

  EditText.Text := TestCase.Text;
  ComboBoxFont.Text := TestCase.FontName;
  FontName := TestCase.FontName;
  FLanguage := TestCase.Language;
  FScript := TestCase.Script;
  FDirection := TestCase.Direction;

  Invalidate;
end;

procedure TFmRenderDemo.EditTextChange(Sender: TObject);
begin
  Text := EditText.Text;
end;

procedure TFmRenderDemo.FontScannedHandler(Sender: TObject; const FontFileName: string;
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

initialization
  GetDPIScale;
end.
