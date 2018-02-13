defmodule Zhop.CatalogTest do
  use ExUnit.Case
  doctest Zhop.Catalog

  test "greets the world" do
    assert Zhop.Catalog.hello() == :world
  end
end
