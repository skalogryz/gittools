unit gitlogparser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, gitscanutils;

type
  // see GitLog pretty formats https://git-scm.com/docs/pretty-formats

  TGitLogEntry = (
     gleCommit // always starts a new hash
    ,gleInfo
    ,gleGitAttr
    ,gleTitleStart
    ,gleTitle
    ,gleTitleEnd
    ,gleFileName
    ,gleUnknown
    ,gleCommitEnd
  );

  { TGitLogScanner }

  // scanns "fuller" pretty format
  TGitLogScanner = class(TObject)
  private
    isTitle     : Boolean;
    isCommit    : Boolean;
    isTitleDone : Boolean;
  public
    Entry       : TGitLogEntry;
    CommitHash  : string;
    EntryName   : string;
    EntryValue  : string;
    FileMod     : string;
    function ConsumeLine(const s: string): TGitLogEntry;
    procedure Reset;
  end;

implementation

{ TGitLogScanner }

function TGitLogScanner.ConsumeLine(const s: string): TGitLogEntry;
var
  i : integer;
  t : string;
begin
  try
    if s = '' then begin
      if isTitleDone and isCommit then begin
        isCommit := false;
        Result := gleCommitEnd;
      end else begin
        if not isTitle then begin
          Result := gleTitleStart;
          isTitleDone := false;
        end else begin
          Result := gleTitleEnd;
          isTitleDone := true;
        end;
        isTitle := not isTitle;
      end;
      Exit;
    end;

    if isTitle then begin
      EntryValue := s;
      Result := gleTitle;
      Exit;
    end;

    i:=1;
    if (s[i] = ' ') then begin
      Result := gleGitAttr;
      ScanWhile(s, [#32], i);
      EntryName := ScanTo(s, [':'], i);
      inc(i, 2); // skip ': '
      EntryValue := ScanTo(s, UnixEoln, i);
    end else begin
      t := ScanWhile(s, Alpha, i);
      if (t = 'commit') then begin
        EntryName := 'commit';
        Result := gleCommit;
        ScanWhile(s, WhiteSpace, i);
        CommitHash := ScanTo(s, UnixEoln, i);
        EntryValue := CommitHash;
        isCommit := true;
        isTitleDone := false;
      end else if (i<=length(s)) and (s[i]=#9) then begin ;// else if (t='A' or
        Result:=gleFileName;
        FileMod := t;
        ScanWhile(s, Tabs, i);
        EntryValue := ScanTo(s, UnixEoln, i);
      end else begin
        Result:=gleInfo;
        EntryName := t;
        inc(i, 2);
        ScanWhile(s, WhiteSpace, i);
        EntryValue:=ScanTo(s, UnixEoln, i);
        inc(i);
      end;
    end;
  finally
    Entry := Result;
  end;
end;

procedure TGitLogScanner.Reset;
begin
  isTitle:=false;
  isCommit:=false;
  isTitleDone:=false;
end;

end.

