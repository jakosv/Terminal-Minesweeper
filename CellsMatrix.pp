unit CellsMatrix;

interface
uses cell;
type
    CellCoord = integer;
    CMItemPtr = ^CMItem;
    CMItem = record
        data: TCell;
        next, prev: CMItemPtr; 
    end;
    TCellsMatrix = record 
        cells: CMItemPtr;
        rows, columns: integer;
    end;

procedure CMInit(var matrix: TCellsMatrix; rows, columns: integer);
function CMGet(row, column: CellCoord; var matrix: TCellsMatrix): TCell;
procedure CMSet(row, column: CellCoord; var cell: TCell;  
    var matrix: TCellsMatrix);
procedure CMRemove(var matrix: TCellsMatrix);

implementation
procedure CMInit(var matrix: TCellsMatrix; rows, columns: integer);
var
    ItemsCount, i: integer;
    tmp: CMItemPtr;
begin
    matrix.cells := nil; 
    matrix.rows := rows;
    matrix.columns := columns;
    ItemsCount := rows * columns;
    for i := 1 to ItemsCount do
    begin
        new(tmp);
        tmp^.next := matrix.cells;
        InitDefaultCell(tmp^.data);
        matrix.cells := tmp;
    end;
end;

function GetItemNumber(row, column: CellCoord; MatrixColumns: integer)
                                                                    : integer;
begin
    GetItemNumber := (row - 1) * MatrixColumns + column;
end;

function CMGet(row, column: CellCoord; var matrix: TCellsMatrix): TCell;
var
    ItemNumber, i: integer;
    tmp: CMItemPtr;
begin
    tmp := matrix.cells;
    ItemNumber := GetItemNumber(row, column, matrix.columns);
    for i := 2 to ItemNumber do
        tmp := tmp^.next;
    CMGet := tmp^.data; 
end;

procedure CMSet(row, column: CellCoord; var cell: TCell;  
    var matrix: TCellsMatrix);
var
    ItemNumber, i: integer;
    tmp: CMItemPtr;
begin
    tmp := matrix.cells;
    ItemNumber := GetItemNumber(row, column, matrix.columns);
    for i := 2 to ItemNumber do
        tmp := tmp^.next; 
    tmp^.data := cell;
end;

procedure CMRemove(var matrix: TCellsMatrix);
var
    tmp, cells: CMItemPtr;
begin
    cells := matrix.cells;
    while cells <> nil do
    begin
        tmp := cells;
        cells := cells^.next;
        dispose(tmp);
    end;
    matrix.cells := nil;
    matrix.rows := 0;
    matrix.columns := 0;
end;

end.
