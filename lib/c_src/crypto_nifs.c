#include <erl_nif.h>
#include <sodium.h>
#include <string.h>

#define FOR(i,n) for(i=0; i<n; ++i)
typedef unsigned char u8;
typedef unsigned long long int u64;
typedef unsigned int ui;

void Keccak(ui r, ui c, const u8 *in, u64 inLen, u8 sfx, u8 *out, u64 outLen);
void FIPS202_SHAKE128(const u8 *in, u64 inLen, u8 *out, u64 outLen) { Keccak(1344, 256, in, inLen, 0x1F, out, outLen); }
void FIPS202_SHAKE256(const u8 *in, u64 inLen, u8 *out, u64 outLen) { Keccak(1088, 512, in, inLen, 0x1F, out, outLen); }
void FIPS202_SHA3_224(const u8 *in, u64 inLen, u8 *out) { Keccak(1152, 448, in, inLen, 0x06, out, 28); }
void FIPS202_SHA3_256(const u8 *in, u64 inLen, u8 *out) { Keccak(1088, 512, in, inLen, 0x06, out, 32); }
void FIPS202_SHA3_384(const u8 *in, u64 inLen, u8 *out) { Keccak(832, 768, in, inLen, 0x06, out, 48); }
void FIPS202_SHA3_512(const u8 *in, u64 inLen, u8 *out) { Keccak(576, 1024, in, inLen, 0x06, out, 64); }

int LFSR86540(u8 *R) { (*R)=((*R)<<1)^(((*R)&0x80)?0x71:0); return ((*R)&2)>>1; }
#define ROL(a,o) ((((u64)a)<<o)^(((u64)a)>>(64-o)))
static u64 load64(const u8 *x) { ui i; u64 u=0; FOR(i,8) { u<<=8; u|=x[7-i]; } return u; }
static void store64(u8 *x, u64 u) { ui i; FOR(i,8) { x[i]=u; u>>=8; } }
static void xor64(u8 *x, u64 u) { ui i; FOR(i,8) { x[i]^=u; u>>=8; } }
#define rL(x,y) load64((u8*)s+8*(x+5*y))
#define wL(x,y,l) store64((u8*)s+8*(x+5*y),l)
#define XL(x,y,l) xor64((u8*)s+8*(x+5*y),l)
void KeccakF1600(void *s)
{
  ui r,x,y,i,j,Y; u8 R=0x01; u64 C[5],D;
  for(i=0; i<24; i++) {
    /*θ*/ FOR(x,5) C[x]=rL(x,0)^rL(x,1)^rL(x,2)^rL(x,3)^rL(x,4); FOR(x,5) { D=C[(x+4)%5]^ROL(C[(x+1)%5],1); FOR(y,5) XL(x,y,D); }
    /*ρπ*/ x=1; y=r=0; D=rL(x,y); FOR(j,24) { r+=j+1; Y=(2*x+3*y)%5; x=y; y=Y; C[0]=rL(x,y); wL(x,y,ROL(D,r%64)); D=C[0]; }
    /*χ*/ FOR(y,5) { FOR(x,5) C[x]=rL(x,y); FOR(x,5) wL(x,y,C[x]^((~C[(x+1)%5])&C[(x+2)%5])); }
    /*ι*/ FOR(j,7) if (LFSR86540(&R)) XL(0,0,(u64)1<<((1<<j)-1));
  }
}
void Keccak(ui r, ui c, const u8 *in, u64 inLen, u8 sfx, u8 *out, u64 outLen)
{
  /*initialize*/ u8 s[200]; ui R=r/8; ui i,b=0; FOR(i,200) s[i]=0;
  /*absorb*/ while(inLen>0) { b=(inLen<R)?inLen:R; FOR(i,b) s[i]^=in[i]; in+=b; inLen-=b; if (b==R) { KeccakF1600(s); b=0; } }
  /*pad*/ s[b]^=sfx; if((sfx&0x80)&&(b==(R-1))) KeccakF1600(s); s[R-1]^=0x80; KeccakF1600(s);
  /*squeeze*/ while(outLen>0) { b=(outLen<R)?outLen:R; FOR(i,b) out[i]=s[i]; out+=b; outLen-=b; if(outLen>0) KeccakF1600(s); }
}

static ERL_NIF_TERM gen_ed25519_keypair(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary pk_result_bin;
  ErlNifBinary sk_result_bin;
  ERL_NIF_TERM pk_result;
  ERL_NIF_TERM sk_result;
  
  unsigned char pk[crypto_sign_PUBLICKEYBYTES];
  unsigned char sk[crypto_sign_SECRETKEYBYTES];
  
  crypto_sign_keypair(pk, sk);

  pk_result_bin = (ErlNifBinary) {crypto_sign_PUBLICKEYBYTES, pk};
  sk_result_bin = (ErlNifBinary) {crypto_sign_SECRETKEYBYTES, sk};
  
  pk_result = enif_make_binary(env, &pk_result_bin);
  sk_result = enif_make_binary(env, &sk_result_bin);

  return enif_make_tuple2(env, pk_result, sk_result);
}

