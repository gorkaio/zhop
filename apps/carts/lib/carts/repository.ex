defmodule Zhop.Carts.Repository do
  @moduledoc """
  Cart repository behaviour
  """
  alias Zhop.Carts.Cart

  @repository Application.get_env(:carts, :repository)

  @callback find(id :: String.t()) :: {:ok, Cart.t()} | {:error, :not_found}
  @callback save(cart :: Cart.t()) :: :ok | {:error, reason :: term}

  def find(id) do
    @repository.find(id)
  end

  def save(cart) do
    @repository.save(cart)
  end
end
