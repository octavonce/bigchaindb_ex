defmodule BigchainEx.Fulfillment.Ed25519Sha512 do
  @type t :: %__MODULE__{
    public_key: String.t,
    signature: String.t
  }

  defstruct [
    :public_key, 
    :signature
  ]

  @spec asn1_encode(__MODULE__.t) :: {:ok, binary} | {:error, String.t}
  def asn1_encode(%__MODULE__{} = fulfillment) do
    :CryptoConditions.encode(:Ed25519Sha512Fulfillment, fulfillment)
  end
end