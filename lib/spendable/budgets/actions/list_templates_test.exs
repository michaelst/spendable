defmodule Spendable.Budgets.Actions.ListTemplatesTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "sorts templates by name", %{scope: scope} do
    {:ok, _salary} = Budgets.create_template(scope, %{"name" => "Salary"})
    {:ok, _bonus} = Budgets.create_template(scope, %{"name" => "Bonus"})

    assert [%{name: "Bonus"}, %{name: "Salary"}] = Budgets.list_templates(scope)
  end

  # Budget's list filtered archived rows but the template list did not, so archived templates leaked.
  test "excludes archived templates", %{scope: scope} do
    {:ok, template} = Budgets.create_template(scope, %{"name" => "Salary"})
    {:ok, _archived} = Budgets.archive_template(scope, template)

    assert [] = Budgets.list_templates(scope)
  end

  test "excludes other users' templates", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _theirs} = Budgets.create_template(Scope.for_user(other_user), %{"name" => "Theirs"})
    {:ok, _mine} = Budgets.create_template(scope, %{"name" => "Mine"})

    assert [%{name: "Mine"}] = Budgets.list_templates(scope)
  end

  test "filters by a search term", %{scope: scope} do
    {:ok, _salary} = Budgets.create_template(scope, %{"name" => "Salary"})
    {:ok, _bonus} = Budgets.create_template(scope, %{"name" => "Bonus"})

    assert [%{name: "Salary"}] = Budgets.list_templates(scope, search: "sal")
  end

  test "ignores a blank search term", %{scope: scope} do
    {:ok, _salary} = Budgets.create_template(scope, %{"name" => "Salary"})

    assert [%{name: "Salary"}] = Budgets.list_templates(scope, search: "")
  end
end
