defmodule Spendable.OAuth.Actions.RevokeAuthorizationTest do
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

    scope = Scope.for_user(user)

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
        "client_id" => client_id,
        "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
        "code_verifier" => @code_verifier
      })

    %{client_id: client_id, scope: scope, tokens: tokens}
  end

  test "cuts off a client the user disconnects", %{client_id: client_id, scope: scope, tokens: tokens} do
    assert :ok = OAuth.revoke_authorization(scope, client_id)

    assert [] = OAuth.list_authorizations(scope)
    assert {:error, :invalid_token} = OAuth.verify_access_token(tokens.access_token, @resource)

    assert {:error, :invalid_grant} =
             OAuth.exchange_refresh_token(%{"refresh_token" => tokens.refresh_token, "client_id" => client_id})
  end

  test "cuts off a code the client had not redeemed yet", %{client_id: client_id, scope: scope} do
    {:ok, code, _redirect_uri} =
      OAuth.create_authorization_code(scope, %{
        client: %Client{id: client_id, redirect_uris: ["https://claude.ai/api/mcp/auth_callback"]},
        redirect_uri: "https://claude.ai/api/mcp/auth_callback",
        scope: "mcp",
        code_challenge: Base.url_encode64(:crypto.hash(:sha256, @code_verifier), padding: false),
        code_challenge_method: :S256,
        resource: @resource,
        state: nil
      })

    assert :ok = OAuth.revoke_authorization(scope, client_id)

    assert {:error, :invalid_grant} =
             OAuth.exchange_authorization_code(%{
               "code" => code,
               "client_id" => client_id,
               "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
               "code_verifier" => @code_verifier
             })
  end

  test "leaves an authorization that belongs to a different user", %{client_id: client_id, scope: scope, tokens: tokens} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert :ok = OAuth.revoke_authorization(Scope.for_user(other_user), client_id)

    assert [%{client_id: ^client_id}] = OAuth.list_authorizations(scope)
    assert {:ok, _user} = OAuth.verify_access_token(tokens.access_token, @resource)
  end
end
