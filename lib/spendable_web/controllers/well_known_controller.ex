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

  @doc """
  Claims `/plaid-oauth` for the iOS app, so the bank's OAuth page returns to Link rather than to
  Safari. Apple fetches this itself over https and caches it, so a change takes a while to reach
  devices that have already seen the old one.
  """
  def apple_app_site_association(conn, _params) do
    json(conn, %{
      applinks: %{
        details: [
          %{
            appIDs: [Application.get_env(:spendable, :ios_app_id)],
            components: [%{"/" => "/plaid-oauth*"}]
          }
        ]
      }
    })
  end

  defp issuer, do: :spendable |> Application.get_env(:issuer) |> String.trim_trailing("/")
end
