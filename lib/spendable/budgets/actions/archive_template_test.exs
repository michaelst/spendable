defmodule Spendable.Budgets.Actions.ArchiveTemplateTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, template} = Budgets.create_template(scope, %{"name" => "Paycheck"})

    %{scope: scope, template: template}
  end

  test "archives a template", %{scope: scope, template: template} do
    assert {:ok, %BudgetAllocationTemplate{archived_at: %DateTime{}}} =
             Budgets.archive_template(scope, template)
  end

  test "errors when the template is already archived", %{scope: scope, template: template} do
    {:ok, template} = Budgets.archive_template(scope, template)

    assert {:error, :already_archived} = Budgets.archive_template(scope, template)
  end

  test "errors when the template belongs to a different user", %{template: template} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Budgets.archive_template(Scope.for_user(other_user), template)
  end
end
