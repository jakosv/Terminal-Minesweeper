unit game;

interface
uses GameCursor, GameField;
type
    GameDifficult = (GDEasy, GDMedium, GDHard);
    TGame = record
        GameOver, win: boolean;
        difficult: GameDifficult;
        FlagsRemain: integer;
        field: TFieldPtr;
        cursor: TCursorPtr;
    end;

procedure StartGame(var GameState: TGame);

implementation
uses keyboard, menu, crt;

const
    FieldHeight = 10;
    FieldWidth = 20;
    EasyBombsCount = 20;
    MediumBombsCount = 30;
    HardBombsCount = 40;

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
        ShowFieldBombs(GameState.field);
    end;
    IsGameOver := GameState.GameOver;
end;

procedure GetGameDifficult(var GameState: TGame);
begin
    { ShowMenu(); }
    GameState.difficult := GDEasy;
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
        OpenFieldCell(cursor^.x, cursor^.y, field);
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
        begin
            GameState.GameOver := true;
            {ShowPauseMenu(IsExit);
            if IsExit then
                ExitGame(GameState);}
        end;
    end;
end;

procedure GameLoop(var GameState: TGame);
const
    DelayDuration = 30;
var
    key: integer;
begin
    { ShowGameInfo(GameState); }
    if not KeyPressed then
    begin
        delay(DelayDuration);
        exit;
    end;
    GetKey(key);
    KeyHandler(key, GameState);
end;

procedure GameEnd(var GameState: TGame);
begin
    RemoveField(GameState.field);
    RemoveCursor(GameState.cursor);
end;

procedure StartGame(var GameState: TGame);
begin
    GetGameDifficult(GameState);
    InitGame(GameState);
    while not IsGameOver(GameState) do
        GameLoop(GameState);
    GameEnd(GameState);
end;

end.
