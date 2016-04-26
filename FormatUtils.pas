unit FormatUtils;

interface

function FormatBytes(Bytes: Integer): String;

implementation

uses
  SysUtils;

function FormatBytes(Bytes: Integer): String;
const
  Factor = 1024;
  BytesInKilobyte = Factor;
  BytesInMegabyte = Factor * BytesInKilobyte;
  BytesInGigabyte = Factor * BytesInMegabyte;
begin
  if Bytes < BytesInKilobyte then
    Result := Format('%d B', [Bytes])
  else if Bytes < BytesInMegabyte then
    Result := Format('%.1f KB', [Bytes / BytesInKilobyte])
  else if Bytes < BytesInGigabyte then
    Result := Format('%.1f MB', [Bytes / BytesInMegabyte])
  else
    Result := Format('%.1f GB', [Bytes / BytesInGigabyte])
end;

end.
