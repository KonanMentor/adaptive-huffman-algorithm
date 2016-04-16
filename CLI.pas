uses
  Interfaces, Classes, SysUtils, CustApp, Encoder;

type
  TConsoleApplication = class(TCustomApplication)
    protected
      procedure DoRun; override;
    public
      constructor Create;
  end;

constructor TConsoleApplication.Create;
begin
  inherited Create(nil);
  StopOnException := true;
end;

procedure TConsoleApplication.DoRun;
const
  EncodeOptionName = 'e';
var
  SourceStream: TFileStream;
  FileName: String;
  Encoder: TEncoder;
begin
  if HasOption(EncodeOptionName) then
  begin
    FileName := GetOptionValue(EncodeOptionName);
    try
      SourceStream := TFileStream.Create(FileName, fmOpenRead);
    except
      on E: EFOpenError do
        begin
          WriteLn('Unable to read file');
          Terminate;
          Exit;
        end;
    end;

    Encoder := TEncoder.Create(SourceStream, nil);
  end;

  Terminate;
end;

var
  Application: TConsoleApplication;

begin
  Application := TConsoleApplication.Create;
  Application.Run;
  Application.Free;
end.
