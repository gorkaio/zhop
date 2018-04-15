defmodule Zhop.Carts.Repository.Memory do
  @moduledoc """
  Cart in memory repository implementation
  """
  @behaviour Zhop.Carts.Repository
  alias Zhop.Carts.Cart

  use GenServer

  @doc false
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: via_tuple())
  end

  @doc false
  def via_tuple do
    {:via, :gproc, {:n, :l, :carts_repository}}
  end

  @doc false
  def init(_args) do
    {
      :ok,
      Map.new(initial_data(), fn %{cart: cart, contents: contents} ->
        {
          cart.id,
          build_cart(cart, contents)
        }
      end)
    }
  end

  defp build_cart(%Cart{} = cart, contents) do
    Enum.reduce(contents, cart, fn {item, quantity}, cart ->
      with {:ok, cart} <- Cart.add(cart, item, quantity) do
        cart
      end
    end)
  end

  defp initial_data do
    [
      %{cart: Cart.new("CART1"), contents: %{"T-SHIRT" => 1, "VOUCHER" => 3}},
      %{cart: Cart.new("CART2"), contents: %{"VOUCHER" => 10}},
      %{cart: Cart.new("CART3"), contents: %{}}
    ]
  end

  # API

  @doc """
  Finds a cart by ID

  ## Parameters

    - id: ID of the searched cart

  ## Examples

      iex> cart = Zhop.Carts.Cart.new("CART")
      ...> Zhop.Carts.Repository.Memory.save(cart)
      ...> Zhop.Carts.Repository.Memory.find("CART")
      {:ok, %Zhop.Carts.Cart{id: "CART", contents: %{}}}

      iex> Zhop.Carts.Repository.Memory.find("UNEXISTING_CART")
      {:error, :not_found}

  """
  @spec find(id :: String.t()) :: {:ok, Cart.t()} | {:error, :not_found}
  def find(id) do
    GenServer.call(via_tuple(), {:find, id})
  end

  @doc """
  Saves a cart in the repository

  ## Parameters

    - cart: Zhop.Carts.Cart to save

  ## Examples

      iex> cart = Zhop.Carts.Cart.new("CART")
      ...> Zhop.Carts.Repository.Memory.save(cart)
      :ok

  """
  @spec save(item :: Cart.t()) :: :ok
  def save(%Cart{} = cart) do
    GenServer.call(via_tuple(), {:save, cart})
  end

  # SERVER

  def handle_call({:find, id}, _from, status) do
    case Map.get(status, id) do
      nil -> {:reply, {:error, :not_found}, status}
      cart -> {:reply, {:ok, cart}, status}
    end
  end

  def handle_call({:save, %Cart{} = cart}, _from, status) do
    {:reply, :ok, Map.put(status, cart.id, cart)}
  end
end
