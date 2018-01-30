defmodule BigchaindbEx.Fulfillment.Ed25519Sha512Test do
  use BigchaindbEx.TestCase

  alias BigchaindbEx.Crypto
  alias BigchaindbEx.Fulfillment.Ed25519Sha512

  property "asn1_decode/1" do
    for_all {{pub_key, priv_key}, message} in {&keypair/0, &random_string/0} do
      {:ok, sig} = Crypto.sign(message, priv_key)
      {:ok, ffl} = Ed25519Sha512.to_asn1(%Ed25519Sha512{public_key: pub_key, signature: sig})
      {:ok, %Ed25519Sha512{public_key: decoded_pub_key, signature: decoded_signature}} = Ed25519Sha512.from_asn1(ffl)
      decoded_pub_key === pub_key and decoded_signature === sig
    end
  end

  property "from_json/1" do
    for_all {{public_key, private_key}, message} in {&keypair/0, &random_string/0} do
      {:ok, signature} = Crypto.sign(message, private_key)

      struct = %Ed25519Sha512{
        public_key: public_key,
        signature: signature
      }

      encoded_json = Poison.encode! %{
        public_key: Base.url_encode64(public_key, padding: false),
        signature: Base.url_encode64(signature, padding: false)
      }
      
      Ed25519Sha512.from_json(encoded_json) === struct
    end
  end

  property "serialize_uri/1" do
    for_all ffl in &gen_fulfillment/0 do
      serialize_uri_oracle(ffl) === Ed25519Sha512.serialize_uri(ffl)
    end
  end

  property "from_uri/1" do
    for_all ffl in &gen_fulfillment/0 do
      {:ok, uri} = Ed25519Sha512.serialize_uri(ffl)
      from_uri_oracle(uri) === Ed25519Sha512.from_uri(uri)
    end
  end

  defp serialize_uri_oracle(ffl) do
    {:ok, bin} = Ed25519Sha512.to_asn1(ffl)
    {:ok, Base.url_encode64(bin, padding: false)}
  end

  defp from_uri_oracle(uri) do
    {:ok, decoded} = Base.url_decode64(uri, padding: false)
    {:ok, struct} = Ed25519Sha512.from_asn1(decoded)
    {:ok, struct}
  end
end