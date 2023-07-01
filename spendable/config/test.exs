import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :spendable, Spendable.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "spendable_test#{System.get_env("MIX_TEST_PARTITION")}",
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

config :spendable, Plaid,
  base_url: "https://sandbox.plaid.com",
  client_id: "test",
  secret_key: "test"

config :tesla, adapter: TeslaMock

config :goth,
  disabled: true

config :mox,
  apns: APNSMock,
  pubsub: PubSubMock

config :ash, disable_async?: true
config :ash, :missed_notifications, :ignore
