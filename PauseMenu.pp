unit PauseMenu;

interface
type
    PauseMenuButtons = (BNone, BContinue, BRestart, BExit);

procedure ShowPauseMenu(var SelectedButton: PauseMenuButtons);

implementation
uses widget, crt;
const
    PauseMenuTitle = 'Pause';
    PauseMenuItems: array [BContinue..BExit] of string = (
        'Continue',
        'Restart game',
        'Exit'
    );

procedure ShowPauseMenu(var SelectedButton: PauseMenuButtons);
var
    SelectedItem: string;
    button: PauseMenuButtons;
    list: ListWidget;
begin
    SelectedButton := BNone;
    CreateListWidget(list, PauseMenuTitle);
    for button := BContinue to BExit do
        AddListWidgetItem(list, PauseMenuItems[button]);
    ShowListWidget(list, SelectedItem);
    RemoveListWidget(list);
    for button := BContinue to BExit do
        if SelectedItem = PauseMenuItems[button] then
        begin
            SelectedButton := button;
            break;
        end;
    clrscr;
end;
end.
