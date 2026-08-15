defmodule Spendable.Transactions.Actions.ReplacePendingTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, pending} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, settled} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.25",
        "date" => "2026-08-16",
        "reviewed" => false
      })

    %{scope: scope, pending: pending, settled: settled}
  end

  test "moves the pending allocations onto the settled transaction", %{
    scope: scope,
    pending: pending,
    settled: settled
  } do
    {:ok, %{id: budget_id} = budget} = Budgets.create_budget(scope, %{"name" => "Coffee"})

    {:ok, pending} =
      Transactions.update_transaction(scope, pending, %{
        "budget_allocations" => %{"0" => %{"amount" => "-5.00", "budget_id" => budget.id}}
      })

    assert {:ok, _settled} = Transactions.replace_pending(scope, pending, settled)
    assert {:error, :transaction_not_found} = Transactions.get_transaction(scope, id: pending.id)

    {:ok, settled} = Transactions.get_transaction(scope, id: settled.id)

    assert [%{budget_id: _spendable}, %{budget_id: ^budget_id, amount: moved}] =
             settled.budget_allocations

    assert Decimal.eq?(moved, "-5.00")
  end

  test "errors when the transactions belong to a different user", %{
    pending: pending,
    settled: settled
  } do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Transactions.replace_pending(Scope.for_user(other_user), pending, settled)
  end
end
