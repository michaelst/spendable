defmodule Budget.Banks.Member.Resolver do
  alias Budget.Banks.Member
  alias Budget.Repo
  alias Budget.Banks.Providers.Plaid.Adapter

  def create(%{public_token: token}, %{context: %{current_user: user}}) do
    {:ok, %{body: %{"access_token" => token}}} = Plaid.exchange_public_token(token)
    {:ok, %{body: details}} = Plaid.member(token)

    %Member{plaid_token: token}
    |> Member.changeset(Adapter.format(details, user.id, :member))
    |> Repo.insert()
    |> case do
      {:ok, member} ->
        {:ok, _} = Exq.enqueue(Exq, "default", Budget.Jobs.Banks.SyncMember, [member.id])

        {:ok, member}

      result ->
        result
    end
  end
end
