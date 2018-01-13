defmodule BigchainEx.Condition.Ed25519Sha256 do
  @TYPE_ID 4
  @TYPE_NAME "ed25519-sha-256"
  @TYPE_ASN1 "ed25519Sha256"
  @TYPE_ASN1_CONDITION "ed25519Sha256Condition"
  @TYPE_ASN1_FULFILLMENT "ed25519Sha256Fulfillment"
  @TYPE_CATEGORY "simple"

  @CONSTANT_COST 131072
  @PUBLIC_KEY_LENGTH 32
  @SIGNATURE_LENGTH 64
  
  def serialize_to_uri(hash) when is_binary(hash) do
    
  end
end