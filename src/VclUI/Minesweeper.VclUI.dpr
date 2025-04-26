program Minesweeper.VclUI;

uses
  Vcl.Forms,
  Minesweeper.Game in '..\Shared\Minesweeper.Game.pas',
  Minesweeper.VclUI.Forms.GameForm in 'Minesweeper.VclUI.Forms.GameForm.pas' {GameForm},
  Minesweeper.VclUI.Dialogs in 'Minesweeper.VclUI.Dialogs.pas',
  Minesweeper.VclUI.Dialogs.CustomSettingsForm in 'Minesweeper.VclUI.Dialogs.CustomSettingsForm.pas' {CustomSettingsForm},
  Minesweeper.VclUI.Resources in 'Minesweeper.VclUI.Resources.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGameForm, GameForm);
  Application.Run;
end.
