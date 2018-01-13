defmodule BigchainEx.Utils do
  @doc """
    Generates a unix timestamp with
    the current date and time.
  """
  def gen_timestamp, do: :os.system_time(:seconds)
end