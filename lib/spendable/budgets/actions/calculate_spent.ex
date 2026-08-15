defmodule Spendable.Budgets.Actions.CalculateSpent do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  @zero Decimal.new("0.00")

  @doc """
  What each of the given budgets was spent against in one month, keyed by budget id.

  Only outgoing allocations count as spending, and an excluded transaction never does. Returns a
  map rather than decorating the budgets: spending belongs to a month, not to a budget, so a
  budget struct is the wrong place to keep it. Every id asked for comes back, at zero if unspent.
  """
  def calculate_spent(_scope, [], _month), do: %{}

  def calculate_spent(%Scope{user: %{id: user_id}}, budgets, month) do
    start_date = Date.beginning_of_month(month)
    end_date = Date.end_of_month(month)
    budget_ids = Enum.map(budgets, & &1.id)

    spent =
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
        where: allocation.amount < 0,
        group_by: allocation.budget_id
      )
      |> Repo.all()
      |> Map.new()

    Map.new(budget_ids, &{&1, Map.get(spent, &1, @zero)})
  end
end
