defmodule Spendable.Banks.Member.Resolver do
  alias Spendable.Banks.Member
  alias Spendable.Repo
  alias Spendable.Banks.Providers.Plaid.Adapter

  def list(_parent, _args, _resolution) do
    {:ok, Member |> Repo.all()}
  end

  def create(%{public_token: token}, %{context: %{current_user: user}}) do
    {:ok, %{body: %{"access_token" => token}}} = Plaid.exchange_public_token(token)
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
