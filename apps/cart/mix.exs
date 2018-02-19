defmodule Zhop.Cart.MixProject do
  use Mix.Project

  def project do
    [
      app: :cart,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Zhop.Cart",
      docs: [
        main: "Zhop.Cart",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Zhop.Cart.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gproc, "~> 0.6.1"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
      {:quixir, "~> 0.9", only: :test},
      {:mox, "~> 0.3", only: :test},
      {:money, "~> 1.2"}
    ]
  end
end
