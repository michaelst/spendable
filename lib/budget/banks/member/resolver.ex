defmodule Budget.Banks.Member.Resolver do
  alias Budget.Banks.Member
  alias Budget.Repo

  def create(params, %{context: %{current_user: user}}) do
    {:ok, %{body: %{"access_token" => access_token, "item_id" => item_id}}} =
      Plaid.exchange_public_token(params.public_token)

    struct(Member)
    |> Member.changeset(%{
      user_id: user.id,
      name: "test",
      plaid_token: access_token,
      external_id: item_id,
      provider: "Plaid"
    })
    |> Repo.insert()
  end
end
