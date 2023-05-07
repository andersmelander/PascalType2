object FmRenderDemo: TFmRenderDemo
  Left = 322
  Top = 97
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'PascalType Render Demo'
  ClientHeight = 436
  ClientWidth = 676
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    676
    436)
  TextHeight = 13
  object LabelText: TLabel
    Left = 8
    Top = 11
    Width = 26
    Height = 13
    Caption = 'Text:'
  end
  object LabelFont: TLabel
    Left = 384
    Top = 11
    Width = 26
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Font:'
    ExplicitLeft = 199
  end
  object LabelFontSize: TLabel
    Left = 596
    Top = 11
    Width = 23
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Size:'
    ExplicitLeft = 391
  end
  object LabelFontEngine: TLabel
    Left = 8
    Top = 417
    Width = 53
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Rasterizer:'
  end
  object EditText: TEdit
    Left = 40
    Top = 8
    Width = 338
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'PascalType Render Demo'
    OnChange = EditTextChange
  end
  object ComboBoxFont: TComboBox
    Left = 416
    Top = 8
    Width = 174
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 1
    OnChange = ComboBoxFontChange
  end
  object ComboBoxFontSize: TComboBox
    Left = 625
    Top = 8
    Width = 43
    Height = 21
    Style = csDropDownList
    Anchors = [akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemIndex = 8
    ParentFont = False
    TabOrder = 2
    Text = '20'
    OnChange = ComboBoxFontSizeChange
    Items.Strings = (
      '8'
      '9'
      '10'
      '11'
      '12'
      '14'
      '16'
      '18'
      '20'
      '22'
      '24'
      '26'
      '28'
      '36'
      '48'
      '72'
      '96'
      '128'
      '256')
  end
  object PanelText: TPanel
    Left = 8
    Top = 35
    Width = 660
    Height = 376
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = clWhite
    TabOrder = 3
    OnResize = PanelTextResize
    object PaintBox: TPaintBox
      Left = 0
      Top = 0
      Width = 656
      Height = 372
      Align = alClient
      OnPaint = PaintBoxPaint
      ExplicitWidth = 451
      ExplicitHeight = 119
    end
  end
  object RadioButtonWindows: TRadioButton
    Left = 76
    Top = 416
    Width = 62
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Windows'
    Checked = True
    TabOrder = 4
    TabStop = True
    OnClick = RadioButtonWindowsClick
  end
  object RadioButtonPascalType: TRadioButton
    Left = 144
    Top = 416
    Width = 74
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'GDI'
    TabOrder = 5
    OnClick = RadioButtonPascalTypeClick
  end
  object RadioButtonGraphics32: TRadioButton
    Left = 231
    Top = 416
    Width = 74
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Graphics32'
    TabOrder = 6
    OnClick = RadioButtonGraphics32Click
  end
end
