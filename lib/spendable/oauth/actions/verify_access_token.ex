defmodule Spendable.OAuth.Actions.VerifyAccessToken do
  @moduledoc false

  import Ecto.Query
  import Spendable.OAuth.Utils.DecodeToken

  alias Spendable.OAuth.Schemas.AccessToken
  alias Spendable.Repo

  @doc """
  Resolves a bearer token to the user it acts as. The resource is matched too, so a token minted
  for one audience cannot be replayed against another.
  """
  def verify_access_token(token, resource) do
    with {:ok, selector, verifier} <- decode_token(token, :access),
         %AccessToken{} = access_token <- fetch(selector, resource),
         true <- Plug.Crypto.secure_compare(access_token.verify_hash, :crypto.hash(:sha256, verifier)) do
      {:ok, access_token.user}
    else
      _error -> {:error, :invalid_token}
    end
  end

  defp fetch(selector, resource) do
    Repo.one(
      from token in AccessToken,
        where: token.selector == ^selector,
        where: token.resource == ^resource,
        where: is_nil(token.revoked_at),
        where: token.expires_at > ^DateTime.utc_now(),
        preload: [:user]
    )
  end
end
