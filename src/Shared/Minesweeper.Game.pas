unit Minesweeper.Game;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Math, System.Diagnostics;

type
  TCellState = (Hidden, Revealed, Flagged, Questioned);

  TCell = record
    HasMine: Boolean;
    AdjacentMines: Integer;
    State: TCellState;
  end;

  TBoard = array of array of TCell;

  TGameState = (Ready, Playing, Won, Lost);

  TCellChangeEvent = procedure(Sender: TObject; X, Y: Integer; const Cell: TCell) of object;
  TGameStateEvent = procedure(Sender: TObject; State: TGameState) of object;
  TFlagCountChangeEvent = procedure(Sender: TObject; Count: Integer) of object;

  TMinesweeperGameConfig = record
    Width: Integer;
    Height: Integer;
    MineCount: Integer;
    constructor Create(AWidth, AHeight, AMineCount: Integer);
  end;

  TMinesweeperGameConfigs = class abstract
  public const
    Beginner: TMinesweeperGameConfig = (Width: 8; Height: 8; MineCount: 10);
    Intermediate: TMinesweeperGameConfig = (Width: 16; Height: 16; MineCount: 40);
    Expert: TMinesweeperGameConfig = (Width: 30; Height: 16; MineCount: 99);
  end;

type
  TMinesweeperGame = class(TObject)
  private
    FStopwatch: TStopwatch;
    FBoard: TBoard;
    FConfig: TMinesweeperGameConfig;
    FGameState: TGameState;
    FRevealedCount: Integer;
    FFlagsPlaced: Integer;

    FOnCellChange: TCellChangeEvent;
    FOnGameState: TGameStateEvent;
    FOnFlagCountChange: TFlagCountChangeEvent;
    FRevealCounter: Integer;

    procedure InitializeBoard;
    procedure PlaceMines(ExcludeX, ExcludeY: Integer);
    procedure CalculateAdjacentMines;
    function IsValidCoord(X, Y: Integer): Boolean;
    function DoRevealCell(X, Y: Integer): Boolean;
    procedure DoRevealAdjacentCells(X, Y: Integer);
    procedure SetGameState(Value: TGameState);
    procedure CheckWinCondition;
    procedure UpdateFlagCount;
    function CountAdjacentFlags(X, Y: Integer): Integer;
    procedure SetOnGameState(const Value: TGameStateEvent);
    function GetElapsedSeconds: double;
  public
    constructor Create(AWidth, AHeight, AMineCount: Integer); overload;
    constructor Create(AConfig: TMinesweeperGameConfig); overload;
    destructor Destroy; override;

    procedure StartGame;
    procedure ToggleFlag(X, Y: Integer);
    procedure RevealCell(X, Y: Integer);

    property Config: TMinesweeperGameConfig read FConfig;
    property Width: Integer read FConfig.Width;
    property Height: Integer read FConfig.Height;
    property MineCount: Integer read FConfig.MineCount;
    property GameState: TGameState read FGameState;
    property FlagsPlaced: Integer read FFlagsPlaced;
    property ElapsedSeconds: double read GetElapsedSeconds;
    property RevealCounter: Integer read FRevealCounter;
    function GetCell(X, Y: Integer): TCell;

    property OnCellChange: TCellChangeEvent read FOnCellChange write FOnCellChange;
    property OnGameState: TGameStateEvent read FOnGameState write SetOnGameState;
    property OnFlagCountChange: TFlagCountChangeEvent read FOnFlagCountChange write FOnFlagCountChange;
  end;

implementation

{ TMinesweeperGameConfig }

constructor TMinesweeperGameConfig.Create(AWidth, AHeight, AMineCount: Integer);
begin
  Width := AWidth;
  Height := AHeight;
  MineCount := AMineCount;
end;

{ TMinesweeperGame }

