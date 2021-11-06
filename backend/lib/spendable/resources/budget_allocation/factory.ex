defmodule Spendable.BudgetAllocation.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_allocation_factory(attrs) do
        budget_id = attrs[:budget_id] || insert(:budget, user_id: attrs[:user_id]).id
        transaction_id = attrs[:transaction_id] || insert(:transaction, user_id: attrs[:user_id]).id

        allocation = %Spendable.BudgetAllocation{
          amount: Spendable.TestUtils.random_decimal(500..100_000),
          budget_id: budget_id,
          transaction_id: transaction_id,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }

        merge_attributes(allocation, attrs)
      end
    end
  end
end
