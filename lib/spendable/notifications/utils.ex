defmodule Spendable.Notifications.Utils do
  alias Pigeon.APNS
  alias Pigeon.APNS.Notification

  def send(%{device_tokens: %Ecto.Association.NotLoaded{}}, _, _), do: raise("device_tokens must be preloaded")

  def send(user, title, body) do
    user.device_tokens
    |> Enum.filter(& &1.enabled)
    |> Enum.each(fn
      %{device_token: device_token} ->
        %Pigeon.APNS.Notification{response: :success} =
          %{
            "title" => title,
            "body" => body
          }
          |> Notification.new(device_token, "fiftysevenmedia.Spendable")
          |> push(Application.get_env(:spendable, :env))
    end)
  end

  defp push(_notification, :test), do: %Pigeon.APNS.Notification{response: :success}
  defp push(notification, _), do: APNS.push(notification)
end
