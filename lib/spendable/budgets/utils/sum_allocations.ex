defmodule Spendable.Budgets.Utils.SumAllocations do
  @moduledoc "Import this module rather than aliasing it."

  import Ecto.Query

  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Repo
  alias Spendable.Transactions.Schemas.Transaction

  @zero Decimal.new("0.00")

  @doc """
  What the given budgets' allocations add up to in one month, keyed by budget id.

  Signed and un-negated: money out is negative and money in is positive, so the caller decides
  which way round the figure reads. Shared so that what counts as a month's movement - and what an
  excluded transaction or a transfer does not count toward - is written once.
  """
  def sum_allocations(_user_id, [], _month), do: %{}

  def sum_allocations(user_id, budget_ids, month) do
    start_date = Date.beginning_of_month(month)
    end_date = Date.end_of_month(month)

    from(allocation in BudgetAllocation,
      join: transaction in Transaction,
      on: allocation.transaction_id == transaction.id,
      select: {allocation.budget_id, coalesce(sum(allocation.amount), ^@zero)},
      where: allocation.user_id == ^user_id,
      where: allocation.budget_id in ^budget_ids,
      where: transaction.date >= ^start_date,
      where: transaction.date <= ^end_date,
      where: not transaction.excluded,
      where: is_nil(transaction.transfer_id),
      group_by: allocation.budget_id
    )
    |> Repo.all()
    |> Map.new()
  end
end
