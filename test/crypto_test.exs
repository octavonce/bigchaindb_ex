defmodule BigchaindbExCryptoTest do
  use BigchaindbEx.TestCase
  alias BigchaindbEx.{Crypto, Base58}

  # TODO: Write property for this with test vectors
  test "sha3_hash256/1" do
    {:ok, result} = Crypto.sha3_hash256("Hello world!")
    assert result === "ecd0e108a98e192af1d2c25055f4e3bed784b5c877204e73219a5203251feaab"
  end

  property "sha3_hash256/2" do
    forall {input, output} <- gen_sha3_io() do
      {:ok, result} = Crypto.sha3_hash256(Hexate.decode(input))
      result === String.downcase(output)
    end
  end

  property "generate_pub_key/2" do
    forall {pub_key, priv_key} <- keypair() do
      {:ok, key} = Crypto.generate_pub_key(priv_key)
      key === pub_key
    end
  end

  property "verify/3" do
    forall {{pub_key, priv_key}, message} <- {keypair(), random_string()} do
      {:ok, sig} = Crypto.sign(message, priv_key)
      Crypto.verify(message, sig, pub_key)
    end 
  end

  property "encode_base58/1" do
    forall x <- random_string() do
      hex_str = Base.encode16(x)
      {int, _} = Integer.parse(hex_str, 16)
      encoded = Base58.encode(int)

      encoded === Crypto.encode_base58(x)
    end
  end

  property "decode_base58/1" do
    forall x <- random_string() do
      {:ok, decoded} = x 
      |> Crypto.encode_base58
      |> Crypto.decode_base58

      decoded === x
    end
  end
end