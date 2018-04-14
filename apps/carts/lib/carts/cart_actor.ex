defmodule Zhop.Carts.CartActor do
  @moduledoc """
  Cart Actor
  """
  use GenServer
  alias Zhop.Carts.{Cart, Repository}

  @timeout 10_000

  # CLIENT

  @doc """
  Creates a new cart process

  ## Parameters

    - id: Cart ID

  """
  @spec new(id :: String.t()) :: {:ok, pid} | {:error, reason :: term}
  def new(id) do
    with {:pid, {:error, :not_found}} <- {:pid, pid(id)},
         {:repo, {:error, :not_found}} <- {:repo, Repository.find(id)},
         {:ok, cart} <- Cart.new(id),
         :ok <- Repository.save(cart) do
      GenServer.start_link(__MODULE__, cart, name: via_tuple(id))
    end
  end

  @doc """
  Starts or retrieves a cart process

  ## Parameters

    - id: Cart ID

  """
  @spec start(id :: String.t()) :: {:ok, pid} | {:error, reason :: term}
  def start(id) do
    with {:pid, {:error, :not_found}} <- {:pid, pid(id)},
         {:repo, {:ok, cart}} <- {:repo, Repository.find(id)} do
      GenServer.start_link(__MODULE__, cart, name: via_tuple(id))
    else
      {:pid, {:ok, pid}} -> {:ok, pid}
      {:repo, {:error, error}} -> {:error, error}
    end
  end

  @doc false
  def via_tuple(id) do
    {:via, :gproc, process(id)}
  end

  @doc """
  Gets PID for a given cart id

  ## Parameters

    - id: Cart ID

  """
  @spec pid(id :: String.t()) :: {:ok, pid} | {:error, :not_found}
  def pid(id) do
    case :gproc.whereis_name(process(id)) do
      :undefined -> {:error, :not_found}
      pid -> {:ok, pid}
    end
  end

  @doc false
  defp process(id) do
    {:n, :l, {:cart, id}}
  end

  @doc false
  def init(%Cart{} = cart) do
    {:ok, cart, @timeout}
  end

  @doc """
  Adds an item to a cart

  ## Parameters

    - id: Cart ID
    - item: Item ID
    - quantity: number of items to add

  """
  @spec add(id :: String.t(), item :: String.t(), quantity :: integer) :: :ok
  def add(id, item, quantity \\ 1) do
    GenServer.cast(via_tuple(id), {:add, item, quantity})
  end

  @doc """
  Removes an item from the given cart

  ## Parameters

    - id: Cart ID
    - item: Item ID
    - quantity: numbre of items to remove

  """
  @spec remove(id :: String.t(), item :: String.t(), quantity :: integer) :: :ok
  def remove(id, item, quantity \\ 1) do
    GenServer.cast(via_tuple(id), {:remove, item, quantity})
  end

  @doc """
  Checks if given cart contains an item

  ## Parameters

    - id: Cart ID
    - item: Item ID

  """
  @spec has(id :: String.t(), item :: String.t()) :: {:ok, result :: boolean} | {:error, result :: boolean}
  def has(id, item) do
    GenServer.call(via_tuple(id), {:has, item})
  end

  @doc """
  Counts number of a certain item in a cart

  ## Parameters

    - id: Cart ID
    - item: Item ID

  """
  def count(id, item) do
    GenServer.call(via_tuple(id), {:count, item})
  end

  @doc """
  Gets state for a given cart process

  ## Parameters

    id: Cart ID

  """
  def state(id) do
    GenServer.call(via_tuple(id), :state)
  end

  # SERVER

  def handle_cast({:add, item, quantity}, %Cart{} = cart) do
    with {:ok, cart} <- Cart.add(cart, item, quantity) do
      Repository.save(cart)
      {:noreply, cart}
    end
  end

  def handle_cast({:remove, item, quantity}, %Cart{} = cart) do
    with {:ok, cart} <- Cart.remove(cart, item, quantity) do
      Repository.save(cart)
      {:noreply, cart}
    end
  end

  def handle_call({:has, item}, _from, %Cart{} = cart) do
    {:reply, Cart.has(cart, item), cart}
  end

  def handle_call({:count, item}, _from, %Cart{} = cart) do
    {:reply, Cart.count(cart, item), cart}
  end

  def handle_call(:state, _from, %Cart{} = cart) do
    {:reply, cart, cart}
  end

  def handle_info(:timeout, _cart) do
    {:stop, :normal, []}
  end
end
