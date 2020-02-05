# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :spendable,
  env: Mix.env(),
  ecto_repos: [Spendable.Repo]

config :spendable, Spendable.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10

# Configures the endpoint
config :spendable, Spendable.Web.Endpoint,
  secret_key_base: "NoM/w1aErkEg8aarboi9MDakr7zalCnOmhuuNqZtu2cB5PRdK6lXWD/BeMywMcWO",
  render_errors: [view: Spendable.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Spendable.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :exq,
  max_retries: 3,
  name: Exq,
  namespace: "exq-#{Mix.env()}",
  start_on_application: false,
  queues: ["default"]

config :spendable, Spendable.Guardian,
  issuer: "Spendable",
  secret_key: "TZc05TFSvH7nzsbhKVTs9++F3X8e/cmnk/UHM9chuEhhKRygFmBnqc+TUvjirMZP"

config :tesla, :adapter, Tesla.Adapter.Mint

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
