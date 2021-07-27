unit gitexec;

interface

uses
  process,
  processunicode;

const
  GitLog = 'log';
  GitNoPager = '--no-pager';

type
  TRunResult = record
    ExitCode : Integer;
    StdOut   : string;
    StdErr   : string;
  end;

var
  GitExecPath : TProcessString = 'git'; // should be full path on Linux

procedure GitRun(const dir: UnicodeString;
  const args: array of UnicodeString; out res: TRunResult);

implementation

procedure GitRun(const dir: UnicodeString;
  const args: array of UnicodeString; out res: TRunResult);
var
  opt : TProcessOptions;
  st  : string;
begin
  res.StdErr:='';
  opt := [poUsePipes, poWaitOnExit];
  RunCommandIndir( dir, GitExecPath, args, res.StdOut, res.ExitCode, opt, swoNone);
end;

end.
