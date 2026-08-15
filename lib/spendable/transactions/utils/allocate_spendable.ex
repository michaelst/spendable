defmodule Spendable.Transactions.Utils.AllocateSpendable do
  @moduledoc "Import this module rather than aliasing it."

  import Ecto.Changeset

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Scope

  @zero Decimal.new("0")

  @doc """
  Sends whatever a transaction has not allocated to the Spendable budget.

  Every transaction is fully allocated - a remainder is money the user has not decided about
  yet, and Spendable is where it waits. This is the last step of the changeset rather than
  something each action calls, so no write can skip it. The work happens in `prepare_changes/2`,
  which runs inside the write's transaction and not at all while the form is only being
  validated. The existing Spendable line is rebuilt rather than adjusted, so re-running this is
  idempotent.
  """
  def allocate_spendable(%Ecto.Changeset{} = changeset) do
    prepare_changes(changeset, &put_remainder/1)
  end

  defp put_remainder(changeset) do
    user_id = get_field(changeset, :user_id)
    {:ok, spendable} = Budgets.find_or_create_spendable_budget(Scope.for_user(%User{id: user_id}))

    changeset = load_allocations(changeset)

    kept =
      changeset
      |> get_assoc(:budget_allocations, :changeset)
      |> Enum.reject(&(&1.action in [:replace, :delete] or get_field(&1, :budget_id) == spendable.id))

    allocated = Enum.reduce(kept, @zero, &Decimal.add(get_field(&1, :amount), &2))
    unallocated = Decimal.sub(get_field(changeset, :amount), allocated)

    if Decimal.eq?(unallocated, @zero) do
      put_assoc(changeset, :budget_allocations, kept)
    else
      remainder =
        change(%BudgetAllocation{user_id: user_id}, %{
          amount: unallocated,
          budget_id: spendable.id
        })

      put_assoc(changeset, :budget_allocations, [remainder | kept])
    end
  end

  # An action that changes nothing about the allocations never loads them, but the remainder
  # still has to be measured against what is already there.
  defp load_allocations(%{data: %{budget_allocations: %Ecto.Association.NotLoaded{}}} = changeset) do
    %{changeset | data: changeset.repo.preload(changeset.data, :budget_allocations)}
  end

  defp load_allocations(changeset), do: changeset
end
