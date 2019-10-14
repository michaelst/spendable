defmodule Spendable.User.Resolver.CreateTest do
  use SpendableWeb.ConnCase, async: true

  test "create", %{conn: conn} do
    query = """
      mutation {
        createUser(
          firstName: "Michael",
          last_name: "St Clair",
          email: "michaelst57@gmail.com",
          password: "password"
        ) {
          id, firstName, lastName, email, token
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
                 "firstName" => "Michael",
                 "id" => _,
                 "lastName" => "St Clair",
                 "token" => _
               }
             }
           } = response
  end

  test "required validation", %{conn: conn} do
    query = """
      mutation {
        createUser(
          firstName: "Michael",
          last_name: "St Clair",
        ) {
          id, firstName, lastName, email, token
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
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "email: can't be blank",
                 "path" => ["createUser"]
               },
               %{
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "password: can't be blank",
                 "path" => ["createUser"]
               }
             ],
             "data" => %{"createUser" => nil}
           }
  end

  test "unique validation", %{conn: conn} do
    query = """
      mutation {
        createUser(
          email: "michaelst57@gmail.com",
          password: "password"
        ) {
          id, firstName, lastName, email, token
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
             "data" => %{"createUser" => nil}
           }
  end
end
