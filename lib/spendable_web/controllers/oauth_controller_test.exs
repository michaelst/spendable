defmodule SpendableWeb.OAuthControllerTest do
  use SpendableWeb.ConnCase, async: true

  alias Spendable.Accounts
  alias Spendable.OAuth
  alias Spendable.Scope

  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"
  @code_verifier "a-secret-only-this-client-knows"

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "registers a client a caller can then authorize as", %{conn: conn} do
    assert %{
             "client_id" => "oc_" <> _rest,
             "client_name" => "Claude",
             "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"],
             "token_endpoint_auth_method" => "none",
             "scope" => "mcp"
           } =
             json_response(
               post(conn, ~p"/oauth/register", %{
                 "client_name" => "Claude",
                 "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
               }),
               201
             )
  end

  test "refuses to register a client whose metadata cannot be honored", %{conn: conn} do
    assert %{"error" => "invalid_client_metadata"} =
             json_response(post(conn, ~p"/oauth/register", %{"client_name" => "Claude"}), 400)
  end

  test "exchanges a code, then the refresh token it came with", %{conn: conn, scope: scope} do
    {:ok, client, nil} =
      OAuth.register_client(%{
        "client_name" => "Claude",
        "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
      })

    {:ok, code, _redirect_uri} =
      OAuth.create_authorization_code(scope, %{
        client: client,
        redirect_uri: "https://claude.ai/api/mcp/auth_callback",
        scope: "mcp",
        code_challenge: Base.url_encode64(:crypto.hash(:sha256, @code_verifier), padding: false),
        code_challenge_method: :S256,
        resource: @resource,
        state: nil
      })

    exchanged =
      post(conn, ~p"/oauth/token", %{
        "grant_type" => "authorization_code",
        "code" => code,
        "client_id" => client.id,
        "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
        "code_verifier" => @code_verifier
      })

    assert %{"access_token" => "sp.at." <> _access, "refresh_token" => refresh_token, "token_type" => "Bearer"} =
             json_response(exchanged, 200)

    assert ["no-store"] = get_resp_header(exchanged, "cache-control")

    assert %{"access_token" => "sp.at." <> _rotated} =
             json_response(
               post(conn, ~p"/oauth/token", %{
                 "grant_type" => "refresh_token",
                 "refresh_token" => refresh_token,
                 "client_id" => client.id
               }),
               200
             )
  end

  test "reads a confidential client's credentials from basic auth", %{conn: conn, scope: scope} do
    {:ok, client, secret} =
      OAuth.register_client(%{
        "client_name" => "Editor",
        "redirect_uris" => ["http://localhost:8123/callback"],
        "token_endpoint_auth_method" => "client_secret_basic"
      })

    {:ok, code, _redirect_uri} =
      OAuth.create_authorization_code(scope, %{
        client: client,
        redirect_uri: "http://localhost:8123/callback",
        scope: "mcp",
        code_challenge: Base.url_encode64(:crypto.hash(:sha256, @code_verifier), padding: false),
        code_challenge_method: :S256,
        resource: @resource,
        state: nil
      })

    params = %{
      "grant_type" => "authorization_code",
      "code" => code,
      "redirect_uri" => "http://localhost:8123/callback",
      "code_verifier" => @code_verifier
    }

    assert %{"error" => "invalid_client"} =
             json_response(
               conn
               |> put_req_header("authorization", Plug.BasicAuth.encode_basic_auth(client.id, "sp.cs.wrong"))
               |> post(~p"/oauth/token", params),
               401
             )

    assert %{"access_token" => "sp.at." <> _access} =
             json_response(
               conn
               |> put_req_header("authorization", Plug.BasicAuth.encode_basic_auth(client.id, secret))
               |> post(~p"/oauth/token", params),
               200
             )
  end

  test "refuses a grant it cannot honor", %{conn: conn} do
    assert %{"error" => "invalid_grant"} =
             json_response(
               post(conn, ~p"/oauth/token", %{"grant_type" => "authorization_code", "code" => "sp.ac.nope"}),
               400
             )

    assert %{"error" => "unsupported_grant_type"} =
             json_response(post(conn, ~p"/oauth/token", %{"grant_type" => "password"}), 400)
  end
end
