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

config :spendable, Plaid,
  client_id: Secret.read!("PLAID_CLIENT_ID"),
  secret_key: Secret.read!("PLAID_SECRET_KEY")

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :spendable, Spendable.Repo,
    database: "spendable",
    hostname: System.fetch_env!("DB_HOSTNAME"),
    username: System.fetch_env!("DB_USERNAME"),
    password: Secret.read!("DB_PASSWORD"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  host = System.get_env("PHX_HOST") || "spendable.money"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :spendable, SpendableWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: Secret.read!("SECRET_KEY_BASE")

    config :goth,
      json: File.read!("/etc/secrets/GCP_SA_KEY")
end
