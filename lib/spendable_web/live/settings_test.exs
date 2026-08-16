defmodule SpendableWeb.Live.SettingsTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts
  alias Spendable.OAuth
  alias Spendable.Scope

  @issuer Application.compile_env(:spendable, :issuer)
  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"
  @code_verifier "a-secret-only-this-client-knows"

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, client, nil} =
      OAuth.register_client(%{
        "client_name" => "Claude",
        "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
      })

    %{
      client: client,
      conn: init_test_session(conn, %{"current_user_id" => user.id}),
      scope: scope
    }
  end

  test "shows the address to point an MCP client at", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/settings")

    assert html =~ "#{@issuer}/mcp"
    assert html =~ "Nothing is connected yet"
  end

  test "lists a connected app and disconnects it", %{client: client, conn: conn, scope: scope} do
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

    {:ok, tokens} =
      OAuth.exchange_authorization_code(%{
        "code" => code,
        "client_id" => client.id,
        "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
        "code_verifier" => @code_verifier
      })

    {:ok, view, html} = live(conn, ~p"/settings")

    assert html =~ "Claude"

    view |> element("#disconnect-#{client.id}") |> render_click()
    assert render(view) =~ "Disconnect Claude?"

    view |> element("#cancel-disconnect") |> render_click()
    refute render(view) =~ "Disconnect Claude?"

    view |> element("#disconnect-#{client.id}") |> render_click()
    html = view |> element("#confirm-disconnect-button") |> render_click()

    assert html =~ "Nothing is connected yet"
    assert {:error, :invalid_token} = OAuth.verify_access_token(tokens.access_token, @resource)
  end
end
