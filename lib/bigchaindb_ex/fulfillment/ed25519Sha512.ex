defmodule BigchaindbEx.Fulfillment.Ed25519Sha512 do
  alias BigchaindbEx.Crypto

  @doc """
    Encodes a given public key and 
    a signature to the asn1 binary
    format.
  """
  @spec asn1_encode(%{public_key: String.t, signature: String.t}) :: {:ok, binary} | {:error, String.t}
  def asn1_encode(%{public_key: pub_key, signature: sig}) when is_binary(pub_key) and is_binary(sig) do
    with {:ok, pub_key} <- Crypto.decode_base58(pub_key),
         {:ok, sig}     <- Crypto.decode_base58(sig)
    do
      :Fulfillments.encode(:Ed25519Sha512Fulfillment, {nil, pub_key, sig})
    else
      {:error, reason} -> {:error, "Could not decode public key or signature: #{inspect reason}"}
    end
  end

  @doc """
    Decodes an asn1 encoded binary
    to it's base58 representation.
  """
  @spec asn1_decode(binary) :: {:ok, String.t} | {:error, String.t}
  def asn1_decode(binary) when is_bitstring(binary) do
    case :Fulfillments.decode(:Ed25519Sha512Fulfillment, binary) do
      {:ok, result}    -> {:ok, Crypto.encode_base58(result)}
      {:error, reason} -> {:error, "Could not decode fulfillment: #{inspect reason}"}
    end
  end
end