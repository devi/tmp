// Blake2b

// Ported by Devi Mandiri. Public domain.

var u64 = function (h, l) {
  h = h|0; l = l|0;
  this.hi = h >>> 0;
  this.lo = l >>> 0;
};

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

function add64() {
  var l = 0, h = 0, t;
  for (var i = 0; i < arguments.length; ++i) {
    t = l; l = (t + arguments[i].lo)>>>0;
    h = (h + arguments[i].hi + ((l < t) ? 1 : 0))>>>0;
  }
  return new u64(h, l);
}

function xor64(x, y) {
  return new u64(x.hi ^ y.hi, x.lo ^ y.lo);
}

function rotr64(x, c) {
  c = 64 - c;

  var h0 = 0, l0 = 0, h1 = 0, l1 = 0, c1 = 64 - c;

  // shl
  if (c < 32) {
    h0 = (x.hi << c) | ((x.lo & (((1 << c) - 1)|0) << (32 - c)) >>> (32 - c));
    l0 = x.lo << c;
  } else {
    h0 = x.lo << (c - 32);
  }

  // shr
  if (c1 < 32) {
    h1 = x.hi >>> c1;
    l1 = (x.lo >>> c1) | (x.hi & (((1 << c1) - 1)|0)) << (32 - c1);
  } else {
    l1 = x.hi >>> (c1 - 32);
  }

  return new u64(h0 | h1, l0 | l1);
}

function flatten64(x) {
  return (x.hi * 4294967296 + x.lo);
}

function load64(x, i) {
  var l = x[i]   | (x[i+1]<<8) | (x[i+2]<<16) | (x[i+3]<<24);
  var h = x[i+4] | (x[i+5]<<8) | (x[i+6]<<16) | (x[i+7]<<24);
  return new u64(h, l);
}

function store64(x, i, u) {
  x[i]   = (u.lo & 0xff); u.lo >>>= 8;
  x[i+1] = (u.lo & 0xff); u.lo >>>= 8;
  x[i+2] = (u.lo & 0xff); u.lo >>>= 8;
  x[i+3] = (u.lo & 0xff);
  x[i+4] = (u.hi & 0xff); u.hi >>>= 8;
  x[i+5] = (u.hi & 0xff); u.hi >>>= 8;
  x[i+6] = (u.hi & 0xff); u.hi >>>= 8;
  x[i+7] = (u.hi & 0xff);
}


var BLOCKBYTES = 128,
    OUTBYTES   = 64,
    KEYBYTES   = 64;

var iv = [
  new u64(0x6a09e667, 0xf3bcc908), new u64(0xbb67ae85, 0x84caa73b),
  new u64(0x3c6ef372, 0xfe94f82b), new u64(0xa54ff53a, 0x5f1d36f1),
  new u64(0x510e527f, 0xade682d1), new u64(0x9b05688c, 0x2b3e6c1f),
  new u64(0x1f83d9ab, 0xfb41bd6b), new u64(0x5be0cd19, 0x137e2179)
];

var State = function() {
  this.h = iv.slice(0);
  this.t = [new u64(0,0), new u64(0,0)];
  this.f = [new u64(0,0), new u64(0,0)];
  this.buf = new Array(256);
  for (var i = 256; i--;) this.buf[i] = 0;
  this.buflen = 0;
};

var sigma = [
  [  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15],
  [ 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3],
  [ 11,  8, 12,  0,  5,  2, 15, 13, 10, 14,  3,  6,  7,  1,  9,  4],
  [  7,  9,  3,  1, 13, 12, 11, 14,  2,  6,  5, 10,  4,  0, 15,  8],
  [  9,  0,  5,  7,  2,  4, 10, 15, 14,  1, 11, 12,  6,  8,  3, 13],
  [  2, 12,  6, 10,  0, 11,  8,  3,  4, 13,  7,  5, 15, 14,  1,  9],
  [ 12,  5,  1, 15, 14, 13,  4, 10,  0,  7,  6,  3,  9,  2,  8, 11],
  [ 13, 11,  7, 14, 12,  1,  3,  9,  5,  0, 15,  4,  8,  6,  2, 10],
  [  6, 15, 14,  9, 11,  3,  0,  8, 12,  2, 13,  7,  1,  4, 10,  5],
  [ 10,  2,  8,  4,  7,  6,  1,  5, 15, 11,  9, 14,  3, 12, 13 , 0],
  [  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15],
  [ 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3]
];

