defmodule Spendable.Publishers.SendNotificationRequest do
  alias Google.PubSub

  require Application

  @topic if Application.compile_env(:spendable, :env) == :prod,
           do: "spendable.send-notification-request",
           else: "spendable-dev.send-notification-request"

  def publish(user_id, title, body) when is_integer(user_id) and is_binary(title) and is_binary(body) do
    %SendNotificationRequest{user_id: user_id, title: title, body: body}
    |> SendNotificationRequest.encode()
    |> PubSub.publish(@topic)
  end
end
