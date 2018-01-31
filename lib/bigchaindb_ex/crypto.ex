defmodule BigchaindbEx.Crypto do
  @moduledoc """
    This module provides cryptography utilities.
  """

  use Bitwise
  alias BigchaindbEx.{Base58, Utils}

  @on_load :load_nifs

  def load_nifs do
    :erlang.load_nif('./priv/crypto_nifs', 1)
  end

  @doc """
    Generates an ed25519 public key
    from a given private key.
  """
  @spec gen_ed25519_public_key(binary) :: {:ok, binary} | {:error, String.t}
  def gen_ed25519_public_key(binary) 
    when is_binary(binary) 
    and  byte_size(binary) == 64 
  do 
    _gen_ed25519_public_key(binary)
  end

  defp _gen_ed25519_public_key(_) do
    raise "NIF gen_ed25519_public_key/1 is not implemented!"
  end

  @doc """
    Hashes a given string with the 
    sha3 256bit algorithm.
  """
  @spec sha3_hash256(String.t, boolean) :: {:ok, binary} | {:error, String.t}
  def sha3_hash256(string, hex \\ true) 
    when is_binary(string) 
    and  is_boolean(hex)
  do
    case _sha3_hash256(string) do
      {:ok, result}    -> {:ok, (if hex, do: Hexate.encode(result), else: result)}
      {:error, reason} -> {:error, "Could not hash string: #{reason}"}
    end
  end

  defp _sha3_hash256(_) do
    raise "NIF sha3_hash256/1 is not implemented!"
  end

  @doc """
    Generates a public and private key pair.

    ## Example
      iex> {pub_key, priv_key} = BigchaindbEx.Crypto.generate_key_pair()
  """
  @spec generate_keypair :: {String.t, String.t}
  def generate_keypair do
    {pub, priv} = _gen_ed25519_keypair()
    {encode_base58(pub), encode_base58(priv)}
  end

  defp _gen_ed25519_keypair do
    raise "NIF _gen_ed25519_keypair/0 is not implemented!"
  end

  @doc """
    Generates a public key from a 
    given private key.
  """
  @spec generate_pub_key(binary) :: {:ok, binary} | {:error, String.t}
  def generate_pub_key(priv_key) when is_binary(priv_key) do
    with {:ok, decoded} <- decode_base58(priv_key),
         {:ok, pk_bin}  <- gen_ed25519_public_key(decoded)
    do
      {:ok, encode_base58(pk_bin)}
    else
      _ -> {:error, "Could not decode the given private key!"}
    end
  end

  @doc """
    Creates a signature based 
    on a given message and a private key.
  """
  @spec sign(String.t, binary) :: {:ok, binary} | {:error, String.t}
  def sign(message, priv_key) 
    when is_binary(message) 
    and  is_binary(priv_key)
  do
    with {:ok, priv_key}  <- decode_base58(priv_key),
         {:ok, signature} <- _sign(message, priv_key) 
    do
      {:ok, encode_base58(signature)}
    end
  end

  defp _sign(_, _) do
    raise "NIF _sign/2 is not implemented!"
  end

  @doc """
    Verifies a signature
    based on the given message
    and public key.
  """
  @spec verify(String.t, String.t, String.t) :: boolean | {:error, Atom.t}
  def verify(message, signature, pub_key) 
    when is_binary(message) 
    and  is_binary(signature) 
    and  is_binary(pub_key) 
  do
    with {:ok, pub_key}   <- decode_base58(pub_key),
         {:ok, signature} <- decode_base58(signature)
    do
      case _verify(message, signature, pub_key) do
        :__true__         -> true
        :__false__        -> false
        {:error, reason}  -> {:error, reason} 
      end
    else
      _ -> raise "Could not decode public key!"
    end
  end

  defp _verify(_, _, _) do
    raise "NIF _verify/2 is not implemented!"
  end

  @doc """
    Encodes a binary to a 
    base58 encoded string.
  """
  @spec encode_base58(binary) :: String.t
  def encode_base58(_, padding_required \\ 0)
  def encode_base58(<<0, tail :: binary>>, padding_required) when is_integer(padding_required) do
    encode_base58(tail, padding_required + 1)
  end
  def encode_base58(str, padding_required) 
    when is_binary(str) 
    and  is_integer(padding_required)
  do
    result = str
    |> String.reverse
    |> encode_base58_parse_str
    |> Base58.encode_int

    if padding_required > 0 do
      Enum.reduce(0..padding_required, result, fn (_, acc) -> "1" <> acc end)
    else
      result
    end
  end

  defp encode_base58_parse_str(_, p \\ 1, acc \\ 0)
  defp encode_base58_parse_str(<<head :: binary-size(1), tail :: binary>>, p, acc) do
    <<c>> = head
    encode_base58_parse_str(tail, p <<< 8, acc + p * c)
  end
  defp encode_base58_parse_str(<<>>, _, acc), do: acc

  @doc """
    Decodes a base58 encoded string.
  """
  @spec decode_base58(String.t) :: {:ok, binary} | {:error, RuntimeError.t}
  def decode_base58(str) when is_binary(str) do
    {result, padding} = decode_base58_remove_padding(str)
    decoded = result
    |> Base58.decode
    |> do_decode_base58
    
    if padding > 0 do
      padded_result = Enum.reduce(0..padding, decoded, fn (_, acc) -> <<0, acc :: binary>> end)
      {:ok, padded_result}
    else
      {:ok, decoded}
    end
  rescue
    e in RuntimeError -> {:error, e}
  end

  defp do_decode_base58(_, acc \\ <<>>)
  defp do_decode_base58(0, acc), do: acc
  defp do_decode_base58(num, acc) 
    when is_number(num) 
    and  is_binary(acc)
  do 
    {div, mod} = Utils.divmod(num, 256)
    do_decode_base58(div, <<mod, acc :: binary>>)
  end

  defp decode_base58_remove_padding(_, padding \\ 0)
  defp decode_base58_remove_padding("1" <> str, padding) do
    decode_base58_remove_padding(str, padding + 1)    
  end
  defp decode_base58_remove_padding(result, padding) do
    {result, padding}
  end
end