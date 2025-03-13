unit Python;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, Controls, StdCtrls,
  PythonEngine,  {$IFDEF FPC}Lcl.{$ENDIF}PythonGUIInputOutput;

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
const
  Py_single_input = 256;
  Py_file_input   = 257;
  Py_eval_input   = 258;
var
  e: TPythonEngine;
  s2: Utf8String;
  m : PPyObject;
  globals, codeObj, res: PPyObject;
begin
  // Engine.ExecString(Expression);
  Result := '';
  e := Python.Engine;
  s2 := Utf8String(Expression);

  m := e.GetMainModule;
  globals := e.PyModule_GetDict(m);

  // Try compiling in eval mode (for expressions)
  codeObj := e.Py_CompileString(PAnsiChar(s2), '<stdin>', Py_eval_input);
  if Assigned(codeObj) then
  begin
    // If eval mode works, execute it and print the result
    res := e.PyEval_EvalCode(PPyCodeObject(codeObj), globals, locals);
    if Assigned(res) then
    begin
      if res <> e.py_None then
      begin
        Result := Repr(res);
      end;
      e.Py_DECREF(res);
    end;
    e.Py_DECREF(codeObj);
  end
  else
  begin
    // If eval mode fails, assume it's a statement and run normally
    e.PyErr_Clear();

    codeObj := e.Py_CompileString(PAnsiChar(s2), '<stdin>', Py_file_input); // Py_single_input);
    if Assigned(codeObj) then
    begin
      res := e.PyEval_EvalCode(PPyCodeObject(codeObj), globals, locals);
      e.Py_DECREF(res);
      e.Py_DECREF(codeObj);
    end
    else
      e.PyErr_Print(); // Print syntax errors
  end
end;

end.

