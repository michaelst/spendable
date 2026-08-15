defmodule Spendable.Repo do
  use Ecto.Repo,
    otp_app: :spendable,
    adapter: Ecto.Adapters.Postgres
end
