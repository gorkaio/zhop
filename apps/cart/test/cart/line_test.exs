defmodule Zhop.Cart.LineTest do
  alias Zhop.Cart.Line
  use Quixir
  use ExUnit.Case, async: true
  doctest Line

  test "defaults creation to a quantity of one" do
    assert {:ok, %Line{item: "TEST", quantity: 1}} == Line.new("TEST")
  end

  test "does not allow non string item ids" do
    assert {:error, :invalid_item} == Line.new(23)
  end

  test "does not allow empty item ids" do
    assert {:error, :invalid_item} == Line.new("")
  end

  test "does not allow blank item ids" do
    assert {:error, :invalid_item} == Line.new(" ")
    assert {:error, :invalid_item} == Line.new("\t\n")
  end

  test "does not allow negative quantities on creation" do
    ptest quantity: int(max: -1) do
      assert {:error, :invalid_quantity} == Line.new("TEST", quantity)
    end
  end

  test "creates lines of positive or zero quantities" do
    ptest quantity: int(min: 0) do
      assert {:ok, %Line{item: "TEST", quantity: quantity}} == Line.new("TEST", quantity)
    end
  end

  test "allows adding quantity to a line" do
    ptest original_quantity: int(min: 1), added_quantity: int(min: 0)  do
      {:ok, line} = Line.new("TEST", original_quantity)
      assert {:ok, %Line{item: "TEST", quantity: original_quantity + added_quantity}} == Line.add(line, added_quantity)
    end
  end

  test "defaults to adding one" do
    ptest original_quantity: int(min: 1) do
      {:ok, line} = Line.new("TEST", original_quantity)
      assert {:ok, %Line{item: "TEST", quantity: original_quantity + 1}} == Line.add(line)
    end
  end

  test "does not allow adding negative quantities" do
    ptest original_quantity: int(min: 1), added_quantity: int(max: -1) do
      {:ok, line} = Line.new("TEST", original_quantity)
      assert {:error, :invalid_quantity} == Line.add(line, added_quantity)
    end
  end

   test "allows substracting quantity from a line" do
    ptest original_quantity: int(min: 1), substracted_quantity: int(min: 0, max: ^original_quantity) do
      {:ok, line} = Line.new("TEST", original_quantity)
      assert {:ok, %Line{item: "TEST", quantity: original_quantity - substracted_quantity}} == Line.remove(line, substracted_quantity)
    end
  end

  test "defaults to removing one" do
    ptest original_quantity: int(min: 1) do
      {:ok, line} = Line.new("TEST", original_quantity)
      assert {:ok, %Line{item: "TEST", quantity: original_quantity - 1}} == Line.remove(line)
    end
  end

  test "substracting a quantity greater or equal to the contained quantity makes the result empty" do
    ptest original_quantity: int(min: 1), substracted_quantity: int(min: ^original_quantity) do
      {:ok, line} = Line.new("TEST", original_quantity)
      assert {:ok, %Line{item: "TEST", quantity: 0}} == Line.remove(line, substracted_quantity)
    end
  end
end
