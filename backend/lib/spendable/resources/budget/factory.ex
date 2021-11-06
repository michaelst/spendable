defmodule Spendable.Budget.Factory do
  defmacro __using__(_opts) do
    quote do
      def budget_factory() do
        %Spendable.Budget{
          name: "Food",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end
    end
  end
end
