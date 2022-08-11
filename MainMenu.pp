unit MainMenu;

interface
type
    MenuButton = (BNone, BStart, BResults, BControls, BAuthor, BExit);

procedure ShowMenu(var SelectedButton: MenuButton);
procedure ShowBestResults;
procedure ShowControlsInfo;
procedure ShowAuthorInfo;

implementation
uses game, widget, GameResults, sysutils, crt;

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
        'My github: https://github.com/jakosv';

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

procedure ShowBestResults;
var
    results: ArrayOfResults;
    result: TResult;
    ResultPosition: integer;
    difficult: GameDifficult;
    text: string;
begin
    text := '';
    GetResults(results);
    for difficult := GDEasy to GDHard do
    begin
        ResultPosition := ord(difficult) + 1;
        result := results[ResultPosition];
        text := text + ResultToStr(result, difficult);
        if difficult <> GDHard then
            text := text + '\n';
    end;
    ShowTextBox(ResultsTitle, text);
end;

procedure ShowControlsInfo;
begin
    ShowTextBox(ControlsInfoTitle, ControlsInfo);
end;

procedure ShowAuthorInfo;
begin
    ShowTextBox(AuthorInfoTitle, AuthorInfo);
end;

end.
