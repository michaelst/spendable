defmodule Spendable.Budget.Calculations.SpentByMonth do
  use Ash.Calculation, type: :decimal

  import Ecto.Query

  alias Spendable.Repo
  alias Spendable.BudgetAllocation
  alias Spendable.Transaction

  @impl Ash.Calculation
  def calculate(budgets, _opts, _resolution) do
    {:ok, Enum.map(budgets, &do_calculate/1)}
  end

  defp do_calculate(budget) do
    query =
      from ba in BudgetAllocation,
        join: t in Transaction,
        on: ba.transaction_id == t.id,
        select: %{
          month: fragment("TO_CHAR(?, 'YYYY-MM-01')::date", t.date),
          spent: sum(ba.amount) |> coalesce(^Decimal.new(0))
        },
        where: ba.budget_id == ^budget.id,
        where: ba.amount < 0,
        group_by: fragment("TO_CHAR(?, 'YYYY-MM-01')", t.date),
        order_by: [desc: fragment("TO_CHAR(?, 'YYYY-MM-01')", t.date)]

    current_month = Date.utc_today() |> Timex.beginning_of_month()

    case Repo.all(query) do
      [%{month: ^current_month} | _rest] = months ->
        months

      months ->
        [%{month: current_month, spent: Decimal.new(0)} | months]
    end
  end
end
