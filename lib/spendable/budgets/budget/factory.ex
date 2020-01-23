defmodule Spendable.Budgets.Budget.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_factory do
        %Spendable.Budgets.Budget{
          balance: Spendable.TestUtils.random_decimal(500..100_000),
          name: "Food"
        }
      end

      def goal_factory do
        %Spendable.Budgets.Budget{
          goal: Spendable.TestUtils.random_decimal(500_000..1_000_000),
          balance: Spendable.TestUtils.random_decimal(120_000..800_000),
          name: "Vacation"
        }
      end
    end
  end
end
