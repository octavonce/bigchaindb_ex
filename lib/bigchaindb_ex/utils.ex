defmodule BigchaindbEx.Utils do
  @doc """
    Generates a unix timestamp with
    the current date and time.
  """
  def gen_timestamp, do: :os.system_time(:seconds)

  @doc """
    Maps a collection in parallel.
  """
  def parallel_map(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end

  @doc """
    Returns the quotient and the 
    remainder of a division.

    # Example:
      iex> divmod(126207244316550804821666916, 256) 
      {492997048111526581334636, 100}
  """
  @spec divmod(number, number) :: {number, number}
  def divmod(a, b) 
    when is_integer(a)
    and  is_integer(b)
  do
   {div(a, b), rem(a, b)}
  end

  @doc """
    Deeply encodes a map to JSON with all of 
    it's keys in alphabetical order.
  """
  def encode_map_to_json_sorted_keys(map) when is_map(map) do
    az_keys = map 
    |> Map.keys 
    |> Enum.sort

    iodata = [
      "{",
      Enum.map(az_keys, fn k ->
        v = map[k]
        [Poison.encode!(k), ":", encode_map_to_json_sorted_keys(v)]
      end) |> Enum.intersperse(","),
      "}"
    ]
    IO.iodata_to_binary(iodata)
  end
  def encode_map_to_json_sorted_keys(list = [head | _]) when is_map(head) do
    iodata = [
      "[",
      list
      |> Enum.map(&encode_map_to_json_sorted_keys/1)
      |> Enum.intersperse(","),
      "]"
    ]
    
    IO.iodata_to_binary(iodata)
  end
  def encode_map_to_json_sorted_keys(val), do: Poison.encode!(val)
end