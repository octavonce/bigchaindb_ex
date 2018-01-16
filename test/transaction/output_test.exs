defmodule BigchaindbEx.Transaction.OutputTest do
  use BigchaindbEx.TestCase

  alias BigchaindbEx.Fulfillment
  alias BigchaindbEx.Transaction.Output

  # TODO: Write property for generate
  # once all the crypto conditions are 
  # implemented.
  # property "generate/2" do
  #   forall {pub_key, _} <- keypair do
      
  #   end
  # end

  property "to_map/1" do
    forall output <- gen_output() do
      to_map_oracle(output) === Output.to_map(output)
    end
  end

  def to_map_oracle(output) do
    details = %{
      type: "ed25519-sha-256",
      public_key: output.fulfillment.public_key
    }
    {:ok, uri} = Fulfillment.get_condition_uri(output.fulfillment)

    {:ok, %{
      public_keys: output.public_keys,
      amount: output.amount,
      condition: %{
        details: details,
        uri: uri
      }
    }}
  end
end