unit Decoder;

interface

uses
  Classes, HuffmanTree, BitReader, BitsHelper;

procedure Decode(Source, Destination: TStream);

implementation

procedure Decode(Source, Destination: TStream);
const
  SymbolBitsCount = 9;
  EOF = 256;
var
  Tree: THuffmanTree;
  Symbol, Code: TBits;
  BitReader: TBitReader;
begin
  BitReader := TBitReader.Create(Source);
  Tree := THuffmanTree.Create(SymbolBitsCount);
  //Tree.Print;
  while true do
  begin
    Symbol := Tree.GetSymbol(BitReader.ReadBit);
    if Symbol = nil then
      Symbol := BitReader.ReadBits(SymbolBitsCount);
    if BitsToCardinal(Symbol) = EOF then
      break;
    Tree.Add(Symbol);
    //Tree.Print;
    //WriteLn('Symbol:');
    //WriteLn(BitsToString(Symbol));
    Destination.WriteByte(BitsToCardinal(Symbol));
  end;
end;

end.
