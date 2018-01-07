defmodule BigchainExTransactionTest do
  use BigchainEx.TestCase

  test "prepare/1 CREATE - should ok" do
    {pub, _} = BigchainEx.Crypto.generate_keypair
    result1 = BigchainEx.Transaction.prepare(operation: "CREATE", signers: [pub], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result1 do
      {:ok, _}    -> assert true
      {:error, _} -> assert false
    end

    result2 = BigchainEx.Transaction.prepare(operation: "CREATE", signers: pub, asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result2 do
      {:ok, _}    -> assert true
      {:error, _} -> assert false
    end
  end

  test "prepare/1 TRANSFER - should ok" do
    {pub, _} = BigchainEx.Crypto.generate_keypair
    result1 = BigchainEx.Transaction.prepare(operation: "TRANSFER", signers: pub, asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result1 do
      {:ok, _}    -> assert true
      {:error, _} -> assert false
    end

    result2 = BigchainEx.Transaction.prepare(operation: "TRANSFER", signers: pub, recipients: pub, asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result2 do
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

  test "prepare/1 - should error on signers" do
    result = BigchainEx.Transaction.prepare(operation: "CREATE", signers: [], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result do
      {:ok, _}    -> assert false
      {:error, _} -> assert true
    end
  end

  test "prepare/1 - should error on data" do
    result = BigchainEx.Transaction.prepare(operation: "CREATE", signers: "fdsfs", asset: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}})

    case result do
      {:ok, _}    -> assert false
      {:error, _} -> assert true
    end
  end
end
