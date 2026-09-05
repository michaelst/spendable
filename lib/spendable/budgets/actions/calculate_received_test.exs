defmodule Spendable.Budgets.Actions.CalculateReceivedTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, %{id: salary_id} = salary} =
      Budgets.create_budget(scope, %{"name" => "Salary", "type" => "income"})

    %{scope: scope, salary: salary, salary_id: salary_id}
  end

  test "reports what an income budget took in", %{
    scope: scope,
    salary: salary,
    salary_id: salary_id
  } do
    {:ok, _paycheck} =
      Transactions.create_transaction(scope, %{
        "name" => "Payday",
        "amount" => "4200.00",
        "date" => "2026-08-15",
        "budget_allocations" => %{"0" => %{"amount" => "4200.00", "budget_id" => salary_id}}
      })

    assert %{^salary_id => received} = Budgets.calculate_received(scope, [salary], ~D[2026-08-15])
    assert Decimal.eq?(received, "4200.00")
  end

  test "keeps each source apart", %{scope: scope, salary: salary, salary_id: salary_id} do
    {:ok, %{id: rewards_id} = rewards} =
      Budgets.create_budget(scope, %{"name" => "Card Rewards", "type" => "income"})

    {:ok, _paycheck} =
      Transactions.create_transaction(scope, %{
        "name" => "Payday",
        "amount" => "4200.00",
        "date" => "2026-08-15",
        "budget_allocations" => %{"0" => %{"amount" => "4200.00", "budget_id" => salary_id}}
      })

    {:ok, _cashback} =
      Transactions.create_transaction(scope, %{
        "name" => "Cashback",
        "amount" => "40.00",
        "date" => "2026-08-16",
        "budget_allocations" => %{"0" => %{"amount" => "40.00", "budget_id" => rewards_id}}
      })

    received = Budgets.calculate_received(scope, [salary, rewards], ~D[2026-08-15])

    assert Decimal.eq?(received[salary_id], "4200.00")
    assert Decimal.eq?(received[rewards_id], "40.00")
  end

  # A refund landing in an envelope is money off that month's spending, not money taken in.
  test "leaves a budget that spends out of what was received", %{scope: scope} do
    {:ok, %{id: groceries_id} = groceries} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, _refund} =
      Transactions.create_transaction(scope, %{
        "name" => "Returned",
        "amount" => "20.00",
        "date" => "2026-08-15",
        "budget_allocations" => %{"0" => %{"amount" => "20.00", "budget_id" => groceries_id}}
      })

    assert %{^groceries_id => received} =
             Budgets.calculate_received(scope, [groceries], ~D[2026-08-15])

    assert Decimal.eq?(received, "0.00")
  end

  test "reports zero for a month nothing arrived in", %{
    scope: scope,
    salary: salary,
    salary_id: salary_id
  } do
    assert %{^salary_id => received} = Budgets.calculate_received(scope, [salary], ~D[2026-07-01])
    assert Decimal.eq?(received, "0.00")
  end

  test "returns nothing when given no budgets", %{scope: scope} do
    assert %{} == Budgets.calculate_received(scope, [], ~D[2026-08-15])
  end

  test "leaves another user's income out", %{scope: scope, salary: salary, salary_id: salary_id} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _paycheck} =
      Transactions.create_transaction(scope, %{
        "name" => "Payday",
        "amount" => "4200.00",
        "date" => "2026-08-15",
        "budget_allocations" => %{"0" => %{"amount" => "4200.00", "budget_id" => salary_id}}
      })

    assert %{^salary_id => received} =
             Budgets.calculate_received(Scope.for_user(other_user), [salary], ~D[2026-08-15])

    assert Decimal.eq?(received, "0.00")
  end
end
