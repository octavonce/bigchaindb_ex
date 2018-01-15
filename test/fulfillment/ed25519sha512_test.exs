defmodule BigchaindbEx.Fulfillment.Ed25519Sha512Test do
  use BigchaindbEx.TestCase

  alias BigchaindbEx.Crypto
  alias BigchaindbEx.Fulfillment.Ed25519Sha512

  property "asn1_decode/1" do
    forall {{pub_key, priv_key}, message} <- {keypair(), random_string()} do
      {:ok, sig} = Crypto.sign(message, priv_key)
      {:ok, ffl} = Ed25519Sha512.to_asn1(%Ed25519Sha512{public_key: pub_key, signature: sig})
      {:ok, %Ed25519Sha512{public_key: decoded_pub_key, signature: decoded_signature}} = Ed25519Sha512.from_asn1(ffl)
      decoded_pub_key === pub_key and decoded_signature === sig
    end
  end

  property "from_json/1" do
    forall {{public_key, private_key}, message} <- {keypair(), random_string()} do
      {:ok, signature} = Crypto.sign(message, private_key)

      struct = %Ed25519Sha512{
        public_key: public_key,
        signature: signature
      }

      encoded_json = Poison.encode! %{
        public_key: Base.encode64(public_key),
        signature: Base.encode64(signature)
      }
      
      Ed25519Sha512.from_json(encoded_json) === struct
    end
  end
end