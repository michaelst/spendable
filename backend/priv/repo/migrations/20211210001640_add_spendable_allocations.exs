defmodule Spendable.Repo.Migrations.AddSpendableAllocations do
  use Ecto.Migration

  alias Spendable.Api

  def change() do
    Spendable.Transaction
    |> Ash.Query.load([:budget_allocations, :user])
    |> Api.read!()
    |> Enum.each(fn transaction ->
      transaction
      |> Ash.Changeset.for_update(:update, %{budget_allocations: transaction.budget_allocations},
        actor: transaction.user
      )
      |> Api.update!()
    end)
  end
end
