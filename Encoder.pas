unit Encoder;

interface

uses
  Classes, HuffmanTree, BitsHelper;

procedure Encode(Source, Destination: TStream);

implementation

procedure Encode(Source, Destination: TStream);
const
  SymbolBitsCount = 9;
  EOF = 256;
var
  Tree: THuffmanTree;
  Symbol: TBits;
begin
  Tree := THuffmanTree.Create(SymbolBitsCount);
  Tree.Print;
  while Source.Position < Source.Size do
  begin
    Symbol := CardinalToBits(Source.ReadByte);
    Tree.Add(Symbol);
    Tree.Print;
    WriteLn(BitsToString(Tree.GetCode(Symbol)));
    //BitWriter
    //Destination
  end;
  Tree.Add(CardinalToBits(EOF));
  Tree.Print;
end;

end.
