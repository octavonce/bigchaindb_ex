defmodule BigchaindbEx.Condition.Ed25519Sha256 do
  alias BigchaindbEx.Crypto
  alias BigchaindbEx.Fulfillment

  @type t :: %__MODULE__{
    cost: Integer.t,
    type_id: Integer.t,
    hash: binary
  }

  defstruct [
    :cost,
    :type_id,
    :hash
  ]

  @id 4
  @type_name "ed25519-sha-256"
  @asn1 "ed25519Sha256"
  @asn1_condition "ed25519Sha256Condition"
  @asn1_fulfillment "ed25519Sha256Fulfillment"
  @category "simple"

  @constant_cost 131072
  @public_key_length 32
  @signature_length 64

  def type_id,               do: @id
  def type_name,             do: @type_name
  def type_asn1,             do: @asn1
  def type_asn1_condition,   do: @asn1_condition
  def type_asn1_fulfillment, do: @asn1_fulfillment
  def type_category,         do: @category
  def type_cost,             do: @constant_cost
  def type_pub_key_length,   do: @public_key_length
  def type_signature_length, do: @signature_length 

  @doc """
    Derives the condition
    from a given fulfillment.
  """
  @spec from_fulfillment(Fulfillment.Ed25519Sha512.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def from_fulfillment(%Fulfillment.Ed25519Sha512{public_key: pub_key} = ffl) when is_binary(pub_key) do
    case generate_hash(pub_key) do
      {:ok, hash} -> {:ok, %__MODULE__{
        cost: @constant_cost,
        type_id: @id,
        hash: hash
      }}
      {:error, reason} -> {:error, "Could not derive condition: #{inspect reason}"}
    end
  end
  def from_fulfillment(_), do: {:error, "The given fulfillment is invalid!"}
  
  @doc """
    Generates a hash from a 
    given public key and the 
    condition's fingerprint contents.
  """
  @spec generate_hash(String.t) :: {:ok, binary} | {:error, String.t}
  def generate_hash(public_key) when is_binary(public_key) do
    with {:ok, decoded} <- Crypto.decode_base58(public_key),
         {:ok, asn1_binary} <- :Fingerprints.encode(:Ed25519FingerprintContents, {nil, decoded})
    do
      {:ok, :crypto.hash(:sha256, asn1_binary)}
    else
      {:error, reason} -> {:error, "Could not decode public key: #{inspect reason}"}
    end
  end

  @doc """
    Serializes a given hash
    to an url-friendly format.
  """
  @spec serialize_to_uri(bitstring) :: binary
  def serialize_to_uri(hash) when is_bitstring(hash) do
    "ni:///sha-256;" <> Base.encode64(hash) <> "?fpt=" <> @type_name <> "&cost=" <> to_string(@constant_cost)
  end
end