import Config


config :spendable, SpendableWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :logger, level: :info

config :spendable, Plaid, base_url: "https://development.plaid.com"
