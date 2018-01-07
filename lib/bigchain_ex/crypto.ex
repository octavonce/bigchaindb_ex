defmodule BigchainEx.Crypto do
  @moduledoc """
    This module provides cryptography utilities.
  """

  alias BigchainEx.Base58

  @doc """
    Generates a public and private key pair.

    ## Example
      iex> BigchainEx.Crypto.generate_key_pair()
      
      {"Nb7NxsJVntGK8RkbFqeDZ6ZrbNFuetXofQEYPtSku3RnXSzC2HWH2PjH3jPAD7DnHAsYWRiP85CUcmfxrmTQdR22",
      "6F18nEJLGKuh3ctSnT62KSmfs9xEJR1B8iEqJxSwNqq3"}
  """
  @spec generate_keypair :: {String.t, String.t}
  def generate_keypair do
    {pub, priv} = :crypto.generate_key(:ecdh, :secp256k1)
    {encode_base58(pub), encode_base58(priv)}
  end

  @doc """
    Generates a public key from a 
    given private key.
  """
  @spec generate_pub_key(String.t) :: {:ok, String.t} | {:error, String.t}
  def generate_pub_key(priv_key) do
    case decode_base58(priv_key) do
      {:ok, key} ->
        {pub, _} = :crypto.generate_key(:ecdh, :secp256k1, key)
        {:ok, encode_base58(pub)}
      _ -> {:error, "Could not decode the given private key!"}
    end
  end

  @doc """
    Encodes a binary to a 
    base58 encoded string.
  """
  @spec encode_base58(binary) :: String.t
  def encode_base58(str) when is_binary(str) or is_bitstring(str) do
    hex_str = Base.encode16(str)
    {int, _} = Integer.parse(hex_str, 16)
    Base58.encode(int)
  end

  @doc """
    Decodes a base58 encoded string
  """
  @spec decode_base58(String.t) :: {:ok, binary} | :error
  def decode_base58(str) when is_binary(str) do
    str
    |> Base58.decode
    |> Integer.to_string(16) 
    |> Base.decode16
  end
end