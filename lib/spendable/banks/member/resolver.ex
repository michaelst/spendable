defmodule Spendable.Banks.Member.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Banks.Member
  alias Spendable.Repo
  alias Spendable.Banks.Providers.Plaid.Adapter

  def list(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, from(Member, where: [user_id: ^user.id]) |> Repo.all()}
  end

  def create(%{public_token: token}, %{context: %{current_user: user}}) do
    {:ok, %{body: %{"access_token" => token}}} = Plaid.exchange_public_token(token)
    # TODO: handle when this next call times out as we need to not lose the token after we exchange it
    {:ok, %{body: details}} = Plaid.member(token)

    %Member{plaid_token: token}
    |> Member.changeset(Adapter.format(details, user.id, :member))
    |> Repo.insert()
    |> case do
      {:ok, member} ->
        {:ok, _} = Exq.enqueue(Exq, "default", Spendable.Jobs.Banks.SyncMember, [member.id])

        {:ok, member}

      result ->
        result
    end
  end
end
