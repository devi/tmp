// helper for dealing with uint64
var u64 = function (h, l) {
  h = h|0; l = l|0;
  this.hi = h >>> 0;
  this.lo = l >>> 0;
}

function new64(num) {
  var hi = 0, lo = num >>> 0;
  if ((+(Math.abs(num))) >= 1) {
    if (num > 0) {
      hi = ((Math.min((+(Math.floor(num/4294967296))), 4294967295))|0) >>> 0;
    } else {
      hi = (~~((+(Math.ceil((num - +(((~~(num)))>>>0))/4294967296))))) >>> 0;
    }
  }
  return new u64(hi, lo);
}

function shr64(x, c) {
  var h = 0, l = 0;
  if (c < 32) {
    l = (x.lo >>> c) | (x.hi & (((1 << c) - 1)|0)) << (32 - c);
    h = x.hi >>> c;
  } else {
    l = x.hi >>> (c - 32);
  }
  return new u64(h, l);
}

function shl64(x, c) {
  var h = 0, l = 0;
  if (c < 32) {
    h = (x.hi << c) | ((x.lo & (((1 << c) - 1)|0) << (32 - c)) >>> (32 - c));
    l = x.lo << c;
  } else {
    h = x.lo << (c - 32);
  }
  return new u64(h, l);
}

function rotl64(x, c) {
  var t1 = shl64(x, c);
  var t2 = shr64(x, 64 - c);
  return new u64(t1.hi | t2.hi, t1.lo | t2.lo);
}

function rotr64(x, c) {
  return rotl64(x, 64 - c);
}

function mul(a, b, make64) {
  make64 = make64|0;
  var ah, al, bh, bl, c, d, e, x, y, z; // TODO: reduce variable

  ah = a >>> 16; al = a & 0xffff;
  bh = b >>> 16; bl = b & 0xffff;
  c = al*bl; d = ah*bl; e = al*bh;

  var l = (c + ((d + e) << 16) >>> 0)|0;

  if (!make64) return l;

  x = d + (c >>> 16); 
  y = (e + (x & 0xffff)) >>> 16;
  z = x >>> 16;

  return new u64((ah*bh + y + z), l);
}

function mul64(x, y) {
  var z = mul(x.lo, y.lo, 1);
  z.hi += ((mul(x.hi, y.lo) + mul(y.hi, x.lo))|0);
  return z;
}

function add64() {
  var a = arguments, t,
      l = a[0].lo, h = a[0].hi;
  for (var i = 1; i < a.length; i++) {
    t = l; l = (t + a[i].lo)>>>0;
    h = (h + a[i].hi + ((l < t) ? 1 : 0))>>>0;
  }
  return new u64(h, l);
}

function sub64(x, y) {
  return new u64(x.hi - y.hi - ((x.lo < y.lo) ? 1 : 0), x.lo - y.lo);
}

function flatten64(x) {
  // caveat: it will loose precision with big numbers
  return (x.hi * 4294967296 + x.lo);
}

function xor64() {
  var a = arguments, h = a[0].hi, l = a[0].lo;
  for (var i = 1; i < a.length; i++) {
    h = (h ^ a[i].hi) >>> 0;
    l = (l ^ a[i].lo) >>> 0;
  }
  return new u64(h, l);
}
