unit InspectBase;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, Controls,
  {$IFDEF FPC} LResources, LCLType, {$ENDIF}
  VirtualTrees;

type
  PNodeData = ^TNodeData;

  IDataRender = interface(IInterface)
    function MainText(Node: PNodeData; Expanded: Boolean): string;
    function ChildCount(Node: PNodeData): Integer;
    procedure InitChildData(ParentData, ChildData: PNodeData; ChildIndex: Integer);
  end;

  TNodeData = record
    Render: IDataRender;
    Data: Pointer;
  end;

  TRowDisplayer = function (Column: Integer; AData: PNodeData; Expanded: Boolean): WideString;

  TVirtualStringTreeEx = class(TVirtualStringTree)
  public
    procedure InitPrevNodes(Node: PVirtualNode);
  end;

  TTreeAdapter = class(TObject)
  private
    RootData: TNodeData;
  protected
    procedure VirtualStringTree1GetNodeDataSize(Sender: TBaseVirtualTree; var
            NodeDataSize: Integer);
    procedure VirtualStringTree1InitNode(Sender: TBaseVirtualTree; ParentNode,
            Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure VirtualStringTree1FreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree; Node:
            PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var
            CellText: String);
  public
    RowDisplayer: TRowDisplayer;
    procedure SetRootNode(Render: IDataRender; Data: Pointer);
    procedure DefineColumns(Tree: TBaseVirtualTree; TreeColumn: Integer; ARowDisplayer: TRowDisplayer;
            const Titles: array of String; const Widths: array of Integer);
  end;

implementation


{ TVirtualStringTreeEx }

procedure TVirtualStringTreeEx.InitPrevNodes(Node: PVirtualNode);
var
  Prev: PVirtualNode;
  i, n: Integer;
  LNodes: array of PVirtualNode;
begin
  n := 0;
  Prev := Node;
  repeat
    if vsInitialized in Prev^.States then
      Break;
    Inc(n);
    Prev := Prev^.PrevSibling;
  until Prev = nil;
  SetLength(LNodes, n);
  Prev := Node;
  for i := 0 to n - 1 do
  begin
    LNodes[i] := Prev;
    Prev := Prev^.PrevSibling;
  end;

  for i := n - 1 downto 0 do
    InitNode(LNodes[i]);
end;


{ TTreeAdapter }

procedure TTreeAdapter.VirtualStringTree1GetNodeDataSize(Sender: TBaseVirtualTree;
        var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TNodeData);
end;

procedure TTreeAdapter.VirtualStringTree1InitNode(Sender: TBaseVirtualTree;
        ParentNode, Node: PVirtualNode; var InitialStates:
        TVirtualNodeInitStates);
var
  Data: Pointer;
  DataRef: PNodeData;
  nChild: Integer;
  ParentData: PNodeData;
  //Script: IScriptObject;
  Render: IDataRender;
begin
  DataRef := PNodeData(Sender.GetNodeData(Node));

  if Assigned(ParentNode) then
  try //begin
    ParentData := Sender.GetNodeData(ParentNode);
    ParentData.Render.InitChildData(ParentData, DataRef, Node.Index) ;
    Render := DataRef.Render;
  except
    Data := nil;
  end
  else
  begin
    Data := RootData.Data;
    Render := RootData.Render;
    DataRef.Data := Data;
    DataRef.Render := Render;
  end;

  nChild := Render.ChildCount(DataRef);
  Sender.ChildCount[Node] := nChild;

  (*
  DataRef := PNodeData(Sender.GetNodeData(Node));
  DataRef.ptr := Ptr;
  DataRef.car := Data;

  if nChild > MaxChildCount then
    nChild := MaxChildCount;
  Sender.ChildCount[Node] := nChild;
  *)
end;

procedure TTreeAdapter.VirtualStringTree1FreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PNodeData;
begin
  Data := PNodeData(Sender.GetNodeData(Node));
  Data^.Render := nil;
  //Data.Free; }
end;

procedure TTreeAdapter.VirtualStringTree1GetText(Sender: TBaseVirtualTree; Node:
        PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var
        CellText: String);
var
  y: Integer;
begin
  y := Node.Index;
  case Column of
    0:   CellText := Format('%d:%d', [Sender.GetNodeLevel(Node), y]);
    else
      // try
         CellText := RowDisplayer(Column, PNodeData(Sender.GetNodeData(Node)), vsExpanded in Node^.States);
      // except
      //   on E: Exception do
      //     Log('except @ TTreeAdapter.VirtualStringTree1GetText(%d, %d)'#10#10#9'%s: %s',
      //       [Column, y, E.ClassName, E.Message]);
      // else
      //   Log('except @ TTreeAdapter.VirtualStringTree1GetText(%d, %d)', [Column, y]);
      // end;
  end
end;

procedure TTreeAdapter.SetRootNode(Render: IDataRender; Data: Pointer);
begin
  RootData.Render := Render;
  RootData.Data := Data;
end;


procedure TTreeAdapter.DefineColumns(Tree: TBaseVirtualTree; TreeColumn: Integer; ARowDisplayer:
    TRowDisplayer; const Titles: array of String; const Widths: array of
    Integer);
var
  i: Integer;
  v: TVirtualStringTreeEx;
begin
  RowDisplayer := ARowDisplayer;
  v := TVirtualStringTreeEx(Tree);
  //with VirtualStringTree1 do
  begin
    v.Header.Options := [hoColumnResize, hoDrag, hoVisible];
    for i := Low(Titles) to High(Titles) do
      with v.Header.Columns.Add do
      begin
        Position := i;
        Width := Widths[i];
        Text := Titles[i];
      end;
    v.Header.AutoSizeIndex := TreeColumn;
    v.Header.MainColumn := TreeColumn;

    v.OnFreeNode := VirtualStringTree1FreeNode;
    v.OnGetText := VirtualStringTree1GetText;
    v.OnGetNodeDataSize := VirtualStringTree1GetNodeDataSize;
    v.OnInitNode := VirtualStringTree1InitNode;

    v.RootNodeCount := 1;
  end;
  //UpdateToolMenu;
end;

end.

