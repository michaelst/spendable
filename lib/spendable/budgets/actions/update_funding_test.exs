defmodule Spendable.Budgets.Actions.UpdateFundingTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Funding
  alias Spendable.Scope

  # Behind the current month, so creating a self-funding budget does not fund these as a side
  # effect and every figure below is one this test put there.
  @month ~D[2020-05-01]
  @earlier ~D[2020-04-01]

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, %{id: budget_id} = budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "funding_amount" => "300.00"})

    %{scope: scope, budget: budget, budget_id: budget_id}
  end

  test "funds a month that was never funded", %{scope: scope, budget: budget, budget_id: budget_id} do
    assert {:ok, %Funding{id: "fnd_" <> _uxid, month: @month}} =
             Budgets.update_funding(scope, budget, ~D[2020-05-15], "200.00")

    assert %{^budget_id => funded} = Budgets.calculate_funded(scope, [budget], @month)
    assert Decimal.eq?(funded, "200.00")
  end

  test "replaces what the month was already funded with", %{scope: scope, budget: budget, budget_id: budget_id} do
    {:ok, 1} = Budgets.fund_budgets(scope, @month)
    {:ok, _funding} = Budgets.update_funding(scope, budget, @month, "200.00")

    assert %{^budget_id => funded} = Budgets.calculate_funded(scope, [budget], @month)
    assert Decimal.eq?(funded, "200.00")
  end

  test "leaves every other month alone", %{scope: scope, budget: budget, budget_id: budget_id} do
    {:ok, 1} = Budgets.fund_budgets(scope, @earlier)
    {:ok, 1} = Budgets.fund_budgets(scope, @month)
    {:ok, _funding} = Budgets.update_funding(scope, budget, @month, "0.00")

    assert %{^budget_id => funded} = Budgets.calculate_funded(scope, [budget], @earlier)
    assert Decimal.eq?(funded, "300.00")
  end

  test "records a skipped month rather than removing it", %{scope: scope, budget: budget} do
    {:ok, %Funding{amount: amount}} = Budgets.update_funding(scope, budget, @month, "0.00")

    assert Decimal.eq?(amount, "0.00")
    assert {:ok, 0} = Budgets.fund_budgets(scope, @month)
  end

  test "refuses a budget belonging to someone else", %{budget: budget} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Budgets.update_funding(Scope.for_user(other_user), budget, @month, "200.00")
  end

  test "errors without an amount", %{scope: scope, budget: budget} do
    assert {:error, changeset} = Budgets.update_funding(scope, budget, @month, nil)

    assert %{amount: ["can't be blank"]} = errors_on(changeset)
  end
end
