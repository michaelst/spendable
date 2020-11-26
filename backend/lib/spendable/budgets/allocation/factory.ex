defmodule Spendable.Budgets.Allocation.Factory do
  defmacro __using__(_opts) do
    quote do
      def allocation_factory(attrs) do
        allocation = %Spendable.Budgets.Allocation{
          amount: Spendable.TestUtils.random_decimal(500..100_000),
          budget: build(:budget, user: attrs[:user]),
          transaction: build(:transaction, user: attrs[:user])
        }

        merge_attributes(allocation, attrs)
      end
    end
  end
end
