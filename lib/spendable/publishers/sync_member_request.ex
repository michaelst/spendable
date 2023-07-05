defmodule Spendable.Publishers.SyncMemberRequest do
  alias Google.PubSub

  require Application

  @topic if Application.compile_env(:spendable, :env) == :prod,
           do: "spendable.sync-member-request",
           else: "spendable-dev.sync-member-request"

  defp pubsub(), do: Application.get_env(:mox, :pubsub, PubSub)

  def publish(member_id) when is_binary(member_id) do
    %Banks.V1.SyncMemberRequest{member_id: member_id}
    |> Banks.V1.SyncMemberRequest.encode()
    |> pubsub().publish(@topic)
  end
end
