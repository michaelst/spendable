defmodule Budget.Banks.Member.Resolver do
  def create(%{public_token: token}, %{context: %{current_user: user}}) do
    {:ok, %{body: params}} = Plaid.exchange_public_token(token)

    struct(Member)
    |> Member.changeset(Adapter.format(params["access_token"], user, :member))
    |> Repo.insert()
    |> case do
      {:ok, member} ->
        {:ok, _} = Exq.enqueue(Exq, "default", Budget.Jobs.Banks.SyncMember, [user.id, member.external_id])

        {:ok, member}

      result ->
        result
    end
  end
end
