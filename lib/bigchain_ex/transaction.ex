defmodule BigchainEx.Transaction do
  @type t :: %__MODULE__{
    operation: String.t,
    asset: String.t,
    signers: String.t | Enum.t,
    metadata: String.t
  }

  @enforce_keys [
    :operation,
    :signers
  ]

  defstruct [
    :operation,
    :asset,
    :signers,
    :metadata
  ]

  @spec prepare(Keyword.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def prepare(opts \\ []) do
    
  end

  #@spec fulfill(__MODULE__.t, )
  def fullfill(tx, priv_key) do
    
  end
end