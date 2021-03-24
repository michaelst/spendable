defmodule Spendable.Banks.Member.Resolver do
  require Logger
  import Ecto.Query, only: [from: 2]

  alias Spendable.Banks.Member
  alias Spendable.Banks.Providers.Plaid.Adapter
  alias Spendable.Broadway.SyncMember
  alias Spendable.Publishers.SyncMemberRequest
  alias Spendable.Repo

  def list(_args, %{context: %{current_user: user}}) do
    {:ok, from(Member, where: [user_id: ^user.id], order_by: :id) |> Repo.all()}
  end

  def get(_args, %{context: %{model: model}}) do
    {:ok, model}
  end

  def create(%{public_token: token}, %{context: %{current_user: user}}) do
    count = from(Member, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

    if count < user.bank_limit do
      {:ok, %{body: %{"access_token" => token}}} = Plaid.exchange_public_token(token)
      Logger.info("New plaid member token: #{token}")
      {:ok, %{body: details}} = Plaid.item(token)

      %Member{plaid_token: token}
      |> Member.changeset(Adapter.format(details, user.id, :member))
      |> Repo.insert()
      |> case do
        {:ok, member} ->
          SyncMember.sync_accounts(member)
          {:ok, %{status: 200}} = SyncMemberRequest.publish(member.id)
          {:ok, member}

        result ->
          result
      end
    else
      {:error, "Bank limit reached"}
    end
  end
end
