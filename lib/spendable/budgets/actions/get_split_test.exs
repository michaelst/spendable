defmodule Spendable.Budgets.Actions.GetSplitTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Split
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, split} =
      Budgets.create_split(scope, %{
        "name" => "Paycheck",
        "split_lines" => %{
          "0" => %{"amount" => "10.00", "budget_id" => budget.id}
        }
      })

    %{scope: scope, split: split}
  end

  test "returns the split with its lines and their budgets", %{
    scope: scope,
    split: split
  } do
    assert {:ok, %Split{name: "Paycheck"} = found} =
             Budgets.get_split(scope, split.id)

    assert [%{budget: %{name: "Groceries"}}] = found.split_lines
  end

  test "errors when no split matches", %{scope: scope} do
    assert {:error, :split_not_found} =
             Budgets.get_split(scope, "bat_01M036GTQ48JXS0A2AXFNV6H5P")
  end

  test "errors when the split belongs to a different user", %{split: split} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :split_not_found} =
             Budgets.get_split(Scope.for_user(other_user), split.id)
  end
end
