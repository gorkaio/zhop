defmodule Zhop.Catalog do
  @moduledoc """
  Catalog module of the Zhop project.

  Allows retrieving information of existing products
  """
  alias Zhop.Catalog.{Item, Repository}

  @repository Application.get_env(:catalog, :repository)

  @doc """
  Gets name for a given item

  ## Parameters

    - id: ID of the searched item
 
  """
  @spec name(id :: String.t()) :: {:ok, String.t()} | {:error, reason :: term}
  def name(id) do
    with {:ok, item} <- @repository.find(id)
    do
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
  @spec price(id :: String.t()) :: {:ok, String.t()} | {:error, reason :: term}
  def price(id) do
    with {:ok, item} <- @repository.find(id)
    do
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
    with {:ok, item} <- @repository.find(id)
    do
      {:ok, item.type}
    else
      error -> error
    end
  end
end
