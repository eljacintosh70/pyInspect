unit WndTree;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  VirtualTrees, InspectBase;


type

  { TTreeForm }

  TTreeForm = class(TForm)
    VirtualStringTree1: TVirtualStringTree;
  protected
    procedure VirtualStringTree1InvalidNode(Sender: TBaseVirtualTree;
            Node: PVirtualNode);
    procedure VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree;
            Node: PVirtualNode; Column: TColumnIndex);
    procedure VirtualStringTree1Expanding(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
  public
    TreeAdapter: TTreeAdapter;
    function InitTree: TVirtualStringTree;
  end;

var
  TreeForm: TTreeForm;

implementation

{$R *.dfm}

{ TTreeForm }

function TTreeForm.InitTree: TVirtualStringTree;
var
  v: TVirtualStringTree;
begin
  v := VirtualStringTree1;
  //VirtualStringTree1 := TVirtualStringTreeEx.Create(Self);
  //with VirtualStringTree1 do
  begin
//    v.Parent := Self;
//    v.Left := 0;
//    v.Top := 25;
//    v.Width := 688;
//    v.Height := 401;
//    v.Align := alClient;
    v.ClipboardFormats.Add('Plain text');
    v.Header.Font.Charset := DEFAULT_CHARSET;
//    v.Header.Font.Color := clWindowText;
//    v.Header.Font.Height := -11;
//    v.Header.Font.Name := 'MS Sans Serif';
//    v.Header.Font.Style := [];
    v.TabOrder := 0;
    v.TreeOptions.SelectionOptions := [toMultiSelect];
    v.TreeOptions.AutoOptions := [toAutoDropExpand, toAutoTristateTracking,
        toAutoScrollOnExpand, toAutoChangeScale{, toAutoDeleteMovedNodes, toAutoSort}];
    v.OnCollapsed := VirtualStringTree1InvalidNode;
    v.OnExpanded := VirtualStringTree1InvalidNode;
    v.OnFocusChanged := VirtualStringTree1FocusChanged;
    v.OnExpanding := VirtualStringTree1Expanding;
  end;
  Result := v;
end;

procedure TTreeForm.VirtualStringTree1InvalidNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  VirtualStringTree1.InvalidateNode(Node);
end;

procedure TTreeForm.VirtualStringTree1Expanding(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var Allowed: Boolean);
var
  NodaData: PNodeData;
  //nChild: Integer;
begin
  NodaData := Sender.GetNodeData(Node);
  if not Assigned(NodaData^.Render) then
  begin
    {
    if IsString(NodaData^.car) then
    begin
      NodaData^.Render := LinesArray(NodaData^.car);
      nChild := NodaData^.Render.Length;
      Sender.ChildCount[Node] := nChild;
    end;
    }
    Allowed := True;
  end;
end;

procedure TTreeForm.VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
{
var
  i: Integer;
  Tool: ITool;
  Data: PToolData;
}
begin
{
  CbPath.Text := NodePath(Sender.RootNode, Node);
  FocusNode := Node;
  if Assigned(Tools) then
  begin
    Data := VirtualStringTree1.GetNodeData(Node);
    for i := 0 to Tools.Count - 1 do
    begin
      Tool := ITool(Tools[i]);
      Tool.ChangeActive(Data);
    end;
  end;
}
end;

end.

