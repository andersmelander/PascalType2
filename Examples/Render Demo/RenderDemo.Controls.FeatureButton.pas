unit RenderDemo.Controls.FeatureButton;

interface

uses
  Classes,
  Graphics,
  GR32,
  GR32_Image,
  PascalType.Types;

type
  TFeatureButtonState = (fbsNone, fbsEnabled, fbsDisabled);

  TFeatureButton = class(TCustomPaintBox32)
  private const
    ButtonColors: array[TFeatureButtonState] of TColor32 = ($FFBFBFBF, clGreen32, clRed32);
    StateColors: array[TFeatureButtonState] of TColor32 = ($FFB0B0B0, clWhite32, clWhite32);
    TextColors: array[TFeatureButtonState] of TColor32 = (clBlack32, clWhite32, clWhite32);
    GlyphColors: array[TFeatureButtonState] of TColor32 = (0, clGreen32, clRed32);
    GlyphMargin = 4.0;
  private
    class var FGlyphs: array[TFeatureButtonState] of TArrayOfFloatPoint;
  private
    FTag: TTableName;
    FCaption: string;
    FState: TFeatureButtonState;
    FHasScaledGlyphs: boolean;
    FScaledGlyphs: array[TFeatureButtonState] of TArrayOfFloatPoint;
    function ScalePath(const Path: TArrayOfFloatPoint): TArrayOfFloatPoint;
    procedure SetState(const Value: TFeatureButtonState);
    procedure SetCaption(const Value: string);
    procedure SetTag(const Value: TTableName);
    function GetFont: TFont;
  protected
    procedure DoPaintBuffer; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure Click; override;

  private
    class constructor Create;
  public
    constructor Create(AOwner: TComponent); override;

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    property Tag: TTableName read FTag write SetTag;
    property Caption: string read FCaption write SetCaption;
    property State: TFeatureButtonState read FState write SetState;

    property OnClick;
    property Margins;
    property AlignWithMargins;
    property Font: TFont read GetFont; // Redirect from TControl.Font to Buffer.Font
  end;

implementation

uses
  Windows,
  Messages,
  Math,
  Types,
  GR32_Backends,
  GR32_Paths,
  GR32_Brushes;

{ TFeatureButton }

procedure TFeatureButton.Click;
begin
  if (State = High(State)) then
    State := Low(State)
  else
    State := Succ(State);

  inherited;
end;

constructor TFeatureButton.Create(AOwner: TComponent);
begin
  inherited;
  Buffer.DrawMode := dmBlend;
  SetBounds(0, 0, 75, 25);
end;

class constructor TFeatureButton.Create;
begin
  FGlyphs[fbsEnabled] := [FloatPoint(2.5, 7.5), FloatPoint(5.5, 10.5), FloatPoint(13.5, 2.5), FloatPoint(15.5, 4.5), FloatPoint(5.5, 14.5), FloatPoint(0.5, 9.5)];
  FGlyphs[fbsDisabled] := [FloatPoint(2.5, 1.5), FloatPoint(7.5, 6.5), FloatPoint(12.5, 1.5), FloatPoint(14.5, 3.5), FloatPoint(9.5, 8.5), FloatPoint(14.5, 13.5), FloatPoint(12.5, 15.5), FloatPoint(7.5, 10.5), FloatPoint(2.5, 15.5), FloatPoint(0.5, 13.5), FloatPoint(5.5, 8.5), FloatPoint(0.5, 3.5)];
end;

procedure TFeatureButton.DoPaintBuffer;

  procedure PaintBackground;
  var
    P: TPoint;
    SaveIndex: Integer;
  begin
    SaveIndex := SaveDC(Buffer.Handle);
    try
      GetViewportOrgEx(Buffer.Handle, P);
      SetViewportOrgEx(Buffer.Handle, P.X - Left, P.Y - Top, nil);
      IntersectClipRect(Buffer.Handle, 0, 0, Parent.ClientWidth, Parent.ClientHeight);
      Parent.Perform(WM_ERASEBKGND, Buffer.Handle, 0);
      Parent.Perform(WM_PAINT, Buffer.Handle, 0);
    finally
      RestoreDC(Buffer.Handle, SaveIndex);
    end;
  end;

  function Darken(Color: TColor32): TColor32;
  var
    H, S, L: Single;
  begin
    RGBtoHSL(Color, H, S, L);
    L := L * 0.9;
    Result := HSLtoRGB(H, S, L);
  end;

