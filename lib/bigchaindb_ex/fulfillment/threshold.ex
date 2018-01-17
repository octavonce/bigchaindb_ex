defmodule BigchaindbEx.Fulfillment.ThresholdFulfillment do
  @type t :: %__MODULE__{
    subfulfillments: Enum.t,
    subconditions: Enum.t
  }

  @enforce_keys [:subfulfillments, :subconditions]
  
  defstruct [
    :subfulfillments, 
    :subconditions
  ]

  def add_subcondition(%__MODULE__{} = ffl) do
    
  end

  def add_subfulfillment(%__MODULE__{} = ffl) do
 
  end
end