unit BufferedStream;

interface

uses
  Classes;

type
  TBufferedStream = class(TStream)
    private
      FStream: TStream;
      FWriteBuffer, FReadBuffer: array of Byte;
      FWriteBufferIndex, FReadBufferIndex: Cardinal;
      FPosition: Int64;
      procedure Fetch;
    protected
      function GetPosition: Int64; override;
      function GetSize: Int64; override;
    public
      constructor Create(Stream: TStream; BufferSize: Cardinal = 1024 * 1024);
      procedure WriteByte(Data: Byte);
      function ReadByte: Byte;
      procedure Flush;
  end;

implementation

constructor TBufferedStream.Create(Stream: TStream; BufferSize: Cardinal = 1024 * 1024);
begin
  FStream := Stream;
  FPosition := 0;
  SetLength(FWriteBuffer, BufferSize);
  FWriteBufferIndex := 0;
  SetLength(FReadBuffer, BufferSize);
  FReadBufferIndex := BufferSize;
end;

procedure TBufferedStream.WriteByte(Data: Byte);
begin
  FWriteBuffer[FWriteBufferIndex] := Data;
  FWriteBufferIndex := FWriteBufferIndex + 1;
  if FWriteBufferIndex = Length(FWriteBuffer) then
    Flush;
end;

function TBufferedStream.ReadByte: Byte;
begin
  if FReadBufferIndex = Length(FReadBuffer) then
    Fetch;
  Result := FReadBuffer[FReadBufferIndex];
  FReadBufferIndex := FReadBufferIndex + 1;
  FPosition := FPosition + 1;
end;

procedure TBufferedStream.Fetch;
begin
  FStream.Read(Pointer(FReadBuffer)^, Length(FReadBuffer));
  FReadBufferIndex := 0;
end;

procedure TBufferedStream.Flush;
begin
  FStream.WriteBuffer(Pointer(FWriteBuffer)^, FWriteBufferIndex);
  FWriteBufferIndex := 0;
end;

function TBufferedStream.GetPosition: Int64;
begin
  Result := FPosition;
end;

function TBufferedStream.GetSize: Int64;
begin
  Result := FStream.Size;
end;

end.
