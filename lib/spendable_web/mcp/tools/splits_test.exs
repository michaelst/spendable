defmodule SpendableWeb.MCP.Tools.SplitsTest do
  use Spendable.DataCase, async: true

  alias Anubis.Server.Frame
  alias Anubis.Server.Response
  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Scope
  alias SpendableWeb.MCP.Tools.ArchiveSplit
  alias SpendableWeb.MCP.Tools.CreateSplit
  alias SpendableWeb.MCP.Tools.ListSplits
  alias SpendableWeb.MCP.Tools.UpdateSplit

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, %Budget{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    %{budget_id: budget_id, frame: Frame.new(%{current_scope: scope}), scope: scope}
  end

  test "creates a split and lists it with its lines", %{budget_id: budget_id, frame: frame} do
    assert {:reply, %Response{structured_content: %{split: %{name: "Weekly shop"}}}, ^frame} =
             CreateSplit.execute(
               %{name: "Weekly shop", lines: [%{budget_id: budget_id, amount: "-40.00"}]},
               frame
             )

    assert {:reply,
            %Response{
              structured_content: %{
                splits: [%{name: "Weekly shop", lines: [%{budget_id: ^budget_id, amount: "-40.00"}]}]
              }
            }, ^frame} = ListSplits.execute(%{}, frame)
  end

  test "replaces the lines a split had", %{budget_id: budget_id, frame: frame, scope: scope} do
    {:ok, split} =
      Budgets.create_split(scope, %{
        "name" => "Weekly shop",
        "split_lines" => [%{"budget_id" => budget_id, "amount" => "-40.00"}]
      })

    {:ok, %Budget{id: dining_id}} = Budgets.create_budget(scope, %{"name" => "Dining"})

    assert {:reply,
            %Response{
              structured_content: %{
                split: %{name: "Big shop", lines: [%{budget_id: ^dining_id, amount: "-60.00"}]}
              }
            }, ^frame} =
             UpdateSplit.execute(
               %{split_id: split.id, name: "Big shop", lines: [%{budget_id: dining_id, amount: "-60.00"}]},
               frame
             )
  end

  test "archives a split so it stops being listed", %{budget_id: budget_id, frame: frame, scope: scope} do
    {:ok, split} =
      Budgets.create_split(scope, %{
        "name" => "Weekly shop",
        "split_lines" => [%{"budget_id" => budget_id, "amount" => "-40.00"}]
      })

    assert {:reply, %Response{structured_content: %{split: %{archived: true}}}, ^frame} =
             ArchiveSplit.execute(%{split_id: split.id}, frame)

    assert {:reply, %Response{structured_content: %{splits: []}}, ^frame} = ListSplits.execute(%{}, frame)

    assert {:reply, %Response{isError: true, content: [%{"text" => "already archived"}]}, ^frame} =
             ArchiveSplit.execute(%{split_id: split.id}, frame)
  end

  test "cannot reach a split belonging to another user", %{frame: frame} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    other_scope = Scope.for_user(other_user)
    {:ok, budget} = Budgets.create_budget(other_scope, %{"name" => "Groceries"})

    {:ok, split} =
      Budgets.create_split(other_scope, %{
        "name" => "Weekly shop",
        "split_lines" => [%{"budget_id" => budget.id, "amount" => "-40.00"}]
      })

    assert {:reply, %Response{isError: true, content: [%{"text" => "split not found"}]}, ^frame} =
             UpdateSplit.execute(%{split_id: split.id, name: "Mine now"}, frame)

    assert {:reply, %Response{isError: true, content: [%{"text" => "split not found"}]}, ^frame} =
             ArchiveSplit.execute(%{split_id: split.id}, frame)

    assert {:reply, %Response{structured_content: %{splits: []}}, ^frame} = ListSplits.execute(%{}, frame)
  end

  test "reports why a split could not be created", %{budget_id: budget_id, frame: frame} do
    assert {:reply, %Response{isError: true, content: [%{"text" => "name can't be blank"}]}, ^frame} =
             CreateSplit.execute(%{name: "", lines: [%{budget_id: budget_id, amount: "-40.00"}]}, frame)
  end

  test "reports which line of a split is wrong", %{frame: frame} do
    error = "split_lines budget_id does not exist"

    assert {:reply, %Response{isError: true, content: [%{"text" => ^error}]}, ^frame} =
             CreateSplit.execute(
               %{name: "Weekly shop", lines: [%{budget_id: "bgt_nosuchbudget", amount: "-40.00"}]},
               frame
             )
  end
end
