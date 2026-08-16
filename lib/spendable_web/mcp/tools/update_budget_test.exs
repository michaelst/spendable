defmodule SpendableWeb.MCP.Tools.UpdateBudgetTest do
  use Spendable.DataCase, async: true

  alias Anubis.Server.Frame
  alias Anubis.Server.Response
  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias SpendableWeb.MCP.Tools.UpdateBudget

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    %{budget: budget, frame: Frame.new(%{current_scope: scope}), scope: scope}
  end

  test "changes only the fields it is given", %{budget: budget, frame: frame} do
    assert {:reply,
            %Response{structured_content: %{budget: %{name: "Food", type: :envelope, budgeted_amount: "300.00"}}},
            ^frame} =
             UpdateBudget.execute(%{budget_id: budget.id, name: "Food", budgeted_amount: "300.00"}, frame)
  end

  test "sets the balance the user asks for", %{budget: budget, frame: frame, scope: scope} do
    assert {:reply, %Response{structured_content: %{budget: %{balance: "40.00"}}}, ^frame} =
             UpdateBudget.execute(%{budget_id: budget.id, balance: "40.00"}, frame)

    assert [%{balance: balance}] = Budgets.list_budgets(scope)
    assert Decimal.eq?(balance, "40.00")
  end

  test "cannot reach a budget belonging to another user", %{frame: frame} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Groceries"})

    assert {:reply, %Response{isError: true, content: [%{"text" => "budget not found"}]}, ^frame} =
             UpdateBudget.execute(%{budget_id: budget.id, name: "Food"}, frame)
  end

  test "reports why a budget could not be changed", %{budget: budget, frame: frame} do
    assert {:reply, %Response{isError: true, content: [%{"text" => "name can't be blank"}]}, ^frame} =
             UpdateBudget.execute(%{budget_id: budget.id, name: ""}, frame)
  end
end
