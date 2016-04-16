unit BitsHelper;

interface

uses
  Classes;

function CardinalToBits(Value: Cardinal): TBits;
function BitsToCardinal(Bits: TBits): Cardinal;
function BitsToString(Bits: TBits): String;

implementation

function CardinalToBits(Value: Cardinal): TBits;
var
  i: Integer;
begin
  Result := TBits.Create(SizeOf(Value) * 8);
  i := 0;
  while Value <> 0 do
  begin
    if (Value and 1) <> 0 then
      Result.SetOn(i);
    i := i + 1;
    Value := Value shr 1;
  end;
end;

function BitsToCardinal(Bits: TBits): Cardinal;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Bits.Size - 1 do
    if Bits.Get(i) then
      Result := Result xor (1 shl i);
end;

function BitsToString(Bits: TBits): String;
var
  i: Integer;
begin
  Result := '';
  for i := Bits.Size - 1 downto 0 do
    if Bits.Get(i) then
      Result := Result + '1'
    else
      Result := Result + '0';
end;
end.
