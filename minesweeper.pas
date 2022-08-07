program main;

uses game, widget, GameResults, sysutils, keyboard, crt;

type
    MenuButton = (BNone, BStart, BResults, BControls, BAuthor, BExit);
    ButtonsArray = array [BStart..BExit] of string;

const
    MenuTitle = 'Menu';
    ControlsInfoTitle = 'Controls';
    AuthorInfoTitle = 'Author';
    ResultsTitle = 'Results';
    MenuItems: array [BStart..BExit] of string = (
        'Start game', 
        'Best results', 
        'Controls', 
        'Author', 
        'Exit'
    ); 
    ControlsInfo = 'w/ArrowUp - move up\n' +
        'a/ArrowLeft - move left\n' +
        's/ArrowDown - move down\n' +
        'd/ArrowRight - move right\n' +
        'Space - open cell\n' +
        'f - set flag\n' +
        'x - mark cell suspicious\n' +
        'Esc - pause';
    AuthorInfo = 'Hello, world! I am Jakos! :D\n' +
        'This is my terminal minesweeper game\nwritten in Free Pascal.\n' +
        'It is also an Open Source.\n' + 
        'Any bugs? My github: github.com/jakosv';

procedure ShowMenu(var SelectedButton: MenuButton);
var
    SelectedItem: string;
    button: MenuButton;
    list: ListWidget;
begin
    clrscr;
    CreateListWidget(list, MenuTitle);
    for button := BStart to BExit do
        AddListWidgetItem(list, MenuItems[button]);
    ShowListWidget(list, SelectedItem);
    RemoveListWidget(list);
    for button := BStart to BExit do
        if SelectedItem = MenuItems[button] then
        begin
            SelectedButton := button;
            break;
        end;
    clrscr;
end;

function ResultPosition(difficult: GameDifficult): shortint;
begin
    ResultPosition := ord(difficult) + 1;
end;

function ResultToStr(var result: TResult; difficult: GameDifficult): string;
var
    str: string;
begin
    str := DifficultNames[difficult] + ': ';
    if result.GameTime <> 0 then
    begin
        str := str + TimeToStr(result.GameTime) + ' | Date: ' + 
            DateTimeToStr(result.date)
    end
    else
        str := str + 'no result';
    ResultToStr := str;
end;

procedure ShowBestResults();
var
    results: ArrayOfResults;
    result: TResult;
    difficult: GameDifficult;
    text: string;
begin
    text := '';
    GetResults(results);
    for difficult := GDEasy to GDHard do
    begin
        result := results[ResultPosition(difficult)];
        text := text + ResultToStr(result, difficult);
        if difficult <> GDHard then
            text := text + '\n';
    end;
    ShowTextBox(ResultsTitle, text);
end;

procedure ShowControlsInfo();
begin
    ShowTextBox(ControlsInfoTitle, ControlsInfo);
end;

procedure ShowAuthorInfo;
begin
    ShowTextBox(AuthorInfoTitle, AuthorInfo);
end;

procedure ProceedGameResults(var GameState: TGame);
var
    GameTime: TDateTime;
    difficult: GameDifficult;
    win: boolean;
begin
    GameTime := GameState.GameTime;
    difficult := GameState.difficult;
    win := GameState.win;
    if win and IsNewRecord(GameTime, ResultPosition(difficult)) then
        SaveResult(GameTime, ResultPosition(difficult));
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
