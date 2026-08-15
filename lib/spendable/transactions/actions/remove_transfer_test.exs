defmodule Spendable.Transactions.Actions.RemoveTransferTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Scope
  alias Spendable.Transactions
  alias Spendable.Transactions.Schemas.Transaction

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, out} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer to savings",
        "amount" => "-500.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, in_} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer from checking",
        "amount" => "500.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, in_)
    {:ok, out} = Transactions.get_transaction(scope, id: out.id)

    %{scope: scope, out: out, in: in_}
  end

  test "unlinks both sides", %{scope: scope, out: out, in: in_} do
    assert {:ok, %Transaction{transfer_id: nil}} = Transactions.remove_transfer(scope, out)

    assert {:ok, %Transaction{transfer_id: nil}} = Transactions.get_transaction(scope, id: out.id)
    assert {:ok, %Transaction{transfer_id: nil}} = Transactions.get_transaction(scope, id: in_.id)
  end

  test "errors when the transaction is not part of a transfer", %{scope: scope} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    assert {:error, :not_a_transfer} = Transactions.remove_transfer(scope, transaction)
  end

  test "errors when the transaction belongs to a different user", %{out: out} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Transactions.remove_transfer(Scope.for_user(other_user), out)
  end
end
