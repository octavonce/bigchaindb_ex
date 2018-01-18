defmodule BigchaindbEx.Condition.Ed25519Sha256 do
  @moduledoc """
    ED25519: Ed25519 signature condition.

    This condition implements Ed25519 signatures.
    
    ED25519 is assigned the type ID 4. It relies only on the ED25519 feature suite
    which corresponds to a bitmask of 0x20.
  """

  alias BigchaindbEx.{Crypto, Fulfillment, Condition}

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

  @type_id 4
  @type_name "ed25519-sha-256"
  @asn1 "ed25519Sha256"
  @asn1_condition "ed25519Sha256Condition"
  @asn1_fulfillment "ed25519Sha256Fulfillment"
  @category "simple"

  @constant_cost 131072
  @public_key_length 32
  @signature_length 64

  def type_id,               do: @type_id
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
        type_id: @type_id,
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
    Derives a condition from
    an encoded uri.
  """
  @spec from_uri(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def from_uri(uri) when is_binary(uri) do
    with {:ok, hash} <- Condition.decode_hash_from_uri(uri),
         {:ok, type} <- Condition.decode_type_from_uri(uri)
    do
      cond_type = @type_name

      case type do
        ^cond_type -> 
          {:ok, %__MODULE__{
            cost: @constant_cost,
            type_id: @type_id,
            hash: hash
          }}
        _ -> {:error, "Could not decode uri: Type mismatch"}
      end
    else
      {:error, reason} -> {:error, "Could not decode uri: #{inspect uri}"}
    end
  end

  @doc """
    Serializes a given hash
    to an url-friendly format.
  """
  @spec hash_to_uri(bitstring) :: String.t
  def hash_to_uri(hash) when is_bitstring(hash) do
    "ni:///sha-256;" <> Base.encode64(hash) <> "?fpt=" <> @type_name <> "&cost=" <> to_string(@constant_cost)
  end
end