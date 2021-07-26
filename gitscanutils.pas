unit gitscanutils;

interface

type
  TCharSet = set of AnsiChar;

function ScanWhile(const str: string; WhileInChars: TCharSet; var idx: integer): string;
function ScanTo(const str: string; ToChars: TCharSet; var idx: integer): string;

const
  WhiteSpace     = [#32,#9,#10,#13];
  DefaultSymbols = ['&','-','$','<','>','+','*','\','/'];
  AlphaLow       = ['a'..'z'];
  AlphaUp        = ['A'..'Z'];
  Alpha          = AlphaUp + AlphaLow;
  UnixEoln       = [#10];
  Tabs           = [#9];

implementation

function ScanWhile(const str: string; WhileInChars: TCharSet; var idx: integer): string;
var
  i : integer;
begin
  i:=idx;
  while (idx<=length(str)) and (str[idx] in WhileInChars) do inc(idx);
  Result:=copy(str, i, idx-i);
end;

function ScanTo(const str: string; ToChars: TCharSet; var idx: integer): string;
var
  i : integer;
begin
  i:=idx;
  while (idx<=length(str)) and not (str[idx] in ToChars) do inc(idx);
  Result:=copy(str, i, idx-i);
end;

end.
