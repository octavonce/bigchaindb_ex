defmodule BigchaindbEx.Transaction.InputTest do
  use BigchaindbEx.TestCase
  alias BigchaindbEx.Transaction.{Input, Output}

  property "generate/1" do
    for_all ffl in &gen_fulfillment/0 do
      generate_oracle(ffl.public_key, ffl.signature) === Input.generate(ffl.public_key, ffl.signature)
    end
  end

  defp generate_oracle(public_key, signature) do
    output = Output.generate(public_key, 1, signature)

    %Input{
      fulfillment: output.fulfillment,
      owners_before: [public_key],
      fulfills: nil
    }
  end
end