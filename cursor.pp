unit cursor;

interface
uses field;
type
    TCursor = record
        x, y: shortint;
        color, CellBgcolor: word;
        FieldPtr: TFieldPtr;
    end;
    TCursorPtr = ^TCursor;

procedure CreateCursor(FieldPtr: TFieldPtr; color: word; var CursorPtr: TCursorPtr);
procedure RemoveCursor(var CursorPtr: TCursorPtr);
procedure DrawCursor(CursorPtr: TCursorPtr);
procedure MoveCursor(CursorPtr: TCursorPtr; dx, dy: shortint);
procedure OpenCursorCell(CursorPtr: TCursorPtr; var IsBomb: boolean);
procedure SetCursorFlag(CursorPtr: TCursorPtr);
procedure SetCursorSuspicious(CursorPtr: TCursorPtr);

implementation

procedure CreateCursor(FieldPtr: TFieldPtr; color: word; var CursorPtr: TCursorPtr);
begin
    new(CursorPtr);
    CursorPtr^.FieldPtr := FieldPtr;
    CursorPtr^.x := 1;
    CursorPtr^.y := 1;
    CursorPtr^.color := color;
    CursorPtr^.CellBgcolor := 
        GetFieldCellBgcolor(CursorPtr^.x, CursorPtr^.y, FieldPtr);
    DrawCursor(CursorPtr);
end;

procedure RemoveCursor(var CursorPtr: TCursorPtr);
begin
    dispose(CursorPtr);
    CursorPtr := nil;
end;

procedure DrawCursor(CursorPtr: TCursorPtr);
begin
    SetFieldCellBgcolor(CursorPtr^.color, CursorPtr^.x, CursorPtr^.y, 
        CursorPtr^.FieldPtr); 
    DrawFieldCell(CursorPtr^.x, CursorPtr^.y, CursorPtr^.FieldPtr);
end;

procedure UpdateCursor(CursorPtr: TCursorPtr);
begin
    CursorPtr^.CellBgcolor := 
        GetFieldCellBgcolor(CursorPtr^.x, CursorPtr^.y, CursorPtr^.FieldPtr);
    DrawCursor(CursorPtr);
end;

procedure RestoreCursorCell(CursorPtr: TCursorPtr);
begin
    SetFieldCellBgcolor(CursorPtr^.CellBgcolor, CursorPtr^.x, CursorPtr^.y, 
        CursorPtr^.FieldPtr);     
    DrawFieldCell(CursorPtr^.x, CursorPtr^.y, CursorPtr^.FieldPtr);
end;

procedure MoveCursor(CursorPtr: TCursorPtr; dx, dy: shortint);
var
    NewX, NewY: shortint;
begin
    NewX := CursorPtr^.x + dx;
    NewY := CursorPtr^.y + dy;
    if not IsCorrectCoord(NewX, NewY, CursorPtr^.FieldPtr) then
        exit;
    RestoreCursorCell(CursorPtr);
    CursorPtr^.x := CursorPtr^.x + dx;
    CursorPtr^.y := CursorPtr^.y + dy;
    UpdateCursor(CursorPtr);
end;

procedure OpenCursorCell(CursorPtr: TCursorPtr; var IsBomb: boolean);
begin
    RestoreCursorCell(CursorPtr);
    OpenFieldCell(CursorPtr^.x, CursorPtr^.y, CursorPtr^.FieldPtr);
    IsBomb := 
        IsActiveBomb(CursorPtr^.x, CursorPtr^.y, CursorPtr^.FieldPtr);
    if IsBomb then
        ShowFieldBombs(CursorPtr^.FieldPtr);
    UpdateCursor(CursorPtr);
end;

procedure SetCursorFlag(CursorPtr: TCursorPtr);
begin
    RestoreCursorCell(CursorPtr);
    SetFieldCellFlag(CursorPtr^.x, CursorPtr^.y, CursorPtr^.FieldPtr); 
    UpdateCursor(CursorPtr);
end;

procedure SetCursorSuspicious(CursorPtr: TCursorPtr);
begin
    RestoreCursorCell(CursorPtr);
    SetFieldCellSuspicious(CursorPtr^.x, CursorPtr^.y, CursorPtr^.FieldPtr); 
    UpdateCursor(CursorPtr);
end;

end.
