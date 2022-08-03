{DEFINE DEBUG}
unit field;

interface
uses CellsMatrix, cell;

type
    TField = record
        height, width, x, y: shortint;
        cells: TCellsMatrix;
    end;
    TFieldPtr = ^TField;

procedure CreateField(height, width, x, y, BombsCount: shortint; 
    var FieldPtr: TFieldPtr);
procedure RemoveField(FieldPtr: TFieldPtr);
procedure DrawField(FieldPtr: TFieldPtr);
procedure DrawFieldCell(x, y: CellCoord; FieldPtr: TFieldPtr);
procedure SetFieldCellFlag(x, y: CellCoord; FieldPtr: TFieldPtr);
procedure SetFieldCellSuspicious(x, y: CellCoord; FieldPtr: TFieldPtr);
function IsActiveBomb(x, y: CellCoord; FieldPtr: TFieldPtr): boolean;
procedure OpenFieldCell(x, y: CellCoord; FieldPtr: TFieldPtr);
procedure SetFieldCellBgcolor(bgcolor: word; x, y: CellCoord; 
    FieldPtr: TFieldPtr);
function GetFieldCellBgcolor(x, y: CellCoord; FieldPtr: TFieldPtr): word;
function FieldFlagsCount(FieldPtr: TFieldPtr): integer;
function IsCorrectCoord(x, y: CellCoord; FieldPtr: TFieldPtr): boolean;
function ExistActiveBomb(FieldPtr: TFieldPtr): boolean;
procedure ShowFieldBombs(FieldPtr: TFieldPtr);

implementation
uses crt;

const
    FieldBorderSize = 1;
    FieldBorderSymbol = '#';
    FieldBorderFgcolor = Black;
    FieldBorderBgcolor = Green;

function IsCorrectCoord(x, y: CellCoord; FieldPtr: TFieldPtr): boolean;
begin
    IsCorrectCoord := 
        (x <= FieldPtr^.width) and (x >= 1) and 
        (y <= FieldPtr^.height) and (y >= 1);
end;

function GoodBombPosition(x, y: CellCoord; FieldPtr: TFieldPtr): boolean;
const
    dx: array [1..3] of shortint = (-1, 0, 1);
    dy: array [1..3] of shortint = (-1, 0, 1);
var
    i, j: CellCoord;
    CellObj: TCell;
begin
    GoodBombPosition := false;
    for i := 1 to 3 do
        for j := 1 to 3 do
        begin
            CellObj := CMGet(y + dy[j], x + dx[i], FieldPtr^.cells);
            if not ((dx[i] = 0) and (dy[j] = 0)) and
                IsCorrectCoord(x, y, FieldPtr) and 
                (CellObj.CellType <> CBomb) then
            begin
                GoodBombPosition := true;
            end;
        end;
end;

procedure GenerateBombs(BombsCount: shortint; FieldPtr: TFieldPtr);
var
    CellObj: TCell;
    x, y: CellCoord;
    i: shortint;
begin
    randomize;
    i := 0;
    while i < BombsCount do
    begin
        x := random(FieldPtr^.width - 1) + 1;
        y := random(FieldPtr^.height - 1) + 1;
        CellObj := CMGet(y, x, FieldPtr^.cells);
        if (CellObj.CellType = CBomb) or 
            (not GoodBombPosition(x, y, FieldPtr)) then
        begin
            continue;
        end;
        SetCellBomb(CellObj);
        CMSet(y, x, CellObj, FieldPtr^.cells);
        i := i + 1;
    end;
end;

function CountBombsAround(x, y: CellCoord; FieldPtr: TFieldPtr): shortint;
const
    dx: array [1..3] of shortint = (-1, 0, 1);
    dy: array [1..3] of shortint = (-1, 0, 1);
var
    i, j, BombsCount: shortint;
    CellObj: TCell;
