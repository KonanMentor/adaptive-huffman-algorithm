unit HuffmanTree;

interface

uses
  Classes, BitsMap, BitsHelper, SysUtils;

type
  TNode = class
    public
      type
        TWeight = Int64;
    private
      FSymbol: TBits;
      FWeight: TWeight;
      FOrder: Integer;
      FLeft, FRight, FParent: TNode;
    public
      constructor Create(Symbol: TBits = nil; Parent: TNode = nil; Weight: TWeight = 0);
      procedure ChangeChild(OldChild, NewChild: TNode);
      property Symbol: TBits read FSymbol write FSymbol;
      property Left: TNode read FLeft write FLeft;
      property Right: TNode read FRight write FRight;
      property Parent: TNode read FParent write FParent;
      property Weight: TWeight read FWeight write FWeight;
      property Order: Integer read FOrder write FOrder;
  end;
  THuffmanTree = class
    private
      FSymbolBitsCount: Integer;
      FRoot, FNYT: TNode;
      FSymbolNodes: TBitsMap<TNode>;
      FNodes: array of TNode;
      procedure PrintNode(Node: TNode; Padding: String = '');
      procedure Print(Node: TNode; Padding: String); overload;
      function IsLeaf(Node: TNode): Boolean;
      procedure GetCode(Node: TNode; Code: TBits; Index: Integer); overload;
      procedure Exchange(A, B: TNode);
      function GetLeader(Node: TNode): TNode;
      procedure UpdateTree(Node: TNode);
      procedure PushNode(Node: TNode);
    public
      type
        TPredicate = function: Boolean of object;
      constructor Create(SymbolBitsCount: Integer);
      function Has(Symbol: TBits): Boolean;
      procedure Add(Symbol: TBits);
      function GetCode(Symbol: TBits): TBits; overload;
      function GetNYTCode: TBits;
      function GetSymbol(DoGoRight: TPredicate): TBits;
      procedure Print; overload;
  end;

implementation

constructor TNode.Create(Symbol: TBits; Parent: TNode; Weight: TWeight);
begin
  FSymbol := Symbol;
  FParent := Parent;
  FWeight := Weight;
end;

procedure TNode.ChangeChild(OldChild, NewChild: TNode);
begin
  if OldChild = FLeft then
    FLeft := NewChild
  else
    FRight := NewChild;
  NewChild.Parent := Self;
end;

constructor THuffmanTree.Create(SymbolBitsCount: Integer);
begin
  FSymbolBitsCount := SymbolBitsCount;
  FSymbolNodes := TBitsMap<TNode>.Create(SymbolBitsCount);
  FNYT := TNode.Create;
  FRoot := FNYT;
  PushNode(FRoot);
end;

function THuffmanTree.IsLeaf(Node: TNode): Boolean;
begin
  Result := (Node.Left = nil) and (Node.Right = nil);
end;

function THuffmanTree.GetLeader(Node: TNode): TNode;
var
  Index: Integer;
begin
  Index := Node.Order;
  while (Index >= 0) and (FNodes[Index].Weight = Node.Weight) do
  begin
    if (not IsLeaf(Node)) or (IsLeaf(FNodes[Index]) = IsLeaf(Node)) then
      Result := FNodes[Index];
    Index := Index - 1;
  end;
end;

procedure THuffmanTree.Exchange(A, B: TNode);
var
  TempNode: TNode;
  TempInt: Integer;
begin
  //WriteLn('Exchange');
  //PrintNode(A);
  //PrintNode(B);

  if A = B then
    Exit;

  TempNode := A.Parent;
  B.Parent.ChangeChild(B, A);
  TempNode.ChangeChild(A, B);

  TempInt := A.Order;
  A.Order := B.Order;
  B.Order := TempInt;

  FNodes[A.Order] := A;
  FNodes[B.Order] := B;
end;

procedure THuffmanTree.UpdateTree(Node: TNode);
begin
  Exchange(GetLeader(Node), Node);
  Node.Weight := Node.Weight + 1;
  if Node.Parent <> nil then
    UpdateTree(Node.Parent);
end;

procedure THuffmanTree.PushNode(Node: TNode);
begin
  SetLength(FNodes, Length(FNodes) + 1);
  FNodes[Length(FNodes) - 1] := Node;
  Node.Order := Length(FNodes) - 1;
end;

function THuffmanTree.Has(Symbol: TBits): Boolean;
begin
  Result := FSymbolNodes.Has(Symbol);
end;

procedure THuffmanTree.Add(Symbol: TBits);
var
  SymbolNode, NewNYTNode: TNode;
begin
  //Write('Add ');
  //WriteLn(BitsToCardinal(Symbol));
  SymbolNode := FSymbolNodes.Get(Symbol);
  if SymbolNode = nil then
  begin
    SymbolNode := TNode.Create(Symbol, FNYT, 0);
    NewNYTNode := TNode.Create(nil, FNYT);
    FNYT.Left := SymbolNode;
    FNYT.Right := NewNYTNode;
    FSymbolNodes.Put(Symbol, SymbolNode);
    PushNode(SymbolNode);
    PushNode(NewNYTNode);
    FNYT := NewNYTNode;
  end;
  UpdateTree(SymbolNode);
end;

procedure THuffmanTree.PrintNode(Node: TNode; Padding: String = '');
var
  Symbol: Integer;
begin
  if Node.Symbol = nil then
    Symbol := -1
  else
    Symbol := BitsToCardinal(Node.Symbol);
  WriteLn(Format('%ss: %d, w: %d', [Padding, Symbol, Node.Weight]));
end;

procedure THuffmanTree.Print(Node: TNode; Padding: String);
begin
  if Node = nil then
    Exit;
  PrintNode(Node, Padding);
  Print(Node.Left, Padding + '  ');
  Print(Node.Right, Padding + '  ');
end;

procedure THuffmanTree.GetCode(Node: TNode; Code: TBits; Index: Integer);
begin
  if Node <> FRoot then
  begin
    Code.Grow(Index + 1);
    if Node.Parent.Right = Node then
      Code.SetOn(Index);
    GetCode(Node.Parent, Code, Index + 1);
  end;
end;

function THuffmanTree.GetCode(Symbol: TBits): TBits;
begin
  Result := TBits.Create;
  GetCode(FSymbolNodes.Get(Symbol), Result, 0);
end;

function THuffmanTree.GetNYTCode: TBits;
begin
  Result := TBits.Create;
  GetCode(FNYT, Result, 0);
end;

procedure THuffmanTree.Print;
begin
  Print(FRoot, '');
end;

function THuffmanTree.GetSymbol(DoGoRight: TPredicate): TBits;
var
  Node: TNode;
begin
  Node := FRoot;
  while not IsLeaf(Node) do
    if DoGoRight then
      Node := Node.Right
    else
      Node := Node.Left;
  Result := Node.Symbol;
end;

end.
