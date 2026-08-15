defmodule Spendable.Budgets.Actions.GetTemplateTest do
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

    %{scope: scope, template: template}
  end

  test "returns the template with its lines and their budgets", %{
    scope: scope,
    template: template
  } do
    assert {:ok, %BudgetAllocationTemplate{name: "Paycheck"} = found} =
             Budgets.get_template(scope, template.id)

    assert [%{budget: %{name: "Groceries"}}] = found.budget_allocation_template_lines
  end

  test "errors when no template matches", %{scope: scope} do
    assert {:error, :template_not_found} =
             Budgets.get_template(scope, "bat_01M036GTQ48JXS0A2AXFNV6H5P")
  end

  test "errors when the template belongs to a different user", %{template: template} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :template_not_found} =
             Budgets.get_template(Scope.for_user(other_user), template.id)
  end
end
