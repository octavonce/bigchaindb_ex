defmodule BigchaindbEx.Generators do
  def random_string(length \\ Enum.random(1..64)) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  def keypair, do: BigchaindbEx.Crypto.generate_keypair
end