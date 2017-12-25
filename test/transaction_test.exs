defmodule BigchainExTransactionTest do
  use ExUnit.Case

  test "prepare/1 - should ok" do
    {pub, _} = BigchainEx.Crypto.generate_keypair
    result = BigchainEx.Transaction.prepare(operation: "CREATE", signers: [pub], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result do
      {:ok, _}    -> assert true
      {:error, _} -> assert false
    end
  end

  test "prepare/1 - should error on operation" do
    {pub, _} = BigchainEx.Crypto.generate_keypair
    result = BigchainEx.Transaction.prepare(operation: "CREATEGFD", signers: [pub], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result do
      {:ok, _}    -> assert false
      {:error, _} -> assert true
    end
  end
end
