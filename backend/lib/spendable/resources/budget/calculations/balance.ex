defmodule Spendable.Budget.Calculations.Balance do
  use Ash.Calculation, type: :string

  import Ecto.Query

  alias Spendable.BudgetAllocation
  alias Spendable.Repo

  @impl Ash.Calculation
  def calculate(budgets, _opts, _context) do
    allocated = budgets |> Enum.map(& &1.id) |> allocated()

    balances =
      Enum.map(budgets, fn budget ->
        allocated
        |> Map.get(budget.id, Decimal.new("0"))
        |> Decimal.add(budget.adjustment)
      end)

    {:ok, balances}
  end

  def allocated(budget_ids) when is_list(budget_ids) do
    from(a in BudgetAllocation,
      select: {a.budget_id, sum(a.amount)},
      group_by: a.budget_id,
      where: a.budget_id in ^budget_ids
    )
    |> Repo.all()
    |> Map.new()
  end

  def allocated(budget_id), do: allocated([budget_id])[budget_id] || "0.00"
end
