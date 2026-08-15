defmodule Spendable.Transactions.Actions.UpdateTransactionTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions
  alias Spendable.Transactions.Schemas.Transaction

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    %{scope: scope, budget: budget, transaction: transaction}
  end

  test "renames a transaction", %{scope: scope, transaction: transaction} do
    assert {:ok, %Transaction{name: "Espresso"}} =
             Transactions.update_transaction(scope, transaction, %{"name" => "Espresso"})
  end

  test "marks a transaction reviewed", %{scope: scope, transaction: transaction} do
    assert {:ok, %Transaction{reviewed: true}} =
             Transactions.update_transaction(scope, transaction, %{"reviewed" => true})
  end

  # The remainder follows the amount, so raising it grows what waits in Spendable.
  test "moves the Spendable line when the amount changes", %{scope: scope, transaction: transaction} do
    {:ok, _updated} = Transactions.update_transaction(scope, transaction, %{"amount" => "-8.00"})

    {:ok, %{id: spendable_id}} = Budgets.find_or_create_spendable_budget(scope)
    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)

    assert [%{budget_id: ^spendable_id, amount: amount}] = transaction.budget_allocations
    assert Decimal.eq?(amount, "-8.00")
  end

  test "splits the amount and leaves the remainder in Spendable", %{
    scope: scope,
    budget: budget,
    transaction: transaction
  } do
    {:ok, _updated} =
      Transactions.update_transaction(scope, transaction, %{
        "budget_allocations" => %{"0" => %{"amount" => "-2.00", "budget_id" => budget.id}}
      })

    {:ok, spendable} = Budgets.find_or_create_spendable_budget(scope)
    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)

    by_budget = Map.new(transaction.budget_allocations, &{&1.budget_id, &1.amount})

    assert Decimal.eq?(by_budget[budget.id], "-2.00")
    assert Decimal.eq?(by_budget[spendable.id], "-3.00")
  end

  test "errors when the transaction belongs to a different user", %{transaction: transaction} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Transactions.update_transaction(Scope.for_user(other_user), transaction, %{
               "name" => "Theirs"
             })
  end

  test "errors when the name is blank", %{scope: scope, transaction: transaction} do
    assert {:error, changeset} =
             Transactions.update_transaction(scope, transaction, %{"name" => ""})

    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end
end
