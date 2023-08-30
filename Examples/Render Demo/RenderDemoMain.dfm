object FmRenderDemo: TFmRenderDemo
  Left = 322
  Top = 97
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'PascalType Render Demo'
  ClientHeight = 436
  ClientWidth = 916
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  PopupMenu = PopupMenu
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    916
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
    Left = 660
    Top = 11
    Width = 26
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Font:'
  end
  object LabelFontSize: TLabel
    Left = 836
    Top = 11
    Width = 23
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Size:'
    ExplicitLeft = 391
  end
  object Label1: TLabel
    Left = 492
    Top = 11
    Width = 50
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Test case:'
  end
  object EditText: TEdit
    Left = 40
    Top = 8
    Width = 441
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'PascalType Render Demo'
    OnChange = EditTextChange
  end
  object ComboBoxFont: TComboBox
    Left = 692
    Top = 8
    Width = 138
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 1
    OnChange = ComboBoxFontChange
  end
  object ComboBoxFontSize: TComboBox
    Left = 865
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
    ItemIndex = 13
    ParentFont = False
    TabOrder = 2
    Text = '36'
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
    Width = 900
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
      Width = 900
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
      object PaintBox1: TPaintBox
        Left = 879
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
        Width = 879
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
      Width = 900
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
      object PaintBox2: TPaintBox
        Left = 879
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
        Width = 879
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
      Width = 900
      Height = 98
      Margins.Left = 0
      Margins.Top = 1
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'PascalType Graphics32'
      ShowCaption = False
      TabOrder = 2
      object PaintBox3: TPaintBox
        Left = 879
        Top = 0
        Width = 21
        Height = 98
        Align = alRight
        OnPaint = PaintBox1Paint
        ExplicitLeft = 484
        ExplicitHeight = 133
      end
      object PaintBoxGraphics32: TPaintBox
        Left = 0
        Top = 0
        Width = 879
        Height = 98
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
      Top = 296
      Width = 900
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
      object PaintBox4: TPaintBox
        Left = 879
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
        Width = 879
        Height = 97
        Align = alClient
        OnPaint = PaintBoxImage32Paint
        ExplicitLeft = 4
        ExplicitWidth = 484
        ExplicitHeight = 133
      end
    end
  end
  object ComboBoxTestCase: TComboBox
    Left = 544
    Top = 8
    Width = 105
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 4
    OnChange = ComboBoxTestCaseChange
  end
  object ActionList: TActionList
    Left = 436
    Top = 84
    object ActionColor: TAction
      AutoCheck = True
      Caption = 'Color individual glyphs'
      OnExecute = ActionColorExecute
    end
    object ActionPaintPoints: TAction
      AutoCheck = True
      Caption = 'Paint curve control points'
      OnExecute = ActionPaintPointsExecute
    end
  end
  object PopupMenu: TPopupMenu
    Left = 452
    Top = 224
    object MenuItemColor: TMenuItem
      Action = ActionColor
      AutoCheck = True
    end
    object Paintcurvecontrolpoints1: TMenuItem
      Action = ActionPaintPoints
      AutoCheck = True
    end
  end
end
