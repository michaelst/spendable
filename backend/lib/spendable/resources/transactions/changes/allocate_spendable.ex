defmodule Spendable.Transaction.Changes.AllocateSpendable do
  use Ash.Resource.Change

  alias Spendable.Api
  alias Spendable.Budget
  alias Spendable.Repo

  require Logger

  def change(changeset, _opts, %{actor: user}) do
    amount = Ash.Changeset.get_attribute(changeset, :amount)
    budget_allocations = Ash.Changeset.get_argument(changeset, :budget_allocations)

    add_spendable_allocation(changeset, amount, budget_allocations, user)
  end

  defp add_spendable_allocation(changeset, amount, budget_allocations, user) when is_list(budget_allocations) do
    spendable_id = get_spendable_id(user)
    allocations = Enum.reject(budget_allocations, &(&1.budget.id == spendable_id))

    allocated = Enum.reduce(allocations, Decimal.new(0), &Decimal.add(&1.amount, &2))
    unallocated = Decimal.sub(amount, allocated)

    new_allocations =
      if Decimal.eq?(unallocated, 0) do
        allocations
      else
        [%{amount: unallocated, budget: %{id: get_spendable_id(user)}} | allocations]
      end

    Ash.Changeset.set_argument(changeset, :budget_allocations, new_allocations)
  end

  defp add_spendable_allocation(changeset, _amount, _budget_allocations, _user) do
    changeset
  end

  defp get_spendable_id(user) do
    budget =
      Repo.get_by(Budget, user_id: user.id, name: "Spendable")
      |> case do
        nil ->
          Budget
          |> Ash.Changeset.for_create(
            :create,
            %{
              name: "Spendable",
              track_spending_only: true
            },
            actor: user
          )
          |> Api.create!()

        budget ->
          budget
      end

    budget.id
  end
end
