unit WndMain; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, PairSplitter, Python;

type

  { TForm1 }

  TForm1 = class(TForm)    
    Memo2: TMemo;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;   
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    BExecute: TButton;
    BLoad: TButton;
    BSave: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure BExecuteClick(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;

var
  Form1: TForm1; 

implementation

{ TForm1 }


procedure TForm1.BExecuteClick(Sender: TObject);
var
  s: string;
begin
  s := Memo1.Lines.Text;
  s := Execute(s);
  if s <> '' then
  begin
    s := 'Result: ' + s;
    Memo2.Lines.Add(s);
  end;
end;

procedure TForm1.BLoadClick(Sender: TObject);
begin
  with OpenDialog1 do
    begin
      if Execute then
        Memo1.Lines.LoadFromFile( FileName );
    end;
end;

procedure TForm1.BSaveClick(Sender: TObject);
begin
  with SaveDialog1 do
    begin
      if Execute then
        Memo1.Lines.SaveToFile( FileName );
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin        
  InitEngine(Self, Memo2);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CloseEngine;
end;

initialization
  {$I wndmain.lrs}

end.

