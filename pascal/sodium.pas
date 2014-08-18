unit sodium;

{$mode objfpc}{$H+}
{$packrecords C}

interface

uses
  ctypes;

{
  Free Pascal wrapper for libsodium - https://github.com/jedisct1/libsodium

  Automatically converted by H2Pas 1.0.0 from sodium.h
  The following command line parameters were used:
    -d
    -C
    -p
}

type
  Psize_t = ^csize_t;
  Ppcchar = ^pcchar;

const
  SODIUMLIB =
    {$IFDEF WINDOWS}
      'sodium.dll'
    {$ELSE}
      {$IFDEF DARWIN}
        'libsodium.dylib'
      {$ELSE}
        'libsodium.so'
      {$ENDIF}
    {$ENDIF}
    ;

// move to initialization
//function sodium_init:cint;cdecl;external SODIUMLIB;

function sodium_version_string:pcchar;cdecl;external SODIUMLIB;
function sodium_library_version_major:cint;cdecl;external SODIUMLIB;
function sodium_library_version_minor:cint;cdecl;external SODIUMLIB;

// utils
procedure sodium_memzero(pnt:pointer; len:csize_t);cdecl;external SODIUMLIB;
{ WARNING: sodium_memcmp() must be used to verify if two secret keys
 * are equal, in constant time.
 * It returns 0 if the keys are equal, and -1 if they differ.
 * This function is not designed for lexicographical comparisons.
  }
function sodium_memcmp(b1_:pointer; b2_:pointer; len:csize_t):cint;cdecl;external SODIUMLIB;
function sodium_bin2hex(hex:pcchar; hex_maxlen:csize_t; bin:pcuchar; bin_len:csize_t):pcchar;cdecl;external SODIUMLIB;
function sodium_hex2bin(bin:pcuchar; bin_maxlen:csize_t; hex:pcchar; hex_len:csize_t; ignore:pcchar;
           bin_len:Psize_t; hex_end:Ppcchar):cint;cdecl;external SODIUMLIB;
function sodium_mlock(addr:pointer; len:csize_t):cint;cdecl;external SODIUMLIB;
function sodium_munlock(addr:pointer; len:csize_t):cint;cdecl;external SODIUMLIB;

// runtime
function sodium_runtime_get_cpu_features:cint;cdecl;external SODIUMLIB;
function sodium_runtime_has_neon:cint;cdecl;external SODIUMLIB;
function sodium_runtime_has_sse2:cint;cdecl;external SODIUMLIB;
function sodium_runtime_has_sse3:cint;cdecl;external SODIUMLIB;


// randombytes
type
  Prandombytes_implementation = ^randombytes_implementation;
  randombytes_implementation = record
    implementation_name : function :pcchar;cdecl;
    random : function :cuint32;cdecl;
    stir : procedure ;cdecl;
    uniform : function (upper_bound:cuint32):cuint32;cdecl;
    buf : procedure (buf:pointer; size:csize_t);cdecl;
    close : function :cint;cdecl;
  end;

function randombytes_set_implementation(impl:Prandombytes_implementation):cint;cdecl;external;
procedure randombytes(buf:pcuchar; buf_len:culonglong);cdecl;external;
function randombytes_implementation_name:pcchar;cdecl;external;
function randombytes_random:cuint32;cdecl;external;
procedure randombytes_stir;cdecl;external;
function randombytes_uniform(upper_bound:cuint32):cuint32;cdecl;external;
procedure randombytes_buf(buf:pointer; size:csize_t);cdecl;external;
function randombytes_close:cint;cdecl;external;

// randombytes_sysrandom
function randombytes_sysrandom_implementation_name:pcchar;cdecl;external;
function randombytes_sysrandom:cuint32;cdecl;external;
procedure randombytes_sysrandom_stir;cdecl;external;
function randombytes_sysrandom_uniform(upper_bound:cuint32):cuint32;cdecl;external;
procedure randombytes_sysrandom_buf(buf:pointer; size:csize_t);cdecl;external;
function randombytes_sysrandom_close:cint;cdecl;external;

