defmodule Spendable.Budgets.Actions.ArchiveSplitTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Split
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, split} = Budgets.create_split(scope, %{"name" => "Paycheck"})

    %{scope: scope, split: split}
  end

  test "archives a split", %{scope: scope, split: split} do
    assert {:ok, %Split{archived_at: %DateTime{}}} =
             Budgets.archive_split(scope, split)
  end

  test "errors when the split is already archived", %{scope: scope, split: split} do
    {:ok, split} = Budgets.archive_split(scope, split)

    assert {:error, :already_archived} = Budgets.archive_split(scope, split)
  end

  test "errors when the split belongs to a different user", %{split: split} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Budgets.archive_split(Scope.for_user(other_user), split)
  end
end
