defmodule Spendable.Budgets.Actions.ArchiveBudgetTest do
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

  test "archives a budget", %{scope: scope, budget: budget} do
    assert {:ok, %Budget{archived_at: %DateTime{}}} = Budgets.archive_budget(scope, budget)
  end

  test "errors when the budget is already archived", %{scope: scope, budget: budget} do
    {:ok, budget} = Budgets.archive_budget(scope, budget)

    assert {:error, :already_archived} = Budgets.archive_budget(scope, budget)
  end

  test "errors when the budget belongs to a different user", %{budget: budget} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} = Budgets.archive_budget(Scope.for_user(other_user), budget)
  end

  test "drops the budget from the list", %{scope: scope, budget: budget} do
    {:ok, _archived} = Budgets.archive_budget(scope, budget)

    assert [] = Budgets.list_budgets(scope)
  end
end