// randombytes_salsa20
function randombytes_salsa20_implementation_name:pcchar;cdecl;external;
function randombytes_salsa20_random:cuint32;cdecl;external;
procedure randombytes_salsa20_random_stir;cdecl;external;
function randombytes_salsa20_random_uniform(upper_bound:cuint32):cuint32;cdecl;external;
procedure randombytes_salsa20_random_buf(buf:pointer; size:csize_t);cdecl;external;
function randombytes_salsa20_random_close:cint;cdecl;external;

// verify
function crypto_verify_16(x:pcuchar; y:pcuchar):cint;cdecl;external;
function crypto_verify_32(x:pcuchar; y:pcuchar):cint;cdecl;external;
function crypto_verify_64(x:pcuchar; y:pcuchar):cint;cdecl;external;

// salsa208
const
  crypto_core_salsa208_OUTPUTBYTES = 64;
  crypto_core_salsa208_INPUTBYTES = 16;
  crypto_core_salsa208_KEYBYTES = 32;
  crypto_core_salsa208_CONSTBYTES = 16;

function crypto_core_salsa208(outbuf:pcuchar; inbuf:pcuchar; k:pcuchar; c:pcuchar):cint;cdecl;external;


// salsa20
const
  crypto_core_salsa20_OUTPUTBYTES = 64;
  crypto_core_salsa20_INPUTBYTES = 16;
  crypto_core_salsa20_KEYBYTES = 32;
  crypto_core_salsa20_CONSTBYTES = 16;

function crypto_core_salsa20(outbuf:pcuchar; inbuf:pcuchar; k:pcuchar; c:pcuchar):cint;cdecl;external;


// salsa2012
const
  crypto_core_salsa2012_OUTPUTBYTES = 64;
  crypto_core_salsa2012_INPUTBYTES = 16;
  crypto_core_salsa2012_KEYBYTES = 32;
  crypto_core_salsa2012_CONSTBYTES = 16;

function crypto_core_salsa2012(outbuf:pcuchar; inbuf:pcuchar; k:pcuchar; c:pcuchar):cint;cdecl;external;


// hsalsa20
const
  crypto_core_hsalsa20_OUTPUTBYTES = 32;
  crypto_core_hsalsa20_INPUTBYTES = 16;
  crypto_core_hsalsa20_KEYBYTES = 32;
  crypto_core_hsalsa20_CONSTBYTES = 16;

function crypto_core_hsalsa20(outbuf:pcuchar; inbuf:pcuchar; k:pcuchar; c:pcuchar):cint;cdecl;external;


// stream aes128 ctr
const
  crypto_stream_aes128ctr_KEYBYTES = 16;
  crypto_stream_aes128ctr_NONCEBYTES = 16;
  crypto_stream_aes128ctr_BEFORENMBYTES = 1408;

