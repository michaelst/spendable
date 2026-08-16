defmodule Spendable.Accounts.Actions.RevokeApiToken do
  @moduledoc false

  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Signing out deletes the token rather than expiring it: a stolen phone must lose access now.
  """
  def revoke_api_token(
        %Scope{user: %{id: user_id}},
        %ApiToken{user_id: user_id} = api_token
      ) do
    Repo.delete(api_token)
  end

  def revoke_api_token(_scope, _api_token), do: {:error, :not_authorized}
end
