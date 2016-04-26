uses
  Interfaces, Classes, SysUtils, CustApp, Encoder, Decoder, Stopwatch, FormatUtils;

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
  DecodeOptionName = 'd';
  EncodedFileExtension = '.ah';
  DecodedFileExtension = '.out';
var
  SourceStream, DestinationStream: TFileStream;
  FileName: String;
  Stopwatch: TStopwatch;
begin
  if HasOption(EncodeOptionName) and HasOption(DecodeOptionName) then
  begin
    WriteLn('Simultaneous encoding and decoding is now allowed');
    Terminate;
    Exit;
  end;

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

    try
      Stopwatch := TStopwatch.StartNew;
      Encode(SourceStream, DestinationStream);
      Stopwatch.Stop;
      WriteLn(Format('Compression ratio: %.2f' + sLineBreak + 'Elapsed time: %.3fs' + sLineBreak + 'Original file size: %s' + sLineBreak + 'Compressed file size: %s', [DestinationStream.Size / SourceStream.Size, Stopwatch.GetElapsedMilliseconds / 1000, FormatBytes(SourceStream.Size), FormatBytes(DestinationStream.Size)]));
    finally
      SourceStream.Free;
      DestinationStream.Free;
    end;
  end;

  if HasOption(DecodeOptionName) then
  begin
    FileName := GetOptionValue(DecodeOptionName);
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
      DestinationStream := TFileStream.Create(FileName + DecodedFileExtension, fmOpenWrite or fmCreate);
    except
      on E: EFOpenError do
        begin
          WriteLn('Unable to create/write to ouput file');
          Terminate;
          Exit;
        end;
    end;
    try
      try
        Stopwatch := TStopwatch.StartNew;
        Decode(SourceStream, DestinationStream);
        Stopwatch.Stop;
      WriteLn(Format('Elapsed time: %.3fs' + sLineBreak + 'Original file size: %s' + sLineBreak + 'Decompressed file size: %s', [Stopwatch.GetElapsedMilliseconds / 1000, FormatBytes(SourceStream.Size), FormatBytes(DestinationStream.Size)]));
      except
        WriteLn('Unable to decode file');
      end;
    finally
      SourceStream.Free;
      DestinationStream.Free;
    end;
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
