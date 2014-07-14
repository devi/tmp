// keccak
//
// Implementation derived from https://github.com/floodyberry/scrypt-jane
//
// Ported by Devi Mandiri. Public domain
//
var u64 = function (h, l) {
  h = h|0; l = l|0;
  this.hi = h >>> 0;
  this.lo = l >>> 0;
}

function xor64() {
  var a = arguments, h = a[0].hi, l = a[0].lo;
  for (var i = 1, len = a.length; i < len; i++) {
    h = (h ^ a[i].hi) >>> 0;
    l = (l ^ a[i].lo) >>> 0;
  }
  return new u64(h, l);
}

function rotl64(x, c) {
  var h0 = 0, l0 = 0, h1 = 0, l1 = 0, c1 = 64 - c;

  // shift left
  if (c < 32) {
    h0 = (x.hi << c) | ((x.lo & (((1 << c) - 1)|0) << (32 - c)) >>> (32 - c));
    l0 = x.lo << c;
  } else {
    h0 = x.lo << (c - 32);
  }

  // shift right
  if (c1 < 32) {
    h1 = x.hi >>> c1;
    l1 = (x.lo >>> c1) | (x.hi & (((1 << c1) - 1)|0)) << (32 - c1);
  } else {
    l1 = x.hi >>> (c1 - 32);
  }

  return new u64(h0 | h1, l0 | l1);
}

function xnd64(x, y, z) {
  return new u64(x.hi ^ ((~y.hi) & z.hi), x.lo ^ ((~y.lo) & z.lo));
}

function load64(x, i) {
  var l = x[i]   | (x[i+1]<<8) | (x[i+2]<<16) | (x[i+3]<<24);
  var h = x[i+4] | (x[i+5]<<8) | (x[i+6]<<16) | (x[i+7]<<24);
  return new u64(h, l);
}

var DigestSize = 64; // default keccak-512
var Keccak_F = 1600;
var Keccak_C = 0;
var Keccak_R = 0;
var BlockSize = 0;

var Context = function() {
  var i = 25;

  this.state = new Array(i);
  this.leftover = 0;
  this.buffer = new Uint8Array(BlockSize);

  for (;i--;) this.state[i] = new u64(0, 0);
  for (i = BlockSize; i--;) this.buffer[i] = 0;
};

var keccak_round_constants = [
  new u64(0x00000000, 0x00000001), new u64(0x00000000, 0x00008082),
  new u64(0x80000000, 0x0000808a), new u64(0x80000000, 0x80008000),
  new u64(0x00000000, 0x0000808b), new u64(0x00000000, 0x80000001),
  new u64(0x80000000, 0x80008081), new u64(0x80000000, 0x00008009),
  new u64(0x00000000, 0x0000008a), new u64(0x00000000, 0x00000088),
  new u64(0x00000000, 0x80008009), new u64(0x00000000, 0x8000000a),
  new u64(0x00000000, 0x8000808b), new u64(0x80000000, 0x0000008b),
  new u64(0x80000000, 0x00008089), new u64(0x80000000, 0x00008003),
  new u64(0x80000000, 0x00008002), new u64(0x80000000, 0x00000080),
  new u64(0x00000000, 0x0000800a), new u64(0x80000000, 0x8000000a),
  new u64(0x80000000, 0x80008081), new u64(0x80000000, 0x00008080),
  new u64(0x00000000, 0x80000001), new u64(0x80000000, 0x80008008)
];

