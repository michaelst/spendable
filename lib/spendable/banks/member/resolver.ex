defmodule Spendable.Banks.Member.Resolver do
  require Logger
  import Ecto.Query, only: [from: 2]

  alias Spendable.Banks.Member
  alias Spendable.Banks.Providers.Plaid.Adapter
  alias Spendable.Jobs.Banks.SyncMember
  alias Spendable.Repo

  def list(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, from(Member, where: [user_id: ^user.id]) |> Repo.all()}
  end

  def create(%{public_token: token}, %{context: %{current_user: user}}) do
    count = from(Member, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

    if count < user.bank_limit do
      {:ok, %{body: %{"access_token" => token}}} = Plaid.exchange_public_token(token)
      Logger.info("New plaid member token: #{token}")
      {:ok, %{body: details}} = Plaid.member(token)

      %Member{plaid_token: token}
      |> Member.changeset(Adapter.format(details, user.id, :member))
      |> Repo.insert()
      |> case do
        {:ok, member} ->
          {:ok, _} = Exq.enqueue(Exq, "default", SyncMember, [member.id])

          {:ok, member}

        result ->
          result
      end
    else
      {:error, "Bank limit reached"}
    end
  end
end
