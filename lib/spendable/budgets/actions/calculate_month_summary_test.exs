defmodule Spendable.Budgets.Actions.CalculateMonthSummaryTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, %{id: budget_id}} =
      Budgets.create_budget(scope, %{
        "name" => "Groceries",
        "type" => "envelope",
        "funding_amount" => "400.00"
      })

    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-30.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, _allocated} =
      Transactions.update_transaction(scope, transaction, %{
        "budget_allocations" => %{"0" => %{"amount" => "-30.00", "budget_id" => budget_id}}
      })

    %{scope: scope, budget_id: budget_id}
  end

  test "totals what envelopes budgeted and spent", %{scope: scope, budget_id: budget_id} do
    summary = Budgets.calculate_month_summary(scope, ~D[2026-08-15])

    assert Decimal.eq?(summary.allocated_total, "400.00")
    assert Decimal.eq?(summary.spent_total, "30.00")
    assert Decimal.eq?(summary.spent[budget_id], "30.00")
  end

  test "any date in a month selects that whole month", %{scope: scope} do
    assert %{month: ~D[2026-08-01]} = Budgets.calculate_month_summary(scope, ~D[2026-08-27])
  end

  test "reports whether the month asked for is the current one", %{scope: scope} do
    assert %{current_month: true} =
             Budgets.calculate_month_summary(scope, Date.utc_today())

    assert %{current_month: false} =
             Budgets.calculate_month_summary(scope, Date.add(Date.utc_today(), -60))
  end

  test "counts nothing spent in a month with no activity", %{scope: scope} do
    summary = Budgets.calculate_month_summary(scope, ~D[2026-07-01])

    assert Decimal.eq?(summary.spent_total, "0")
    assert Decimal.eq?(summary.allocated_total, "400.00")
  end

  test "leaves a tracking budget out of the totals", %{scope: scope} do
    {:ok, %{id: tracked_id}} =
      Budgets.create_budget(scope, %{"name" => "Fuel", "type" => "tracking"})

    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Petrol",
        "amount" => "-50.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, _allocated} =
      Transactions.update_transaction(scope, transaction, %{
        "budget_allocations" => %{"0" => %{"amount" => "-50.00", "budget_id" => tracked_id}}
      })

    summary = Budgets.calculate_month_summary(scope, ~D[2026-08-15])

    assert Decimal.eq?(summary.spent_total, "30.00")
    assert Decimal.eq?(summary.spent[tracked_id], "50.00")
  end

  test "narrows the budgets to a search", %{scope: scope} do
    {:ok, _other} = Budgets.create_budget(scope, %{"name" => "Holiday"})

    summary = Budgets.calculate_month_summary(scope, ~D[2026-08-15], search: "Holi")

    assert [%{name: "Holiday"}] = summary.budgets
  end

  test "offers the current month in the picker even with nothing spent in it", %{scope: scope} do
    current_month = Date.beginning_of_month(Date.utc_today())
    summary = Budgets.calculate_month_summary(scope, current_month)

    assert [%{month: ^current_month} | _older] = summary.spent_by_month
  end
end
