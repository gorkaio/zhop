defmodule Zhop.Catalog.Repository do
  @moduledoc """
  Catalog repository behaviour
  """
  alias Zhop.Catalog.Item
  @repository Application.get_env(:catalog, :repository)

  @callback find(id :: String.t()) :: {:ok, Item.t()} | {:error, :not_found}
  @callback save(item :: Item.t()) :: :ok | {:error, reason :: term}

  def find(id) do
    @repository.find(id)
  end

  def save(item) do
    @repository.save(item)
  end
end
