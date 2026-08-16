defmodule Spendable.OAuth.Actions.ValidateAuthorizationRequestTest do
  use Spendable.DataCase, async: true

  alias Spendable.OAuth
  alias Spendable.OAuth.Schemas.Client

  @resource "#{Application.compile_env(:spendable, :issuer)}/mcp"

  setup do
    {:ok, client, nil} =
      OAuth.register_client(%{
        "client_name" => "Claude",
        "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
      })

    %{client: client}
  end

  test "accepts a request the consent screen can act on", %{client: %Client{id: client_id} = client} do
    assert {:ok,
            %{
              client: %Client{id: ^client_id},
              redirect_uri: "https://claude.ai/api/mcp/auth_callback",
              scope: "mcp",
              code_challenge: "abc123",
              code_challenge_method: :S256,
              state: "opaque"
            }} =
             OAuth.validate_authorization_request(%{
               "client_id" => client.id,
               "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
               "response_type" => "code",
               "code_challenge" => "abc123",
               "code_challenge_method" => "S256",
               "resource" => @resource,
               "state" => "opaque"
             })
  end

  test "refuses a request whose client or redirect uri cannot be trusted", %{client: client} do
    assert {:error, :missing_client_id} = OAuth.validate_authorization_request(%{})

    assert {:error, :unknown_client} = OAuth.validate_authorization_request(%{"client_id" => "oc_nosuchclient"})

    assert {:error, :missing_redirect_uri} =
             OAuth.validate_authorization_request(%{"client_id" => client.id})

    assert {:error, :invalid_redirect_uri} =
             OAuth.validate_authorization_request(%{
               "client_id" => client.id,
               "redirect_uri" => "https://evil.test/callback"
             })
  end

  test "lets a native client come back on whatever local port it bound" do
    {:ok, client, nil} =
      OAuth.register_client(%{
        "client_name" => "Editor",
        "redirect_uris" => ["http://localhost:8123/callback"]
      })

    assert {:ok, %{redirect_uri: "http://localhost:52341/callback"}} =
             OAuth.validate_authorization_request(%{
               "client_id" => client.id,
               "redirect_uri" => "http://localhost:52341/callback",
               "response_type" => "code",
               "code_challenge" => "abc123",
               "code_challenge_method" => "S256",
               "resource" => @resource
             })

    assert {:error, :invalid_redirect_uri} =
             OAuth.validate_authorization_request(%{
               "client_id" => client.id,
               "redirect_uri" => "http://localhost:52341/somewhere-else"
             })
  end

  test "reports anything else on the client's own redirect uri", %{client: client} do
    request = %{
      "client_id" => client.id,
      "redirect_uri" => "https://claude.ai/api/mcp/auth_callback",
      "response_type" => "code",
      "code_challenge" => "abc123",
      "code_challenge_method" => "S256",
      "resource" => @resource,
      "state" => "opaque"
    }

    for {invalid, error} <- [
          {%{"response_type" => "token"}, "unsupported_response_type"},
          {%{"code_challenge_method" => "plain"}, "invalid_request"},
          {%{"code_challenge" => nil}, "invalid_request"},
          {%{"scope" => "everything"}, "invalid_scope"},
          {%{"resource" => "https://elsewhere.test/mcp"}, "invalid_target"}
        ] do
      redirect = "https://claude.ai/api/mcp/auth_callback?error=#{error}&state=opaque"

      assert {:redirect, ^redirect} = OAuth.validate_authorization_request(Map.merge(request, invalid))
    end
  end
end
