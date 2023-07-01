defmodule Spendable.Transaction.Changes.AllocateSpendable do
  use Ash.Resource.Change

  alias Spendable.Utils

  require Logger

  def change(changeset, _opts, %{actor: user}) do
    amount = Ash.Changeset.get_attribute(changeset, :amount)
    budget_allocations = Ash.Changeset.get_argument(changeset, :budget_allocations)

    add_spendable_allocation(changeset, amount, budget_allocations, user)
  end

  # on update we only want to manage allocations if they are changing them
  defp add_spendable_allocation(
         %{action_type: :update} = changeset,
         amount,
         budget_allocations,
         user
       )
       when is_list(budget_allocations) do
    handle_add_spendable_allocation(changeset, amount, budget_allocations, user)
  end

  # on create we want to handle the scenario where no allocations are passed in and create a spendable one
  defp add_spendable_allocation(
         %{action_type: :create} = changeset,
         amount,
         budget_allocations,
         user
       ) do
    handle_add_spendable_allocation(changeset, amount, budget_allocations || [], user)
  end

  defp add_spendable_allocation(changeset, _amount, _budget_allocations, _user) do
    changeset
  end

  defp handle_add_spendable_allocation(changeset, amount, budget_allocations, user) do
    spendable_id = Utils.get_spendable_id(user)
    allocations = Enum.reject(budget_allocations, &(&1.budget.id == spendable_id))

    allocated = Enum.reduce(allocations, Decimal.new(0), &Decimal.add(&1.amount, &2))
    unallocated = Decimal.sub(amount, allocated)

    new_allocations =
      if Decimal.eq?(unallocated, 0) do
        allocations
      else
        [%{amount: unallocated, budget: %{id: spendable_id}} | allocations]
      end

    Ash.Changeset.set_argument(changeset, :budget_allocations, new_allocations)
  end
end
