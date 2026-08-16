# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :spendable,
  env: config_env(),
  ecto_repos: [Spendable.Repo],
  # The OAuth issuer, and the origin of the MCP resource tokens are bound to. Overridden per
  # environment, since it has to be the URL a client actually reaches this app on.
  issuer: "http://localhost:4000",
  # Team id and bundle id, which is what an apple-app-site-association names. Both are public.
  ios_app_id: "A4TA99R8XM.fiftysevenmedia.Spendable"

config :spendable, Oban,
  repo: Spendable.Repo,
  queues: [banks: 5, notifications: 5]

config :spendable, Spendable.Repo,
  migration_primary_key: [type: :text],
  migration_foreign_key: [type: :text],
  migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :spendable, SpendableWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: SpendableWeb.ErrorHTML, json: SpendableWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Spendable.PubSub,
  live_view: [signing_salt: "8XuGywrS"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.3.3",
  default: [
    args: ~w(
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, :adapter, {Tesla.Adapter.Finch, name: Spendable.Finch}
config :oauth2, adapter: {Tesla.Adapter.Finch, name: Spendable.Finch}

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]

config :spendable, Spendable.Accounts.Clients.Google, base_url: "https://www.googleapis.com"

# Sign in with Apple's audience is the bundle id, which is fixed and public.
config :spendable, Spendable.Accounts.Clients.Apple,
  base_url: "https://appleid.apple.com",
  audiences: ["fiftysevenmedia.Spendable"]

# An APNs topic is the bundle id. The signing key, its id and the team id come from runtime.exs;
# without them the client answers `{:error, :not_configured}` and nothing else changes.
config :spendable, Spendable.Accounts.Clients.Apns,
  base_url: "https://api.push.apple.com",
  topic: "fiftysevenmedia.Spendable"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
