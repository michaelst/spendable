defmodule SpendableWeb.WellKnownController do
  use SpendableWeb, :controller

  def oauth_authorization_server(conn, _params) do
    issuer = issuer()

    json(conn, %{
      issuer: issuer,
      authorization_endpoint: "#{issuer}/oauth/authorize",
      token_endpoint: "#{issuer}/oauth/token",
      registration_endpoint: "#{issuer}/oauth/register",
      scopes_supported: ["mcp"],
      response_types_supported: ["code"],
      grant_types_supported: ["authorization_code", "refresh_token"],
      code_challenge_methods_supported: ["S256"],
      token_endpoint_auth_methods_supported: ["none", "client_secret_basic", "client_secret_post"],
      client_id_metadata_document_supported: true
    })
  end

  def oauth_protected_resource(conn, _params) do
    issuer = issuer()

    json(conn, %{
      resource: "#{issuer}/mcp",
      authorization_servers: [issuer],
      scopes_supported: ["mcp"],
      bearer_methods_supported: ["header"]
    })
  end

  defp issuer, do: :spendable |> Application.get_env(:issuer) |> String.trim_trailing("/")
end
