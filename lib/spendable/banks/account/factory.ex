defmodule Spendable.Banks.Account.Factory do
  defmacro __using__(_opts) do
    quote do
      def bank_account_factory(attrs) do
        bank_account = %Spendable.Banks.Account{
          bank_member: build(:bank_member, user: attrs[:user]),
          external_id: Faker.UUID.v4(),
          name: "Checking",
          balance: "100.00",
          type: "depository",
          sub_type: "checking",
          sync: true
        }

        merge_attributes(bank_account, attrs)
      end
    end
  end
end
