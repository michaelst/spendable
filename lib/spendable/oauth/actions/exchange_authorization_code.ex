defmodule Spendable.OAuth.Actions.ExchangeAuthorizationCode do
  @moduledoc false

  import Ecto.Query
  import Spendable.OAuth.Utils.AuthenticateClient
  import Spendable.OAuth.Utils.DecodeToken
  import Spendable.OAuth.Utils.IssueTokens
  import Spendable.OAuth.Utils.VerifyPkceChallenge

  alias Spendable.OAuth.Schemas.AuthorizationCode
  alias Spendable.Repo

  @doc """
  Redeems an authorization code for tokens, once. Every check the code carries has to line up -
  the client, its redirect URI, and the PKCE verifier - or nothing is issued.
  """
  def exchange_authorization_code(params) do
    code = params["code"] || ""
    client_id = params["client_id"]
    code_verifier = params["code_verifier"] || ""

    result =
      Repo.transaction(fn ->
        with {:ok, selector, verifier} <- decode_token(code, :authorization_code),
             %AuthorizationCode{} = authorization_code <- fetch(selector),
             true <- Plug.Crypto.secure_compare(authorization_code.verify_hash, :crypto.hash(:sha256, verifier)),
             true <- authorization_code.client_id == client_id,
             :ok <- authenticate_client(client_id, params["client_secret"]),
             true <- authorization_code.redirect_uri == params["redirect_uri"],
             true <- verify_pkce_challenge(code_verifier, authorization_code.code_challenge),
             :ok <- claim(authorization_code),
             {:ok, tokens} <-
               issue_tokens(%{
                 user_id: authorization_code.user_id,
                 client_id: authorization_code.client_id,
                 scope: authorization_code.scope,
                 resource: authorization_code.resource
               }) do
          tokens
        else
          {:error, :invalid_client} -> Repo.rollback(:invalid_client)
          _error -> Repo.rollback(:invalid_grant)
        end
      end)

    case result do
      {:ok, tokens} -> {:ok, tokens}
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch(selector) do
    Repo.one(
      from code in AuthorizationCode,
        where: code.selector == ^selector,
        where: is_nil(code.used_at),
        where: code.expires_at > ^DateTime.utc_now()
    )
  end

  # Claim the code atomically: only the request that flips used_at from nil wins, so two clients
  # racing to redeem the same code can never both succeed.
  defp claim(authorization_code) do
    now = DateTime.utc_now()
    query = from code in AuthorizationCode, where: code.id == ^authorization_code.id and is_nil(code.used_at)

    case Repo.update_all(query, set: [used_at: now, updated_at: now]) do
      {1, _records} ->
        :ok

      # coveralls-ignore-start only reachable when a concurrent request claims the same code between
      # fetch/1 and this update; a test runs against one serialized sandbox connection, so that
      # interleaving cannot be produced from the suite.
      _none ->
        :error
        # coveralls-ignore-stop
    end
  end
end
