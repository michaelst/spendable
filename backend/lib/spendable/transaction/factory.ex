defmodule Spendable.Transaction.Factory do
  defmacro __using__(_opts) do
    quote do
      def transaction_factory() do
        %Spendable.Transaction{
          amount: 10.25,
          date: Date.utc_today(),
          name: "test",
          note: "some notes",
          reviewed: false
        }
      end
    end
  end
end
