defmodule Spendable.Banks.Actions.UpsertFinanceKitMemberTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "creates the connection the device reports into", %{scope: scope} do
    assert {:ok, %BankMember{name: "Apple", provider: "FinanceKit", plaid_token: nil}} =
             Banks.upsert_finance_kit_member(scope)
  end

  # The app asks on every authorization, and a second connection would split the accounts in two.
  test "asking twice returns the connection already held", %{scope: scope} do
    {:ok, %{id: id}} = Banks.upsert_finance_kit_member(scope)

    assert {:ok, %BankMember{id: ^id}} = Banks.upsert_finance_kit_member(scope)
    assert [%{name: "Apple"}] = Banks.list_bank_members(scope)
  end

  test "comes back with its accounts loaded", %{scope: scope} do
    {:ok, member} = Banks.upsert_finance_kit_member(scope)

    {:ok, _account} =
      Banks.upsert_bank_account(scope, member, %{
        balance: Decimal.new("-42.00"),
        external_id: "apple-card",
        name: "Apple Card",
        sub_type: "credit card",
        type: "credit"
      })

    assert {:ok, %BankMember{bank_accounts: [%{name: "Apple Card"}]}} =
             Banks.upsert_finance_kit_member(scope)
  end
end
