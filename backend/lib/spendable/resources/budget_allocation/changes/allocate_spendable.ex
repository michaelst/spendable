defmodule Spendable.BudgetAllocation.Changes.AllocateSpendable do
  use Ash.Resource.Change

  alias Spendable.Api

  require Logger

  def change(changeset, _opts, %{actor: user}) do
    Ash.Changeset.after_action(
      changeset,
      fn
        _changeset, %{budget: %{name: "Spendable"}} = allocation ->
          {:ok, allocation}

        changeset, allocation ->
          %{transaction: transaction} = Api.load!(allocation, transaction: :budget_allocations)
          allocated = Enum.reduce(transaction.budget_allocations, Decimal.new(0), &Decimal.add(&1.amount, &2))

          amount_changing? = Ash.Changeset.changing_attribute?(changeset, :amount)
          not_allocated? = not Decimal.eq?(transaction.amount, allocated)
          deleting? = changeset.action.type == :destroy

          if (amount_changing? or deleting?) and not_allocated? do
            transaction
            |> Ash.Changeset.for_update(:update, %{budget_allocations: transaction.budget_allocations}, actor: user)
            |> Api.update!()
          end

          {:ok, allocation}
      end
    )
  end
end
