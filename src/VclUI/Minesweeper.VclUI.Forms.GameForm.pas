unit Minesweeper.VclUI.Forms.GameForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Actions, System.ImageList,
  Vcl.ExtCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Grids, Vcl.ActnList, Vcl.Menus, Vcl.ImgList, Vcl.Buttons,
  Minesweeper.Game, Minesweeper.VclUI.Dialogs;

type
  TGameForm = class(TForm)
    DrawGrid1: TDrawGrid;
    FlagsLabel: TLabel;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    BeginnerGameAction: TAction;
    IntermediateGameAction: TAction;
    ExpertGameAction: TAction;
    CustomGameAction: TAction;
    Settings1: TMenuItem;
    Beginner1: TMenuItem;
    Intermediate1: TMenuItem;
    Expert1: TMenuItem;
    Custom1: TMenuItem;
    RestartGameAction: TAction;
    CellImageList: TImageList;
    Timer1: TTimer;
    ElapsedSecondsLabel: TLabel;
    GameImageList: TImageList;
    Panel1: TPanel;
    NewGameButton: TSpeedButton;
    TimeGroupBox: TGroupBox;
    MinesGroupBox: TGroupBox;
    procedure FormDestroy(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BeginnerGameActionExecute(Sender: TObject);
    procedure IntermediateGameActionExecute(Sender: TObject);
    procedure ExpertGameActionExecute(Sender: TObject);
    procedure RestartGameActionExecute(Sender: TObject);
    procedure CustomGameActionExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    Game: TMinesweeperGame;
    FSetupGameLocked: Boolean;
    FShowAdjacentCells: Boolean;
    procedure HandleCellChange(Sender: TObject; X, Y: Integer; const Cell: TCell);
    procedure HandleGameState(Sender: TObject; State: TGameState);
    procedure HandleFlagCountChange(Sender: TObject; Count: Integer);
    procedure SetupGrid;
    procedure SetupGame(Config: TMinesweeperGameConfig);
    procedure UpdateElapsed();
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  GameForm: TGameForm;

implementation

{$R *.dfm}

uses
  Minesweeper.VclUI.Resources,
  Vcl.Dialogs;

const
  GRID_SIZE = 24;

  CELL_CLOSED = 0;
  CELL_FLAG = 1;
  CELL_QM = 2;
  CELL_MINE = 3;
  CELL_MINE_RED = 4;
  CELL_OPEN = 5;

constructor TGameForm.Create(AOwner: TComponent);
begin
  Self.OnDestroy := FormDestroy;

  inherited;

  NewGameButton.OnClick := RestartGameActionExecute;
  DrawGrid1.OnMouseDown := DrawGrid1MouseDown;
  DrawGrid1.OnMouseUp := DrawGrid1MouseUp;
  DrawGrid1.OnDrawCell := DrawGrid1DrawCell;

  BeginnerGameAction.Caption := CaptionSettingsBeginner;
  IntermediateGameAction.Caption := CaptionSettingsIntermediate;
  ExpertGameAction.Caption := CaptionSettingsExpert;
  CustomGameAction.Caption := CaptionSettingsCustom;

  Self.Caption := CaptionMinesweeper;
  TimeGroupBox.Caption := CaptionTime;
  MinesGroupBox.Caption := CaptionMines;

  ElapsedSecondsLabel.Hint := HintElapsedSeconds;
  FLagsLabel.Hint := HintMinesLeft;
  NewGameButton.Hint := HintRestartGame;
end;

procedure TGameForm.CustomGameActionExecute(Sender: TObject);
var
  LDialog: TCustomSettingsDialog;
begin
  LDialog := TCustomSettingsDialog.Create(Self);
  try
    LDialog.Config := Game.Config;
    if LDialog.Execute then
    begin
      SetupGame(LDialog.Config);
    end;
  finally
    FreeAndNil(LDialog);
  end;
end;

procedure TGameForm.FormDestroy(Sender: TObject);
begin
  Game.Free;
end;

procedure TGameForm.FormShow(Sender: TObject);
begin
  if not Assigned(Game) then
    SetupGame(TMinesweeperGameConfigs.Beginner);
end;

procedure TGameForm.BeginnerGameActionExecute(Sender: TObject);
begin
  SetupGame(TMinesweeperGameConfigs.Beginner);
end;

procedure TGameForm.SetupGame(Config: TMinesweeperGameConfig);
begin
  if FSetupGameLocked then
    Exit;

  FSetupGameLocked := True;
  try
    FreeAndNil(Game);
    Game := TMinesweeperGame.Create(Config);
    Game.OnCellChange := HandleCellChange;
    Game.OnGameState := HandleGameState;
    Game.OnFlagCountChange := HandleFlagCountChange;
    SetupGrid;
    HandleFlagCountChange(Game, Game.MineCount);

  finally
    FSetupGameLocked := False;
  end;
end;

procedure TGameForm.SetupGrid;
begin
  DrawGrid1.ColCount := Game.Width;
  DrawGrid1.RowCount := Game.Height;
  DrawGrid1.DefaultColWidth := GRID_SIZE;
  DrawGrid1.DefaultRowHeight := GRID_SIZE;

  DrawGrid1.Width := Game.Width * GRID_SIZE + 4 + (Game.Width - 1) * DrawGrid1.GridLineWidth; // +2 für Ränder
  DrawGrid1.Height := Game.Height * GRID_SIZE + 4 + (Game.Height - 1) * DrawGrid1.GridLineWidth;

  Panel1.Width := DrawGrid1.Width;
end;

procedure TGameForm.Timer1Timer(Sender: TObject);
begin
  UpdateElapsed();
end;

procedure TGameForm.UpdateElapsed;
begin
  ElapsedSecondsLabel.Caption := string.Format('%3.3d', [Round(Game.ElapsedSeconds)]);
end;

procedure TGameForm.HandleCellChange(Sender: TObject; X, Y: Integer; const Cell: TCell);
begin
  DrawGrid1.Invalidate();
end;

procedure TGameForm.HandleGameState(Sender: TObject; State: TGameState);
begin
  NewGameButton.ImageIndex := Ord(State);
  Timer1.Enabled := State = TGameState.Playing;
  DrawGrid1.Invalidate;
  UpdateElapsed();
end;

procedure TGameForm.IntermediateGameActionExecute(Sender: TObject);
begin
  SetupGame(TMinesweeperGameConfigs.Intermediate);
end;

procedure TGameForm.RestartGameActionExecute(Sender: TObject);
begin
  Game.StartGame;
  SetupGrid;
  HandleFlagCountChange(Game, Game.MineCount);
  DrawGrid1.Invalidate;
end;

procedure TGameForm.HandleFlagCountChange(Sender: TObject; Count: Integer);
begin
  FlagsLabel.Caption := string.Format('%3.3d', [Count]);
end;

procedure TGameForm.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Canvas: TCanvas;
  Cell, SelectedCell: TCell;
  AdjacentSelection: TRect;
  ImageIndex: Integer;
begin
  AdjacentSelection := TRect.Create(DrawGrid1.Selection.Left, DrawGrid1.Selection.Top, DrawGrid1.Selection.Right + 1,
    DrawGrid1.Selection.Bottom + 1);
  AdjacentSelection.Inflate(1, 1);

  Canvas := DrawGrid1.Canvas;

  Cell := Game.GetCell(ACol, ARow);
  SelectedCell := Game.GetCell(DrawGrid1.Selection.Left, DrawGrid1.Selection.Top);

  ImageIndex := CELL_CLOSED;

  case Cell.State of
    TCellState.Hidden:
      if FShowAdjacentCells and (SelectedCell.State = TCellState.Revealed) and AdjacentSelection.Contains(TPoint.Create(ACol, ARow)) then
      begin
        ImageIndex := CELL_OPEN;
      end
      else
      begin
        if (Game.GameState <> TGameState.Playing) and (Cell.HasMine) then
          ImageIndex := CELL_MINE;
      end;

    TCellState.Questioned:
      ImageIndex := CELL_QM;

    TCellState.Flagged:
      ImageIndex := CELL_FLAG;

    TCellState.Revealed:
      begin
        if Cell.HasMine then
          ImageIndex := CELL_MINE_RED
        else
          ImageIndex := CELL_OPEN + Cell.AdjacentMines;
      end;
  end;

  CellImageList.Draw(Canvas, Rect.Left, Rect.Top, ImageIndex, dsNormal, itImage);
end;

procedure TGameForm.DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (Game.GameState = TGameState.Playing) then
  begin
    FShowAdjacentCells := True;
    DrawGrid1.Invalidate();
  end;
end;

procedure TGameForm.DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Integer;
begin
  FShowAdjacentCells := False;

  DrawGrid1.MouseToCell(X, Y, Col, Row);

  if (Col >= 0) and (Col < Game.Width) and (Row >= 0) and (Row < Game.Height) then
  begin
    if Button = mbLeft then
    begin
      Game.RevealCell(Col, Row);
    end
    else if Button = mbRight then
    begin
      Game.ToggleFlag(Col, Row);
    end;

    DrawGrid1.Invalidate();
  end;
end;

procedure TGameForm.ExpertGameActionExecute(Sender: TObject);
begin
  SetupGame(TMinesweeperGameConfigs.Expert);
end;

end.
