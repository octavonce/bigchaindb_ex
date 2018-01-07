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
    Options given to prepare/1
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

  @doc """
    Fulfills a given transaction.
  """
  @spec fulfill(__MODULE__.t, String.t | Enum.t | Tuple.t) :: {:ok, Transaction.t} | {:error, String.t}
  def fulfill(%__MODULE__{} = tx, priv_key)  when is_binary(priv_key), do: fulfill(tx, [priv_key])
  def fulfill(%__MODULE__{} = tx, priv_keys) when is_tuple(priv_keys), do: fulfill(tx, Tuple.to_list(priv_keys))
  def fulfill(%__MODULE__{} = tx, priv_keys) when is_list(priv_keys) do
    # https://github.com/bigchaindb/bigchaindb/blob/master/bigchaindb/common/transaction.py
    
    # Generate public keys from the 
    # given private keys.
    key_pairs = Enum.map(priv_keys, fn p_key ->
      case BigchainEx.Crypto.generate_pub_key(p_key) do
        {:ok, pub_key} -> {pub_key, p_key}
        {:error, _}    -> {:error, p_key}
      end
    end)

    # Check for errors
    errors = key_pairs
    |> Enum.filter(fn x -> elem(x, 0) === :error end)
    |> Enum.map(fn x -> {:error, key} = x; key end)

    if Enum.count(errors) > 0 do
      {:error, "The following keys could not be decoded: #{inspect errors}"}
    else 
      # Serialize the transaction to json
      result = tx
      |> Map.from_struct
      |> Poison.encode

      case result do
        {:error, error} -> {:error, "Could not serialize transaction! Errors: #{inspect error}"}
        {:ok, serialized_tx} ->
          # Sign the transaction using the 
          # keys and the serialized tx
          
      end
    end
  end
  def fulfill(%__MODULE__{} = tx, _), do: {:error, "Invalid private key/s!"}
  def fulfill(_, _), do: {:error, "You must supply a transaction object as the first argument!"}

  @doc """
    Sends a fulfilled transaction to
    the bigchaindb cluster.
  """
  @spec send(__MODULE__.t) :: {:ok, Transaction.t} | {:error, String.t}
  def send(%__MODULE__{} = tx) do
    
  end

  @spec retrieve(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def retrieve(tx_id) when is_binary(tx_id) do
    
  end

  @spec status(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def status(tx_id) when is_binary(tx_id) do
    
  end
end