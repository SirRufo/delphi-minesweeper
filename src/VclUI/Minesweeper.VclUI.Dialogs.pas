unit Minesweeper.VclUI.Dialogs;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils,
  Vcl.Forms, Vcl.Controls,
  Minesweeper.Game,
  Minesweeper.VclUI.Dialogs.CustomSettingsForm;

type
  TCommonDialog = class(TComponent)
  public
    function Execute: Boolean; overload; virtual;
    function Execute(ParentWindow: HWND): Boolean; overload; virtual; abstract;
  end;

  TCustomSettingsDialog = class(TCommonDialog)
  private
    FDialog: TCustomSettingsForm;
    FConfig: TMinesweeperGameConfig;
  public
    property Config: TMinesweeperGameConfig read FConfig write FConfig;

    function Execute(ParentWindow: HWND): Boolean; override;
  end;

implementation

{ TCommonDialog }

function ApplicationMainHandle: HWND;
begin
  if Application.MainFormOnTaskBar and (Application.MainForm <> nil) then
    Result := Application.MainFormHandle
  else
    Result := Application.Handle;
end;

function TCommonDialog.Execute: Boolean;
var
  ParentWnd: HWND;
begin
  if Application.ModalPopupMode <> pmNone then
  begin
    ParentWnd := Application.ActiveFormHandle;
    if ParentWnd = 0 then
      ParentWnd := ApplicationMainHandle;
  end
  else
    ParentWnd := ApplicationMainHandle;
  Result := Execute(ParentWnd);
end;

{ TCustomSettingsDialog }

function TCustomSettingsDialog.Execute(ParentWindow: HWND): Boolean;
begin
  FDialog := TCustomSettingsForm.Create(Self);
  try
    FDialog.WidthNumberBox.ValueInt := Config.Width;
    FDialog.HeightNumberBox.ValueInt := Config.Height;
    FDialog.MineCountNumberBox.ValueInt := Config.MineCount;
    FDialog.ParentWindow := ParentWindow;
    Result := FDialog.ShowModal() = mrOK;
    if Result then
    begin
      Config := TMinesweeperGameConfig.Create(FDialog.WidthNumberBox.ValueInt, FDialog.HeightNumberBox.ValueInt,
        FDialog.MineCountNumberBox.ValueInt);
    end;
  finally
    FreeAndNil(FDialog);
  end;
end;

end.
