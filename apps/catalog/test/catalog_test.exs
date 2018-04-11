defmodule Zhop.CatalogTest do
  use ExUnit.Case, async: false
  import Mox
  doctest Zhop.Catalog

  alias Zhop.Catalog

  setup [:verify_on_exit!]

  test "gets price of existing items" do
    assert Catalog.price("TEST") == {:ok, Money.new(3_20)}
  end

  test "returns error :not_found trying to get price of non existing items" do
    assert Catalog.price("NON_EXISTING_ITEM") == {:error, :not_found}
  end

  test "gets name of existing items" do
    assert Catalog.name("TEST") == {:ok, "TEST PRODUCT"}
  end

  test "returns error :not_found trying to get name of non existing items" do
    assert Catalog.name("NON_EXITING_ITEM") == {:error, :not_found}
  end

  test "gets type of existing items" do
    assert Catalog.type("TEST") == {:ok, :product}
  end

  test "returns error :not_found trying to get type of non existing items" do
    assert Catalog.type("NON_EXISTING_ITEM") == {:error, :not_found}
  end
end
