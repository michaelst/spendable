defmodule Spendable.Broadway.SendNotification do
  use Broadway
  import Ecto.Query, only: [from: 2]

  alias Broadway.Message
  alias Spendable.Repo

  @producer unless Application.get_env(:spendable, :env) == :prod,
              do: {Broadway.DummyProducer, []},
              else:
                {BroadwayCloudPubSub.Producer,
                 subscription: "projects/cloud-57/subscriptions/spendable.send-notification-request"}

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: @producer
      ],
      processors: [
        default: []
      ],
      batchers: [
        default: [
          batch_size: 10,
          batch_timeout: 2_000
        ]
      ]
    )
  end

  def handle_message(_processor_name, message, _context) do
    Message.update_data(message, &process_data/1)
  end

  def handle_batch(_batch_name, messages, _batch_info, _context) do
    messages
  end

  defp process_data(data) do
    %SendNotificationRequest{user_id: user_id, title: title, body: body} = SendNotificationRequest.decode(data)

    from(Spendable.Notifications.Settings, where: [user_id: ^user_id, enabled: true])
    |> Repo.all()
    |> Enum.each(fn settings ->
      %{"title" => title, "body" => body}
      |> Notifications.Provider.new!(settings)
      |> Notifications.Provider.push!()
      |> case do
        :ok -> :ok
        :invalid_token -> Repo.delete!(settings)
      end
    end)
  end
end
