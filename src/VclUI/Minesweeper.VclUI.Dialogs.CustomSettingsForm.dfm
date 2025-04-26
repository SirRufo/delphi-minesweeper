object CustomSettingsForm: TCustomSettingsForm
  Left = 0
  Top = 0
  AutoSize = True
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 127
  ClientWidth = 162
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 6
    Width = 35
    Height = 15
    Caption = 'Width:'
  end
  object Label2: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 35
    Width = 39
    Height = 15
    Caption = 'Height:'
  end
  object Label3: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 64
    Width = 35
    Height = 15
    Caption = 'Mines:'
  end
  object WidthNumberBox: TNumberBox
    AlignWithMargins = True
    Left = 91
    Top = 3
    Width = 68
    Height = 23
    Alignment = taRightJustify
    MinValue = 8.000000000000000000
    MaxValue = 100.000000000000000000
    TabOrder = 0
    Value = 8.000000000000000000
    OnChangeValue = WidthOrHeightNumberBoxChangeValue
  end
  object HeightNumberBox: TNumberBox
    AlignWithMargins = True
    Left = 91
    Top = 32
    Width = 68
    Height = 23
    Alignment = taRightJustify
    MinValue = 8.000000000000000000
    MaxValue = 100.000000000000000000
    TabOrder = 1
    Value = 8.000000000000000000
    OnChangeValue = WidthOrHeightNumberBoxChangeValue
  end
  object MineCountNumberBox: TNumberBox
    AlignWithMargins = True
    Left = 91
    Top = 61
    Width = 68
    Height = 23
    Alignment = taRightJustify
    MinValue = 1.000000000000000000
    MaxValue = 64.000000000000000000
    TabOrder = 2
    Value = 1.000000000000000000
  end
  object OkButton: TButton
    AlignWithMargins = True
    Left = 3
    Top = 99
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object CancelButton: TButton
    AlignWithMargins = True
    Left = 84
    Top = 99
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
