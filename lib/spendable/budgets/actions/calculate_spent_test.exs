defmodule Spendable.Budgets.Actions.CalculateSpentTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope

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
end
