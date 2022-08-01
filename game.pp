unit game;

interface
uses cursor, field;
type
    GameDifficult = (GDEasy, GDMedium, GDHard);
    TGame = record
        GameOver, win: boolean;
        FlagsCount: shortint;
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

procedure SetGameDifficult(difficult: GameDifficult; var GameState: TGame);
begin
    case difficult of
        GDEasy:
            GameState.FlagsCount := EasyBombsCount;
        GDMedium:
            GameState.FlagsCount := MediumBombsCount;
        GDHard:
            GameState.FlagsCount := HardBombsCount;
    end;
end;

procedure InitGame(difficult: GameDifficult; var GameState: TGame);
var
    FieldX, FieldY: shortint;
begin
    GameState.GameOver := false;
    GameState.win := false;
    SetGameDifficult(difficult, GameState);
    FieldX := (ScreenWidth - FieldWidth) div 2;
    FieldY := (ScreenHeight - FieldHeight) div 2;
    CreateField(FieldHeight, FieldWidth, FieldX, FieldY, 
        10, GameState.FieldPtr);
    CreateCursor(GameState.FieldPtr, CursorColor, GameState.CursorPtr); 
end;

function IsGameOver(var GameState: TGame): boolean;
begin
    if not ExistActiveBomb(GameState.FieldPtr) then
    begin
        GameState.GameOver := true;
        GameState.win := true;
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
    if GameState.FlagsCount = 0 then
        exit;
    MarkFlagCursor(GameState.CursorPtr);
    GameState.FlagsCount := GameState.FlagsCount - 1;
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
            MarkSuspiciousCursor(GameState.CursorPtr);
        KeySpace:
            OpenCursorCell(GameState.CursorPtr);
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

procedure StartGame(var GameState: TGame);
var
    difficult: GameDifficult;
begin
    GetGameDifficult(difficult);
    InitGame(difficult, GameState);
    DrawField(GameState.FieldPtr);
    DrawCursor(GameState.CursorPtr);
    while not IsGameOver(GameState) do
        GameLoop(GameState);
    RemoveField(GameState.FieldPtr);
    RemoveCursor(GameState.CursorPtr);
end;

end.
