unit WndMain;



interface

uses
  Classes, SysUtils,
  Windows, Messages, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,
  Python;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    BExecute: TButton;
    Splitter1: TSplitter;
    BLoad: TButton;
    BSave: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Memo2: TMemo;
    BMain: TButton;
    BLocals: TButton;
    Label1: TLabel;
    procedure BExecuteClick(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
    procedure BMainClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BLocalsClick(Sender: TObject);
  end;


var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  WndTree, InspectPython;

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

procedure TForm1.BLocalsClick(Sender: TObject);
begin
  inspectScope('Exploring -- locals', locals);
end;

procedure TForm1.BSaveClick(Sender: TObject);
begin
  with SaveDialog1 do
    begin
      if Execute then
        Memo1.Lines.SaveToFile( FileName );
    end;
end;

procedure TForm1.BMainClick(Sender: TObject);
begin
  inspect('Exploring -- __maim__', __main__);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitEngine(Self, Memo2);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CloseEngine;
end;

end.
