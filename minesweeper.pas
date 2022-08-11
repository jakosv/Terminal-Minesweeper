program main;

uses game, MainMenu, GameResults, widget, keyboard, crt, sysutils;

const
    NewRecordTitle = 'New record!';
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

var
    GameState: TGame;
    SelectedButton: MenuButton;
begin
    GameState.IsRestart := false;
    while true do
    begin
        if not GameState.IsRestart then
        begin
            SelectedButton := BNone;
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
                ShowControlsInfo();
            BAuthor:
                ShowAuthorInfo();
            else
                break;
        end;
    end;
    clrscr;
end.
