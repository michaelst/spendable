defmodule Spendable.Publishers.SyncMemberRequest do
  def publish(member_id) when is_integer(member_id) do
    %SyncMemberRequest{member_id: member_id}
    |> SyncMemberRequest.encode()
    |> Weddell.publish("spendable.sync-member-request")
  end
end
