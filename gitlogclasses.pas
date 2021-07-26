unit gitlogclasses;

interface

uses
  SysUtils, Classes, gitlogparser;

type
  TLogFile = class(TObject)
  public
    fileName : string;
    action   : string;
  end;

  { TLogEntry }

  TLogEntry = class(TObject)
    Hash       : string;
    Author     : string;
    AuthorDate : TDatetime;
    Commit     : string;
    CommitDate : TDateTime;
    Message    : string;
    files      : TList;
    constructor Create;
    destructor Destroy; override;
    function AddFile: TLogFile;
  end;

procedure ReadEntries(dst: TList; const srcFile: string);
procedure ClearList(dst: TList);

implementation

{ TLogEntry }

constructor TLogEntry.Create;
begin
  inherited Create;
  files := TList.Create;
end;

destructor TLogEntry.Destroy;
var
  i : integer;
begin
  for i:=0 to files.Count-1 do TObject(files[i]).Free;
  files.Free;
  inherited Destroy;
end;

function TLogEntry.AddFile: TLogFile;
begin
  Result := TLogFile.Create;
  files.Add(Result);
end;

procedure ReadEntries(dst: TList; const srcFile: string);
var
  fs   : TFileStream;
  st   : TStringList;
  scan : TGitLogScanner;
  en   : TLogEntry;
  i    : integer;
  fn   : TLogFile;
begin
  fs:=TFileStream.Create(srcFile, fmOpenRead or fmshareDenyNone);
  st := TStringList.Create;
  scan := TGitLogScanner.Create;
  try
    st.LoadFromFile(srcFile);
    en := nil;
    for i:=0 to st.Count-1 do begin
      case scan.ConsumeLine(st[i]) of
        gleCommitEnd: en := nil;
        gleCommit: begin
          en := TLogEntry.Create;
          en.Hash := scan.CommitHash;
          dst.Add(en);
        end;
        gleTitle: begin
          if en.Message = '' then en.Message := Copy(scan.EntryValue, 5, length(scan.EntryValue)-4)
          else en.Message := en.Message + #10 + Copy(scan.EntryValue, 5, length(scan.EntryValue)-4);
        end;
        gleFileName: begin
          fn := en.AddFile;
          fn.fileName := scan.EntryValue;
          fn.action := scan.FileMod;
        end;
        //,gleInfo
        //,gleGitAttr
      end;
    end;
  finally
    scan.Free;
    st.Free;
    fs.Free;
  end;
end;

procedure ClearList(dst: TList);
var
  i : integer;
begin
  if not Assigned(dst) then Exit;
  for i:=0 to dst.Count-1 do
    TObject(dst[i]).free;
  dst.Clear;
end;

end.
