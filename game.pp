unit game;

interface
uses GameCursor, GameField, PauseMenu, widget, controls, sysutils;
type
    GameDifficult = (GDEasy, GDMedium, GDHard);
    TGame = record
        GameOver, win, IsExit, IsRestart: boolean;
        difficult: GameDifficult;
        FlagsRemain: integer;
        StartTime, GameTime: TDateTime;
        field: TFieldPtr;
        cursor: TCursorPtr;
        controls: ControlsArray;
    end;

const
    DifficultNames: array [GDEasy..GDHard] of string = (
        'Easy',
        'Medium',
        'Hard'
    );

procedure StartGame(var GameState: TGame);

implementation
uses keyboard, crt;

const
    FieldHeight = 10;
    FieldWidth = 20;
    EasyBombsCount = 20;
    MediumBombsCount = 25;
    HardBombsCount = 30;
    DifficultMenuTitle = 'Choose difficult';
    GameInfoFgcolor = LightGray;
    GameInfoBgcolor = Black;
    GameOverMessageColor = Red;
    WinMessage = 'You win! Press any key';
    LoseMessage = 'You lose! Press any key';
    PlayAgainMessage = 'Play again?';
    GameOverMessageLine = 5;
    FlagsInfoLine = 3;
    TimerLine = 4;

function GetBombsCount(difficult: GameDifficult): integer;
begin
    case difficult of
        GDEasy:
            GetBombsCount := EasyBombsCount;
        GDMedium:
            GetBombsCount := MediumBombsCount;
        GDHard:
            GetBombsCount := HardBombsCount;
    end;
end;

procedure InitGame(var GameState: TGame);
var
    FieldX, FieldY: shortint;
    BombsCount: integer;
begin
    GameState.GameOver := false;
    GameState.win := false;
    GameState.IsExit := false;
    GameState.IsRestart := false;
    GameState.StartTime := Time;
    GameState.GameTime := 0;
    FieldX := (ScreenWidth - FieldWidth) div 2;
    FieldY := (ScreenHeight - FieldHeight) div 2;
    BombsCount := GetBombsCount(GameState.difficult);
    GameState.FlagsRemain := BombsCount;
    CreateField(FieldHeight, FieldWidth, FieldX, FieldY, BombsCount, 
        GameState.field);
    CreateCursor(GameState.field, GameState.cursor); 
    LoadControls(GameState.controls);
end;

function IsGameOver(var GameState: TGame): boolean;
begin
    if (not ExistActiveBomb(GameState.field)) and
        (not ExistHiddenEmptyCell(GameState.field)) then
    begin
        GameState.GameOver := true;
        GameState.win := true;
    end;
    IsGameOver := 
        GameState.GameOver or GameState.IsExit or GameState.IsRestart;
end;

procedure GetGameDifficult(var GameState: TGame);
var
    SelectedItem: string;
    difficult: GameDifficult;
    list: ListWidget;
begin
    clrscr;
    CreateListWidget(list, DifficultMenuTitle);
    GameState.difficult := GDEasy;
    for difficult := GDEasy to GDHard do
        AddListWidgetItem(list, DifficultNames[difficult]);
    ShowListWidget(list, SelectedItem);
    RemoveListWidget(list);
    for difficult := GDEasy to GDHard do
        if SelectedItem = DifficultNames[difficult] then
        begin
            GameState.difficult := difficult;
            break;
        end;
    clrscr;
end;

procedure OpenKeyHandler(var GameState: TGame);
var
    cursor: TCursorPtr;
    field: TFieldPtr;
begin
    cursor := GameState.cursor;
    field := GameState.field;
    if not IsCellHidden(cursor^.x, cursor^.y, field) or
        IsCellFlag(cursor^.x, cursor^.y, field) then
    begin
        exit;
    end;
    if IsActiveBomb(cursor^.x, cursor^.y, field) then
    begin
        GameState.GameOver := true;
        ShowFieldBombs(field);
    end
    else
        OpenEmptyFieldCell(cursor^.x, cursor^.y, field);
    UpdateCursor(cursor, field);
end;

function CountDigits(number: integer): integer;
var
    count: integer;
begin
    count := 0;
    while number <> 0 do
    begin
        count := count + 1;
        number := number div 10;
    end;
    CountDigits := count;
end;

procedure FlagKeyHandler(var GameState: TGame);
var
    cursor: TCursorPtr;
    field: TFieldPtr;
    FlagsRemain: integer;
