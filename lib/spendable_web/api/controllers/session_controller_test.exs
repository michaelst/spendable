defmodule SpendableWeb.Api.SessionControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Scope
  alias Spendable.TestData
  alias SpendableWeb.Api.ApiSpec

  @api_spec ApiSpec.spec()

  setup %{conn: conn} do
    stub(TeslaMock, :call, fn %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
      TeslaHelper.response(body: TestData.Google.certs())
    end)

    %{conn: put_req_header(conn, "content-type", "application/json")}
  end

  test "signs in with a Google ID token", %{conn: conn} do
    body = %{"provider" => "google", "id_token" => TestData.Google.id_token()}

    response = conn |> post(~p"/api/session", body) |> json_response(201)

    assert_schema(response, "Session", @api_spec)
    assert {:ok, _api_token} = Accounts.authenticate_api_token(response["token"])
  end

  test "records the device name", %{conn: conn} do
    body = %{
      "provider" => "google",
      "id_token" => TestData.Google.id_token(),
      "device_name" => "iPhone"
    }

    assert %{"device_name" => "iPhone"} = conn |> post(~p"/api/session", body) |> json_response(201)
  end

  test "rejects an ID token Google did not sign", %{conn: conn} do
    body = %{"provider" => "google", "id_token" => TestData.Google.id_token_from_unknown_key()}

    response = conn |> post(~p"/api/session", body) |> json_response(401)

    assert %{"errors" => [%{"code" => "invalid_id_token"}]} = response
    assert_schema(response, "Errors", @api_spec)
  end

  test "rejects a request missing the ID token", %{conn: conn} do
    response = conn |> post(~p"/api/session", %{"provider" => "google"}) |> json_response(422)

    assert_schema(response, "Errors", @api_spec)
  end

  test "rejects an unsupported provider", %{conn: conn} do
    body = %{"provider" => "myspace", "id_token" => TestData.Google.id_token()}

    assert %{"errors" => [_invalid]} = conn |> post(~p"/api/session", body) |> json_response(422)
  end

  test "signing out revokes the token used", %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, api_token} = Accounts.create_api_token(Scope.for_user(user), %{})

    conn = put_req_header(conn, "authorization", "Bearer " <> api_token.token)

    assert conn |> delete(~p"/api/session") |> response(204)
    assert {:error, :invalid_token} = Accounts.authenticate_api_token(api_token.token)
  end

  test "signing out without a token is unauthorized", %{conn: conn} do
    response = conn |> delete(~p"/api/session") |> json_response(401)

    assert %{"errors" => [%{"code" => "unauthenticated"}]} = response
    assert_schema(response, "Errors", @api_spec)
  end
end
