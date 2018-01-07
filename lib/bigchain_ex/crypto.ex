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
  @spec generate_pub_key(binary) :: {:ok, binary} | {:error, String.t}
  def generate_pub_key(priv_key) when is_binary(priv_key) do
    case decode_base58(priv_key) do
      {:ok, key} ->
        {pub, _} = :crypto.generate_key(:ecdh, :secp256k1, key)
        {:ok, encode_base58(pub)}
      _ -> {:error, "Could not decode the given private key!"}
    end
  end

  @doc """
    Creates a signature based 
    on a given message and a private key.
  """
  @spec sign(String.t, Enum.t) :: {:ok, binary} | {:error, String.t}
  def sign(message, priv_key) when is_binary(message) and is_binary(priv_key) do
    case decode_base58(priv_key) do
      {:ok, key} -> {:ok, :crypto.sign(:ecdsa, :sha256, message, [key, :secp256k1])}
      _          -> {:error, "Could not decode private key!"}
    end
  end

  @doc """
    Verifies a signature
    based on the given message
    and public key.
  """
  @spec verify(String.t, String.t, String.t) :: boolean 
  def verify(message, signature, pub_key) 
    when is_binary(message) 
    and  is_binary(signature) 
    and  is_binary(pub_key) 
  do
    case decode_base58(pub_key) do
      {:ok, decoded} -> :crypto.verify(:ecdsa, :sha256, message, signature, [decoded, :secp256k1])
      _              -> raise "Could not decode public key!"
    end
  end

  @doc """
    Encodes a binary to a 
    base58 encoded string.
  """
  @spec encode_base58(binary) :: String.t
  def encode_base58(str) when is_binary(str) or is_bitstring(str) do
    hex_str = Hexate.encode(str)
    {int, o} = Integer.parse(hex_str, 16)
    Base58.encode(int)
  end

  @doc """
    Decodes a base58 encoded string
  """
  @spec decode_base58(String.t) :: {:ok, binary} | {:error, RuntimeError.t}
  def decode_base58(str) when is_binary(str) do
    require Integer

    decoded = str
    |> Base58.decode
    |> Integer.to_string(16)
    |> (fn x -> (if x |> String.length |> Integer.is_odd, do: "0#{x}", else: x) end).()
    |> Hexate.decode

    {:ok, decoded}
  rescue
    e in RuntimeError -> {:error, e}
  end
end