begin
    BombsCount := 0;
    for i := 1 to 3 do
        for j := 1 to 3 do
            if IsCorrectCoord(x + dx[i], y + dy[j], FieldPtr) then
            begin
                CellObj := CMGet(y + dy[j], x + dx[i], FieldPtr^.cells);
                if CellObj.CellType = CBomb then
                    BombsCount := BombsCount + 1;
            end;
    CountBombsAround := BombsCount;
end;

procedure NumberEmptyCell(x, y: CellCoord; BombsAround: shortint; 
    FieldPtr: TFieldPtr);
var
    CellObj: TCell;
begin
    CellObj := CMGet(y, x, FieldPtr^.cells);
    SetCellSymbol(chr(ord('0') + BombsAround), CellObj);
    CMSet(y, x, CellObj, FieldPtr^.cells);
    DrawFieldCell(x, y, FieldPtr);
end;

procedure HideFieldCells(FieldPtr: TFieldPtr);
var
    CellObj: TCell;
    i, j: CellCoord;
begin
    for i := 1 to FieldPtr^.height do
        for j := 1 to FieldPtr^.width do
        begin
            CellObj := CMGet(i, j, FieldPtr^.cells);
            {$IFDEF DEBUG}
            if CellObj.CellType <> CBomb then
            {$ENDIF}
            HideCell(CellObj);
            CMSet(i, j, CellObj, FieldPtr^.cells);
        end;
end;

procedure CreateField(height, width, x, y, BombsCount: shortint; 
    var FieldPtr: TFieldPtr);
begin
    new(FieldPtr);
    FieldPtr^.height := height;
    FieldPtr^.width := width;
    FieldPtr^.x := x;
    FieldPtr^.y := y;
    CMInit(FieldPtr^.cells, height, width);
    GenerateBombs(BombsCount, FieldPtr);
    HideFieldCells(FieldPtr);
    DrawField(FieldPtr);
end;

procedure RemoveField(FieldPtr: TFieldPtr);
begin
    CMRemove(FieldPtr^.cells);
    FieldPtr^.height := 0;
    FieldPtr^.width := 0;
    FieldPtr^.x := 0;
    FieldPtr^.y := 0;
    dispose(FieldPtr);
    FieldPtr := nil;
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

procedure DrawFieldCell(x, y: CellCoord; FieldPtr: TFieldPtr);
var
    CellObj: TCell;
    SaveTextAttr: integer;
begin
    CellObj := CMGet(y, x, FieldPtr^.cells);
    GotoXY(FieldPtr^.x + x - 1, FieldPtr^.y + y - 1);
    SaveTextAttr := TextAttr;
    TextColor(CellObj.fgcolor);
    TextBackground(CellObj.bgcolor);
    write(CellObj.symbol);
    TextAttr := SaveTextAttr;
    GotoXY(1, 1);
end;

procedure DrawField(FieldPtr: TFieldPtr);
var
    i, j: CellCoord;
begin
    DrawFieldBorder(FieldPtr^.height + 2 * FieldBorderSize, 
        FieldPtr^.width + 2 * FieldBorderSize, 
        FieldPtr^.x - FieldBorderSize, 
        FieldPtr^.y - FieldBorderSize);
    for i := 1 to FieldPtr^.height do
        for j := 1 to FieldPtr^.width do
            DrawFieldCell(j, i, FieldPtr);
end;

procedure SetFieldCell(MarkType: MarkTypes; x, y: CellCoord; 
    FieldPtr: TFieldPtr);
var
    CellObj: TCell;
begin
    CellObj := CMGet(y, x, FieldPtr^.cells);
    if not CellObj.hidden then
        exit;
    if CellObj.MarkType <> MarkType then
        MarkCell(MarkType, CellObj)
    else
        MarkCell(MNone, CellObj);
    CMSet(y, x, CellObj, FieldPtr^.cells);
end;

procedure SetFieldCellFlag(x, y: CellCoord; FieldPtr: TFieldPtr);
begin
    SetFieldCell(MFlag, x, y, FieldPtr);
end;

procedure SetFieldCellSuspicious(x, y: CellCoord; FieldPtr: TFieldPtr);
begin
    SetFieldCell(MSuspicious, x, y, FieldPtr);
