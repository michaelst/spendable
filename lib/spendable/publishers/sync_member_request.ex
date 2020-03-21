defmodule Spendable.Publishers.SyncMemberRequest do
  @topic if Application.get_env(:spendable, :env) == :prod,
           do: "spendable.sync-member-request",
           else: "spendable-dev.sync-member-request"

  def publish(member_id) when is_integer(member_id) do
    %SyncMemberRequest{member_id: member_id}
    |> SyncMemberRequest.encode()
    |> Weddell.publish(@topic)
  end
end
