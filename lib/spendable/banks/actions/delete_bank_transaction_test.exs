defmodule Spendable.Banks.Actions.DeleteBankTransactionTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Scope
  alias Spendable.TestData
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {_account, bank_transaction} = TestData.FinanceKit.card_with_charge(scope)

    %{scope: scope, bank_transaction: bank_transaction}
  end

  # A declined or reversed authorization did not happen, so the user's work on it goes too.
  test "takes the transaction with it", %{scope: scope, bank_transaction: bank_transaction} do
    assert {:ok, _deleted} = Banks.delete_bank_transaction(scope, bank_transaction)

    assert [] = Transactions.list_transactions(scope)

    assert {:error, :bank_transaction_not_found} =
             Banks.get_bank_transaction(scope, external_id: "txn-1")
  end

  test "refuses a charge belonging to another user", %{bank_transaction: bank_transaction} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Banks.delete_bank_transaction(Scope.for_user(other_user), bank_transaction)
  end
end
