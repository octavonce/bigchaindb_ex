defmodule BigchaindbEx.Condition.ThresholdTest do
  use BigchaindbEx.TestCase

  alias BigchaindbEx.Condition
  alias BigchaindbEx.Condition.ThresholdSha256

  property "add_subcondition/2" do
    forall ffl <- gen_fulfillment() do
      {:ok, subcondition} = Condition.from_fulfillment(ffl)
      condition = %ThresholdSha256{
        threshold: 1,
        subconditions: []
      }

      ThresholdSha256.add_subcondition(condition, subcondition) === add_subcondition_oracle(condition, subcondition)
    end
  end

  property "add_subfulfillment/2" do
    forall ffl <- gen_fulfillment() do
      condition = %ThresholdSha256{
        threshold: 1,
        subconditions: []
      }

      ThresholdSha256.add_subcondition(condition, ffl) === add_subfulfillment_oracle(condition, ffl)
    end
  end

  defp add_subcondition_oracle(condition, subcondition) do
    {:ok, subcondition} = Condition.from_uri(subcondition)
    {:ok, Map.merge(condition, %{subconditions: Enum.concat(condition.subconditions, [subcondition])})}
  end

  defp add_subfulfillment_oracle(condition, ffl) do
    {:ok, subcondition} = Condition.from_fulfillment(ffl)
    add_subcondition_oracle(condition, subcondition)
  end
end