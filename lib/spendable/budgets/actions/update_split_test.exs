defmodule Spendable.Budgets.Actions.UpdateSplitTest do
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

    %{scope: scope, budget: budget, split: split}
  end

  test "renames a split", %{scope: scope, split: split} do
    assert {:ok, %Split{name: "Salary"}} =
             Budgets.update_split(scope, split, %{"name" => "Salary"})
  end

  test "changes a line's amount", %{scope: scope, budget: budget, split: split} do
    [line] = split.split_lines

    assert {:ok, updated} =
             Budgets.update_split(scope, split, %{
               "split_lines" => %{
                 "0" => %{"id" => line.id, "amount" => "25.00", "budget_id" => budget.id}
               }
             })

    assert [%{amount: amount}] = updated.split_lines
    assert Decimal.eq?(amount, "25.00")
  end

  test "adds a line", %{scope: scope, budget: budget, split: split} do
    [line] = split.split_lines

    assert {:ok, updated} =
             Budgets.update_split(scope, split, %{
               "split_lines" => %{
                 "0" => %{"id" => line.id, "amount" => "10.00", "budget_id" => budget.id},
                 "1" => %{"amount" => "5.00", "budget_id" => budget.id}
               }
             })

    assert [_first, _second] = updated.split_lines
  end

  # The form removes a row by posting its index in drop_param rather than omitting it.
  test "drops a line", %{scope: scope, budget: budget, split: split} do
    [line] = split.split_lines

    assert {:ok, updated} =
             Budgets.update_split(scope, split, %{
               "split_lines" => %{
                 "0" => %{"id" => line.id, "amount" => "10.00", "budget_id" => budget.id}
               },
               "lines_drop" => ["0"]
             })

    assert [] = updated.split_lines
  end

  test "errors when the split belongs to a different user", %{split: split} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Budgets.update_split(Scope.for_user(other_user), split, %{"name" => "Salary"})
  end

  test "errors when the name is blank", %{scope: scope, split: split} do
    assert {:error, changeset} = Budgets.update_split(scope, split, %{"name" => ""})

    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end
end
