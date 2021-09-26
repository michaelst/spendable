defmodule Spendable.Budget.Calculations.Balance do
  use Ash.Calculation, type: :string

  import Ecto.Query

  alias Spendable.BudgetAllocation
  alias Spendable.Repo

  @impl Ash.Calculation
  def calculate(budgets, _opts, _context) do
    budget_ids = Enum.map(budgets, & &1.id)

    allocated =
      from(a in BudgetAllocation,
        select: {a.budget_id, sum(a.amount)},
        group_by: a.budget_id,
        where: a.budget_id in ^budget_ids
      )
      |> Repo.all()
      |> Map.new()

    balances =
      Enum.map(budgets, fn budget ->
        allocated
        |> Map.get(budget.id, Decimal.new("0"))
        |> Decimal.add(budget.adjustment)
      end)

    {:ok, balances}
  end
end
