defmodule BigchaindbEx.ConditionTest do
  use BigchaindbEx.TestCase

  alias BigchaindbEx.Condition
  alias BigchaindbEx.Condition.Ed25519Sha256

  property "decode_hash_from_uri/1" do
    for_all hash in &gen_hash/0 do
      uri = Ed25519Sha256.hash_to_uri(hash)
      {:ok, hash_from_uri} = Condition.decode_hash_from_uri(uri)

      hash_from_uri === hash
    end
  end 

  property "decode_type_from_uri/1" do
    for_all uri in &gen_uri/0 do
      [_, str] = String.split(uri, "?fpt=")
      [type, _] = String.split(str, "&cost=")
      {:ok, decoded_type} = Condition.decode_type_from_uri(uri)

      type === decoded_type
    end
  end
end