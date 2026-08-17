defmodule SpendableWeb.MCP.Tools.FundBudgetTest do
  use Spendable.DataCase, async: true

  alias Anubis.Server.Frame
  alias Anubis.Server.Response
  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias SpendableWeb.MCP.Tools.FundBudget

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, %{id: budget_id} = budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    %{frame: Frame.new(%{current_scope: scope}), scope: scope, budget: budget, budget_id: budget_id}
  end

  test "puts money into a named month", %{frame: frame, budget: budget} do
    assert {:reply,
            %Response{
              structured_content: %{
                funding: %{name: "Groceries", month: "2020-05-01", amount: "200.00", balance: "200.00"}
              }
            }, ^frame} =
             FundBudget.execute(
               %{budget_id: budget.id, amount: "200.00", month: "2020-05-15"},
               frame
             )
  end

  test "funds the current month when none is given", %{
    frame: frame,
    scope: scope,
    budget: budget,
    budget_id: budget_id
  } do
    assert {:reply, %Response{isError: false}, ^frame} =
             FundBudget.execute(%{budget_id: budget_id, amount: "200.00"}, frame)

    month = Date.beginning_of_month(Date.utc_today())

    assert %{^budget_id => funded} = Budgets.calculate_funded(scope, [budget], month)
    assert Decimal.eq?(funded, "200.00")
  end

  test "replaces what a month was funded with rather than adding to it", %{
    frame: frame,
    budget: budget
  } do
    {:reply, %Response{isError: false}, ^frame} =
      FundBudget.execute(%{budget_id: budget.id, amount: "300.00", month: "2020-05-01"}, frame)

    assert {:reply, %Response{structured_content: %{funding: %{balance: "200.00"}}}, ^frame} =
             FundBudget.execute(
               %{budget_id: budget.id, amount: "200.00", month: "2020-05-01"},
               frame
             )
  end

  test "reports a month it cannot read", %{frame: frame, budget: budget} do
    assert {:reply, %Response{isError: true}, ^frame} =
             FundBudget.execute(%{budget_id: budget.id, amount: "200.00", month: "May"}, frame)
  end

  test "reports a budget that is not the user's", %{frame: frame} do
    assert {:reply, %Response{isError: true}, ^frame} =
             FundBudget.execute(%{budget_id: "bgt_nope", amount: "200.00"}, frame)
  end
end
