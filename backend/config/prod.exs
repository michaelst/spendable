use Mix.Config

config :spendable, Spendable.Web.Endpoint,
  url: [host: "spendable.money", port: 80],
  debug_errors: false,
  http: [
    port: 80,
    protocol_options: [max_keepalive: :infinity],
    compress: true
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true

config :spendable, Spendable.Repo,
  username: "postgres",
  password: System.get_env("DB_PASSWORD"),
  database: "spendable",
  hostname: "10.122.112.3",
  pool_size: 5

config :logger, level: :info

config :cors_plug,
  origin: ["https://spendable.money"],
  max_age: 86400

config :spendable, Spendable.Guardian,
  issuer: "spendable.money",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :pigeon, :apns,
  apns_default: %{
    cert: {:spendable, "apns/cert.pem"},
    key: {:spendable, "apns/key_unencrypted.pem"},
    mode: :prod
  }

config :spendable, Plaid,
  base_url: "https://development.plaid.com",
  client_id: System.get_env("PLAID_CLIENT_ID"),
  secret_key: System.get_env("PLAID_SECRET_KEY"),
  public_key: System.get_env("PLAID_PUBLIC_KEY")

config :weddell,
  project: "cloud-57"
