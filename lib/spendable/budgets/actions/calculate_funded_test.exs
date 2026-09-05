defmodule Spendable.Budgets.Actions.CalculateFundedTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope

  # Behind the current month, which a self-funding budget fills on creation.
  @month ~D[2020-05-01]

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, %{id: budget_id} = budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    %{scope: scope, budget: budget, budget_id: budget_id}
  end

  test "reports what the month funded", %{scope: scope, budget: budget, budget_id: budget_id} do
    {:ok, 1} = Budgets.fund_budgets(scope, @month)

    assert %{^budget_id => funded} = Budgets.calculate_funded(scope, [budget], ~D[2020-05-15])
    assert Decimal.eq?(funded, "300.00")
  end

  test "reports zero for a month that funded nothing", %{
    scope: scope,
    budget: budget,
    budget_id: budget_id
  } do
    {:ok, 1} = Budgets.fund_budgets(scope, @month)

    assert %{^budget_id => funded} = Budgets.calculate_funded(scope, [budget], ~D[2020-04-01])
    assert Decimal.eq?(funded, "0.00")
  end

  test "returns nothing when given no budgets", %{scope: scope} do
    assert %{} == Budgets.calculate_funded(scope, [], @month)
  end

  test "leaves another user's funding out", %{scope: scope, budget: budget, budget_id: budget_id} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, 1} = Budgets.fund_budgets(scope, @month)

    assert %{^budget_id => funded} =
             Budgets.calculate_funded(Scope.for_user(other_user), [budget], @month)

    assert Decimal.eq?(funded, "0.00")
  end
end
