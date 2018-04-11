defmodule Zhop.Carts.Cart do
  @moduledoc """
  Documentation for Zhop.Carts.Cart
  """
  alias __MODULE__

  @type t :: %Cart{}

  defstruct [:id, :contents]

  @doc """
  Creates a new Cart

  # Parameters

    - id: Cart ID string

  # Examples

      iex> Zhop.Carts.Cart.new("abcd")
      {:ok, %Zhop.Carts.Cart{id: "abcd", contents: %{}}}

  """
  @spec new(id :: String.t()) :: {:ok, Cart.t()} | {:error, reason :: term}
  def new(id) when is_binary(id) do
    {:ok, %Cart{id: id, contents: Map.new()}}
  end

  @doc """
  Adds items to a cart

  # Parameters

    - cart: cart to add items to
    - id: item ID
    - quantity: number of items to add, defaults to one

  # Examples

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> Zhop.Carts.Cart.add(cart, "ITEM")
      {:ok, %Zhop.Carts.Cart{id: "abcd", contents: %{"ITEM" => 1}}}

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> Zhop.Carts.Cart.add(cart, "ITEM", 5)
      {:ok, %Zhop.Carts.Cart{id: "abcd", contents: %{"ITEM" => 5}}}

  """
  @spec add(cart :: Cart.t(), id :: String.t(), quantity :: integer) ::
          {:ok, Cart.t()} | {:error, reason :: term}
  def add(cart, id, quantity \\ 1)

  def add(cart = %Cart{}, id, quantity) do
    with {:ok, id} <- validate_item_id(id),
         {:ok, quantity} <- validate_quantity(quantity) do
      {:ok, %Cart{cart | contents: Map.update(cart.contents, id, quantity, &(&1 + quantity))}}
    else
      error -> error
    end
  end

  def add(_, _, _), do: {:error, :invalid_argument}

  @doc """
  Removes items from cart

  # Parameters

    - cart: cart to remove items from
    - id: item ID
    - quantity: number of items to remove, defaults to one

  # Examples

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> Zhop.Carts.Cart.remove(cart, "ITEM")
      {:ok, %Zhop.Carts.Cart{id: "abcd", contents: %{}}}

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> {:ok, cart} = Zhop.Carts.Cart.add(cart, "ITEM", 5)
      ...> Zhop.Carts.Cart.remove(cart, "ITEM", 2)
      {:ok, %Zhop.Carts.Cart{id: "abcd", contents: %{"ITEM" => 3}}}

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> {:ok, cart} = Zhop.Carts.Cart.add(cart, "ITEM", 5)
      ...> Zhop.Carts.Cart.remove(cart, "ITEM", 21)
      {:ok, %Zhop.Carts.Cart{id: "abcd", contents: %{}}}

  """
  @spec remove(cart :: Cart.t(), id :: String.t(), quantity :: integer) ::
          {:ok, Cart.t()} | {:error, reason :: term}
  def remove(cart, id, quantity \\ 1)

  def remove(cart = %Cart{}, id, quantity) do
    with {:ok, id} <- validate_item_id(id),
         {:ok, quantity} <- validate_quantity(quantity) do
      current_quantity = Map.get(cart.contents, id)

      cond do
        current_quantity == nil ->
          {:ok, cart}

        current_quantity <= quantity ->
          {:ok, %Cart{cart | contents: Map.delete(cart.contents, id)}}

        true ->
          {:ok, %Cart{cart | contents: Map.put(cart.contents, id, current_quantity - quantity)}}
      end
    else
      error -> error
    end
  end

  def remove(_, _, _, _), do: {:error, :invalid_argument}

  @doc """
  Counts number of items in cart

  # Parameters

    - cart: cart to count items from
    - id: item ID

  # Examples

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> Zhop.Carts.Cart.count(cart, "ITEM")
      0

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> {:ok, cart} = Zhop.Carts.Cart.add(cart, "ITEM", 5)
      ...> Zhop.Carts.Cart.count(cart, "ITEM")
      5

  """
  @spec count(cart :: Cart.t(), id :: String.t()) :: integer
  def count(cart = %Cart{}, id) do
    Map.get(cart.contents, id, 0)
  end

  @doc """
  Determine if cart contains a given item

  # Parameters

    - cart: cart to count items from
    - id: item ID

  # Examples

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> Zhop.Carts.Cart.has(cart, "ITEM")
      false

      iex> {:ok, cart} = Zhop.Carts.Cart.new("abcd")
      ...> {:ok, cart} = Zhop.Carts.Cart.add(cart, "ITEM", 5)
      ...> Zhop.Carts.Cart.has(cart, "ITEM")
      true

  """
  @spec has(cart :: Cart.t(), id :: String.t()) :: boolean
  def has(cart = %Cart{}, id) do
    Map.get(cart.contents, id, 0) !== 0
  end

  defp validate_item_id(item_id) when is_binary(item_id) do
    clean_item_id = String.trim(item_id)

    if String.length(clean_item_id) > 0 do
      {:ok, clean_item_id}
    else
      {:error, :invalid_item_id}
    end
  end

  defp validate_item_id(_), do: {:error, :invalid_item_id}

  defp validate_quantity(quantity) when is_integer(quantity) and quantity >= 0,
    do: {:ok, quantity}

  defp validate_quantity(_), do: {:error, :invalid_quantity}
end
