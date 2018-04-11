defmodule Zhop.Carts.Repository.MemoryTest do
  alias Zhop.Carts.{Cart, Repository.Memory}
  use ExUnit.Case, async: false
  doctest Memory

  test "it finds existing carts" do
    {:ok, cart} = Cart.new("TEST")
    :ok = Memory.save(cart)
    assert {:ok, cart} == Memory.find("TEST")
  end

  test "it returns a :not_found error trying to find non existing carts" do
    assert {:error, :not_found} == Memory.find("___NON EXISTING CART___")
  end

  test "it updates existing carts" do
    {:ok, cart} = Cart.new("TEST")
    :ok = Memory.save(cart)
    {:ok, cart} = Cart.add(cart, "T-SHIRT", 3)
    :ok = Memory.save(cart)
    assert {:ok, cart} == Memory.find("TEST")
  end
end
