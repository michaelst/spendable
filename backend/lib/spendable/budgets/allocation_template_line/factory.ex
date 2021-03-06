defmodule Spendable.Budgets.AllocationTemplateLine.Factory do
  defmacro __using__(_opts) do
    quote do
      def allocation_template_line_factory(attrs) do
        line = %Spendable.Budgets.AllocationTemplateLine{
          amount: Spendable.TestUtils.random_decimal(500..100_000),
          budget: build(:budget, user: attrs[:user]),
          user: attrs[:user]
        }

        merge_attributes(line, attrs)
      end
    end
  end
end
