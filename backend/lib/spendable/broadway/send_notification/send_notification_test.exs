defmodule Spendable.Broadway.SendNotificationTest do
  use Spendable.DataCase, async: true

  import Ecto.Query, only: [from: 2]

  alias Spendable.Api
  alias Spendable.Broadway.SendNotification
  alias Spendable.NotificationSettings
  alias Spendable.Repo

  setup do
    _pid = start_supervised!({SendNotification, name: __MODULE__})

    :ok
  end

  test "send notification" do
    user = Factory.insert(Spendable.User)

    bad_settings =
      Factory.insert(Spendable.NotificationSettings,
        user_id: user.id,
        device_token: "bad-device-token-1",
        enabled: false
      )

    Factory.insert(Spendable.NotificationSettings, user_id: user.id, device_token: "test-device-token-1", enabled: true)

    APNSMock
    |> expect(:push, 3, fn
      %{device_token: "bad-device-token-1"} = notification -> %{notification | response: :bad_device_token}
      notification -> %{notification | response: :success}
    end)

    data =
      %SendNotificationRequest{user_id: user.id, title: "Test", body: "Some message"}
      |> SendNotificationRequest.encode()

    ref = Broadway.test_message(__MODULE__, data, metadata: %{test_process: self()})
    assert_receive {:ack, ^ref, [_] = _successful, []}, 1000

    assert 2 = from(NotificationSettings, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

    bad_settings
    |> Ash.Changeset.for_update(:update, %{enabled: true})
    |> Api.update!()

    ref = Broadway.test_message(__MODULE__, data, metadata: %{test_process: self()})
    assert_receive {:ack, ^ref, [_] = _successful, []}, 1000

    assert 1 = from(NotificationSettings, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)
  end
end
