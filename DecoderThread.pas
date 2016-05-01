unit DecoderThread;

interface

uses
  Classes, Decoder;

type
  TDecodedEvent = procedure of object;
  TErrorEvent = procedure of object;
  TProgressEvent = procedure(PercentComplete: Double) of object;
  TDecoderThread = class(TThread)
    private
      FOnDecoded: TDecodedEvent;
      FOnProgress: TProgressEvent;
      FOnError: TErrorEvent;
      FSource, FDestination: TStream;
      procedure Decoded;
      procedure Error;
      procedure Progress(PercentComplete: Double);
    protected
      procedure Execute; override;
    public
      constructor Create(CreateSuspended: Boolean; Source, Destination: TStream);
      property OnDecoded: TDecodedEvent read FOnDecoded write FOnDecoded;
      property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
      property OnError: TErrorEvent read FOnError write FOnError;
  end;

implementation

type
  TProgressHandler = class
    private
      FPercentComplete: Double;
      FHandler: TProgressEvent;
    public
      constructor Create(PercentComplete: Double; Handler: TProgressEvent);
      procedure Progress;
  end;

constructor TProgressHandler.Create(PercentComplete: Double; Handler: TProgressEvent);
begin
  FPercentComplete := PercentComplete;
  FHandler := Handler;
end;

procedure TProgressHandler.Progress;
begin
  FHandler(FPercentComplete);
end;

procedure TDecoderThread.Decoded;
begin
  if Assigned(FOnDecoded) then
    Queue(FOnDecoded);
end;

procedure TDecoderThread.Error;
begin
  if Assigned(FOnError) then
    Queue(FOnError);
end;

procedure TDecoderThread.Progress(PercentComplete: Double);
var
  ProgressHandler: TProgressHandler;
begin
  if Assigned(FOnProgress) then
  begin
    ProgressHandler := TProgressHandler.Create(PercentComplete, FOnProgress);
    Queue(ProgressHandler.Progress);
  end;
end;

constructor TDecoderThread.Create(CreateSuspended: Boolean; Source, Destination: TStream);
begin
  FSource := Source;
  FDestination := Destination;
  inherited Create(CreateSuspended);
end;

procedure TDecoderThread.Execute;
begin
  try
    Decode(FSource, FDestination, Progress);
  except
    Error;
    Exit;
  end;
  Decoded;
end;

end.
