defmodule BigchaindbEx.Transaction.Output do
  @moduledoc """
    Represents a transaction output.
  """

  alias BigchaindbEx.{Fulfillment, Crypto}
  alias BigchaindbEx.Fulfillment.Ed25519Sha512

  @max_amount :math.pow(9 * 10, 18)
  @enforce_keys [:amount, :public_keys, :fulfillment]

  @type t :: %__MODULE__{
    amount: Integer.t,
    public_keys: Enum.t,
    fulfillment: Ed25519Sha512.t
  }

  defstruct [
    :amount,
    :public_keys,
    :fulfillment
  ]

  defmacro amount_is_valid(amount) do
    quote do
      is_integer(unquote(amount)) and unquote(amount) > 0 and unquote(amount) <= @max_amount
    end
  end

  @doc """
    Generates an output struct
    from the given public keys and 
    the given amount.
  """
  @spec generate(Enum.t, Integer.t, String.t) :: __MODULE__.t
  def generate(_, _, signature \\ nil)
  def generate([public_key], amount, signature) when amount_is_valid(amount), do: generate(public_key, amount, signature)
  def generate(public_key, amount, signature) when is_binary(public_key) and amount_is_valid(amount) do 
    %__MODULE__{
      public_keys: [public_key],
      amount: amount,
      fulfillment: %Ed25519Sha512{public_key: public_key, signature: signature}
    }
  end
  def generate(public_keys, amount, signature) when is_list(public_keys) and amount_is_valid(amount) do
    %__MODULE__{
      public_keys: public_keys,
      amount: amount,
      fulfillment: Enum.map(public_keys, fn key -> %Ed25519Sha512{public_key: key, signature: signature} end)
    }
  end
  def generate([], _, _), do: {:error, "You must provide at least one public key!"}

  @doc """
    Converts an output struct
    to a serialized plain map.
  """
  @spec to_map(__MODULE__.t) :: Map.t
  def to_map(%__MODULE__{} = output) do
    with {:ok, details} <- fulfillment_to_details(output.fulfillment),
         {:ok, uri}     <- Fulfillment.get_condition_uri(output.fulfillment)
    do
      {:ok, %{
        public_keys: Enum.map(output.public_keys, &Crypto.encode_base58/1),
        amount: "#{output.amount}",
        condition: %{
          details: details,
          uri: uri
        }
      }}
    else
      {:error, reason} -> {:error, "Could not convert output to map: #{inspect reason}"}
    end
  end

  defp fulfillment_to_details(%Ed25519Sha512{} = ffl) do
    {:ok, %{
      type: "ed25519-sha-256",
      public_key: Crypto.encode_base58(ffl.public_key)
    }}
  end
  defp fulfillment_to_details(_), do: {:error, "The given fulfillment is invalid!"}
end