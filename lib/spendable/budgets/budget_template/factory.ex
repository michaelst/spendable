defmodule Spendable.Budgets.BudgetTemplate.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_template_factory(attrs) do
        template = %Spendable.Budgets.BudgetTemplate{
          name: "Payday",
          lines: [
            build(:budget_template_line, user_id: attrs[:user_id]),
            build(:budget_template_line, user_id: attrs[:user_id])
          ]
        }

        merge_attributes(template, attrs)
      end
    end
  end
end
