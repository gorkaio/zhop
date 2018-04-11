use Mix.Config

config :carts,
  repository: Zhop.Carts.Repository.Memory,
  catalog: Zhop.Catalog

config :money,
  default_currency: :EUR,
  separator: ".",
  delimeter: ",",
  symbol: false,
  symbol_on_right: false,
  symbol_space: false

import_config "#{Mix.env()}.exs"
