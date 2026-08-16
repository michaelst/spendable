defmodule SpendableWeb.Api.MeControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User
  alias Spendable.Scope
  alias SpendableWeb.Api.ApiSpec

  @api_spec ApiSpec.spec()

  setup %{conn: conn} do
    {:ok, %User{id: user_id} = user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        image: "https://lh3.googleusercontent.com/a/photo"
      })

    {:ok, api_token} = Accounts.create_api_token(Scope.for_user(user), %{})

    %{conn: put_req_header(conn, "authorization", "Bearer " <> api_token.token), user_id: user_id}
  end

  test "returns the signed-in user", %{conn: conn, user_id: user_id} do
    response = conn |> get(~p"/api/me") |> json_response(200)

    assert_schema(response, "User", @api_spec)
    assert %{"id" => ^user_id, "image" => "https://lh3.googleusercontent.com/a/photo"} = response
  end

  test "rejects an unknown token", %{conn: conn} do
    conn = put_req_header(conn, "authorization", "Bearer nope")

    assert %{"errors" => [%{"code" => "unauthenticated"}]} =
             conn |> get(~p"/api/me") |> json_response(401)
  end

  test "rejects a malformed authorization header", %{conn: conn} do
    conn = put_req_header(conn, "authorization", "Basic dXNlcjpwYXNz")

    assert %{"errors" => [%{"code" => "unauthenticated"}]} =
             conn |> get(~p"/api/me") |> json_response(401)
  end
end
