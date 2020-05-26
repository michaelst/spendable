defmodule Spendable.User.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true

  test "create", %{conn: conn} do
    query = """
      mutation {
        createUser(
          email: "michaelst57@gmail.com",
          password: "password"
        ) {
          id
          email
          token
        }
      }
    """

    response =
      conn
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "createUser" => %{
                 "email" => "michaelst57@gmail.com",
                 "id" => _,
                 "token" => _
               }
             }
           } = response
  end

  test "required validation", %{conn: conn} do
    query = """
      mutation {
        createUser(
          email: null
          password: null
        ) {
          id
          email
          token
        }
      }
    """

    response =
      conn
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert response == %{
             "errors" => [
               %{
                 "locations" => [%{"column" => 7, "line" => 3}],
                 "message" => "Argument \"email\" has invalid value null."
               },
               %{
                 "locations" => [%{"column" => 7, "line" => 4}],
                 "message" => "Argument \"password\" has invalid value null."
               }
             ]
           }
  end

  test "unique validation", %{conn: conn} do
    query = """
      mutation {
        createUser(
          email: "michaelst57@gmail.com",
          password: "password"
        ) {
          id
          email
          token
        }
      }
    """

    conn
    |> post("/graphql", %{query: query})
    |> json_response(200)

    response =
      conn
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert response == %{
             "errors" => [
               %{
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "email: has already been taken",
                 "path" => ["createUser"]
               }
             ],
             "data" => nil
           }
  end
end
