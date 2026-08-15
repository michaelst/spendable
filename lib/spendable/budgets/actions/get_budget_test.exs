defmodule Spendable.Budgets.Actions.GetBudgetTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, %{id: budget_id} = budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    %{scope: scope, budget: budget, budget_id: budget_id}
  end

  test "returns the budget with its balance filled in", %{scope: scope, budget_id: budget_id} do
    assert {:ok, %Budget{id: ^budget_id, balance: balance}} =
             Budgets.get_budget(scope, id: budget_id)

    assert Decimal.eq?(balance, "0.00")
  end

  test "errors when no budget matches", %{scope: scope} do
    assert {:error, :budget_not_found} = Budgets.get_budget(scope, name: "Nope")
  end

  # The id is real, so this proves the owner filter refuses it rather than simply not finding it.
  test "errors when the budget belongs to a different user", %{budget: budget} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :budget_not_found} =
             Budgets.get_budget(Scope.for_user(other_user), id: budget.id)
  end
end
