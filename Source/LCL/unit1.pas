unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, PairSplitter, PythonEngine, lcl.PythonGUIInputOutput;

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
    PythonEngine1: TPythonEngine;
    PythonGUIInputOutput1: TPythonGUIInputOutput;
    procedure BExecuteClick(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
  end;

var
  Form1: TForm1; 

implementation

{ TForm1 }


procedure TForm1.BExecuteClick(Sender: TObject);
begin
  PythonEngine1.ExecStrings( Memo1.Lines );
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

initialization
  {$I unit1.lrs}

end.

