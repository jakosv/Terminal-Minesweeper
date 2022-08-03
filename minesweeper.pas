program main;

uses game, widget, crt;

type
    MenuButton = (BStart, BResults, BControls, BExit);
    ButtonsArray = array [BStart..BExit] of string;

const
    MenuItems: array [BStart..BExit] of string = (
        'Start game', 
        'Best results', 
        'Controls', 
        'Exit'
    ); 

procedure ShowMenu(var SelectedItem: string);
var
    button: MenuButton;
    list: ListWidget;
begin
    CreateListWidget(list, 'menu');
    for button := BStart to BExit do
        AddListWidgetItem(list, MenuItems[button]);
    ShowListWidget(list, SelectedItem);
    RemoveListWidget(list);
end;

procedure ShowBestResults();
begin

end;

procedure ShowControls();
begin

end;

var
    SelectedItem: string;
    button, SelectedButton: MenuButton;
    GameState: TGame;
begin
    clrscr;
    while true do
    begin
        ShowMenu(SelectedItem);
        for button := BStart to BExit do
            if SelectedItem = MenuItems[button] then
                SelectedButton := button;
        case SelectedButton of 
            BStart:
                StartGame(GameState);
            BResults:
                ShowBestResults();
            BControls:
                ShowControls();
            else
                break;
        end;
    end;
    clrscr;
end.
