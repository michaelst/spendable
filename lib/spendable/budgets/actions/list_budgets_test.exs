defmodule Spendable.Budgets.Actions.ListBudgetsTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "sorts Spendable first, then alphabetically", %{scope: scope} do
    {:ok, _rent} = Budgets.create_budget(scope, %{"name" => "Rent"})
    {:ok, _groceries} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _spendable} = Budgets.find_or_create_spendable_budget(scope)

    assert [%{name: "Spendable"}, %{name: "Groceries"}, %{name: "Rent"}] =
             Budgets.list_budgets(scope)
  end

  test "excludes archived budgets", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _archived} = Budgets.archive_budget(scope, budget)

    assert [] = Budgets.list_budgets(scope)
  end

  test "excludes other users' budgets", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _theirs} =
      Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Not Mine"})

    {:ok, _mine} = Budgets.create_budget(scope, %{"name" => "Mine"})

    assert [%{name: "Mine"}] = Budgets.list_budgets(scope)
  end

  test "filters by a search term", %{scope: scope} do
    {:ok, _groceries} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _rent} = Budgets.create_budget(scope, %{"name" => "Rent"})

    assert [%{name: "Groceries"}] = Budgets.list_budgets(scope, search: "groc")
  end

  test "ignores a blank search term", %{scope: scope} do
    {:ok, _groceries} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    assert [%{name: "Groceries"}] = Budgets.list_budgets(scope, search: "")
  end

  test "reports the adjustment as the balance when nothing is allocated", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _adjusted} = Budgets.update_budget(scope, budget, %{"balance" => "30.00"})

    assert [%{balance: balance}] = Budgets.list_budgets(scope)
    assert Decimal.eq?(balance, "30.00")
  end

  test "leaves an excluded transaction out of the balance", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, _transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Reimbursed lunch",
        "amount" => "-20.00",
        "date" => "2026-08-15",
        "reviewed" => false,
        "excluded" => true,
        "budget_allocations" => %{"0" => %{"amount" => "-20.00", "budget_id" => budget.id}}
      })

    assert [%{name: "Spendable"}, %{name: "Groceries", balance: balance}] = Budgets.list_budgets(scope)
    assert Decimal.eq?(balance, "0.00")
  end

  test "leaves a transfer out of the balance", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, out} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer to savings",
        "amount" => "-20.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, into} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer from checking",
        "amount" => "20.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, into)
    {:ok, out} = Transactions.get_transaction(scope, id: out.id)

    {:ok, _allocated} =
      Transactions.update_transaction(scope, out, %{
        "budget_allocations" => %{"0" => %{"amount" => "-20.00", "budget_id" => budget.id}}
      })

    assert [%{name: "Spendable"}, %{name: "Groceries", balance: balance}] = Budgets.list_budgets(scope)
    assert Decimal.eq?(balance, "0.00")
  end
end
