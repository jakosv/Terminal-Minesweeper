program main;

uses game, MainMenu, GameResults, keyboard, crt;

procedure ProceedGameResults(var GameState: TGame);
var
    GameTime: TDateTime;
    difficult: GameDifficult;
    ResultPosition: integer;
begin
    GameTime := GameState.GameTime;
    difficult := GameState.difficult;
    ResultPosition := ord(difficult) + 1;
    if IsNewRecord(GameTime, ResultPosition) then
        SaveResult(GameTime, ResultPosition);
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
