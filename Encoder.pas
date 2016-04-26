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
  Symbol, EOFBits: TBits;
  BitWriter: TBitWriter;

  procedure WriteSymbolCode(Symbol: TBits);
  begin
    if not Tree.Has(Symbol) then
    begin
      BitWriter.WriteBits(Tree.GetNYTCode());
      BitWriter.WriteBits(Symbol);
    end
    else
    begin
      BitWriter.WriteBits(Tree.GetCode(Symbol));
    end;
  end;
begin
  BitWriter := TBitWriter.Create(Destination);
  Tree := THuffmanTree.Create(SymbolBitsCount);
  //Tree.Print;
  while Source.Position < Source.Size do
  begin
    Symbol := CardinalToBits(Source.ReadByte, SymbolBitsCount);
    WriteSymbolCode(Symbol);
    Tree.Add(Symbol);
    //Tree.Print;
  end;
  //Tree.Print;
  EOFBits := CardinalToBits(EOF, SymbolBitsCount);
  WriteSymbolCode(EOFBits);
  Tree.Add(EOFBits);
  //WriteLn(BitsToString(Code));
  BitWriter.Flush;
end;

end.
