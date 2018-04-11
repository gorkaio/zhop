defmodule Zhop.Catalog.Repository.Fixtures do
  @moduledoc """
  Catalog in memory repository with preloaded fixtures
  """
  @behaviour Zhop.Catalog.Repository
  alias Zhop.Catalog.Item

  use GenServer

  @doc false
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: via_tuple())
  end

  @doc false
  def via_tuple do
    {:via, :gproc, {:n, :l, :catalog_repository}}
  end

  @doc false
  def init(_args) do
    {:ok, Map.new(initial_data(), fn {:ok, item} -> {item.id, item} end)}
  end

  defp initial_data do
    [
      Item.new("TEST", "TEST PRODUCT", :product, Money.new(3_20))
    ]
  end

  def find(id) do
    GenServer.call(via_tuple(), {:find, id})
  end

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
