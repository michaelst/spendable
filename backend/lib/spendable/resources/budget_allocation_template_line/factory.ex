defmodule Spendable.BudgetAllocationTemplateLine.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_allocation_template_line_factory(attrs) do
        line = %Spendable.BudgetAllocationTemplateLine{
          amount: Spendable.TestUtils.random_decimal(500..100_000),
          budget: build(:budget, user_id: attrs[:user_id]),
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }

        merge_attributes(line, attrs)
      end
    end
  end
end
