use Mix.Config

config :spendable, Spendable.Web.Endpoint,
  url: [host: "spendable.money", port: 80],
  debug_errors: false,
  http: [
    port: 4000,
    protocol_options: [max_keepalive: :infinity],
    compress: true
  ],
  server: true

config :spendable, Spendable.Repo,
  database: "spendable",
  pool_size: 5

config :logger,
  backends: [:console, Sentry.LoggerBackend],
  level: :info

config :cors_plug,
  origin: ["https://spendable.money"],
  max_age: 86400

config :spendable, Spendable.Guardian, issuer: "spendable.money"

config :spendable, Plaid, base_url: "https://development.plaid.com"
