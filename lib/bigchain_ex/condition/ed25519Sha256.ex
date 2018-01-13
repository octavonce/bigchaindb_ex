defmodule BigchainEx.Condition.Ed25519Sha256 do
  @id 4
  @type_name "ed25519-sha-256"
  @asn1 "ed25519Sha256"
  @asn1_condition "ed25519Sha256Condition"
  @asn1_fulfillment "ed25519Sha256Fulfillment"
  @category "simple"

  @constant_cost 131072
  @public_key_length 32
  @signature_length 64

  def type_id,               do: @id
  def type_name,             do: @type_name
  def type_asn1,             do: @asn1
  def type_asn1_condition,   do: @asn1_condition
  def type_asn1_fulfillment, do: @asn1_fulfillment
  def type_category,         do: @category
  def type_cost,             do: @constant_cost
  def type_pub_key_length,   do: @public_key_length
  def type_signature_length, do: @signature_length   
  
  def serialize_to_uri(hash) when is_binary(hash) do
    
  end
end