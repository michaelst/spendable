defmodule Spendable.BudgetAllocationTemplate.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_allocation_template_factory(attrs) do
        template = %Spendable.BudgetAllocationTemplate{
          name: "Payday",
          budget_allocation_template_lines: [
            build(:budget_allocation_template_line, user_id: attrs[:user_id]),
            build(:budget_allocation_template_line, user_id: attrs[:user_id])
          ],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }

        merge_attributes(template, attrs)
      end
    end
  end
end
