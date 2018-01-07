defmodule BigchainExCryptoTest do
  use BigchainEx.TestCase
  alias BigchainEx.{Crypto, Base58}

  property "generate_pub_key/2" do
    forall {pub_key, priv_key} <- Crypto.generate_keypair do
      {:ok, key} = Crypto.generate_pub_key(priv_key)
      key === pub_key
    end
  end

  property "encode_base58" do
    forall x <- random_string(Enum.random(1..64)) do
      hex_str = Base.encode16(x)
      {int, _} = Integer.parse(hex_str, 16)
      encoded = Base58.encode(int)

      encoded === Crypto.encode_base58(x)
    end
  end

  property "decode_base58" do
    forall x <- random_string(Enum.random(1..64)) do
      {:ok, decoded} = x 
      |> Crypto.encode_base58
      |> Crypto.decode_base58

      decoded === x
    end
  end
end