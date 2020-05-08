defmodule Spendable.Budgets.AllocationTemplate.Factory do
  defmacro __using__(_opts) do
    quote do
      def allocation_template_factory(attrs) do
        template = %Spendable.Budgets.AllocationTemplate{
          name: "Payday",
          lines: [
            build(:allocation_template_line, user: attrs[:user]),
            build(:allocation_template_line, user: attrs[:user])
          ]
        }

        merge_attributes(template, attrs)
      end
    end
  end
end
