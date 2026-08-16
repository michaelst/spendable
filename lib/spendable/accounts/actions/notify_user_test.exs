defmodule Spendable.Accounts.Actions.NotifyUserTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Jobs.SendNotification
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "queues one notification for the user", %{scope: scope} do
    {:ok, _job} =
      Accounts.notify_user(scope, %{count: 3, total: Decimal.new("-84.21"), alert: true})

    assert_enqueued(
      worker: SendNotification,
      args: %{user_id: scope.user.id, count: 3, total: "-84.21", alert: true}
    )
  end

  test "queues a silent one", %{scope: scope} do
    {:ok, _job} = Accounts.notify_user(scope, %{count: 0, total: Decimal.new(0), alert: false})

    assert_enqueued(worker: SendNotification, args: %{user_id: scope.user.id, alert: false})
  end
end
