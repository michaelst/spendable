defmodule Spendable.OAuth.Actions.ExchangeAuthorizationCodeTest do
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
        state: "opaque"
      })

    %{
      client: client,
      params: %{
        "code" => code,
        "client_id" => client.id,
        "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
        "code_verifier" => @code_verifier
      }
    }
  end

  test "exchanges a code for an access token and a refresh token", %{params: params} do
    assert {:ok,
            %{
              access_token: "sp.at." <> _access,
              refresh_token: "sp.rt." <> _refresh,
              token_type: "Bearer",
              expires_in: 3600,
              scope: "mcp"
            }} = OAuth.exchange_authorization_code(params)
  end

  test "refuses a code to anyone who cannot produce every part of the grant", %{params: params} do
    for invalid <- [
          %{"code_verifier" => "not-the-verifier"},
          %{"redirect_uri" => "https://evil.test/callback"},
          %{"client_id" => "oc_someoneelse"},
          %{"code" => "sp.ac.bm90LWEtcmVhbC1jb2RlLi4u"}
        ] do
      assert {:error, :invalid_grant} =
               OAuth.exchange_authorization_code(Map.merge(params, invalid))
    end
  end

  test "refuses a code that has already been redeemed", %{params: params} do
    assert {:ok, _tokens} = OAuth.exchange_authorization_code(params)

    assert {:error, :invalid_grant} = OAuth.exchange_authorization_code(params)
  end

  test "refuses a confidential client that cannot produce its secret" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, client, secret} =
      OAuth.register_client(%{
        "client_name" => "Editor",
        "redirect_uris" => ["http://localhost:8123/callback"],
        "token_endpoint_auth_method" => "client_secret_basic"
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

    params = %{
      "code" => code,
      "client_id" => client.id,
      "redirect_uri" => "http://localhost:8123/callback",
      "code_verifier" => @code_verifier
    }

    assert {:error, :invalid_client} =
             OAuth.exchange_authorization_code(Map.put(params, "client_secret", "sp.cs.wrong"))

    assert {:ok, _tokens} = OAuth.exchange_authorization_code(Map.put(params, "client_secret", secret))
  end
end
