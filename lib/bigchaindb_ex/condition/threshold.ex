defmodule BigchaindbEx.Condition.ThresholdSha256 do
  @moduledoc """
    THRESHOLD-SHA-256: Threshold gate condition using SHA-256.

    Threshold conditions can be used to create m-of-n multi-signature groups.
    
    Threshold conditions can represent the AND operator by setting the threshold
    to equal the number of subconditions (n-of-n) or the OR operator by setting the thresold to one (1-of-n).
    
    Threshold conditions allows each subcondition to carry an integer weight.

    Since threshold conditions operate on conditions, they can be nested as well
    which allows the creation of deep threshold trees of public keys.

    By using Merkle trees, threshold fulfillments do not need to to provide the
    structure of unfulfilled subtrees. That means only the public keys that are
    actually used in a fulfillment, will actually appear in the fulfillment, saving space.
    
    One way to formally interpret threshold conditions is as a boolean weighted
    threshold gate. A tree of threshold conditions forms a boolean weighted
    threshold circuit.

    THRESHOLD-SHA-256 is assigned the type ID 2. It relies on the SHA-256 and
    THRESHOLD feature suites which corresponds to a feature bitmask of 0x09.
    
    Threshold determines the weighted threshold that is used to consider this condition
    fulfilled. If the added weight of all valid subfulfillments is greater or
    equal to this number, the threshold condition is considered to be fulfilled.
  """

  alias BigchaindbEx.{Fulfillment, Condition}

  @type t :: %__MODULE__{
    threshold: Integer.t,
    subconditions: Enum.t
  }

  @enforce_keys [:threshold, :subconditions]
  
  defstruct [
    :threshold, 
    :subconditions
  ]
  
  @type_id 2
  @type_name "threshold-sha-256"
  @asn1 "thresholdSha256"
  @asn1_condition "thresholdSha256Condition"
  @asn1_fulfillment "thresholdSha256Fulfillment"
  @category "compound"

  def type_id,               do: @type_id
  def type_name,             do: @type_name
  def type_asn1,             do: @asn1
  def type_asn1_condition,   do: @asn1_condition
  def type_asn1_fulfillment, do: @asn1_fulfillment
  def type_category,         do: @category

  @doc """
    Adds the given subcondition
    to the threshold struct.
  """
  @spec add_subcondition(__MODULE__.t, String.t | Condition.t) :: {:ok, __MODULE__.t} :: {:error, String.t}
  def add_subcondition(%__MODULE__{} = condition, subcondition) when is_binary(subcondition) do
    case Condition.from_uri(subcondition) do
      {:ok, subcondition} -> add_subcondition(condition, subcondition)
      {:error, reason}    -> {:error, "Could not parse subcondition uri: #{inspect reason}"}
    end
  end
  def add_subcondition(%__MODULE__{} = condition, subcondition) do
    {:ok, Map.merge(condition, %{subconditions: Enum.concat(condition.subconditions, [subcondition])})}
  end

  @doc """
    Derives the given fulfillment's
    condition and adds that to the
    struct's subconditions.
  """
  @spec add_subfulfillment(__MODULE__.t, String.t | Fulfillment.t) :: {:ok, __MODULE__.t} :: {:error, String.t}
  def add_subfulfillment(%__MODULE__{} = condition, fulfillment) do
    case Condition.from_fulfillment(fulfillment) do
      {:ok, subcondition} -> add_subfulfillment(condition, subcondition)
      {:error, reason}    -> {:error, "Could not add subfulfillment: #{inspect reason}"}
    end
  end
end