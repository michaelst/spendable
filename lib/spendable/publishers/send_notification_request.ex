defmodule Spendable.Publishers.SendNotificationRequest do
  def publish(user_id, title, body) when is_integer(user_id) and is_binary(title) and is_binary(body) do
    %SendNotificationRequest{user_id: user_id, title: title, body: body}
    |> SendNotificationRequest.encode()
    |> Weddell.publish("spendable.send-notification-request")
  end
end
