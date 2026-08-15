defmodule Spendable.Budgets.Actions.UpdateBudgetTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    %{scope: scope, budget: budget}
  end

  test "renames a budget", %{scope: scope, budget: budget} do
    assert {:ok, %Budget{name: "Food"}} =
             Budgets.update_budget(scope, budget, %{"name" => "Food"})
  end

  # The user sets a balance; the adjustment is what the app derives to make that balance true.
  test "writes the adjustment needed to reach a requested balance", %{
    scope: scope,
    budget: budget
  } do
    assert {:ok, %Budget{adjustment: adjustment, balance: balance}} =
             Budgets.update_budget(scope, budget, %{"balance" => "25.00"})

    assert Decimal.eq?(adjustment, "25.00")
    assert Decimal.eq?(balance, "25.00")
  end

  test "moves the adjustment by the difference when the balance changes again", %{
    scope: scope,
    budget: budget
  } do
    {:ok, budget} = Budgets.update_budget(scope, budget, %{"balance" => "25.00"})

    assert {:ok, %Budget{adjustment: adjustment}} =
             Budgets.update_budget(scope, budget, %{"balance" => "40.00"})

    assert Decimal.eq?(adjustment, "40.00")
  end

  test "leaves the adjustment alone when no balance is requested", %{
    scope: scope,
    budget: budget
  } do
    {:ok, budget} = Budgets.update_budget(scope, budget, %{"balance" => "25.00"})

    assert {:ok, %Budget{adjustment: adjustment}} =
             Budgets.update_budget(scope, budget, %{"name" => "Food"})

    assert Decimal.eq?(adjustment, "25.00")
  end

  test "errors when the budget belongs to a different user", %{budget: budget} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Budgets.update_budget(Scope.for_user(other_user), budget, %{"name" => "Food"})
  end

  test "errors when the name is blank", %{scope: scope, budget: budget} do
    assert {:error, changeset} = Budgets.update_budget(scope, budget, %{"name" => ""})

    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end
end
