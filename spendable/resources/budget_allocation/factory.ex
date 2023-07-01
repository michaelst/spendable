defmodule Spendable.BudgetAllocation.Factory do
  def default() do
    %{
      amount: Spendable.TestUtils.random_decimal(500..100_000)
    }
  end
end
