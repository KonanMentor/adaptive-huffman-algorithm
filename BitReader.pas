unit BitReader;

interface

uses
  Classes;

type
  TBitReader = class
    const
      BITS_IN_BYTE = 8;
    private
      FSource: TStream;
      FBuffer: Byte;
      FBufferIndex: Byte;
      procedure ReadBuffer;
    public
      constructor Create(Source: TStream);
      function ReadBit: Boolean;
      function ReadBits(Count: Cardinal): TBits;
  end;

implementation

constructor TBitReader.Create(Source: TStream);
begin
  FSource := Source;
  FBufferIndex := SizeOf(FBuffer) * BITS_IN_BYTE - 1;
end;

function TBitReader.ReadBit: Boolean;
begin
  if FBufferIndex = SizeOf(FBuffer) * BITS_IN_BYTE - 1 then
    ReadBuffer;

  Result := (FBuffer and (1 shl FBufferIndex)) <> 0;

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
