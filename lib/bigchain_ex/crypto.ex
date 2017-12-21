defmodule BigchainEx.Crypto do
  @moduledoc """
  This module provides cryptography utilities.
  """

  @doc """
  Generates a public and private key pair.

  ## Example
    iex> BigchainEx.Crypto.generate_key_pair
    
    {"044A9AD8D64C39C41D577A98D3BA80930F30D6D8AAF614A38A20952019FFFA40A095E159B1049755D06531E84910EDA161AEFA7D29F347A45077E0CEB8EBD9215E",
    "0777C775631DBC21ED3AA5526C905BC122AEE7B9EB6C2C1F9F17345346906778"}
  """
  @spec generate_keypair :: {String.t, String.t}
  def generate_keypair do
    {pub, priv} = :crypto.generate_key(:ecdh, :secp256k1)
    {Base.encode16(pub), Base.encode16(priv)}
  end
end