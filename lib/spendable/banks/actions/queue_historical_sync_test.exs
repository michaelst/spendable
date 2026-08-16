defmodule Spendable.Banks.Actions.QueueHistoricalSyncTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    %{scope: Scope.for_user(user), bank_member: bank_member}
  end

  test "queues a sync reaching two years back", %{scope: scope, bank_member: bank_member} do
    {:ok, _job} = Banks.queue_historical_sync(scope, bank_member)

    start_date = Date.shift(Date.utc_today(), month: -24)

    assert_enqueued(
      worker: Spendable.Banks.Jobs.SyncMember,
      args: %{bank_member_id: bank_member.id, start_date: Date.to_iso8601(start_date)}
    )
  end

  # Wallet is read on the device, so the server has nothing to pull and the app backfills instead.
  test "refuses a connection the server cannot pull", %{scope: scope} do
    {:ok, member} = Banks.upsert_finance_kit_member(scope)

    assert {:error, :not_supported} = Banks.queue_historical_sync(scope, member)
  end

  test "refuses another user's connection", %{bank_member: bank_member} do
    {:ok, other} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Banks.queue_historical_sync(Scope.for_user(other), bank_member)
  end
end
