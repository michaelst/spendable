defmodule Spendable.Repo do
  use AshPostgres.Repo,
    otp_app: :spendable,
    adapter: Ecto.Adapters.Postgres
end
