defmodule Zhop.Carts.CartsSupervisor do
  @moduledoc """
  Cart actors supervisor
  """
  use DynamicSupervisor
  alias Zhop.Carts.CartActor

  @max_carts 2000

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: via_tuple())
  end

  def via_tuple do
    {:via, :gproc, {:n, :l, :carts_supervisor}}
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one, max_children: @max_carts)
  end

  def new(cart_id) do
    DynamicSupervisor.start_child(via_tuple(), %{
      id: CartActor,
      restart: :transient,
      start: {CartActor, :new, [cart_id]}
    })
  end

  def start(cart_id) do
    DynamicSupervisor.start_child(via_tuple(), %{
      id: CartActor,
      restart: :transient,
      start: {CartActor, :start, [cart_id]}
    })
  end

  def remove(cart_id) do
    with {:ok, pid} <- CartActor.pid(cart_id) do
      DynamicSupervisor.terminate_child(via_tuple(), pid)
    end
  end

  def count_children do
    DynamicSupervisor.count_children(via_tuple())
  end

  def children do
    DynamicSupervisor.which_children(via_tuple())
  end
end
