import Config

config :spendable, Spendable.Web.Endpoint, secret_key_base: File.read!("/etc/secrets/SECRET_KEY_BASE")

config :spendable, Spendable.Repo,
  hostname: System.fetch_env!("DB_HOSTNAME"),
  username: System.fetch_env!("DB_USERNAME"),
  password: File.read!("/etc/secrets/DB_PASSWORD")

config :spendable, Spendable.Guardian, secret_key: File.read!("/etc/secrets/GUARDIAN_SECRET")

config :pigeon, :apns,
  apns_default: %{
    cert: File.read!("/etc/secrets/APNS_CERT"),
    key: File.read!("/etc/secrets/APNS_KEY"),
    mode: :prod
  }

config :spendable, Plaid,
  client_id: File.read!("/etc/secrets/PLAID_CLIENT_ID"),
  secret_key: File.read!("/etc/secrets/PLAID_SECRET_KEY"),
  public_key: File.read!("/etc/secrets/PLAID_PUBLIC_KEY")

config :sentry,
  dsn: File.read!("/etc/secrets/SENTRY_DSN")

config :goth,
  json: File.read!("/etc/secrets/GCP_SA_KEY")