constructor TMinesweeperGame.Create(AConfig: TMinesweeperGameConfig);
begin
  inherited Create;
  FConfig := AConfig;
  SetLength(FBoard, Width, Height);
  FStopwatch := TStopwatch.Create();
  StartGame;
end;

constructor TMinesweeperGame.Create(AWidth, AHeight, AMineCount: Integer);
begin
  Create(TMinesweeperGameConfig.Create(AWidth, AHeight, AMineCount));
end;

destructor TMinesweeperGame.Destroy;
begin
  SetLength(FBoard, 0, 0);
  inherited Destroy;
end;

procedure TMinesweeperGame.StartGame;
begin
  InitializeBoard;
  FRevealCounter := 0;
  FRevealedCount := 0;
  FFlagsPlaced := 0;
  UpdateFlagCount;
  SetGameState(TGameState.Ready);
end;

procedure TMinesweeperGame.InitializeBoard;
var
  X, Y: Integer;
begin
  for X := 0 to Width - 1 do
  begin
    for Y := 0 to Height - 1 do
    begin
      FBoard[X, Y].HasMine := False;
      FBoard[X, Y].AdjacentMines := 0;
      FBoard[X, Y].State := TCellState.Hidden;
    end;
  end;
end;

procedure TMinesweeperGame.PlaceMines(ExcludeX, ExcludeY: Integer);
var
  MinesToPlace: Integer;
  X, Y: Integer;
begin
  MinesToPlace := MineCount;
  while MinesToPlace > 0 do
  begin
    X := Random(Width);
    Y := Random(Height);

    if not FBoard[X, Y].HasMine and not((X = ExcludeX) and (Y = ExcludeY)) then
    begin
      FBoard[X, Y].HasMine := True;
      Dec(MinesToPlace);
    end;
  end;
end;

procedure TMinesweeperGame.CalculateAdjacentMines;
var
  X, Y, i, j, nx, ny, Count: Integer;
begin
  for X := 0 to Width - 1 do
  begin
    for Y := 0 to Height - 1 do
    begin
      if not FBoard[X, Y].HasMine then
      begin
        Count := 0;

        for i := -1 to 1 do
        begin
          for j := -1 to 1 do
          begin
            if (i = 0) and (j = 0) then
              Continue;

            nx := X + i;
            ny := Y + j;

            if IsValidCoord(nx, ny) then
            begin
              if FBoard[nx, ny].HasMine then
              begin
                Inc(Count);
              end;
            end;
          end;
        end;
        FBoard[X, Y].AdjacentMines := Count;
      end
      else
      begin
        FBoard[X, Y].AdjacentMines := -1;
      end;
    end;
  end;
end;

function TMinesweeperGame.IsValidCoord(X, Y: Integer): Boolean;
begin
  Result := (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height);
end;

procedure TMinesweeperGame.SetGameState(Value: TGameState);
begin
  if FGameState <> Value then
  begin
    FGameState := Value;

    case FGameState of
      TGameState.Ready:
        FStopwatch.Reset();
      TGameState.Playing:
        FStopwatch.Start();
      TGameState.Won:
        FStopwatch.Stop();
      TGameState.Lost:
        FStopwatch.Stop();
    end;

    if Assigned(FOnGameState) then
    begin
      FOnGameState(Self, Value);
    end;
  end;
end;

procedure TMinesweeperGame.SetOnGameState(const Value: TGameStateEvent);
begin
  FOnGameState := Value;
  if Assigned(Value) then
    Value(Self, GameState);
end;

