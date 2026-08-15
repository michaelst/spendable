defmodule Spendable.Budgets.Actions.FindOrCreateSpendableBudgetTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "creates the Spendable budget as a tracking budget", %{scope: scope} do
    assert {:ok, %Budget{name: "Spendable", type: :tracking}} =
             Budgets.find_or_create_spendable_budget(scope)
  end

  test "returns the existing one rather than a second", %{scope: scope} do
    {:ok, %{id: budget_id}} = Budgets.find_or_create_spendable_budget(scope)

    assert {:ok, %Budget{id: ^budget_id}} = Budgets.find_or_create_spendable_budget(scope)
    assert [%{name: "Spendable"}] = Budgets.list_budgets(scope)
  end

  test "gives each user their own", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, %{id: mine}} = Budgets.find_or_create_spendable_budget(scope)
    {:ok, %{id: theirs}} = Budgets.find_or_create_spendable_budget(Scope.for_user(other_user))

    refute mine == theirs
  end
end
