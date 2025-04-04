object Form1: TForm1
  Left = 241
  Top = 155
  Width = 544
  Height = 375
  VertScrollBar.Range = 200
  ActiveControl = BExecute
  Caption = 'Inspect Python Code'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = 11
  Font.Name = 'MS Sans Serif'
  Font.Pitch = fpVariable
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 153
    Width = 528
    Height = 3
    Cursor = crVSplit
    Align = alTop
    Color = clBtnFace
    ParentColor = False
    ExplicitWidth = 536
  end
  object Memo1: TMemo
    Left = 0
    Top = 156
    Width = 528
    Height = 136
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Pitch = fpVariable
    Font.Style = []
    Lines.Strings = (
      'print(2+2)')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 292
    Width = 528
    Height = 44
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 322
      Top = 16
      Width = 38
      Height = 13
      Caption = 'Explore:'
    end
    object BExecute: TButton
      Left = 6
      Top = 6
      Width = 115
      Height = 25
      Caption = 'Execute script'
      TabOrder = 0
      OnClick = BExecuteClick
    end
    object BLoad: TButton
      Left = 127
      Top = 6
      Width = 91
      Height = 25
      Caption = 'Load script...'
      TabOrder = 1
      OnClick = BLoadClick
    end
    object BSave: TButton
      Left = 224
      Top = 6
      Width = 89
      Height = 25
      Caption = 'Save script...'
      TabOrder = 2
      OnClick = BSaveClick
    end
    object BMain: TButton
      Left = 366
      Top = 6
      Width = 75
      Height = 25
      Caption = '__ &main __'
      TabOrder = 3
      OnClick = BMainClick
    end
    object BLocals: TButton
      Left = 447
      Top = 6
      Width = 75
      Height = 25
      Caption = '&locals'
      TabOrder = 4
      OnClick = BLocalsClick
    end
  end
  object Memo2: TMemo
    Left = 0
    Top = 0
    Width = 528
    Height = 153
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.py'
    Filter = 'Python files|*.py|Text files|*.txt|All files|*.*'
    Title = 'Open'
    Left = 176
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.py'
    Filter = 'Python files|*.py|Text files|*.txt|All files|*.*'
    Title = 'Save As'
    Left = 208
  end
end
