defmodule Spendable.Budgets.Actions.CalculateMonthSummary do
  @moduledoc false

  alias Spendable.Budgets
  alias Spendable.Scope

  @zero Decimal.new("0")

  @doc """
  Every number the budgets screen shows for one month, so the web and the API cannot disagree
  about what a month adds up to.

  Only envelopes count toward the allocated, funded and spent totals: a tracking budget reserves
  nothing and a goal is money going in rather than out. Earned comes off the income budgets, which
  are the only budgets that receive, and it is what says whether the funding amounts are
  survivable.
  """
  def calculate_month_summary(%Scope{} = scope, %Date{} = month, opts \\ []) do
    month = Date.beginning_of_month(month)
    budgets = Budgets.list_budgets(scope, search: opts[:search])
    spent = Budgets.calculate_spent(scope, budgets, month)
    received = Budgets.calculate_received(scope, budgets, month)
    funded = Budgets.calculate_funded(scope, budgets, month)
    envelopes = Enum.filter(budgets, &(&1.type == :envelope))
    income = Enum.filter(budgets, &(&1.type == :income))

    %{
      month: month,
      current_month: Date.compare(month, Date.beginning_of_month(Date.utc_today())) == :eq,
      budgets: budgets,
      spent: spent,
      received: received,
      funded: funded,
      spent_by_month: Budgets.calculate_spent_by_month(scope),
      spendable: Budgets.calculate_spendable(scope),
      allocated_total: total(envelopes, & &1.funding_amount),
      funded_total: total(envelopes, &Map.get(funded, &1.id)),
      earned_total: total(income, &Map.get(received, &1.id)),
      spent_total: total(envelopes, &Map.get(spent, &1.id))
    }
  end

  # No `abs` here: `calculate_spent/3` already nets and negates, so a month refunded more than it
  # spent has to stay negative rather than read as that much spending.
  defp total(budgets, amount) do
    Enum.reduce(budgets, @zero, &Decimal.add(&2, amount.(&1) || @zero))
  end
end
