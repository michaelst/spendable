defmodule Notifications.Providers.APNS do
  alias Pigeon.APNS
  alias Pigeon.APNS.Notification

  defp apns(), do: Application.get_env(:mox, :apns, APNS)

  def new(message, settings) do
    Notification.new(message, settings.device_token, "fiftysevenmedia.Spendable")
  end

  def push(notification) do
    case apns().push(notification) do
      %Notification{response: :success} -> :ok
      %Notification{response: :bad_device_token} -> :invalid_token
    end
  end
end
