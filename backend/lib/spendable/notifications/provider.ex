defmodule Notifications.Provider do
  alias Notifications.Providers.APNS

  def new(message, %{provider: :apns} = settings), do: APNS.new(message, settings)

  def push(%Pigeon.APNS.Notification{} = notification), do: APNS.push(notification)
end
