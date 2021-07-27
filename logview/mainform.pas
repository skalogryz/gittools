unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  gitlogclasses, RichMemo, gitexec;

type

  { TLogViewForm }

  TLogViewForm = class(TForm)
    LogList: TListView;
    FilesList: TListView;
    Panel1: TPanel;
    PanelFiles: TPanel;
    PanelMessage: TPanel;
    PanelLog: TPanel;
    LogMessage: TRichMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure FilesListData(Sender: TObject; Item: TListItem);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LogListData(Sender: TObject; Item: TListItem);
    procedure LogListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private

  public
    showLog  : TList;
    showItem : TLogEntry;
    procedure SetLogFile(const fn: string);
    procedure UpdateListView;
    procedure UpdateItemsView;
    procedure SelectItemByIndex(showLogIndex: Integer);
  end;

var
  LogViewForm: TLogViewForm;

implementation

{$R *.lfm}

{ TLogViewForm }

procedure TLogViewForm.LogListData(Sender: TObject; Item: TListItem);
var
  i : integer;
  lg : TLogEntry;
begin
  if not ASsigned(showLog) then Exit;
  i := Item.Index;
  if (i<0) or (i>=showLog.Count) then Exit;

  lg := TLogEntry(showLog[i]);
  item.Caption := lg.Hash;
  //Item.SubItems.add(lg.Hash);
  Item.SubItems.add(lg.Message);
end;

procedure TLogViewForm.LogListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if not Selected then Exit;
  if not Assigned(Item) then Exit;
  SelectItemByIndex(Item.Index);
end;

procedure TLogViewForm.FormCreate(Sender: TObject);
var
  st : TStringList;
  res : TRunResult;
begin
  showLog:=TList.Create;

  GitRun( UTF8Decode( GetCurrentDir ), [GitNoPager, GitLog,'--pretty=fuller'], res);
  st := TStringList.Create;
  try
    st.Text := res.StdOut;
    st.SaveToFile('temp.txt');
  finally
    st.Free;
  end;


  SetLogFile('temp.txt');
end;

procedure TLogViewForm.FilesListData(Sender: TObject; Item: TListItem);
var
  idx : integer;
  fn  : TLogFile;
begin
  if showItem = nil then Exit;
  idx := Item.Index;
  if (idx < 0) or (idx>=showItem.files.Count) then Exit;
  fn := TLogFile(showItem.files[idx]);
  item.Caption := fn.fileName;
  item.SubItems.Add(fn.action);
end;

procedure TLogViewForm.FormDestroy(Sender: TObject);
begin
  ClearList(showLog);
  showLog.Free;
end;

procedure TLogViewForm.SetLogFile(const fn: string);
begin
  ClearList(showLog);
  ReadEntries(showLog, fn);

  UpdateListView;
end;

procedure TLogViewForm.UpdateListView;
begin
  LogList.Items.Count:=showLog.Count;
end;

procedure TLogViewForm.UpdateItemsView;
begin
  if showItem = nil then begin
    LogMessage.Clear;
    FilesList.Items.Count:=0;
  end else begin
    LogMessage.Text := showItem.Message;
    FilesList.Items.Clear;
    FilesList.Items.Count := showItem.files.Count;
  end;
end;

procedure TLogViewForm.SelectItemByIndex(showLogIndex: Integer);
begin
  if (showLogIndex<0) or (showLogIndex>=showLog.Count) then
    showItem := nil
  else
    showItem := TLogEntry(showLog[showLogIndex]);
  UpdateItemsView;

end;

end.

