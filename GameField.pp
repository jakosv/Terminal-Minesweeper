{DEFINE DEBUG}
unit GameField;

interface
uses CellsMatrix, FieldCell;

type
    TField = record
        height, width, x, y: shortint;
        cells: TCellsMatrix;
    end;
    TFieldPtr = ^TField;

procedure CreateField(height, width, x, y, BombsCount: shortint; 
    var field: TFieldPtr);
procedure RemoveField(field: TFieldPtr);
procedure SetFieldCellFlag(x, y: CellCoord; field: TFieldPtr);
procedure SetFieldCellSuspicious(x, y: CellCoord; field: TFieldPtr);
function IsActiveBomb(x, y: CellCoord; field: TFieldPtr): boolean;
function IsCellEmpty(x, y: CellCoord; field: TFieldPtr): boolean;
function IsCellFlag(x, y: CellCoord; field: TFieldPtr): boolean;
function IsCellHidden(x, y: CellCoord; field: TFieldPtr): boolean;
procedure OpenEmptyFieldCell(x, y: CellCoord; field: TFieldPtr);
procedure SetFieldCellBgcolor(bgcolor: word; x, y: CellCoord; 
    field: TFieldPtr);
function GetFieldCellBgcolor(x, y: CellCoord; field: TFieldPtr): word;
function IsCorrectCoord(x, y: CellCoord; field: TFieldPtr): boolean;
function ExistActiveBomb(field: TFieldPtr): boolean;
function ExistHiddenEmptyCell(field: TFieldPtr): boolean;
procedure ShowFieldBombs(field: TFieldPtr);

implementation
uses crt;

const
    FieldBorderSize = 1;
    FieldBorderSymbol = '#';
    FieldBorderFgcolor = Black;
    FieldBorderBgcolor = Green;

function IsCorrectCoord(x, y: CellCoord; field: TFieldPtr): boolean;
begin
    IsCorrectCoord := 
        (x <= field^.width) and (x >= 1) and 
        (y <= field^.height) and (y >= 1);
end;

function GoodBombPosition(x, y: CellCoord; field: TFieldPtr): boolean;
const
    dx: array [1..3] of shortint = (-1, 0, 1);
    dy: array [1..3] of shortint = (-1, 0, 1);
var
    i, j: CellCoord;
    cell: TCell;
begin
    GoodBombPosition := false;
    for i := 1 to 3 do
        for j := 1 to 3 do
        begin
            cell := CMGet(y + dy[j], x + dx[i], field^.cells);
            if not ((dx[i] = 0) and (dy[j] = 0)) and
                IsCorrectCoord(x, y, field) and 
                (cell.CellType <> CBomb) then
            begin
                GoodBombPosition := true;
            end;
        end;
end;

procedure GenerateBombs(BombsCount: shortint; field: TFieldPtr);
var
    cell: TCell;
    x, y: CellCoord;
    i: shortint;
begin
    randomize;
    i := 0;
    while i < BombsCount do
    begin
        x := random(field^.width - 1) + 1;
        y := random(field^.height - 1) + 1;
        cell := CMGet(y, x, field^.cells);
        if (cell.CellType = CBomb) or 
            (not GoodBombPosition(x, y, field)) then
        begin
            continue;
        end;
        SetCellBomb(cell);
        CMSet(y, x, cell, field^.cells);
        i := i + 1;
    end;
end;

function CountBombsAround(x, y: CellCoord; field: TFieldPtr): shortint;
const
    dx: array [1..3] of shortint = (-1, 0, 1);
    dy: array [1..3] of shortint = (-1, 0, 1);
var
    i, j, BombsCount: shortint;
    cell: TCell;
begin
    BombsCount := 0;
    for i := 1 to 3 do
        for j := 1 to 3 do
            if IsCorrectCoord(x + dx[i], y + dy[j], field) then
            begin
                cell := CMGet(y + dy[j], x + dx[i], field^.cells);
                if cell.CellType = CBomb then
                    BombsCount := BombsCount + 1;
            end;
    CountBombsAround := BombsCount;
end;

