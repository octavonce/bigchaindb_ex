#include <erl_nif.h>
#include <sodium.h>
#include <string.h>

static ERL_NIF_TERM gen_ed25519_public_key(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  unsigned char pk[crypto_sign_PUBLICKEYBYTES];
  unsigned char sk[crypto_sign_SECRETKEYBYTES];
  
  ErlNifBinary sk_bin;
  ERL_NIF_TERM pk_result;
  ERL_NIF_TERM ok_atom     = enif_make_atom(env, "ok");
  ERL_NIF_TERM error_atom  = enif_make_atom(env, "error");
  ERL_NIF_TERM badarg_err  = enif_make_string(env, "Invalid argument! The first arg must be a 64 byte binary!", ERL_NIF_LATIN1);
  ERL_NIF_TERM nacl_err    = enif_make_string(env, "Could not initialize libsodium!", ERL_NIF_LATIN1);
  ERL_NIF_TERM badkey_err  = enif_make_string(env, "The given private key is invalid!", ERL_NIF_LATIN1);
  ERL_NIF_TERM decode_err  = enif_make_string(env, "Could not decode public key!", ERL_NIF_LATIN1);

  if (sodium_init() == -1) {
    return enif_make_tuple2(env, error_atom, nacl_err);
  }

  if (!enif_inspect_iolist_as_binary(env, argv[0], &sk_bin)) {
    return enif_make_tuple2(env, error_atom, badarg_err);
  }

  if (strlen((char *)sk_bin.data) != 64) {
    return enif_make_tuple2(env, error_atom, badarg_err);
  }

  if (crypto_sign_seed_keypair(pk, sk, sk_bin.data) == -1) {
    return enif_make_tuple2(env, error_atom, badkey_err);
  };

  if (enif_binary_to_term(env, pk, 64, &pk_result, ERL_NIF_BIN2TERM_SAFE)) {
    return enif_make_tuple2(env, error_atom, decode_err);
  };

  free(pk);
  free(sk);

  return enif_make_tuple2(env, ok_atom, pk_result);
}

static ErlNifFunc nif_funcs[] = {
  {"gen_ed25519_public_key", 1, gen_ed25519_public_key}
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
