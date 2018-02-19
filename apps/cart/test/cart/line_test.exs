defmodule Zhop.Cart.LineTest do
  alias Zhop.Cart.Line
  use ExUnit.Case, async: true
  doctest Line

  test "defaults creation to a quantity of one" do
    assert {:ok, %Line{item: "TEST", quantity: 1}} == Line.new("TEST")
  end

  test "does not allow negative nor zero quantities on creation" do
    ptest quantity: int(max: 0) do
      assert {:error, :invalid_quantity} == Line.new("TEST", quantity)
    end
  end

  test "creates lines of positive quantities" do
    ptest quantity: int(min: 1) do
      assert {:ok, %Line{item: "TEST", quantity: quantity}} == Line.new("TEST", quantity)
    end
  end

  test "allows adding quantity to a line" do
    ptest original_quantity: int(min: 1), added_quantity: int(min: 0)  do
      line = Line.new("TEST", original_quantity)
      assert {:ok, %Line{item: "TEST", quantity: original_quantity + added_quantity}} == Line.add(line, added_quantity)
    end
  end

  test "allows substracting quantity from a line" do
    ptest original_quantity: int(min: 1), substracted_quantity: int(max: ^original_quantity - 1) do
      line = Line.new("TEST", original_quantity)
      assert {:ok, %Line{item: "TEST", quantity: original_quantity - substracted_quantity}} = Line.remove(line, substracted_quantity)
    end
  end

  test "substracting a quantity greater or equal to the contained quantity makes the result empty" do
    ptest original_quantity: int(min: 1), substracted_quantity: int(min: ^original_quantity) do
      line = Line.new("TEST", original_quantity)
      assert {:ok, %Line{item: "TEST", quantity: 0}} = Line.remove(line, substracted_quantity)
    end
  end
end
