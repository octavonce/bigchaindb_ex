defmodule BigchainEx.Fulfillment.Ed25519Sha512Test do
  use BigchainEx.TestCase

  alias BigchainEx.Crypto
  alias BigchainEx.Fulfillment.Ed25519Sha512

  property "asn1_decode/1" do
    forall {{pub_key, priv_key}, message} <- {keypair(), random_string()} do
      {:ok, sig} = Crypto.sign(message, priv_key)
      {:ok, ffl} = Ed25519Sha512.asn1_encode(%{public_key: pub_key, signature: sig})
      {:ok, decoded} = Ed25519Sha512.asn1_decode(ffl)

      decoded === ffl
    end
  end
end