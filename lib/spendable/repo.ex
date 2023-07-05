defmodule Spendable.Repo do
  use AshPostgres.Repo,
    otp_app: :spendable,
    adapter: Ecto.Adapters.Postgres

  def installed_extensions() do
    ["citext", "uuid-ossp"]
  end
end