end;

procedure SetFieldCellBgcolor(bgcolor: word; x, y: CellCoord; 
    FieldPtr: TFieldPtr);
var
    CellObj: TCell;
begin
    CellObj := CMGet(y, x, FieldPtr^.cells);
    SetCellBgcolor(bgcolor, CellObj);
    CMSet(y, x, CellObj, FieldPtr^.cells);
end;

function GetFieldCellBgcolor(x, y: CellCoord; FieldPtr: TFieldPtr): word;
var
    CellObj: TCell;
begin
    CellObj := CMGet(y, x, FieldPtr^.cells);
    GetFieldCellBgcolor := CellObj.bgcolor;
end;

function FieldFlagsCount(FieldPtr: TFieldPtr): integer;
var
    i, j: CellCoord;
    CellObj: TCell;
    count: integer;
begin
    count := 0;
    for i := 1 to FieldPtr^.height do
        for j := 1 to FieldPtr^.width do
        begin
            CellObj := CMGet(i, j, FieldPtr^.cells);
            if CellObj.MarkType = MFlag then
                count := count + 1;
        end;
    FieldFlagsCount := count;
end;

function IsActiveBomb(x, y: CellCoord; FieldPtr: TFieldPtr): boolean;
var
    CellObj: TCell;
begin
    CellObj := CMGet(y, x, FieldPtr^.cells); 
    IsActiveBomb := 
        (CellObj.CellType = CBomb) and (CellObj.MarkType = MNone);
end;

procedure OpenEmptyFieldCells(x, y: CellCoord; FieldPtr: TFieldPtr);
const
    dx: array [1..3] of shortint = (-1, 0, 1);
    dy: array [1..3] of shortint = (-1, 0, 1);
var
    i, j, BombsAroundCell: shortint;
    CellObj: TCell;
begin
    if not IsCorrectCoord(x, y, FieldPtr) then
        exit;
    CellObj := CMGet(y, x, FieldPtr^.cells);
    if (CellObj.CellType = CBomb) or (not CellObj.hidden) or 
        (CellObj.MarkType <> MNone) then
    begin
        exit;
    end;
    OpenCell(CellObj);
    CMSet(y, x, CellObj, FieldPtr^.cells);
    BombsAroundCell := CountBombsAround(x, y, FieldPtr);
    DrawFieldCell(x, y, FieldPtr);
    if BombsAroundCell > 0 then
    begin
        NumberEmptyCell(x, y, BombsAroundCell, FieldPtr);
        exit;
    end;
    for i := 1 to 3 do
        for j := 1 to 3 do
            OpenEmptyFieldCells(x + dx[i], y + dy[j], FieldPtr);  
end;

procedure OpenFieldCell(x, y: CellCoord; FieldPtr: TFieldPtr);
begin
    OpenEmptyFieldCells(x, y, FieldPtr);
end;

function ExistActiveBomb(FieldPtr: TFieldPtr): boolean;
var
    i, j: CellCoord;
    CellObj: TCell;
    exist: boolean;
begin
    exist := false;
    for i := 1 to FieldPtr^.height do
        for j := 1 to FieldPtr^.width do
        begin
            CellObj := CMGet(i, j, FieldPtr^.cells);
            if (CellObj.CellType = CBomb) and (CellObj.MarkType <> MFlag) then
                exist := true;
        end;
    ExistActiveBomb := exist;
end;

procedure ShowFieldBombs(FieldPtr: TFieldPtr);
var
    i, j: CellCoord;
    CellObj: TCell;
begin
    for i := 1 to FieldPtr^.height do
        for j := 1 to FieldPtr^.width do
        begin
            CellObj := CMGet(i, j, FieldPtr^.cells);
            if CellObj.CellType = CBomb then
            begin
                OpenCell(CellObj);
                CMSet(i, j, CellObj, FieldPtr^.cells);
                DrawFieldCell(j, i, FieldPtr);
            end;
        end;
end;

end.
