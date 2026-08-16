defmodule SpendableWeb.MCP.Tools.AllocateTransactionTest do
  use Spendable.DataCase, async: true

  alias Anubis.Server.Frame
  alias Anubis.Server.Response
  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Scope
  alias Spendable.Transactions
  alias SpendableWeb.MCP.Tools.AllocateTransaction

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, %Budget{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, transaction} =
      Transactions.create_transaction(scope, %{"name" => "Market", "amount" => "-40.00", "date" => "2026-08-01"})

    %{budget_id: budget_id, frame: Frame.new(%{current_scope: scope}), scope: scope, transaction: transaction}
  end

  test "divides a transaction across budgets", %{budget_id: budget_id, frame: frame, transaction: transaction} do
    assert {:reply,
            %Response{
              structured_content: %{
                transaction: %{allocations: [%{budget_id: ^budget_id, amount: "-40.00"}], reviewed: false}
              }
            }, ^frame} =
             AllocateTransaction.execute(
               %{transaction_id: transaction.id, allocations: [%{budget_id: budget_id, amount: "-40.00"}]},
               frame
             )
  end

  test "leaves whatever is not allocated in Spendable", %{
    budget_id: budget_id,
    frame: frame,
    scope: scope,
    transaction: transaction
  } do
    assert {:reply, %Response{structured_content: %{transaction: %{allocations: allocations}}}, ^frame} =
             AllocateTransaction.execute(
               %{transaction_id: transaction.id, allocations: [%{budget_id: budget_id, amount: "-30.00"}]},
               frame
             )

    {:ok, %Budget{id: spendable_id}} = Budgets.get_budget(scope, name: "Spendable")

    assert [%{budget_id: ^budget_id, amount: "-30.00"}, %{budget_id: ^spendable_id, amount: "-10.00"}] =
             Enum.sort_by(allocations, & &1.amount, :desc)
  end

  test "replaces the allocations a transaction already had", %{
    budget_id: budget_id,
    frame: frame,
    scope: scope,
    transaction: transaction
  } do
    {:reply, %Response{isError: false}, ^frame} =
      AllocateTransaction.execute(
        %{transaction_id: transaction.id, allocations: [%{budget_id: budget_id, amount: "-40.00"}]},
        frame
      )

    {:ok, %Budget{id: other_budget_id}} =
      Budgets.create_budget(scope, %{"name" => "Dining"})

    assert {:reply,
            %Response{
              structured_content: %{
                transaction: %{allocations: [%{budget_id: ^other_budget_id, amount: "-40.00"}], reviewed: true}
              }
            }, ^frame} =
             AllocateTransaction.execute(
               %{
                 transaction_id: transaction.id,
                 allocations: [%{budget_id: other_budget_id, amount: "-40.00"}],
                 reviewed: true
               },
               frame
             )
  end

  test "cannot reach a transaction belonging to another user", %{budget_id: budget_id, frame: frame} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, transaction} =
      Transactions.create_transaction(Scope.for_user(other_user), %{
        "name" => "Market",
        "amount" => "-40.00",
        "date" => "2026-08-01"
      })

    assert {:reply, %Response{isError: true, content: [%{"text" => "transaction not found"}]}, ^frame} =
             AllocateTransaction.execute(
               %{transaction_id: transaction.id, allocations: [%{budget_id: budget_id, amount: "-40.00"}]},
               frame
             )
  end

  test "refuses an allocation to a budget the user does not own", %{frame: frame, transaction: transaction} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, other_budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Groceries"})

    assert {:reply, %Response{isError: true, content: [%{"text" => text}]}, ^frame} =
             AllocateTransaction.execute(
               %{transaction_id: transaction.id, allocations: [%{budget_id: other_budget.id, amount: "-40.00"}]},
               frame
             )

    assert text =~ "does not exist"
  end
end
