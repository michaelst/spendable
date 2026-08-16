defmodule Spendable.OAuth.Actions.RegisterClientTest do
  use Spendable.DataCase, async: true

  alias Spendable.OAuth
  alias Spendable.OAuth.Schemas.Client

  test "registers a public client with no secret" do
    assert {:ok, %Client{client_name: "Claude", token_endpoint_auth_method: :none}, nil} =
             OAuth.register_client(%{
               "client_name" => "Claude",
               "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
             })
  end

  test "issues a secret to a confidential client, storing only its hash" do
    assert {:ok, %Client{secret_verify_hash: <<_sha256::binary-size(32)>>}, "sp.cs." <> _rest} =
             OAuth.register_client(%{
               "client_name" => "Editor",
               "redirect_uris" => ["http://localhost:8123/callback"],
               "token_endpoint_auth_method" => "client_secret_basic"
             })
  end

  test "refuses a client whose redirect uris cannot receive a code safely" do
    assert {:error, changeset} =
             OAuth.register_client(%{
               "client_name" => "Editor",
               "redirect_uris" => ["http://evil.example.com/callback"]
             })

    assert %{redirect_uris: ["must be absolute https (or http loopback) URIs"]} = errors_on(changeset)

    assert {:error, changeset} =
             OAuth.register_client(%{
               "client_name" => "Editor",
               "redirect_uris" => ["https://claude.ai/callback#fragment"]
             })

    assert %{redirect_uris: ["must be absolute https (or http loopback) URIs"]} = errors_on(changeset)

    assert {:error, changeset} = OAuth.register_client(%{"client_name" => "Editor"})
    assert %{redirect_uris: ["can't be blank"]} = errors_on(changeset)
  end
end
