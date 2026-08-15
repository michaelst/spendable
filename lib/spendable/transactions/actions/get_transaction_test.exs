defmodule Spendable.Transactions.Actions.GetTransactionTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Scope
  alias Spendable.Transactions
  alias Spendable.Transactions.Schemas.Transaction

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, %{id: transaction_id} = transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    %{scope: scope, transaction: transaction, transaction_id: transaction_id}
  end

  test "returns the transaction with its allocations", %{
    scope: scope,
    transaction_id: transaction_id
  } do
    assert {:ok, %Transaction{id: ^transaction_id} = found} =
             Transactions.get_transaction(scope, id: transaction_id)

    assert [_spendable_allocation] = found.budget_allocations
  end

  test "errors when no transaction matches", %{scope: scope} do
    assert {:error, :transaction_not_found} =
             Transactions.get_transaction(scope, name: "Nope")
  end

  test "errors when the transaction belongs to a different user", %{transaction_id: transaction_id} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :transaction_not_found} =
             Transactions.get_transaction(Scope.for_user(other_user), id: transaction_id)
  end
end
