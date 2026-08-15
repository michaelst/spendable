defmodule Spendable.Budgets.Actions.CalculateSpentTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

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

  test "ignores a transfer", %{scope: scope, budget: budget, budget_id: budget_id} do
    {:ok, out} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer to savings",
        "amount" => "-20.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, into} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer from checking",
        "amount" => "20.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, into)
    {:ok, out} = Transactions.get_transaction(scope, id: out.id)

    {:ok, _allocated} =
      Transactions.update_transaction(scope, out, %{
        "budget_allocations" => %{"0" => %{"amount" => "-20.00", "budget_id" => budget_id}}
      })

    assert %{^budget_id => spent} = Budgets.calculate_spent(scope, [budget], ~D[2026-08-15])
    assert Decimal.eq?(spent, "0.00")
  end
end
