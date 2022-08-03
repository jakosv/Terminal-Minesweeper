unit game;

interface
uses cursor, field;
type
    GameDifficult = (GDEasy, GDMedium, GDHard);
    TGame = record
        GameOver, win: boolean;
        difficult: GameDifficult;
        FlagsRemain: integer;
        FieldPtr: TFieldPtr;
        CursorPtr: TCursorPtr;
    end;

procedure StartGame(var GameState: TGame);

implementation
uses keyboard, menu, crt;

const
    CursorColor = White;
    FieldHeight = 10;
    FieldWidth = 20;
    EasyBombsCount = 10;
    MediumBombsCount = 30;
    HardBombsCount = 90;

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

procedure InitGame(difficult: GameDifficult; var GameState: TGame);
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
        GameState.FieldPtr);
    CreateCursor(GameState.FieldPtr, CursorColor, GameState.CursorPtr); 
end;

function IsGameOver(var GameState: TGame): boolean;
begin
    if (not ExistActiveBomb(GameState.FieldPtr)) and
        (GameState.FlagsRemain = 0) then
    begin
        GameState.GameOver := true;
        GameState.win := true;
        ShowFieldBombs(GameState.FieldPtr);
    end;
    IsGameOver := GameState.GameOver;
end;

procedure GetGameDifficult(var difficult: GameDifficult);
begin
    { ShowMenu(); }
    difficult := GDEasy;
end;

procedure FlagKeyHandler(var GameState: TGame);
begin
    SetCursorFlag(GameState.CursorPtr);
    GameState.FlagsRemain := 
        GetBombsCount(GameState.difficult) - 
        FieldFlagsCount(GameState.FieldPtr);
end;

procedure OpenKeyHandler(var GameState: TGame);
var
    IsBomb: boolean;
begin
    OpenCursorCell(GameState.CursorPtr, IsBomb);
    if IsBomb then
        GameState.GameOver := true;
end;

procedure KeyHandler(key: integer; var GameState: TGame);
begin
    case key of
        ord('w'), KeyUp:
            MoveCursor(GameState.CursorPtr, 0, -1);
        ord('s'), KeyDown:
            MoveCursor(GameState.CursorPtr, 0, 1);
        ord('d'), KeyRight:
            MoveCursor(GameState.CursorPtr, 1, 0);
        ord('a'), KeyLeft:
            MoveCursor(GameState.CursorPtr, -1, 0);
        ord('f'):
            FlagKeyHandler(GameState);
        ord('x'):
            SetCursorSuspicious(GameState.CursorPtr);
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
    RemoveField(GameState.FieldPtr);
    RemoveCursor(GameState.CursorPtr);
end;

procedure StartGame(var GameState: TGame);
var
    difficult: GameDifficult;
begin
    GetGameDifficult(difficult);
    InitGame(difficult, GameState);
    while not IsGameOver(GameState) do
        GameLoop(GameState);
    GameEnd(GameState);
end;

end.
