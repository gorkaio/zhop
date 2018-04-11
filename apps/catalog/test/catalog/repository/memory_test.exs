defmodule Zhop.Catalog.Repository.MemoryTest do
  alias Zhop.Catalog.{Item, Repository.Memory}
  use ExUnit.Case, async: false
  doctest Memory

  test "it finds existing items" do
    {:ok, item} = Item.new("TEST-ITEM", "My test item", :product, Money.new(12_00))
    :ok = Memory.save(item)
    assert {:ok, item} == Memory.find("TEST-ITEM")
  end

  test "it returns a :not_found error trying to find non existing items" do
    assert {:error, :not_found} == Memory.find("___NON EXISTING ITEM___")
  end

  test "it updates existing items" do
    {:ok, item} = Item.new("TEST1", "Test 1", :product, Money.new(12_00))
    :ok = Memory.save(item)
    {:ok, item} = Item.update_name(item, "New Test name")
    :ok = Memory.save(item)
    assert {:ok, item} == Memory.find("TEST1")
  end
end
