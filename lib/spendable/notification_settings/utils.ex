defmodule Spendable.Notifications.Settings.Utils do
  alias Pigeon.APNS
  alias Pigeon.APNS.Notification
  alias Spendable.Repo

  def send(%{notification_settings: %Ecto.Association.NotLoaded{}}, _, _),
    do: raise("notification_settings must be preloaded")

  def send(user, title, body) do
    user.notification_settings
    |> Enum.filter(& &1.enabled)
    |> Enum.each(fn
      %{device_token: device_token} = notification_settings ->
        %{
          "title" => title,
          "body" => body
        }
        |> Notification.new(device_token, "fiftysevenmedia.Spendable")
        |> push(Application.get_env(:spendable, :env))
        |> case do
          %Pigeon.APNS.Notification{response: :success} -> :ok
          %Pigeon.APNS.Notification{response: :bad_device_token} -> Repo.delete!(notification_settings)
        end
    end)
  end

  defp push(_notification, :test), do: %Pigeon.APNS.Notification{response: :success}
  defp push(notification, _), do: APNS.push(notification)
end
