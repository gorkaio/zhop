defmodule Zhop.Catalog.Repository do
  @moduledoc """
  Catalog repository behaviour
  """
  alias Zhop.Catalog.Item

  @callback find(id :: String.t()) :: {:ok, Item.t()} | {:error, :not_found}
  @callback save(item :: Item.t()) :: :ok | {:error, reason :: term}
end
