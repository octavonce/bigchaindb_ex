defmodule BigchainEx.Fulfillment.Ed25519Sha512 do
  alias BigchainEx.Crypto

  @doc """
    Encodes a given public key and 
    a signature to the asn.1 binary
    format.
  """
  @spec asn1_encode(%{public_key: String.t, signature: String.t}) :: {:ok, binary} | {:error, String.t}
  def asn1_encode(%{public_key: pub_key, signature: sig}) when is_binary(pub_key) and is_binary(sig) do
    with {:ok, pub_key} <- Crypto.decode_base58(pub_key),
         {:ok, sig}     <- Crypto.decode_base58(sig)
    do
      :CryptoConditions.encode(:Ed25519Sha512Fulfillment, {nil, pub_key, sig})
    else
      {:error, reason} -> {:error, "Could not decode public key or signature: #{inspect reason}"}
    end
  end
end