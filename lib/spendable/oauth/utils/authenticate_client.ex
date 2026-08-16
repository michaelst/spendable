defmodule Spendable.OAuth.Utils.AuthenticateClient do
  @moduledoc false

  import Spendable.OAuth.Utils.DecodeToken

  alias Spendable.OAuth.Schemas.Client
  alias Spendable.Repo

  @confidential_methods [:client_secret_basic, :client_secret_post]

  @doc """
  Proves the caller at the token endpoint is the client it claims to be. A public client proves it
  with PKCE instead, so there is nothing to check here.
  """
  def authenticate_client(client_id, provided_secret) do
    case Repo.get(Client, client_id) do
      %Client{token_endpoint_auth_method: method} = client when method in @confidential_methods ->
        verify_secret(client, provided_secret)

      # There is deliberately no nil clause: both callers match the client id against a stored code
      # or refresh token first, and both of those hold a NOT NULL foreign key to oauth_clients, so
      # a missing row is a broken invariant worth crashing on rather than a silent branch.
      %Client{} ->
        :ok
    end
  end

  defp verify_secret(%Client{secret_selector: selector, secret_verify_hash: hash}, secret)
       when is_binary(selector) and is_binary(hash) and is_binary(secret) do
    with {:ok, provided_selector, verifier} <- decode_token(secret, :client_secret),
         true <- Plug.Crypto.secure_compare(provided_selector, selector),
         true <- Plug.Crypto.secure_compare(hash, :crypto.hash(:sha256, verifier)) do
      :ok
    else
      _error -> {:error, :invalid_client}
    end
  end

  defp verify_secret(_client, _secret), do: {:error, :invalid_client}
end
