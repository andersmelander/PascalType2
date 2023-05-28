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
  object GridPanel1: TGridPanel
    Left = 8
    Top = 35
    Width = 660
    Height = 393
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = PanelGDI
        Row = 0
      end
      item
        Column = 0
        Control = PanelPascalTypeGDI
        Row = 1
      end
      item
        Column = 0
        Control = PanelPascalTypeGraphics32
        Row = 2
      end
      item
        Column = 0
        Control = PanelImage32
        Row = 3
      end>
    RowCollection = <
      item
        Value = 25.000000000000000000
      end
      item
        Value = 25.000000000000000000
      end
      item
        Value = 25.000000000000000000
      end
      item
        Value = 25.000000000000000000
      end
      item
        SizeStyle = ssAuto
      end>
    ShowCaption = False
    TabOrder = 3
    object PanelGDI: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 1
      Width = 658
      Height = 97
      Margins.Left = 0
      Margins.Top = 1
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'GDI TextOut'
      ShowCaption = False
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitHeight = 98
      object PaintBox1: TPaintBox
        Left = 637
        Top = 0
        Width = 21
        Height = 97
        Align = alRight
        OnPaint = PaintBox1Paint
        ExplicitLeft = 484
        ExplicitHeight = 133
      end
      object PaintBoxWindows: TPaintBox
        Left = 0
        Top = 0
        Width = 637
        Height = 97
        Align = alClient
        OnPaint = PaintBoxWindowsPaint
        ExplicitLeft = 277
        ExplicitTop = 1
        ExplicitWidth = 451
        ExplicitHeight = 119
      end
    end
    object PanelPascalTypeGDI: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 99
      Width = 658
      Height = 97
      Margins.Left = 0
      Margins.Top = 1
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'PascalType GDI'
      ShowCaption = False
      TabOrder = 1
      ExplicitLeft = 1
      ExplicitHeight = 98
      object PaintBox2: TPaintBox
        Left = 637
        Top = 0
        Width = 21
        Height = 97
        Align = alRight
        OnPaint = PaintBox1Paint
        ExplicitLeft = 484
        ExplicitHeight = 133
      end
      object PaintBoxGDI: TPaintBox
        Left = 0
        Top = 0
        Width = 637
        Height = 97
        Align = alClient
        OnPaint = PaintBoxGDIPaint
        ExplicitLeft = 4
        ExplicitWidth = 484
        ExplicitHeight = 133
      end
    end
    object PanelPascalTypeGraphics32: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 197
      Width = 658
      Height = 96
      Margins.Left = 0
      Margins.Top = 1
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'PascalType Graphics32'
      ShowCaption = False
      TabOrder = 2
      ExplicitLeft = 1
      ExplicitHeight = 97
      object PaintBox3: TPaintBox
        Left = 637
        Top = 0
        Width = 21
        Height = 96
        Align = alRight
        OnPaint = PaintBox1Paint
        ExplicitLeft = 484
        ExplicitHeight = 133
      end
      object PaintBoxGraphics32: TPaintBox
        Left = 0
        Top = 0
        Width = 637
        Height = 96
        Align = alClient
        OnPaint = PaintBoxGraphics32Paint
        ExplicitLeft = 4
        ExplicitWidth = 484
        ExplicitHeight = 133
      end
    end
    object PanelImage32: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 294
      Width = 658
      Height = 97
      Margins.Left = 0
      Margins.Top = 1
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Image32'
      ShowCaption = False
      TabOrder = 3
      ExplicitLeft = 1
      ExplicitHeight = 98
      object PaintBox4: TPaintBox
        Left = 637
        Top = 0
        Width = 21
        Height = 97
        Align = alRight
        OnPaint = PaintBox1Paint
        ExplicitLeft = 484
        ExplicitHeight = 133
      end
      object PaintBoxImage32: TPaintBox
        Left = 0
        Top = 0
        Width = 637
        Height = 97
        Align = alClient
        OnPaint = PaintBoxImage32Paint
        ExplicitLeft = 4
        ExplicitWidth = 484
        ExplicitHeight = 133
      end
    end
  end
end
