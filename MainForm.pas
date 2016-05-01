unit MainForm;

interface

uses
  Forms, Classes, EditBtn, StdCtrls, EncoderThread, DecoderThread, Stopwatch, Dialogs, SysUtils, FormatUtils, ComCtrls, Math;

type
  TMainForm = class(TForm)
    public
      constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    private
      FFileNameEdit: TFileNameEdit;
      FEncodeButton, FDecodeButton: TButton;
      FProgressBar: TProgressBar;
      FEncoderThread: TEncoderThread;
      FDecoderThread: TDecoderThread;
      FStopwatch: TStopwatch;
      FSourceStream, FDestinationStream: TFileStream;
      procedure DisableCodingOperations;
      procedure EnableCodingOperations;
      procedure Encoded;
      procedure Decoded;
      procedure DecoderError;
      procedure Progress(PercentComplete: Double);
      procedure FormResize(Sender: TObject);
      procedure EncodeButtonClick(Sender: TObject);
      procedure DecodeButtonClick(Sender: TObject);
  end;

implementation

procedure TMainForm.DisableCodingOperations;
begin
  FEncodeButton.Enabled := false;
  FDecodeButton.Enabled := false;
end;

procedure TMainForm.EnableCodingOperations;
begin
  FEncodeButton.Enabled := true;
  FDecodeButton.Enabled := true;
end;

procedure TMainForm.Encoded;
begin
  FProgressBar.Position := 0;
  FStopwatch.Stop;
  ShowMessage(Format('Compression ratio: %.2f' + sLineBreak + 'Elapsed time: %.3fs' + sLineBreak + 'Original file size: %s' + sLineBreak + 'Compressed file size: %s', [FDestinationStream.Size / FSourceStream.Size, FStopwatch.GetElapsedMilliseconds / 1000, FormatBytes(FSourceStream.Size), FormatBytes(FDestinationStream.Size)]));
  FStopwatch.Free;
  FSourceStream.Free;
  FDestinationStream.Free;
  FEncoderThread.Terminate;
  FEncoderThread.Free;
  EnableCodingOperations;
end;

procedure TMainForm.Decoded;
begin
  FProgressBar.Position := 0;
  FStopwatch.Stop;
  ShowMessage(Format('Elapsed time: %.3fs' + sLineBreak + 'Original file size: %s' + sLineBreak + 'Decompressed file size: %s', [FStopwatch.GetElapsedMilliseconds / 1000, FormatBytes(FSourceStream.Size), FormatBytes(FDestinationStream.Size)]));
  FStopwatch.Free;
  FSourceStream.Free;
  FDestinationStream.Free;
  FDecoderThread.Terminate;
  FDecoderThread.Free;
  EnableCodingOperations;
end;

procedure TMainForm.DecoderError;
begin
  FProgressBar.Position := 0;
  FStopwatch.Stop;
  ShowMessage('Unable to decode file');
  FStopwatch.Free;
  FSourceStream.Free;
  FDestinationStream.Free;
  FDecoderThread.Terminate;
  FDecoderThread.Free;
  EnableCodingOperations;
end;

procedure TMainForm.Progress(PercentComplete: Double);
begin
  FProgressBar.Position := Ceil(PercentComplete * 100);
end;

procedure TMainForm.EncodeButtonClick(Sender: TObject);
const
  EncodedFileExtension = '.ah';
var
  FileName: String;
begin
  FileName := FFileNameEdit.FileName;
  try
    FSourceStream := TFileStream.Create(FileName, fmOpenRead);
  except
    on E: EFOpenError do
      begin
        ShowMessage('Unable to read file');
        Exit;
      end;
  end;

  try
    FDestinationStream := TFileStream.Create(FileName + EncodedFileExtension, fmOpenWrite or fmCreate);
  except
    on E: EFOpenError do
      begin
        ShowMessage('Unable to create/write to ouput file');
        Exit;
      end;
  end;

  DisableCodingOperations;
  FStopwatch := TStopwatch.StartNew;
  FEncoderThread := TEncoderThread.Create(true, FSourceStream, FDestinationStream);
  FEncoderThread.OnEncoded := Encoded;
  FEncoderThread.OnProgress := Progress;
  FEncoderThread.Start;
end;

procedure TMainForm.DecodeButtonClick(Sender: TObject);
const
  DecodedFileExtension = '.out';
var
  FileName: String;
begin
  FileName := FFileNameEdit.FileName;
  try
    FSourceStream := TFileStream.Create(FileName, fmOpenRead);
  except
    on E: EFOpenError do
      begin
        ShowMessage('Unable to read file');
        Exit;
      end;
  end;

  try
    FDestinationStream := TFileStream.Create(FileName + DecodedFileExtension, fmOpenWrite or fmCreate);
  except
    on E: EFOpenError do
      begin
        ShowMessage('Unable to create/write to ouput file');
        Exit;
      end;
  end;

  DisableCodingOperations;
  FStopwatch := TStopwatch.StartNew;
  FDecoderThread := TDecoderThread.Create(true, FSourceStream, FDestinationStream);
  FDecoderThread.OnDecoded := Decoded;
  FDecoderThread.OnProgress := Progress;
  FDecoderThread.OnError := DecoderError;
  FDecoderThread.Start;
end;

constructor TMainForm.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  inherited CreateNew(AOwner);

  FFileNameEdit := TFileNameEdit.Create(Self);
  FFileNameEdit.Parent := Self;

  FEncodeButton := TButton.Create(Self);
  FEncodeButton.Parent := Self;
  FEncodeButton.Caption := 'Encode';
  FEncodeButton.OnClick := EncodeButtonClick;

  FDecodeButton := TButton.Create(Self);
  FDecodeButton.Parent := Self;
  FDecodeButton.Caption := 'Decode';
  FDecodeButton.OnClick := DecodeButtonClick;

  FProgressBar := TProgressBar.Create(Self);
  FProgressBar.Parent := Self;
  FProgressBar.Smooth := true;

  OnResize := FormResize;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  FFileNameEdit.Width := Self.Width;

  FProgressBar.Top := Self.Height - FProgressBar.Height;
  FProgressBar.Width := Self.Width;

  FEncodeButton.Top := FFileNameEdit.Top + FFileNameEdit.Height;
  FEncodeButton.Width := Self.Width div 2;
  FEncodeButton.Height := Self.Height - FFileNameEdit.Height - FProgressBar.Height;

  FDecodeButton.Top := FFileNameEdit.Top + FFileNameEdit.Height;
  FDecodeButton.Left := Self.Width div 2;
  FDecodeButton.Width := Self.Width div 2;
  FDecodeButton.Height := Self.Height - FFileNameEdit.Height - FProgressBar.Height;
end;

end.
