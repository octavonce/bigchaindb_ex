defmodule BigchaindbExTransactionTest do
  use BigchaindbEx.TestCase
  alias BigchaindbEx.{Transaction, Crypto}

  test "prepare/1 CREATE - should ok" do
    {pub, _} = Crypto.generate_keypair
    result1 = Transaction.prepare(operation: "CREATE", signers: [pub], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result1 do
      {:ok, _}    -> assert true
      {:error, _} -> assert false
    end

    result2 = Transaction.prepare(operation: "CREATE", signers: pub, asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result2 do
      {:ok, _}    -> assert true
      {:error, _} -> assert false
    end
  end

  test "prepare/1 TRANSFER - should ok" do
    {pub, _} = Crypto.generate_keypair
    result1 = Transaction.prepare(operation: "TRANSFER", signers: pub, asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result1 do
      {:ok, _}    -> assert true
      {:error, _} -> assert false
    end

    result2 = Transaction.prepare(operation: "TRANSFER", signers: pub, recipients: pub, asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result2 do
      {:ok, _}    -> assert true
      {:error, _} -> assert false
    end
  end

  test "prepare/1 - should error on operation" do
    {pub, _} = Crypto.generate_keypair
    result = Transaction.prepare(operation: "CREATEGFD", signers: [pub], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result do
      {:ok, _}    -> assert false
      {:error, _} -> assert true
    end
  end

  test "prepare/1 - should error on signers" do
    result = Transaction.prepare(operation: "CREATE", signers: [], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})

    case result do
      {:ok, _}    -> assert false
      {:error, _} -> assert true
    end
  end

  test "prepare/1 - should error on data" do
    result = Transaction.prepare(operation: "CREATE", signers: "fdsfs", asset: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}})

    case result do
      {:ok, _}    -> assert false
      {:error, _} -> assert true
    end
  end

  test "fulfill/2 - CREATE tx" do
    with {pub, priv} <- Crypto.generate_keypair,
         {:ok, tx}   <- Transaction.prepare(operation: "CREATE", signers: pub, asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})
    do
      {:ok, ffl} = Transaction.fulfill(tx, priv)
      assert true
    else
      _ -> assert false
    end
  end

  test "send/1" do
    {pub_key, priv_key} = Crypto.generate_keypair
    {:ok, tx} = Transaction.prepare(operation: "CREATE", signers: [pub_key], asset: %{data: %{bicycle: %{serial_no: 232134, manufacturer: "SpeedWheels"}}})
    {:ok, tx} = Transaction.fulfill(tx, priv_key)
    {:ok, response} = Transaction.send(tx)

    assert response.status_code === 201
  end
end
