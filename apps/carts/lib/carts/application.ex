defmodule Zhop.Carts.Application do
  @moduledoc false
  alias Zhop.Carts.CartsSupervisor

  @repository Application.get_env(:carts, :repository)

  use Application

  def start(_type, _args) do
    children = [
      @repository,
      CartsSupervisor
    ]

    opts = [strategy: :one_for_one, name: Zhop.Carts.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
