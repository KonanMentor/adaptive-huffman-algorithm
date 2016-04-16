uses
  Interfaces, Classes, SysUtils, CustApp, Encoder;

type
  TConsoleApplication = class(TCustomApplication)
    protected
      procedure DoRun; override;
    public
      constructor Create(Owner: TComponent); override;
  end;

constructor TConsoleApplication.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  StopOnException := true;
end;

procedure TConsoleApplication.DoRun;
const
  EncodeOptionName = 'e';
  EncodedFileExtension = '.ah';
var
  SourceStream, DestinationStream: TFileStream;
  FileName: String;
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

    try
      DestinationStream := TFileStream.Create(FileName + EncodedFileExtension, fmOpenWrite or fmCreate);
    except
      on E: EFOpenError do
        begin
          WriteLn('Unable to create/write to ouput file');
          Terminate;
          Exit;
        end;
    end;
    Encode(SourceStream, DestinationStream);
  end;

  Terminate;
end;

var
  Application: TConsoleApplication;

begin
  Application := TConsoleApplication.Create(nil);
  Application.Run;
  Application.Free;
end.
