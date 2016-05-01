unit Encoder;

interface

uses
  Classes, HuffmanTree, BitsHelper, BitWriter, BufferedStream;

type
  TProgressEvent = procedure(PercentComplete: Double) of object;

procedure Encode(Source, Destination: TStream; ProgressCallback: TProgressEvent = nil);

implementation

procedure Encode(Source, Destination: TStream; ProgressCallback: TProgressEvent = nil);
const
  SymbolBitsCount = 9;
  EOF = 256;
  ProgressFreq = 0.01;
var
  Tree: THuffmanTree;
  Symbol, EOFBits: TBits;
  BitWriter: TBitWriter;
  BufferedSource: TBufferedStream;
  ProgressStep: Int64;

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
  BufferedSource := TBufferedStream.Create(Source);
  ProgressStep := Round(BufferedSource.Size * ProgressFreq);
  //Tree.Print;
  while BufferedSource.Position < BufferedSource.Size do
  begin
    Symbol := CardinalToBits(BufferedSource.ReadByte, SymbolBitsCount);
    WriteSymbolCode(Symbol);
    Tree.Add(Symbol);
    if Assigned(ProgressCallback) then
      if BufferedSource.Position mod ProgressStep = 0 then
        ProgressCallback(BufferedSource.Position / BufferedSource.Size);
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
