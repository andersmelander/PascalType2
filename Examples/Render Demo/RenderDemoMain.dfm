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
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  PopupMenu = PopupMenu
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    916
    436)
  TextHeight = 20
  object LabelText: TLabel
    Left = 8
    Top = 11
    Width = 30
    Height = 20
    Caption = 'Text:'
  end
  object LabelFont: TLabel
    Left = 660
    Top = 11
    Width = 32
    Height = 20
    Anchors = [akTop, akRight]
    Caption = 'Font:'
  end
  object LabelFontSize: TLabel
    Left = 829
    Top = 12
    Width = 30
    Height = 20
    Anchors = [akTop, akRight]
    Caption = 'Size:'
  end
  object Label1: TLabel
    Left = 447
    Top = 12
    Width = 62
    Height = 20
    Anchors = [akTop, akRight]
    Caption = 'Test case:'
  end
  object EditText: TEdit
    Left = 44
    Top = 8
    Width = 397
    Height = 28
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'PascalType Render Demo'
    OnChange = EditTextChange
  end
  object ComboBoxFont: TComboBox
    Left = 698
    Top = 8
    Width = 111
    Height = 28
    Anchors = [akTop, akRight]
    DropDownWidth = 200
    TabOrder = 1
    OnChange = ComboBoxFontChange
  end
  object ComboBoxFontSize: TComboBox
    Left = 865
    Top = 8
    Width = 43
    Height = 28
    Style = csDropDownList
    Anchors = [akTop, akRight]
    ItemIndex = 13
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
    ExplicitWidth = 894
    ExplicitHeight = 384
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
      ExplicitWidth = 894
      ExplicitHeight = 95
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
      ExplicitTop = 97
      ExplicitWidth = 894
      ExplicitHeight = 95
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
      ExplicitTop = 193
      ExplicitWidth = 894
      ExplicitHeight = 95
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
      ExplicitTop = 289
      ExplicitWidth = 894
      ExplicitHeight = 95
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
    Left = 512
    Top = 8
    Width = 137
    Height = 28
    Anchors = [akTop, akRight]
    DropDownWidth = 250
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
  end
  object PopupMenu: TPopupMenu
    Left = 452
    Top = 224
    object MenuItemColor: TMenuItem
      Action = ActionColor
      AutoCheck = True
    end
  end
end
