unit sodium;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

interface

uses
  ctypes;

{
  Free Pascal wrapper for libsodium - https://github.com/jedisct1/libsodium

  Automatically converted by H2Pas 1.0.0 from sodium.h
  The following command line parameters were used:
    -D
    -c
    -C
    -l
    libsodium
    -p
    -o
    sodium.pas
    sodium.h
}

type
  size_t = csize_t;
  Psize_t = pcsize_t;
  Ppcchar = ^pcchar;
  uint8_t = cuint8;
  Puint8_t = pcuint8;
  uint16_t = cuint16;
  uint32_t = cuint32;
  uint64_t = cuint64;

const
  SODIUMLIB =
    {$IFDEF WINDOWS}
      'libsodium.dll'
    {$ELSE}
      {$IFDEF DARWIN}
        'libsodium.dylib'
      {$ELSE}
        'libsodium.so'
      {$ENDIF}
    {$ENDIF}
    ;

type
  Prandombytes_implementation = ^Trandombytes_implementation;
  Trandombytes_implementation = record
      implementation_name : function :pcchar;
      random : function :uint32_t;
      stir : procedure ;
      uniform : function (upper_bound:uint32_t):uint32_t;
      buf : procedure (buf:pointer; size:size_t);
      close : function :cint;
    end;

  Prandombytes_sysrandom_implementation = ^Trandombytes_sysrandom_implementation;
  Trandombytes_sysrandom_implementation = Trandombytes_implementation;

  Prandombytes_salsa20_implementation = ^Trandombytes_salsa20_implementation;
  Trandombytes_salsa20_implementation = Trandombytes_implementation;

  Pcrypto_onetimeauth_poly1305_state = ^Tcrypto_onetimeauth_poly1305_state;
  Tcrypto_onetimeauth_poly1305_state = record
      aligner : culonglong;
      opaque : array[0..135] of cuchar;
    end;

  Pcrypto_onetimeauth_poly1305_implementation = ^Tcrypto_onetimeauth_poly1305_implementation;
  Tcrypto_onetimeauth_poly1305_implementation = record
      implementation_name : function :pcchar;
      onetimeauth : function (output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;
      onetimeauth_verify : function (h:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;
      onetimeauth_init : function (state:Pcrypto_onetimeauth_poly1305_state; key:pcuchar):cint;
      onetimeauth_update : function (state:Pcrypto_onetimeauth_poly1305_state; input:pcuchar; inlen:culonglong):cint;
      onetimeauth_final : function (state:Pcrypto_onetimeauth_poly1305_state; output:pcuchar):cint;
    end;

  Pcrypto_onetimeauth_state = ^Tcrypto_onetimeauth_state;
  Tcrypto_onetimeauth_state = Tcrypto_onetimeauth_poly1305_state;

  Pcrypto_hash_sha256_state = ^Tcrypto_hash_sha256_state;
  Tcrypto_hash_sha256_state = record
      state : array[0..7] of uint32_t;
      count : array[0..1] of uint32_t;
      buf : array[0..63] of cuchar;
    end;

  Pcrypto_hash_sha512_state = ^Tcrypto_hash_sha512_state;
  Tcrypto_hash_sha512_state = record
      state : array[0..7] of uint64_t;
      count : array[0..1] of uint64_t;
      buf : array[0..127] of cuchar;
    end;

  Pcrypto_generichash_blake2b_state = ^Tcrypto_generichash_blake2b_state;
  Tcrypto_generichash_blake2b_state = record
      h : array[0..7] of uint64_t;
      t : array[0..1] of uint64_t;
      f : array[0..1] of uint64_t;
      buf : array[0..(2*128)-1] of uint8_t;
      buflen : size_t;
      last_node : uint8_t;
    end;

  Pcrypto_generichash_state = ^Tcrypto_generichash_state;
  Tcrypto_generichash_state = Tcrypto_generichash_blake2b_state;

  Pcrypto_auth_hmacsha256_state = ^Tcrypto_auth_hmacsha256_state;
  Tcrypto_auth_hmacsha256_state = record
      ictx : Tcrypto_hash_sha256_state;
      octx : Tcrypto_hash_sha256_state;
    end;

  Pcrypto_auth_hmacsha512_state = ^Tcrypto_auth_hmacsha512_state;
  Tcrypto_auth_hmacsha512_state = record
      ictx : Tcrypto_hash_sha512_state;
      octx : Tcrypto_hash_sha512_state;
    end;

  Pcrypto_auth_hmacsha512256_state = ^Tcrypto_auth_hmacsha512256_state;
  Tcrypto_auth_hmacsha512256_state = Tcrypto_auth_hmacsha512_state;

{ core }
// move to initialization
//function sodium_init:cint;cdecl;external SODIUMLIB name 'sodium_init';

{ version }
function sodium_version_string:pcchar;cdecl;external SODIUMLIB name 'sodium_version_string';
function sodium_library_version_major:cint;cdecl;external SODIUMLIB name 'sodium_library_version_major';
function sodium_library_version_minor:cint;cdecl;external SODIUMLIB name 'sodium_library_version_minor';

{ runtime }
function sodium_runtime_get_cpu_features:cint;cdecl;external SODIUMLIB name 'sodium_runtime_get_cpu_features';
function sodium_runtime_has_neon:cint;cdecl;external SODIUMLIB name 'sodium_runtime_has_neon';
function sodium_runtime_has_sse2:cint;cdecl;external SODIUMLIB name 'sodium_runtime_has_sse2';
function sodium_runtime_has_sse3:cint;cdecl;external SODIUMLIB name 'sodium_runtime_has_sse3';

{ utils }
procedure sodium_memzero(pnt:pointer; len:size_t);cdecl;external SODIUMLIB name 'sodium_memzero';
function sodium_memcmp(b1_:pointer; b2_:pointer; len:size_t):cint;cdecl;external SODIUMLIB name 'sodium_memcmp';
function sodium_bin2hex(hex:pcchar; hex_maxlen:size_t; bin:pcuchar; bin_len:size_t):pcchar;cdecl;external SODIUMLIB name 'sodium_bin2hex';
function sodium_hex2bin(bin:pcuchar; bin_maxlen:size_t; hex:pcchar; hex_len:size_t; ignore:pcchar;
           bin_len:Psize_t; hex_end:Ppcchar):cint;cdecl;external SODIUMLIB name 'sodium_hex2bin';
function sodium_mlock(addr:pointer; len:size_t):cint;cdecl;external SODIUMLIB name 'sodium_mlock';
function sodium_munlock(addr:pointer; len:size_t):cint;cdecl;external SODIUMLIB name 'sodium_munlock';
function sodium_malloc(size:size_t):pointer;cdecl;external SODIUMLIB name 'sodium_malloc';
function sodium_allocarray(count:size_t; size:size_t):pointer;cdecl;external SODIUMLIB name 'sodium_allocarray';
procedure sodium_free(ptr:pointer);cdecl;external SODIUMLIB name 'sodium_free';
function sodium_mprotect_noaccess(ptr:pointer):cint;cdecl;external SODIUMLIB name 'sodium_mprotect_noaccess';
function sodium_mprotect_readonly(ptr:pointer):cint;cdecl;external SODIUMLIB name 'sodium_mprotect_readonly';
function sodium_mprotect_readwrite(ptr:pointer):cint;cdecl;external SODIUMLIB name 'sodium_mprotect_readwrite';

{ randombytes }
procedure randombytes_buf(buf:pointer; size:size_t);cdecl;external SODIUMLIB name 'randombytes_buf';
function randombytes_random:uint32_t;cdecl;external SODIUMLIB name 'randombytes_random';
function randombytes_uniform(upper_bound:uint32_t):uint32_t;cdecl;external SODIUMLIB name 'randombytes_uniform';
procedure randombytes_stir;cdecl;external SODIUMLIB name 'randombytes_stir';
function randombytes_close:cint;cdecl;external SODIUMLIB name 'randombytes_close';
function randombytes_set_implementation(impl:Prandombytes_implementation):cint;cdecl;external SODIUMLIB name 'randombytes_set_implementation';
function randombytes_implementation_name:pcchar;cdecl;external SODIUMLIB name 'randombytes_implementation_name';
{ -- Compatibility layer with NaCl --  }
procedure randombytes(buf:pcuchar; buf_len:culonglong);cdecl;external SODIUMLIB name 'randombytes';

{ randombytes_sysrandom }
function randombytes_sysrandom_implementation_name:pcchar;cdecl;external SODIUMLIB name 'randombytes_sysrandom_implementation_name';
function randombytes_sysrandom:uint32_t;cdecl;external SODIUMLIB name 'randombytes_sysrandom';
procedure randombytes_sysrandom_stir;cdecl;external SODIUMLIB name 'randombytes_sysrandom_stir';
function randombytes_sysrandom_uniform(upper_bound:uint32_t):uint32_t;cdecl;external SODIUMLIB name 'randombytes_sysrandom_uniform';
procedure randombytes_sysrandom_buf(buf:pointer; size:size_t);cdecl;external SODIUMLIB name 'randombytes_sysrandom_buf';
function randombytes_sysrandom_close:cint;cdecl;external SODIUMLIB name 'randombytes_sysrandom_close';

{ randombytes_salsa20_random }
function randombytes_salsa20_implementation_name:pcchar;cdecl;external SODIUMLIB name 'randombytes_salsa20_implementation_name';
function randombytes_salsa20_random:uint32_t;cdecl;external SODIUMLIB name 'randombytes_salsa20_random';
procedure randombytes_salsa20_random_stir;cdecl;external SODIUMLIB name 'randombytes_salsa20_random_stir';
function randombytes_salsa20_random_uniform(upper_bound:uint32_t):uint32_t;cdecl;external SODIUMLIB name 'randombytes_salsa20_random_uniform';
procedure randombytes_salsa20_random_buf(buf:pointer; size:size_t);cdecl;external SODIUMLIB name 'randombytes_salsa20_random_buf';
function randombytes_salsa20_random_close:cint;cdecl;external SODIUMLIB name 'randombytes_salsa20_random_close';

{ crypto_verify }
function crypto_verify_16_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_verify_16_bytes';
function crypto_verify_16(x:pcuchar; y:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_verify_16';
function crypto_verify_32_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_verify_32_bytes';
function crypto_verify_32(x:pcuchar; y:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_verify_32';
function crypto_verify_64_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_verify_64_bytes';
function crypto_verify_64(x:pcuchar; y:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_verify_64';

{ crypto_core_salsa20 }
function crypto_core_salsa20_outputbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa20_outputbytes';
function crypto_core_salsa20_inputbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa20_inputbytes';
function crypto_core_salsa20_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa20_keybytes';
function crypto_core_salsa20_constbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa20_constbytes';
function crypto_core_salsa20(output:pcuchar; input:pcuchar; k:pcuchar; c:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_core_salsa20';

{ crypto_core_salsa208 }
function crypto_core_salsa208_outputbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa208_outputbytes';
function crypto_core_salsa208_inputbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa208_inputbytes';
function crypto_core_salsa208_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa208_keybytes';
function crypto_core_salsa208_constbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa208_constbytes';
function crypto_core_salsa208(output:pcuchar; input:pcuchar; k:pcuchar; c:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_core_salsa208';

{ crypto_core_salsal2012 }
function crypto_core_salsa2012_outputbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa2012_outputbytes';
function crypto_core_salsa2012_inputbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa2012_inputbytes';
function crypto_core_salsa2012_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa2012_keybytes';
function crypto_core_salsa2012_constbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_salsa2012_constbytes';
function crypto_core_salsa2012(output:pcuchar; input:pcuchar; k:pcuchar; c:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_core_salsa2012';

{ crypto_core_hsalsa20 }
function crypto_core_hsalsa20_outputbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_hsalsa20_outputbytes';
function crypto_core_hsalsa20_inputbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_hsalsa20_inputbytes';
function crypto_core_hsalsa20_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_hsalsa20_keybytes';
function crypto_core_hsalsa20_constbytes:size_t;cdecl;external SODIUMLIB name 'crypto_core_hsalsa20_constbytes';
function crypto_core_hsalsa20(output:pcuchar; input:pcuchar; k:pcuchar; c:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_core_hsalsa20';

{ crypto_stream_salsa20 }
function crypto_stream_salsa20_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_salsa20_keybytes';
function crypto_stream_salsa20_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_salsa20_noncebytes';
function crypto_stream_salsa20(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_salsa20';
function crypto_stream_salsa20_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_salsa20_xor';
function crypto_stream_salsa20_xor_ic(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; ic:uint64_t;
           k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_salsa20_xor_ic';

{ crypto_stream_salsal208 }
function crypto_stream_salsa208_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_salsa208_keybytes';
function crypto_stream_salsa208_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_salsa208_noncebytes';
function crypto_stream_salsa208(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_salsa208';
function crypto_stream_salsa208_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_salsa208_xor';

{ crypto_stream_salsa2012 }
function crypto_stream_salsa2012_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_salsa2012_keybytes';
function crypto_stream_salsa2012_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_salsa2012_noncebytes';
function crypto_stream_salsa2012(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_salsa2012';
function crypto_stream_salsa2012_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_salsa2012_xor';

{ crypto_stream_xsalsa20 }
function crypto_stream_xsalsa20_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_xsalsa20_keybytes';
function crypto_stream_xsalsa20_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_xsalsa20_noncebytes';
function crypto_stream_xsalsa20(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_xsalsa20';
function crypto_stream_xsalsa20_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_xsalsa20_xor';

{ crypto_stream }
function crypto_stream_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_keybytes';
function crypto_stream_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_noncebytes';
function crypto_stream_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_stream_primitive';
function crypto_stream(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream';
function crypto_stream_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_xor';

{ crypto_ctream_chacha20 }
function crypto_stream_chacha20_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_chacha20_keybytes';
function crypto_stream_chacha20_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_chacha20_noncebytes';
function crypto_stream_chacha20(c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_chacha20';
function crypto_stream_chacha20_xor(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_chacha20_xor';
function crypto_stream_chacha20_xor_ic(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; ic:uint64_t;
           k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_chacha20_xor_ic';

function crypto_stream_aes128ctr_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_aes128ctr_keybytes';
function crypto_stream_aes128ctr_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_aes128ctr_noncebytes';
function crypto_stream_aes128ctr_beforenmbytes:size_t;cdecl;external SODIUMLIB name 'crypto_stream_aes128ctr_beforenmbytes';

{ crypto_stream_aes128ctr }
function crypto_stream_aes128ctr(output:pcuchar; outlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_aes128ctr';
function crypto_stream_aes128ctr_xor(output:pcuchar; input:pcuchar; inlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_aes128ctr_xor';
function crypto_stream_aes128ctr_beforenm(c:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_aes128ctr_beforenm';
function crypto_stream_aes128ctr_afternm(output:pcuchar; len:culonglong; nonce:pcuchar; c:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_aes128ctr_afternm';
function crypto_stream_aes128ctr_xor_afternm(output:pcuchar; input:pcuchar; len:culonglong; nonce:pcuchar; c:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_stream_aes128ctr_xor_afternm';

{ crypto_onetimeauth_poly1305 }
function crypto_onetimeauth_poly1305_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305_bytes';
function crypto_onetimeauth_poly1305_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305_keybytes';
function crypto_onetimeauth_poly1305_implementation_name:pcchar;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305_implementation_name';
function crypto_onetimeauth_poly1305_set_implementation(impl:Pcrypto_onetimeauth_poly1305_implementation):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305_set_implementation';
function crypto_onetimeauth_pick_best_implementation:Pcrypto_onetimeauth_poly1305_implementation;cdecl;external SODIUMLIB name 'crypto_onetimeauth_pick_best_implementation';
function crypto_onetimeauth_poly1305(output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305';
function crypto_onetimeauth_poly1305_verify(h:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305_verify';
function crypto_onetimeauth_poly1305_init(state:Pcrypto_onetimeauth_poly1305_state; key:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305_init';
function crypto_onetimeauth_poly1305_update(state:Pcrypto_onetimeauth_poly1305_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305_update';
function crypto_onetimeauth_poly1305_final(state:Pcrypto_onetimeauth_poly1305_state; output:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_poly1305_final';

{ crypto_onetimeauth }
function crypto_onetimeauth_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_onetimeauth_bytes';
function crypto_onetimeauth_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_onetimeauth_keybytes';
function crypto_onetimeauth_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_onetimeauth_primitive';
function crypto_onetimeauth(output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth';
function crypto_onetimeauth_verify(h:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_verify';
function crypto_onetimeauth_init(state:Pcrypto_onetimeauth_state; key:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_init';
function crypto_onetimeauth_update(state:Pcrypto_onetimeauth_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_update';
function crypto_onetimeauth_final(state:Pcrypto_onetimeauth_state; output:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_onetimeauth_final';

{ crypto_secretbox_xsalsa20poly1305 }
function crypto_secretbox_xsalsa20poly1305_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_xsalsa20poly1305_keybytes';
function crypto_secretbox_xsalsa20poly1305_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_xsalsa20poly1305_noncebytes';
function crypto_secretbox_xsalsa20poly1305_zerobytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_xsalsa20poly1305_zerobytes';
function crypto_secretbox_xsalsa20poly1305_boxzerobytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_xsalsa20poly1305_boxzerobytes';
function crypto_secretbox_xsalsa20poly1305_macbytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_xsalsa20poly1305_macbytes';
function crypto_secretbox_xsalsa20poly1305(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_secretbox_xsalsa20poly1305';
function crypto_secretbox_xsalsa20poly1305_open(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_secretbox_xsalsa20poly1305_open';

{ crypto_secretbox }
function crypto_secretbox_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_keybytes';
function crypto_secretbox_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_noncebytes';
function crypto_secretbox_zerobytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_zerobytes';
function crypto_secretbox_boxzerobytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_boxzerobytes';
function crypto_secretbox_macbytes:size_t;cdecl;external SODIUMLIB name 'crypto_secretbox_macbytes';
function crypto_secretbox_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_secretbox_primitive';
function crypto_secretbox(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_secretbox';
function crypto_secretbox_open(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_secretbox_open';
function crypto_secretbox_easy(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_secretbox_easy';
function crypto_secretbox_open_easy(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_secretbox_open_easy';
function crypto_secretbox_detached(c:pcuchar; mac:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar;
           k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_secretbox_detached';
function crypto_secretbox_open_detached(m:pcuchar; c:pcuchar; mac:pcuchar; clen:culonglong; n:pcuchar;
           k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_secretbox_open_detached';

{ crypto_scalarmult_curve25519 }
function crypto_scalarmult_curve25519_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_scalarmult_curve25519_bytes';
function crypto_scalarmult_curve25519_scalarbytes:size_t;cdecl;external SODIUMLIB name 'crypto_scalarmult_curve25519_scalarbytes';
function crypto_scalarmult_curve25519(q:pcuchar; n:pcuchar; p:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_scalarmult_curve25519';
function crypto_scalarmult_curve25519_base(q:pcuchar; n:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_scalarmult_curve25519_base';

{ crypto_scalarmult }
function crypto_scalarmult_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_scalarmult_bytes';
function crypto_scalarmult_scalarbytes:size_t;cdecl;external SODIUMLIB name 'crypto_scalarmult_scalarbytes';
function crypto_scalarmult_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_scalarmult_primitive';
function crypto_scalarmult_base(q:pcuchar; n:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_scalarmult_base';
function crypto_scalarmult(q:pcuchar; n:pcuchar; p:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_scalarmult';

{ crypto_box_curve25519xsalsa20poly1305 }
function crypto_box_curve25519xsalsa20poly1305_seedbytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_seedbytes';
function crypto_box_curve25519xsalsa20poly1305_publickeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_publickeybytes';
function crypto_box_curve25519xsalsa20poly1305_secretkeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_secretkeybytes';
function crypto_box_curve25519xsalsa20poly1305_beforenmbytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_beforenmbytes';
function crypto_box_curve25519xsalsa20poly1305_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_noncebytes';
function crypto_box_curve25519xsalsa20poly1305_zerobytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_zerobytes';
function crypto_box_curve25519xsalsa20poly1305_boxzerobytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_boxzerobytes';
function crypto_box_curve25519xsalsa20poly1305_macbytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_macbytes';
function crypto_box_curve25519xsalsa20poly1305(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305';
function crypto_box_curve25519xsalsa20poly1305_open(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_open';
function crypto_box_curve25519xsalsa20poly1305_seed_keypair(pk:pcuchar; sk:pcuchar; seed:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_seed_keypair';
function crypto_box_curve25519xsalsa20poly1305_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_keypair';
function crypto_box_curve25519xsalsa20poly1305_beforenm(k:pcuchar; pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_beforenm';
function crypto_box_curve25519xsalsa20poly1305_afternm(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_afternm';
function crypto_box_curve25519xsalsa20poly1305_open_afternm(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_curve25519xsalsa20poly1305_open_afternm';

{ crypto_box}
function crypto_box_seedbytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_seedbytes';
function crypto_box_publickeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_publickeybytes';
function crypto_box_secretkeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_secretkeybytes';
function crypto_box_beforenmbytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_beforenmbytes';
function crypto_box_noncebytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_noncebytes';
function crypto_box_zerobytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_zerobytes';
function crypto_box_boxzerobytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_boxzerobytes';
function crypto_box_macbytes:size_t;cdecl;external SODIUMLIB name 'crypto_box_macbytes';
function crypto_box_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_box_primitive';
function crypto_box_seed_keypair(pk:pcuchar; sk:pcuchar; seed:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_seed_keypair';
function crypto_box_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_keypair';
function crypto_box_beforenm(k:pcuchar; pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_beforenm';
function crypto_box_afternm(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_afternm';
function crypto_box_open_afternm(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_open_afternm';
function crypto_box(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box';
function crypto_box_open(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_open';
function crypto_box_easy(c:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_easy';
function crypto_box_open_easy(m:pcuchar; c:pcuchar; clen:culonglong; n:pcuchar; pk:pcuchar;
           sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_open_easy';
function crypto_box_detached(c:pcuchar; mac:pcuchar; m:pcuchar; mlen:culonglong; n:pcuchar;
           pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_detached';
function crypto_box_open_detached(m:pcuchar; c:pcuchar; mac:pcuchar; clen:culonglong; n:pcuchar;
           pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_box_open_detached';

{ crypto_hash_256 }
function crypto_hash_sha256_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_hash_sha256_bytes';
function crypto_hash_sha256(output:pcuchar; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_hash_sha256';
function crypto_hash_sha256_init(state:Pcrypto_hash_sha256_state):cint;cdecl;external SODIUMLIB name 'crypto_hash_sha256_init';
function crypto_hash_sha256_update(state:Pcrypto_hash_sha256_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_hash_sha256_update';
function crypto_hash_sha256_final(state:Pcrypto_hash_sha256_state; output:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_hash_sha256_final';

{ crypto_hash_sha512 }
function crypto_hash_sha512_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_hash_sha512_bytes';
function crypto_hash_sha512(output:pcuchar; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_hash_sha512';
function crypto_hash_sha512_init(state:Pcrypto_hash_sha512_state):cint;cdecl;external SODIUMLIB name 'crypto_hash_sha512_init';
function crypto_hash_sha512_update(state:Pcrypto_hash_sha512_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_hash_sha512_update';
function crypto_hash_sha512_final(state:Pcrypto_hash_sha512_state; output:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_hash_sha512_final';

{ crypto_hash }
function crypto_hash_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_hash_bytes';
function crypto_hash(output:pcuchar; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_hash';
function crypto_hash_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_hash_primitive';

{ crypto_sign_edwards25519sha512batch }
function crypto_sign_edwards25519sha512batch_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_edwards25519sha512batch_bytes';
function crypto_sign_edwards25519sha512batch_publickeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_edwards25519sha512batch_publickeybytes';
function crypto_sign_edwards25519sha512batch_secretkeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_edwards25519sha512batch_secretkeybytes';
function crypto_sign_edwards25519sha512batch(sm:pcuchar; smlen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_edwards25519sha512batch';
function crypto_sign_edwards25519sha512batch_open(m:pcuchar; mlen:pculonglong; sm:pcuchar; smlen:culonglong; pk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_edwards25519sha512batch_open';
function crypto_sign_edwards25519sha512batch_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_edwards25519sha512batch_keypair';

{ crypto_sign_ed25519 }
function crypto_sign_ed25519_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_bytes';
function crypto_sign_ed25519_seedbytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_seedbytes';
function crypto_sign_ed25519_publickeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_publickeybytes';
function crypto_sign_ed25519_secretkeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_secretkeybytes';
function crypto_sign_ed25519(sm:pcuchar; smlen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519';
function crypto_sign_ed25519_open(m:pcuchar; mlen:pculonglong; sm:pcuchar; smlen:culonglong; pk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_open';
function crypto_sign_ed25519_detached(sig:pcuchar; siglen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_detached';
function crypto_sign_ed25519_verify_detached(sig:pcuchar; m:pcuchar; mlen:culonglong; pk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_verify_detached';
function crypto_sign_ed25519_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_keypair';
function crypto_sign_ed25519_seed_keypair(pk:pcuchar; sk:pcuchar; seed:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_seed_keypair';
function crypto_sign_ed25519_pk_to_curve25519(curve25519_pk:pcuchar; ed25519_pk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_pk_to_curve25519';
function crypto_sign_ed25519_sk_to_curve25519(curve25519_sk:pcuchar; ed25519_sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_sk_to_curve25519';
function crypto_sign_ed25519_sk_to_seed(seed:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_sk_to_seed';
function crypto_sign_ed25519_sk_to_pk(pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_ed25519_sk_to_pk';

{ crypto_sign }
function crypto_sign_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_bytes';
function crypto_sign_seedbytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_seedbytes';
function crypto_sign_publickeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_publickeybytes';
function crypto_sign_secretkeybytes:size_t;cdecl;external SODIUMLIB name 'crypto_sign_secretkeybytes';
function crypto_sign_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_sign_primitive';
function crypto_sign_seed_keypair(pk:pcuchar; sk:pcuchar; seed:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_seed_keypair';
function crypto_sign_keypair(pk:pcuchar; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_keypair';
function crypto_sign(sm:pcuchar; smlen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign';
function crypto_sign_open(m:pcuchar; mlen:pculonglong; sm:pcuchar; smlen:culonglong; pk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_open';
function crypto_sign_detached(sig:pcuchar; siglen:pculonglong; m:pcuchar; mlen:culonglong; sk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_detached';
function crypto_sign_verify_detached(sig:pcuchar; m:pcuchar; mlen:culonglong; pk:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_sign_verify_detached';

{ crypto_generichash_blake2b }
function crypto_generichash_blake2b_bytes_min:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_bytes_min';
function crypto_generichash_blake2b_bytes_max:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_bytes_max';
function crypto_generichash_blake2b_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_bytes';
function crypto_generichash_blake2b_keybytes_min:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_keybytes_min';
function crypto_generichash_blake2b_keybytes_max:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_keybytes_max';
function crypto_generichash_blake2b_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_keybytes';
function crypto_generichash_blake2b_saltbytes:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_saltbytes';
function crypto_generichash_blake2b_personalbytes:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_personalbytes';
function crypto_generichash_blake2b(output:pcuchar; outlen:size_t; input:pcuchar; inlen:culonglong; key:pcuchar;
           keylen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b';
function crypto_generichash_blake2b_salt_personal(output:pcuchar; outlen:size_t; input:pcuchar; inlen:culonglong; key:pcuchar;
           keylen:size_t; salt:pcuchar; personal:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_salt_personal';
function crypto_generichash_blake2b_init(state:Pcrypto_generichash_blake2b_state; key:pcuchar; keylen:size_t; outlen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_init';
function crypto_generichash_blake2b_init_salt_personal(state:Pcrypto_generichash_blake2b_state; key:pcuchar; keylen:size_t; outlen:size_t; salt:pcuchar;
           personal:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_init_salt_personal';
function crypto_generichash_blake2b_update(state:Pcrypto_generichash_blake2b_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_update';
function crypto_generichash_blake2b_final(state:Pcrypto_generichash_blake2b_state; output:pcuchar; outlen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_generichash_blake2b_final';

{ crypto_generichash }
function crypto_generichash_bytes_min:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_bytes_min';
function crypto_generichash_bytes_max:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_bytes_max';
function crypto_generichash_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_bytes';
function crypto_generichash_keybytes_min:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_keybytes_min';
function crypto_generichash_keybytes_max:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_keybytes_max';
function crypto_generichash_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_generichash_keybytes';
function crypto_generichash_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_generichash_primitive';
function crypto_generichash(output:pcuchar; outlen:size_t; input:pcuchar; inlen:culonglong; key:pcuchar;
           keylen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_generichash';
function crypto_generichash_init(state:Pcrypto_generichash_state; key:pcuchar; keylen:size_t; outlen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_generichash_init';
function crypto_generichash_update(state:Pcrypto_generichash_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_generichash_update';
function crypto_generichash_final(state:Pcrypto_generichash_state; output:pcuchar; outlen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_generichash_final';

{ crypto_pwhash_scryptsalsa208sha256 }
function crypto_pwhash_scryptsalsa208sha256_saltbytes:size_t;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_saltbytes';
function crypto_pwhash_scryptsalsa208sha256_strbytes:size_t;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_strbytes';
function crypto_pwhash_scryptsalsa208sha256_strprefix:pcchar;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_strprefix';
function crypto_pwhash_scryptsalsa208sha256_opslimit_interactive:size_t;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_opslimit_interactive';
function crypto_pwhash_scryptsalsa208sha256_memlimit_interactive:size_t;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_memlimit_interactive';
function crypto_pwhash_scryptsalsa208sha256_opslimit_sensitive:size_t;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_opslimit_sensitive';
function crypto_pwhash_scryptsalsa208sha256_memlimit_sensitive:size_t;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_memlimit_sensitive';
function crypto_pwhash_scryptsalsa208sha256(output:pcuchar; outlen:culonglong; passwd:pcchar; passwdlen:culonglong; salt:pcuchar;
           opslimit:culonglong; memlimit:size_t):cint;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256';
//function crypto_pwhash_scryptsalsa208sha256_str(output:array[0..(crypto_pwhash_scryptsalsa208sha256_STRBYTES)-1] of cchar; passwd:pcchar; passwdlen:culonglong; opslimit:culonglong; memlimit:size_t):cint;cdecl;external SODIUMLIB name 'crypto_pwhash_scr'
function crypto_pwhash_scryptsalsa208sha256_str(output:pcchar; passwd:pcchar;
           passwdlen:culonglong; opslimit:culonglong; memlimit:size_t):cint;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_str';
//function crypto_pwhash_scryptsalsa208sha256_str_verify(str:array[0..(crypto_pwhash_scryptsalsa208sha256_STRBYTES)-1] of cchar; passwd:pcchar; passwdlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_str_verify';
function crypto_pwhash_scryptsalsa208sha256_str_verify(str: pcchar; passwd:pcchar;
         passwdlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_str_verify';
function crypto_pwhash_scryptsalsa208sha256_ll(passwd:Puint8_t; passwdlen:size_t; salt:Puint8_t; saltlen:size_t; N:uint64_t;
           r:uint32_t; p:uint32_t; buf:Puint8_t; buflen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_pwhash_scryptsalsa208sha256_ll';

{ crypto_aead_chacha20poly1305 }
function crypto_aead_chacha20poly1305_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_aead_chacha20poly1305_keybytes';
function crypto_aead_chacha20poly1305_nsecbytes:size_t;cdecl;external SODIUMLIB name 'crypto_aead_chacha20poly1305_nsecbytes';
function crypto_aead_chacha20poly1305_npubbytes:size_t;cdecl;external SODIUMLIB name 'crypto_aead_chacha20poly1305_npubbytes';
function crypto_aead_chacha20poly1305_abytes:size_t;cdecl;external SODIUMLIB name 'crypto_aead_chacha20poly1305_abytes';
function crypto_aead_chacha20poly1305_encrypt(c:pcuchar; clen:pculonglong; m:pcuchar; mlen:culonglong; ad:pcuchar;
           adlen:culonglong; nsec:pcuchar; npub:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_aead_chacha20poly1305_encrypt';
function crypto_aead_chacha20poly1305_decrypt(m:pcuchar; mlen:pculonglong; nsec:pcuchar; c:pcuchar; clen:culonglong;
           ad:pcuchar; adlen:culonglong; npub:pcuchar; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_aead_chacha20poly1305_decrypt';

{ crypto_auth_hmacsha256 }
function crypto_auth_hmacsha256_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha256_bytes';
function crypto_auth_hmacsha256_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha256_keybytes';
function crypto_auth_hmacsha256(output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha256';
function crypto_auth_hmacsha256_verify(h:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha256_verify';
function crypto_auth_hmacsha256_init(state:Pcrypto_auth_hmacsha256_state; key:pcuchar; keylen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha256_init';
function crypto_auth_hmacsha256_update(state:Pcrypto_auth_hmacsha256_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha256_update';
function crypto_auth_hmacsha256_final(state:Pcrypto_auth_hmacsha256_state; output:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha256_final';

{ crypto_auth_hmacsha512 }
function crypto_auth_hmacsha512_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512_bytes';
function crypto_auth_hmacsha512_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512_keybytes';
function crypto_auth_hmacsha512(output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512';
function crypto_auth_hmacsha512_verify(h:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512_verify';
function crypto_auth_hmacsha512_init(state:Pcrypto_auth_hmacsha512_state; key:pcuchar; keylen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512_init';
function crypto_auth_hmacsha512_update(state:Pcrypto_auth_hmacsha512_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512_update';
function crypto_auth_hmacsha512_final(state:Pcrypto_auth_hmacsha512_state; output:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512_final';

{ crypto_auth_hmacsha512256 }
function crypto_auth_hmacsha512256_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512256_bytes';
function crypto_auth_hmacsha512256_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512256_keybytes';
function crypto_auth_hmacsha512256(output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512256';
function crypto_auth_hmacsha512256_verify(h:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512256_verify';
function crypto_auth_hmacsha512256_init(state:Pcrypto_auth_hmacsha512256_state; key:pcuchar; keylen:size_t):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512256_init';
function crypto_auth_hmacsha512256_update(state:Pcrypto_auth_hmacsha512256_state; input:pcuchar; inlen:culonglong):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512256_update';
function crypto_auth_hmacsha512256_final(state:Pcrypto_auth_hmacsha512256_state; output:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_hmacsha512256_final';

{ crypto_auth }
function crypto_auth_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_auth_bytes';
function crypto_auth_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_auth_keybytes';
function crypto_auth_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_auth_primitive';
function crypto_auth(output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth';
function crypto_auth_verify(h:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_auth_verify';

{ crypto_shorthash_siphash24 }
function crypto_shorthash_siphash24_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_shorthash_siphash24_bytes';
function crypto_shorthash_siphash24_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_shorthash_siphash24_keybytes';
function crypto_shorthash_siphash24(output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_shorthash_siphash24';

{ crypto_shorthash }
function crypto_shorthash_bytes:size_t;cdecl;external SODIUMLIB name 'crypto_shorthash_bytes';
function crypto_shorthash_keybytes:size_t;cdecl;external SODIUMLIB name 'crypto_shorthash_keybytes';
function crypto_shorthash_primitive:pcchar;cdecl;external SODIUMLIB name 'crypto_shorthash_primitive';
function crypto_shorthash(output:pcuchar; input:pcuchar; inlen:culonglong; k:pcuchar):cint;cdecl;external SODIUMLIB name 'crypto_shorthash';

implementation

function sodium_init:cint;cdecl;external SODIUMLIB name 'sodium_init';

initialization
  sodium_init;

end.
