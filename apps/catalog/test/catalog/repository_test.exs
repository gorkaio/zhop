defmodule Zhop.Catalog.RepositoryTest do
  alias Zhop.Catalog.{Item, Repository}
  use ExUnit.Case
  doctest Repository

  test "it finds existing items" do
    {:ok, item} = Item.new("TEST-ITEM", "My test item", :product, Money.new(12_00))
    :ok = Repository.save(item)
    assert {:ok, item} == Repository.find("TEST-ITEM")
  end

  test "it returns a :not_found error trying to find non existing items" do
    assert {:error, :not_found} == Repository.find("___NON EXISTING ITEM___")
  end

  test "it updates existing items" do
    {:ok, item} = Item.new("TEST1", "Test 1", :product, Money.new(12_00))
    :ok = Repository.save(item)
    {:ok, item} = Item.update_name(item, "New Test name")
    :ok = Repository.save(item)
    assert {:ok, item} == Repository.find("TEST1")
  end
end
