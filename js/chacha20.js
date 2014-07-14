/* chacha20 - 256 bits */

// Written in 2014 by Devi Mandiri. Public domain.
//
// Implementation derived from chacha-ref.c version 20080118
// See for details: http://cr.yp.to/chacha/chacha-20080128.pdf

var Chacha20KeySize   = 32;
var Chacha20NonceSize =  8;

var Chacha20Ctx  = function() {
  this.input = new Array(16);
};

function load32(x, i) {
  return x[i] | (x[i+1]<<8) | (x[i+2]<<16) | (x[i+3]<<24);
}

function store32(x, i, u) {
  x[i]   = u & 0xff; u >>>= 8;
  x[i+1] = u & 0xff; u >>>= 8;
  x[i+2] = u & 0xff; u >>>= 8;
  x[i+3] = u & 0xff;
}

function rotl32(v, c) {
  return (v << c) | (v >>> (32 - c));
}

function chacha20_round(x, a, b, c, d) {
  x[a] += x[b]; x[d] = rotl32(x[d] ^ x[a], 16);
  x[c] += x[d]; x[b] = rotl32(x[b] ^ x[c], 12);
  x[a] += x[b]; x[d] = rotl32(x[d] ^ x[a],  8);
  x[c] += x[d]; x[b] = rotl32(x[b] ^ x[c],  7);
}

function chacha20_init(key, nonce) {
  var x = new Chacha20Ctx();

  x.input[0] = 1634760805;
  x.input[1] =  857760878;
  x.input[2] = 2036477234;
  x.input[3] = 1797285236;
  x.input[12] = 0;
  x.input[13] = 0;
  x.input[14] = load32(nonce, 0);
  x.input[15] = load32(nonce, 4);

  for (var i = 0; i < 8; i++) {
    x.input[i+4] = load32(key, i*4);
  }
  return x;
}

function chacha20_keystream(ctx, dst, src, len) {
  var x = new Array(16);
  var buf = new Array(64);
  var i = 0, dpos = 0, spos = 0;

  while (len > 0 ) {
    for (i = 16; i--;) x[i] = ctx.input[i];
    for (i = 20; i > 0; i -= 2) {
      chacha20_round(x, 0, 4, 8,12);
      chacha20_round(x, 1, 5, 9,13);
      chacha20_round(x, 2, 6,10,14);
      chacha20_round(x, 3, 7,11,15);
      chacha20_round(x, 0, 5,10,15);
      chacha20_round(x, 1, 6,11,12);
      chacha20_round(x, 2, 7, 8,13);
      chacha20_round(x, 3, 4, 9,14);
    }
    for (i = 16; i--;) x[i] += ctx.input[i];
    for (i = 16; i--;) store32(buf, 4*i, x[i]);

    ctx.input[12] += 1;
    if (!ctx.input[12]) {
      ctx.input[13] += 1;
    }
    if (len <= 64) {
      for (i = len; i--;) {
        dst[i+dpos] = src[i+spos] ^ buf[i];
      }
      return;
    }
    for (i = 64; i--;) {
      dst[i+dpos] = src[i+spos] ^ buf[i];
    }
    len -= 64;
    spos += 64;
    dpos += 64;
  }
}

//--------------------------- test -----------------------------//
function fromHex(h) {
  h.replace(' ', '');
  var out = [], len = h.length, w = '';
  for (var i = 0; i < len; i += 2) {
    w = h[i];
    if (((i+1) >= len) || typeof h[i+1] === 'undefined') {
        w += '0';
    } else {
        w += h[i+1];
    }
    out.push(parseInt(w, 16));
  }
  return out;
}

function bytesEqual(a, b) {
  var dif = 0;
  if (a.length !== b.length) return 0;
  for (var i = 0; i < a.length; i++) {
    dif |= (a[i] ^ b[i]);
  }
  dif = (dif - 1) >>> 31;
  return (dif & 1);
}

// testVectors from http://tools.ietf.org/html/draft-agl-tls-chacha20poly1305-04#page-11
var testVectors = [
  {
    key:       fromHex('0000000000000000000000000000000000000000000000000000000000000000'),
    nonce:     fromHex('0000000000000000'),
    keystream: fromHex(
                '76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc' + 
                '8b770dc7da41597c5157488d7724e03fb8d84a376a43b8f41518a11c' + 
                'c387b669b2ee6586'
              ),
  },
  {
    key:       fromHex('0000000000000000000000000000000000000000000000000000000000000001'),
    nonce:     fromHex('0000000000000000'),
    keystream: fromHex(
                '4540f05a9f1fb296d7736e7b208e3c96eb4fe1834688d2604f450952' + 
                'ed432d41bbe2a0b6ea7566d2a5d1e7e20d42af2c53d792b1c43fea81' +
                '7e9ad275ae546963'
              ),
  },
  {
    key:       fromHex('0000000000000000000000000000000000000000000000000000000000000000'),
    nonce:     fromHex('0000000000000001'),
    keystream: fromHex(
                'de9cba7bf3d69ef5e786dc63973f653a0b49e015adbff7134fcb7df1' +
                '37821031e85a050278a7084527214f73efc7fa5b5277062eb7a0433e' +
                '445f41e3'
              ),
  },
  {
    key:       fromHex('0000000000000000000000000000000000000000000000000000000000000000'),
    nonce:     fromHex('0100000000000000'),
    keystream: fromHex(
                'ef3fdfd6c61578fbf5cf35bd3dd33b8009631634d21e42ac33960bd1' +
                '38e50d32111e4caf237ee53ca8ad6426194a88545ddc497a0b466e7d' +
                '6bbdb0041b2f586b'
              ),
  },
  {
    key:       fromHex('000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f'),
    nonce:     fromHex('0001020304050607'),
    keystream: fromHex(
                'f798a189f195e66982105ffb640bb7757f579da31602fc93ec01ac56' +
                'f85ac3c134a4547b733b46413042c9440049176905d3be59ea1c53f1' +
                '5916155c2be8241a38008b9a26bc35941e2444177c8ade6689de9526' +
                '4986d95889fb60e84629c9bd9a5acb1cc118be563eb9b3a4a472f82e' +
                '09a7e778492b562ef7130e88dfe031c79db9d4f7c7a899151b9a4750' +
                '32b63fc385245fe054e3dd5a97a5f576fe064025d3ce042c566ab2c5' +
                '07b138db853e3d6959660996546cc9c4a6eafdc777c040d70eaf46f7' +
                '6dad3979e5c5360c3317166a1c894c94a371876a94df7628fe4eaaf2' +
                'ccb27d5aaae0ad7ad0f9d4b6ad3b54098746d4524d38407a6deb3ab7' +
                '8fab78c9'
              ),
  },
];

var vect, ctx, klen, out;
for (var i = 0; i < testVectors.length; i++) {
  vect = testVectors[i];
  klen = vect.keystream.length;
  out = new Array(klen);

  ctx = chacha20_init(vect.key, vect.nonce);

  chacha20_keystream(ctx, out, out, klen);

  console.log(bytesEqual(vect.keystream, out));
}
