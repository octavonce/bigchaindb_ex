defmodule BigchaindbEx.Generators do
  alias BigchaindbEx.Crypto
  alias BigchaindbEx.Transaction.Output

  def gen_output do
    {pub_key, _} = keypair
    Output.generate(pub_key, Enum.random(1..10000000))
  end

  def random_string(length \\ Enum.random(1..64)) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  def keypair, do: Crypto.generate_keypair
end