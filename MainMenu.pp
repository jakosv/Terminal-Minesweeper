unit MainMenu;

interface
type
    MenuButton = (BNone, BStart, BResults, BControls, BAuthor, BExit);

procedure ShowMenu(var SelectedButton: MenuButton);
procedure ShowBestResults;
procedure ShowControlsSettings;
procedure ShowAuthorInfo;

implementation
uses game, widget, GameResults, keyboard, controls, sysutils, crt;

const
    MenuTitle = 'Menu';
    ControlsoTitle = 'Controls';
    ControlsSettingsTitle = 'Controls settings';
    AuthorInfoTitle = 'Author';
    ResultsTitle = 'Results';
    SaveControlsButton = 'Save';
    CancelControlsButton = 'Cancel';
    MenuItems: array [BStart..BExit] of string = (
        'Start game', 
        'Best results', 
        'Controls', 
        'Author', 
        'Exit'
    ); 
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

function ResultToStr(var result: TResult; difficult: GameDifficult)
                                                                : string;
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
    key: shortint;
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
    GetKey(key);
end;

procedure ParseControlStr(var str: string; var ControlName: string);
var
    i: shortint;
begin
    ControlName := '';
    for i := 1 to length(str) - 1 do
        if (str[i] = ' ') and (str[i + 1] = '-') then
            break
        else
            ControlName := ControlName + str[i]
end;

procedure GetNewControl(CurrentControl: TControl; 
    var ControlKeyCode: shortint);
var
    SaveKey, key: shortint;
    message, KeyName: string;
begin
    key := ControlKeyCode;
    SaveKey := key;
    while true do
    begin
        GetKeyName(key, KeyName);
        message := 'Key: ' + KeyName + '\nPress key again to apply';
        clrscr;
        ShowTextBox(ControlsNames[CurrentControl], message);
        GetKey(key);
        if key = SaveKey then
            break;
        SaveKey := key;
    end;
    ControlKeyCode := SaveKey;
end;

procedure ShowControlsSettings;
var
    SelectedItem, ControlDescription, KeyName, SelectedControlName: string;
    control: TControl;
    list: ListWidget;
    CurrentControls: ControlsArray;
begin
    LoadControls(CurrentControls);
    CreateListWidget(list, ControlsSettingsTitle);   
    for control := CKeyMoveUp to CKeyPause do
    begin
        GetControlDescription(control, CurrentControls, ControlDescription);
        AddListWidgetItem(list, ControlDescription);
    end;
    AddListWidgetSeparator(list);
    AddListWidgetItem(list, SaveControlsButton);
    AddListWidgetItem(list, CancelControlsButton);
    while true do
    begin
        ShowListWidget(list, SelectedItem);
        ParseControlStr(SelectedItem, SelectedControlName);
        GetControlByName(SelectedControlName, control);
        if SelectedItem = SaveControlsButton then
        begin
            SetControls(CurrentControls);
            break;
        end
        else if (SelectedItem = CancelControlsButton) or 
            (control = CKeyNone) then
        begin
            break;
        end;
        GetNewControl(control, CurrentControls[control]);
        GetControlDescription(control, CurrentControls, ControlDescription);
        UpdateListWidgetItem(list, ControlDescription); 
    end;
    RemoveListWidget(list);
end;

procedure ShowAuthorInfo;
var
    key: shortint;
begin
    ShowTextBox(AuthorInfoTitle, AuthorInfo);
    GetKey(key);
end;

end.
