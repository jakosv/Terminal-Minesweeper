unit keyboard;

interface
const
    KeyEsc = 27;
    KeySpace = 32;
    KeyUp = -72;
    KeyDown = -80;
    KeyLeft = -75;
    KeyRight = -77;

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
