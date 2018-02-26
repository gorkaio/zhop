defmodule Zhop.Cart.Line do
  alias __MODULE__

  @type t :: %Line{}

  @enforce_keys [:item, :quantity]
  defstruct [:item, :quantity]

  defguardp is_valid_quantity(quantity) when is_integer(quantity) and quantity >= 0

  @doc """
  Creates new cart line
  """
  @spec new(item :: String.t(), quantity :: integer) :: {:ok, Line.t()} | {:error, reason :: term}
  def new(item, quantity \\ 1)
  def new(item, quantity) when is_binary(item) and is_valid_quantity(quantity) do
    with {:ok, item} <- validate_item(item)
    do
      {:ok, %Line{item: item, quantity: quantity}}
    else
      error -> error
    end
  end
  def new(item, quantity) when is_binary(item) and not is_valid_quantity(quantity), do: {:error, :invalid_quantity}
  def new(_, _), do: {:error, :invalid_item}

  @doc """
  Adds quantity to a cart line
  """
  @spec add(line :: Line.t(), added_quantity :: integer) :: {:ok, Line.t()} | {:error, reason :: term}
  def add(line, added_quantity \\ 1)
  def add(%Line{} = line, added_quantity) when is_valid_quantity(added_quantity) do
    {:ok, %Line{line | quantity: line.quantity + added_quantity}}
  end
  def add(%Line{} = line, _), do: {:error, :invalid_quantity}

  @doc """
  Removes quantity from a cart line
  """
  @spec remove(line :: Line.t(), removed_quantity :: integer) :: {:ok, Line.t()} | {:error, reason :: term}
  def remove(line, removed_quantity \\ 1)
  def remove(%Line{} = line, removed_quantity) when is_valid_quantity(removed_quantity) do
    {:ok, %Line{line | quantity: max(0, line.quantity - removed_quantity)}}
  end
  def remove(%Line{} = line, _), do: {:error, :invalid_quantity}

  defp validate_item(item) do
    case item |> String.trim |> String.length do
      0 -> {:error, :invalid_item}
      _ -> {:ok, item}
    end 
  end
end