function TMinesweeperGame.DoRevealCell(X, Y: Integer): Boolean;
begin
  Result := False;
  if not IsValidCoord(X, Y) or (FGameState > TGameState.Playing) then
    Exit;

  if FBoard[X, Y].State = TCellState.Flagged then
    Exit;

  if not(GameState = TGameState.Playing) then
  begin
    PlaceMines(X, Y);
    CalculateAdjacentMines;
    SetGameState(TGameState.Playing);
  end;

  Result := True;

  if FBoard[X, Y].State = TCellState.Revealed then
  begin
    if (FBoard[X, Y].AdjacentMines > 0) and (FBoard[X, Y].AdjacentMines = CountAdjacentFlags(X, Y)) then
      DoRevealAdjacentCells(X, Y);
    Exit;
  end;

  FBoard[X, Y].State := TCellState.Revealed;

  if Assigned(FOnCellChange) then
    FOnCellChange(Self, X, Y, FBoard[X, Y]);

  if FBoard[X, Y].HasMine then
  begin
    SetGameState(TGameState.Lost);
    Exit;
  end;

  Inc(FRevealedCount);

  if FBoard[X, Y].AdjacentMines = 0 then
  begin
    DoRevealAdjacentCells(X, Y);
  end;

  CheckWinCondition;
end;

procedure TMinesweeperGame.DoRevealAdjacentCells(X, Y: Integer);
var
  i, j, nx, ny: Integer;
begin
  for i := -1 to 1 do
  begin
    for j := -1 to 1 do
    begin
      if (i = 0) and (j = 0) then
        Continue;

      nx := X + i;
      ny := Y + j;

      if IsValidCoord(nx, ny) and (FBoard[nx, ny].State = TCellState.Hidden) then
      begin
        DoRevealCell(nx, ny);
      end;
    end;
  end;
end;

procedure TMinesweeperGame.RevealCell(X, Y: Integer);
begin
  if DoRevealCell(X, Y) then
    Inc(FRevealCounter);
end;

procedure TMinesweeperGame.ToggleFlag(X, Y: Integer);
begin
  if not IsValidCoord(X, Y) or (FGameState <> TGameState.Playing) then
    Exit;

  if FBoard[X, Y].State = TCellState.Revealed then
    Exit;

  case FBoard[X, Y].State of
    TCellState.Hidden:
      begin
        if FFlagsPlaced < MineCount then
        begin
          FBoard[X, Y].State := TCellState.Flagged;
          Inc(FFlagsPlaced);
        end
        else
        begin
          FBoard[X, Y].State := TCellState.Questioned;
        end;
      end;
    TCellState.Flagged:
      begin
        FBoard[X, Y].State := TCellState.Questioned;
        Dec(FFlagsPlaced);
      end;
    TCellState.Questioned:
      begin
        FBoard[X, Y].State := TCellState.Hidden;
      end;
  end;

  UpdateFlagCount;

  if Assigned(FOnCellChange) then
    FOnCellChange(Self, X, Y, FBoard[X, Y]);
end;

procedure TMinesweeperGame.UpdateFlagCount;
begin
  if Assigned(FOnFlagCountChange) then
    FOnFlagCountChange(Self, MineCount - FFlagsPlaced);
end;

procedure TMinesweeperGame.CheckWinCondition;
begin
  if FRevealedCount = (Width * Height - MineCount) then
  begin
    SetGameState(TGameState.Won);
  end;
end;

function TMinesweeperGame.CountAdjacentFlags(X, Y: Integer): Integer;
var
  i, j, nx, ny: Integer;
begin
  Result := 0;
  for i := -1 to 1 do
    for j := -1 to 1 do
      if not((i = 0) and (j = 0)) then
      begin
        nx := X + i;
        ny := Y + j;
        if Self.IsValidCoord(nx, ny) and (FBoard[nx, ny].State = TCellState.Flagged) then
          Inc(Result);
      end;
end;

function TMinesweeperGame.GetCell(X, Y: Integer): TCell;
begin
  if IsValidCoord(X, Y) then
    Result := FBoard[X, Y]
  else
    raise Exception.CreateFmt('Invalid coordinates (%d, %d)', [X, Y]);
end;

function TMinesweeperGame.GetElapsedSeconds: double;
begin
  Result := FStopwatch.Elapsed.TotalSeconds;
end;

end.
