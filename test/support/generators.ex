defmodule BigchaindbEx.Generators do
  alias BigchaindbEx.{Crypto, Utils}
  alias BigchaindbEx.Transaction.Output
  alias BigchaindbEx.Fulfillment.Ed25519Sha512
  alias BigchaindbEx.Condition.Ed25519Sha256

  def gen_hash do
    # TODO: Generate random hash from all types
    {pub_key, _} = keypair()
    {:ok, hash} = Ed25519Sha256.generate_hash(pub_key)
    hash
  end

  def gen_uri, do: gen_uri(gen_hash())
  def gen_uri(hash) when is_bitstring(hash) do
    # TODO: Generate random uri from all types
    Ed25519Sha256.hash_to_uri(hash)
  end

  def gen_fulfillment do
    {pub_key, priv_key} = keypair()
    {:ok, sig} = Crypto.sign("Hello world", priv_key)

    %Ed25519Sha512{
      public_key: pub_key,
      signature: sig
    }
  end

  def gen_public_keys, do: gen_public_keys(Enum.random(1..1000))
  def gen_public_keys(count) when is_integer(count) and count > 0 do
    Utils.parallel_map(0..count, fn _ -> {pub_key, _} = keypair(); pub_key end) 
  end

  def gen_output do
    {pub_key, priv_key} = keypair()
    {:ok, sig} = Crypto.sign("Hello world", priv_key)
    Output.generate(pub_key, Enum.random(1..10000000), sig)
  end

  def random_string(length \\ Enum.random(1..64)) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  def keypair, do: Crypto.generate_keypair
end