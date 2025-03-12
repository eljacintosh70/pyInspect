unit InspectPython;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils,
  PythonEngine,
  WndTree, InspectBase, Python;

type
  IKvRender = interface(IDataRender)
    ['{F2A97689-1475-4000-ABE8-9DF18958037E}']
  end;

  { TPyRender }

  TPyRender = class(TInterfacedObject, IDataRender)
  protected
    function MainText(Node: PNodeData; Expanded: Boolean): string; virtual;
    function ChildCount(Node: PNodeData): Integer; virtual;
    procedure InitChildData(ParentData, ChildData: PNodeData; ChildIndex: Integer); virtual;
  end;

  { TPyListRender }

  TPyListRender = class(TPyRender)
  protected
    function MainText(Node: PNodeData; Expanded: Boolean): string; override;
    function ChildCount(Node: PNodeData): Integer; override;
    procedure InitChildData(ParentData, ChildData: PNodeData; ChildIndex: Integer); override;
  end;

  { TPyTupleRender }

  TPyTupleRender = class(TPyRender)
  protected
    function MainText(Node: PNodeData; Expanded: Boolean): string; override;
    function ChildCount(Node: PNodeData): Integer; override;
    procedure InitChildData(ParentData, ChildData: PNodeData; ChildIndex: Integer); override;
  end;

  { TPyDictRender }

  TPyDictRender = class(TPyRender, IKvRender)
  protected
    // IDataRender
    function MainText(Node: PNodeData; Expanded: Boolean): string; override;
    function ChildCount(Node: PNodeData): Integer; override;
    procedure InitChildData(ParentData, ChildData: PNodeData; ChildIndex: Integer); override;
  protected
    // IKvRender
    function IKvRender_MainText(Node: PNodeData; Expanded: Boolean): string;
    function IKvRender_ChildCount(Node: PNodeData): Integer;
    procedure IKvRender_InitChildData(ParentData, ChildData: PNodeData; ChildIndex: Integer);

    function IKvRender.MainText = IKvRender_MainText;
    function IKvRender.ChildCount = IKvRender_ChildCount;
    procedure IKvRender.InitChildData = IKvRender_InitChildData;
    // help IKvRender
    function RenderKey(Obj: PPyObject): string; virtual;
  public
    d, k, v: PPyObject;
    constructor Create(AD: PPyObject);
    destructor Destroy; override;
  end;

  { TPyScopeRender }

  TPyScopeRender = class(TPyDictRender)
  protected
    // help IKvRender
    function RenderKey(Obj: PPyObject): string; override;
  end;

  { TPyModuleRender }

  TPyModuleRender = class(TPyScopeRender)
  protected
    // IDataRender
    function MainText(Node: PNodeData; Expanded: Boolean): string; override;
    function ChildCount(Node: PNodeData): Integer; override;
  public
    constructor Create(AMod: PPyObject);
  end;


function CreateRender(ob: PPyObject): IDataRender;

procedure inspect(Caption: string; Obj: PPyObject; Render: IDataRender = nil);
procedure inspectScope(Caption: string; Obj: PPyObject);

implementation

var
  FObjRender: IDataRender;
function ObjRender: IDataRender;
var
  PyRender: TPyRender;
begin
  if not Assigned(FObjRender) then
  begin
    PyRender := TPyRender.Create;
    FObjRender := PyRender;
  end;
  Result := FObjRender;
end;

var
  FListRender: IDataRender;
function ListRender: IDataRender;
var
  PyRender: TPyListRender;
begin
  if not Assigned(FListRender) then
  begin
    PyRender := TPyListRender.Create;
    FListRender := PyRender;
  end;
  Result := FListRender;
end;

var
  FTupleRender: IDataRender;
function TupleRender: IDataRender;
var
  PyRender: TPyTupleRender;
begin
  if not Assigned(FTupleRender) then
  begin
    PyRender := TPyTupleRender.Create;
    FTupleRender := PyRender;
  end;
  Result := FTupleRender;
end;

function CreateRender(ob: PPyObject): IDataRender;
var
  PyRender: TPyRender;
