program testGitLogParser;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, gitlogparser
  { you can add units after this };

var
  s : string;
  sc : TGitLogScanner;
begin
  sc := TGitLogScanner.Create;
  while not eof(input) do begin
    readln(s);
    //if sc.ConsumeLine(s) = gleCommit then
    case sc.ConsumeLine(s) of
      gleCommit: writeln(sc.CommitHash);
      //gleTitle: writeln(sc.EntryValue);
      //gleTitleEnd: break;
    end;

  end;
  sc.Free;
end.

