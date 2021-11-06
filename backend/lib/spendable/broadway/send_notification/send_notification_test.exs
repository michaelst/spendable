defmodule Spendable.Broadway.SendNotificationTest do
  use Spendable.DataCase, async: false

  import Mock
  import Ecto.Query, only: [from: 2]

  alias Spendable.Api
  alias Spendable.Broadway.SendNotification
  alias Spendable.NotificationSettings
  alias Spendable.Repo

  test "send notification" do
    user = insert(:user)
    bad_settings = insert(:notification_settings, user_id: user.id, device_token: "bad-device-token-1", enabled: false)
    insert(:notification_settings, user_id: user.id, device_token: "test-device-token-1", enabled: true)

    with_mock Pigeon.APNS, [:passthrough],
      push: fn
        %{device_token: "bad-device-token-1"} = notification -> %{notification | response: :bad_device_token}
        notification -> %{notification | response: :success}
      end do
      data =
        %SendNotificationRequest{user_id: user.id, title: "Test", body: "Some message"}
        |> SendNotificationRequest.encode()

      ref = Broadway.test_message(SendNotification, data)
      assert_receive {:ack, ^ref, [_] = _successful, []}, 1000

      assert 2 = from(NotificationSettings, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

      bad_settings
      |> Ash.Changeset.for_update(:update, %{enabled: true})
      |> Api.update!()

      ref = Broadway.test_message(SendNotification, data)
      assert_receive {:ack, ^ref, [_] = _successful, []}, 1000

      assert 1 = from(NotificationSettings, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)
    end
  end
end
