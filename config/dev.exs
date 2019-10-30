use Mix.Config

# Configure your database
config :spendable, Spendable.Repo,
  username: "postgres",
  password: "postgres",
  database: "spendable_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
config :spendable, SpendableWeb.Endpoint,
  https: [
    port: 4040,
    cipher_suite: :strong,
    keyfile: "/etc/letsencrypt/live/spendable.dev/privkey.pem",
    cacertfile: "/etc/letsencrypt/live/spendable.dev/chain.pem",
    certfile: "/etc/letsencrypt/live/spendable.dev/cert.pem"
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :spendable, Plaid, base_url: "https://sandbox.plaid.com"

if File.exists?("config/dev.secret.exs") do
  import_config "dev.secret.exs"
end
