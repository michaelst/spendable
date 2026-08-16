defmodule Spendable.Accounts.Actions.UpsertUserFromOauth do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Accounts.Schemas.UserIdentity
  alias Spendable.Repo

  @doc """
  Signs in the account behind a provider's subject, creating one on first sign-in.

  An unrecognised subject is always a new account. Nothing is stored that would identify the same
  person at two providers, so the app cannot guess that a Google and an Apple sign-in belong
  together - the user says so, from inside the account, with `link_identity/3`.

  Only what the provider owns is refreshed, and only when it sends it: bank_limit is ours to set,
  and a provider that omits a picture must not erase the one we have.
  """
  def upsert_user_from_oauth(%{provider: provider, external_id: external_id} = attrs) do
    query =
      from(identity in UserIdentity,
        where: identity.provider == ^provider,
        where: identity.external_id == ^external_id,
        preload: [:user]
      )

    case Repo.one(query) do
      %UserIdentity{user: user} -> {:ok, refresh(user, attrs)}
      nil -> create_user_with_identity(attrs)
    end
  end

  defp create_user_with_identity(%{provider: provider, external_id: external_id} = attrs) do
    {:ok, user} =
      Repo.transaction(fn ->
        user = %User{} |> User.changeset(attrs) |> Repo.insert!()

        Repo.insert!(%UserIdentity{
          user_id: user.id,
          provider: provider,
          external_id: external_id
        })

        user
      end)

    {:ok, user}
  end

  defp refresh(user, attrs) do
    user
    |> User.changeset(Map.reject(attrs, fn {_key, value} -> is_nil(value) end))
    |> Repo.update!()
  end
end
