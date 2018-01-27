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
    with {:ok, type} <- decode_type_from_uri(uri) do
      ed25519_type = Ed25519Sha256.type_name()

      case type do
        ^ed25519_type  -> Ed25519Sha256.from_uri(uri)
        _              -> {:error, "The condition type from the given uri is invalid!"}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
    Converts a condition
    to an uri.
  """
  @spec to_uri(__MODULE__.t) :: {:ok, String.t} | {:error, String.t}
  def to_uri(%Ed25519Sha256{} = condition), do: Ed25519Sha256.to_uri(condition)
  def to_uri(_), do: {:error, "The given condition is invalid!"}

  @doc """
    Derives a condition from
    a given fulfillment.
  """
  @spec from_fulfillment(Fulfillment.t) :: {:ok, __MODULE__.t} | {:error, String.t}
  def from_fulfillment(%Ed25519Sha512{} = ffl), do: Ed25519Sha256.from_fulfillment(ffl)
  def from_fulfillment(_), do: {:error, "The given fulfillment is not valid!"}

  @doc """
    Decodes the hash from a given uri.
  """
  @spec decode_hash_from_uri(String.t) :: {:ok, binary} | {:error, String.t}
  def decode_hash_from_uri(uri) when is_binary(uri) do
    with [_, str]    <- String.split(uri, "ni:///sha-256;"),
         [hash, _]   <- String.split(str, "?fpt="),
         {:ok, hash} <- Base.url_decode64(hash)
    do
      {:ok, hash}
    else
      _ -> {:error, "Could not decode hash!"}
    end
  end

  @doc """
    Decodes the condition
    type from a given uri.
  """
  @spec decode_type_from_uri(String.t) :: {:ok, String.t} | {:error, String.t}
  def decode_type_from_uri(uri) when is_binary(uri) do
    with [_, str]    <- String.split(uri, "?fpt="),
         [type, _]   <- String.split(str, "&cost=")
    do
      {:ok, type}
    else
      _ -> {:error, "Could not decode type!"}
    end
  end
end