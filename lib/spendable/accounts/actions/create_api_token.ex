defmodule Spendable.Accounts.Actions.CreateApiToken do
  @moduledoc false

  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  The raw token comes back on the virtual `token` field and is the only time it exists in full.
  Only its hash is stored, so a leaked database gives up no working credentials.
  """
  def create_api_token(%Scope{user: %{id: user_id}}, attrs) do
    token = ApiToken.build_token()

    %ApiToken{
      user_id: user_id,
      token_hash: ApiToken.hash(token),
      last_used_at: DateTime.utc_now(),
      expires_at: ApiToken.expires_at()
    }
    |> ApiToken.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, api_token} -> {:ok, %{api_token | token: token}}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
