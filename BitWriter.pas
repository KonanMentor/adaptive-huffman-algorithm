unit BitWriter;

interface

uses
  Classes;

type
  TBitWriter = class
    const
      BITS_IN_BYTE = 8;
    private
      FDestination: TStream;
      FBuffer: Byte;
      FBufferIndex: Byte;
    public
      constructor Create(Destination: TStream);
      procedure WriteBit(Value: Boolean);
      procedure WriteBits(Bits: TBits);
      procedure Flush;
  end;

implementation

constructor TBitWriter.Create(Destination: TStream);
begin
  FDestination := Destination;
  FBufferIndex := SizeOf(FBuffer) * BITS_IN_BYTE - 1;
end;

procedure TBitWriter.WriteBit(Value: Boolean);
begin
  if Value then
    FBuffer := FBuffer xor (1 shl FBufferIndex);
  if FBufferIndex = 0 then
  begin
    Flush;
    FBufferIndex := SizeOf(FBuffer) * BITS_IN_BYTE - 1;
  end
  else
    FBufferIndex := FBufferIndex - 1;
end;

procedure TBitWriter.WriteBits(Bits: TBits);
var
  i: Integer;
begin
  for i := Bits.Size - 1 downto 0 do
    WriteBit(Bits.Get(i));
end;

procedure TBitWriter.Flush;
begin
  if FBufferIndex = SizeOf(FBuffer) * BITS_IN_BYTE - 1 then
    Exit;

  FDestination.WriteByte(FBuffer);
  FBuffer := 0;
end;

end.
