/* crypto_hash - sha256 */

// Written in 2014 by Devi Mandiri. Public domain.
//
// Implementation derived from TweetNaCl version 20140427.
// See for details: http://tweetnacl.cr.yp.to/
//
function load(x, pos) {
  return x[pos+3] | (x[pos+2]<<8) | (x[pos+1]<<16) | (x[pos]<<24);
}

function store(x, pos, u) {
  x[pos+3] = u & 0xff; u >>= 8;
  x[pos+2] = u & 0xff; u >>= 8;
  x[pos+1] = u & 0xff; u >>= 8;
  x[pos]   = u & 0xff;
}

function SHR(x, c) { return x >>> c; }
function ROTR(x, c) { return (x >>> c) | (x << (32 - c)); }
function Ch(x, y, z) { return ((x & y) ^ (~x & z)); }
function Maj(x, y, z) { return ((x & y) ^ (x & z) ^ (y & z)); }
function Sigma0(x) { return (ROTR(x, 2) ^ ROTR(x,13) ^ ROTR(x,22)); }
function Sigma1(x) { return (ROTR(x, 6) ^ ROTR(x,11) ^ ROTR(x,25)); }
function sigma0(x) { return (ROTR(x, 7) ^ ROTR(x,18) ^ SHR( x, 3)); }
function sigma1(x) { return (ROTR(x,17) ^ ROTR(x,19) ^ SHR( x,10)); }
  
var K = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
  0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
  0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
  0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
  0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

function crypto_hashblocks(x, m, n) {
  var z = new Uint32Array(8),
      b = new Uint32Array(8),
      a = new Uint32Array(8),
      w = new Uint32Array(16),
      t, i, j, pos = 0;

  for (i = 8; i--;) z[i] = a[i] = load(x, 4*i);

  while (n >= 64) {
    for (i = 16; i--;) w[i] = load(m, 4*i+pos);

    for (i = 0; i < 64; i++) {
      for (j = 8; j--;) b[j] = a[j];

      t = a[7] + Sigma1(a[4]) + Ch(a[4], a[5], a[6]) + K[i] + w[i%16];
      b[7] = t + Sigma0(a[0]) + Maj(a[0], a[1], a[2]);
      b[3] += t;

      for (j = 8; j--;) a[(j+1)%8] = b[j];

      if (i%16 == 15) {
        for (j = 0; j < 16; j++) {
          w[j] += w[(j+9)%16] + sigma0(w[(j+1)%16]) + sigma1(w[(j+14)%16]);
        }
      }
    }

    for (i = 0; i < 8; i++) {
      a[i] += z[i]; z[i] = a[i];
    }
    pos += 64;
    n -= 64;
  }

  for (i = 0; i < 8; i++) store(x, 4*i, z[i]);

  return n;
}

var iv = [
  0x6a, 0x09, 0xe6, 0x67,
  0xbb, 0x67, 0xae, 0x85,
  0x3c, 0x6e, 0xf3, 0x72,
  0xa5, 0x4f, 0xf5, 0x3a,
  0x51, 0x0e, 0x52, 0x7f,
  0x9b, 0x05, 0x68, 0x8c,
  0x1f, 0x83, 0xd9, 0xab,
  0x5b, 0xe0, 0xcd, 0x19,
];

function crypto_hash(out, m, n) {
  var h = new Uint32Array(iv),
      x = new Uint32Array(128),
      i, b = n << 3, len = n;

  crypto_hashblocks(h, m, n);
  n &= 63;

  for (i = n; i--;) x[i] = m[len-n+i];
  x[n] = 128;

  n = 128-64*(n<56);
  for (i = 1; i < 9; i++) {
    x[n-i] = b; b >>=8;
  }
  crypto_hashblocks(h, x, n);

  for (i = 32; i--;) out[i] = h[i];
}
