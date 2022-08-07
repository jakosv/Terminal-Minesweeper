unit GameCursor;

interface
uses GameField;
type
    TCursor = record
        x, y: shortint;
        fgcolor, bgcolor, SaveCellBgcolor: word;
    end;
    TCursorPtr = ^TCursor;

procedure CreateCursor(field: TFieldPtr; var cursor: TCursorPtr);
procedure RemoveCursor(var cursor: TCursorPtr);
procedure MoveCursor(cursor: TCursorPtr; dx, dy: shortint;
    field: TFieldPtr);
procedure DrawCursor(cursor: TCursorPtr; field: TFieldPtr);
procedure UpdateCursor(cursor: TCursorPtr; field: TFieldPtr);

implementation
uses crt;

const
    DefaultCursorBgcolor = LightGray;

procedure DrawCursor(cursor: TCursorPtr; field: TFieldPtr);
begin
    SetFieldCellColor(cursor^.fgcolor, cursor^.bgcolor, cursor^.x, 
        cursor^.y, field);
end;

procedure CreateCursor(field: TFieldPtr; var cursor: TCursorPtr);
begin
    new(cursor);
    cursor^.x := 1;
    cursor^.y := 1;
    GetFieldCellColor(cursor^.x, cursor^.y, field, cursor^.fgcolor,
        cursor^.SaveCellBgcolor);
    cursor^.bgcolor := DefaultCursorBgcolor;
    DrawCursor(cursor, field);
end;

procedure RestoreCursorCell(cursor: TCursorPtr; field: TFieldPtr);
begin
    SetFieldCellColor(cursor^.fgcolor, cursor^.SaveCellBgcolor, cursor^.x, 
        cursor^.y, field);     
end;

procedure RemoveCursor(var cursor: TCursorPtr);
begin
    dispose(cursor);
    cursor := nil;
end;

procedure UpdateCursor(cursor: TCursorPtr; field: TFieldPtr);
begin
    GetFieldCellColor(cursor^.x, cursor^.y, field, cursor^.fgcolor,
        cursor^.SaveCellBgcolor);
    DrawCursor(cursor, field);
end;

procedure MoveCursor(cursor: TCursorPtr; dx, dy: shortint; field: TFieldPtr);
var
    NewX, NewY: shortint;
begin
    NewX := cursor^.x + dx;
    NewY := cursor^.y + dy;
    if not IsCorrectCoord(NewX, NewY, field) then
        exit;
    RestoreCursorCell(cursor, field);
    cursor^.x := cursor^.x + dx;
    cursor^.y := cursor^.y + dy;
    UpdateCursor(cursor, field);
end;

end.