function blocks(ctx, input, pos) {
  var i = 0,
    s = ctx.state,
    t = new Array(5),
    u = new Array(5),
    v, w;

  for (i = 0; i < BlockSize / 8; i++) { // 256=8 512=16
    s[i] = xor64(s[i], load64(input, i*8+pos));
  }

  for (i = 0; i < 24; i++) {
    t[0] = xor64(s[0], s[5], s[10], s[15], s[20]);
    t[1] = xor64(s[1], s[6], s[11], s[16], s[21]);
    t[2] = xor64(s[2], s[7], s[12], s[17], s[22]);
    t[3] = xor64(s[3], s[8], s[13], s[18], s[23]);
    t[4] = xor64(s[4], s[9], s[14], s[19], s[24]);

    u[0] = xor64(t[4], rotl64(t[1], 1));
    u[1] = xor64(t[0], rotl64(t[2], 1));
    u[2] = xor64(t[1], rotl64(t[3], 1));
    u[3] = xor64(t[2], rotl64(t[4], 1));
    u[4] = xor64(t[3], rotl64(t[0], 1));

    s[0] = xor64(s[0], u[0]); s[5] = xor64(s[5], u[0]); s[10] = xor64(s[10], u[0]); s[15] = xor64(s[15], u[0]); s[20] = xor64(s[20], u[0]);
    s[1] = xor64(s[1], u[1]); s[6] = xor64(s[6], u[1]); s[11] = xor64(s[11], u[1]); s[16] = xor64(s[16], u[1]); s[21] = xor64(s[21], u[1]);
    s[2] = xor64(s[2], u[2]); s[7] = xor64(s[7], u[2]); s[12] = xor64(s[12], u[2]); s[17] = xor64(s[17], u[2]); s[22] = xor64(s[22], u[2]);
    s[3] = xor64(s[3], u[3]); s[8] = xor64(s[8], u[3]); s[13] = xor64(s[13], u[3]); s[18] = xor64(s[18], u[3]); s[23] = xor64(s[23], u[3]);
    s[4] = xor64(s[4], u[4]); s[9] = xor64(s[9], u[4]); s[14] = xor64(s[14], u[4]); s[19] = xor64(s[19], u[4]); s[24] = xor64(s[24], u[4]);

    v = s[1];
    s[ 1] = rotl64(s[ 6], 44);
    s[ 6] = rotl64(s[ 9], 20);
    s[ 9] = rotl64(s[22], 61);
    s[22] = rotl64(s[14], 39);
    s[14] = rotl64(s[20], 18);
    s[20] = rotl64(s[ 2], 62);
    s[ 2] = rotl64(s[12], 43);
    s[12] = rotl64(s[13], 25);
    s[13] = rotl64(s[19],  8);
    s[19] = rotl64(s[23], 56);
    s[23] = rotl64(s[15], 41);
    s[15] = rotl64(s[ 4], 27);
    s[ 4] = rotl64(s[24], 14);
    s[24] = rotl64(s[21],  2);
    s[21] = rotl64(s[ 8], 55);
    s[ 8] = rotl64(s[16], 45);
    s[16] = rotl64(s[ 5], 36);
    s[ 5] = rotl64(s[ 3], 28);
    s[ 3] = rotl64(s[18], 21);
    s[18] = rotl64(s[17], 15);
    s[17] = rotl64(s[11], 10);
    s[11] = rotl64(s[ 7],  6);
    s[ 7] = rotl64(s[10],  3);
    s[10] = rotl64(v    ,  1);

    v = s[0];
    w = s[1];
    s[0] = xnd64(s[0], w   , s[2]);
    s[1] = xnd64(s[1], s[2], s[3]);
    s[2] = xnd64(s[2], s[3], s[4]);
    s[3] = xnd64(s[3], s[4], v);
    s[4] = xnd64(s[4], v   , w);

    v = s[5];
    w = s[6];
    s[5] = xnd64(s[5], w   , s[7]);
    s[6] = xnd64(s[6], s[7], s[8]);
    s[7] = xnd64(s[7], s[8], s[9]);
    s[8] = xnd64(s[8], s[9], v);
    s[9] = xnd64(s[9], v   , w);

    v = s[10];
    w = s[11];
    s[10] = xnd64(s[10], w    , s[12]);
    s[11] = xnd64(s[11], s[12], s[13]);
    s[12] = xnd64(s[12], s[13], s[14]);
    s[13] = xnd64(s[13], s[14], v);
    s[14] = xnd64(s[14], v    , w);

    v = s[15];
    w = s[16];
    s[15] = xnd64(s[15], w    , s[17]);
    s[16] = xnd64(s[16], s[17], s[18]);
    s[17] = xnd64(s[17], s[18], s[19]);
    s[18] = xnd64(s[18], s[19], v);
    s[19] = xnd64(s[19], v    , w);

    v = s[20];
    w = s[21];
    s[20] = xnd64(s[20], w    , s[22]);
    s[21] = xnd64(s[21], s[22], s[23]);
    s[22] = xnd64(s[22], s[23], s[24]);
    s[23] = xnd64(s[23], s[24], v);
    s[24] = xnd64(s[24], v    , w);

    s[0] = xor64(s[0], keccak_round_constants[i]);
  }

  ctx.state = s;
}

function init() {
  if (typeof arguments[0] !== 'undefined') {
    switch (arguments[0]) {
      case 0:
        DigestSize = 28; // keccak-224
        break;
      case 1:
        DigestSize = 32; // keccak-256
        break;
      case 2:
        DigestSize = 48; // keccak-384
        break;
      default:
        DigestSize = 64; // keccak-512
    }
  }

  Keccak_C = DigestSize * 8 * 2;
  Keccak_R = Keccak_F - Keccak_C;
  BlockSize = Keccak_R / 8;

  return new Context();
}

function update(ctx, input, inlen) {
  var pos = 0;

  if (ctx.leftover) {
    var want = BlockSize - ctx.leftover;
    want = (want < inlen) ? want : inlen;
    for (var i = want; i--;)
      ctx.buffer[i+ctx.leftover] = input[i+pos];
    ctx.leftover += want;
    if (ctx.leftover < BlockSize)
      return;
    pos += want;
    inlen -= want;
    blocks(ctx, ctx.buffer, 0);
  }

  while (inlen >= BlockSize) {
    blocks(ctx, input, pos);
    pos += BlockSize;
    inlen -= BlockSize;
  }

  ctx.leftover = inlen;
  if (ctx.leftover) {
    for (var i = ctx.leftover; i--;) {
      ctx.buffer[i] = input[i+pos];
    }
  }
}

function finish(ctx, out) {
  var i = 0, u = 0;

  ctx.buffer[ctx.leftover] = 0x01;
  for (i = BlockSize - (ctx.leftover + 1); i--;) {
    ctx.buffer[i+ctx.leftover+1] = 0;
  }
  ctx.buffer[BlockSize-1] |= 0x80;
  blocks(ctx, ctx.buffer, 0);

  
  for (i = 0; i < DigestSize; i += 8) {
    u = ctx.state[i/8];

    out[i]   = (u.lo & 0xff); u.lo >>>= 8;
    out[i+1] = (u.lo & 0xff); u.lo >>>= 8;
    out[i+2] = (u.lo & 0xff); u.lo >>>= 8;
    out[i+3] = (u.lo & 0xff);

    if (i !== 24 || DigestSize !== 28) {
      out[i+4] = (u.hi & 0xff); u.hi >>>= 8;
      out[i+5] = (u.hi & 0xff); u.hi >>>= 8;
      out[i+6] = (u.hi & 0xff); u.hi >>>= 8;
      out[i+7] = (u.hi & 0xff);
    }
  }
}
