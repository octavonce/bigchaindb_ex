defmodule BigchaindbEx.Http do
  @moduledoc """
    Bigchaindb http client
  """

  use HTTPotion.Base

  @host    Application.get_env(:bigchaindb_ex, :host)
  @port    Application.get_env(:bigchaindb_ex, :port)
  @https   Application.get_env(:bigchaindb_ex, :https)
  @app_id  Application.get_env(:bigchaindb_ex, :app_id)
  @app_key Application.get_env(:bigchaindb_ex, :app_key)

  def process_url(url) do
    path = url
    |> String.split("/")
    |> Enum.join("/")

    bigchain_url() <> path
  end

  def process_request_headers(headers) do
    if is_binary(@app_id) and is_binary(@app_key) do
      headers
      |> Map.put("app_id", @app_id)
      |> Map.put("app_key", @app_key)
    else
      headers
    end
  end

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