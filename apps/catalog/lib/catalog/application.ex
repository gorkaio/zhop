defmodule Zhop.Catalog.Application do
  @moduledoc false

  @repository Application.get_env(:catalog, :repository)

  use Application

  def start(_type, _args) do
    children = [
      @repository
    ]

    opts = [strategy: :one_for_one, name: Zhop.Catalog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
