import Config

if Config.config_env() == :dev do
  DotenvParser.load_file(".env")
end

defmodule Secret do
  def read!(name, non_prod_default \\ nil) do
    if config_env() == :prod do
      File.read!("/etc/secrets/" <> name)
    else
      System.get_env(name, non_prod_default)
    end
  end
end

config :spendable, Spendable.Banks.Clients.Plaid,
  client_id: Secret.read!("PLAID_CLIENT_ID", "test"),
  secret_key: Secret.read!("PLAID_SECRET_KEY", "test")

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: Secret.read!("GOOGLE_CLIENT_ID"),
  client_secret: Secret.read!("GOOGLE_CLIENT_SECRET")

if config_env() == :prod do
  # On by default because every deployed database requires it; the docker compose prod profile
  # turns it off, since the postgres it runs against is on the same bridge network.
  config :spendable, Spendable.Repo,
    ssl: System.get_env("DB_SSL") != "false",
    ssl_opts: [
      verify: :verify_none
    ],
    database: "spendable",
    hostname: System.fetch_env!("DB_HOSTNAME"),
    username: System.fetch_env!("DB_USERNAME"),
    password: Secret.read!("DB_PASSWORD"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  host = System.get_env("PHX_HOST") || "spendable.money"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :spendable, issuer: "https://#{host}"

  config :spendable, SpendableWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [port: port],
    secret_key_base: Secret.read!("SECRET_KEY_BASE")
end