function G(v, m, r, i, a, b, c, d) {
  v[a] = add64(v[a], v[b], m[sigma[r][2*i+0]]);
  v[d] = rotr64(xor64(v[d], v[a]), 32);
  v[c] = add64(v[c], v[d]);
  v[b] = rotr64(xor64(v[b], v[c]), 24);
  v[a] = add64(v[a], v[b], m[sigma[r][2*i+1]]);
  v[d] = rotr64(xor64(v[d], v[a]), 16);
  v[c] = add64(v[c], v[d]);
  v[b] = rotr64(xor64(v[b], v[c]), 63);
}

function compress(ctx, block) {
  var m = new Array(16);
  var v = new Array(16);
  var i = 0;

  for (i = 16; i--;) m[i] = load64(block, i*8);

  for (i = 8; i--;) v[i] = ctx.h[i];

  v[ 8] = iv[0];
  v[ 9] = iv[1];
  v[10] = iv[2];
  v[11] = iv[3];

  v[12] = xor64(ctx.t[0], iv[4]);
  v[13] = xor64(ctx.t[1], iv[5]);
  v[14] = xor64(ctx.f[0], iv[6]);
  v[15] = xor64(ctx.f[1], iv[7]);

  for (i = 0; i < 12; i++) {
    G(v, m, i, 0, 0, 4, 8,12);
    G(v, m, i, 1, 1, 5, 9,13);
    G(v, m, i, 2, 2, 6,10,14);
    G(v, m, i, 3, 3, 7,11,15);
    G(v, m, i, 4, 0, 5,10,15);
    G(v, m, i, 5, 1, 6,11,12);
    G(v, m, i, 6, 2, 7, 8,13);
    G(v, m, i, 7, 3, 4, 9,14);
  }

  for (i = 0; i < 8; i++) {
    ctx.h[i] = xor64(ctx.h[i], xor64(v[i], v[i+8]));
  }
}

function increment_counter(ctx, inc) {
  var t = new64(inc);
  ctx.t[0] = add64(ctx.t[0], t);
  if (flatten64(ctx.t[0]) < inc) {
    ctx.t[1] = add64(ctx.t[1], new64(1));
  }
}

function update(ctx, p, plen) {
  var i = 0, offset = 0, left = 0, fill = 0;
  while (plen > 0) {
    left = ctx.buflen;
    fill = 256 - left;

    if (plen > fill) {
      for (i = 0; i < fill; i++) {
        ctx.buf[i+left] = p[i+offset];
      }

      ctx.buflen += fill;

      increment_counter(ctx, 128);
      compress(ctx, ctx.buf);

      for (i = 128; i--;) {
        ctx.buf[i] = ctx.buf[i+128];
      }

      ctx.buflen -= 128;
      offset += fill;
      plen -= fill;
    } else {
      for (i = plen; i--;) {
        ctx.buf[i+left] = p[i+offset];
      }
      ctx.buflen += plen;
      offset += plen;
      plen -= plen;
    }
  }
}

function finish(ctx, out) {
  var i = 0;

  if (ctx.buflen > 128) {
    increment_counter(ctx, 128);
    compress(ctx, ctx.buf);
    ctx.buflen -= 128;
    for (i = ctx.buflen; i--;) {
      ctx.buf[i] = ctx.buf[i+128];
    }
  }

  increment_counter(ctx, ctx.buflen);
  ctx.f[0] = new u64(0xffffffff, 0xffffffff);

  for (i = 256 - ctx.buflen; i--;)
    ctx.buf[i+ctx.buflen] = 0;

  compress(ctx, ctx.buf);

  for (i = 0; i < 8; i++) {
    store64(out, i*8, ctx.h[i]);
  }
}

function init(key, outlen) {
  var ctx = new State();
  var p = new Array(64);
  var klen = 0;
  var dlen = 64;
  var i = 0;

  for (i = 64; i--;) p[i] = 0;

  if (typeof key !== 'undefined') {
    if (key.length > 64) return false;
    klen = key.length;
  }

  if (typeof outlen !== 'undefined') {
    if (outlen > 64) return false;
    dlen = outlen;
  }

  p[0] = dlen; // digest_length
  p[1] = klen; // key_length
  p[2] = 1;    // fanout
  p[3] = 1;    // depth

  ctx.h[0] = xor64(ctx.h[0], load64(p, 0));

  if (klen > 0) {
    var block = new Array(128);
    for (i = 128; i--;) block[i] = 0;
    for (i = klen; i--;) block[i] = key[i];
    update(ctx, block, 128);
  }

  return ctx;
}