function crypto_stream_aes128ctr(outbuf:pcuchar; outlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_aes128ctr_xor(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_aes128ctr_beforenm(c:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_aes128ctr_afternm(outbuf:pcuchar; len:culonglong; nonce:pcuchar; c:pcuchar):cint;cdecl;external;
function crypto_stream_aes128ctr_xor_afternm(outbuf:pcuchar; inbuf:pcuchar; len:culonglong; nonce:pcuchar; c:pcuchar):cint;cdecl;external;

// stream chacha20
const
  crypto_stream_chacha20_KEYBYTES = 32;
  crypto_stream_chacha20_NONCEBYTES = 8;

function crypto_stream_chacha20(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_chacha20_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_chacha20_xor_ic(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; ic:cuint64; k:pcuchar):cint;cdecl;external;

// stream salsa208
const
  crypto_stream_salsa208_KEYBYTES = 32;
  crypto_stream_salsa208_NONCEBYTES = 8;

function crypto_stream_salsa208(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_salsa208_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;

// stream salsa20
const
  crypto_stream_salsa20_KEYBYTES = 32;
  crypto_stream_salsa20_NONCEBYTES = 8;

function crypto_stream_salsa20(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_salsa20_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_salsa20_xor_ic(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; ic:cuint64; k:pcuchar):cint;cdecl;external;

// stream salsa2012
const
  crypto_stream_salsa2012_KEYBYTES = 32;
  crypto_stream_salsa2012_NONCEBYTES = 8;

function crypto_stream_salsa2012(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_salsa2012_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;

// stream xsalsa20
const
  crypto_stream_xsalsa20_KEYBYTES = 32;
  crypto_stream_xsalsa20_NONCEBYTES = 24;

function crypto_stream_xsalsa20(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_xsalsa20_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;

// stream
const
  crypto_stream_KEYBYTES = crypto_stream_xsalsa20_KEYBYTES;
  crypto_stream_NONCEBYTES = crypto_stream_xsalsa20_NONCEBYTES;

function crypto_stream(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_stream_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;

// poly1305
type
  Pcrypto_onetimeauth_poly1305_state = ^crypto_onetimeauth_poly1305_state;
  crypto_onetimeauth_poly1305_state = record
      aligner : culonglong;
      opaque : array[0..135] of cuchar;
    end;

  Pcrypto_onetimeauth_poly1305_implementation = ^crypto_onetimeauth_poly1305_implementation;
  crypto_onetimeauth_poly1305_implementation = record
      implementation_name : function :pcchar;cdecl;
      onetimeauth : function (outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;
      onetimeauth_verify : function (h:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;
      onetimeauth_init : function (state:Pcrypto_onetimeauth_poly1305_state; key:pcuchar):cint;cdecl;
      onetimeauth_update : function (state:Pcrypto_onetimeauth_poly1305_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;
      onetimeauth_final : function (state:Pcrypto_onetimeauth_poly1305_state; outbuf:pcuchar):cint;cdecl;
    end;

const
  crypto_onetimeauth_poly1305_BYTES = 16;
  crypto_onetimeauth_poly1305_KEYBYTES = 32;

function crypto_onetimeauth_poly1305_implementation_name:pcchar;cdecl;external;
function crypto_onetimeauth_poly1305_set_implementation(impl:Pcrypto_onetimeauth_poly1305_implementation):cint;cdecl;external;
function crypto_onetimeauth_pick_best_implementation:Pcrypto_onetimeauth_poly1305_implementation;cdecl;external;

function crypto_onetimeauth_poly1305(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_onetimeauth_poly1305_verify(h:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_onetimeauth_poly1305_init(state:Pcrypto_onetimeauth_poly1305_state; key:pcuchar):cint;cdecl;external;
function crypto_onetimeauth_poly1305_update(state:Pcrypto_onetimeauth_poly1305_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_onetimeauth_poly1305_final(state:Pcrypto_onetimeauth_poly1305_state; outbuf:pcuchar):cint;cdecl;external;

// onetimeauth
type
  Pcrypto_onetimeauth_state = ^crypto_onetimeauth_state;
  crypto_onetimeauth_state = crypto_onetimeauth_poly1305_state;

const
  crypto_onetimeauth_BYTES = crypto_onetimeauth_poly1305_BYTES;
  crypto_onetimeauth_KEYBYTES = crypto_onetimeauth_poly1305_KEYBYTES;

function crypto_onetimeauth(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_onetimeauth_verify(h:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_onetimeauth_init(state:Pcrypto_onetimeauth_state; key:pcuchar):cint;cdecl;external;
function crypto_onetimeauth_update(state:Pcrypto_onetimeauth_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_onetimeauth_final(state:Pcrypto_onetimeauth_state; outbuf:pcuchar):cint;cdecl;external;

// secretbox_xsalsa20poly1305
const
  crypto_secretbox_xsalsa20poly1305_KEYBYTES = 32;
  crypto_secretbox_xsalsa20poly1305_NONCEBYTES = 24;
  crypto_secretbox_xsalsa20poly1305_ZEROBYTES = 32;
  crypto_secretbox_xsalsa20poly1305_BOXZEROBYTES = 16;
  crypto_secretbox_xsalsa20poly1305_MACBYTES = crypto_secretbox_xsalsa20poly1305_ZEROBYTES-crypto_secretbox_xsalsa20poly1305_BOXZEROBYTES;

function crypto_secretbox_xsalsa20poly1305(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_secretbox_xsalsa20poly1305_open(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;


// secretbox
const
  crypto_secretbox_KEYBYTES = crypto_secretbox_xsalsa20poly1305_KEYBYTES;
  crypto_secretbox_NONCEBYTES = crypto_secretbox_xsalsa20poly1305_NONCEBYTES;
  crypto_secretbox_ZEROBYTES = crypto_secretbox_xsalsa20poly1305_ZEROBYTES;
  crypto_secretbox_BOXZEROBYTES = crypto_secretbox_xsalsa20poly1305_BOXZEROBYTES;
  crypto_secretbox_MACBYTES = crypto_secretbox_xsalsa20poly1305_MACBYTES;

function crypto_secretbox(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_secretbox_open(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_secretbox_easy(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_secretbox_open_easy(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_secretbox_detached(c:pcuchar; mac:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_secretbox_open_detached(m:pcuchar; c:pcuchar; mac:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;

// curve25519 scalar multiplication
const
  crypto_scalarmult_curve25519_BYTES = 32;
  crypto_scalarmult_curve25519_SCALARBYTES = 32;
  crypto_scalarmult_BYTES = 32;
  crypto_scalarmult_SCALARBYTES = 32;

function crypto_scalarmult_curve25519(q:pcuchar; n:pcuchar; p:pcuchar):cint;cdecl;external;
function crypto_scalarmult_curve25519_base(q:pcuchar; n:pcuchar):cint;cdecl;external;
function crypto_scalarmult_base(q:pcuchar; n:pcuchar):cint;cdecl;external;
function crypto_scalarmult(q:pcuchar; n:pcuchar; p:pcuchar):cint;cdecl;external;


// box curve25519 xsalsa20 poly1305
const
  crypto_box_curve25519xsalsa20poly1305_SEEDBYTES = 32;
  crypto_box_curve25519xsalsa20poly1305_PUBLICKEYBYTES = 32;
  crypto_box_curve25519xsalsa20poly1305_SECRETKEYBYTES = 32;
  crypto_box_curve25519xsalsa20poly1305_BEFORENMBYTES = 32;
  crypto_box_curve25519xsalsa20poly1305_NONCEBYTES = 24;
  crypto_box_curve25519xsalsa20poly1305_ZEROBYTES = 32;
  crypto_box_curve25519xsalsa20poly1305_BOXZEROBYTES = 16;
  crypto_box_curve25519xsalsa20poly1305_MACBYTES = crypto_box_curve25519xsalsa20poly1305_ZEROBYTES-crypto_box_curve25519xsalsa20poly1305_BOXZEROBYTES;

function crypto_box_curve25519xsalsa20poly1305(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external;
function crypto_box_curve25519xsalsa20poly1305_open(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external;
function crypto_box_curve25519xsalsa20poly1305_seed_keypair(pk:pcuchar; sk:pcuchar; seed:pcuchar):cint;cdecl;external;
function crypto_box_curve25519xsalsa20poly1305_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external;
function crypto_box_curve25519xsalsa20poly1305_beforenm(k:pcuchar; pk:pcuchar; sk:pcuchar):cint;cdecl;external;
function crypto_box_curve25519xsalsa20poly1305_afternm(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_box_curve25519xsalsa20poly1305_open_afternm(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;

// box
const
  crypto_box_SEEDBYTES = crypto_box_curve25519xsalsa20poly1305_SEEDBYTES;
  crypto_box_PUBLICKEYBYTES = crypto_box_curve25519xsalsa20poly1305_PUBLICKEYBYTES;
  crypto_box_SECRETKEYBYTES = crypto_box_curve25519xsalsa20poly1305_SECRETKEYBYTES;
  crypto_box_BEFORENMBYTES = crypto_box_curve25519xsalsa20poly1305_BEFORENMBYTES;
  crypto_box_NONCEBYTES = crypto_box_curve25519xsalsa20poly1305_NONCEBYTES;
  crypto_box_ZEROBYTES = crypto_box_curve25519xsalsa20poly1305_ZEROBYTES;
  crypto_box_BOXZEROBYTES = crypto_box_curve25519xsalsa20poly1305_BOXZEROBYTES;
  crypto_box_MACBYTES = crypto_box_curve25519xsalsa20poly1305_MACBYTES;

function crypto_box_seed_keypair(pk:pcuchar; sk:pcuchar; seed:pcuchar):cint;cdecl;external;
function crypto_box_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external;
function crypto_box_beforenm(k:pcuchar; pk:pcuchar; sk:pcuchar):cint;cdecl;external;
function crypto_box_afternm(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_box_open_afternm(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_box(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external;
function crypto_box_open(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external;
function crypto_box_easy(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external;
function crypto_box_open_easy(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external;
function crypto_box_detached(c:pcuchar; mac:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar;
           pk:pcuchar; sk:pcuchar):cint;cdecl;external;
function crypto_box_open_detached(m:pcuchar; c:pcuchar; mac:pcuchar; clen:culonglong; n:pcuchar;
           pk:pcuchar; sk:pcuchar):cint;cdecl;external;


// blake2b
type
  Pcrypto_generichash_blake2b_state = ^crypto_generichash_blake2b_state;
  crypto_generichash_blake2b_state = record
      h : array[0..7] of cuint64;
      t : array[0..1] of cuint64;
      f : array[0..1] of cuint64;
      buf : array[0..(2*128)-1] of cuint8;
      buflen : csize_t;
      last_node : cuint8;
    end;

const
  crypto_generichash_blake2b_BYTES_MIN = 16;
  crypto_generichash_blake2b_BYTES_MAX = 64;
  crypto_generichash_blake2b_BYTES = 32;
  crypto_generichash_blake2b_KEYBYTES_MIN = 16;
  crypto_generichash_blake2b_KEYBYTES_MAX = 64;
  crypto_generichash_blake2b_KEYBYTES = 32;
  crypto_generichash_blake2b_SALTBYTES = 16;
  crypto_generichash_blake2b_PERSONALBYTES = 16;

function crypto_generichash_blake2b(outbuf:pcuchar; outlen:csize_t; inbuf:pcuchar; inlen:culonglong; key:pcuchar;
           keylen:csize_t):cint;cdecl;external;
function crypto_generichash_blake2b_salt_personal(outbuf:pcuchar; outlen:csize_t; inbuf:pcuchar; inlen:culonglong; key:pcuchar;
           keylen:csize_t; salt:pcuchar; personal:pcuchar):cint;cdecl;external;
function crypto_generichash_blake2b_init(state:Pcrypto_generichash_blake2b_state; key:pcuchar; keylen:csize_t; outlen:csize_t):cint;cdecl;external;
function crypto_generichash_blake2b_init_salt_personal(state:Pcrypto_generichash_blake2b_state; key:pcuchar; keylen:csize_t; outlen:csize_t; salt:pcuchar;
           personal:pcuchar):cint;cdecl;external;
function crypto_generichash_blake2b_update(state:Pcrypto_generichash_blake2b_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_generichash_blake2b_final(state:Pcrypto_generichash_blake2b_state; outbuf:pcuchar; outlen:csize_t):cint;cdecl;external;

// generic hash
const
  crypto_generichash_BYTES_MIN = crypto_generichash_blake2b_BYTES_MIN;
  crypto_generichash_BYTES_MAX = crypto_generichash_blake2b_BYTES_MAX;
  crypto_generichash_BYTES = crypto_generichash_blake2b_BYTES;
  crypto_generichash_KEYBYTES_MIN = crypto_generichash_blake2b_KEYBYTES_MIN;
  crypto_generichash_KEYBYTES_MAX = crypto_generichash_blake2b_KEYBYTES_MAX;
  crypto_generichash_KEYBYTES = crypto_generichash_blake2b_KEYBYTES;

type
  Pcrypto_generichash_state = ^crypto_generichash_state;
  crypto_generichash_state = crypto_generichash_blake2b_state;

function crypto_generichash(outbuf:pcuchar; outlen:csize_t; inbuf:pcuchar; inlen:culonglong; key:pcuchar;
           keylen:csize_t):cint;cdecl;external;
function crypto_generichash_init(state:Pcrypto_generichash_state; key:pcuchar; keylen:csize_t; outlen:csize_t):cint;cdecl;external;
function crypto_generichash_update(state:Pcrypto_generichash_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_generichash_final(state:Pcrypto_generichash_state; outbuf:pcuchar; outlen:csize_t):cint;cdecl;external;

// siphash 2.4
const
  crypto_shorthash_siphash24_BYTES = 8;
  crypto_shorthash_siphash24_KEYBYTES = 16;

function crypto_shorthash_siphash24(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;

// shorthash
const
  crypto_shorthash_BYTES = crypto_shorthash_siphash24_BYTES;
  crypto_shorthash_KEYBYTES = crypto_shorthash_siphash24_KEYBYTES;

function crypto_shorthash(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;

// sha256
type
  Pcrypto_hash_sha256_state = ^crypto_hash_sha256_state;
  crypto_hash_sha256_state = record
      state : array[0..7] of cuint32;
      count : array[0..1] of cuint32;
      buf : array[0..63] of cuchar;
    end;

const
  crypto_hash_sha256_BYTES = 32;

function crypto_hash_sha256(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_hash_sha256_init(state:Pcrypto_hash_sha256_state):cint;cdecl;external;
function crypto_hash_sha256_update(state:Pcrypto_hash_sha256_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_hash_sha256_final(state:Pcrypto_hash_sha256_state; outbuf:pcuchar):cint;cdecl;external;

// sha512
type
  Pcrypto_hash_sha512_state = ^crypto_hash_sha512_state;
  crypto_hash_sha512_state = record
      state : array[0..7] of cuint64;
      count : array[0..1] of cuint64;
      buf : array[0..127] of cuchar;
    end;

const
  crypto_hash_sha512_BYTES = 64;

function crypto_hash_sha512(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_hash_sha512_init(state:Pcrypto_hash_sha512_state):cint;cdecl;external;
function crypto_hash_sha512_update(state:Pcrypto_hash_sha512_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_hash_sha512_final(state:Pcrypto_hash_sha512_state; outbuf:pcuchar):cint;cdecl;external;

// scrypt salsa208 sha256
const
  crypto_pwhash_scryptsalsa208sha256_SALTBYTES = 32;
  crypto_pwhash_scryptsalsa208sha256_STRBYTES = 102;
  crypto_pwhash_scryptsalsa208sha256_STRPREFIX = '$7$';
  crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_INTERACTIVE = 524288;
  crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_INTERACTIVE = 16777216;
  crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_SENSITIVE = 33554432;
  crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_SENSITIVE = 1073741824;

type
  TPwhashScrypt = array[0..(crypto_pwhash_scryptsalsa208sha256_STRBYTES)-1] of cchar;

function crypto_pwhash_scryptsalsa208sha256(outbuf:pcuchar; outlen:culonglong; passwd:pcchar; passwdlen:culonglong; salt:pcuchar;
           opslimit:culonglong; memlimit:csize_t):cint;cdecl;external;
function crypto_pwhash_scryptsalsa208sha256_str(outbuf:TPwhashScrypt; passwd:pcchar; passwdlen:culonglong; opslimit:culonglong; memlimit:csize_t):cint;cdecl;external;
function crypto_pwhash_scryptsalsa208sha256_str_verify(str:TPwhashScrypt; passwd:pcchar; passwdlen:culonglong):cint;cdecl;external;
function crypto_pwhash_scryptsalsa208sha256_ll(passwd:Pcuint8; passwdlen:csize_t; salt:Pcuint8; saltlen:csize_t; N:cuint64;
           r:cuint32; p:cuint32; buf:Pcuint8; buflen:csize_t):cint;cdecl;external;

// hash
const
  crypto_hash_BYTES = crypto_hash_sha512_BYTES;

function crypto_hash(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;

// ed25519
const
  crypto_sign_ed25519_BYTES = 64;
  crypto_sign_ed25519_SEEDBYTES = 32;
  crypto_sign_ed25519_PUBLICKEYBYTES = 32;
  crypto_sign_ed25519_SECRETKEYBYTES = 32+32;

function crypto_sign_ed25519(sm:pcuchar; smlen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_open(m:pcuchar; mlen:pculonglong; sm:pcuchar; smlen:culonglong; pk:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_detached(sig:pcuchar; siglen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_verify_detached(sig:pcuchar; m:pcuchar; mlen:culonglong; pk:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_seed_keypair(pk:pcuchar; sk:pcuchar; seed:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_pk_to_curve25519(curve25519_pk:pcuchar; ed25519_pk:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_sk_to_curve25519(curve25519_sk:pcuchar; ed25519_sk:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_sk_to_seed(seed:pcuchar; sk:pcuchar):cint;cdecl;external;
function crypto_sign_ed25519_sk_to_pk(pk:pcuchar; sk:pcuchar):cint;cdecl;external;

// edwards25519 sha512 batch
const
  crypto_sign_edwards25519sha512batch_BYTES = 64;
  crypto_sign_edwards25519sha512batch_PUBLICKEYBYTES = 32;
  crypto_sign_edwards25519sha512batch_SECRETKEYBYTES = 32+32;

function crypto_sign_edwards25519sha512batch(sm:pcuchar; smlen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external;
function crypto_sign_edwards25519sha512batch_open(m:pcuchar; mlen:pculonglong; sm:pcuchar; smlen:culonglong; pk:pcuchar):cint;cdecl;external;
function crypto_sign_edwards25519sha512batch_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external;

// sign
const
  crypto_sign_BYTES = crypto_sign_ed25519_BYTES;
  crypto_sign_SEEDBYTES = crypto_sign_ed25519_SEEDBYTES;
  crypto_sign_PUBLICKEYBYTES = crypto_sign_ed25519_PUBLICKEYBYTES;
  crypto_sign_SECRETKEYBYTES = crypto_sign_ed25519_SECRETKEYBYTES;

function crypto_sign_seed_keypair(pk:pcuchar; sk:pcuchar; seed:pcuchar):cint;cdecl;external;
function crypto_sign_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external;
function crypto_sign(sm:pcuchar; smlen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external;
function crypto_sign_open(m:pcuchar; mlen:pculonglong; sm:pcuchar; smlen:culonglong; pk:pcuchar):cint;cdecl;external;
function crypto_sign_detached(sig:pcuchar; siglen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external;
function crypto_sign_verify_detached(sig:pcuchar; m:pcuchar; mlen:culonglong; pk:pcuchar):cint;cdecl;external;

// aead chacha20 poly1305
const
  crypto_aead_chacha20poly1305_KEYBYTES = 32;
  crypto_aead_chacha20poly1305_NSECBYTES = 0;
  crypto_aead_chacha20poly1305_NPUBBYTES = 8;
  crypto_aead_chacha20poly1305_ABYTES = 16;

function crypto_aead_chacha20poly1305_encrypt(c:pcuchar; clen:pculonglong; m:pcuchar; mlen:culonglong; ad:pcuchar;
             adlen:culonglong; nsec:pcuchar; npub:pcuchar; k:pcuchar):cint;cdecl;external;
function crypto_aead_chacha20poly1305_decrypt(m:pcuchar; mlen:pculonglong; nsec:pcuchar; c:pcuchar; clen:culonglong;
             ad:pcuchar; adlen:culonglong; npub:pcuchar; k:pcuchar):cint;cdecl;external;

// hmac sha256
type
  Pcrypto_auth_hmacsha256_state = ^crypto_auth_hmacsha256_state;
  crypto_auth_hmacsha256_state = record
      ictx : crypto_hash_sha256_state;
      octx : crypto_hash_sha256_state;
    end;

const
  crypto_auth_hmacsha256_BYTES = 32;
  crypto_auth_hmacsha256_KEYBYTES = 32;

function crypto_auth_hmacsha256(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_auth_hmacsha256_verify(h:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_auth_hmacsha256_init(state:Pcrypto_auth_hmacsha256_state; key:pcuchar; keylen:csize_t):cint;cdecl;external;
function crypto_auth_hmacsha256_update(state:Pcrypto_auth_hmacsha256_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_auth_hmacsha256_final(state:Pcrypto_auth_hmacsha256_state; outbuf:pcuchar):cint;cdecl;external;

// hmac sha512
type
  Pcrypto_auth_hmacsha512_state = ^crypto_auth_hmacsha512_state;
  crypto_auth_hmacsha512_state = record
      ictx : crypto_hash_sha512_state;
      octx : crypto_hash_sha512_state;
    end;

const
  crypto_auth_hmacsha512_BYTES = 64;
  crypto_auth_hmacsha512_KEYBYTES = 32;

function crypto_auth_hmacsha512(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_auth_hmacsha512_verify(h:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_auth_hmacsha512_init(state:Pcrypto_auth_hmacsha512_state; key:pcuchar; keylen:csize_t):cint;cdecl;external;
function crypto_auth_hmacsha512_update(state:Pcrypto_auth_hmacsha512_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_auth_hmacsha512_final(state:Pcrypto_auth_hmacsha512_state; outbuf:pcuchar):cint;cdecl;external;

// hmac sha512 sha256
type
  Pcrypto_auth_hmacsha512256_state = ^crypto_auth_hmacsha512_state;

const
  crypto_auth_hmacsha512256_BYTES = 32;
  crypto_auth_hmacsha512256_KEYBYTES = 32;

function crypto_auth_hmacsha512256(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_auth_hmacsha512256_verify(h:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_auth_hmacsha512256_init(state:Pcrypto_auth_hmacsha512256_state; key:pcuchar; keylen:csize_t):cint;cdecl;external;
function crypto_auth_hmacsha512256_update(state:Pcrypto_auth_hmacsha512256_state; inbuf:pcuchar; inlen:culonglong):cint;cdecl;external;
function crypto_auth_hmacsha512256_final(state:Pcrypto_auth_hmacsha512256_state; outbuf:pcuchar):cint;cdecl;external;

// auth hmac
const
  crypto_auth_BYTES = crypto_auth_hmacsha512256_BYTES;
  crypto_auth_KEYBYTES = crypto_auth_hmacsha512256_KEYBYTES;

function crypto_auth(outbuf:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;
function crypto_auth_verify(h:pcuchar; inbuf:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external;


implementation

function sodium_init:cint;cdecl;external SODIUMLIB;

initialization
  sodium_init;

end.
