defmodule Budget.User.Resolver.LoginTest do
  use BudgetWeb.ConnCase, async: true
  alias Budget.User

  test "login", %{conn: conn} do
    email = "#{Ecto.UUID.generate()}@example.com"

    struct(User) |> User.changeset(%{email: email, password: "password"}) |> Budget.Repo.insert!()

    query = """
      mutation {
        login(
          email: "#{email}",
          password: "password"
        ) {
          id, firstName, lastName, email, token
        }
      }
    """

    response =
      conn
      |> post("/", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "login" => %{
                 "email" => ^email,
                 "firstName" => nil,
                 "id" => _,
                 "lastName" => nil,
                 "token" => _
               }
             }
           } = response
  end

  test "invalid login", %{conn: conn} do
    email = "#{Ecto.UUID.generate()}@example.com"

    struct(User) |> User.changeset(%{email: email, password: "password"}) |> Budget.Repo.insert!()

    query = """
      mutation {
        login(
          email: "#{email}",
          password: "password1"
        ) {
          id, firstName, lastName, email, token
        }
      }
    """

    response =
      conn
      |> post("/", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{"login" => nil},
             "errors" => [
               %{
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "Incorrect login credentials",
                 "path" => ["login"]
               }
             ]
           } == response
  end
end
