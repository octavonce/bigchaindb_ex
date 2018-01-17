defmodule BigchaindbEx.Condition do
  @moduledoc """
    Provides crypto conditions general functions.
  """

  alias BigchaindbEx.Fulfillment
  alias BigchaindbEx.Fulfillment.Ed25519Sha512
  alias BigchaindbEx.Condition.{Ed25519Sha256, ThresholdSha256}

  @type t :: Ed25519Sha256.t | ThresholdSha256.t

  @doc """
    Derives a condition from an uri.
  """
  @spec from_uri(String.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def from_uri(uri) when is_binary(uri) do
    # TODO: Pattern match against 
    # the uri to dispatch to
    # each type's from_uri fn
  end

  @doc """
    Derives a condition from
    a given fulfillment.
  """
  @spec from_fulfillment(Fulfillment.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def from_fulfillment(%Ed25519Sha512{} = ffl), do: Ed25519Sha256.from_fulfillment(ffl)
  def from_fulfillment(_), do: {:error, "The given fulfillment is not valid!"}
end