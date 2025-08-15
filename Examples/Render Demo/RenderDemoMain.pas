unit RenderDemoMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Vcl.Menus, System.Actions, Vcl.ActnList,
  PascalType.Types,
  PascalType.Classes,
  PascalType.Tables,
  PascalType.FontFace,
  PascalType.FontFace.SFNT,
  PascalType.Shaper.Plan,
  PascalType.Renderer,
  PascalType.Painter,
  PascalType.Painter.GDI,
  PascalType.Painter.Graphics32,
  RenderDemoFontNameScanner;

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
    GridPanelSamples: TGridPanel;
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
    ActionList: TActionList;
    ActionColor: TAction;
    PopupMenu: TPopupMenu;
    MenuItemColor: TMenuItem;
    ActionPaintPoints: TAction;
    Paintcurvecontrolpoints1: TMenuItem;
    N1: TMenuItem;
    ActionFeaturesClear: TAction;
    Clearallfeatures1: TMenuItem;
    FlowPanelFeatures: TFlowPanel;
    PanelTop: TPanel;
    LabelText: TLabel;
    EditText: TEdit;
    Label1: TLabel;
    ComboBoxTestCase: TComboBox;
    LabelFont: TLabel;
    ComboBoxFont: TComboBox;
    LabelFontSize: TLabel;
    ComboBoxFontSize: TComboBox;
    PanelMain: TPanel;
    SplitterFeatures: TSplitter;
    ActionPaintMetrics: TAction;
    Drawglyphmetrics1: TMenuItem;
    MenuItemRenderer: TMenuItem;
    MenuItemRendererPascalTypeGDI: TMenuItem;
    MenuItemRendererGDI: TMenuItem;
    MenuItemRendererPascalTypeGraphics32: TMenuItem;
    MenuItemRendererImage32: TMenuItem;
    N2: TMenuItem;
    ButtonLoad: TButton;
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
    procedure ActionGenericExecute(Sender: TObject);
    procedure ActionFeaturesClearExecute(Sender: TObject);
    procedure MenuItemRendererClick(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
  private
    FFontFace: TPascalTypeFontFace;
    FRenderer: TPascalTypeRenderer;
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
    FHasAvailableFeatures: boolean;
    FFeatures: TPascalTypeShaperFeatures;
    FPlannedFeatures: TPascalTypeFeatures;
    procedure FontScannedHandler(Sender: TObject; const FontFileName: string; Font: TCustomPascalTypeFontFacePersistent);
    procedure SetText(const Value: string);
    procedure SetFontSize(const Value: Integer);
    procedure SetFontName(const Value: string);
    procedure ButtonFeatureClick(Sender: TObject);
  protected
    procedure LoadFont(Filename: string); // not "const" on purpose
    procedure FontNameChanged;
    procedure FontSizeChanged;
    procedure TextChanged;
    procedure UpdateAvailableFeatures;
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
  System.Math,
  System.Types,
  System.UITypes,
  System.IOUtils,
{$ifdef IMAGE32}
  Img32,
  Img32.Text,
{$endif IMAGE32}
  GR32,
  GR32_Polygons,
  GR32_Brushes,
  GR32_Paths,
  PascalType.Unicode,
  PascalType.Platform.Windows,
  PascalType.Shaper,
  PascalType.Shaper.Script.Default,
  PascalType.GlyphString,
  PascalType.Tables.OpenType.Feature,
  PascalType.Tables.OpenType.Common,
  RenderDemo.Controls.FeatureButton;

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
  TestCases: array[0..21] of TTestCase = (
    (Name: 'Default'; FontName: 'Arial'; Text: 'PascalType Render Demo'),
    (Name: 'GSUB, Single, Single/frac'; FontName: 'Calibri'; Text: '123'#$2044'456! ½ 1/2 1'#$2044'2 12 OS/2'),
    (Name: 'GSUB, Single, List'; FontName: 'Candara'; Script: (AsAnsiChar: 'latn'); Text: #$0386#$038C#$038E#$038F), // Script is detected as "grek" (Greek) but font appears to have problems with that
//    (Name: 'GSUB, Single, List'; FontName: 'Candara'; Text: #$0386#$038C#$038E#$038F), // Script is detected as grek but font appears to have problems with that
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
    (Name: 'Feature: calt'; FontName: 'Cascadia Code Regular'; Text: '⁄⁄ --> => ->> <==> <!-- |--|--| == != === !== >= <= <><|<||<|||<~> <~ www ::: ... ***'),
    (Name: 'Script: Arabic'; FontName: 'Arabic Typesetting'; Text: 'إِنَّ ٱلَّذِينَ كَفَرُوا۟ سَوَآءٌ عَلَيْهِمْ ءَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ'),
    (Name: 'Script: Hangul'; FontName: 'Arial Unicode MS'; Text: '모든 인류 구성원의 천부의 존엄성과 동등하고 양도할 수 없는 권리를 인정하는'),
    (Name: 'Unicode normalization'; FontName: 'Arial'; Text: 'æøåÆØÅ'),
    (Name: 'Composite glyphs'; FontName: 'Segoe UI'; Text: '½äâåéò'),
    (Name: 'Color emojis'; FontName: 'Segoe UI Emoji'; Text: ':-) + variation'#$263A#$FE0F' Another :-)'#$1f60a' Brown Thumbs-up'#$1f44d#$1f3ff' Mind blown'#$1f92f' <3'#$2764#$FE0F' Duck'#$1F986),
    (Name: 'Baseline'; FontName: 'Leipzig'; Text: ' '+#$EA64#$E050#$E051#$E052#$E053#$E054#$E055)
  );

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
  GridPanelSamples.RowCollection.Items[MenuItemRendererPascalTypeGDI.Tag].SizeStyle := ssAbsolute;
  GridPanelSamples.RowCollection.Items[MenuItemRendererPascalTypeGDI.Tag].Value := 0;
  GridPanelSamples.RowCollection.EquallySplitPercentuals;
{$ifndef IMAGE32}
  PanelImage32.Free;
  GridPanel1.RowCollection.Items[3].Free;
  GridPanel1.RowCollection.EquallySplitPercentuals;
  MenuItemRendererImage32.Free;
{$endif IMAGE32}

  FFeatures := TPascalTypeShaperFeatures.Create;

  FFontFace := TPascalTypeFontFace.Create;

  // create rasterizers
  FRenderer := TPascalTypeRenderer.Create;
  FRenderer.FontFace := FFontFace;
  FRenderer.PixelPerInch := Screen.PixelsPerInch;
  FRenderer.HorizontalOrigin := hoZero;
  FRenderer.VerticalOrigin := voZero;
  FRenderer.Options := [roColor];

  // set initial properties
  FontSize := StrToIntDef(ComboBoxFontSize.Text, 36);

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
  FreeAndNil(FRenderer);
  FreeAndNil(FFontFace);

  FFontScanner.Terminate;
  FFontScanner.WaitFor;
  FFontScanner.Free;
  FFeatures.Free;

  FUserFontScanner.Terminate;
  FUserFontScanner.WaitFor;
  FUserFontScanner.Free;
end;

procedure TFmRenderDemo.FormShow(Sender: TObject);
begin
  Text := EditText.Text;
end;

procedure TFmRenderDemo.MenuItemRendererClick(Sender: TObject);
begin
  if (TMenuItem(Sender).Checked) then
  begin
    GridPanelSamples.RowCollection.Items[TMenuItem(Sender).Tag].SizeStyle := ssPercent;
  end else
  begin
    GridPanelSamples.RowCollection.Items[TMenuItem(Sender).Tag].SizeStyle := ssAbsolute;
    GridPanelSamples.RowCollection.Items[TMenuItem(Sender).Tag].Value := 0;
  end;
  GridPanelSamples.RowCollection.EquallySplitPercentuals;
end;

procedure TFmRenderDemo.ButtonFeatureClick(Sender: TObject);
var
  Tag: TTableType;
  State: TFeatureButtonState;
begin
  Tag := TFeatureButton(Sender).Tag;
  State := TFeatureButton(Sender).State;

  case State of
    fbsNone:
      FFeatures.Remove(Tag.AsAnsiChar);

    fbsEnabled:
      FFeatures[Tag.AsAnsiChar] := True;

    fbsDisabled:
      FFeatures[Tag.AsAnsiChar] := False;
  end;

  Invalidate;
end;

procedure TFmRenderDemo.ButtonLoadClick(Sender: TObject);
begin
  var Folder := '';
  var Filename := '';

  if (FFontFilename <> '') then
  begin
    Folder := TPath.GetDirectoryName(FFontFilename);
    Filename := TPath.GetFileName(FFontFilename);
  end;

  if (Folder = '') then
    Folder := TPath.GetDirectoryName(Application.ExeName);

  if (PromptForFileName(Filename, '*.ttf', '', 'Select font file', Folder)) then
    LoadFont(Filename);
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
  TPaintBox(Sender).Canvas.TextOut(4, TPaintBox(Sender).Height-4, TPanel(TPaintBox(Sender).Parent).Caption);
end;

procedure TFmRenderDemo.PaintBoxGDIPaint(Sender: TObject);
var
  Canvas: TCanvas;
  Painter: IPascalTypePainter;
begin
  Canvas := TPaintBox(Sender).Canvas;

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Canvas.ClipRect);

  Painter := TPascalTypePainterGDI.Create(Canvas);

  FRenderer.RenderText(FText, Painter);

  if (ActionPaintPoints.Checked) then
  begin
    FRenderer.Options := FRenderer.Options + [roPoints];

    FRenderer.RenderText(FText, Painter);

    FRenderer.Options := FRenderer.Options - [roPoints];
  end;
end;

procedure TFmRenderDemo.PaintBoxGraphics32Paint(Sender: TObject);
var
  Canvas: TCanvas;
  Painter: IPascalTypePainter;
  Bitmap32: TBitmap32;
  Script: TTableType;
  Shaper: TPascalTypeShaper;
  UTF32: TPascalTypeCodePoints;
  ShapedText: TPascalTypeGlyphString;
  Tag: PascalType.Types.TTableName;
  SaveOptions: TPascalTypeRenderOptions;
begin
  Canvas := TPaintBox(Sender).Canvas;

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Canvas.ClipRect);

//  CBezierTolerance := 0.01;
  Bitmap32 := TBitmap32.Create;
  try
    Bitmap32.SetSize(TPaintBox(Sender).Width, TPaintBox(Sender).Height);
    Bitmap32.Clear(clWhite32);

    Painter := TPascalTypePainterBitmap32.Create(Bitmap32);
    try
      // Convert to UTF32 so we only do it once
      UTF32 := PascalTypeUnicode.UTF16ToUTF32(FText);

      // Detect script from input text if it hasn't been explicitly specified.
      Script := FScript;
      if (Script.AsCardinal = 0) then
        Script := TPascalTypeShaper.DetectScript(UTF32);

      // Get a shaper that can handle the script
      Shaper := TPascalTypeShaper.CreateShaper(FFontFace, Script);
      try
        for Tag in FFeatures do
          Shaper.Features[Tag] := FFeatures[Tag];

        Shaper.Language := FLanguage;
        Shaper.Script := Script;
        Shaper.Direction := FDirection;

        ShapedText := Shaper.Shape(UTF32);
        try

          if (ActionPaintMetrics.Checked) then
            FRenderer.Options := FRenderer.Options + [roMetrics]
          else
            FRenderer.Options := FRenderer.Options - [roMetrics];

          FRenderer.RenderShapedText(ShapedText, Painter);

          if (ActionPaintPoints.Checked) then
          begin
            SaveOptions := FRenderer.Options;
            FRenderer.Options := FRenderer.Options + [roPoints] - [roMetrics];

            FRenderer.RenderShapedText(ShapedText, Painter);

            FRenderer.Options := SaveOptions;
          end;
        finally
          ShapedText.Free;
        end;

      finally
        Shaper.Free;
      end;

    finally
      Painter := nil;
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
        Font.FontHeight :=  _DPIAware(FFontSize * 96 div 72);

        Font.InvertY := True;

        Image.SetSize(TPaintBox(Sender).Width, TPaintBox(Sender).Height, clWhite32);

        Img32.Text.DrawText(Image, 0, Font.Ascent, FText, Font, clBlack32, True);

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
  lf.lfHeight := -_DPIAware(FFontSize * 96 div 72);
//  lf.lfHeight := -MulDiv(FFontSize, Canvas.Font.PixelsPerInch, 72);
  lf.lfWeight := FW_NORMAL;
  lf.lfCharSet := Font.Charset;
  StrPLCopy(lf.lfFaceName, FFontName, LF_FACESIZE);
  lf.lfQuality := ANTIALIASED_QUALITY;
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
  FHasAvailableFeatures := False;
end;

type
  TPascalTypeShaperCracker = class(TPascalTypeShaper);

procedure TFmRenderDemo.UpdateAvailableFeatures;
var
  Script: TTableType;
  UTF32: TPascalTypeCodePoints;
  Table: TCustomOpenTypeCommonTable;
  AvailableFeatures: TPascalTypeFeatures;
  Tag: PascalType.Types.TTableName;
  i: integer;
  FeatureTableClass: TOpenTypeFeatureTableClass;
  FeatureButton: TFeatureButton;
  Shaper: TPascalTypeShaper;
  Plan: TPascalTypeShapingPlan;
  DummyGlyphs: TPascalTypeGlyphString;
  DummyFeatures: TPascalTypeShaperFeatures;
begin
  if (FHasAvailableFeatures) then
    exit;
  FHasAvailableFeatures := True;

  // Detect script from input text if it hasn't been explicitly specified.
  Script := FScript;
  if (Script.AsCardinal = 0) then
  begin
    UTF32 := PascalTypeUnicode.UTF16ToUTF32(FText);
    Script := TPascalTypeShaper.DetectScript(UTF32);
  end;

  // Get available features from GPOS and GSUB tables
  AvailableFeatures := [];
  Table := FFontFace.GetTableByTableType('GSUB') as TCustomOpenTypeCommonTable;
  if (Table <> nil) then
    AvailableFeatures := AvailableFeatures + Table.GetAvailableFeatures(Script, FLanguage);

  Table := FFontFace.GetTableByTableType('GPOS') as TCustomOpenTypeCommonTable;
  if (Table <> nil) then
    AvailableFeatures := AvailableFeatures + Table.GetAvailableFeatures(Script, FLanguage);

  // If we do not have a 'kern' lookup, but we have an old-style kern table, then
  // we indicate that we are able to apply the 'kern' feature.
  if (not AvailableFeatures.Contains('kern')) and (FFontFace.GetTableByTableType('kern') <> nil) then
    AvailableFeatures.Add('kern');

  // Feature menuitems are marked with Tag<>0. Get rid of the old ones
  for i := PopupMenu.Items.Count-1 downto 0 do
    if (PopupMenu.Items[i].Tag <> 0) then
      PopupMenu.Items[i].Free;
  for i := FlowPanelFeatures.ControlCount-1 downto 0 do
    FlowPanelFeatures.Controls[i].Free;

  // Intersect the existing feature selection with the available ones
  for Tag in FFeatures do
    if (not AvailableFeatures[Tag]) then
      FFeatures.Remove(Tag);

  // Create a shaping plan so we can get access to the default plan features
  Shaper := TPascalTypeShaper.CreateShaper(FFontFace, Script);
  try
    Plan := TPascalTypeShaperCracker(Shaper).CreateShapingPlan;
    try
      DummyGlyphs := Shaper.TextToGlyphs('');
      try
        DummyFeatures := TPascalTypeShaperFeatures.Create;
        try

          TPascalTypeShaperCracker(Shaper).SetupPlan(Plan, DummyGlyphs, DummyFeatures);
          FPlannedFeatures.Assign(Plan.GlobalFeatures);

        finally
          DummyFeatures.Free;
        end;

      finally
        DummyGlyphs.Free;
      end;
    finally
      Plan.Free;
    end;
  finally
    Shaper.Free;
  end;

  // Create menuitem for available features
  for Tag in AvailableFeatures do
  begin
    FeatureButton := TFeatureButton.Create(Self);

    FeatureButton.Font.Size := 13;
    if (Tag in FPlannedFeatures) then
      FeatureButton.Font.Style := [TFontStyle.fsBold];

    FeatureButton.Margins.Left := 2;
    FeatureButton.Margins.Right := 2;
    FeatureButton.Margins.Top := 2;
    FeatureButton.Margins.Bottom := 2;
    FeatureButton.AlignWithMargins := True;

    FeatureButton.Tag := Tag;
    FeatureButton.Caption := string(Tag);
    FeatureTableClass := FindFeatureByType(TTableType(Tag));
    if (FeatureTableClass <> nil) then
      FeatureButton.Hint := FeatureTableClass.DisplayName;
    if (FFeatures.HasValue(Tag)) then
    begin
      if (FFeatures[Tag]) then
        FeatureButton.State := fbsEnabled
      else
        FeatureButton.State := fbsDisabled;
    end else
      FeatureButton.State := fbsNone;

    FeatureButton.Parent := FlowPanelFeatures;
    FeatureButton.OnClick := ButtonFeatureClick;
  end;
end;

procedure TFmRenderDemo.LoadFont(Filename: string);
begin
  Invalidate;
  FFontFilename := '';
  FHasAvailableFeatures := False;
  try

    try
      FFontFace.LoadFromFile(FileName);
      FFontFilename := FileName;

    except
      on E: Exception do
        Application.ShowException(E);
    end;

  finally
    UpdateAvailableFeatures;
  end;

  if (FFontFilename = '') then
    ShowMessageFmt('Unable to load specified font file: %s', [FileName]);
end;

procedure TFmRenderDemo.FontNameChanged;
var
  FontIndex : Integer;
begin
  Invalidate;
  FFontFilename := '';

  for FontIndex := 0 to High(FFontArray) do
    if FFontArray[FontIndex].FullFontName = FFontName then
    begin
      LoadFont(FFontArray[FontIndex].FileName);
      exit;
    end;

  ShowMessageFmt('Selected font not found: %s', [FFontName]);
end;

procedure TFmRenderDemo.FontSizeChanged;
begin
  FRenderer.FontSize := FFontSize;
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
  if (TAction(Sender).Checked) then
    FRenderer.Options := FRenderer.Options + [roColorize]
  else
    FRenderer.Options := FRenderer.Options - [roColorize];
end;

procedure TFmRenderDemo.ActionFeaturesClearExecute(Sender: TObject);
begin
  FFeatures.Clear;
  FHasAvailableFeatures := False;
  UpdateAvailableFeatures;
  Invalidate;
end;

procedure TFmRenderDemo.ActionGenericExecute(Sender: TObject);
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

  FHasAvailableFeatures := False;
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
