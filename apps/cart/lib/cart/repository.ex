defmodule Zhop.Carts.Repository do
    @moduledoc """
    Cart repository behaviour
    """
    alias Zhop.Carts.Cart
  
    @callback find(id :: String.t()) :: {:ok, Cart.t()} | {:error, :not_found}
    @callback save(cart :: Cart.t()) :: :ok | {:error, reason :: term}
  end