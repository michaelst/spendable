defmodule SpendableWeb.WellKnownControllerTest do
  use SpendableWeb.ConnCase, async: true

  @issuer Application.compile_env(:spendable, :issuer)

  test "tells a client where to register, authorize and get tokens", %{conn: conn} do
    assert %{
             "issuer" => @issuer,
             "authorization_endpoint" => "#{@issuer}/oauth/authorize",
             "token_endpoint" => "#{@issuer}/oauth/token",
             "registration_endpoint" => "#{@issuer}/oauth/register",
             "code_challenge_methods_supported" => ["S256"],
             "grant_types_supported" => ["authorization_code", "refresh_token"],
             "client_id_metadata_document_supported" => true
           } = json_response(get(conn, ~p"/.well-known/oauth-authorization-server"), 200)
  end

  test "describes the MCP resource at both paths a client may look for it", %{conn: conn} do
    for path <- [~p"/.well-known/oauth-protected-resource", ~p"/.well-known/oauth-protected-resource/mcp"] do
      assert %{
               "resource" => "#{@issuer}/mcp",
               "authorization_servers" => [@issuer],
               "scopes_supported" => ["mcp"],
               "bearer_methods_supported" => ["header"]
             } = json_response(get(conn, path), 200)
    end
  end
end
