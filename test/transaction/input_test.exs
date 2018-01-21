defmodule BigchaindbEx.Transaction.InputTest do
  use BigchaindbEx.TestCase
  alias BigchaindbEx.Transaction.{Input, Output}

  property "generate/1" do
    forall pub_keys <- gen_public_keys(Enum.random(1..3)) do
      generate_oracle(pub_keys) === Input.generate(pub_keys)
    end
  end

  defp generate_oracle(public_keys) do
    output = Output.generate(public_keys, 1)

    %Input{
      fulfillment: output.fulfillment,
      owners_before: public_keys,
      fulfills: nil
    }
  end
end