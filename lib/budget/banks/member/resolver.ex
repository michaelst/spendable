defmodule Budget.Banks.Member.Resolver do
  def create(params, %{context: %{current_user: user}}) do
    case Budget.Banks.Member.Sync.create(params, user) do
      {:ok, member} ->
        {:ok, _} = Exq.enqueue(Exq, "default", Budget.Jobs.Banks.SyncMember, [user.id, member.external_id])

        {:ok, member}

      result ->
        result
    end
  end
end
