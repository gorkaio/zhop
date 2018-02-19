defmodule Zhop.Catalog.Repository.MemoryRepositoryTest do
  alias Zhop.Catalog.{Item, Repository.MemoryRepository}
  use ExUnit.Case, async: false
  doctest MemoryRepository

  test "it finds existing items" do
    {:ok, item} = Item.new("TEST-ITEM", "My test item", :product, Money.new(12_00))
    :ok = MemoryRepository.save(item)
    assert {:ok, item} == MemoryRepository.find("TEST-ITEM")
  end

  test "it returns a :not_found error trying to find non existing items" do
    assert {:error, :not_found} == MemoryRepository.find("___NON EXISTING ITEM___")
  end

  test "it updates existing items" do
    {:ok, item} = Item.new("TEST1", "Test 1", :product, Money.new(12_00))
    :ok = MemoryRepository.save(item)
    {:ok, item} = Item.update_name(item, "New Test name")
    :ok = MemoryRepository.save(item)
    assert {:ok, item} == MemoryRepository.find("TEST1")
  end
end
