defmodule Spendable.BankMember.Factory do
  defmacro __using__(_opts) do
    quote do
      def bank_member_factory(attrs) do
        bank_member = %Spendable.BankMember{
          external_id: Ecto.UUID.generate(),
          institution_id: "ins_1",
          name: "Plaid",
          plaid_token: "access-sandbox-898addd0-d983-45f8-a034-3b29d62794a7",
          provider: "Plaid",
          status: "CONNECTED",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }

        merge_attributes(bank_member, attrs)
      end
    end
  end
end
