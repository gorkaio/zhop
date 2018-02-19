use Mix.Config

config :catalog,
  repository: Zhop.Catalog.Repository.MemoryRepository

config :money,
  default_currency: :EUR,
  separator: ".",
  delimeter: ",",
  symbol: false,
  symbol_on_right: false,
  symbol_space: false

import_config "#{Mix.env}.exs"
