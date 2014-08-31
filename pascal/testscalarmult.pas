program testscalarmult;

{$mode objfpc}{$H+}

uses
  heaptrc, sodium;

const
  hexTbl: array[0..15] of char='0123456789abcdef';

function BytesToHex(const buf: PByte; bufLen: PtrUInt): string;
var
  i: PtrUInt;
  p: PChar;
begin
  SetLength(Result, bufLen * 2);
  p := Pointer(Result);
  for i := 0 to bufLen-1 do
  begin
    p[0] := hexTbl[(buf[i] shr 4) and 15];
    p[1] := hexTbl[buf[i] and 15];
    Inc(p, 2);
  end;
end;

procedure zap(b: Pointer; len: SizeInt);
begin
  FillChar(b^, len, 0);
end;

// https://code.google.com/p/go/source/browse/curve25519/curve25519_test.go?repo=crypto
const
  expectedHex = '89161fde887b2b53de549af483940106ecc114d6982daa98256de23bdf77661a';

var
  input, output,
  tmp: array[0..31] of byte;
  i: integer;

begin
  zap(@input, SizeOf(input));
  zap(@output, SizeOf(output));
  zap(@tmp, SizeOf(tmp));
  
  input[0] := 1;

  for i := 0 to 199 do
  begin
    crypto_scalarmult_base(@output, @input);
    tmp := output;
    output := input;
    input := tmp;
  end;

  WriteLn(expectedHex);
  WriteLn(BytesToHex(@input, 32));
end.
