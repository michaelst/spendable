defmodule Spendable.OAuth.Actions.ExchangeRefreshTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.OAuth
  alias Spendable.Scope

  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"
  @code_verifier "a-secret-only-this-client-knows"

  setup do
    {:ok, user} =
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

    %{client: client, tokens: tokens, user: user}
  end

  test "rotates a refresh token for a fresh pair", %{client: client, tokens: tokens} do
    assert {:ok, %{access_token: "sp.at." <> _access, refresh_token: refreshed}} =
             OAuth.exchange_refresh_token(%{
               "refresh_token" => tokens.refresh_token,
               "client_id" => client.id
             })

    assert refreshed != tokens.refresh_token
  end

  test "revokes the family the first time a spent refresh token comes back", %{client: client, tokens: tokens} do
    {:ok, second} =
      OAuth.exchange_refresh_token(%{"refresh_token" => tokens.refresh_token, "client_id" => client.id})

    assert {:error, :invalid_grant} =
             OAuth.exchange_refresh_token(%{"refresh_token" => tokens.refresh_token, "client_id" => client.id})

    assert {:error, :invalid_grant} =
             OAuth.exchange_refresh_token(%{"refresh_token" => second.refresh_token, "client_id" => client.id})

    assert {:error, :invalid_token} = OAuth.verify_access_token(second.access_token, @resource)
  end

  test "refuses to refresh for a confidential client that cannot produce its secret", %{user: user} do
    {:ok, client, secret} =
      OAuth.register_client(%{
        "client_name" => "Editor",
        "redirect_uris" => ["http://localhost:8123/callback"],
        "token_endpoint_auth_method" => "client_secret_post"
      })

    {:ok, code, _redirect_uri} =
      OAuth.create_authorization_code(Scope.for_user(user), %{
        client: client,
        redirect_uri: "http://localhost:8123/callback",
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
        "client_secret" => secret,
        "redirect_uri" => "http://localhost:8123/callback",
        "code_verifier" => @code_verifier
      })

    assert {:error, :invalid_client} =
             OAuth.exchange_refresh_token(%{
               "refresh_token" => tokens.refresh_token,
               "client_id" => client.id,
               "client_secret" => "sp.cs.wrong"
             })

    assert {:ok, _rotated} =
             OAuth.exchange_refresh_token(%{
               "refresh_token" => tokens.refresh_token,
               "client_id" => client.id,
               "client_secret" => secret
             })
  end

  test "refuses a refresh token that is not this client's", %{client: client, tokens: tokens} do
    for invalid <- [
          %{"client_id" => "oc_someoneelse"},
          %{"refresh_token" => "sp.rt.bm90LWEtcmVhbC10b2tlbi4u"},
          %{"refresh_token" => "not-a-token"}
        ] do
      assert {:error, :invalid_grant} =
               OAuth.exchange_refresh_token(
                 Map.merge(%{"refresh_token" => tokens.refresh_token, "client_id" => client.id}, invalid)
               )
    end
  end
end
