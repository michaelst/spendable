defmodule SpendableWeb.Plugs.VerifyMcpTokenTest do
  use SpendableWeb.ConnCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User
  alias Spendable.OAuth
  alias Spendable.Scope
  alias SpendableWeb.Plugs.VerifyMcpToken

  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"
  @code_verifier "a-secret-only-this-client-knows"

  setup do
    {:ok, %User{id: user_id} = user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, client, nil} =
      OAuth.register_client(%{
        "client_name" => "Claude",
        "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
      })

    {:ok, code, _redirect_uri} =
      OAuth.create_authorization_code(Scope.for_user(user), %{
        client: client,
        redirect_uri: "https://claude.ai/api/mcp/auth_callback",
        scope: "mcp",
        code_challenge: Base.url_encode64(:crypto.hash(:sha256, @code_verifier), padding: false),
        code_challenge_method: :S256,
        resource: @resource,
        state: nil
      })

    {:ok, tokens} =
      OAuth.exchange_authorization_code(%{
        "code" => code,
        "client_id" => client.id,
        "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
        "code_verifier" => @code_verifier
      })

    %{tokens: tokens, user_id: user_id}
  end

  test "init/1 passes options through" do
    assert VerifyMcpToken.init(:opts) == :opts
  end

  test "acts as the user the bearer token was issued to", %{conn: conn, tokens: tokens, user_id: user_id} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{tokens.access_token}")
      |> VerifyMcpToken.call([])

    assert %{assigns: %{current_scope: %Scope{user: %User{id: ^user_id}}}, state: :unset} = conn
  end

  test "answers a call it cannot authenticate with where to authorize", %{conn: conn, tokens: tokens} do
    for unauthenticated <- [
          conn,
          put_req_header(conn, "authorization", "Bearer sp.at.bm90LWEtcmVhbC10b2tlbi4u"),
          put_req_header(conn, "authorization", tokens.access_token)
        ] do
      assert %{status: 401, state: :sent} = conn = VerifyMcpToken.call(unauthenticated, [])

      assert [www_authenticate] = get_resp_header(conn, "www-authenticate")
      assert www_authenticate =~ ~s(Bearer realm="mcp")
      assert www_authenticate =~ "/.well-known/oauth-protected-resource/mcp"
    end
  end
end
