import Config

config :spendable, issuer: "http://localhost:4002"

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :spendable, Spendable.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "spendable_test#{System.get_env("DB_NAME_SUFFIX", "")}#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :spendable, SpendableWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jpA0Rf9pPhX4snfhftMLUHEqS1EI/V0J22KstbXCMGSt+WUWW/JxzTngZmfu6QuR",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :spendable, Spendable.Banks.Clients.Plaid,
  base_url: "https://sandbox.plaid.com",
  client_id: "test",
  secret_key: "test"

config :spendable, Spendable.Accounts.Clients.Google,
  base_url: "https://www.googleapis.com",
  audiences: ["spendable-ios.apps.googleusercontent.com"]

config :tesla, adapter: TeslaMock

# Jobs run inline in tests so a sync is asserted on, not waited for.
config :spendable, Oban, testing: :manual
