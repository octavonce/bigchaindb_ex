defmodule BigchaindbEx.Utils do
  @doc """
    Generates a unix timestamp with
    the current date and time.
  """
  def gen_timestamp, do: :os.system_time(:seconds)

  @doc """
    Extracts the bits from a given binary
  """
  @spec extract_bits(String.t) :: Enum.t
  def extract_bits(str) when is_binary(str) do
    extract_bits(str, [])
  end
  defp extract_bits(<<b :: size(1), bits :: bitstring>>, acc) when is_bitstring(bits) do
    extract_bits(bits, [b | acc])
  end
  defp extract_bits(<<>>, acc), do: acc |> Enum.reverse
end