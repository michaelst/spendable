defmodule Spendable.Budgets.Actions.CreateTemplateTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    %{scope: scope, budget: budget}
  end

  test "creates a template with its lines", %{scope: scope, budget: budget} do
    assert {:ok, %BudgetAllocationTemplate{id: "bat_" <> _uxid, name: "Paycheck"} = template} =
             Budgets.create_template(scope, %{
               "name" => "Paycheck",
               "budget_allocation_template_lines" => %{
                 "0" => %{"amount" => "10.00", "budget_id" => budget.id}
               }
             })

    assert [%{id: "batl_" <> _line_uxid, amount: amount}] =
             template.budget_allocation_template_lines

    assert Decimal.eq?(amount, "10.00")
  end

  test "gives the lines the template's owner", %{scope: scope, budget: budget} do
    %{id: user_id} = scope.user

    {:ok, template} =
      Budgets.create_template(scope, %{
        "name" => "Paycheck",
        "budget_allocation_template_lines" => %{
          "0" => %{"amount" => "10.00", "budget_id" => budget.id}
        }
      })

    assert [%{user_id: ^user_id}] = template.budget_allocation_template_lines
  end

  # The budget id is posted, so a line must not be able to reach another user's budget.
  test "rejects a line pointing at another user's budget", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, their_budget} =
      Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Theirs"})

    assert {:error, changeset} =
             Budgets.create_template(scope, %{
               "name" => "Paycheck",
               "budget_allocation_template_lines" => %{
                 "0" => %{"amount" => "10.00", "budget_id" => their_budget.id}
               }
             })

    assert %{budget_allocation_template_lines: [%{budget_id: ["does not exist"]}]} =
             errors_on(changeset)
  end

  test "errors without a name", %{scope: scope} do
    assert {:error, changeset} = Budgets.create_template(scope, %{})

    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end

  test "errors when a line has no budget", %{scope: scope} do
    assert {:error, changeset} =
             Budgets.create_template(scope, %{
               "name" => "Paycheck",
               "budget_allocation_template_lines" => %{"0" => %{"amount" => "10.00"}}
             })

    assert %{budget_allocation_template_lines: [%{budget_id: ["can't be blank"]}]} =
             errors_on(changeset)
  end
end
