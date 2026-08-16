defmodule SpendableWeb.MCP.Tools.ListBudgetsTest do
  use Spendable.DataCase, async: true

  alias Anubis.Server.Frame
  alias Anubis.Server.Response
  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias SpendableWeb.MCP.Tools.ListBudgets

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    %{frame: Frame.new(%{current_scope: scope}), scope: scope}
  end

  test "lists the budgets of the user the frame acts as", %{frame: frame, scope: scope} do
    {:ok, _budget} = Budgets.create_budget(scope, %{"name" => "Groceries", "budgeted_amount" => "250.00"})

    assert {:reply,
            %Response{
              structured_content: %{
                budgets: [
                  %{name: "Groceries", type: :envelope, balance: "0.00", budgeted_amount: "250.00"}
                ]
              }
            }, ^frame} = ListBudgets.execute(%{}, frame)
  end

  test "lists only budgets matching a search", %{frame: frame, scope: scope} do
    {:ok, _groceries} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _rent} = Budgets.create_budget(scope, %{"name" => "Rent"})

    assert {:reply, %Response{structured_content: %{budgets: [%{name: "Rent", budgeted_amount: nil}]}}, ^frame} =
             ListBudgets.execute(%{search: "Ren"}, frame)
  end

  test "does not list another user's budgets", %{frame: frame} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Groceries"})

    assert {:reply, %Response{structured_content: %{budgets: []}}, ^frame} = ListBudgets.execute(%{}, frame)
  end
end
