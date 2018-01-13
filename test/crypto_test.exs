defmodule BigchaindbExCryptoTest do
  use BigchaindbEx.TestCase
  alias BigchaindbEx.{Crypto, Base58}

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

  property "remove_base64_padding/1" do
    forall {pub_key, _} <- keypair() do
      hex_pub_key = pub_key |> Base58.decode |> Integer.to_string(16)
      padded = "0" <> hex_pub_key

      unpadded = padded 
      |> Crypto.remove_base64_padding
      |> Crypto.remove_base64_padding
      |> Crypto.remove_base64_padding

      unpadded === hex_pub_key
    end 
  end
end