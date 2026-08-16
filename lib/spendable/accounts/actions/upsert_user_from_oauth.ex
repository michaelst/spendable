defmodule Spendable.Accounts.Actions.UpsertUserFromOauth do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Accounts.Schemas.UserIdentity
  alias Spendable.Repo

  @doc """
  Signs in the account behind a provider's subject, creating one on first sign-in.

  The email is what ties two providers to one account, so signing in with Apple on a phone lands
  on the account Google already made for the same address. Only what the provider owns is
  refreshed, and only when it sends it - bank_limit is ours to set, and a provider that omits an
  email must not erase the one we have.
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
      nil -> link_identity(attrs)
    end
  end

  defp link_identity(%{provider: provider, external_id: external_id} = attrs) do
    {:ok, user} =
      Repo.transaction(fn ->
        user = find_or_create_user(attrs)

        Repo.insert!(%UserIdentity{
          user_id: user.id,
          provider: provider,
          external_id: external_id
        })

        user
      end)

    {:ok, user}
  end

  defp find_or_create_user(attrs) do
    case find_by_email(attrs[:email]) do
      %User{} = user -> refresh(user, attrs)
      nil -> %User{} |> User.changeset(attrs) |> Repo.insert!()
    end
  end

  defp find_by_email(email) when is_binary(email), do: Repo.get_by(User, email: email)
  defp find_by_email(_email), do: nil

  defp refresh(user, attrs) do
    user
    |> User.changeset(Map.reject(attrs, fn {_key, value} -> is_nil(value) end))
    |> Repo.update!()
  end
end
