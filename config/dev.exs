import Config

port = String.to_integer(System.get_env("PORT") || "4000")

config :spendable, issuer: "http://localhost:#{port}"

# Configure your database
config :spendable, Spendable.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  # DB_NAME_SUFFIX is set per worktree by scripts/setup-worktree.sh so worktrees share one postgres
  # without sharing a database.
  database: "spendable_dev#{System.get_env("DB_NAME_SUFFIX", "")}",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :spendable, SpendableWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: port],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "l81LE/gDqTAH6t2OtLgHe3sZ1UfdWtRo2NJrarieYTvGU7y/Hhb8o9UCL0iCJ7cm",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :spendable, SpendableWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/spendable_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :spendable, Spendable.Banks.Clients.Plaid, base_url: "https://sandbox.plaid.com"
