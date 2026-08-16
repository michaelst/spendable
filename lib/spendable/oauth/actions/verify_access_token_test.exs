defmodule Spendable.OAuth.Actions.VerifyAccessTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User
  alias Spendable.OAuth
  alias Spendable.Scope

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

    %{client: client, tokens: tokens, user_id: user_id}
  end

  test "identifies the user an access token was issued to", %{tokens: tokens, user_id: user_id} do
    assert {:ok, %User{id: ^user_id}} = OAuth.verify_access_token(tokens.access_token, @resource)
  end

  test "refuses a token presented anywhere but the resource it was bound to", %{tokens: tokens} do
    assert {:error, :invalid_token} =
             OAuth.verify_access_token(tokens.access_token, "https://elsewhere.test/mcp")
  end

  test "refuses a token that was never issued", %{tokens: tokens} do
    for invalid <- ["sp.at.bm90LWEtcmVhbC10b2tlbi4u", "not-a-token", tokens.refresh_token] do
      assert {:error, :invalid_token} = OAuth.verify_access_token(invalid, @resource)
    end
  end

  test "refuses a token whose family was revoked", %{client: client, tokens: tokens} do
    {:ok, second} =
      OAuth.exchange_refresh_token(%{"refresh_token" => tokens.refresh_token, "client_id" => client.id})

    {:ok, _third} = OAuth.exchange_refresh_token(%{"refresh_token" => second.refresh_token, "client_id" => client.id})

    {:error, :invalid_grant} =
      OAuth.exchange_refresh_token(%{"refresh_token" => tokens.refresh_token, "client_id" => client.id})

    assert {:error, :invalid_token} = OAuth.verify_access_token(second.access_token, @resource)
  end
end
