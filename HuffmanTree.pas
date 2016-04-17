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
      FLeft, FRight, FParent: TNode;
    public
      constructor Create(Symbol: TBits = nil; Parent: TNode = nil; Weight: TWeight = 0);
      property Symbol: TBits read FSymbol write FSymbol;
      property Left: TNode read FLeft write FLeft;
      property Right: TNode read FRight write FRight;
      property Parent: TNode read FParent write FParent;
      property Weight: TWeight read FWeight write FWeight;
  end;
  THuffmanTree = class
    private
      FSymbolBitsCount: Integer;
      FRoot, FNYT: TNode;
      FSymbolNodes: TBitsMap<TNode>;
      procedure Print(Node: TNode; Padding: String); overload;
      function IsLeaf(Node: TNode): Boolean;
      procedure UpdateWeights(Node: TNode);
      procedure GetCode(Node: TNode; Code: TBits; Index: Integer); overload;
    public
      type
        TPredicate = function: Boolean of object;
      constructor Create(SymbolBitsCount: Integer);
      function Add(Symbol: TBits): TBits;
      function GetCode(Symbol: TBits): TBits; overload;
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

constructor THuffmanTree.Create(SymbolBitsCount: Integer);
begin
  FSymbolBitsCount := SymbolBitsCount;
  FSymbolNodes := TBitsMap<TNode>.Create(SymbolBitsCount);
  FNYT := TNode.Create;
  FRoot := FNYT;
end;

function THuffmanTree.IsLeaf(Node: TNode): Boolean;
begin
  Result := (Node.Left = nil) and (Node.Right = nil);
end;

procedure THuffmanTree.UpdateWeights(Node: TNode);
begin
  if not IsLeaf(Node) then
    Node.Weight := Node.Left.Weight + Node.Right.Weight;
  if Node <> FRoot then
    UpdateWeights(Node.Parent);
end;

function THuffmanTree.Add(Symbol: TBits): TBits;
var
  SymbolNode: TNode;
begin
  SymbolNode := FSymbolNodes.Get(Symbol);
  Result := TBits.Create;
  if SymbolNode = nil then
  begin
    FNYT.Left := TNode.Create(nil, FNYT);
    FNYT.Right := TNode.Create(Symbol, FNYT, 1);
    FSymbolNodes.Put(Symbol, FNYT.Right);
    UpdateWeights(FNYT);
    GetCode(FNYT, Result, 0);
    Result := ConcatBits(Result, Symbol);
    FNYT := FNYT.Left;
  end
  else
  begin
    SymbolNode.Weight := SymbolNode.Weight + 1;
    UpdateWeights(SymbolNode);
    GetCode(SymbolNode, Result, 0);
  end;
  WriteLn(BitsToCardinal(Symbol));
end;

procedure THuffmanTree.Print(Node: TNode; Padding: String);
var
  Symbol: Integer;
begin
  if Node = nil then
    Exit;
  if Node.Symbol = nil then
    Symbol := -1
  else
    Symbol := BitsToCardinal(Node.Symbol);
  WriteLn(Format('%ss: %d, w: %d', [Padding, Symbol, Node.Weight]));
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
