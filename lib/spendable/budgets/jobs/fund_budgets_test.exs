defmodule Spendable.Budgets.Jobs.FundBudgetsTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Jobs.FundBudgets
  alias Spendable.Scope

  # Behind the current month, which creating a self-funding budget fills on its own. Funding that
  # month here would say nothing about whether the job did anything.
  @month "2020-05-01"

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "funds the month it is given, and only once", %{scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    assert {:ok, 1} = perform_job(FundBudgets, %{"month" => @month})

    {:ok, filled} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(filled.balance, "600.00")

    # The daily schedule only works because funding a month again costs nothing - otherwise every
    # run after the first would double what the budgets hold.
    assert {:ok, 0} = perform_job(FundBudgets, %{"month" => @month})

    {:ok, unchanged} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(unchanged.balance, "600.00")
  end

  test "funds every user, not just one", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _mine} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    {:ok, _theirs} =
      Budgets.create_budget(Scope.for_user(other_user), %{
        "name" => "Theirs",
        "funding_amount" => "50.00"
      })

    assert {:ok, 2} = perform_job(FundBudgets, %{"month" => @month})
  end

  test "skips a budget that does not fund itself", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    assert {:ok, 0} = perform_job(FundBudgets, %{"month" => @month})

    {:ok, unfilled} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(unfilled.balance, "0.00")
  end

  # What the cron sends. Creating the budget has already filled this month, which is the whole
  # reason the job is safe to run every day rather than only on the first.
  test "falls back to the current month when the args say nothing", %{scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    assert {:ok, 0} = perform_job(FundBudgets, %{})

    {:ok, filled} = Budgets.get_budget(scope, id: budget.id)
    assert Decimal.eq?(filled.balance, "300.00")
  end
end
