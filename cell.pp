unit cell;

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

procedure InitDefaultCell(var CellObj: TCell);
procedure SetCellSymbol(symbol: char; var CellObj: TCell);
procedure SetCellFgcolor(fgcolor: word; var CellObj: TCell);
procedure SetCellBgcolor(bgcolor: word; var CellObj: TCell);
procedure SetCellEmpty(var CellObj: TCell);
procedure SetCellBomb(var CellObj: TCell);
procedure HideCell(var CellObj: TCell);
procedure OpenCell(var CellObj: TCell);
procedure MarkCell(MarkType: MarkTypes; var CellObj: TCell);

implementation
const
    HiddenCellSymbol = '.';
    HiddenCellFgcolor = White;
    HiddenCellBgcolor = Green;
    EmptyCellSymbol = ' ';
    EmptyCellFgcolor = Black;
    EmptyCellBgcolor = Brown;
    BombCellSymbol = '*';
    BombCellFgcolor = Red;
    BombCellBgcolor = Brown;
    MarkedBombCellFgcolor = White;
    MarkedBombCellBgcolor = Brown;
    FlagCellSymbol = 'F';
    FlagCellFgcolor = Red;
    SuspiciousCellSymbol = '?';
    SuspiciousCellFgcolor = Red; 

procedure SetCellEmpty(var CellObj: TCell);
begin
    SetCellSymbol(EmptyCellSymbol, CellObj);
    SetCellFgcolor(EmptyCellFgcolor, CellObj);
    SetCellBgcolor(EmptyCellBgcolor, CellObj);
    CellObj.CellType := CEmpty; 
end;

procedure SetCellBomb(var CellObj: TCell);
begin
    SetCellSymbol(BombCellSymbol, CellObj);
    if CellObj.MarkType = MFlag then
    begin
        SetCellFgcolor(MarkedBombCellFgcolor, CellObj);
        SetCellBgcolor(MarkedBombCellBgcolor, CellObj);
    end
    else
    begin
        SetCellFgcolor(BombCellFgcolor, CellObj);
        SetCellBgcolor(BombCellBgcolor, CellObj);
    end;
    CellObj.CellType := CBomb;
end;

procedure InitDefaultCell(var CellObj: TCell);
begin
    CellObj.MarkType := MNone;
    CellObj.hidden := false;
    SetCellEmpty(CellObj);
end;

procedure SetCellSymbol(symbol: char; var CellObj: TCell);
begin
    CellObj.symbol := symbol;
end;

procedure SetCellFgcolor(fgcolor: word; var CellObj: TCell);
begin
    CellObj.fgcolor := fgcolor;
end;

procedure SetCellBgcolor(bgcolor: word; var CellObj: TCell);
begin
    CellObj.bgcolor := bgcolor;
end;

procedure MarkCellFlag(var CellObj: TCell);
begin
    CellObj.MarkType := MFlag;
    SetCellSymbol(FlagCellSymbol, CellObj);
    SetCellFgcolor(FlagCellFgcolor, CellObj);
    SetCellBgcolor(HiddenCellBgcolor, CellObj);
end;

procedure MarkCellSuspicious(var CellObj: TCell);
begin
    CellObj.MarkType := MSuspicious;
    SetCellSymbol(SuspiciousCellSymbol, CellObj);
    SetCellFgcolor(SuspiciousCellFgcolor, CellObj);
    SetCellBgcolor(HiddenCellBgcolor, CellObj);
end;

procedure HideCell(var CellObj: TCell);
begin
    SetCellSymbol(HiddenCellSymbol, CellObj);
    SetCellFgcolor(HiddenCellFgcolor, CellObj);
    SetCellBgcolor(HiddenCellBgcolor, CellObj);
    CellObj.hidden := true;
end;

procedure OpenCell(var CellObj: TCell);
begin
    case CellObj.CellType of
        CEmpty:
            SetCellEmpty(CellObj);
        CBomb:
            SetCellBomb(CellObj);
    end;
    CellObj.hidden := false;
end;

procedure UnmarkCell(var CellObj: TCell);
begin
    HideCell(CellObj)
end;

procedure MarkCell(MarkType: MarkTypes; var CellObj: TCell);
begin
    CellObj.MarkType := MarkType;
    case MarkType of
        MNone:
            UnmarkCell(CellObj);
        MFlag:
            MarkCellFlag(CellObj);
        MSuspicious:
            MarkCellSuspicious(CellObj);
    end;
end;

end.
