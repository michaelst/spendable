defmodule Spendable.Transactions.Actions.DeleteTransactionTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Scope
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    %{scope: scope, transaction: transaction}
  end

  test "deletes a transaction and its allocations", %{scope: scope, transaction: transaction} do
    assert {:ok, _deleted} = Transactions.delete_transaction(scope, transaction)
    assert [] = Transactions.list_transactions(scope)
    assert {:error, :transaction_not_found} = Transactions.get_transaction(scope, id: transaction.id)
  end

  test "errors when the transaction belongs to a different user", %{transaction: transaction} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Transactions.delete_transaction(Scope.for_user(other_user), transaction)
  end
end
