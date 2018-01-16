defmodule BigchaindbEx.Fulfillment do
  @moduledoc """
    Provides functions for handling fulfillments.
  """

  alias BigchaindbEx.Condition.{Ed25519Sha256}
  alias BigchaindbEx.Fulfillment.{Ed25519Sha512}

  # TODO: Add multiple types
  @type t :: Ed25519Sha512.t

  @doc """
    Derives a condition based
    on the given fulfillment.
  """
  @spec get_condition(__MODULE__.t) :: {:ok, :condition} | {:error, String.t}
  def get_condition(%Ed25519Sha512{} = ffl), do: Ed25519Sha512.from_fulfillment(ffl)
  def get_condition(_), do: {:error, "The given fulfillment is invalid!"}

  @doc """
    Gets the uri from a
    given condition struct.
  """
  @spec get_condition_uri(__MODULE__.t) :: {:ok, String.t} | {:error, String.t}
  def get_condition_uri(%Ed25519Sha512{} = ffl) do
    case Ed25519Sha256.from_fulfillment(ffl) do
      {:ok, condition} -> 
        {:ok, Ed25519Sha256.serialize_to_uri(condition.hash)}
      {:error, reason} -> {:error, "Could not get condition from fulfillment: #{inspect reason}"}
    end
  end  
end