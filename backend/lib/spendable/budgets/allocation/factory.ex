defmodule Spendable.Budgets.Allocation.Factory do
  defmacro __using__(_opts) do
    quote do
      def allocation_factory(attrs) do
        allocation = %Spendable.Budgets.Allocation{
          amount: Spendable.TestUtils.random_decimal(500..100_000),
          budget: build(:budget, user_id: attrs[:user_id]),
          transaction: build(:transaction, user_id: attrs[:user_id])
        }

        merge_attributes(allocation, attrs)
      end
    end
  end
end
