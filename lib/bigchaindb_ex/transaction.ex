defmodule BigchaindbEx.Transaction do
  alias BigchaindbEx.{Crypto, Utils}
  alias BigchaindbEx.Transaction.{Input, Output}

  @type t :: %__MODULE__{
    operation: String.t,
    asset: Map.t,
    inputs: Enum.t,
    outputs: Enum.t,
    metadata: Map.t,
    fulfillments: Enum.t,
    conditions: Enum.t,
    version: String.t,
    timestamp: String.t
  }

  @enforce_keys [:operation, :version, :timestamp]

  defstruct [
    :operation,
    :asset,
    :inputs,
    :outputs,
    :metadata,
    :version,
    :fulfillments,
    :conditions,
    :timestamp
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
      iex> BigchaindbEx.Transaction.prepare(operation: "CREATE", signers: [signer1, signer2], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})
      
      {:ok, tx}
  """
  @spec prepare(prepare_opts) :: {:ok, __MODULE__.t} | {:error, String.t}
  def prepare(opts) when is_list(opts), do: opts |> Enum.into(%{}) |> prepare()
  def prepare(opts = %{signers: signer})  when is_binary(signer), do: prepare(Map.merge(opts, %{signers: [signer]}))
  def prepare(opts = %{signers: signers}) when is_tuple(signers), do: prepare(Map.merge(opts, %{signers: Tuple.to_list(signers)}))
  def prepare(%{signers: []}), do: {:error, "No signers given! Please provide at least one signer!"}
  def prepare(%{recipients: []}), do: {:error, "Each `recipient` in the list must be a tuple of `{[<list of public keys>], <amount>}`"}
  def prepare(opts = %{operation: "CREATE", asset: asset = %{data: _}, signers: signers}) when is_list(signers)  do
    {:ok, %__MODULE__{
      operation: "CREATE",
      asset: asset,
      inputs: signers,
      outputs: [{signers, 1}],
      metadata: opts[:metadata] || %{},
      version: "1.0",
      timestamp: Utils.gen_timestamp()
    }}
  end
  def prepare(opts = %{operation: "CREATE", asset: asset = %{data: _}, signers: signers, recipients: recipients}) 
    when is_list(signers) 
    and  is_list(recipients)
  do
    {:ok, %__MODULE__{
      operation: "CREATE",
      asset: asset,
      inputs: signers,
      outputs: recipients,
      metadata: opts[:metadata] || %{},
      version: "1.0",
      timestamp: Utils.gen_timestamp()
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
      inputs: signers,
      outputs: [{signers, 1}],
      metadata: opts[:metadata] || %{},
      version: "1.0",
      timestamp: Utils.gen_timestamp()
    }}
  end
  def prepare(opts = %{operation: "TRANSFER", asset: asset = %{data: _}, signers: signers, recipients: recipients})
    when (is_list(signers) or is_binary(signers) or is_tuple(signers))
    and  (is_list(recipients) or is_binary(recipients) or is_tuple(recipients)) 
  do
    {:ok, %__MODULE__{
      operation: "TRANSFER",
      asset: asset,
      inputs: signers,
      outputs: recipients,
      metadata: opts[:metadata] || %{},
      version: "1.0",
      timestamp: Utils.gen_timestamp()
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
    # Generate public keys from the 
    # given private keys.
    key_pairs = Enum.map(priv_keys, fn p_key ->
      case Crypto.generate_pub_key(p_key) do
        {:ok, pub_key} -> {pub_key, p_key}
        {:error, _}    -> {:error, p_key}
      end
    end)

    # Check for errors
    errors = key_pairs
    |> Enum.filter(fn {atom, _} -> atom === :error end)
    |> Enum.map(fn {_, key} -> key end)

    if Enum.count(errors) > 0 do
      {:error, "The following keys could not be decoded: #{inspect errors}"}
    else 
      # Serialize the transaction to json
      result = tx
      |> Map.from_struct
      |> serialize_outputs
      |> Poison.encode
      
      case result do
        {:error, error} -> {:error, "Could not serialize transaction! Errors: #{inspect error}"}
        {:ok, serialized_tx} ->
          # Sign the transaction using the 
          # keys and the serialized tx
          signatures = Enum.map(key_pairs, fn {pub_key, priv_key} ->
            case Crypto.sign(serialized_tx, priv_key) do
              {:ok, signed}    -> {signed, pub_key} 
              {:error, reason} -> {:error, reason}
            end
          end)

          # Check for errors
          errors = signatures
          |> Enum.filter(fn {atom, _} -> atom === :error end)
          |> Enum.map(fn {_, key} -> key end)

          if Enum.count(errors) > 0 do
            {:error, "Signing using the given private key/s failed: #{inspect errors}"}
          else
            verified_signatures = Enum.map(signatures, fn {sig, pub_key} -> 
              {pub_key, sig, Crypto.verify(serialized_tx, sig, pub_key)}
            end)

            errors = verified_signatures
            |> Enum.filter(fn {_, _, valid} -> not valid end)
            |> Enum.map(fn {key, _, _} -> key end)

            if Enum.count(errors) > 0 do
              {:error, "Verifying using the given private key/s failed: #{inspect errors}"}
            else
              fulfilled_inputs = Enum.map(verified_signatures, fn {pub_key, _signature, _valid} ->
                Input.generate(pub_key)
              end)

              fulfilled_outputs = Enum.map(tx.outputs, fn {pub_keys, amount} -> 
                Output.generate(pub_keys, amount)
              end)

              fulfilled_tx = Map.merge(tx, %{
                inputs: fulfilled_inputs,
                outputs: fulfilled_outputs
              })

              {:ok, fulfilled_tx}
            end
          end
      end
    end
  end
  def fulfill(%__MODULE__{} = tx, _), do: {:error, "Invalid private key/s!"}
  def fulfill(_, _), do: {:error, "You must supply a transaction object as the first argument!"}

  @doc """
    Sends a fulfilled transaction to
    the bigchaindb cluster.
  """
  @spec send(__MODULE__.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def send(%__MODULE__{} = tx) do
  
  end

  @spec retrieve(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def retrieve(tx_id) when is_binary(tx_id) do
    
  end

  @spec status(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def status(tx_id) when is_binary(tx_id) do
    
  end

  defp serialize_outputs(tx) when is_map(tx) do 
    Map.merge(tx, %{
      outputs: Enum.map(tx.outputs, fn 
        x when is_tuple(x) -> Tuple.to_list(x)
        x                  -> x
      end)
    })
  end
end