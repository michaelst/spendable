defmodule SpendableWeb.Api.SessionControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Scope
  alias Spendable.TestData
  alias SpendableWeb.Api.ApiSpec

  @api_spec ApiSpec.spec()

  setup %{conn: conn} do
    stub(TeslaMock, :call, fn
      %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
        TeslaHelper.response(body: TestData.Google.certs())

      %{url: "https://appleid.apple.com/auth/keys"}, _opts ->
        TeslaHelper.response(body: TestData.Apple.certs())
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

  test "signs in with an Apple ID token", %{conn: conn} do
    body = %{"provider" => "apple", "id_token" => TestData.Apple.id_token()}

    response = conn |> post(~p"/api/session", body) |> json_response(201)

    assert_schema(response, "Session", @api_spec)
    assert {:ok, _api_token} = Accounts.authenticate_api_token(response["token"])
  end

  # Signing in is not how two providers reach one account - linking from inside one is.
  test "each provider signs into its own account until they are linked", %{conn: conn} do
    google = %{"provider" => "google", "id_token" => TestData.Google.id_token()}
    apple = %{"provider" => "apple", "id_token" => TestData.Apple.id_token()}

    %{"token" => google_token} = conn |> post(~p"/api/session", google) |> json_response(201)
    %{"token" => apple_token} = conn |> post(~p"/api/session", apple) |> json_response(201)

    {:ok, %{user: %{id: user_id}}} = Accounts.authenticate_api_token(google_token)
    {:ok, %{user: %{id: apple_user_id}}} = Accounts.authenticate_api_token(apple_token)

    refute apple_user_id == user_id
  end

  test "registers the device for push", %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, api_token} = Accounts.create_api_token(Scope.for_user(user), %{})
    apns_token = String.duplicate("ab", 32)

    conn = put_req_header(conn, "authorization", "Bearer " <> api_token.token)

    assert conn |> patch(~p"/api/session", %{"apns_token" => apns_token}) |> response(204)
    assert {:ok, %{apns_token: ^apns_token}} = Accounts.authenticate_api_token(api_token.token)
  end

  test "rejects a device token that is not one", %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, api_token} = Accounts.create_api_token(Scope.for_user(user), %{})

    response =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> patch(~p"/api/session", %{"apns_token" => "nope"})
      |> json_response(422)

    assert_schema(response, "Errors", @api_spec)
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
