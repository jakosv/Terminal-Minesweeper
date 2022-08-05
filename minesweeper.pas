program main;

uses game, widget, GameResults, sysutils, crt;

type
    MenuButton = (BStart, BResults, BControls, BAuthor, BExit);
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
    GameDifficults: array [GDEasy..GDHard] of string = (
        'Easy',
        'Medium',
        'Hard'
    );

procedure ShowMenu(var SelectedButton: MenuButton);
var
    SelectedItem: string;
    button: MenuButton;
    list: ListWidget;
begin
    CreateListWidget(list, MenuTitle);
    for button := BStart to BExit do
        AddListWidgetItem(list, MenuItems[button]);
    ShowListWidget(list, SelectedItem);
    RemoveListWidget(list);
    for button := BStart to BExit do
        if SelectedItem = MenuItems[button] then
            SelectedButton := button;
end;

function ResultPosition(difficult: GameDifficult): shortint;
begin
    ResultPosition := ord(difficult) + 1;
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
        text := text + GameDifficults[difficult] + ': ';
        if result.GameTime <> 0 then
        begin
            text := text + TimeToStr(result.GameTime) + ' | Date: ' + 
                DateTimeToStr(result.date)
        end
        else
            text := text + 'No results';
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

procedure CheckGameResults(var GameState: TGame);
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
    while true do
    begin
        clrscr;
        ShowMenu(SelectedButton);
        case SelectedButton of 
            BStart:
                StartGame(GameState);
            BResults:
                ShowBestResults();
            BControls:
                ShowControlsInfo();
            BAuthor:
                ShowAuthorInfo();
            else
                break;
        end;
        CheckGameResults(GameState);
    end;
    clrscr;
end.
