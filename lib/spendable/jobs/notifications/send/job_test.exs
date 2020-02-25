defmodule Spendable.Jobs.Notifictions.SendTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory
  import Mock
  import Ecto.Query, only: [from: 2]

  alias Spendable.Jobs.Notifications.Send
  alias Spendable.Notifications.Settings
  alias Spendable.Repo

  test "send notification" do
    {user, _} = Spendable.TestUtils.create_user()
    bad_settings = insert(:notification_settings, user: user, device_token: "bad-device-token-1", enabled: false)
    insert(:notification_settings, user: user, device_token: "test-device-token-1", enabled: true)

    with_mock Pigeon.APNS, [:passthrough],
      push: fn
        %{device_token: "bad-device-token-1"} = notification -> %{notification | response: :bad_device_token}
        notification -> %{notification | response: :success}
      end do
      assert :ok == Send.perform(user.id, "test")

      assert 2 = from(Spendable.Notifications.Settings, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

      bad_settings
      |> Settings.changeset(%{enabled: true})
      |> Repo.update!()

      assert :ok == Send.perform(user.id, "test")

      assert 1 = from(Spendable.Notifications.Settings, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)
    end
  end
end
