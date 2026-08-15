defmodule Spendable.Budgets.Actions.CalculateSpendableTest do
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

  test "is zero with no accounts and no budgets", %{scope: scope} do
    assert Decimal.eq?(Budgets.calculate_spendable(scope), "0.00")
  end

  # No bank balance to draw on, so an envelope holding 30 leaves the pool 30 short.
  test "subtracts what an envelope budget claims", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _adjusted} = Budgets.update_budget(scope, budget, %{"balance" => "30.00"})

    assert Decimal.eq?(Budgets.calculate_spendable(scope), "-30.00")
  end

  test "ignores tracking budgets", %{scope: scope} do
    {:ok, spendable} = Budgets.find_or_create_spendable_budget(scope)
    {:ok, _adjusted} = Budgets.update_budget(scope, spendable, %{"balance" => "30.00"})

    assert Decimal.eq?(Budgets.calculate_spendable(scope), "0.00")
  end

  test "ignores other users' budgets", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    other_scope = Scope.for_user(other_user)
    {:ok, budget} = Budgets.create_budget(other_scope, %{"name" => "Theirs"})
    {:ok, _adjusted} = Budgets.update_budget(other_scope, budget, %{"balance" => "30.00"})

    assert Decimal.eq?(Budgets.calculate_spendable(scope), "0.00")
  end

  test "ignores what an excluded transaction allocated to an envelope", %{scope: scope} do
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

    assert Decimal.eq?(Budgets.calculate_spendable(scope), "0.00")
  end
end
