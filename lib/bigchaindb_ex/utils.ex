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
end