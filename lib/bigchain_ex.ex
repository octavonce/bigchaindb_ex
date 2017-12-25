defmodule BigchainEx do
  @moduledoc """
    Documentation for BigchainEx.
  """

  @doc """
    Sends a http request to the root 
    bigchaindb endpoint.
  """
  def api_info do
    BigchainEx.Http.get("")
  end

  @doc """
    Sends a http request to the
    block endpoint with the given 
    block id parameter.
  """  
  def block(block_id) when is_binary(block_id) do
    BigchainEx.Http.get("/api/v1/blocks/#{block_id}")
  end
end
