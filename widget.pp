unit widget;

interface
uses crt;

const
    InterfaceFgcolor = Black;
    InterfaceBgcolor = LightGray;

type
    ListWidgetItemPtr = ^ListWidgetItem;
    ListWidgetItem = record
        data: string;
        prev, next: ListWidgetItemPtr; 
    end;
    ListWidget = record
        FirstItem, LastItem, SelectedItem: ListWidgetItemPtr;
        ItemsCount, MaxItemSize: integer;
        title: string;
    end;

procedure CreateListWidget(var list: ListWidget; title: string);
procedure RemoveListWidget(var list: ListWidget);
procedure ShowListWidget(var list: ListWidget; var selection: string);
procedure DrawText(data: string; x, y: integer; fgcolor, bgcolor: word; 
    IsBlink: boolean);
procedure ClearLine(LineNumber: integer);
procedure AddListWidgetItem(var list: ListWidget; item: string);
procedure NextListWidgetItem(var list: ListWidget);
procedure PrevListWidgetItem(var list: ListWidget);
procedure ShowTextBox(title: string; content: string);
procedure ShowMessage(msg: string);
procedure ShowConfirm(msg: string; var answer: boolean; DefaultFirst: boolean);

implementation
uses keyboard;

const
    FormTopIndent = 1;
    FormBottomIndent = 1;
    FormHorizontalIndent = 3;
    ListSelectionFgcolor = InterfaceBgcolor;
    ListSelectionBgcolor = InterfaceFgcolor;

type
    TForm = record
        title: string;
        x, y, height, width: integer;
    end;

procedure DrawLine(x, y, size: integer);
var
    i, SaveTextAttr: integer;
begin
    SaveTextAttr := TextAttr;
    GotoXY(x, y);
    TextBackground(InterfaceBgcolor);
    for i:=1 to size do
        write(' '); 
    GotoXY(1, 1);
    TextAttr := SaveTextAttr;
end;

procedure DrawText(data: string; x, y: integer; fgcolor, bgcolor: word; 
    IsBlink: boolean);
var
    i, SaveTextAttr: integer;
begin
    SaveTextAttr := TextAttr;
    GotoXY(x, y);
    if IsBlink then
        TextColor(fgcolor + blink)
    else
        TextColor(fgcolor);
    TextBackground(bgcolor);
    for i:=1 to length(data) do
        write(data[i]);
    GotoXY(1, 1);
    TextAttr := SaveTextAttr;
end;

procedure ClearLine(LineNumber: integer);
var
    i: integer;
begin
    GotoXY(1, LineNumber);
    for i:=1 to ScreenWidth do
        write(' ');
end;

procedure DrawFormTitle(var form: TForm);
var
    TitleX, i, SaveTextAttr: integer;
begin
    SaveTextAttr := TextAttr;
    TitleX := (form.x + (form.width - length(form.title)) div 2);
    GotoXY(form.x, form.y);
    TextColor(InterfaceFgcolor);
    TextBackground(InterfaceBgcolor);
    for i:=form.x to TitleX - 1 do
        write('=');
    write(form.title);
    for i:=(TitleX + length(form.title)) to (form.x + form.width - 1) do
        write('=');
    GotoXY(1, 1);
    TextAttr := SaveTextAttr;
end;

procedure DrawForm(var form: TForm);
var
    i: integer;
begin
    DrawFormTitle(form);
    for i:=1 to form.height do
        DrawLine(form.x, form.y + i, form.width);
end;


procedure CreateForm(var form: TForm; height, width: integer; title: string);
begin
    if length(title) > width then
        form.width := length(title) + 2*FormHorizontalIndent
    else
        form.width := width + 2*FormHorizontalIndent;
    form.height := height + FormTopIndent + FormBottomIndent;
    form.x := (ScreenWidth - form.width + 1) div 2;
    form.y := (ScreenHeight - form.height + 1) div 2;
    form.title := title;
    if form.title <> '' then
        form.title := ' ' + form.title + ' ';
    DrawForm(form);
