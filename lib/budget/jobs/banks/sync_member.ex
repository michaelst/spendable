defmodule Budget.Jobs.Banks.SyncMember do
  alias Budget.Banks.Member
  alias Budget.Repo
  alias Budget.Banks.Providers.Plaid.Adapter

  def perform(user_id, external_id) do
    member = Repo.get_by!(Member, external_id: token)

    member
    |> Member.changeset(Adapter.format(member.plaid_token, user_id, :member))
    |> Repo.update!()

    {:ok, %{body: %{"accounts" => accounts}}} = Plaid.accounts(token)

    Enum.map(accounts, fn account ->
      account
    end)
  end
end
