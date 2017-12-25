defmodule BigchainEx.Transaction do
  @type t :: %__MODULE__{
    operation: String.t,
    asset: Map.t,
    signers: Enum.t,
    meta: Map.t
  }

  @enforce_keys [
    :operation,
    :signers,
    :asset
  ]

  defstruct [
    :operation,
    :asset,
    :signers,
    :meta
  ]

  @type options :: [
    operation: String.t,
    asset: Map.t,
    signers: Enum.t,
    meta: Map.t
  ]

  @doc """
    Prepares a transaction.

    ## Example
      iex> BigchainEx.Transaction.prepare(operation: "CREATE", signers: [signer1, signer2], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})
      
      {:ok, tx}
  """
  @spec prepare(options) :: {:ok, __MODULE__.t} | {:error, String.t}
  def prepare(opts) when is_list(opts), do: opts |> Enum.into(%{}) |> prepare()
  def prepare(%{signers: []}), do: {:error, "At least one signer is required!"}
  def prepare(opts = %{operation: operation, asset: asset, signers: signers}) 
    when is_binary(operation)
    and  is_list(signers)
    and  is_map(asset)
  do
    if operation == "CREATE" or operation == "TRANSFER" do
      {:ok, %__MODULE__{
        operation: operation,
        asset: asset,
        signers: signers,
        meta: opts[:meta] || %{}
      }}
    else 
      {:error, "The given operation value #{operation} is invalid! Suggested: CREATE or TRANSFER"}
    end
  end
  def prepare(_), do: {:error, "The given options are invalid!"}

  @spec fulfill(__MODULE__.t, String.t) :: :ok | :error
  def fulfill(%__MODULE__{} = tx, priv_key) when is_binary(priv_key) do
    
  end

  @spec retrieve(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def retrieve(tx_id) when is_binary(tx_id) do
    
  end
end