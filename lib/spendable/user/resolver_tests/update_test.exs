defmodule Spendable.User.Resolver.UpdateTest do
  use SpendableWeb.ConnCase, async: true

  test "update", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      mutation {
        updateUser(
          firstName: "Michael"
          last_name: "St Clair"
        ) {
          firstName
          lastName
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "updateUser" => %{
                 "firstName" => "Michael",
                 "lastName" => "St Clair"
               }
             }
           } = response
  end

  test "unauthenticated", %{conn: conn} do
    query = """
      mutation {
        updateUser(
          firstName: "Michael"
          last_name: "St Clair"
        ) {
          firstName
          lastName
        }
      }
    """

    response =
      conn
      |> post("/", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{"updateUser" => nil},
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
