defmodule Notifications.Providers.APNS do
  @behaviour Notifications.Provider

  alias Pigeon.APNS
  alias Pigeon.APNS.Notification

  @impl Notifications.Provider
  def new(message, settings) do
    Notification.new(message, settings.device_token, "fiftysevenmedia.Spendable")
  end

  @impl Notifications.Provider
  def push(notification) do
    case APNS.push(notification) do
      %Notification{response: :success} -> :ok
      %Notification{response: :bad_device_token} -> :invalid_token
    end
  end
end
