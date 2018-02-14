defmodule Zhop.Catalog.Repository do
  @moduledoc """
  Catalog repository
  """
  alias Zhop.Catalog.Item
  
  use GenServer

  @doc false
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: via_tuple())
  end

  @doc false
  def via_tuple() do
    {:via, :gproc, {:n, :l, :catalog_repository}}
  end

  @doc false
  def init(_args) do
    {:ok, Map.new(initial_data(), fn {:ok, item} -> {item.id, item} end)}
  end

  defp initial_data() do
    [
      Item.new("VOUCHER", "Voucher", :product, Money.new(12_00)),
      Item.new("T-SHIRT", "Awesome T-Shirt", :product, Money.new(22_34)),
      Item.new("FTW-MUG", "4DW Coffee Mug", :product, Money.new(7_10))
    ]
  end

  # API

  @doc """
  Finds an item by ID

  ## Parameters

    - id: ID of the searched item

  ## Examples

      iex> {:ok, item} = Zhop.Catalog.Item.new("ITEM", "My item", :product, Money.new(12_00))
      ...> Zhop.Catalog.Repository.save(item)
      ...> Zhop.Catalog.Repository.find("ITEM")
      {:ok, %Zhop.Catalog.Item{id: "ITEM", name: "My item", type: :product, price: Money.new(12_00)}}

      iex> Zhop.Catalog.Repository.find("UNEXISTING_ITEM")
      {:error, :not_found}

  """
  @spec find(id :: String.t()) :: {:ok, Item.t()} | {:error, :item_not_found}
  def find(id) do
    GenServer.call(via_tuple(), {:find, id})  
  end

  @doc """
  Saves an item into the repository

  ## Parameters

    - item: Zhop.Catalog.Item to save

  ## Examples

      iex> {:ok, item} = Zhop.Catalog.Item.new("ITEM", "My item", :product, Money.new(12_00))
      ...> Zhop.Catalog.Repository.save(item)
      :ok

  """
  @spec save(item :: Item.t()) :: :ok
  def save(%Item{} = item) do
    GenServer.call(via_tuple(), {:save, item})
  end
  

  # SERVER

  def handle_call({:find, id}, _from, status) do
    case Map.get(status, id) do
      nil -> {:reply, {:error, :not_found}, status}
      item -> {:reply, {:ok, item}, status}
    end
  end

  def handle_call({:save, %Item{} = item}, _from, status) do
    {:reply, :ok, Map.put(status, item.id, item)}
  end
end
