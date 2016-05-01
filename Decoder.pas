unit Decoder;

interface

uses
  Classes, HuffmanTree, BitReader, BitsHelper;

type
  TProgressEvent = procedure(PercentComplete: Double) of object;

procedure Decode(Source, Destination: TStream; ProgressCallback: TProgressEvent = nil);

implementation

procedure Decode(Source, Destination: TStream; ProgressCallback: TProgressEvent = nil);
const
  SymbolBitsCount = 9;
  EOF = 256;
  ProgressFreq = 0.01;
var
  Tree: THuffmanTree;
  Symbol, Code: TBits;
  BitReader: TBitReader;
  ProgressStep: Int64;
begin
  BitReader := TBitReader.Create(Source);
  Tree := THuffmanTree.Create(SymbolBitsCount);
  ProgressStep := Round(BitReader.Size * ProgressFreq);
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
    if Assigned(ProgressCallback) then
      if BitReader.Position mod ProgressStep = 0 then
        ProgressCallback(BitReader.Position / BitReader.Size);
  end;
end;

end.
