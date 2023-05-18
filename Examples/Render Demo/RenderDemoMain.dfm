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
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = PaintBoxWindows
        Row = 0
      end
      item
        Column = 0
        Control = PaintBoxGDI
        Row = 1
      end
      item
        Column = 0
        Control = PaintBoxGraphics32
        Row = 2
      end
      item
        Column = 0
        Control = PaintBoxImage32
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
    object PaintBoxWindows: TPaintBox
      Left = 1
      Top = 1
      Width = 658
      Height = 98
      Align = alClient
      OnPaint = PaintBoxWindowsPaint
      ExplicitLeft = 277
      ExplicitWidth = 451
      ExplicitHeight = 119
    end
    object PaintBoxGDI: TPaintBox
      Left = 1
      Top = 99
      Width = 658
      Height = 98
      Align = alClient
      OnPaint = PaintBoxGDIPaint
      ExplicitLeft = 277
      ExplicitTop = 94
      ExplicitWidth = 451
      ExplicitHeight = 119
    end
    object PaintBoxGraphics32: TPaintBox
      Left = 1
      Top = 197
      Width = 658
      Height = 97
      Align = alClient
      OnPaint = PaintBoxGraphics32Paint
      ExplicitLeft = 277
      ExplicitTop = 188
      ExplicitWidth = 451
      ExplicitHeight = 119
    end
    object PaintBoxImage32: TPaintBox
      Left = 1
      Top = 294
      Width = 658
      Height = 98
      Align = alClient
      OnPaint = PaintBoxImage32Paint
      ExplicitLeft = 277
      ExplicitTop = 188
      ExplicitWidth = 451
      ExplicitHeight = 119
    end
  end
end
