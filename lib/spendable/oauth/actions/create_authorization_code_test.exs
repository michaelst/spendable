defmodule Spendable.OAuth.Actions.CreateAuthorizationCodeTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.OAuth
  alias Spendable.OAuth.Schemas.Client
  alias Spendable.Scope

  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, client, nil} =
      OAuth.register_client(%{
        "client_name" => "Claude",
        "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
      })

    %{
      scope: Scope.for_user(user),
      request: %{
        client: client,
        redirect_uri: "https://claude.ai/api/mcp/auth_callback",
        scope: "mcp",
        code_challenge: "abc123",
        code_challenge_method: :S256,
        resource: @resource,
        state: "opaque"
      }
    }
  end

  test "issues a code the client can exchange", %{scope: scope, request: request} do
    assert {:ok, "sp.ac." <> _rest, redirect_uri} = OAuth.create_authorization_code(scope, request)
    assert redirect_uri =~ "https://claude.ai/api/mcp/auth_callback?code=sp.ac."
    assert redirect_uri =~ "&state=opaque"
  end

  test "records a client identified by url, which has no registration to point at", %{
    scope: scope,
    request: request
  } do
    request = %{
      request
      | client: %Client{
          id: "https://client.invalid/mcp.json",
          client_name: "Invalid Editor",
          redirect_uris: ["https://client.invalid/callback"],
          scope: "mcp"
        },
        redirect_uri: "https://client.invalid/callback"
    }

    assert {:ok, "sp.ac." <> _rest, redirect_uri} = OAuth.create_authorization_code(scope, request)
    assert redirect_uri =~ "https://client.invalid/callback?code=sp.ac."
  end
end
