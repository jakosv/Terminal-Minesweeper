unit keyboard;

interface
type
    SpecKeys = (KeyEsc, KeySpace, KeyEnter, KeyUp, KeyDown, KeyLeft,
        KeyRight);
const
    SpecKeyCodes: array [KeyEsc..KeyRight] of shortint = (
        27, { KeyEsc }
        32, { KeySpace }
        13, { KeyEnter }
        -72, { KeyUp }
        -80, { KeyDown }
        -75, { KeyLeft }
        -77 {KeyRight }
    );
    
    SpecKeyName: array [KeyEsc..KeyRight] of string = (
        'Escape',
        'Space',
        'Enter',
        'Arrow Up',
        'Arrow Down',
        'Arrow Left',
        'Arrow Right'
    );

procedure GetKey(var n: shortint);
procedure GetKeyName(key: shortint; var KeyName: string);

implementation
uses crt;

procedure GetKey(var n: shortint);
var
    c: char;
begin
    c := ReadKey; 
    if c = #0 then
    begin
        c := ReadKey;
        n := -ord(c);
    end
    else
        n := ord(c);
end;

procedure GetKeyName(key: shortint; var KeyName: string);
var
    SpecKey: SpecKeys;
begin
    KeyName := '';
    for SpecKey := KeyEsc to KeyRight do
        if SpecKeyCodes[SpecKey] = key then
        begin
            KeyName := SpecKeyName[SpecKey];
            break;
        end;
    if KeyName = '' then
        KeyName := chr(key);
end;

end.