end;

procedure CreateListWidget(var list: ListWidget; title: string);
begin
    list.FirstItem := nil;
    list.LastItem := nil;
    list.SelectedItem := nil;
    list.ItemsCount := 0;
    list.MaxItemSize := 0;
    list.title := title;
end;

procedure RemoveListWidget(var list: ListWidget);
var
    tmp: ListWidgetItemPtr;
begin
    while list.ItemsCount > 0 do
    begin
        tmp := list.FirstItem;
        list.FirstItem := list.FirstItem^.next;
        dispose(tmp);
        list.ItemsCount := list.ItemsCount - 1;
    end;
    list.FirstItem := nil;
    list.LastItem := nil;
    list.MaxItemSize := 0;
    list.title := '';
end;

procedure DrawFormTextLine(var form: TForm; var data: string; 
    LineNumber: integer; fgcolor, bgcolor: word);
var
    EmptySpaceSymbols, i, SaveTextAttr: integer;
begin
    SaveTextAttr := TextAttr;
    GotoXY(form.x + FormHorizontalIndent, form.y + LineNumber + FormTopIndent);
    TextColor(fgcolor);
    TextBackground(bgcolor);
    write(data);
    EmptySpaceSymbols := (form.width - 2*FormHorizontalIndent - length(data));
    for i:=1 to EmptySpaceSymbols do
        write(' ');
    GotoXY(1, 1);
    TextAttr := SaveTextAttr;
end;

procedure DrawFormTextLineCenter(var form: TForm; var data: string; 
    LineNumber: integer; fgcolor, bgcolor: word);
var
    LeftSpace, RightSpace, TextX, i, SaveTextAttr: integer;
begin
    SaveTextAttr := TextAttr;
    GotoXY(form.x + FormHorizontalIndent, form.y + LineNumber + FormTopIndent);
    TextColor(fgcolor);
    TextBackground(bgcolor);
    TextX := form.x + FormHorizontalIndent + (form.width - length(data) -
        2*FormHorizontalIndent) div 2 - 1;
    LeftSpace := (TextX - form.x - FormHorizontalIndent) + 1;
    for i:=1 to LeftSpace do
        write(' ');
    write(data);
    RightSpace := form.width - length(data) - LeftSpace - 
        2*FormHorizontalIndent;
    for i:=1 to RightSpace do
        write(' ');
    GotoXY(1, 1);
    TextAttr := SaveTextAttr;
end;

procedure DrawListWidget(var list: ListWidget);
var
    form: TForm;
    tmp: ListWidgetItemPtr;
    LineNumber: integer;
begin
    CreateForm(form, list.ItemsCount, list.MaxItemSize, list.title);  
    DrawForm(form);
    LineNumber := 1;
    tmp := list.FirstItem;
    while tmp <> nil do
    begin
        if list.SelectedItem = tmp then
            DrawFormTextLineCenter(form, tmp^.data, LineNumber, 
                ListSelectionFgcolor,ListSelectionBgcolor)
        else
            DrawFormTextLineCenter(form, tmp^.data, LineNumber, 
                InterfaceFgcolor, InterfaceBgcolor);
        tmp := tmp^.next;
        LineNumber := LineNumber + 1;
    end;
end;

procedure ShowListWidget(var list: ListWidget; var selection: string);
var
    key: integer;
begin
    while true do
    begin
        DrawListWidget(list);
        GetKey(key);
        case key of
            KeyDown, ord('s'):
                NextListWidgetItem(list);
            KeyUp, ord('w'):
                PrevListWidgetItem(list);
            KeyEnter: begin
                selection := list.SelectedItem^.data;
                break;
            end;
            ord('q'), KeyEsc: begin
                selection := '';
                break;
            end;
        end;
    end;
end;

procedure AddListWidgetItem(var list: ListWidget; item: string);
var
    tmp: ListWidgetItemPtr;
