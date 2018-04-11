defmodule Zhop.Catalog.ItemTest do
  alias Zhop.Catalog.Item
  use ExUnit.Case, async: true
  use Quixir
  doctest Item

  test "it does not allow empty IDs" do
    assert {:error, :invalid_item_id} == Item.new("", "My test", :product, Money.new(12_00))
  end

  test "it dues not allow blank IDs" do
    assert {:error, :invalid_item_id} == Item.new("   ", "My test", :product, Money.new(12_00))
  end

  test "it does not allow lowercase ids" do
    assert {:error, :invalid_item_id} == Item.new("test", "My test", :product, Money.new(34_00))
  end

  test "it allows hyphens and underscores in item ids" do
    assert {:ok,
            %Item{id: "__T-E-S-T__", name: "My test", type: :product, price: Money.new(12_00)}} ==
             Item.new("__T-E-S-T__", "My test", :product, Money.new(12_00))
  end

  test "it does not allow ids larger than 32 chars" do
    ptest id: string(min: 33, chars: :upper) do
      assert {:error, :invalid_item_id} == Item.new(id, "My test", :product, Money.new(34_00))
    end
  end

  test "it does not allow empty names" do
    assert {:error, :invalid_item_name} == Item.new("TEST", "", :product, Money.new(12_00))
  end

  test "it does not allow blank names" do
    assert {:error, :invalid_item_name} == Item.new("TEST", "  ", :product, Money.new(12_00))
  end

  test "it allows values greater then zero for product prices" do
    ptest amount: int(min: 1) do
      assert {:ok, %Item{id: "TEST", name: "My test", type: :product, price: Money.new(amount)}} ==
               Item.new("TEST", "My test", :product, Money.new(amount))
    end
  end

  test "it does not allow values equal or below zero for product prices" do
    ptest amount: int(max: 0) do
      assert {:error, :invalid_item_price} ==
               Item.new("TEST", "My test", :product, Money.new(amount))
    end
  end

  test "it allows values lesser than zero for discount prices" do
    ptest amount: int(max: -1) do
      assert {:ok, %Item{id: "TEST", name: "My test", type: :discount, price: Money.new(amount)}} ==
               Item.new("TEST", "My test", :discount, Money.new(amount))
    end
  end

  test "it does not allow values equal or greater than zero for discounts" do
    ptest amount: int(min: 0) do
      assert {:error, :invalid_item_price} ==
               Item.new("TEST", "My test", :discount, Money.new(amount))
    end
  end

  test "it does not allow unknown types" do
    assert {:error, :invalid_item_data} == Item.new("TEST", "My test", :unknown, Money.new(12_00))
  end

  test "it creates products" do
    ptest id: string(min: 1, max: 32, chars: :upper),
          name: string(min: 1, must_have: ["a"]),
          amount: positive_int() do
      assert {:ok, %Item{id: id, name: name, type: :product, price: Money.new(amount)}} ==
               Item.new(id, name, :product, Money.new(amount))
    end
  end

  test "it creates discounts" do
    ptest id: string(min: 1, max: 32, chars: :upper),
          name: string(min: 1, must_have: ["a"]),
          amount: negative_int() do
      assert {:ok, %Item{id: id, name: name, type: :discount, price: Money.new(amount)}} ==
               Item.new(id, name, :discount, Money.new(amount))
    end
  end

  test "it allows renaming items" do
    ptest name: string(min: 1, must_have: ["a"]) do
      {:ok, item} = Item.new("TEST", "My test", :product, Money.new(12_00))
      {:ok, item} = Item.update_name(item, name)
      assert item.name == name
    end
  end

  test "it allows updating price of products with positive amounts" do
    ptest amount: int(min: 1) do
      {:ok, item} = Item.new("TEST", "My test", :product, Money.new(12_00))
      {:ok, item} = Item.update_price(item, Money.new(amount))
      assert item.price == Money.new(amount)
    end
  end

  test "it does not allow updating price of products with non positive amounts" do
    ptest amount: int(max: 0) do
      {:ok, item} = Item.new("TEST", "My test", :product, Money.new(12_00))
      assert {:error, :invalid_item_price} == Item.update_price(item, Money.new(amount))
    end
  end

  test "it allows updating price of discounts with negative amounts" do
    ptest amount: int(max: -1) do
      {:ok, item} = Item.new("TEST", "My test", :discount, Money.new(-12_00))
      {:ok, item} = Item.update_price(item, Money.new(amount))
      assert item.price == Money.new(amount)
    end
  end

  test "it does not allow updating prices of discounts with positive amounts" do
    ptest amount: int(min: 0) do
      {:ok, item} = Item.new("TEST", "My test", :discount, Money.new(-12_00))
      assert {:error, :invalid_item_price} == Item.update_price(item, Money.new(amount))
    end
  end
end
