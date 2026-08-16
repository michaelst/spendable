defmodule Spendable.Budgets.Actions.CalculateMonthSummary do
  @moduledoc false

  alias Spendable.Budgets
  alias Spendable.Scope

  @zero Decimal.new("0")

  @doc """
  Every number the budgets screen shows for one month, so the web and the API cannot disagree
  about what a month adds up to.

  Only envelopes count toward the allocated and spent totals: a tracking budget reserves nothing
  and a goal is money going in rather than out.
  """
  def calculate_month_summary(%Scope{} = scope, %Date{} = month, opts \\ []) do
    month = Date.beginning_of_month(month)
    budgets = Budgets.list_budgets(scope, search: opts[:search])
    spent = Budgets.calculate_spent(scope, budgets, month)
    envelopes = Enum.filter(budgets, &(&1.type == :envelope))

    %{
      month: month,
      current_month: Date.compare(month, Date.beginning_of_month(Date.utc_today())) == :eq,
      budgets: budgets,
      spent: spent,
      spent_by_month: Budgets.calculate_spent_by_month(scope),
      spendable: Budgets.calculate_spendable(scope),
      allocated_total: total(envelopes, & &1.budgeted_amount),
      spent_total: total(envelopes, &Map.get(spent, &1.id))
    }
  end

  defp total(envelopes, amount) do
    envelopes
    |> Enum.reduce(@zero, &Decimal.add(&2, amount.(&1) || @zero))
    |> Decimal.abs()
  end
end