begin
  if ob = nil then
  begin
    Result := ObjRender;
    Exit;
  end;

  Engine.Py_XINCREF(ob); // no debería estar acá
  if Engine.PyModule_Check(ob) then
  begin
    PyRender := TPyModuleRender.Create(ob);
    Result := PyRender;
  end
  else if Engine.PyDict_Check(ob) then
  begin
    PyRender := TPyDictRender.Create(ob);
    Result := PyRender;
  end
  else if Engine.PyList_Check(ob) then
    Result := ListRender
  else if Engine.PyTuple_Check(ob) then
    Result := TupleRender
  else
    Result := ObjRender
end;

function DisplayPython(Column: Integer; AData: PNodeData; Expanded: Boolean): WideString;
begin
  if Column = 1 then
    Result := AData.Render.MainText(AData, Expanded)
  else
    Result := ''
end;

procedure inspect(Caption: string; Obj: PPyObject; Render: IDataRender = nil);
var
  Form: TTreeForm;
  TreeAdapter: TTreeAdapter;
begin
  Form := TTreeForm.Create(nil);
  Form.Caption := Caption;

  TreeAdapter := TTreeAdapter.Create;
  Form.TreeAdapter := TreeAdapter;

  if not Assigned(Render) then
    Render := CreateRender(Obj);
  TreeAdapter.SetRootNode(Render, Obj);
  Engine.Py_XINCREF(Obj);
  TreeAdapter.DefineColumns(Form.InitTree,
    1, DisplayPython,
    ['Index', 'Data'],
    [ 75,      544  ]);

  Form.Show;
end;

procedure inspectScope(Caption: string; Obj: PPyObject);
var
  Render: IDataRender;
  PyRender: TPyScopeRender;
begin
  PyRender := TPyScopeRender.Create(Obj);
  Render := PyRender;
  inspect(Caption, Obj, Render);
end;

{ TPyRender }

function TPyRender.MainText(Node: PNodeData; Expanded: Boolean): string;
var
  Obj: PPyObject;
begin
  Obj := PPyObject(Node.Data);
  if Assigned(Obj) then
    Result := Repr(Obj)
  else
    Result := 'None';
end;

function TPyRender.ChildCount(Node: PNodeData): Integer;
begin
  Result := 0;
end;

procedure TPyRender.InitChildData(ParentData, ChildData: PNodeData;
  ChildIndex: Integer);
begin
  ChildData.Render := ObjRender;
  ChildData.Data := nil;
end;

{ TPyListRender }

function TPyListRender.ChildCount(Node: PNodeData): Integer;
var
  L: PPyObject;
begin
  L := Node.Data;
  Result := Engine.PyList_Size(L);
end;

procedure TPyListRender.InitChildData(ParentData, ChildData: PNodeData;
  ChildIndex: Integer);
var
  Len: Py_ssize_t;
  i: NativeInt;
  Obj: PPyObject;
  L: PPyObject;
begin
  i := ChildIndex;
  L := ParentData.Data;
  Len := Engine.PyList_Size(L);
  if (Cardinal(i) < Len) then
  begin
    Obj := Engine.PyList_GetItem(L, i); // Borrowed reference
    ChildData.Data := Obj;
  end
  else
    Obj := nil;
  ChildData.Render := CreateRender(Obj);
end;

function TPyListRender.MainText(Node: PNodeData; Expanded: Boolean): string;
begin
  if Expanded then
    Result := '['
  else
    Result := inherited MainText(Node, Expanded);
end;

{ TPyTupleRender }

function TPyTupleRender.ChildCount(Node: PNodeData): Integer;
var
  L: PPyObject;
begin
  L := Node.Data;
  Result := Engine.PyTuple_Size(L);
end;

procedure TPyTupleRender.InitChildData(ParentData, ChildData: PNodeData;
  ChildIndex: Integer);
var
  Len: Py_ssize_t;
  i: NativeInt;
  Obj: PPyObject;
  L: PPyObject;
