defmodule SpendableWeb.Api.IdentityControllerTest do
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

    {:ok, user} = Accounts.sign_in_with_oauth("google", TestData.Google.id_token())
    scope = Scope.for_user(user)
    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    %{conn: conn, scope: scope}
  end

  test "adds another way to sign in", %{conn: conn} do
    body = %{"provider" => "apple", "id_token" => TestData.Apple.id_token()}

    response = conn |> post(~p"/api/identities", body) |> json_response(201)

    assert %{"provider" => "apple"} = response
    assert_schema(response, "Identity", @api_spec)
  end

  test "the account then lists both ways in", %{conn: conn} do
    body = %{"provider" => "apple", "id_token" => TestData.Apple.id_token()}
    conn |> post(~p"/api/identities", body) |> json_response(201)

    response = conn |> get(~p"/api/me") |> json_response(200)

    assert %{"identities" => [%{"provider" => "google"}, %{"provider" => "apple"}]} = response
    assert_schema(response, "User", @api_spec)
  end

  test "adding a provider already on the account is a conflict", %{conn: conn} do
    body = %{"provider" => "google", "id_token" => TestData.Google.id_token()}

    assert %{"errors" => [%{"code" => "identity_already_linked"}]} =
             conn |> post(~p"/api/identities", body) |> json_response(409)
  end

  test "adding a provider already on someone else's account is a conflict", %{conn: conn} do
    {:ok, _theirs} = Accounts.sign_in_with_oauth("apple", TestData.Apple.id_token())

    body = %{"provider" => "apple", "id_token" => TestData.Apple.id_token()}

    assert %{"errors" => [%{"code" => "identity_claimed"}]} =
             conn |> post(~p"/api/identities", body) |> json_response(409)
  end

  test "an unverifiable token is rejected", %{conn: conn} do
    body = %{
      "provider" => "apple",
      "id_token" => TestData.Apple.id_token(%{"aud" => "com.someone.else"})
    }

    assert %{"errors" => [%{"code" => "invalid_id_token"}]} =
             conn |> post(~p"/api/identities", body) |> json_response(401)
  end

  test "linking needs a signed-in account", %{conn: conn} do
    body = %{"provider" => "apple", "id_token" => TestData.Apple.id_token()}

    assert %{"errors" => [%{"code" => "unauthenticated"}]} =
             conn
             |> delete_req_header("authorization")
             |> post(~p"/api/identities", body)
             |> json_response(401)
  end

  test "removes a way to sign in", %{conn: conn, scope: scope} do
    {:ok, apple} = Accounts.link_identity(scope, "apple", TestData.Apple.id_token())

    assert conn |> delete(~p"/api/identities/#{apple.id}") |> response(204)
    assert %{"identities" => [%{"provider" => "google"}]} = conn |> get(~p"/api/me") |> json_response(200)
  end

  test "removing the last way in is a conflict", %{conn: conn, scope: scope} do
    [google] = Accounts.list_identities(scope)

    assert %{"errors" => [%{"code" => "last_identity"}]} =
             conn |> delete(~p"/api/identities/#{google.id}") |> json_response(409)
  end

  test "an unknown identity is not found", %{conn: conn} do
    assert %{"errors" => [%{"code" => "identity_not_found"}]} =
             conn |> delete(~p"/api/identities/usi_nope") |> json_response(404)
  end
end
