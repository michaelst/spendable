defmodule Spendable.Banks.Actions.GetBankAccountTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, %BankAccount{id: account_id}} =
      Repo.insert(%BankAccount{
        user_id: user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Checking",
        balance: Decimal.new("100.00"),
        sub_type: "checking",
        type: "depository"
      })

    %{scope: Scope.for_user(user), account_id: account_id}
  end

  test "returns the account", %{scope: scope, account_id: account_id} do
    assert {:ok, %BankAccount{id: ^account_id, name: "Checking"}} =
             Banks.get_bank_account(scope, account_id)
  end

  test "errors when there is no such account", %{scope: scope} do
    assert {:error, :bank_account_not_found} = Banks.get_bank_account(scope, "bka_nope")
  end

  test "errors when the account belongs to a different user", %{account_id: account_id} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :bank_account_not_found} =
             Banks.get_bank_account(Scope.for_user(other_user), account_id)
  end
end
