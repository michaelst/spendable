defmodule Spendable.BudgetAllocation.Factory do
  def default() do
    %{
      # Spendable.TestUtils.random_decimal(500..100_000)
      amount: 1
    }
  end
end
