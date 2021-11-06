defmodule Notifications.Provider do
  @callback new(%{optional(any) => any}, Spendable.Notifications.Settings) ::
              Pigeon.APNS.Notification | Pigeon.FCM.Notification
  @callback push(Pigeon.APNS.Notification | Pigeon.FCM.Notification) :: :ok | :invalid_token

  alias Notifications.Providers.APNS

  def new!(message, %{provider: :apns} = settings), do: APNS.new(message, settings)

  def push!(%Pigeon.APNS.Notification{} = notification), do: APNS.push(notification)
end
