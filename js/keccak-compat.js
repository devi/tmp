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

var keccak_rounds = [
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

var keccak_rotate=[1,3,6,10,15,21,28,36,45,55,2,14,27,41,56,8,25,43,62,18,39,61,20,44];

var keccak_pi=[10,7,11,17,18,3,5,16,8,21,24,4,15,23,19,13,12,2,20,14,22,9,6,1];

function blocks(state, input, pos) {
  var i, x, y, t, bc = new Array(5);

  for (i = 0; i < BlockSize / 8; i++) {
    state[i] = xor64(state[i], load64(input, i*8+pos));
  }

  for (i = 0; i < 24; ++i) {
    for (x = 5; x--;) {
      bc[x] = xor64(state[x], state[5+x], state[10+x], state[15+x], state[20+x]);
    }

    for (x = 0; x < 5; ++x) {
      t = xor64(bc[(x+4)%5], rotl64(bc[(x+1)%5], 1));
      for (y = 0; y < 25; y += 5) {
        state[y+x] = xor64(state[y+x], t);
      }
    }

    t = state[1];
    for (x = 0; x < 24; ++x) {
      bc[0] = state[keccak_pi[x]];
      state[keccak_pi[x]] = rotl64(t, keccak_rotate[x]);
      t = bc[0];
    }

    for (y = 0; y < 25; y += 5) {
      for (x = 5; x--;) {
        bc[x] = state[y+x];
      }
      for (x = 5; x--;) {
        state[y+x] = xnd64(bc[x], bc[(x+1)%5], bc[(x+2)%5]);
      }
    }

    state[0] = xor64(state[0], keccak_rounds[i]);
  }
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
    blocks(ctx.state, ctx.buffer, 0);
  }

  while (inlen >= BlockSize) {
    blocks(ctx.state, input, pos);
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
  blocks(ctx.state, ctx.buffer, 0);

  
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
