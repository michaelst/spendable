defmodule Spendable.Budget.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_factory() do
        %Spendable.Budget{
          name: "Food"
        }
      end
    end
  end
end
