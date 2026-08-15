defmodule Spendable.Budgets.Actions.ListSplitsTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "sorts splits by name", %{scope: scope} do
    {:ok, _salary} = Budgets.create_split(scope, %{"name" => "Salary"})
    {:ok, _bonus} = Budgets.create_split(scope, %{"name" => "Bonus"})

    assert [%{name: "Bonus"}, %{name: "Salary"}] = Budgets.list_splits(scope)
  end

  # Budget's list filtered archived rows but the split list did not, so archived splits leaked.
  test "excludes archived splits", %{scope: scope} do
    {:ok, split} = Budgets.create_split(scope, %{"name" => "Salary"})
    {:ok, _archived} = Budgets.archive_split(scope, split)

    assert [] = Budgets.list_splits(scope)
  end

  test "excludes other users' splits", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _theirs} = Budgets.create_split(Scope.for_user(other_user), %{"name" => "Theirs"})
    {:ok, _mine} = Budgets.create_split(scope, %{"name" => "Mine"})

    assert [%{name: "Mine"}] = Budgets.list_splits(scope)
  end

  test "filters by a search term", %{scope: scope} do
    {:ok, _salary} = Budgets.create_split(scope, %{"name" => "Salary"})
    {:ok, _bonus} = Budgets.create_split(scope, %{"name" => "Bonus"})

    assert [%{name: "Salary"}] = Budgets.list_splits(scope, search: "sal")
  end

  test "ignores a blank search term", %{scope: scope} do
    {:ok, _salary} = Budgets.create_split(scope, %{"name" => "Salary"})

    assert [%{name: "Salary"}] = Budgets.list_splits(scope, search: "")
  end
end
