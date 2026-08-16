defmodule Spendable.OAuth.Actions.GetClientTest do
  use Spendable.DataCase, async: true

  alias Spendable.OAuth
  alias Spendable.OAuth.Schemas.Client

  test "returns a registered client" do
    {:ok, %Client{id: client_id}, nil} =
      OAuth.register_client(%{
        "client_name" => "Claude",
        "redirect_uris" => ["https://claude.ai/api/mcp/auth_callback"]
      })

    assert {:ok, %Client{id: ^client_id, client_name: "Claude"}} = OAuth.get_client(client_id)
  end

  test "reports an unregistered client id as not found" do
    assert {:error, :client_not_found} = OAuth.get_client("oc_nosuchclient")
  end

  test "builds a client from the metadata document a url client id points at" do
    expect(TeslaMock, :call, fn %{url: "https://client.invalid/mcp.json"}, _opts ->
      TeslaHelper.response(
        body: %{
          "client_id" => "https://client.invalid/mcp.json",
          "client_name" => "Invalid Editor",
          "redirect_uris" => ["https://client.invalid/callback"]
        }
      )
    end)

    assert {:ok,
            %Client{
              id: "https://client.invalid/mcp.json",
              client_name: "Invalid Editor",
              redirect_uris: ["https://client.invalid/callback"],
              token_endpoint_auth_method: :none
            }} = OAuth.get_client("https://client.invalid/mcp.json")
  end

  test "refuses a metadata document that redirects somewhere it does not own" do
    expect(TeslaMock, :call, fn _env, _opts ->
      TeslaHelper.response(
        body: %{
          "client_id" => "https://client.invalid/mcp.json",
          "redirect_uris" => ["https://elsewhere.invalid/callback"]
        }
      )
    end)

    assert {:error, :client_not_found} = OAuth.get_client("https://client.invalid/mcp.json")
  end

  test "refuses a url client id that resolves to an address inside the network" do
    for host <- [
          "localhost",
          "127.0.0.1",
          "0.0.0.0",
          "10.1.2.3",
          "172.16.0.1",
          "192.168.1.1",
          "169.254.169.254",
          "100.64.0.1",
          "198.18.0.1",
          "239.0.0.1",
          "[::1]",
          "[::]",
          "[fd00::1]",
          "[fe80::1]",
          "[::ffff:10.0.0.1]"
        ] do
      assert {:error, :client_not_found} = OAuth.get_client("https://#{host}/mcp.json")
    end
  end

  test "refuses a client id that is not an https url it can fetch" do
    assert {:error, :client_not_found} = OAuth.get_client("https:///mcp.json")
  end

  test "does fetch a url client id out on the public internet" do
    for host <- ["8.8.8.8", "[2001:4860:4860::8888]"] do
      expect(TeslaMock, :call, fn _env, _opts -> TeslaHelper.response(status: 404) end)

      assert {:error, :client_not_found} = OAuth.get_client("https://#{host}/mcp.json")
    end
  end
end
