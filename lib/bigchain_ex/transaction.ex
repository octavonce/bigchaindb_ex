defmodule BigchainEx.Transaction do
  @type t :: %__MODULE__{
    operation: String.t,
    asset: Map.t,
    signers: Enum.t | String.t | Tuple.t,
    recipients: Enum.t | String.t | Tuple.t,
    metadata: Map.t
  }

  @enforce_keys [:operation]

  defstruct [
    :operation,
    :asset,
    :signers,
    :recipients,
    :metadata
  ]

  @typedoc """
    Options given to the prepare/1 func
  """
  @type prepare_opts :: [
    operation: String.t,
    asset: Map.t,
    signers: Enum.t | String.t | Tuple.t,
    recipients: Enum.t | String.t | Tuple.t,
    metadata: Map.t
  ]

  @doc """
    Prepares a transaction.

    ## Example
      iex> BigchainEx.Transaction.prepare(operation: "CREATE", signers: [signer1, signer2], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})
      
      {:ok, tx}
  """
  @spec prepare(prepare_opts) :: {:ok, __MODULE__.t} | {:error, String.t}
  def prepare(opts) when is_list(opts), do: opts |> Enum.into(%{}) |> prepare()
  def prepare(%{signers: []}), do: {:error, "At least one signer is required!"}
  def prepare(opts = %{operation: "CREATE", asset: asset = %{data: _}, signers: signers}) 
    when is_list(signers) 
    or   is_binary(signers)
    or   is_tuple(signers) 
  do
    {:ok, %__MODULE__{
      operation: "CREATE",
      asset: asset,
      signers: signers,
      metadata: opts[:metadata] || %{}
    }}
  end
  def prepare(opts = %{operation: "CREATE", asset: asset = %{data: _}, signers: signers, recipients: recipients}) 
    when (is_list(signers) or is_binary(signers) or is_tuple(signers)) 
    and  (is_list(recipients) or is_binary(recipients) or is_tuple(recipients))
  do
    {:ok, %__MODULE__{
      operation: "CREATE",
      asset: asset,
      signers: signers,
      recipients: recipients,
      metadata: opts[:metadata] || %{}
    }}
  end
  def prepare(opts = %{operation: "TRANSFER", asset: asset = %{data: _}, signers: signers})
    when is_list(signers) 
    or   is_binary(signers) 
    or   is_tuple(signers)
  do
    {:ok, %__MODULE__{
      operation: "TRANSFER",
      asset: asset,
      signers: signers,
      recipients: signers,
      metadata: opts[:metadata] || %{}
    }}
  end
  def prepare(opts = %{operation: "TRANSFER", asset: asset = %{data: _}, signers: signers, recipients: recipients})
    when (is_list(signers) or is_binary(signers) or is_tuple(signers))
    and  (is_list(recipients) or is_binary(recipients) or is_tuple(recipients)) 
  do
    {:ok, %__MODULE__{
      operation: "TRANSFER",
      asset: asset,
      signers: signers,
      recipients: recipients,
      metadata: opts[:metadata] || %{}
    }}
  end
  def prepare(_), do: {:error, "The given options are invalid!"}

  @spec fulfill(__MODULE__.t, String.t) :: :ok | :error
  def fulfill(%__MODULE__{} = tx, priv_key) when is_binary(priv_key) do
    
  end

  @spec retrieve(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def retrieve(tx_id) when is_binary(tx_id) do
    
  end

  @spec retrieve(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def status(tx_id) when is_binary(tx_id) do
    
  end
end