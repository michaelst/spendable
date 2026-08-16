defmodule SpendableWeb.Live.OAuthAuthorizeTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts
  alias Spendable.OAuth

  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        image: "https://example.test/avatar.png"
      })

    {:ok, client, nil} =
      OAuth.register_client(%{
        "client_name" => "Claude",
        "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
      })

    request = %{
      "client_id" => client.id,
      "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
      "response_type" => "code",
      "code_challenge" => "abc123",
      "code_challenge_method" => "S256",
      "resource" => @resource,
      "state" => "opaque"
    }

    %{conn: init_test_session(conn, %{"current_user_id" => user.id}), request: request}
  end

  test "connecting sends the client back a code", %{conn: conn, request: request} do
    {:ok, view, html} = live(conn, ~p"/oauth/authorize?#{request}")

    assert html =~ "Connect Claude"
    assert html =~ "claude.ai"

    assert {:error, {:redirect, %{to: redirect_uri}}} =
             view |> element("#approve") |> render_click()

    assert redirect_uri =~ "https://claude.ai/api/mcp/auth_callback?code=sp.ac."
    assert redirect_uri =~ "&state=opaque"
  end

  test "denying sends the client back a refusal", %{conn: conn, request: request} do
    {:ok, view, _html} = live(conn, ~p"/oauth/authorize?#{request}")

    denied = "https://claude.ai/api/mcp/auth_callback?error=access_denied&state=opaque"

    assert {:error, {:redirect, %{to: ^denied}}} = view |> element("#deny") |> render_click()
  end

  test "will not send a code anywhere the client did not register", %{conn: conn, request: request} do
    {:ok, _view, html} =
      live(conn, ~p"/oauth/authorize?#{%{request | "redirect_uri" => "https://evil.test/callback"}}")

    assert html =~ "This app could not be verified"
    assert html =~ "not one the app registered"
  end

  test "reports an app it has never heard of", %{conn: conn, request: request} do
    {:ok, _view, html} =
      live(conn, ~p"/oauth/authorize?#{%{request | "client_id" => "oc_nosuchclient"}}")

    assert html =~ "not registered with Spendable"
  end

  test "reports a request that names neither an app nor where to return", %{conn: conn, request: request} do
    {:ok, _view, html} = live(conn, ~p"/oauth/authorize")
    assert html =~ "did not say which app"

    {:ok, _view, html} = live(conn, ~p"/oauth/authorize?#{Map.delete(request, "redirect_uri")}")
    assert html =~ "did not say where to send you"
  end

  test "names the port a local client will be sent back on", %{conn: conn} do
    {:ok, client, nil} =
      OAuth.register_client(%{
        "client_name" => "Editor",
        "redirect_uris" => ["http://localhost:8123/callback"]
      })

    {:ok, _view, html} =
      live(
        conn,
        ~p"/oauth/authorize?#{%{"client_id" => client.id, "redirect_uri" => "http://localhost:8123/callback", "response_type" => "code", "code_challenge" => "abc123", "code_challenge_method" => "S256", "resource" => @resource}}"
      )

    assert html =~ "localhost:8123"
  end

  test "sends a request the client can be told about straight back to it", %{conn: conn, request: request} do
    refused = "https://claude.ai/api/mcp/auth_callback?error=unsupported_response_type&state=opaque"

    assert {:error, {:redirect, %{to: ^refused}}} =
             live(conn, ~p"/oauth/authorize?#{%{request | "response_type" => "token"}}")
  end

  test "signs a visitor in first, then finishes what they came for", %{request: request} do
    conn = get(build_conn(), ~p"/oauth/authorize?#{request}")

    assert redirected_to(conn) == "/"
    assert get_session(conn, "return_to") =~ "/oauth/authorize?"
  end
end