begin
    cursor := GameState.cursor;
    field := GameState.field;
    if not IsCellHidden(cursor^.x, cursor^.y, field) then
        exit;
    SetFieldCellFlag(cursor^.x, cursor^.y, field);
    if IsCellFlag(cursor^.x, cursor^.y, field) then
        FlagsRemain := GameState.FlagsRemain - 1
    else
        FlagsRemain := GameState.FlagsRemain + 1;
    if CountDigits(FlagsRemain) <> CountDigits(GameState.FlagsRemain) then
        ClearLine(FlagsInfoLine);
    GameState.FlagsRemain := FlagsRemain;
    UpdateCursor(cursor, field);
end;

procedure SuspiciousMarkKeyHandler(var GameState: TGame);
var
    cursor: TCursorPtr;
    field: TFieldPtr;
begin
    cursor := GameState.cursor;
    field := GameState.field;
    if not IsCellHidden(cursor^.x, cursor^.y, field) then
        exit;
    SetFieldCellSuspicious(cursor^.x, cursor^.y, field);
    UpdateCursor(cursor, field);
end;

procedure PauseKeyHandler(var GameState: TGame);
var
    SelectedButton: PauseMenuButtons;
    PauseTimestamp: TDateTime;
begin
    PauseTimestamp := Time;
    ShowPauseMenu(SelectedButton);
    GameState.StartTime := GameState.StartTime + (Time - PauseTimestamp); 
    case SelectedButton of
        BRestart:
            GameState.IsRestart := true;
        BExit:
            GameState.IsExit := true;
        else begin
            DrawField(GameState.field);
            DrawCursor(GameState.cursor, GameState.field);
        end;
    end;
end;

procedure KeyHandler(key: integer; var GameState: TGame);
var
    CurrentControls: ControlsArray; 
begin
    CurrentControls := GameState.controls;
    if key = CurrentControls[CKeyMoveUp] then
        MoveCursor(GameState.cursor, 0, -1, GameState.field)
    else if key = CurrentControls[CKeyMoveDown] then
        MoveCursor(GameState.cursor, 0, 1, GameState.field)
    else if key = CurrentControls[CKeyMoveRight] then
        MoveCursor(GameState.cursor, 1, 0, GameState.field)
    else if key = CurrentControls[CKeyMoveLeft] then
        MoveCursor(GameState.cursor, -1, 0, GameState.field)
    else if key = CurrentControls[CKeyFlag] then
        FlagKeyHandler(GameState)
    else if key = CurrentControls[CKeySuspicious] then
        SuspiciousMarkKeyHandler(GameState)
    else if key = CurrentControls[CKeyOpen] then
        OpenKeyHandler(GameState)
    else if key = CurrentControls[CKeyPause] then
        PauseKeyHandler(GameState);
end;

procedure ShowGameInfo(var GameState: TGame);
var
    TimerMsg, FlagsMsg: string;
begin
    TimerMsg := 'Time: ' + TimeToStr(GameState.GameTime);
    FlagsMsg := 'Flags remain: ' + IntToStr(GameState.FlagsRemain);
    DrawText(TimerMsg, GameState.field^.x, TimerLine, GameInfoFgcolor, 
        GameInfoBgcolor);
    DrawText(FlagsMsg, GameState.field^.x, FlagsInfoLine, GameInfoFgcolor, 
        GameInfoBgcolor);
end;

procedure GameLoop(var GameState: TGame);
const
    DelayDuration = 30;
var
    key: integer;
begin
    GameState.GameTime := Time - GameState.StartTime;
    ShowGameInfo(GameState);
    if not KeyPressed then
    begin
        delay(DelayDuration);
        exit;
    end;
    GetKey(key);
    KeyHandler(key, GameState);
end;

procedure ShowPlayAgainDialog(var answer: boolean);
begin
    ShowConfirm(PlayAgainMessage, answer, true);
end;

procedure GameEnd(var GameState: TGame);
var
    key: integer;
begin
    if GameState.GameOver then
    begin
        ShowFieldBombs(GameState.field);
        UpdateCursor(GameState.cursor, GameState.field);
        if GameState.win then
            DrawText(WinMessage, GameState.field^.x, GameOverMessageLine,
                GameOverMessageColor, GameInfoBgcolor)
        else
            DrawText(LoseMessage, GameState.field^.x, GameOverMessageLine, 
                GameOverMessageColor, GameInfoBgcolor);
        GetKey(key);
        ShowPlayAgainDialog(GameState.IsRestart);
    end;
    RemoveField(GameState.field);
    RemoveCursor(GameState.cursor);
end;

procedure StartGame(var GameState: TGame);
begin
    clrscr;
    if not GameState.IsRestart then
        GetGameDifficult(GameState);
    InitGame(GameState);
    while not IsGameOver(GameState) do
        GameLoop(GameState);
    GameEnd(GameState);
end;

end.
