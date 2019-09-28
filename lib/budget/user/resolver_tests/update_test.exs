defmodule Budget.User.Resolver.UpdateTest do
  use BudgetWeb.ConnCase, async: true

  alias Budget.User
  alias Budget.Repo

  test "update", %{conn: conn} do
    email = "#{Ecto.UUID.generate()}@example.com"

    user = struct(User) |> User.changeset(%{email: email, password: "password"}) |> Repo.insert!()

    query = """
      mutation {
        updateUser(
          id: #{user.id}
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
             "data" => %{
               "updateUser" => %{
                 "firstName" => "Michael",
                 "lastName" => "St Clair",
               }
             }
           } = response
  end
end
