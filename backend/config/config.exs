import Config

config :spendable,
  env: config_env(),
  ecto_repos: [Spendable.Repo],
  ash_apis: [Spendable.Api]

config :spendable, Spendable.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10

# Configures the endpoint
config :spendable, Spendable.Web.Endpoint,
  secret_key_base: "NoM/w1aErkEg8aarboi9MDakr7zalCnOmhuuNqZtu2cB5PRdK6lXWD/BeMywMcWO",
  render_errors: [view: Spendable.Web.ErrorView, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :trace_id, :span_id],
  level: :info

config :cors_plug,
  origin: ["http://localhost:3000"],
  max_age: 86400

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: config_env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spendable, Spendable.Auth.Guardian,
  issuer: "https://securetoken.google.com/cloud-57",
  verify_issuer: true,
  allowed_algos: ["RS256"],
  secret_fetcher: Spendable.Auth.Guardian.KeyServer

config :tesla, Tesla.Adapter.Mint, timeout: 30000

config :goth, project_id: "cloud-57"

config :spendable, Spendable.Tracer,
  service: :spendable_api,
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
    "service.name" => "Spendable",
    "service.namespace" => "backend"
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
