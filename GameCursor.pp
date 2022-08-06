unit GameCursor;

interface
uses GameField;
type
    TCursor = record
        x, y: shortint;
        color, SaveCellBgcolor: word;
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
    CursorDefaultColor = White;

procedure DrawCursor(cursor: TCursorPtr; field: TFieldPtr);
begin
    SetFieldCellBgcolor(cursor^.color, cursor^.x, cursor^.y, 
        field); 
end;

procedure CreateCursor(field: TFieldPtr; var cursor: TCursorPtr);
begin
    new(cursor);
    cursor^.x := 1;
    cursor^.y := 1;
    cursor^.color := CursorDefaultColor;
    cursor^.SaveCellBgcolor := 
        GetFieldCellBgcolor(cursor^.x, cursor^.y, field);
    DrawCursor(cursor, field);
end;

procedure RestoreCursorCell(cursor: TCursorPtr; field: TFieldPtr);
begin
    SetFieldCellBgcolor(cursor^.SaveCellBgcolor, cursor^.x, 
        cursor^.y, field);     
end;

procedure RemoveCursor(var cursor: TCursorPtr);
begin
    dispose(cursor);
    cursor := nil;
end;

procedure UpdateCursor(cursor: TCursorPtr; field: TFieldPtr);
begin
    cursor^.SaveCellBgcolor := 
        GetFieldCellBgcolor(cursor^.x, cursor^.y, field);
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
