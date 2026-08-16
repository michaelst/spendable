defmodule SpendableWeb.MCP.Tools.ListTransactionsTest do
  use Spendable.DataCase, async: true

  alias Anubis.Server.Frame
  alias Anubis.Server.Response
  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Scope
  alias Spendable.Transactions
  alias SpendableWeb.MCP.Tools.ListTransactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    %{frame: Frame.new(%{current_scope: scope}), scope: scope}
  end

  test "lists a transaction with how it is allocated", %{frame: frame, scope: scope} do
    {:ok, %Budget{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, _transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-40.00",
        "date" => "2026-08-01",
        "budget_allocations" => [%{"amount" => "-40.00", "budget_id" => budget_id}]
      })

    assert {:reply,
            %Response{
              structured_content: %{
                transactions: [
                  %{
                    name: "Market",
                    date: "2026-08-01",
                    amount: "-40.00",
                    reviewed: false,
                    excluded: false,
                    allocations: [%{budget_id: ^budget_id, amount: "-40.00"}]
                  }
                ]
              }
            }, ^frame} = ListTransactions.execute(%{}, frame)
  end

  test "leaves out reviewed transactions unless asked for", %{frame: frame, scope: scope} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{"name" => "Market", "amount" => "-40.00", "date" => "2026-08-01"})

    {:ok, _reviewed} = Transactions.update_transaction(scope, transaction, %{"reviewed" => true})

    assert {:reply, %Response{structured_content: %{transactions: []}}, ^frame} =
             ListTransactions.execute(%{}, frame)

    assert {:reply, %Response{structured_content: %{transactions: [%{name: "Market", reviewed: true}]}}, ^frame} =
             ListTransactions.execute(%{show_reviewed: true}, frame)
  end

  test "narrows the list by search and page size", %{frame: frame, scope: scope} do
    {:ok, _market} =
      Transactions.create_transaction(scope, %{"name" => "Market", "amount" => "-40.00", "date" => "2026-08-01"})

    {:ok, _rent} =
      Transactions.create_transaction(scope, %{"name" => "Rent", "amount" => "-900.00", "date" => "2026-08-02"})

    assert {:reply, %Response{structured_content: %{transactions: [%{name: "Rent"}]}}, ^frame} =
             ListTransactions.execute(%{search: "Ren"}, frame)

    assert {:reply, %Response{structured_content: %{transactions: [%{name: "Market"}]}}, ^frame} =
             ListTransactions.execute(%{page: 2, per_page: 1}, frame)
  end

  test "does not list another user's transactions", %{frame: frame} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _transaction} =
      Transactions.create_transaction(Scope.for_user(other_user), %{
        "name" => "Market",
        "amount" => "-40.00",
        "date" => "2026-08-01"
      })

    assert {:reply, %Response{structured_content: %{transactions: []}}, ^frame} =
             ListTransactions.execute(%{}, frame)
  end
end
