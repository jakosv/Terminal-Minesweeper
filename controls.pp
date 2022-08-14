unit controls;

interface
uses keyboard;
type
    ControlKey = (CKeyMoveUp, CKeyMoveDown, CKeyMoveRight, CKeyMoveLeft, 
        CKeyOpen, CKeyFlag, CKeySuspicious, CKeyPause); 
    ControlsArray = array [CKeyMoveUp..CKeyPause] of shortint;

procedure LoadControls(var CurrentControls: ControlsArray);
procedure SetControls(var NewControls: ControlsArray);
procedure GetDefaultControls(var DefaultControls: ControlsArray);

implementation
const
    ControlsFilename = '.controls';
    DefaultKeyMoveUp = KeyUp;
    DefaultKeyMoveDown = KeyDown;
    DefaultKeyMoveRight = KeyRight;
    DefaultKeyMoveLeft = KeyLeft;
    DefaultKeyOpen = KeySpace;
    DefaultKeyFlag = ord('f');
    DefaultKeySuspicious = ord('x');
    DefaultKeyPause = KeyEsc;

type
    FileOfControls = file of ControlsArray;

procedure GetDefaultControls(var DefaultControls: ControlsArray);
begin
    DefaultControls[CKeyMoveUp] := DefaultKeyMoveUp;
    DefaultControls[CKeyMoveDown] := DefaultKeyMoveDown;
    DefaultControls[CKeyMoveRight] := DefaultKeyMoveRight;
    DefaultControls[CKeyMoveLeft] := DefaultKeyMoveLeft;
    DefaultControls[CKeyOpen] := DefaultKeyOpen;
    DefaultControls[CKeyFlag] := DefaultKeyFlag;
    DefaultControls[CKeySuspicious] := DefaultKeySuspicious;
    DefaultControls[CKeyPause] := DefaultKeyPause;
end;

procedure InitDefaultControls(var f: FileOfControls);
var
    DefaultControls: ControlsArray;
begin
    rewrite(f);
    GetDefaultControls(DefaultControls);
    seek(f, 0);
    write(f, DefaultControls);
end;

procedure LoadControls(var CurrentControls: ControlsArray);
var
    f: FileOfControls;
begin
{$I-}
    assign(f, ControlsFilename);
    reset(f);
    if IOResult <> 0 then
        InitDefaultControls(f);
    seek(f, 0);
    read(f, CurrentControls);
    close(f);
end;

procedure SetControls(var NewControls: ControlsArray);
var
    f: FileOfControls;
begin
{$I-}
    assign(f, ControlsFilename);
    reset(f);
    if IOResult <> 0 then
        InitDefaultControls(f);
    seek(f, 0);
    write(f, NewControls);
    close(f);
end;

end.
