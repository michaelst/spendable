ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(Spendable.Repo, :manual)
Absinthe.Test.prime(Spendable.Web.Schema)
