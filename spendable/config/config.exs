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
  ash_apis: [Spendable.Api]

# Configures the endpoint
config :spendable, SpendableWeb.Endpoint,
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
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
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

config :ash, :use_all_identities_in_manage_relationship?, false

config :tesla, :adapter, {Tesla.Adapter.Finch, name: Spendable.Finch}

config :goth, project_id: "cloud-57"

config :spendable, Spendable.Tracer,
  service: :spendable,
  adapter: SpandexOTLP.Adapter,
  disabled?: config_env() != :prod,
  env: "PROD"

config :spandex_phoenix, tracer: Spendable.Tracer

config :spandex_ecto, SpandexEcto.EctoLogger, tracer: Spendable.Tracer

config :spandex_otlp, SpandexOTLP,
  otp_app: :spendable,
  endpoint: "tempo.grafana.svc.cluster.local:4317",
  headers: %{},
  resources: %{
    "service.name" => "spendable"
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
