defmodule Spendable.Accounts.Actions.AuthenticateApiToken do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Repo

  @doc """
  Takes no scope because it is what produces one: the caller has a token and nothing else.

  Returns the token with its user preloaded so the caller can build a scope without a second query.
  """
  def authenticate_api_token(token) when is_binary(token) do
    now = DateTime.utc_now()
    token_hash = ApiToken.hash(token)

    query =
      from api_token in ApiToken,
        where: api_token.token_hash == ^token_hash,
        where: api_token.expires_at > ^now,
        preload: [:user]

    case Repo.one(query) do
      %ApiToken{} = api_token -> {:ok, touch(api_token)}
      nil -> {:error, :invalid_token}
    end
  end

  def authenticate_api_token(_token), do: {:error, :invalid_token}

  defp touch(%ApiToken{} = api_token) do
    if ApiToken.stale?(api_token) do
      {:ok, touched} =
        api_token
        |> Ecto.Changeset.change(%{
          last_used_at: DateTime.utc_now(),
          expires_at: ApiToken.expires_at()
        })
        |> Repo.update()

      touched
    else
      api_token
    end
  end
end
