defmodule Spendable.Banks.Member.Factory do
  defmacro __using__(_opts) do
    quote do
      def bank_member_factory() do
        %Spendable.Banks.Member{
          external_id: Faker.UUID.v4(),
          institution_id: "ins_1",
          name: "Plaid",
          plaid_token: "access-sandbox-898addd0-d983-45f8-a034-3b29d62794a7",
          provider: "Plaid",
          status: "Connected"
        }
      end
    end
  end
end
