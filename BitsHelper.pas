unit BitsHelper;

interface

uses
  Classes;

function CardinalToBits(Value: Cardinal; BitsCount: Integer = 32): TBits;
function BitsToCardinal(Bits: TBits): Cardinal;
function BitsToString(Bits: TBits): String;
function ConcatBits(First, Second: TBits): TBits;

implementation

function CardinalToBits(Value: Cardinal; BitsCount: Integer = 32): TBits;
var
  i: Integer;
begin
  Result := TBits.Create(BitsCount);
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

function ConcatBits(First, Second: TBits): TBits;
var
  i: Integer;
begin
  Result := TBits.Create(First.Size + Second.Size);
  for i := 0 to Second.Size - 1 do
    Result.Bits[i] := Second.Bits[i];
  for i := 0 to First.Size - 1 do
    Result.Bits[i + Second.Size] := First.Bits[i];
end;

end.
