defmodule Budget.Repo do
  use Ecto.Repo,
    otp_app: :budget,
    adapter: Ecto.Adapters.Postgres
end
