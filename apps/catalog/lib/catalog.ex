defmodule Zhop.Catalog do
  @moduledoc """
  Catalog module of the Zhop project.

  Manages information about products.

  This should be the only module used by other applications, and defines its contract via behaviour.
  """
  alias Zhop.Catalog.{Item, Repository}

  # This should be the only exposed module for this app.
  # Make it a contract for other modules by defining its behaviour.
  @callback name(id :: String.t()) :: {:ok, String.t()} | {:error, reason :: term}
  @callback price(id :: String.t()) :: {:ok, Money.t()} | {:error, reason :: term}
  @callback type(id :: String.t()) :: {:ok, Item.types()} | {:error, reason :: term}

  @doc """
  Gets name for a given item

  ## Parameters

    - id: ID of the searched item

  """
  @spec name(id :: String.t()) :: {:ok, String.t()} | {:error, reason :: term}
  def name(id) do
    with {:ok, item} <- Repository.find(id) do
      {:ok, item.name}
    else
      error -> error
    end
  end

  @doc """
  Gets price of given item

  ## Parameters

    - id: ID of the searched item

  """
  @spec price(id :: String.t()) :: {:ok, Money.t()} | {:error, reason :: term}
  def price(id) do
    with {:ok, item} <- Repository.find(id) do
      {:ok, item.price}
    else
      error -> error
    end
  end

  @doc """
  Gets type of given item

  # Parameters

    - id: ID of the searched item

  """
  @spec type(id :: String.t()) :: {:ok, Item.types()} | {:error, reason :: term}
  def type(id) do
    with {:ok, item} <- Repository.find(id) do
      {:ok, item.type}
    else
      error -> error
    end
  end
end
