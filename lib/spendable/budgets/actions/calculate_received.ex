defmodule Spendable.Budgets.Actions.CalculateReceived do
  @moduledoc false

  import Spendable.Budgets.Utils.SumAllocations

  alias Spendable.Scope

  @zero Decimal.new("0.00")

  @doc """
  What each of the given budgets took in over one month, keyed by budget id.

  Only an income budget receives. Every other budget spends, and what arrives in one of those is a
  refund against its spending rather than money taken in, so it is left out here and comes back at
  zero - see `calculate_spent/3`.

  The sum is not negated: money arriving is positive, which is the direction an income budget is
  read in.
  """
  def calculate_received(_scope, [], _month), do: %{}

  def calculate_received(%Scope{user: %{id: user_id}}, budgets, month) do
    income = Enum.filter(budgets, &(&1.type == :income))
    received = sum_allocations(user_id, Enum.map(income, & &1.id), month)

    Map.new(budgets, &{&1.id, Map.get(received, &1.id, @zero)})
  end
end
