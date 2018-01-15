defmodule BigchaindbEx.Fulfillment.Ed25519Sha512Test do
  use BigchaindbEx.TestCase

  alias BigchaindbEx.Crypto
  alias BigchaindbEx.Fulfillment.Ed25519Sha512

  property "asn1_decode/1" do
    forall {{pub_key, priv_key}, message} <- {keypair(), random_string()} do
      {:ok, sig} = Crypto.sign(message, priv_key)
      {:ok, ffl} = Ed25519Sha512.asn1_encode(%{public_key: pub_key, signature: sig})
      {:ok, %{public_key: decoded_pub_key, signature: decoded_signature}} = Ed25519Sha512.asn1_decode(ffl)
      decoded_pub_key === pub_key and decoded_signature === sig
    end
  end
end