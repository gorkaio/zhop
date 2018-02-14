defmodule Zhop.Catalog.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Zhop.Catalog.Repository
    ]

    opts = [strategy: :one_for_one, name: Zhop.Catalog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
