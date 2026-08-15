defmodule Spendable.Budgets.Actions.UpdateTemplateTest do
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

    {:ok, template} =
      Budgets.create_template(scope, %{
        "name" => "Paycheck",
        "budget_allocation_template_lines" => %{
          "0" => %{"amount" => "10.00", "budget_id" => budget.id}
        }
      })

    %{scope: scope, budget: budget, template: template}
  end

  test "renames a template", %{scope: scope, template: template} do
    assert {:ok, %BudgetAllocationTemplate{name: "Salary"}} =
             Budgets.update_template(scope, template, %{"name" => "Salary"})
  end

  test "changes a line's amount", %{scope: scope, budget: budget, template: template} do
    [line] = template.budget_allocation_template_lines

    assert {:ok, updated} =
             Budgets.update_template(scope, template, %{
               "budget_allocation_template_lines" => %{
                 "0" => %{"id" => line.id, "amount" => "25.00", "budget_id" => budget.id}
               }
             })

    assert [%{amount: amount}] = updated.budget_allocation_template_lines
    assert Decimal.eq?(amount, "25.00")
  end

  test "adds a line", %{scope: scope, budget: budget, template: template} do
    [line] = template.budget_allocation_template_lines

    assert {:ok, updated} =
             Budgets.update_template(scope, template, %{
               "budget_allocation_template_lines" => %{
                 "0" => %{"id" => line.id, "amount" => "10.00", "budget_id" => budget.id},
                 "1" => %{"amount" => "5.00", "budget_id" => budget.id}
               }
             })

    assert [_first, _second] = updated.budget_allocation_template_lines
  end

  # The form removes a row by posting its index in drop_param rather than omitting it.
  test "drops a line", %{scope: scope, budget: budget, template: template} do
    [line] = template.budget_allocation_template_lines

    assert {:ok, updated} =
             Budgets.update_template(scope, template, %{
               "budget_allocation_template_lines" => %{
                 "0" => %{"id" => line.id, "amount" => "10.00", "budget_id" => budget.id}
               },
               "lines_drop" => ["0"]
             })

    assert [] = updated.budget_allocation_template_lines
  end

  test "errors when the template belongs to a different user", %{template: template} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Budgets.update_template(Scope.for_user(other_user), template, %{"name" => "Salary"})
  end

  test "errors when the name is blank", %{scope: scope, template: template} do
    assert {:error, changeset} = Budgets.update_template(scope, template, %{"name" => ""})

    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end
end
