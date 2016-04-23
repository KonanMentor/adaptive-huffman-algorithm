unit BitsMap;

interface

uses
  Classes, BitsHelper;

type
  TBitsMap<T> = class
    private
      FTable: array of T;
    public
      constructor Create(BitsCount: Integer);
      function Get(Key: TBits): T;
      function Has(Key: TBits): Boolean;
      procedure Put(Key: TBits; Value: T);
  end;

implementation

constructor TBitsMap<T>.Create(BitsCount: Integer);
begin
  SetLength(FTable, 1 shl BitsCount);
end;

function TBitsMap<T>.Get(Key: TBits): T;
begin
  Result := FTable[BitsToCardinal(Key)];
end;

function TBitsMap<T>.Has(Key: TBits): Boolean;
begin
  Result := FTable[BitsToCardinal(Key)] <> nil;
end;

procedure TBitsMap<T>.Put(Key: TBits; Value: T);
begin
  FTable[BitsToCardinal(Key)] := Value;
end;

end.
