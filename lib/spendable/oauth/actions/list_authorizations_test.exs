defmodule Spendable.OAuth.Actions.ListAuthorizationsTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.OAuth
  alias Spendable.OAuth.Schemas.Client
  alias Spendable.Scope

  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"
  @code_verifier "a-secret-only-this-client-knows"

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, %Client{id: client_id} = client, nil} =
      OAuth.register_client(%{
        "client_name" => "Claude",
        "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
      })

    %{client: client, client_id: client_id, scope: Scope.for_user(user)}
  end

  test "lists a client the user has authorized", %{client: client, client_id: client_id, scope: scope} do
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

    {:ok, _tokens} =
      OAuth.exchange_authorization_code(%{
        "code" => code,
        "client_id" => client.id,
        "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
        "code_verifier" => @code_verifier
      })

    assert [%{client_id: ^client_id, client_name: "Claude", sessions: 1, last_authorized_at: %DateTime{}}] =
             OAuth.list_authorizations(scope)
  end

  test "does not list another user's authorizations", %{client: client, scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, code, _redirect_uri} =
      OAuth.create_authorization_code(Scope.for_user(other_user), %{
        client: client,
        redirect_uri: "https://claude.ai/api/mcp/auth_callback",
        scope: "mcp",
        code_challenge: Base.url_encode64(:crypto.hash(:sha256, @code_verifier), padding: false),
        code_challenge_method: :S256,
        resource: @resource,
        state: nil
      })

    {:ok, _tokens} =
      OAuth.exchange_authorization_code(%{
        "code" => code,
        "client_id" => client.id,
        "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
        "code_verifier" => @code_verifier
      })

    assert [] = OAuth.list_authorizations(scope)
  end
end
