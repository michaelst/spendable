defmodule Spendable.Notifications.Utils do
  alias Pigeon.APNS
  alias Pigeon.APNS.Notification

  def send(user, title, body) do
    Enum.each(user.device_tokens, fn device_token ->
      %Pigeon.APNS.Notification{response: :success} =
        %{
          "title" => title,
          "body" => body
        }
        |> Notification.new(device_token)
        |> APNS.push()
    end)
  end
end