begin
    new(tmp); 
    if list.FirstItem = nil then
        list.FirstItem := tmp
    else
        list.LastItem^.next := tmp;
    tmp^.data := item;
    tmp^.next := nil;
    tmp^.prev := list.LastItem;
    list.LastItem := tmp;
    list.ItemsCount := list.ItemsCount + 1;
    if length(item) > list.MaxItemSize then
        list.MaxItemSize := length(item);
    if list.SelectedItem = nil then
        list.SelectedItem := list.FirstItem;
end;

procedure NextListWidgetItem(var list: ListWidget);
begin
    if list.ItemsCount = 0 then
        exit;
    list.SelectedItem := list.SelectedItem^.next; 
    if list.SelectedItem = nil then
        list.SelectedItem := list.FirstItem;
end;

procedure PrevListWidgetItem(var list: ListWidget);
begin
    if list.ItemsCount = 0 then
        exit;
    list.SelectedItem := list.SelectedItem^.prev; 
    if list.SelectedItem = nil then
        list.SelectedItem := list.LastItem;
end;

procedure DrawMessageLine(x, y, size: integer; var msg: string; 
    MessageWidth: integer);
var
    i, SaveTextAttr: integer;
begin
    SaveTextAttr := TextAttr;
    TextColor(InterfaceFgcolor);
    TextBackground(InterfaceBgcolor);
    GotoXY(x, y);
    write(' ');
    for i:=1 to MessageWidth do
        write(msg[i]);
    for i:=(MessageWidth + 1) to size - 1 do
        write(' ');
    TextAttr := SaveTextAttr;
end;

procedure GetMessageInfo(var msg: string; var MaxLineSize: integer;
    var LinesCount: integer);
var
    TempSize, i: integer;
begin
    TempSize := 0;
    MaxLineSize := 0;
    LinesCount := 1;
    i := 1;
    while i <= length(msg) - 1 do
        if (msg[i] = '\') and (msg[i + 1] = 'n') then
        begin
            LinesCount := LinesCount + 1;
            if TempSize > MaxLineSize then
                MaxLineSize := TempSize;
            TempSize := 0;
            i := i + 2;
        end
        else
        begin
            TempSize := TempSize + 1;
            i := i + 1;
        end;
    TempSize := TempSize + 1;
    if TempSize > MaxLineSize then
        MaxLineSize := TempSize;
end;

procedure ShowTextBox(title: string; content: string);
var
    i, idx, LineNumber, MaxLineSize, LinesCount, c: integer;
    row: string[70];
    form: TForm;
begin
    GetMessageInfo(content, MaxLineSize, LinesCount); 
    CreateForm(form, LinesCount, MaxLineSize, title);
    LineNumber := 1;
    idx := 1;
    i := 1;
    while i <= length(content) - 1 do
    begin
        if ((content[i] = '\') and (content[i + 1] = 'n')) then
        begin
            SetLength(row, idx - 1);
            DrawFormTextLine(form, row, LineNumber, InterfaceFgcolor,
                InterfaceBgcolor);
            LineNumber := LineNumber + 1;
            idx := 1;
            i := i + 2;
        end
        else
        begin
            row[idx] := content[i];
            idx := idx + 1;
            i := i + 1;
        end;
    end;
    row[idx] := content[i];
    SetLength(row, idx);
    DrawFormTextLine(form, row, LineNumber, InterfaceFgcolor, InterfaceBgcolor);
    GetKey(c);
end;

procedure ShowMessage(msg: string);
begin
    ShowTextBox('', msg);
end;

procedure ShowConfirm(msg: string; var answer: boolean; DefaultFirst: boolean);
var
    list: ListWidget;
    SelectedItem: string;
begin
    CreateListWidget(list, msg);
    AddListWidgetItem(list, 'Yes');
    AddListWidgetItem(list, 'No');
    if not DefaultFirst then
        NextListWidgetItem(list);
    ShowListWidget(list, SelectedItem);
    answer := SelectedItem = 'Yes';
    RemoveListWidget(list);
end;

end.
