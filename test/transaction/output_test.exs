defmodule BigchaindbEx.Transaction.OutputTest do
  use BigchaindbEx.TestCase

  alias BigchaindbEx.{Fulfillment, Crypto}
  alias BigchaindbEx.Transaction.Output

  # TODO: Write property for generate
  # once all the crypto conditions are 
  # implemented.
  # property "generate/2" do
  #   for_all {pub_key, _} in keypair do
      
  #   end
  # end

  property "to_map/1" do
    for_all output in &gen_output/0 do
      to_map_oracle(output) === Output.to_map(output)
    end
  end

  defp to_map_oracle(output) do
    {:ok, uri} = Fulfillment.get_condition_uri(output.fulfillment)
    details = %{
      type: "ed25519-sha-256",
      public_key: Crypto.encode_base58(output.fulfillment.public_key)
    }

    {:ok, %{
      public_keys: Enum.map(output.public_keys, &Crypto.encode_base58/1),
      amount: "#{output.amount}",
      condition: %{
        details: details,
        uri: uri
      }
    }}
  end
end