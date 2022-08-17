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
        'escape',
        'space',
        'enter',
        'up',
        'down',
        'left',
        'right'
    );

procedure GetKey(var n: integer);

implementation
uses crt;

procedure GetKey(var n: integer);
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

end.
