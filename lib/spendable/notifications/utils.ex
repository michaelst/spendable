defmodule Spendable.Notifications.Utils do
  alias Pigeon.APNS
  alias Pigeon.APNS.Notification

  def send(%{device_tokens: %Ecto.Association.NotLoaded{}}, _, _), do: raise("Device tokens must be preloaded")

  def send(user, title, body) do
    Enum.each(user.device_tokens, fn %{device_token: device_token} ->
      %Pigeon.APNS.Notification{response: :success} =
        %{
          "title" => title,
          "body" => body
        }
        |> Notification.new(device_token, "fiftysevenmedia.Spendable")
        |> APNS.push()
    end)
  end
end
