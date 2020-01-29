defmodule Spendable.Budgets.BudgetAllocationTemplateLine.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_template_line_factory(attrs) do
        line = %Spendable.Budgets.BudgetAllocationTemplateLine{
          amount: Spendable.TestUtils.random_decimal(500..100_000),
          priority: sequence(:priority, & &1),
          budget: build(:budget, user_id: attrs[:user_id])
        }

        merge_attributes(line, Map.drop(attrs, [:user_id]))
      end
    end
  end
end
