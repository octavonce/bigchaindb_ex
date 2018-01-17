defmodule BigchaindbEx.Fulfillment.Ed25519Sha512 do
  alias BigchaindbEx.Crypto

  @type t :: %__MODULE__{
    public_key: String.t,
    signature: String.t
  }

  defstruct [
    :public_key,
    :signature
  ]

  @doc """
    Converts a json string to
    an ed25519Sha512 fulfillment 
    struct.
  """
  @spec from_json(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def from_json(json) when is_binary(json) do
    with {:ok, decoded}           <- Poison.decode(json),
         {:ok, decoded_pub_key}   <- Base.decode64(decoded["public_key"]),
         {:ok, decoded_signature} <- Base.decode64(decoded["signature"]) 
    do
      %__MODULE__{
        public_key: decoded_pub_key,
        signature: decoded_signature
      }
    else
      {:error, reason} -> {:error, "Could not decode the given json string: #{inspect reason}"}
      _                -> {:error, "Could not decode the public key or signature from the given json."}
    end
  end

  @doc """
    Serializes the given fulfillment
    struct to a url-safe URI.
  """
  @spec serialize_uri(__MODULE__.t) :: {:ok, String.t} | {:error, String.t}
  def serialize_uri(%__MODULE__{} = ffl) do
    case to_asn1(ffl) do
      {:ok, bin}       -> {:ok, Base.encode64(bin, padding: false)}
      {:error, reason} -> {:error, "There was an error converting the fulfillment struct to asn1: #{inspect reason}"}
    end
  end

  @doc """
    Converts a serialized uri
    to a fulfillment struct.
  """
  @spec from_uri(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def from_uri(uri) when is_binary(uri) do
    with {:ok, decoded} <- Base.decode64(uri, padding: false),
         {:ok, struct}  <- from_asn1(decoded)
    do
      {:ok, struct}
    else
      {:error, reason} -> {:error, "Could not decode uri: #{inspect reason}"}
    end
  end

  @doc """
    Encodes a given public key and 
    a signature to the asn1 binary
    format.
  """
  @spec to_asn1(%{public_key: String.t, signature: String.t}) :: {:ok, binary} | {:error, String.t}
  def to_asn1(%__MODULE__{} = %{public_key: public_key, signature: signature}) when is_binary(public_key) and is_binary(signature) do
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
  @spec from_asn1(bitstring) :: {:ok, %__MODULE__{}} | {:error, String.t}
  def from_asn1(bytes) when is_bitstring(bytes) do
    case :Fulfillments.decode(:Ed25519Sha512Fulfillment, bytes) do
      {:ok, {_, pub_key, signature}} -> {:ok, %__MODULE__{public_key: Crypto.encode_base58(pub_key), signature: Crypto.encode_base58(signature)}}
      {:error, reason} -> {:error, "Could not decode fulfillment: #{inspect reason}"}
    end
  end
end