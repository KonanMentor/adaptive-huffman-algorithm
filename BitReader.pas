unit BitReader;

interface

uses
  Classes, BufferedStream;

type
  TBitReader = class
    const
      BITS_IN_BYTE = 8;
    private
      FSource: TBufferedStream;
      FBuffer: Byte;
      FBufferIndex: Byte;
      FPosition, FSize: Int64;
      procedure ReadBuffer;
    public
      constructor Create(Source: TStream);
      function ReadBit: Boolean;
      function ReadBits(Count: Cardinal): TBits;
      property Position: Int64 read FPosition;
      property Size: Int64 read FSize;
  end;

implementation

constructor TBitReader.Create(Source: TStream);
begin
  FSource := TBufferedStream.Create(Source);
  FBufferIndex := SizeOf(FBuffer) * BITS_IN_BYTE - 1;
  FSize := FSource.Size * BITS_IN_BYTE;
end;

function TBitReader.ReadBit: Boolean;
begin
  if FBufferIndex = SizeOf(FBuffer) * BITS_IN_BYTE - 1 then
    ReadBuffer;

  Result := (FBuffer and (1 shl FBufferIndex)) <> 0;

  FPosition += 1;

  if FBufferIndex = 0 then
    FBufferIndex := SizeOf(FBuffer) * BITS_IN_BYTE - 1
  else
    FBufferIndex := FBufferIndex - 1;
end;

function TBitReader.ReadBits(Count: Cardinal): TBits;
var
  i: Integer;
begin
  Result := TBits.Create(Count);
  for i := Count - 1 downto 0 do
    Result.Bits[i] := ReadBit;
end;

procedure TBitReader.ReadBuffer;
begin
  FBuffer := FSource.ReadByte;
end;

end.
