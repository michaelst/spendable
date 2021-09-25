defmodule Spendable.BudgetAllocationTemplate.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_allocation_template_factory(attrs) do
        template = %Spendable.BudgetAllocationTemplate{
          name: "Payday",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }

        merge_attributes(template, attrs)
      end
    end
  end
end
