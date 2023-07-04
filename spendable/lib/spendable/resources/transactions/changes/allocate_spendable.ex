defmodule Spendable.Transaction.Changes.AllocateSpendable do
  use Ash.Resource.Change

  alias Spendable.Utils

  require Logger

  def change(changeset, _opts, %{actor: user}) do
    IO.inspect :change
    Ash.Changeset.after_action(changeset, fn _changeset, transaction ->
      IO.inspect transaction
      spendable_id = Utils.get_spendable_id(user)
      allocations = Enum.reject(transaction.budget_allocations, &(&1.budget_id == spendable_id))

      allocated = Enum.reduce(allocations, Decimal.new(0), &Decimal.add(&1.amount, &2))
      unallocated = Decimal.sub(transaction.amount, allocated)

      unless Decimal.eq?(unallocated, 0) do
        new_allocations = [%{amount: unallocated, budget: %{id: spendable_id}} | allocations] |> IO.inspect

        transaction
        |> Ash.Changeset.for_update(:update, %{budget_allocations: new_allocations}, actor: user)
        |> Spendable.Api.update()
        |> IO.inspect
      end

      {:ok, transaction}
    end)
  end
end
