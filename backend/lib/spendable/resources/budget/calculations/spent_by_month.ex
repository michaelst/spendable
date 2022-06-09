defmodule Spendable.Budget.Calculations.SpentByMonth do
  use Ash.Calculation, type: :decimal

  import Ecto.Query

  alias Spendable.BudgetAllocation
  alias Spendable.Repo
  alias Spendable.Transaction

  @impl Ash.Calculation
  def calculate(budgets, _opts, %{number_of_months: number_of_months}) do
    {:ok, Enum.map(budgets, &do_calculate(&1, number_of_months))}
  end

  defp do_calculate(budget, number_of_months) do
    start_date = Timex.now() |> Timex.shift(months: -number_of_months + 1) |> Timex.beginning_of_month()

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
        where: t.date >= ^start_date,
        group_by: fragment("TO_CHAR(?, 'YYYY-MM-01')", t.date)

    data = Repo.all(query)

    Timex.Interval.new(from: start_date, until: Timex.now(), right_open: false, step: [months: 1])
    |> Enum.map(fn datetime ->
      date = Timex.to_date(datetime)
      matching_month = Enum.find(data, &(&1.month == date))

      %{
        spent: matching_month[:spent] || Decimal.new("0.00"),
        month: date
      }
    end)
    |> Enum.reverse()
  end
end
