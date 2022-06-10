ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(Spendable.Repo, :manual)
BroadwayEctoSandbox.attach(Spendable.Repo)
Absinthe.Test.prime(Spendable.Web.Schema)
