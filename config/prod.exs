use Mix.Config

config :spendable, Spendable.Web.Endpoint,
  url: [host: "spendable.dev", port: 80],
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

config :sentry,
  dsn: "https://299a9efbc76c4c3084085c9de461aeb9@sentry.io/2426632",
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

config :exq,
  host: "10.128.0.9",
  concurrency: 1,
  scheduler_enable: true,
  max_retries: 3

# Do not print debug messages in production
config :logger, level: :info

config :spendable, Spendable.Guardian,
  issuer: "spendable.dev",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :spendable, Plaid,
  base_url: "https://development.plaid.com",
  client_id: System.get_env("PLAID_CLIENT_ID"),
  secret_key: System.get_env("PLAID_SECRET_KEY"),
  public_key: System.get_env("PLAID_PUBLIC_KEY")
