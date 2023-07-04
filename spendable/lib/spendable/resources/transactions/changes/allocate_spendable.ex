defmodule Spendable.Transaction.Changes.AllocateSpendable do
  use Ash.Resource.Change

  alias Spendable.BudgetAllocation
  alias Spendable.Utils

  require Logger

  def change(changeset, _opts, %{actor: user}) do
    Ash.Changeset.after_action(changeset, fn _changeset, transaction ->
      spendable_id = Utils.get_spendable_id(user)
      allocations = Enum.reject(transaction.budget_allocations, &(&1.budget_id == spendable_id))

      allocated = Enum.reduce(allocations, Decimal.new(0), &Decimal.add(&1.amount, &2))
      unallocated = Decimal.sub(transaction.amount, allocated)

      unless Decimal.eq?(unallocated, 0) do
        new_allocations = [%{amount: unallocated, budget_id: to_string(spendable_id)} | allocations]

        transaction
        |> Ash.Changeset.for_update(:update_allocations, %{budget_allocations: new_allocations}, actor: user)
        |> Spendable.Api.update!()
      end

      {:ok, transaction}
    end)
  end
end
