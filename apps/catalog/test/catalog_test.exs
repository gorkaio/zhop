defmodule Zhop.CatalogTest do
  use ExUnit.Case, async: false
  import Mox
  doctest Zhop.Catalog

  # @todo Setting a mock for a supervised process under the same app tree
  #   is harder than expected. Look into this and try to mock the repo instead
  #   of using the fixtured one.

  setup [:verify_on_exit!]

  test "gets price of existing items" do
    assert Zhop.Catalog.price("TEST") == {:ok, Money.new(3_20)}
  end

  test "returns error :not_found trying to get price of non existing items" do
    assert Zhop.Catalog.price("NON_EXISTING_ITEM") == {:error, :not_found}
  end

  test "gets name of existing items" do
    assert Zhop.Catalog.name("TEST") == {:ok, "TEST PRODUCT"}
  end

  test "returns error :not_found trying to get name of non existing items" do
    assert Zhop.Catalog.name("NON_EXITING_ITEM") == {:error, :not_found}
  end

  test "gets type of existing items" do
    assert Zhop.Catalog.type("TEST") == {:ok, :product}
  end

  test "returns error :not_found trying to get type of non existing items" do
    assert Zhop.Catalog.type("NON_EXISTING_ITEM") == {:error, :not_found}
  end
end
