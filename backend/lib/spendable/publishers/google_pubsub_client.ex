defmodule Google.PubSub do
  def client do
    {:ok, project} = Goth.Config.get(:project_id)
    {:ok, %{type: type, token: token}} = Goth.Token.for_scope("https://www.googleapis.com/auth/pubsub")

    middleware = [
      {Tesla.Middleware.BaseUrl, "https://pubsub.googleapis.com/v1/projects/#{project}/topics"},
      {Tesla.Middleware.Headers, [{"authorization", "#{type} #{token}"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def publish(message, topic) do
    client() |> Tesla.post("#{topic}:publish", %{messages: [%{data: Base.encode64(message)}]})
  end
end
