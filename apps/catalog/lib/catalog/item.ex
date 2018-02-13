defmodule Zhop.Catalog.Item do
  @moduledoc """
    Catalog item
  """
  alias __MODULE__

  @type t :: %Item{}

  @regex_id ~r/^[A-Z0-9_-]{1,32}$/
  
  @valid_types [:product, :discount]
  @type types :: :product | :discount

  @enforce_keys [:id, :name, :type, :price]
  defstruct [:id, :name, :type, :price]

  defguardp valid_item(id, name, type) when is_binary(id) and is_binary(name) and type in @valid_types

  @doc """
  Creates a new item

  ## Parameters
  
    - id: alphanumeric string from 1 to 32 chars. Allows uppercase letters, numbers, hyphen and underscore.
    - name: item name string. Cannot be blank.
    - type: item type (`:product` or `:discount`)
    - price: item price expressed with Money. Must be positive for products, negative for discounts.

  ## Examples
  
      iex> Zhop.Catalog.Item.new("EXAMPLE", "Example product", :product, Money.new(1234))
      {:ok, %Zhop.Catalog.Item{id: "EXAMPLE", name: "Example product", type: :product, price: %Money{amount: 1234, currency: :EUR}}}
      
      iex> Zhop.Catalog.Item.new("EXAMPLE", "Example discount", :discount, Money.new(-1234))      
      {:ok, %Zhop.Catalog.Item{id: "EXAMPLE", name: "Example discount", type: :discount, price: %Money{amount: -1234, currency: :EUR}}}
      
      iex> Zhop.Catalog.Item.new("", "Example item", :product, Money.new(1234))
      {:error, :invalid_item_id}

      iex> Zhop.Catalog.Item.new("EXAMPLE", "   ", :product, Money.new(1234))
      {:error, :invalid_item_name}

      iex> Zhop.Catalog.Item.new("EXAMPLE", "Example product", :product, Money.new(-1234))
      {:error, :invalid_item_price}

      iex> Zhop.Catalog.Item.new("EXAMPLE", "Example discount", :discount, Money.new(1234))
      {:error, :invalid_item_price}

      iex> Zhop.Catalog.Item.new(12, 34, 56, 78)
      {:error, :invalid_item_data}

  """
  @spec new(id :: String.t(), name :: String.t(), type :: :product | :discount, money :: Money.t()) :: {:ok, Item.t()} | {:error, reason :: term}
  def new(id, name, type, %Money{} = price) when valid_item(id, name, type) do
    with {:ok, id} <- validate_id(id, type),
      {:ok, name} <- validate_name(name, type),
      {:ok, price} <- validate_price(price, type)
    do
      {:ok, %Item{id: id, name: name, type: type, price: price}}
    else
      error -> error
    end
  end
  def new(_id, _name, _type, _price), do: {:error, :invalid_item_data}

  @doc """
  Updates item price

  ## Parameters

    - item: item to be updated.
    - updated_price: new price expressed with Money. Must be positive for products, negative for discounts

  ## Examples

      iex> {:ok, item} = Zhop.Catalog.Item.new("ID", "Name", :product, Money.new(12_00))
      ...> Zhop.Catalog.Item.update_price(item, Money.new(23_34))
      {:ok, %Zhop.Catalog.Item{id: "ID", name: "Name", type: :product, price: %Money{amount: 2334, currency: :EUR}}} 
      
      
      iex> {:ok, item} = Zhop.Catalog.Item.new("ID", "Name", :product, Money.new(12_00))
      ...> Zhop.Catalog.Item.update_price(item, Money.new(-23_34))
      {:error, :invalid_item_price}

      iex> {:ok, item} = Zhop.Catalog.Item.new("ID", "Name", :discount, Money.new(-12_00))
      ...> Zhop.Catalog.Item.update_price(item, Money.new(-3_00))
      {:ok, %Zhop.Catalog.Item{id: "ID", name: "Name", type: :discount, price: %Money{amount: -300, currency: :EUR}}} 
    
      iex> {:ok, item} = Zhop.Catalog.Item.new("ID", "Name", :discount, Money.new(-12_00))
      ...> Zhop.Catalog.Item.update_price(item, Money.new(7_00))
      {:error, :invalid_item_price}

  """
  @spec update_price(item :: Item.t(), updated_price :: Money.t()) :: Item.t() | {:error, :invalid_product_price}
  def update_price(%Item{} = item, %Money{} = updated_price) do
    with {:ok, price} <- validate_price(updated_price, item.type) do
      {:ok, %Item{item | price: price}}
    else
      error -> error
    end
  end

  @doc """
  Updates item name

  ## Parameters

    - item: item to be updated.
    - updated_name: new name string. From 1 to 32 uppercase letters, numbers, hyphens and underscores.

  ## Examples  
    
      iex> {:ok, item} = Zhop.Catalog.Item.new("ID", "Name", :product, Money.new(12_00)) 
      ...> Zhop.Catalog.Item.update_name(item, "New name")
      {:ok, %Zhop.Catalog.Item{id: "ID", name: "New name", type: :product, price: %Money{amount: 1200, currency: :EUR}}}

      
      iex> {:ok, item} = Zhop.Catalog.Item.new("ID", "Name", :product, Money.new(12_00))
      ...> Zhop.Catalog.Item.update_name(item, "")
      {:error, :invalid_item_name} 
  
  """
  @spec update_name(item :: Item.t(), updated_name :: String.t()) :: Item.t() | {:error, :invalid_product_name}
  def update_name(%Item{} = item, updated_name) when is_binary(updated_name) do
    with {:ok, name} <- validate_name(updated_name, item.type) do
      {:ok, %Item{item | name: name}}
    else
      error -> error
    end
  end

  defp validate_id(id, _type) do
    case Regex.match?(@regex_id, id) do
      true -> {:ok, id}
      false -> {:error, :invalid_item_id}
    end
  end

  defp validate_name(name, _type) do
    case name |> String.trim |> String.length > 0 do
      true -> {:ok, name}
      false -> {:error, :invalid_item_name}
    end
  end

  defp validate_price(%Money{} = price, :product) do
    case price.amount() > 0 do
      true -> {:ok, price}
      false -> {:error, :invalid_item_price}
    end
  end
  defp validate_price(%Money{} = price, :discount) do
    case price.amount() < 0 do
      true -> {:ok, price}
      false -> {:error, :invalid_item_price}
    end
  end
end
