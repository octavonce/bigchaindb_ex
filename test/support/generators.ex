defmodule BigchaindbEx.Generators do
  alias BigchaindbEx.Crypto

  def random_string(length \\ Enum.random(1..64)) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  def keypair, do: Crypto.generate_keypair
end