var
  Canvas: TCanvas32;
  FillBrush: TSolidBrush;
  StrokeBrush: TStrokeBrush;
  r, r2: TFloatRect;
  p: TFloatPoint;
  Radius: Single;
  s: TFeatureButtonState;
begin
  if (not FHasScaledGlyphs) then
  begin
    FHasScaledGlyphs := True;

    for s := Low(TFeatureButtonState) to High(TFeatureButtonState) do
      FScaledGlyphs[s] := ScalePath(FGlyphs[s]);
  end;

  Buffer.Clear(Color32(Color));
//  PaintBackground;

  Canvas := TCanvas32.Create(Buffer);
  try

    FillBrush := Canvas.Brushes.Add(TSolidBrush) as TSolidBrush;
    if (MouseInControl) then
      FillBrush.FillColor := Darken(ButtonColors[State])
    else
      FillBrush.FillColor := ButtonColors[State];

    r := GR32.FloatRect(ClientRect);
    Radius := ClientHeight / 2;
    Canvas.RoundRect(r, Radius);
    Canvas.EndPath(True);
    FillBrush.Visible := False;

    if (True) then
    begin
      StrokeBrush := Canvas.Brushes.Add(TStrokeBrush) as TStrokeBrush;
      StrokeBrush.FillColor := Darken(FillBrush.FillColor);
      StrokeBrush.StrokeWidth := 1;

      r2 := r;
      GR32.InflateRect(r2, -1, -1);

      Canvas.RoundRect(r2, Radius-2);
      Canvas.EndPath(True);
      StrokeBrush.Visible := False;
    end else
      StrokeBrush := nil;


    if (StateColors[State] <> 0) then
    begin
      FillBrush.Visible := True;
      FillBrush.FillColor := StateColors[State];

      p := r.TopLeft;
      p.X := p.X + Radius;
      p.Y := p.Y + Radius;

      Canvas.Circle(p, Radius - GlyphMargin);
      Canvas.EndPath(True);
      FillBrush.Visible := False;
    end;

    if (Length(FGlyphs[State]) > 0) then
    begin
      FillBrush.Visible := True;
      FillBrush.FillColor := GlyphColors[State];

      Canvas.Polygon(FScaledGlyphs[State]);

      FillBrush.Visible := False;
    end;

    r2 := r;
    r2.Left := r2.Left + ClientHeight; // ClientHeight = 2*Radius

    FillBrush.Visible := True;
    FillBrush.FillColor := TextColors[State];
    Canvas.RenderText(r2, Caption, DT_VCENTER);

  finally
    Canvas.Free;
  end;

  inherited;
end;

function TFeatureButton.GetFont: TFont;
begin
  Result := Buffer.Font;
end;

procedure TFeatureButton.MouseEnter;
begin
  inherited;
  Invalidate;
end;

procedure TFeatureButton.MouseLeave;
begin
  inherited;
  Invalidate;
end;

function TFeatureButton.ScalePath(const Path: TArrayOfFloatPoint): TArrayOfFloatPoint;
var
  i: integer;
  GlyphScale: Single;
begin
  SetLength(Result, Length(Path));
  GlyphScale := (ClientHeight - 2 * GlyphMargin - 4) / 16;

  for i := 0 to High(Path) do
  begin
    Result[i].X := GlyphMargin + 2 + Path[i].X * GlyphScale;
    Result[i].Y := GlyphMargin + 2 + Path[i].Y * GlyphScale;
  end;
end;

procedure TFeatureButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;

  FHasScaledGlyphs := False;
end;

procedure TFeatureButton.SetCaption(const Value: string);
var
  Canvas: TCanvas32;
  r: TFloatRect;
begin
  FCaption := Value;

  Canvas := TCanvas32.Create(Buffer);
  try

    r := FloatRect(Buffer.BoundsRect);
    r := Canvas.MeasureText(r, Caption, DT_SINGLELINE);
    Width := Height + Ceil(r.Right - r.Left) + 2 * 4;

  finally
    Canvas.Free;
  end;

  Invalidate;
end;

procedure TFeatureButton.SetState(const Value: TFeatureButtonState);
begin
  if (FState = Value) then
    exit;

  FState := Value;
  Invalidate;
end;

procedure TFeatureButton.SetTag(const Value: TTableName);
begin
  FTag := Value;
  Invalidate;
end;

end.
