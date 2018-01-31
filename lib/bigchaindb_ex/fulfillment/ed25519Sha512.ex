defmodule BigchaindbEx.Fulfillment.Ed25519Sha512 do
  alias BigchaindbEx.Crypto

  @type t :: %__MODULE__{
    public_key: binary,
    signature: binary
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
    with {:ok, %{"public_key" => pub_key, "signature" => sig}}  <- Poison.decode(json),
         {:ok, decoded_pub_key}   <- Base.url_decode64(pub_key, padding: false),
         {:ok, decoded_signature} <- Base.url_decode64(sig, padding: false) 
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
      {:ok, bin}       -> {:ok, Base.url_encode64(bin, padding: false)}
      {:error, reason} -> {:error, "There was an error converting the fulfillment struct to asn1: #{inspect reason}"}
    end
  end

  @doc """
    Converts a serialized uri
    to a fulfillment struct.
  """
  @spec from_uri(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def from_uri(uri) when is_binary(uri) do
    with {:ok, decoded} <- Base.url_decode64(uri, padding: false),
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
  @spec to_asn1(%{public_key: binary, signature: binary}) :: {:ok, binary} | {:error, String.t}
  def to_asn1(%__MODULE__{} = %{public_key: public_key, signature: signature}) 
    when is_binary(public_key) 
    and  is_binary(signature) 
  do
    if byte_size(public_key) === 32 and byte_size(signature) === 64 do
      :Fulfillments.encode(:Ed25519Sha512Fulfillment, {:Ed25519Sha512Fulfillment, public_key, signature})
    else
      {:error, "Invalid public key or signature length! The public key must have 32 bytes and the signature must have 64 bytes!"}
    end
  end

  @doc """
    Decodes an asn1 encoded binary
    to it's base58 representation.
  """
  @spec from_asn1(binary) :: {:ok, %__MODULE__{}} | {:error, String.t}
  def from_asn1(bytes) when is_binary(bytes) do
    case :Fulfillments.decode(:Ed25519Sha512Fulfillment, bytes) do
      {:ok, {_, pub_key, signature}} -> {:ok, %__MODULE__{public_key: pub_key, signature: signature}}
      {:error, reason} -> {:error, "Could not decode fulfillment: #{inspect reason}"}
    end
  end
end