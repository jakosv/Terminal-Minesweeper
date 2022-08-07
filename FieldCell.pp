unit FieldCell;

interface
uses crt;
type
    CellTypes = (CEmpty, CBomb);
    MarkTypes = (MNone, MFlag, MSuspicious);
    TCell = record
        symbol: char;
        fgcolor, bgcolor: word;
        CellType: CellTypes;
        MarkType: MarkTypes;
        hidden: boolean;
    end;

procedure CreateCell(var cell: TCell);
procedure SetCellSymbol(symbol: char; var cell: TCell);
procedure SetCellFgcolor(fgcolor: word; var cell: TCell);
procedure SetCellBgcolor(bgcolor: word; var cell: TCell);
procedure SetCellEmpty(var cell: TCell);
procedure SetCellBomb(var cell: TCell);
procedure HideCell(var cell: TCell);
procedure ShowCell(var cell: TCell);
procedure MarkCell(MarkType: MarkTypes; var cell: TCell);

implementation
const
    HiddenCellSymbol = '.';
    HiddenCellFgcolor = LightGray;
    HiddenCellBgcolor = Green;
    EmptyCellSymbol = ' ';
    EmptyCellFgcolor = Black;
    EmptyCellBgcolor = Brown;
    BombCellSymbol = '*';
    BombCellFgcolor = Red;
    BombCellBgcolor = Brown;
    MarkedBombCellFgcolor = Green;
    MarkedBombCellBgcolor = Brown;
    FlagCellSymbol = 'F';
    FlagCellFgcolor = Red;
    FlagCellBgcolor = HiddenCellBgcolor;
    SuspiciousCellSymbol = '?';
    SuspiciousCellFgcolor = Black; 
    SuspiciousCellBgcolor = HiddenCellBgcolor; 

procedure CreateCell(var cell: TCell);
begin
    cell.symbol := HiddenCellSymbol;
    cell.fgcolor := HiddenCellFgcolor;
    cell.bgcolor := HiddenCellBgcolor;
    cell.CellType := CEmpty;
    cell.MarkType := MNone;
    cell.hidden := false;
end;

procedure SetCellEmpty(var cell: TCell);
begin
    SetCellSymbol(EmptyCellSymbol, cell);
    SetCellFgcolor(EmptyCellFgcolor, cell);
    SetCellBgcolor(EmptyCellBgcolor, cell);
    cell.CellType := CEmpty; 
end;

procedure SetCellBomb(var cell: TCell);
begin
    SetCellSymbol(BombCellSymbol, cell);
    if cell.MarkType = MFlag then
    begin
        SetCellFgcolor(MarkedBombCellFgcolor, cell);
        SetCellBgcolor(MarkedBombCellBgcolor, cell);
    end
    else
    begin
        SetCellFgcolor(BombCellFgcolor, cell);
        SetCellBgcolor(BombCellBgcolor, cell);
    end;
    cell.CellType := CBomb;
end;

procedure SetCellSymbol(symbol: char; var cell: TCell);
begin
    cell.symbol := symbol;
end;

procedure SetCellFgcolor(fgcolor: word; var cell: TCell);
begin
    cell.fgcolor := fgcolor;
end;

procedure SetCellBgcolor(bgcolor: word; var cell: TCell);
begin
    cell.bgcolor := bgcolor;
end;

procedure MarkCellFlag(var cell: TCell);
begin
    cell.MarkType := MFlag;
    SetCellSymbol(FlagCellSymbol, cell);
    SetCellFgcolor(FlagCellFgcolor, cell);
    SetCellBgcolor(FlagCellBgcolor, cell);
end;

procedure MarkCellSuspicious(var cell: TCell);
begin
    cell.MarkType := MSuspicious;
    SetCellSymbol(SuspiciousCellSymbol, cell);
    SetCellFgcolor(SuspiciousCellFgcolor, cell);
    SetCellBgcolor(FlagCellBgcolor, cell);
end;

procedure HideCell(var cell: TCell);
begin
    SetCellSymbol(HiddenCellSymbol, cell);
    SetCellFgcolor(HiddenCellFgcolor, cell);
    SetCellBgcolor(HiddenCellBgcolor, cell);
    cell.hidden := true;
end;

procedure ShowCell(var cell: TCell);
begin
    case cell.CellType of
        CEmpty:
            SetCellEmpty(cell);
        CBomb:
            SetCellBomb(cell);
    end;
    cell.hidden := false;
end;

procedure UnmarkCell(var cell: TCell);
begin
    HideCell(cell)
end;

procedure MarkCell(MarkType: MarkTypes; var cell: TCell);
begin
    cell.MarkType := MarkType;
    case MarkType of
        MNone:
            UnmarkCell(cell);
        MFlag:
            MarkCellFlag(cell);
        MSuspicious:
            MarkCellSuspicious(cell);
    end;
end;

end.
