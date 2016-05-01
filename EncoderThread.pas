unit EncoderThread;

interface

uses
  Classes, Encoder;

type
  TEncodedEvent = procedure of object;
  TProgressEvent = procedure(PercentComplete: Double) of object;
  TEncoderThread = class(TThread)
    private
      FOnEncoded: TEncodedEvent;
      FOnProgress: TProgressEvent;
      FSource, FDestination: TStream;
      procedure Encoded;
      procedure Progress(PercentComplete: Double);
    protected
      procedure Execute; override;
    public
      constructor Create(CreateSuspended: Boolean; Source, Destination: TStream);
      property OnEncoded: TEncodedEvent read FOnEncoded write FOnEncoded;
      property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
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

procedure TEncoderThread.Encoded;
begin
  if Assigned(FOnEncoded) then
    Queue(FOnEncoded);
end;

procedure TEncoderThread.Progress(PercentComplete: Double);
var
  ProgressHandler: TProgressHandler;
begin
  if Assigned(FOnProgress) then
  begin
    ProgressHandler := TProgressHandler.Create(PercentComplete, FOnProgress);
    Queue(ProgressHandler.Progress);
  end;
end;

constructor TEncoderThread.Create(CreateSuspended: Boolean; Source, Destination: TStream);
begin
  FSource := Source;
  FDestination := Destination;
  inherited Create(CreateSuspended);
end;

procedure TEncoderThread.Execute;
begin
  Encode(FSource, FDestination, Progress);
  Encoded;
end;

end.
