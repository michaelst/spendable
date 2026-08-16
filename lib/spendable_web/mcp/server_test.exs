defmodule SpendableWeb.MCP.ServerTest do
  # async: false because the tool runs inside the MCP session process, which only reaches the
  # test's data through a shared sandbox.
  use SpendableWeb.ConnCase, async: false

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.OAuth
  alias Spendable.Scope

  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"
  @code_verifier "a-secret-only-this-client-knows"
  @protocol_version "2025-06-18"

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

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

    {:ok, tokens} =
      OAuth.exchange_authorization_code(%{
        "code" => code,
        "client_id" => client.id,
        "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
        "code_verifier" => @code_verifier
      })

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{tokens.access_token}")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")

    initialized =
      post(conn, ~p"/mcp", %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{
          "protocolVersion" => @protocol_version,
          "capabilities" => %{},
          "clientInfo" => %{"name" => "test", "version" => "1"}
        }
      })

    assert %{"result" => %{"serverInfo" => %{"name" => "spendable"}}} = json_response(initialized, 200)
    assert [session_id] = get_resp_header(initialized, "mcp-session-id")

    conn = put_req_header(conn, "mcp-session-id", session_id)

    post(conn, ~p"/mcp", %{"jsonrpc" => "2.0", "method" => "notifications/initialized"})

    %{conn: conn, scope: scope}
  end

  test "runs a tool as the user the token was issued to", %{conn: conn, scope: scope} do
    {:ok, _budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    called =
      post(conn, ~p"/mcp", %{
        "jsonrpc" => "2.0",
        "id" => 2,
        "method" => "tools/call",
        "params" => %{"name" => "list_budgets", "arguments" => %{}}
      })

    assert %{"result" => %{"structuredContent" => %{"budgets" => [%{"name" => "Groceries"}]}}} =
             json_response(called, 200)
  end

  # The type arrives as a JSON string and is validated before anything casts it, so an enum of
  # atoms rejected every call that named one.
  test "takes a budget type as the JSON string a client sends", %{conn: conn} do
    called =
      post(conn, ~p"/mcp", %{
        "jsonrpc" => "2.0",
        "id" => 2,
        "method" => "tools/call",
        "params" => %{
          "name" => "create_budget",
          "arguments" => %{"name" => "Home Renovation", "type" => "tracking"}
        }
      })

    assert %{"result" => %{"structuredContent" => %{"budget" => %{"type" => "tracking"}}}} =
             json_response(called, 200)
  end

  test "keeps an ampersand in a name it is given", %{conn: conn} do
    called =
      post(conn, ~p"/mcp", %{
        "jsonrpc" => "2.0",
        "id" => 2,
        "method" => "tools/call",
        "params" => %{"name" => "create_budget", "arguments" => %{"name" => "Auto Insurance & Fees"}}
      })

    assert %{"result" => %{"structuredContent" => %{"budget" => %{"name" => "Auto Insurance & Fees"}}}} =
             json_response(called, 200)
  end

  test "refuses a call with no bearer token" do
    assert %{status: 401} =
             build_conn()
             |> put_req_header("content-type", "application/json")
             |> post(~p"/mcp", %{"jsonrpc" => "2.0", "id" => 1, "method" => "initialize"})
  end
end
