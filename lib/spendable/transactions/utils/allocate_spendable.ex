defmodule Spendable.Transactions.Utils.AllocateSpendable do
  @moduledoc "Import this module rather than aliasing it."

  alias Spendable.Budgets
  alias Spendable.Repo
  alias Spendable.Transactions.Schemas.Transaction

  @zero Decimal.new("0")

  @doc """
  Sends whatever a transaction has not allocated to the Spendable budget.

  Every transaction is fully allocated - a remainder is money the user has not decided about
  yet, and Spendable is where it waits. The existing Spendable line is rebuilt rather than
  adjusted, so re-running this is idempotent.
  """
  def allocate_spendable(scope, %Transaction{} = transaction) do
    {:ok, spendable} = Budgets.find_or_create_spendable_budget(scope)

    transaction = Repo.preload(transaction, :budget_allocations, force: true)
    allocations = Enum.reject(transaction.budget_allocations, &(&1.budget_id == spendable.id))
    allocated = Enum.reduce(allocations, @zero, &Decimal.add(&1.amount, &2))
    unallocated = Decimal.sub(transaction.amount, allocated)

    if Decimal.eq?(unallocated, @zero) do
      {:ok, %{transaction | budget_allocations: allocations}}
    else
      put_remainder(transaction, allocations, unallocated, spendable.id)
    end
  end

  defp put_remainder(transaction, allocations, unallocated, spendable_id) do
    kept =
      Enum.map(allocations, fn allocation ->
        %{"id" => allocation.id, "amount" => allocation.amount, "budget_id" => allocation.budget_id}
      end)

    remainder = %{"amount" => unallocated, "budget_id" => spendable_id}

    transaction
    |> Transaction.changeset(%{"budget_allocations" => [remainder | kept]})
    |> Repo.update()
  end
end
