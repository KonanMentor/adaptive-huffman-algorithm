unit Encoder;

interface

uses
  Classes, HuffmanTree, BitsHelper, BitWriter;

procedure Encode(Source, Destination: TStream);

implementation

procedure Encode(Source, Destination: TStream);
const
  SymbolBitsCount = 9;
  EOF = 256;
var
  Tree: THuffmanTree;
  Symbol, Code: TBits;
  BitWriter: TBitWriter;
begin
  BitWriter := TBitWriter.Create(Destination);
  Tree := THuffmanTree.Create(SymbolBitsCount);
  Tree.Print;
  while Source.Position < Source.Size do
  begin
    Symbol := CardinalToBits(Source.ReadByte, SymbolBitsCount);
    Code := Tree.Add(Symbol);
    Tree.Print;
    WriteLn(BitsToString(Code));
    BitWriter.WriteBits(Code);
  end;
  Code := Tree.Add(CardinalToBits(EOF, SymbolBitsCount));
  Tree.Print;
  WriteLn(BitsToString(Code));
  BitWriter.WriteBits(Code);
  BitWriter.Flush;
end;

end.
