defmodule Spendable.Transactions.Actions.CreateTransactionTest do
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
    {:ok, %{id: budget_id} = budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    %{scope: scope, budget: budget, budget_id: budget_id}
  end

  test "creates a transaction owned by the scope's user", %{scope: scope} do
    %{id: user_id} = scope.user

    assert {:ok, %Transaction{id: "txn_" <> _uxid, name: "Coffee", user_id: ^user_id}} =
             Transactions.create_transaction(scope, %{
               "name" => "Coffee",
               "amount" => "-5.00",
               "date" => "2026-08-15",
               "reviewed" => false
             })
  end

  # A transaction is never partly unallocated: what the user does not assign waits in Spendable.
  test "sends the whole amount to Spendable when nothing is allocated", %{scope: scope} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, %{id: spendable_id}} = Budgets.find_or_create_spendable_budget(scope)
    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)

    assert [%{budget_id: ^spendable_id, amount: amount}] = transaction.budget_allocations
    assert Decimal.eq?(amount, "-5.00")
  end

  test "sends only the remainder to Spendable", %{scope: scope, budget: budget} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Shopping",
        "amount" => "-50.00",
        "date" => "2026-08-15",
        "reviewed" => false,
        "budget_allocations" => %{"0" => %{"amount" => "-30.00", "budget_id" => budget.id}}
      })

    {:ok, spendable} = Budgets.find_or_create_spendable_budget(scope)
    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)

    by_budget = Map.new(transaction.budget_allocations, &{&1.budget_id, &1.amount})

    assert Decimal.eq?(by_budget[budget.id], "-30.00")
    assert Decimal.eq?(by_budget[spendable.id], "-20.00")
  end

  test "adds no Spendable line when the transaction is fully allocated", %{
    scope: scope,
    budget: budget,
    budget_id: budget_id
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Shopping",
        "amount" => "-50.00",
        "date" => "2026-08-15",
        "reviewed" => false,
        "budget_allocations" => %{"0" => %{"amount" => "-50.00", "budget_id" => budget.id}}
      })

    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)

    assert [%{budget_id: ^budget_id}] = transaction.budget_allocations
  end

  test "rejects an allocation pointing at another user's budget", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, their_budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Theirs"})

    assert {:error, changeset} =
             Transactions.create_transaction(scope, %{
               "name" => "Shopping",
               "amount" => "-50.00",
               "date" => "2026-08-15",
               "reviewed" => false,
               "budget_allocations" => %{
                 "0" => %{"amount" => "-50.00", "budget_id" => their_budget.id}
               }
             })

    assert %{budget_allocations: [%{budget_id: ["does not exist"]}]} = errors_on(changeset)
  end

  test "errors without a name", %{scope: scope} do
    assert {:error, changeset} =
             Transactions.create_transaction(scope, %{
               "amount" => "-5.00",
               "date" => "2026-08-15",
               "reviewed" => false
             })

    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end
end
