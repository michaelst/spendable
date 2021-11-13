defmodule Spendable.Budget.Calculations.Spent do
  use Ash.Calculation, type: :string

  import Ecto.Query

  alias Spendable.BudgetAllocation
  alias Spendable.Repo
  alias Spendable.Transaction

  @impl Ash.Calculation
  def calculate(budgets, _opts, %{month: month}) do
    start_date = Timex.beginning_of_month(month)
    end_date = Timex.end_of_month(start_date)
    budget_ids = Enum.map(budgets, & &1.id)

    query =
      from ba in BudgetAllocation,
        join: t in Transaction,
        on: ba.transaction_id == t.id,
        select: {
          ba.budget_id,
          sum(ba.amount) |> coalesce(^Decimal.new(0))
        },
        where: ba.budget_id in ^budget_ids,
        where: t.date >= ^start_date,
        where: t.date <= ^end_date,
        where: ba.amount < 0,
        group_by: :budget_id

    spent_by_budget_id =
      query
      |> Repo.all()
      |> Map.new()

    spent_per_budget =
      Enum.map(budgets, fn budget ->
        Map.get(spent_by_budget_id, budget.id, Decimal.new("0"))
      end)

    {:ok, spent_per_budget}
  end
end
