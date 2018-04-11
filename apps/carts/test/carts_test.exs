defmodule Zhop.CartsTest do
  use ExUnit.Case, async: true
  alias Zhop.Carts
  import Mox

  setup :verify_on_exit!

  test "it returns error :not_found asking for contents of non existing cart" do
    assert Carts.contents("NON_EXISTING_CART") === {:error, :not_found}
  end

  test "it returns error :not_found asking for price of non existing cart" do
    assert Carts.price("NON_EXISTING_CART") === {:error, :not_found}
  end

  test "it returns error :not_found asking to add contents to non existing cart" do
    assert Carts.add("NON_EXISTING_CART", "ITEM", 2) === {:error, :not_found}
  end

  test "it returns error :not_found asking to remove contents from non existing cart" do
    assert Carts.remove("NON_EXISTING_CART", "ITEM", 2) === {:error, :not_found}
  end

  test "it creates new carts" do
    {:ok, id} = Carts.create()
    assert Carts.price(id) === {:ok, Money.new(0)}
    assert Carts.contents(id) === {:ok, []}
  end

  test "it returns contents for empty carts" do
    {:ok, id} = Carts.create()
    assert Carts.contents(id) === {:ok, []}
  end

  test "it returns contents for carts with content" do
    Zhop.Catalog.Mock
    |> expect(:name, fn "ITEM1" -> {:ok, "Item 1"} end)
    |> expect(:name, fn "ITEM2" -> {:ok, "Item 2"} end)
    |> expect(:price, fn "ITEM1" -> {:ok, Money.new(12_25)} end)
    |> expect(:price, fn "ITEM2" -> {:ok, Money.new(5_10)} end)

    {:ok, id} = Carts.create()
    Carts.add(id, "ITEM1")
    Carts.add(id, "ITEM2", 3)

    assert Carts.contents(id) === {
             :ok,
             [
               %{
                 id: "ITEM1",
                 name: "Item 1",
                 price_total: Money.new(12_25),
                 price_unit: Money.new(12_25),
                 quantity: 1
               },
               %{
                 id: "ITEM2",
                 name: "Item 2",
                 price_total: Money.new(15_30),
                 price_unit: Money.new(5_10),
                 quantity: 3
               }
             ]
           }
  end

  test "it returns zero as total price for empty carts" do
    {:ok, id} = Carts.create()
    assert Carts.price(id) === {:ok, Money.new(0)}
  end

  test "it returns total price for carts with content" do
    Zhop.Catalog.Mock
    |> expect(:name, fn "ITEM1" -> {:ok, "Item 1"} end)
    |> expect(:name, fn "ITEM2" -> {:ok, "Item 2"} end)
    |> expect(:price, fn "ITEM1" -> {:ok, Money.new(12_25)} end)
    |> expect(:price, fn "ITEM2" -> {:ok, Money.new(5_10)} end)

    {:ok, id} = Carts.create()
    Carts.add(id, "ITEM1")
    Carts.add(id, "ITEM2", 3)
    assert Carts.price(id) === {:ok, Money.new(27_55)}
  end
end
