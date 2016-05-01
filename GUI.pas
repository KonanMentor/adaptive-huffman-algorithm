uses
  cthreads, cmem, Forms, Interfaces, MainForm;

var
  MainForm: TMainForm;

begin
  Application.Initialize;
  MainForm := TMainForm.CreateNew(Application);
  MainForm.Visible := true;
  Application.Run;
end.
