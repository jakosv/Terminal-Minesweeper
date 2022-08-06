unit game;

interface
uses GameCursor, GameField, widget, sysutils;
type
    GameDifficult = (GDEasy, GDMedium, GDHard);
    TGame = record
        GameOver, win, IsExit, IsRestart: boolean;
        difficult: GameDifficult;
        FlagsRemain: integer;
        StartTime, GameTime: TDateTime;
        field: TFieldPtr;
        cursor: TCursorPtr;
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

type
    PauseMenuButtons = (BNone, BContinue, BRestart, BExit);
const
    FieldHeight = 10;
    FieldWidth = 20;
    EasyBombsCount = 20;
    MediumBombsCount = 30;
    HardBombsCount = 40;
    DifficultMenuTitle = 'Choose difficult';
    PauseMenuTitle = 'Pause';
    PauseMenuItems: array [BContinue..BExit] of string = (
        'Continue',
        'Restart game',
        'Exit'
    );
    GameInfoFgcolor = LightGray;
    GameInfoBgcolor = Black;

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
    if not IsCellHidden(cursor^.x, cursor^.y, field) then
        exit;
    if IsActiveBomb(cursor^.x, cursor^.y, field) then
    begin
        GameState.GameOver := true;
        ShowFieldBombs(field);
    end
    else
        OpenEmptyFieldCell(cursor^.x, cursor^.y, field);
    UpdateCursor(cursor, field);
end;

procedure FlagKeyHandler(var GameState: TGame);
var
    cursor: TCursorPtr;
    field: TFieldPtr;
begin
    cursor := GameState.cursor;
    field := GameState.field;
    if not IsCellHidden(cursor^.x, cursor^.y, field) then
        exit;
    SetFieldCellFlag(cursor^.x, cursor^.y, field);
    if IsCellFlag(cursor^.x, cursor^.y, field) then
        GameState.FlagsRemain := GameState.FlagsRemain - 1
    else
        GameState.FlagsRemain := GameState.FlagsRemain + 1;
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

procedure ShowPauseMenu(var SelectedButton: PauseMenuButtons);
var
    SelectedItem: string;
    button: PauseMenuButtons;
    list: ListWidget;
begin
    SelectedButton := BNone;
    CreateListWidget(list, PauseMenuTitle);
    for button := BContinue to BExit do
        AddListWidgetItem(list, PauseMenuItems[button]);
    ShowListWidget(list, SelectedItem);
    RemoveListWidget(list);
    for button := BContinue to BExit do
        if SelectedItem = PauseMenuItems[button] then
        begin
            SelectedButton := button;
            break;
        end;
    clrscr;
end;

procedure PauseKeyHandler(var GameState: TGame);
var
    SelectedButton: PauseMenuButtons;
begin
    ShowPauseMenu(SelectedButton);
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
begin
    case key of
        ord('w'), KeyUp:
            MoveCursor(GameState.cursor, 0, -1, GameState.field);
        ord('s'), KeyDown:
            MoveCursor(GameState.cursor, 0, 1, GameState.field);
        ord('d'), KeyRight:
            MoveCursor(GameState.cursor, 1, 0, GameState.field);
        ord('a'), KeyLeft:
            MoveCursor(GameState.cursor, -1, 0, GameState.field);
        ord('f'):
            FlagKeyHandler(GameState);
        ord('x'):
            SuspiciousMarkKeyHandler(GameState);
        KeySpace:
            OpenKeyHandler(GameState);
        KeyEsc:
            PauseKeyHandler(GameState);
    end;
end;

procedure DrawGameInfo(str: string; x, y: shortint);
begin
    ClearLine(y);
    DrawText(str, x, y, GameInfoFgcolor, GameInfoBgcolor);
end;

procedure ShowGameInfo(var GameState: TGame);
var
    TimerMsg, FlagsMsg: string;
begin
    TimerMsg := 'Time: ' + TimeToStr(GameState.GameTime);
    FlagsMsg := 'Flags remain: ' + IntToStr(GameState.FlagsRemain);
    DrawGameInfo(TimerMsg, GameState.field^.x, GameState.field^.y - 4);
    DrawGameInfo(FlagsMsg, GameState.field^.x, GameState.field^.y - 3);
end;

procedure GameLoop(var GameState: TGame);
const
    DelayDuration = 30;
var
    key: integer;
begin
    ShowGameInfo(GameState);
    if not KeyPressed then
    begin
        delay(DelayDuration);
        exit;
    end;
    GetKey(key);
    KeyHandler(key, GameState);
end;

procedure GameEnd(var GameState: TGame);
var
    key: integer;
begin
    if GameState.GameOver then
    begin
        ShowFieldBombs(GameState.field);
        UpdateCursor(GameState.cursor, GameState.field);
        GetKey(key);
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
