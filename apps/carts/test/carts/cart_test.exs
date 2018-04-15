defmodule Zhop.Carts.CartTest do
  use ExUnit.Case, async: true
  doctest Zhop.Carts.Cart
  alias Zhop.Carts.Cart
  @uuid "757b3d55-13b0-4cb2-90be-448e67e4532b"

  test "determines if cart has an item" do
    cart = Cart.new(@uuid)
    assert Cart.has(cart, "ITEM") == false
    {:ok, cart} = Cart.add(cart, "ITEM")
    assert Cart.has(cart, "ITEM") == true
    {:ok, cart} = Cart.remove(cart, "ITEM")
    assert Cart.has(cart, "ITEM") == false
  end

  test "counts items in cart" do
    cart = Cart.new(@uuid)
    assert Cart.count(cart, "ITEM") == 0
    {:ok, cart} = Cart.add(cart, "ITEM", 3)
    assert Cart.count(cart, "ITEM") == 3
  end

  test "adds new items to cart defaulting to one unit" do
    cart = Cart.new(@uuid)
    assert Cart.has(cart, "ITEM") == false
    {:ok, cart} = Cart.add(cart, "ITEM")
    assert Cart.count(cart, "ITEM") == 1
  end

  test "adds new items to cart allowing to specify quantity" do
    cart = Cart.new(@uuid)
    assert Cart.has(cart, "ITEM") == false
    {:ok, cart} = Cart.add(cart, "ITEM", 13)
    assert Cart.count(cart, "ITEM") == 13
  end

  test "decreases item units from cart when removing less than existing" do
    cart = Cart.new(@uuid)
    assert Cart.has(cart, "ITEM") == false
    {:ok, cart} = Cart.add(cart, "ITEM", 13)
    {:ok, cart} = Cart.remove(cart, "ITEM", 3)
    assert Cart.count(cart, "ITEM") == 10
  end

  test "removes existing items from cart when removing all existing units" do
    cart = Cart.new(@uuid)
    assert Cart.has(cart, "ITEM") == false
    {:ok, cart} = Cart.add(cart, "ITEM", 13)
    {:ok, cart} = Cart.remove(cart, "ITEM", 13)
    assert Cart.count(cart, "ITEM") == 0
  end

  test "removes existing items from cart when removing more than existing" do
    cart = Cart.new(@uuid)
    assert Cart.has(cart, "ITEM") == false
    {:ok, cart} = Cart.add(cart, "ITEM", 13)
    {:ok, cart} = Cart.remove(cart, "ITEM", 15)
    assert Cart.count(cart, "ITEM") == 0
  end
end