begin
  i := ChildIndex;
  L := ParentData.Data;
  Len := Engine.PyTuple_Size(L);
  if (Cardinal(i) < Len) then
  begin
    Obj := Engine.PyTuple_GetItem(L, i); // Borrowed reference
    ChildData.Data := Obj;
  end
  else
    Obj := nil;
  ChildData.Render := CreateRender(Obj);
end;

function TPyTupleRender.MainText(Node: PNodeData; Expanded: Boolean): string;
begin
  if Expanded then
    Result := '('
  else
    Result := inherited MainText(Node, Expanded);
end;

{ TPyDictRender }

function TPyDictRender.MainText(Node: PNodeData; Expanded: Boolean): string;
begin
  if Expanded then
    Result := '{'
  else
    Result := inherited MainText(Node, Expanded);
end;

function TPyDictRender.RenderKey(Obj: PPyObject): string;
begin
  Result := Repr(Obj)
end;

function TPyDictRender.ChildCount(Node: PNodeData): Integer;
begin
  Result := Engine.PyDict_Size(d);
end;

procedure TPyDictRender.InitChildData(ParentData, ChildData: PNodeData;
  ChildIndex: Integer);
begin
  ChildData.Render := IKvRender(Self);
  ChildData.Data := Pointer(NativeInt(ChildIndex));
end;

function TPyDictRender.IKvRender_MainText(Node: PNodeData; Expanded: Boolean
  ): string;
var
  Len: Py_ssize_t;
  i: NativeInt;
  Obj: PPyObject;
begin
  i := NativeInt(Node.Data);

  Len := Engine.PyList_Size(k);
  if (Cardinal(i) < Len) then
  begin
    Obj := Engine.PyList_GetItem(k, i); // Borrowed reference
    Result := RenderKey(Obj) + ':';
  end
  else
    Result := IntToStr(i) + ':';

  if Expanded then
    Exit;

  Len := Engine.PyList_Size(v);
  if (Cardinal(i) < Len) then
  begin
    Obj := Engine.PyList_GetItem(v, i); // Borrowed reference
    Result := Result + ' ' + Repr(Obj);
  end
  else
    Result := Result + ' ?';
end;

function TPyDictRender.IKvRender_ChildCount(Node: PNodeData): Integer;
begin
  Result := 1;
end;

procedure TPyDictRender.IKvRender_InitChildData(ParentData,
  ChildData: PNodeData; ChildIndex: Integer);
var
  Len: Py_ssize_t;
  i: NativeInt;
  Obj: PPyObject;
begin
  i := NativeInt(ParentData.Data);
  Len := Engine.PyList_Size(v);
  if (Cardinal(i) < Len) then
  begin
    Obj := Engine.PyList_GetItem(v, i);
    ChildData.Data := Obj;
    //Engine.Py_XDECREF(Obj);
  end
  else
    Obj := nil;
  ChildData.Render := CreateRender(Obj);
end;

constructor TPyDictRender.Create(AD: PPyObject);
begin
  d := AD;
  Engine.Py_XINCREF(d);
  k := Engine.PyDict_Keys(d);   // New reference
  v := Engine.PyDict_Values(d); // New reference
end;

destructor TPyDictRender.Destroy;
begin
  Engine.Py_XDECREF(v);
  Engine.Py_XDECREF(k);
  Engine.Py_XDECREF(d);
  inherited destroy;
end;

{ TPyScopeRender }

function TPyScopeRender.RenderKey(Obj: PPyObject): string;
begin
  Result := Engine.PyObjectAsString(Obj)
end;

{ TPyModuleRender }

function TPyModuleRender.MainText(Node: PNodeData; Expanded: Boolean): string;
var
  p: PAnsiChar;
begin
  p := Engine.PyModule_GetName(Node.Data);
  Result := Format('module %s', [Utf8String(p)]);
end;

function TPyModuleRender.ChildCount(Node: PNodeData): Integer;
var
  d: PPyObject;
begin
  d := Engine.PyModule_GetDict(Node.Data); //  Borrowed reference.
  Result := Engine.PyDict_Size(d);
end;

constructor TPyModuleRender.Create(AMod: PPyObject);
var
  d: PPyObject;
begin
  d := Engine.PyModule_GetDict(AMod);
  inherited Create(d);
end;

end.

