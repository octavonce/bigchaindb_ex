defmodule BigchaindbEx.Fulfillment.Ed25519Sha512 do
  alias BigchaindbEx.Crypto

  @doc """
    Encodes a given public key and 
    a signature to the asn1 binary
    format.
  """
  @spec asn1_encode(%{public_key: String.t, signature: String.t}) :: {:ok, binary} | {:error, String.t}
  def asn1_encode(%{public_key: public_key, signature: signature}) when is_binary(public_key) and is_binary(signature) do
    with {:ok, pub_key} <- Crypto.decode_base58(public_key),
          {:ok, sig}     <- Crypto.decode_base58(signature)
    do
      if byte_size(pub_key) === 32 and byte_size(sig) === 64 do
        :Fulfillments.encode(:Ed25519Sha512Fulfillment, {:Ed25519Sha512Fulfillment, pub_key, sig})
      else
        {:error, "Invalid public key or signature length! The public key must have 32 bytes and the signature must have 64 bytes!"}
      end
    else
      {:error, reason} -> {:error, "Could not decode public key or signature: #{inspect reason}"}
    end
  end

  @doc """
    Decodes an asn1 encoded binary
    to it's base58 representation.
  """
  @spec asn1_decode(bitstring) :: {:ok, String.t} | {:error, String.t}
  def asn1_decode(bytes) when is_bitstring(bytes) do
    case :Fulfillments.decode(:Ed25519Sha512Fulfillment, bytes) do
      {:ok, result}    -> {:ok, Crypto.encode_base58(result)}
      {:error, reason} -> {:error, "Could not decode fulfillment: #{inspect reason}"}
    end
  end
end