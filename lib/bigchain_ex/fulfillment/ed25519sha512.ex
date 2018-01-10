defmodule BigchainEx.Fulfillment.Ed25519Sha512 do
  @type t :: %__MODULE__{
    public_key: <<size(32)>>,
    signature: <<size(64)>>
  }

  defstruct [
    :public_key, 
    :signature
  ]

  def cast() do
    
  end
end