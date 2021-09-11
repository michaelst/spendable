defmodule Spendable.BankAccount.Factory do
  defmacro __using__(_opts) do
    quote do
      def bank_account_factory(attrs) do
        bank_account = %Spendable.BankAccount{
          external_id: Ecto.UUID.generate(),
          name: "Checking",
          balance: "100.00",
          type: "depository",
          sub_type: "checking",
          sync: true,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }

        merge_attributes(bank_account, attrs)
      end
    end
  end
end
