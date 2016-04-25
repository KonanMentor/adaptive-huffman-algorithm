unit MainForm;

interface

uses
  Forms, Classes, EditBtn, StdCtrls, Encoder, Decoder, Stopwatch, Dialogs, SysUtils;

type
  TMainForm = class(TForm)
    public
      constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    private
      FFileNameEdit: TFileNameEdit;
      FEncodeButton, FDecodeButton: TButton;
      procedure FormResize(Sender: TObject);
      procedure EncodeButtonClick(Sender: TObject);
      procedure DecodeButtonClick(Sender: TObject);
  end;

implementation

procedure TMainForm.EncodeButtonClick(Sender: TObject);
const
  EncodedFileExtension = '.ah';
var
  SourceStream, DestinationStream: TFileStream;
  FileName: String;
  Stopwatch: TStopwatch;
begin
  FileName := FFileNameEdit.FileName;
  try
    SourceStream := TFileStream.Create(FileName, fmOpenRead);
  except
    on E: EFOpenError do
      begin
        ShowMessage('Unable to read file');
        Exit;
      end;
  end;

  try
    DestinationStream := TFileStream.Create(FileName + EncodedFileExtension, fmOpenWrite or fmCreate);
  except
    on E: EFOpenError do
      begin
        ShowMessage('Unable to create/write to ouput file');
        Exit;
      end;
  end;

  try
    Stopwatch := TStopwatch.StartNew;
    Encode(SourceStream, DestinationStream);
    Stopwatch.Stop;
    ShowMessage(Format('Compression ratio: %.2f' + sLineBreak + 'Elapsed time: %.3fs', [DestinationStream.Size / SourceStream.Size, Stopwatch.GetElapsedMilliseconds / 1000]));
  finally
    SourceStream.Free;
    DestinationStream.Free;
  end;
end;

procedure TMainForm.DecodeButtonClick(Sender: TObject);
const
  DecodedFileExtension = '.out';
var
  SourceStream, DestinationStream: TFileStream;
  FileName: String;
  Stopwatch: TStopwatch;
begin
  FileName := FFileNameEdit.FileName;
  try
    SourceStream := TFileStream.Create(FileName, fmOpenRead);
  except
    on E: EFOpenError do
      begin
        ShowMessage('Unable to read file');
        Exit;
      end;
  end;

  try
    DestinationStream := TFileStream.Create(FileName + DecodedFileExtension, fmOpenWrite or fmCreate);
  except
    on E: EFOpenError do
      begin
        ShowMessage('Unable to create/write to ouput file');
        Exit;
      end;
  end;

  try
    try
      Stopwatch := TStopwatch.StartNew;
      Decode(SourceStream, DestinationStream);
      Stopwatch.Stop;
      ShowMessage(Format('Elapsed time: %.3fs', [Stopwatch.GetElapsedMilliseconds / 1000]));
    except
      ShowMessage('Unable to decode file');
    end;
  finally
    SourceStream.Free;
    DestinationStream.Free;
  end;
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

  OnResize := FormResize;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  FFileNameEdit.Width := Self.Width;

  FEncodeButton.Top := FFileNameEdit.Top + FFileNameEdit.Height;
  FEncodeButton.Width := Self.Width div 2;
  FEncodeButton.Height := Self.Height - FFileNameEdit.Height;

  FDecodeButton.Top := FFileNameEdit.Top + FFileNameEdit.Height;
  FDecodeButton.Left := Self.Width div 2;
  FDecodeButton.Width := Self.Width div 2;
  FDecodeButton.Height := Self.Height - FFileNameEdit.Height;
end;

end.
