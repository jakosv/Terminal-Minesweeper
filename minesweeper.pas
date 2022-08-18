program main;

uses game, MainMenu, GameResults, widget, keyboard, crt, sysutils;

const
    NewRecordTitle = 'New record!';
    LogoWidth = 60;
    LogoHeight = 6;
    logo: array [1..LogoHeight] of string = (
        ' __  __ _'#10,
        '|  \/  (_)_ __   ___  _____      _____  ___ _ __   ___ _ __'#10,
        '| |\/| | | ''_ \ / _ \/ __\ \ /\ / / _ \/ _ \ ''_ \ / _ \ ''__|'#10,
        '| |  | | | | | |  __/\__ \\ V  V /  __/  __/ |_) |  __/ |'#10,
        '|_|  |_|_|_| |_|\___||___/ \_/\_/ \___|\___| .__/ \___|_|'#10,
        '                                           |_|'
    );

procedure ProceedGameResults(var GameState: TGame);
var
    GameTime: TDateTime;
    difficult: GameDifficult;
    ResultPosition: integer;
    message: string;
begin
    GameTime := GameState.GameTime;
    difficult := GameState.difficult;
    ResultPosition := ord(difficult) + 1;
    if IsNewRecord(GameTime, ResultPosition) then
    begin
        clrscr;
        message := 
            DifficultNames[difficult] + ': ' + TimeToStr(GameState.GameTime);
        ShowTextBox(NewRecordTitle, message);
        SaveResult(GameTime, ResultPosition);
    end;
end;

procedure PrintLogo;
var
    i, x, y: shortint;
begin
    x := (ScreenWidth - LogoWidth) div 2 + 1;
    y := ScreenHeight div 2 + 1 - 2 * LogoHeight;
    for i := 1 to LogoHeight do
    begin
        GotoXY(x, y + i - 1);
        write(logo[i]);
    end;
    GotoXY(1, 1);
end;

var
    GameState: TGame;
    SelectedButton: MenuButton;
begin
    GameState.IsRestart := false;
    while true do
    begin
        clrscr;
        if not GameState.IsRestart then
        begin
            SelectedButton := BNone;
            PrintLogo;
            ShowMenu(SelectedButton);
        end;
        case SelectedButton of 
            BStart: begin
                StartGame(GameState);
                if GameState.win then
                    ProceedGameResults(GameState);
            end;
            BResults:
                ShowBestResults();
            BControls:
                ShowControlsSettings();
            BAuthor:
                ShowAuthorInfo();
            else
                break;
        end;
    end;
    clrscr;
end.
