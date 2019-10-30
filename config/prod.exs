use Mix.Config

config :spendable, SpendableWeb.Endpoint,
  url: [host: "spendable.dev", port: 80],
  debug_errors: false,
  http: [
    port: 80,
    # need to set keepalive timeout for Google Load Balancer
    timeout: 800_000,
    protocol_options: [max_keepalive: :infinity],
    compress: true
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true

# Do not print debug messages in production
config :logger, level: :info

config :spendable, Spendable.Guardian,
  issuer: "spendable.dev",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :spendable, Plaid,
  base_url: "https://production.plaid.com",
  client_id: System.get_env("PLAID_CLIENT_ID"),
  secret_key: System.get_env("PLAID_SECRET_KEY"),
  public_key: System.get_env("PLAID_PUBLIC_KEY")
