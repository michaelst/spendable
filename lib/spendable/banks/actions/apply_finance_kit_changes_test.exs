defmodule Spendable.Banks.Actions.ApplyFinanceKitChangesTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Scope

  # The endpoint looks the connection up under the caller's scope, so this guards the action for
  # any caller that does not.
  test "refuses a connection belonging to another user" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, member} = Banks.upsert_finance_kit_member(Scope.for_user(user))
    changes = %{"history_token_after" => "tok-1", "accounts" => []}

    assert {:error, :not_authorized} =
             Banks.apply_finance_kit_changes(Scope.for_user(other_user), member, changes)
  end
end
