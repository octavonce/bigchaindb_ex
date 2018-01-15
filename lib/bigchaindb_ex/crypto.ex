defmodule BigchaindbEx.Crypto do
  @moduledoc """
    This module provides cryptography utilities.
  """

  require Integer
  alias BigchaindbEx.Base58

  @doc """
    Generates a public and private key pair.

    ## Example
      iex> {pub_key, priv_key} = BigchaindbEx.Crypto.generate_key_pair()
  """
  @spec generate_keypair :: {String.t, String.t}
  def generate_keypair do
    %{public: pub, secret: priv} = :enacl.crypto_sign_ed25519_keypair
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
        result = key
        |> :enacl.crypto_sign_ed25519_secret_to_curve25519
        |> :enacl_ext.curve25519_public_key
        |> encode_base58

        {:ok, result}
      _ -> {:error, "Could not decode the given private key!"}
    end
  end

  @doc """
    Creates a signature based 
    on a given message and a private key.
  """
  @spec sign(String.t, binary) :: {:ok, binary} | {:error, String.t}
  def sign(message, priv_key) when is_binary(message) and is_binary(priv_key) do
    case decode_base58(priv_key) do
      {:ok, key} -> {:ok, :enacl.sign_detached(message, key) |> encode_base58}
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
    with {:ok, pub_key}   <- decode_base58(pub_key),
         {:ok, signature} <- decode_base58(signature)
    do
      case :enacl.sign_verify_detached(signature, message, pub_key) do
        {:ok, _}    -> true
        {:error, _} -> false
      end
    else
      _ -> raise "Could not decode public key!"
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
    Decodes a base58 encoded string.
  """
  @spec decode_base58(String.t) :: {:ok, binary} | {:error, RuntimeError.t}
  def decode_base58(str) when is_binary(str) do
    decoded = str
    |> Base58.decode
    |> Integer.to_string(16)
    |> (fn x -> (if String.length(x) |> Integer.is_odd, do: "0#{x}", else: x) end).()
    |> Hexate.decode

    {:ok, decoded}
  rescue
    e in RuntimeError -> {:error, e}
  end
 
  @doc """
    Adds padding to a hex string.
  """
  def add_base64_padding(string) when is_binary(string) do
    missing_padding = (4 - byte_size(string)) |> rem(4)  

    if missing_padding > 0 do
      Enum.reduce(0..missing_padding, string, fn (_, acc) -> acc <> "=" end)
    else
      string
    end
  end

  @doc """
    Removes the padding from 
    a given hex string.
  """
  @spec remove_base64_padding(String.t) :: String.t 
  def remove_base64_padding(string) when is_binary(string) do
    String.replace(string, "=", "")
  end
end