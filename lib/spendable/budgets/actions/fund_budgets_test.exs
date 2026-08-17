defmodule Spendable.Budgets.Actions.FundBudgetsTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  # Months well behind the current one, so what a self-funding budget puts into today's month on
  # creation never collides with the month a test is funding on purpose.
  @month ~D[2020-05-01]
  @earlier ~D[2020-04-01]
  @next_month ~D[2020-06-01]

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "puts a budget's funding amount into the month", %{scope: scope} do
    {:ok, %{id: budget_id} = budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    assert {:ok, 1} = Budgets.fund_budgets(scope, @month)

    assert %{^budget_id => funded} = Budgets.calculate_funded(scope, [budget], @month)
    assert Decimal.eq?(funded, "300.00")
  end

  test "funds a month once, however many times it runs", %{scope: scope} do
    {:ok, _budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    assert {:ok, 1} = Budgets.fund_budgets(scope, @month)
    assert {:ok, 0} = Budgets.fund_budgets(scope, @month)
    assert {:ok, 0} = Budgets.fund_budgets(scope, ~D[2020-05-27])
  end

  test "funds each month it is asked for, so a balance rolls up", %{scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    assert Decimal.eq?(budget.balance, "300.00")

    assert {:ok, 1} = Budgets.fund_budgets(scope, @earlier)
    assert {:ok, 1} = Budgets.fund_budgets(scope, @month)

    {:ok, filled} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(filled.balance, "900.00")
  end

  test "skips a budget with no funding amount", %{scope: scope} do
    {:ok, _budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    assert {:ok, 0} = Budgets.fund_budgets(scope, @month)
  end

  test "skips budgets that keep no balance", %{scope: scope} do
    {:ok, _tracking} =
      Budgets.create_budget(scope, %{
        "name" => "Fuel",
        "type" => "tracking",
        "budgeted_amount" => "80.00"
      })

    {:ok, _income} =
      Budgets.create_budget(scope, %{
        "name" => "Salary",
        "type" => "income",
        "budgeted_amount" => "4200.00"
      })

    assert {:ok, 0} = Budgets.fund_budgets(scope, @month)
  end

  test "funds a goal toward its target", %{scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{
        "name" => "Holiday",
        "type" => "goal",
        "budgeted_amount" => "2000.00",
        "funding_amount" => "50.00"
      })

    assert {:ok, 1} = Budgets.fund_budgets(scope, @month)

    {:ok, filled} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(filled.balance, "100.00")
  end

  test "skips an archived budget", %{scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    {:ok, _archived} = Budgets.archive_budget(scope, budget)

    assert {:ok, 0} = Budgets.fund_budgets(scope, @month)
  end

  test "leaves another user's budgets alone", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _theirs} =
      Budgets.create_budget(Scope.for_user(other_user), %{
        "name" => "Theirs",
        "funding_amount" => "300.00"
      })

    assert {:ok, 0} = Budgets.fund_budgets(scope, @month)
  end

  test "takes the funded money out of what is left to spend", %{scope: scope} do
    {:ok, _budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    assert Decimal.eq?(Budgets.calculate_spendable(scope), "-300.00")
  end

  test "carries an overspend into the next month when it rolls over", %{scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    {:ok, _spend} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-350.00",
        "date" => Date.utc_today(),
        "budget_allocations" => %{"0" => %{"amount" => "-350.00", "budget_id" => budget.id}}
      })

    {:ok, overspent} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(overspent.balance, "-50.00")

    assert {:ok, 1} = Budgets.fund_budgets(scope, @next_month)

    {:ok, funded} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(funded.balance, "250.00")
  end

  test "tops an overspend back up when it does not roll over", %{scope: scope} do
    {:ok, %{id: budget_id} = budget} =
      Budgets.create_budget(scope, %{
        "name" => "Groceries",
        "funding_amount" => "300.00",
        "rollover" => "false"
      })

    {:ok, _spend} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-350.00",
        "date" => Date.utc_today(),
        "budget_allocations" => %{"0" => %{"amount" => "-350.00", "budget_id" => budget.id}}
      })

    assert {:ok, 1} = Budgets.fund_budgets(scope, @next_month)

    {:ok, funded} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(funded.balance, "300.00")

    assert %{^budget_id => topped_up} = Budgets.calculate_funded(scope, [budget], @next_month)
    assert Decimal.eq?(topped_up, "350.00")
  end

  test "does not let leftover accumulate when it does not roll over", %{scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{
        "name" => "Groceries",
        "funding_amount" => "300.00",
        "rollover" => "false"
      })

    {:ok, _spend} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-200.00",
        "date" => Date.utc_today(),
        "budget_allocations" => %{"0" => %{"amount" => "-200.00", "budget_id" => budget.id}}
      })

    assert {:ok, 1} = Budgets.fund_budgets(scope, @next_month)

    {:ok, funded} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(funded.balance, "300.00")
  end

  test "a goal always rolls over, however it is asked", %{scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{
        "name" => "Holiday",
        "type" => "goal",
        "budgeted_amount" => "2000.00",
        "funding_amount" => "50.00",
        "rollover" => "false"
      })

    assert budget.rollover

    assert {:ok, 1} = Budgets.fund_budgets(scope, @next_month)

    {:ok, funded} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(funded.balance, "100.00")
  end
end
