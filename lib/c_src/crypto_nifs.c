#include <erl_nif.h>
#include <sodium.h>
#include <string.h>
#include "sha3.h"

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

  sha3_context c;
  unsigned char *hash;

  if (!enif_inspect_iolist_as_binary(env, argv[0], &arg_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_atom);
  }

  sha3_Init256(&c);
  sha3_Update(&c, arg_bin.data, arg_bin.size);

  hash = (unsigned char *)sha3_Finalize(&c);

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
