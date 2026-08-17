defmodule Spendable.Budgets.Actions.CalculateSpentTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, %{id: budget_id} = budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    %{scope: scope, budget: budget, budget_id: budget_id}
  end

  test "reports zero for a budget nothing was spent against", %{
    scope: scope,
    budget: budget,
    budget_id: budget_id
  } do
    assert %{^budget_id => spent} = Budgets.calculate_spent(scope, [budget], Date.utc_today())
    assert Decimal.eq?(spent, "0.00")
  end

  test "returns nothing when given no budgets", %{scope: scope} do
    assert %{} == Budgets.calculate_spent(scope, [], Date.utc_today())
  end

  test "nets money coming back against money that went out", %{
    scope: scope,
    budget: budget,
    budget_id: budget_id
  } do
    {:ok, _spend} =
      Transactions.create_transaction(scope, %{
        "name" => "Dinner for the table",
        "amount" => "-200.00",
        "date" => "2026-08-15",
        "budget_allocations" => %{"0" => %{"amount" => "-200.00", "budget_id" => budget_id}}
      })

    {:ok, _reimbursement} =
      Transactions.create_transaction(scope, %{
        "name" => "Paid back",
        "amount" => "200.00",
        "date" => "2026-08-16",
        "budget_allocations" => %{"0" => %{"amount" => "200.00", "budget_id" => budget_id}}
      })

    assert %{^budget_id => spent} = Budgets.calculate_spent(scope, [budget], ~D[2026-08-15])
    assert Decimal.eq?(spent, "0.00")
  end

  test "nets a partial refund", %{scope: scope, budget: budget, budget_id: budget_id} do
    {:ok, _spend} =
      Transactions.create_transaction(scope, %{
        "name" => "Groceries",
        "amount" => "-200.00",
        "date" => "2026-08-15",
        "budget_allocations" => %{"0" => %{"amount" => "-200.00", "budget_id" => budget_id}}
      })

    {:ok, _refund} =
      Transactions.create_transaction(scope, %{
        "name" => "Returned the bad melon",
        "amount" => "5.00",
        "date" => "2026-08-16",
        "budget_allocations" => %{"0" => %{"amount" => "5.00", "budget_id" => budget_id}}
      })

    assert %{^budget_id => spent} = Budgets.calculate_spent(scope, [budget], ~D[2026-08-15])
    assert Decimal.eq?(spent, "195.00")
  end

  # An income budget records money arriving and never spends, so it has no figure here at all.
  test "leaves an income budget out of spending", %{scope: scope} do
    {:ok, %{id: salary_id} = salary} =
      Budgets.create_budget(scope, %{"name" => "Salary", "type" => "income"})

    {:ok, _paycheck} =
      Transactions.create_transaction(scope, %{
        "name" => "Payday",
        "amount" => "4200.00",
        "date" => "2026-08-15",
        "budget_allocations" => %{"0" => %{"amount" => "4200.00", "budget_id" => salary_id}}
      })

    assert %{^salary_id => spent} = Budgets.calculate_spent(scope, [salary], ~D[2026-08-15])
    assert Decimal.eq?(spent, "0.00")
  end

  # Money arriving in a spending budget is a refund, whatever it was, so it comes off the month.
  test "reduces spending by money arriving, even a paycheck", %{
    scope: scope,
    budget: budget,
    budget_id: budget_id
  } do
    {:ok, _spend} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-300.00",
        "date" => "2026-08-15",
        "budget_allocations" => %{"0" => %{"amount" => "-300.00", "budget_id" => budget_id}}
      })

    {:ok, _pay} =
      Transactions.create_transaction(scope, %{
        "name" => "Payday",
        "amount" => "500.00",
        "date" => "2026-08-16",
        "budget_allocations" => %{"0" => %{"amount" => "500.00", "budget_id" => budget_id}}
      })

    assert %{^budget_id => spent} = Budgets.calculate_spent(scope, [budget], ~D[2026-08-15])
    assert Decimal.eq?(spent, "-200.00")
  end

  test "ignores a transfer", %{scope: scope, budget: budget, budget_id: budget_id} do
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
        "budget_allocations" => %{"0" => %{"amount" => "-20.00", "budget_id" => budget_id}}
      })

    assert %{^budget_id => spent} = Budgets.calculate_spent(scope, [budget], ~D[2026-08-15])
    assert Decimal.eq?(spent, "0.00")
  end
end
