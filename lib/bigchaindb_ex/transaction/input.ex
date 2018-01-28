defmodule BigchaindbEx.Transaction.Input do
  @moduledoc """
    Represents a transaction input.
  """

  alias BigchaindbEx.{Fulfillment, Transaction}
  alias BigchaindbEx.Transaction.Output

  @type t :: %__MODULE__{
    fulfillment: Fulfillment.t,
    owners_before: Enum.t,
    fulfills: Transaction.t
  }

  @enforce_keys [:fulfillment, :owners_before, :fulfills]

  defstruct [
    :fulfillment,
    :owners_before,
    :fulfills
  ]

  @doc """
    Creates a new input struct.
  """
  def new(ffl, owner_before, fulfills) when is_binary(owner_before), do: new(ffl, [owner_before], fulfills)
  def new(fulfillment, owners_before, fulfills \\ nil) 
    when is_map(fulfillment)
    and  is_list(owners_before)
    and  is_binary(fulfills)
    or   is_nil(fulfills)
  do
    %__MODULE__{
      fulfillment: fulfillment,
      owners_before: owners_before,
      fulfills: fulfills
    }
  end

  @doc """
    Generates an input struct
    from the given public keys.
  """
  @spec generate(Enum.t, String.t) :: __MODULE__.t
  def generate(pub_key, signature) when is_binary(pub_key) and is_binary(signature), do: generate([pub_key], signature)
  def generate(public_keys, signature) 
    when is_list(public_keys) 
    and  is_binary(signature) 
  do
    output = Output.generate(public_keys, 1, signature)
    new(output.fulfillment, public_keys)
  end

  @doc """
    Converts an input struct
    to a serialized map.
  """
  def to_map(%__MODULE__{} = input) do
    case Fulfillment.serialize_uri(input.fulfillment) do
      {:ok, uri} ->
        {:ok, %{
          owners_before: input.owners_before,
          fulfills: input.fulfills,
          fulfillment: uri
        }}
      {:error, reason} -> {:error, "There was an error converting the input struct: #{inspect reason}"}
    end
  end
end