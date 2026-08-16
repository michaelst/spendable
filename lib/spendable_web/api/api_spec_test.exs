defmodule SpendableWeb.Api.ApiSpecTest do
  use SpendableWeb.ConnCase, async: true

  test "serves the spec the Dart client is generated from", %{conn: conn} do
    response = conn |> get(~p"/api/openapi.json") |> json_response(200)

    assert %{"info" => %{"title" => "Spendable"}, "paths" => paths} = response
    assert Map.has_key?(paths, "/api/session")
  end

  test "documents bearer auth" do
    assert %{security: [%{"bearer" => []}]} = SpendableWeb.Api.ApiSpec.spec()
  end
end
