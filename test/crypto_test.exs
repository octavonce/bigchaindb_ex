defmodule BigchaindbExCryptoTest do
  use BigchaindbEx.TestCase
  alias BigchaindbEx.{Crypto, Base58}

  test "sha3_hash256/2" do
    {:ok, result1} = Crypto.sha3_hash256("字")
    {:ok, result2} = Crypto.sha3_hash256("hello world")

    assert result1 === "2b38731ba4ef72d4034bef49e87c381d1fbe75435163b391dd33249331f91fe7"
    assert result2 === "644bcc7e564373040999aac89e7622f3ca71fba1d972fd94a31c3bfbf24e3938"
  end

  property "generate_pub_key/2" do
    for_all {pub_key, priv_key} in &keypair/0 do
      {:ok, key} = Crypto.generate_pub_key(priv_key)
      key === pub_key
    end
  end

  property "verify/3" do
    for_all {{pub_key, priv_key}, message} in {&keypair/0, &random_string/0} do
      {:ok, sig} = Crypto.sign(message, priv_key)
      Crypto.verify(message, sig, pub_key)
    end 
  end

  test "encode_base58/2" do
    Crypto.encode_base58("hello world") === "StV1DL6CwTryKyV"
  end

  property "decode_base58/1" do
    for_all str in &random_string/0 do
      {:ok, decoded} = str
      |> Crypto.encode_base58
      |> Crypto.decode_base58

      decoded === str
    end
  end
end