static ERL_NIF_TERM sign(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ERL_NIF_TERM ok_atom     = enif_make_atom(env, "ok");
  ERL_NIF_TERM error_atom  = enif_make_atom(env, "error");
  ERL_NIF_TERM badarg_atom = enif_make_atom(env, "badarg");

  ErlNifBinary sk_bin;
  ErlNifBinary message_bin;
  ErlNifBinary result_bin;
  ERL_NIF_TERM result;
  
  unsigned char sig[crypto_sign_BYTES];

  if (!enif_inspect_iolist_as_binary(env, argv[0], &message_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_atom);
  }

  if (!enif_inspect_iolist_as_binary(env, argv[1], &sk_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_atom);
  }

  crypto_sign_detached(sig, NULL, message_bin.data, message_bin.size, sk_bin.data);

  result_bin = (ErlNifBinary) {crypto_sign_BYTES, sig};
  result = enif_make_binary(env, &result_bin);

  return enif_make_tuple2(env, ok_atom, result);
}

static ERL_NIF_TERM verify(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ERL_NIF_TERM error_atom  = enif_make_atom(env, "error");
  ERL_NIF_TERM badarg_atom = enif_make_atom(env, "badarg");
  ERL_NIF_TERM true_atom = enif_make_atom(env, "__true__");
  ERL_NIF_TERM false_atom = enif_make_atom(env, "__false__");

  ErlNifBinary message_bin;
  ErlNifBinary sig_bin;
  ErlNifBinary pk_bin;
  
  if (!enif_inspect_iolist_as_binary(env, argv[0], &message_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_atom);
  }

  if (!enif_inspect_iolist_as_binary(env, argv[1], &sig_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_atom);
  }

  if (!enif_inspect_iolist_as_binary(env, argv[2], &pk_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_atom);
  }

  if (sig_bin.size != crypto_sign_BYTES) {
    return enif_make_tuple2(env, error_atom, badarg_atom);
  }

  if (crypto_sign_verify_detached(sig_bin.data, message_bin.data, message_bin.size, pk_bin.data) != 0) {
    return false_atom;
  }
  
  return true_atom;
}

static ERL_NIF_TERM sha3_hash256(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ERL_NIF_TERM ok_atom     = enif_make_atom(env, "ok");
  ERL_NIF_TERM error_atom  = enif_make_atom(env, "error");
  ERL_NIF_TERM badarg_atom = enif_make_atom(env, "badarg");

  ErlNifBinary arg_bin;
  ErlNifBinary result_bin;
  ERL_NIF_TERM result;

  unsigned char *hash = malloc(32);

  if (!enif_inspect_iolist_as_binary(env, argv[0], &arg_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_atom);
  }

  FIPS202_SHA3_256(arg_bin.data, arg_bin.size, hash);

  result_bin = (ErlNifBinary) {32, hash};
  result = enif_make_binary(env, &result_bin);

  return enif_make_tuple2(env, ok_atom, result);
}

static ERL_NIF_TERM gen_ed25519_public_key(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  unsigned char pk[crypto_sign_PUBLICKEYBYTES];
  
  ErlNifBinary sk_bin;
  ErlNifBinary result_bin;
  ERL_NIF_TERM pk_result;
  ERL_NIF_TERM ok_atom    = enif_make_atom(env, "ok");
  ERL_NIF_TERM error_atom = enif_make_atom(env, "error");
  ERL_NIF_TERM badarg_err = enif_make_string(env, "Invalid argument! The first arg must be a 64 byte binary!", ERL_NIF_LATIN1);
  ERL_NIF_TERM nacl_err   = enif_make_string(env, "Could not initialize libsodium!", ERL_NIF_LATIN1);
  ERL_NIF_TERM badkey_err = enif_make_string(env, "The given private key is invalid!", ERL_NIF_LATIN1);
  
  if (sodium_init() == -1) {
    return enif_make_tuple2(env, error_atom, nacl_err);
  }

  if (!enif_inspect_iolist_as_binary(env, argv[0], &sk_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_err);
  }

  if (crypto_sign_ed25519_sk_to_pk(pk, sk_bin.data) == -1) {
    return enif_make_tuple2(env, error_atom, badkey_err);
  }

  result_bin = (ErlNifBinary) {32, pk};
  pk_result = enif_make_binary(env, &result_bin);

  return enif_make_tuple2(env, ok_atom, pk_result);
}

static ErlNifFunc nif_funcs[] = {
  {"_gen_ed25519_keypair", 0, gen_ed25519_keypair},
  {"_sign", 2, sign},
  {"_verify", 3, verify},
  {"_gen_ed25519_public_key", 1, gen_ed25519_public_key},
  {"_sha3_hash256", 1, sha3_hash256}
};

static int load(ErlNifEnv *env, void **priv, ERL_NIF_TERM info) {
  return 0;
}

static void unload(ErlNifEnv *env, void *priv) {}

static int reload(ErlNifEnv *env, void **priv, ERL_NIF_TERM info) {
  return 0;
}

static int upgrade(ErlNifEnv *env, void **priv, void **old_priv, ERL_NIF_TERM info) {
  return load(env, priv, info);
}

ERL_NIF_INIT(Elixir.BigchaindbEx.Crypto, nif_funcs, &load, &reload, &upgrade, &unload)
