defmodule Zhop.Carts do
  @moduledoc """
  Carts module of the Zhop project.

  Manages information about carts.

  This should be the only module used by other applications, and defines its contract via behaviour.
  """
  alias Zhop.Carts.{CartServer, CartsSupervisor}

  @catalog Application.get_env(:carts, :catalog)

  # This should be the only exposed module for this app.
  # Make it a contract for other modules by defining its behaviour.
  @callback create() :: {:ok, id :: String.t()} | {:error, reason :: term}
  @callback contents(id :: String.t()) :: {:ok, %{}} | {:error, reason :: term}
  @callback price(id :: String.t()) :: {:ok, amount :: Money.t()} | {:error, reason :: term}
  @callback add(id :: String.t(), item :: String.t(), quantity :: integer) :: :ok | {:error, reason :: term}
  @callback remove(id :: String.t(), item :: String.t(), quantity :: integer) :: :ok | {:error, reason :: term}

  @doc """
  Creates a new cart and assigns it an ID for future reference
  """
  @spec create() :: {:ok, id :: String.t()} | {:error, reason :: term}
  def create do
    id = UUID.uuid4()

    with {:ok, _pid} <- CartsSupervisor.new(id) do
      {:ok, id}
    else
      error -> error
    end
  end

  @doc """
  Gets contents of a cart

  ## Parameters

    - id: Cart ID

  """
  @spec contents(id :: String.t()) :: {:ok, %{}} | {:error, reason :: term}
  def contents(id) do
    with {:ok, _pid} <- CartsSupervisor.start(id) do
      {
        :ok,
        Enum.map(CartServer.state(id).contents, fn {item, quantity} ->
          with {:ok, name} <- @catalog.name(item),
               {:ok, price} <- @catalog.price(item) do
            %{
              id: item,
              name: name,
              quantity: quantity,
              price_unit: price,
              price_total: Money.multiply(price, quantity)
            }
          else
            error -> error
          end
        end)
      }
    else
      error -> error
    end
  end

  @doc """
  Calculates total price of a cart

  ## Parameters

    - id: Cart ID

  """
  @spec price(id :: String.t()) :: {:ok, amount :: Money.t()} | {:error, reason :: term}
  def price(id) do
    with {:ok, contents} <- contents(id) do
      {
        :ok,
        Enum.reduce(contents, Money.new(0), fn line, total ->
          Money.add(total, line.price_total)
        end)
      }
    else
      error -> error
    end
  end

  @doc """
  Adds an item to an existing cart

  ## Parameters

    - id: Cart ID
    - item: Item ID
    - quantity: Numbers of items to add

  """
  @spec add(id :: String.t(), item :: String.t(), quantity :: integer) :: :ok | {:error, reason :: term}
  def add(id, item, quantity \\ 1) do
    with {:ok, _pid} <- CartsSupervisor.start(id) do
      CartServer.add(id, item, quantity)
    else
      error -> error
    end
  end

  @doc """
  Removes a certain item from cart

  ## Parameters

    - id: Cart ID
    - item: Item ID
    - quantity: Number of items to remove

  """
  @spec remove(id :: String.t(), item :: String.t(), quantity :: integer) :: :ok | {:error, reason :: term}
  def remove(id, item, quantity \\ 1) do
    with {:ok, _pid} <- CartsSupervisor.start(id) do
      CartServer.remove(id, item, quantity)
    else
      error -> error
    end
  end
end