procedure DrawBorderLine(BorderWidth, x, y: shortint);
var
    i: shortint;
begin
    GotoXY(x, y);
    for i := 1 to BorderWidth do
        write(FieldBorderSymbol);
    GotoXY(1, 1);
end;
    
procedure DrawFieldBorder(BorderHeight, BorderWidth, x, y: shortint);
var
    i: CellCoord;
    SaveTextAttr: integer;
begin
    SaveTextAttr := TextAttr;
    TextColor(FieldBorderFgcolor);
    TextBackground(FieldBorderBgcolor);
    DrawBorderLine(BorderWidth, x, y);
    for i := 2 to BorderHeight - 1 do
    begin
        GotoXY(x, y + i - 1);
        write(FieldBorderSymbol);
        GotoXY(x + BorderWidth - 1, y + i - 1);
        write(FieldBorderSymbol);
    end;
    DrawBorderLine(BorderWidth, x, y + BorderHeight - 1);
    TextAttr := SaveTextAttr;
    GotoXY(1, 1);
end;

procedure DrawFieldCell(x, y: CellCoord; field: TFieldPtr);
var
    cell: TCell;
    SaveTextAttr: integer;
begin
    cell := CMGet(y, x, field^.cells);
    GotoXY(field^.x + x - 1, field^.y + y - 1);
    SaveTextAttr := TextAttr;
    TextColor(cell.fgcolor);
    TextBackground(cell.bgcolor);
    write(cell.symbol);
    TextAttr := SaveTextAttr;
    GotoXY(1, 1);
end;

procedure DrawField(field: TFieldPtr);
var
    i, j: CellCoord;
begin
    DrawFieldBorder(field^.height + 2 * FieldBorderSize, 
        field^.width + 2 * FieldBorderSize, 
        field^.x - FieldBorderSize, 
        field^.y - FieldBorderSize);
    for i := 1 to field^.height do
        for j := 1 to field^.width do
            DrawFieldCell(j, i, field);
end;

procedure HideFieldCells(field: TFieldPtr);
var
    cell: TCell;
    i, j: CellCoord;
begin
    for i := 1 to field^.height do
        for j := 1 to field^.width do
        begin
            cell := CMGet(i, j, field^.cells);
            {$IFDEF DEBUG}
            if cell.CellType <> CBomb then
            {$ENDIF}
            HideCell(cell);
            CMSet(i, j, cell, field^.cells);
        end;
end;

procedure CreateField(height, width, x, y, BombsCount: shortint; 
    var field: TFieldPtr);
begin
    new(field);
    field^.height := height;
    field^.width := width;
    field^.x := x;
    field^.y := y;
    CMInit(field^.cells, height, width);
    GenerateBombs(BombsCount, field);
    HideFieldCells(field);
    DrawField(field);
end;

procedure RemoveField(field: TFieldPtr);
begin
    CMRemove(field^.cells);
    field^.height := 0;
    field^.width := 0;
    field^.x := 0;
    field^.y := 0;
    dispose(field);
    field := nil;
end;


procedure SetFieldCell(MarkType: MarkTypes; x, y: CellCoord; 
    field: TFieldPtr);
var
    cell: TCell;
begin
    cell := CMGet(y, x, field^.cells);
    if cell.MarkType <> MarkType then
        MarkCell(MarkType, cell)
    else
        MarkCell(MNone, cell);
    CMSet(y, x, cell, field^.cells);
    DrawFieldCell(x, y, field);
end;

procedure SetFieldCellFlag(x, y: CellCoord; field: TFieldPtr);
begin
    SetFieldCell(MFlag, x, y, field);
end;

procedure SetFieldCellSuspicious(x, y: CellCoord; field: TFieldPtr);
begin
    SetFieldCell(MSuspicious, x, y, field);
end;

procedure SetFieldCellBgcolor(bgcolor: word; x, y: CellCoord; 
    field: TFieldPtr);
var
    cell: TCell;
begin
    cell := CMGet(y, x, field^.cells);
    SetCellBgcolor(bgcolor, cell);
    CMSet(y, x, cell, field^.cells);
    DrawFieldCell(x, y, field);
