defmodule Spendable.Accounts.Actions.LinkIdentity do
  @moduledoc false

  import Ecto.Query
  import Spendable.Accounts.Utils.VerifyProviderToken

  alias Spendable.Accounts.Schemas.UserIdentity
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Attaches another way of signing in to the account already signed in.

  This is how one person reaches one account from two providers. It takes a scope because proving
  the second provider is not enough - the user has to already be inside the account they are
  attaching it to, or anyone holding a valid Apple token could join themselves to it.
  """
  def link_identity(%Scope{user: %{id: user_id}}, provider, id_token) do
    with {:ok, %{external_id: external_id}} <- verify_provider_token(provider, id_token),
         :ok <- unclaimed(provider, external_id, user_id) do
      {:ok, Repo.insert!(%UserIdentity{user_id: user_id, provider: provider, external_id: external_id})}
    end
  end

  defp unclaimed(provider, external_id, user_id) do
    query =
      from(identity in UserIdentity,
        where: identity.provider == ^provider,
        where: identity.external_id == ^external_id
      )

    case Repo.one(query) do
      %UserIdentity{user_id: ^user_id} -> {:error, :identity_already_linked}
      %UserIdentity{} -> {:error, :identity_claimed}
      nil -> :ok
    end
  end
end
