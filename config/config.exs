# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :budget,
  ecto_repos: [Budget.Repo]

# Configures the endpoint
config :budget, BudgetWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NoM/w1aErkEg8aarboi9MDakr7zalCnOmhuuNqZtu2cB5PRdK6lXWD/BeMywMcWO",
  render_errors: [view: BudgetWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Budget.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :exq,
  namespace: "budget-api",
  queues: ["default"]

config :budget, Budget.Guardian,
  issuer: "Budget",
  secret_key: "TZc05TFSvH7nzsbhKVTs9++F3X8e/cmnk/UHM9chuEhhKRygFmBnqc+TUvjirMZP"

config :tesla, :adapter, Tesla.Adapter.Mint

config :budget, Plaid,
  client_id: "5d902f478e856300113b2c16",
  public_key: "37cc44ed343b19bae3920edf047df1"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
