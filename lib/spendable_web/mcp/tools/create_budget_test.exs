defmodule SpendableWeb.MCP.Tools.CreateBudgetTest do
  use Spendable.DataCase, async: true

  alias Anubis.Server.Frame
  alias Anubis.Server.Response
  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias SpendableWeb.MCP.Tools.CreateBudget

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    %{frame: Frame.new(%{current_scope: scope}), scope: scope}
  end

  test "creates a budget the user can then list", %{frame: frame, scope: scope} do
    assert {:reply,
            %Response{
              structured_content: %{budget: %{name: "Groceries", type: :envelope, funding_amount: "250.00"}}
            }, ^frame} =
             CreateBudget.execute(%{name: "Groceries", funding_amount: "250.00"}, frame)

    assert [%{name: "Groceries"}] = Budgets.list_budgets(scope)
  end

  test "records an adjustment when a starting balance is given", %{frame: frame, scope: scope} do
    assert {:reply, %Response{isError: false}, ^frame} =
             CreateBudget.execute(%{name: "Groceries", type: "goal", balance: "40.00"}, frame)

    assert [%{type: :goal, balance: balance}] = Budgets.list_budgets(scope)
    assert Decimal.eq?(balance, "40.00")
  end

  test "reports why a budget could not be created", %{frame: frame} do
    assert {:reply, %Response{isError: true, content: [%{"text" => "name can't be blank"}]}, ^frame} =
             CreateBudget.execute(%{name: ""}, frame)
  end
end
