defmodule BigchainEx.Http do
  @moduledoc """
  Bigchaindb http client
  """

  use HTTPotion.Base

  @host  Application.get_env(:bigchain_ex, :host)
  @port  Application.get_env(:bigchain_ex, :port)
  @https Application.get_env(:bigchain_ex, :https)

  def process_url(url) do
    path = url
    |> String.split("/")
    |> Enum.join("/")

    bigchain_url() <> path
  end

  # def process_request_headers(headers) do
  # end

  def process_response_body(body) do
    Poison.decode!(body)
  end

  defp bigchain_url do
    url = "#{@host}:#{@port}/"

    if @https do
      "https://" <> url
    else
      url
    end
  end
end