defmodule Spendable.OAuth.Actions.ValidateAuthorizationRequest do
  @moduledoc false

  import Spendable.OAuth.Utils.RedirectUri

  alias Spendable.OAuth

  @doc """
  Checks an authorization request before a consent screen is shown for it.

  A request whose client or redirect URI cannot be trusted returns an error to render, since
  sending the caller onward would hand the code to whoever asked. Everything else is reported to
  the client the way the spec requires: as an `error` on its own redirect URI.
  """
  def validate_authorization_request(params) do
    state = params["state"]
    resource = "#{Application.get_env(:spendable, :issuer)}/mcp"

    with {:ok, client} <- fetch_client(params["client_id"]),
         {:ok, redirect_uri} <- valid_redirect_uri(client, params["redirect_uri"]),
         :ok <- check(params["response_type"] == "code", redirect_uri, state, "unsupported_response_type"),
         :ok <- check(params["code_challenge_method"] == "S256", redirect_uri, state, "invalid_request"),
         :ok <- check(is_binary(params["code_challenge"]), redirect_uri, state, "invalid_request"),
         :ok <- check((params["scope"] || "mcp") == "mcp", redirect_uri, state, "invalid_scope"),
         :ok <- check(params["resource"] == resource, redirect_uri, state, "invalid_target") do
      {:ok,
       %{
         client: client,
         redirect_uri: redirect_uri,
         scope: "mcp",
         code_challenge: params["code_challenge"],
         code_challenge_method: :S256,
         resource: resource,
         state: state
       }}
    end
  end

  defp fetch_client(nil), do: {:error, :missing_client_id}

  defp fetch_client(client_id) do
    case OAuth.get_client(client_id) do
      {:ok, client} -> {:ok, client}
      {:error, :client_not_found} -> {:error, :unknown_client}
    end
  end

  defp valid_redirect_uri(_client, nil), do: {:error, :missing_redirect_uri}

  defp valid_redirect_uri(client, redirect_uri) do
    if registered?(client.redirect_uris, redirect_uri) do
      {:ok, redirect_uri}
    else
      {:error, :invalid_redirect_uri}
    end
  end

  defp check(true, _redirect_uri, _state, _error), do: :ok

  defp check(false, redirect_uri, state, error) do
    {:redirect, redirect_with(redirect_uri, %{error: error, state: state})}
  end
end
