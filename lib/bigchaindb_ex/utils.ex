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
end