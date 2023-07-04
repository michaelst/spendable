defmodule Google.PubSub do
  @behaviour Spendable.Behaviour.PubSub

  def client() do
    {:ok, project} = Goth.Config.get(:project_id)

    %{type: type, token: token} = Goth.fetch!(Spendable.Goth)

    middleware = [
      {Tesla.Middleware.BaseUrl, "https://pubsub.googleapis.com/v1/projects/#{project}/topics"},
      {Tesla.Middleware.Headers, [{"authorization", "#{type} #{token}"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  @impl Spendable.Behaviour.PubSub
  def publish(message, topic) do
    client() |> Tesla.post("#{topic}:publish", %{messages: [%{data: Base.encode64(message)}]})
  end
end