end;

function GetFieldCellBgcolor(x, y: CellCoord; field: TFieldPtr): word;
var
    cell: TCell;
begin
    cell := CMGet(y, x, field^.cells);
    GetFieldCellBgcolor := cell.bgcolor;
end;

function IsActiveBomb(x, y: CellCoord; field: TFieldPtr): boolean;
var
    cell: TCell;
begin
    cell := CMGet(y, x, field^.cells); 
    IsActiveBomb := 
        (cell.CellType = CBomb) and (cell.MarkType <> MFlag);
end;

function IsCellEmpty(x, y: CellCoord; field: TFieldPtr): boolean;
begin
    IsCellEmpty := CMGet(y, x, field^.cells).CellType = CEmpty;
end;

function IsCellFlag(x, y: CellCoord; field: TFieldPtr): boolean;
begin
    IsCellFlag :=
        CMGet(y, x, field^.cells).MarkType = MFlag;
end;

function IsCellSuspicious(x, y: CellCoord; field: TFieldPtr): boolean;
begin
    IsCellSuspicious :=
        CMGet(y, x, field^.cells).MarkType = MSuspicious;
end;

function IsCellHidden(x, y: CellCoord; field: TFieldPtr): boolean;
begin
    IsCellHidden := CMGet(y, x, field^.cells).hidden;
end;

procedure ShowEmptyCell(x, y: CellCoord; BombsAroundCell: shortint; 
    field: TFieldPtr);
var
    cell: TCell;
begin
    cell := CMGet(y, x, field^.cells);
    ShowCell(cell);
    if BombsAroundCell > 0 then
        SetCellSymbol(chr(ord('0') + BombsAroundCell), cell);
    CMSet(y, x, cell, field^.cells);
    DrawFieldCell(x, y, field);
end;

{ Recursive procedure }
procedure OpenEmptyFieldCell(x, y: CellCoord; field: TFieldPtr);
const
    dx: array [1..3] of shortint = (-1, 0, 1);
    dy: array [1..3] of shortint = (-1, 0, 1);
var
    i, j, BombsAroundCell: shortint;
begin
    if not IsCorrectCoord(x, y, field) or not IsCellHidden(x, y, field) or
        not IsCellEmpty(x, y, field) or IsActiveBomb(x, y, field) or
        IsCellFlag(x, y, field) then
    begin
        exit;
    end;
    BombsAroundCell := CountBombsAround(x, y, field);
    ShowEmptyCell(x, y, BombsAroundCell, field);
    if BombsAroundCell > 0 then
        exit;
    for i := 1 to 3 do
        for j := 1 to 3 do
            OpenEmptyFieldCell(x + dx[i], y + dy[j], field);
end;

function ExistActiveBomb(field: TFieldPtr): boolean;
var
    x, y: CellCoord;
    cell: TCell;
    exist: boolean;
begin
    exist := false;
    for y := 1 to field^.height do
        for x := 1 to field^.width do
        begin
            cell := CMGet(y, x, field^.cells);
            if (cell.CellType = CBomb) and (cell.MarkType <> MFlag) then
                exist := true;
        end;
    ExistActiveBomb := exist;
end;

function ExistHiddenEmptyCell(field: TFieldPtr): boolean;
var
    x, y: CellCoord;
    cell: TCell;
    exist: boolean;
begin
    exist := false;
    for y := 1 to field^.height do
        for x := 1 to field^.width do
        begin
            cell := CMGet(y, x, field^.cells);
            if cell.hidden and (cell.CellType = CEmpty) then
                exist := true;
        end;
    ExistHiddenEmptyCell := exist;
end;

procedure ShowFieldBombs(field: TFieldPtr);
var
    i, j: CellCoord;
    cell: TCell;
begin
    for i := 1 to field^.height do
        for j := 1 to field^.width do
        begin
            cell := CMGet(i, j, field^.cells);
            if cell.CellType = CBomb then
            begin
                ShowCell(cell);
                CMSet(i, j, cell, field^.cells);
                DrawFieldCell(j, i, field);
            end;
        end;
end;

end.
