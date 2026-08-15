defmodule Spendable.Budgets.Actions.CreateBudgetTest do
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

  test "creates a budget owned by the scope's user", %{scope: scope} do
    %{id: user_id} = scope.user

    assert {:ok, %Budget{id: "bgt_" <> _uxid, name: "Groceries", type: :envelope, user_id: ^user_id}} =
             Budgets.create_budget(scope, %{"name" => "Groceries"})
  end

  test "ignores a user_id supplied in attrs", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{id: user_id} = scope.user

    assert {:ok, %Budget{user_id: ^user_id}} =
             Budgets.create_budget(scope, %{"name" => "Groceries", "user_id" => other_user.id})
  end

  test "starts with a zero adjustment", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    assert Decimal.eq?(budget.adjustment, "0.00")
  end

  test "accepts a budgeted amount and type", %{scope: scope} do
    assert {:ok, %Budget{type: :goal, budgeted_amount: budgeted_amount}} =
             Budgets.create_budget(scope, %{
               "name" => "Holiday",
               "type" => "goal",
               "budgeted_amount" => "500.00"
             })

    assert Decimal.eq?(budgeted_amount, "500.00")
  end

  test "errors without a name", %{scope: scope} do
    assert {:error, changeset} = Budgets.create_budget(scope, %{})

    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end
end
