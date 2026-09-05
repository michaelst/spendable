defmodule Spendable.Budgets.Actions.CalculateSpent do
  @moduledoc false

  import Spendable.Budgets.Utils.SumAllocations

  alias Spendable.Scope

  @zero Decimal.new("0.00")

  @doc """
  What each of the given budgets was spent against in one month, keyed by budget id.

  Every positive allocation reduces spending: money coming back to a budget cancels money that
  went out of it, so a reimbursement settles the spend it repays and a refund reduces it. That
  holds whatever the money was - a budget records what it is left holding, not where the money
  came from.

  An income budget records money arriving and never spends, so it is left out entirely and comes
  back at zero. `calculate_received/3` is what reads those. An excluded transaction never counts.

  Returns a map rather than decorating the budgets: spending belongs to a month, not to a budget,
  so a budget struct is the wrong place to keep it. Every id asked for comes back, at zero if
  nothing moved.
  """
  def calculate_spent(_scope, [], _month), do: %{}

  def calculate_spent(%Scope{user: %{id: user_id}}, budgets, month) do
    spending = Enum.reject(budgets, &(&1.type == :income))

    spent =
      user_id
      |> sum_allocations(Enum.map(spending, & &1.id), month)
      |> Map.new(fn {budget_id, net} -> {budget_id, Decimal.negate(net)} end)

    Map.new(budgets, &{&1.id, Map.get(spent, &1.id, @zero)})
  end
end
