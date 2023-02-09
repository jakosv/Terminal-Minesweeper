unit controls;

interface
uses keyboard;
type
    TControl = (CKeyNone, CKeyMoveUp, CKeyMoveDown, CKeyMoveRight, 
        CKeyMoveLeft, CKeyOpen, CKeyFlag, CKeySuspicious, CKeyPause); 
    ControlsArray = array [CKeyMoveUp..CKeyPause] of shortint;
    
const
    ControlsNames: array [CKeyMoveUp..CKeyPause] of string = (
        'Move up',
        'Move down',
        'Move right',
        'Move left',
        'Open cell',
        'Set flag',
        'Mark suspicicous',
        'Pause'
    );

procedure LoadControls(var CurrentControls: ControlsArray);
procedure SetControls(var NewControls: ControlsArray);
procedure GetDefaultControls(var DefaultControls: ControlsArray);
procedure GetControlByName(var name: string; var SelectedControl: TControl); 
procedure GetControlDescription(control: TControl; 
    var CurrentControls: ControlsArray; var description: string);

implementation
const
    ControlsFilename = '.controls';

type
    FileOfControls = file of ControlsArray;

procedure GetDefaultControls(var DefaultControls: ControlsArray);
begin
    DefaultControls[CKeyMoveUp] := SpecKeyCodes[KeyUp];
    DefaultControls[CKeyMoveDown] := SpecKeyCodes[KeyDown];
    DefaultControls[CKeyMoveRight] := SpecKeyCodes[KeyRight];
    DefaultControls[CKeyMoveLeft] := SpecKeyCodes[KeyLeft];
    DefaultControls[CKeyOpen] := SpecKeyCodes[KeySpace];
    DefaultControls[CKeyFlag] := ord('f');
    DefaultControls[CKeySuspicious] := ord('x');
    DefaultControls[CKeyPause] := SpecKeyCodes[KeyEsc];
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
    if IOResult <> 0 then
    begin
        GetDefaultControls(CurrentControls);
        SetControls(CurrentControls);
    end;
end;

procedure SetControls(var NewControls: ControlsArray);
var
    f: FileOfControls;
begin
{$I-}
    assign(f, ControlsFilename);
    rewrite(f);
    seek(f, 0);
    write(f, NewControls);
    close(f);
end;

procedure GetControlByName(var name: string; var SelectedControl: TControl); 
var
    control: TControl;
begin
    SelectedControl := CKeyNone;
    for control := CKeyMoveUp to CKeyPause do
        if name = ControlsNames[control] then
        begin
            SelectedControl := control; 
            break;
        end;
end;

procedure GetControlDescription(control: TControl; 
    var CurrentControls: ControlsArray; var description: string);
var
    KeyName: string;
begin
    GetKeyName(CurrentControls[control], KeyName);
    description := ControlsNames[control] + ' - ' + KeyName; 
end;

end.
