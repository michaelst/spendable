defmodule Spendable.User.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true

  test "update", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      mutation {
        updateUser(
          email: "something@example.com"
        ) {
          email
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "updateUser" => %{
                 "email" => "something@example.com"
               }
             }
           } = response
  end

  test "unauthenticated", %{conn: conn} do
    query = """
      mutation {
        updateUser(
          email: "something@example.com"
        ) {
          email
        }
      }
    """

    response =
      conn
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => nil,
             "errors" => [
               %{
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "unauthenticated",
                 "path" => ["updateUser"]
               }
             ]
           } = response
  end
end
