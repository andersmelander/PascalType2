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
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 20
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 916
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      916
      41)
    object LabelText: TLabel
      Left = 8
      Top = 11
      Width = 30
      Height = 20
      Caption = 'Text:'
    end
    object Label1: TLabel
      Left = 427
      Top = 10
      Width = 62
      Height = 20
      Anchors = [akTop, akRight]
      Caption = 'Test case:'
    end
    object LabelFont: TLabel
      Left = 640
      Top = 9
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
    object EditText: TEdit
      Left = 44
      Top = 8
      Width = 377
      Height = 28
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'PascalType Render Demo'
      OnChange = EditTextChange
    end
    object ComboBoxTestCase: TComboBox
      Left = 492
      Top = 6
      Width = 137
      Height = 28
      Anchors = [akTop, akRight]
      DropDownWidth = 250
      TabOrder = 1
      OnChange = ComboBoxTestCaseChange
    end
    object ComboBoxFont: TComboBox
      Left = 678
      Top = 6
      Width = 111
      Height = 28
      Anchors = [akTop, akRight]
      DropDownWidth = 200
      TabOrder = 2
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
      TabOrder = 3
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
    object ButtonLoad: TButton
      Left = 790
      Top = 6
      Width = 28
      Height = 28
      Anchors = [akTop, akRight]
      Caption = #8230
      TabOrder = 4
      OnClick = ButtonLoadClick
    end
  end
  object PanelMain: TPanel
    Left = 0
    Top = 41
    Width = 916
    Height = 395
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object SplitterFeatures: TSplitter
      Left = 185
      Top = 0
      Width = 5
      Height = 395
      MinSize = 50
      ResizeStyle = rsUpdate
      ExplicitLeft = 221
    end
    object GridPanelSamples: TGridPanel
      Left = 190
      Top = 0
      Width = 726
      Height = 395
      Align = alClient
      BevelOuter = bvNone
      Caption = 'GridPanelSamples'
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
      TabOrder = 0
      object PanelGDI: TPanel
        AlignWithMargins = True
        Left = 0
        Top = 1
        Width = 726
        Height = 98
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
          Left = 705
          Top = 0
          Width = 21
          Height = 98
          Align = alRight
          OnPaint = PaintBox1Paint
          ExplicitLeft = 484
          ExplicitHeight = 133
        end
        object PaintBoxWindows: TPaintBox
          Left = 0
          Top = 0
          Width = 705
          Height = 98
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
        Top = 100
        Width = 726
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
          Left = 705
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
          Width = 705
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
        Top = 198
        Width = 726
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
          Left = 705
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
          Width = 705
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
        Top = 297
        Width = 726
        Height = 98
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
          Left = 705
          Top = 0
          Width = 21
          Height = 98
          Align = alRight
          OnPaint = PaintBox1Paint
          ExplicitLeft = 484
          ExplicitHeight = 133
        end
        object PaintBoxImage32: TPaintBox
          Left = 0
          Top = 0
          Width = 705
          Height = 98
          Align = alClient
          OnPaint = PaintBoxImage32Paint
          ExplicitLeft = 4
          ExplicitWidth = 484
          ExplicitHeight = 133
        end
      end
    end
    object FlowPanelFeatures: TFlowPanel
      Left = 0
      Top = 0
      Width = 185
      Height = 395
      Align = alLeft
      BevelEdges = [beRight]
      BevelKind = bkFlat
      BevelOuter = bvNone
      TabOrder = 1
    end
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
      OnExecute = ActionGenericExecute
    end
    object ActionFeaturesClear: TAction
      Caption = 'Clear all features'
      OnExecute = ActionFeaturesClearExecute
    end
    object ActionPaintMetrics: TAction
      AutoCheck = True
      Caption = 'Draw metrics'
      OnExecute = ActionGenericExecute
    end
  end
  object PopupMenu: TPopupMenu
    Left = 452
    Top = 224
    object MenuItemRenderer: TMenuItem
      Caption = 'Renderers'
      object MenuItemRendererGDI: TMenuItem
        AutoCheck = True
        Caption = 'GDI TextOut'
        Checked = True
        OnClick = MenuItemRendererClick
      end
      object MenuItemRendererPascalTypeGDI: TMenuItem
        Tag = 1
        AutoCheck = True
        Caption = 'PascalType GDI renderer'
        OnClick = MenuItemRendererClick
      end
      object MenuItemRendererPascalTypeGraphics32: TMenuItem
        Tag = 2
        AutoCheck = True
        Caption = 'PascalType Graphics32 renderer'
        Checked = True
        OnClick = MenuItemRendererClick
      end
      object MenuItemRendererImage32: TMenuItem
        Tag = 3
        AutoCheck = True
        Caption = 'Image32 DrawText'
        Checked = True
        OnClick = MenuItemRendererClick
      end
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MenuItemColor: TMenuItem
      Action = ActionColor
      AutoCheck = True
      Caption = 'Colorize individual glyphs'
    end
    object Paintcurvecontrolpoints1: TMenuItem
      Action = ActionPaintPoints
      AutoCheck = True
      Caption = 'Draw curve control points'
    end
    object Drawglyphmetrics1: TMenuItem
      Action = ActionPaintMetrics
      AutoCheck = True
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Clearallfeatures1: TMenuItem
      Action = ActionFeaturesClear
      Caption = 'Reset all features'
    end
  end
end
