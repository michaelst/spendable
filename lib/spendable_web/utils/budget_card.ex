defmodule SpendableWeb.Utils.BudgetCard do
  @moduledoc """
  What a budget reads as on the budgets screen: the number to show, what to call it, how far
  along the bar is, and the line underneath.

  Extracted from the LiveView rather than left private because the iOS client has to reach the
  same six answers, and `shared/budget_cards.json` drives a table test on both sides. Colours
  stay with each client - `bar` says which of the three bars this is, not what it looks like.
  """

  import Spendable.Utils

  alias Spendable.Budgets.Schemas.Budget

  # A past month is a record of what was spent, so a balance read now says nothing about it.
  def build_budget_card(_budget, spent, false = _current_month_is_selected) do
    %{amount: spent, label: "SPENT", percent: nil, bar: nil, footer: nil}
  end

  def build_budget_card(%Budget{type: :tracking}, spent, _current_month_is_selected) do
    %{amount: spent, label: "SPENT", percent: nil, bar: nil, footer: nil}
  end

  def build_budget_card(%Budget{type: :envelope, budgeted_amount: nil} = budget, _spent, _current) do
    %{amount: budget.balance, label: "LEFT", percent: nil, bar: nil, footer: nil}
  end

  def build_budget_card(%Budget{type: :envelope} = budget, spent, _current_month_is_selected) do
    over_budget? = Decimal.compare(spent, budget.budgeted_amount) == :gt

    %{
      amount: budget.balance,
      label: "LEFT",
      percent: percent(spent, budget.budgeted_amount),
      bar: if(over_budget?, do: "over", else: "under"),
      footer: "#{format_currency(spent)} of #{format_currency(budget.budgeted_amount)} spent"
    }
  end

  def build_budget_card(%Budget{type: :goal, budgeted_amount: nil} = budget, _spent, _current) do
    %{amount: budget.balance, label: "SAVED", percent: nil, bar: nil, footer: "No goal set"}
  end

  def build_budget_card(%Budget{type: :goal} = budget, _spent, _current_month_is_selected) do
    %{
      amount: Decimal.sub(budget.budgeted_amount, budget.balance),
      label: "TO GO",
      percent: percent(budget.balance, budget.budgeted_amount),
      bar: "goal",
      footer: "#{format_currency(budget.balance)} of #{format_currency(budget.budgeted_amount)} saved"
    }
  end

  defp percent(_part, %Decimal{coef: 0}), do: 0.0

  defp percent(part, whole) do
    part
    |> Decimal.div(whole)
    |> Decimal.mult(100)
    |> Decimal.to_float()
    |> max(0.0)
    |> min(100.0)
    |> Float.round(1)
  end
end
