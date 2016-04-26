unit BitWriter;

interface

uses
  Classes, BufferedStream;

type
  TBitWriter = class
    const
      BITS_IN_BYTE = 8;
    private
      FDestination: TBufferedStream;
      FBuffer: Byte;
      FBufferIndex: Byte;
      procedure FlushBuffer;
    public
      constructor Create(Destination: TStream);
      procedure WriteBit(Value: Boolean);
      procedure WriteBits(Bits: TBits);
      procedure Flush;
  end;

implementation

constructor TBitWriter.Create(Destination: TStream);
begin
  FDestination := TBufferedStream.Create(Destination);
  FBufferIndex := SizeOf(FBuffer) * BITS_IN_BYTE - 1;
end;

procedure TBitWriter.WriteBit(Value: Boolean);
begin
  if Value then
    FBuffer := FBuffer xor (1 shl FBufferIndex);
  if FBufferIndex = 0 then
  begin
    FlushBuffer;
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

procedure TBitWriter.FlushBuffer;
begin
  if FBufferIndex = SizeOf(FBuffer) * BITS_IN_BYTE - 1 then
    Exit;

  FDestination.WriteByte(FBuffer);
  FBuffer := 0;
end;

procedure TBitWriter.Flush;
begin
  FlushBuffer;
  FDestination.Flush;
end;

end.
