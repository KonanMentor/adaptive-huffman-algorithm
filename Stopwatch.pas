unit Stopwatch;

interface

type
  TStopwatch = class
    private
      FStart, FStop: TDateTime;
    public
      procedure Start;
      procedure Stop;
      function GetElapsedMilliseconds: Int64;
      class function StartNew: TStopwatch;
  end;

implementation

uses
  SysUtils, DateUtils;

procedure TStopwatch.Start;
begin
  FStart := Now;
end;

procedure TStopwatch.Stop;
begin
  FStop := Now;
end;

function TStopwatch.GetElapsedMilliseconds: Int64;
begin
  Result := MilliSecondsBetween(FStart, FStop);
end;

class function TStopwatch.StartNew: TStopwatch;
begin
  Result := TStopwatch.Create;
  Result.Start;
end;

end.
