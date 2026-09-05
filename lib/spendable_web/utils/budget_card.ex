defmodule SpendableWeb.Utils.BudgetCard do
  @moduledoc """
  What a budget reads as on the budgets screen: the number to show, what to call it, how far
  along the bar is, and the line underneath.

  Extracted from the LiveView rather than left private because the iOS client has to reach the
  same six answers, and `shared/budget_cards.json` drives a table test on both sides. Colours
  stay with each client - `bar` says which of the four bars this is, not what it looks like.

  The month is passed as one map of what moved - `spent` and `received` - because which of them a
  card reads depends on what kind of budget it is, and a budget that spends never receives.
  """

  import Spendable.Utils

  alias Spendable.Budgets.Schemas.Budget

  # A past month is a record of what moved, so a balance read now says nothing about it.
  def build_budget_card(%Budget{type: :income}, %{received: received}, false = _current_month) do
    %{amount: received, label: "EARNED", percent: nil, bar: nil, footer: nil}
  end

  def build_budget_card(_budget, %{spent: spent}, false = _current_month_is_selected) do
    %{amount: spent, label: "SPENT", percent: nil, bar: nil, footer: nil}
  end

  def build_budget_card(%Budget{type: :tracking, budgeted_amount: nil}, %{spent: spent}, _current) do
    %{amount: spent, label: "SPENT", percent: nil, bar: nil, footer: nil}
  end

  def build_budget_card(%Budget{type: :tracking} = budget, %{spent: spent}, _current) do
    %{
      amount: spent,
      label: "SPENT",
      percent: percent(spent, budget.budgeted_amount),
      bar: spending_bar(spent, budget.budgeted_amount),
      footer: "#{format_currency(spent)} of #{format_currency(budget.budgeted_amount)} spent"
    }
  end

  def build_budget_card(%Budget{type: :income, budgeted_amount: nil}, %{received: received}, _current) do
    %{amount: received, label: "EARNED", percent: nil, bar: nil, footer: nil}
  end

  # Money in is the point here, so there is no bar to be the wrong side of: it fills as the month
  # earns and the footer says how far along that is.
  def build_budget_card(%Budget{type: :income} = budget, %{received: received}, _current) do
    %{
      amount: received,
      label: "EARNED",
      percent: percent(received, budget.budgeted_amount),
      bar: "income",
      footer: "#{format_currency(received)} of #{format_currency(budget.budgeted_amount)} received"
    }
  end

  def build_budget_card(%Budget{type: :envelope, funding_amount: nil} = budget, _month, _current) do
    held(budget)
  end

  # An envelope has one amount: what a month puts in, which is also what its spending is read
  # against. There is nothing to say about funding separately because they are the same figure.
  def build_budget_card(%Budget{type: :envelope} = budget, %{spent: spent}, _current) do
    %{
      held(budget)
      | percent: percent(spent, budget.funding_amount),
        bar: spending_bar(spent, budget.funding_amount),
        footer: "#{format_currency(spent)} of #{format_currency(budget.funding_amount)} spent"
    }
  end

  def build_budget_card(%Budget{type: :goal, budgeted_amount: nil} = budget, _month, _current) do
    %{amount: budget.balance, label: "SAVED", percent: nil, bar: nil, footer: "No goal set"}
  end

  def build_budget_card(%Budget{type: :goal} = budget, _month, _current_month_is_selected) do
    saved_line =
      "#{format_currency(budget.balance)} of #{format_currency(budget.budgeted_amount)} saved"

    %{
      amount: Decimal.sub(budget.budgeted_amount, budget.balance),
      label: "TO GO",
      percent: percent(budget.balance, budget.budgeted_amount),
      bar: "goal",
      footer: suffix_monthly(saved_line, budget.funding_amount)
    }
  end

  # An envelope in the hole is not holding a negative amount, it is short by a positive one - the
  # same way a goal counts what is still TO GO rather than a negative saving. Clients colour the
  # label, since the figure no longer carries a minus sign to key off.
  defp held(%Budget{balance: balance} = budget) do
    if Decimal.negative?(balance) do
      %{amount: Decimal.abs(balance), label: "OVERSPENT", percent: nil, bar: nil, footer: nil}
    else
      %{amount: budget.balance, label: "REMAINING", percent: nil, bar: nil, footer: nil}
    end
  end

  defp spending_bar(spent, budgeted_amount) do
    if Decimal.compare(spent, budgeted_amount) == :gt, do: "over", else: "under"
  end

  defp suffix_monthly(line, nil), do: line
  defp suffix_monthly(line, funding_amount), do: "#{line} · #{format_currency(funding_amount)}/mo"

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
