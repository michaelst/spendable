# Mix.env() can be used inside config files
# credo:disable-for-this-file Credo.Check.Warning.MixEnv
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

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spendable, Spendable.Guardian,
  issuer: "Spendable",
  ttl: {365, :days},
  secret_key: "TZc05TFSvH7nzsbhKVTs9++F3X8e/cmnk/UHM9chuEhhKRygFmBnqc+TUvjirMZP"

config :tesla, Tesla.Adapter.Mint, timeout: 30000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
