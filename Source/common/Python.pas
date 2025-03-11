unit Python;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, Controls, StdCtrls,
  PythonEngine,  {$IFDEF FPC}lcl.{$ENDIF}PythonGUIInputOutput;

{$IF NOT DECLARED(Py_ssize_t)}  // older python4delphi
type
  Py_ssize_t = NativeInt;
{$ENDIF}
{$IF NOT DECLARED(PPyCodeObject)}
type
  PPyCodeObject = PPyObject;
{$ENDIF}


var
  Engine: TPythonEngine;
  locals: PPyObject;

function  __main__: PPyObject;

procedure InitEngine(Parent: TWinControl; Memo2: TCustomMemo);
procedure CloseEngine;

function  Repr(ob: PPyObject): string;
function  Execute(Expression: string): string;

implementation

type
  friend_TPythonEngine = class(TPythonEngine)
  end;

procedure InitEngine(Parent: TWinControl; Memo2: TCustomMemo);
var
  PythonEngine1: TPythonEngine;
  PythonGUIInputOutput1: TPythonGUIInputOutput;
begin
  PythonEngine1 := TPythonEngine.Create(Parent);
  PythonGUIInputOutput1 := TPythonGUIInputOutput.Create(Parent);

  with PythonGUIInputOutput1 do
  begin
    UnicodeIO := True;
    RawOutput := False;
    Output := Memo2;
  end;
  PythonEngine1.IO := PythonGUIInputOutput1;
  friend_TPythonEngine(PythonEngine1).Loaded;

  Engine := PythonEngine1;
  locals := Engine.PyDict_New(); // New reference
end;

procedure CloseEngine;
begin
  Engine.Py_DECREF(locals);
  locals := nil;
  Engine.Free;
  Engine := nil;
end;

function  __main__: PPyObject;
begin
  Result := Engine.GetMainModule;
end;

function  Repr(ob: PPyObject): string;
var
  r: PPyObject;
begin
  if ob = nil then
  begin
    Result := 'nil';
    Exit;
  end;
  r := Engine.PyObject_Repr(ob);
  Result := Engine.PyObjectAsString(r);
  Engine.Py_XDECREF(r);
end;

function  Execute(Expression: string): string;
begin
  Engine.ExecString(Expression);
  Result := '';
end;

end.

