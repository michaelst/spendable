defmodule Budget.Banks.Member.Sync do
  alias Budget.Banks.Member
  alias Budget.Repo
  alias Budget.Banks.Providers.Plaid.Adapter

  def create(%{public_token: token}, user) do
    {:ok, %{body: params}} = Plaid.exchange_public_token(token)

    struct(Member)
    |> Member.changeset(Adapter.format(params, user, :member))
    |> Repo.insert()
  end
end
