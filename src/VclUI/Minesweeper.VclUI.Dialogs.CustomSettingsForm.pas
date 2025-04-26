unit Minesweeper.VclUI.Dialogs.CustomSettingsForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.NumberBox;

type
  TCustomSettingsForm = class(TForm)
    WidthNumberBox: TNumberBox;
    HeightNumberBox: TNumberBox;
    MineCountNumberBox: TNumberBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OkButton: TButton;
    CancelButton: TButton;
    procedure WidthOrHeightNumberBoxChangeValue(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  CustomSettingsForm: TCustomSettingsForm;

implementation

{$R *.dfm}

uses
  Minesweeper.VclUI.Resources;

procedure TCustomSettingsForm.FormCreate(Sender: TObject);
begin
  Self.Caption := CaptionSettings;
  Label1.Caption := CaptionSettingsWidth;
  Label2.Caption := CaptionSettingsHeight;
  Label3.Caption := CaptionSettingsMineCount;
  OkButton.Caption := CaptionOk;
  CancelButton.Caption := CaptionCancel;
end;

procedure TCustomSettingsForm.WidthOrHeightNumberBoxChangeValue(Sender: TObject);
begin
  MineCountNumberBox.MaxValue := Min(999, WidthNumberBox.ValueInt * HeightNumberBox.ValueInt - 1);
end;

end.
