unit GameResults;

interface
uses sysutils;
const
    ResultsCount = 3;
type
    TResult = record
        date, GameTime: TDateTime;
    end;
    ArrayOfResults = array [1..ResultsCount] of TResult;

procedure SaveResult(var GameTime: TDateTime; ResultPos: shortint);
procedure GetResults(var results: ArrayOfResults);
function IsNewRecord(var GameTime: TDateTime; ResultPos: shortint): boolean;

implementation
const
    ResultsFilename = '.results';
type
    FileOfResults = file of TResult;

procedure CreateResultsFile(var f: FileOfResults);
var
    i: shortint;
    result: TResult;
begin
    rewrite(f);
    result.date := 0;
    result.GameTime := 0;
    for i := 1 to ResultsCount do
        write(f, result);
end;

procedure SaveResult(var GameTime: TDateTime; ResultPos: shortint);
var
    f: FileOfResults;
    result: TResult;
begin
    {$I-}
    assign(f, ResultsFilename);
    reset(f);
    if IOResult <> 0 then
        CreateResultsFile(f);
    seek(f, ResultPos - 1);
    read(f, result);
    result.GameTime := GameTime;
    result.date := Date;
    seek(f, ResultPos - 1);
    write(f, result);
    close(f);
end;

procedure GetResults(var results: ArrayOfResults); 
var
    f: FileOfResults;
    i: shortint;
begin
    {$I-}
    assign(f, ResultsFilename);
    reset(f);
    if IOResult <> 0 then
        CreateResultsFile(f);
    seek(f, 0);
    for i := 1 to ResultsCount do
        read(f, results[i]);
    close(f);
end;

function IsNewRecord(var GameTime: TDateTime; ResultPos: shortint): boolean;
var
    f: FileOfResults;
    result: TResult;
begin
    {$I-}
    assign(f, ResultsFilename);
    reset(f);
    if IOResult <> 0 then
    begin
       IsNewRecord := true; 
       exit;
    end;
    seek(f, ResultPos - 1);
    read(f, result);
    IsNewRecord := (result.GameTime = 0) or (result.GameTime > GameTime);
    close(f);
end;

end.
