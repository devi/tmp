// BLAKE2s

// Ported by Devi Mandiri. Public domain.

var BLOCKBYTES = 64,
    OUTBYTES   = 32,
    KEYBYTES   = 32;

var iv = [
  1779033703, 3144134277, 1013904242, 2773480762,
  1359893119, 2600822924,  528734635, 1541459225
];

var sigma = [
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15],
  [14,10, 4, 8, 9,15,13, 6, 1,12, 0, 2,11, 7, 5, 3],
  [11, 8,12, 0, 5, 2,15,13,10,14, 3, 6, 7, 1, 9, 4],
  [ 7, 9, 3, 1,13,12,11,14, 2, 6, 5,10, 4, 0,15, 8],
  [ 9, 0, 5, 7, 2, 4,10,15,14, 1,11,12, 6, 8, 3,13],
  [ 2,12, 6,10, 0,11, 8, 3, 4,13, 7, 5,15,14, 1, 9],
  [12, 5, 1,15,14,13, 4,10, 0, 7, 6, 3, 9, 2, 8,11],
  [13,11, 7,14,12, 1, 3, 9, 5, 0,15, 4, 8, 6, 2,10],
  [ 6,15,14, 9,11, 3, 0, 8,12, 2,13, 7, 1, 4,10, 5],
  [10, 2, 8, 4, 7, 6, 1, 5,15,11, 9,14, 3,12,13 ,0]
];

var State = function() {
  this.h = iv.slice(0);
  this.t = [0,0];
  this.f = [0,0];
  this.buf = new Array(128);
  this.buflen = 0;
};

function load32(x, i) {
  var u = x[i] & 0xff;
  u |= (x[i+1] & 0xff) <<  8;
  u |= (x[i+2] & 0xff) << 16;
  u |= (x[i+3] & 0xff) << 24;
  return u;
}

function store32(x, pos, u) {
  x[pos]   = u & 0xff; u >>>= 8;
  x[pos+1] = u & 0xff; u >>>= 8;
  x[pos+2] = u & 0xff; u >>>= 8;
  x[pos+3] = u & 0xff;
}

function plus() {
  var x = 0;
  for (var i = 0; i < arguments.length; i++) {
    x = (x + arguments[i])>>>0;
  }
  return x;
}

function rotr(v, n) {
  return ((v >>> n) | (v << (32 - n)))>>>0;
}

var v = [], m = [];

function G(r, i, a, b, c, d) {
  v[a] = plus(v[a], v[b], m[sigma[r][2*i]]);
  v[d] = rotr(v[d] ^ v[a], 16);
  v[c] = plus(v[c], v[d]);
  v[b] = rotr(v[b] ^ v[c], 12);
  v[a] = plus(v[a], v[b], m[sigma[r][2*i+1]]);
  v[d] = rotr(v[d] ^ v[a], 8);
  v[c] = plus(v[c], v[d]);
  v[b] = rotr(v[b] ^ v[c], 7);
}

function compress(state, inc) {
  state.t[0] += inc;
  state.t[1] += ((state.t[0] < inc)?1:0); // just in case

  var i = 0;

  for (i = 16; i--;) {
      m[i] = load32(state.buf, i*4);
  }
  for (i =  8; i--;) {
      v[i] = state.h[i];
  }

  v[ 8] = iv[0];
  v[ 9] = iv[1];
  v[10] = iv[2];
  v[11] = iv[3];
  v[12] = (iv[4] ^ state.t[0])>>>0;
  v[13] = (iv[5] ^ state.t[1])>>>0;
  v[14] = (iv[6] ^ state.f[0])>>>0;
  v[15] = (iv[7] ^ state.f[1])>>>0;

  for (i = 0; i < 10; i++) {
    G(i, 0, 0, 4,  8, 12);
    G(i, 1, 1, 5,  9, 13);
    G(i, 2, 2, 6, 10, 14);
    G(i, 3, 3, 7, 11, 15);
    G(i, 4, 0, 5, 10, 15);
    G(i, 5, 1, 6, 11, 12);
    G(i, 6, 2, 7,  8, 13);
    G(i, 7, 3, 4,  9, 14);
  }

  for (i = 8; i--;) {
    state.h[i] ^= v[i] ^ v[i+8];
  }
}

function update (state, p, length) {
  length = length|0;
  var i = 0, pos = 0;
  while (length > 0) {
    var left = state.buflen, fill = 128 - left;
    if (length > fill) {
        for (i = fill; i--;) {
          state.buf[i+left] = p[i+pos];
        }
        state.buflen += fill;
        compress(state, 64);
        for (i = 64; i--;) {
          state.buf[i] = state.buf[i+64];
        }
        state.buflen -= 64;
        pos += fill;
        length -= fill;
    } else {
      for (i = length; i--;) {
        state.buf[i+left] = p[i+pos];
      }
      state.buflen += length;
      pos += length;
      length -= length;
    }
  }
}

function finish(state) {
  var i = 0;
  if (state.buflen > 64) {
    compress(state, 64);
    state.buflen -= 64;
    for (i = state.buflen; i--;) {
      state.buf[i] = state.buf[i+64];
    }
  }
  state.f[0] = 0xffffffff;
  for (i = state.buflen; i < 128; i++) {
    state.buf[i] = 0;
  }
  compress(state, state.buflen);

  var out = new Array(32);
  for (i = 8; i--;) {
    store32(out, i*4, state.h[i]);
  }
  return out;
}

function decodeString(s) {
  var b = [];
  s = unescape(encodeURIComponent(s));
  for (var i = s.length; i--;) {
    b[i] = s.charCodeAt(i);
  }
  return b;
}

function init(key) {
  var k = (typeof key == 'string') ? decodeString(key) : key;
  var len = (typeof key !== 'undefined') ? key.length : 0;

  if (len > 32) len = 32; // truncate

  var s = new State();
  s.h[0] ^= load32([32, len, 1, 1], 0);

  if (len > 0) {
    var block = [], i;
    for (i = 64; i--;) block[i] = 0;
    for (i = len; i--;) block[i] = k[i];
    update(s, block, 64);
  }
  return s;
}
